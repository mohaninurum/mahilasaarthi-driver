import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:mahilasaarthi/constants/app_strings.dart';
import 'package:mahilasaarthi/models/vehicle.dart';
import 'package:mahilasaarthi/requests/auth.request.dart';
import 'package:mahilasaarthi/requests/general.request.dart';
import 'package:mahilasaarthi/services/alert.service.dart';
import 'package:mahilasaarthi/utils/utils.dart';
import 'package:mahilasaarthi/traits/qrcode_scanner.trait.dart';
import 'package:mahilasaarthi/widgets/bottomsheets/account_verification_entry.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'base.view_model.dart';
import 'package:velocity_x/velocity_x.dart';

class RegisterViewModel extends MyBaseViewModel with QrcodeScannerTrait {
  //the textediting controllers
  TextEditingController carMakeTEC = new TextEditingController();
  TextEditingController carModelTEC = new TextEditingController();
  List<String> types = ["Taxi"];
  List<VehicleType> vehicleTypes = [];
  String selectedDriverType = "taxi";
  List<CarMake> carMakes = [];
  List<CarModel> carModels = [];
  CarMake? selectedCarMake;
  CarModel? selectedCarModel;
  List<File> selectedDocuments = [];
  bool hidePassword = true;
  late Country selectedCountry;
  String? firebaseToken;
  String? accountPhoneNumber;
  bool otpLogin = false;

  //
  AuthRequest _authRequest = AuthRequest();
  GeneralRequest _generalRequest = GeneralRequest();

  RegisterViewModel(BuildContext context) {
    this.viewContext = context;
    try {
      this.selectedCountry = Country.parse(AppStrings.countryCode
          .toUpperCase()
          .replaceAll("AUTO,", "")
          .split(",")[0]);
    } catch (error) {
      this.selectedCountry = Country.parse("us");
    }
    notifyListeners();
  }

  // Add this property to store the selected selfie image
  File? _selfieImage;

  // Getter for the selfie image
  File? get selfieImage => _selfieImage;

  // Setter to update the selfie image
  set selfieImage(File? value) {
    _selfieImage = value;
    notifyListeners();
  }

  // Method to handle the selected selfie image
  void onSelfieSelected(File image) {
    selfieImage = image;
  }

  @override
  void initialise() {
    super.initialise();
    fetchVehicleTypes();
    fetchCarMakes();
  }

  showCountryDialPicker() {
    showCountryPicker(
      context: viewContext,
      showPhoneCode: true,
      onSelect: (value) => countryCodeSelected(value),
    );
  }

  countryCodeSelected(Country country) {
    selectedCountry = country;
    notifyListeners();
  }

  void onDocumentsSelected(List<File> documents) {
    selectedDocuments = documents;
    notifyListeners();
  }

  void onSelectedDriverType(String? value) {
    selectedDriverType = value ?? "regular";
    notifyListeners();
  }

  onCarMakeSelected(CarMake value) {
    selectedCarMake = value;
    carMakeTEC.text = value.name;
    notifyListeners();
    fetchCarModel();
  }

  onCarModelSelected(CarModel value) {
    selectedCarModel = value;
    carModelTEC.text = value.name;
    notifyListeners();
  }

  void fetchVehicleTypes() async {
    setBusyForObject(vehicleTypes, true);
    try {
      vehicleTypes = await _generalRequest.getVehicleTypes();
    } catch (error) {
      toastError("$error");
    }
    setBusyForObject(vehicleTypes, false);
  }

  void fetchCarMakes() async {
    setBusyForObject(carMakes, true);
    try {
      carMakes = await _generalRequest.getCarMakes();
    } catch (error) {
      toastError("$error");
    }
    setBusyForObject(carMakes, false);
  }

  void fetchCarModel() async {
    setBusyForObject(carModels, true);
    try {
      carModels = await _generalRequest.getCarModels(
        carMakeId: selectedCarMake?.id,
      );
    } catch (error) {
      toastError("$error");
    }
    setBusyForObject(carModels, false);
  }

  void processRegister() async {
    // Validate returns true if the form is valid, otherwise false.
    if (formBuilderKey.currentState!.saveAndValidate()) {
      if (selectedCarMake == null) {
        toastError("Please select a Vehicle Make from the dropdown".tr());
        return;
      }
      if (selectedCarModel == null) {
        toastError("Please select a Vehicle Model from the dropdown".tr());
        return;
      }
      setBusy(true);
      try {
        Map<String, dynamic> mValues = formBuilderKey.currentState!.value;
        String phone = mValues['phone'].toString();
        accountPhoneNumber =
            Utils.getFormattedPhoneNumber(phone, selectedCountry.phoneCode);

        // check if phone number already exists
        final apiResponse = await _authRequest.verifyPhoneAccount(
          accountPhoneNumber!,
        );

        if (apiResponse.allGood) {
          toastError("An account with this phone number already exists".tr());
          setBusy(false);
          return;
        }

        // BYPASS OTP FOR NOW
        await finishRegistration();
        return;

        if (AppStrings.isFirebaseOtp) {
          await processFirebaseOTPVerification();
        } else if (AppStrings.isCustomOtp) {
          await processCustomOTPVerification();
        } else {
          await finishRegistration();
        }
      } catch (error) {
        toastError("$error");
        setBusy(false);
      }
    }
  }

  Future<void> processFirebaseOTPVerification() async {
    setBusy(true);
    print(
        "RegisterViewModel: processFirebaseOTPVerification starting for number: $accountPhoneNumber");
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: accountPhoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        print(
            "RegisterViewModel: verificationCompleted called. credential: $credential");
        try {
          UserCredential userCredential =
              await FirebaseAuth.instance.signInWithCredential(credential);
          firebaseToken = await userCredential.user?.getIdToken();
          firebaseVerificationId = credential.verificationId;
          await finishRegistration();
        } catch (error) {
          setBusy(false);
          print("RegisterViewModel: verificationCompleted error: $error");
          toastError("$error");
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        setBusy(false);
        print(
            "RegisterViewModel: verificationFailed called. Error code: ${e.code}, Message: ${e.message}");
        if (e.code == 'invalid-phone-number') {
          toastError("Invalid Phone Number".tr());
        } else {
          toastError(e.message ?? "Failed".tr());
        }
      },
      codeSent: (String verificationId, int? resendToken) async {
        print(
            "RegisterViewModel: codeSent called. verificationId: $verificationId, resendToken: $resendToken");
        firebaseVerificationId = verificationId;
        setBusy(false);
        showVerificationEntry();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print(
            "RegisterViewModel: codeAutoRetrievalTimeout called. verificationId: $verificationId");
      },
    );
  }

  Future<void> processCustomOTPVerification() async {
    setBusy(true);
    try {
      await _authRequest.sendOTP(accountPhoneNumber!);
      setBusy(false);
      showVerificationEntry();
    } catch (error) {
      setBusy(false);
      toastError("$error");
    }
  }

  void showVerificationEntry() async {
    setBusy(false);
    await viewContext.push(
      (context) => AccountVerificationEntry(
        vm: this,
        phone: accountPhoneNumber!,
        onSubmit: (smsCode) {
          if (AppStrings.isFirebaseOtp) {
            verifyFirebaseOTP(smsCode);
          } else {
            verifyCustomOTP(smsCode);
          }
          viewContext.pop();
        },
        onResendCode: AppStrings.isCustomOtp
            ? () async {
                try {
                  final response =
                      await _authRequest.sendOTP(accountPhoneNumber!);
                  toastSuccessful(response.message ?? "Success".tr());
                } catch (error) {
                  toastError("$error");
                }
              }
            : () async {
                await processFirebaseOTPVerification();
              },
      ),
    );
  }

  void verifyFirebaseOTP(String smsCode) async {
    setBusy(true);
    try {
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: firebaseVerificationId!,
        smsCode: smsCode,
      );
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
      firebaseToken = await userCredential.user?.getIdToken();
      await finishRegistration();
    } catch (error) {
      setBusy(false);
      toastError("$error");
    }
  }

  void verifyCustomOTP(String smsCode) async {
    setBusy(true);
    try {
      final apiResponse = await _authRequest.verifyOTP(
        accountPhoneNumber!,
        smsCode,
        isLogin: false,
      );
      firebaseToken = apiResponse.body["token"];
      await finishRegistration();
    } catch (error) {
      setBusy(false);
      toastError("$error");
    }
  }

  Future<void> finishRegistration() async {
    setBusy(true);
    try {
      Map<String, dynamic> mValues = formBuilderKey.currentState!.value;
      final carData = {
        "car_make_id": selectedCarMake?.id,
        "car_model_id": selectedCarModel?.id,
      };

      final values = {...mValues, ...carData};
      Map<String, dynamic> params = Map.from(values);
      params["phone"] = accountPhoneNumber;
      params["driver_type"] = "taxi";

      if (firebaseToken != null) {
        if (AppStrings.isFirebaseOtp) {
          params["firebase_id_token"] = firebaseToken;
        } else {
          params["verification_token"] = firebaseToken;
        }
      }

      final apiResponse = await _authRequest.registerRequest(
        vals: params,
        docs: selectedDocuments,
        photo: selfieImage,
      );

      if (apiResponse.allGood) {
        await AlertService.success(
          title: "Become a partner".tr(),
          text: "${apiResponse.message}",
        );
        Navigator.of(viewContext).pop();
      } else {
        toastError("${apiResponse.message}");
      }
    } catch (error) {
      toastError("$error");
    }
    setBusy(false);
  }
}
