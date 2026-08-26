import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:image_picker/image_picker.dart';
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
    if (formBuilderKey.currentState == null) {
      toastError("Please fill out the registration form".tr());
      return;
    }

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
        String phone = mValues['phone']?.toString() ?? "";
        if (phone.isEmpty) {
          toastError("Please enter a valid phone number".tr());
          setBusy(false);
          return;
        }
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

        if (AppStrings.isFirebaseOtp) {
          await processFirebaseOTPVerification();
        } else if (AppStrings.isCustomOtp) {
          await processCustomOTPVerification();
        } else {
          await startAadhaarVerification();
        }
      } catch (error) {
        toastError("$error");
        setBusy(false);
      }
    } else {
      toastError("Please fill all required fields correctly".tr());
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
          await startAadhaarVerification();
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
      final response = await _authRequest.sendOTP(accountPhoneNumber!);
      setBusy(false);
      showVerificationEntry();
    } catch (error) {
      setBusy(false);
      toastError("$error");
    }
  }

  void showVerificationEntry([String? otpCode]) async {
    setBusy(false);
    await Navigator.push(
        viewContext,
        MaterialPageRoute(
          builder: (context) => AccountVerificationEntry(
            vm: this,
            phone: accountPhoneNumber!,
            otpCode: otpCode,
            onSubmit: (smsCode) async {
              bool success = false;
              if (AppStrings.isFirebaseOtp) {
                success = await verifyFirebaseOTP(smsCode);
              } else {
                success = await verifyCustomOTP(smsCode);
              }
              if (success) {
                Navigator.pop(viewContext);
                startAadhaarVerification();
              }
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
        ));
  }

  Future<bool> verifyFirebaseOTP(String smsCode) async {
    setBusy(true);
    try {
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: firebaseVerificationId!,
        smsCode: smsCode,
      );
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
      firebaseToken = await userCredential.user?.getIdToken();
      return true;
    } catch (error) {
      setBusy(false);
      toastError("$error");
      return false;
    }
  }

  Future<bool> verifyCustomOTP(String smsCode) async {
    setBusy(true);
    try {
      final apiResponse = await _authRequest.verifyOTP(
        accountPhoneNumber!,
        smsCode,
        isLogin: false,
      );
      firebaseToken = apiResponse.body["token"];
      return true;
    } catch (error) {
      setBusy(false);
      toastError("$error");
      return false;
    }
  }

  String? aadhaarRefId;
  String? aadhaarNumber;
  Map<String, dynamic>? aadhaarDetails;

  // --- AADHAAR & FACE VERIFICATION FLOW ---
  Future<void> startAadhaarVerification() async {
    setBusy(false);
    TextEditingController aadhaarTEC = TextEditingController();
    bool isGeneratingOtp = false;

    showDialog(
      context: viewContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Aadhaar Verification".tr()),
              content: TextField(
                controller: aadhaarTEC,
                enabled: !isGeneratingOtp,
                keyboardType: TextInputType.number,
                maxLength: 12,
                decoration: InputDecoration(
                  hintText: "Enter 12-digit Aadhaar Number".tr(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isGeneratingOtp
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: Text("Cancel".tr()),
                ),
                ElevatedButton(
                  onPressed: isGeneratingOtp
                      ? null
                      : () async {
                          if (aadhaarTEC.text.trim().length == 12) {
                            setState(() {
                              isGeneratingOtp = true;
                            });
                            bool success = await submitAadhaarNumber(
                                aadhaarTEC.text.trim());
                            if (success) {
                              Navigator.pop(dialogContext);
                              showAadhaarOtpEntry();
                            } else {
                              setState(() {
                                isGeneratingOtp = false;
                              });
                            }
                          } else {
                            toastError("Enter valid 12 digit Aadhaar".tr());
                          }
                        },
                  child: isGeneratingOtp
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text("Generate OTP".tr()),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool> submitAadhaarNumber(String aadhaar) async {
    try {
      final response = await _authRequest.generateAadhaarOtp(aadhaar);
      if (response.allGood ||
          (response.body is Map && response.body['status'] == 'SUCCESS')) {
        aadhaarNumber = aadhaar;
        aadhaarRefId = response.body is Map
            ? (response.body['ref_id']?.toString() ??
                response.body['data']?['ref_id']?.toString())
            : null;
        return true;
      } else {
        String msg = response.message ?? "";
        if (msg.isEmpty &&
            response.body is Map &&
            response.body['message'] != null) {
          msg = response.body['message'].toString();
        }
        if (msg.isEmpty) {
          msg = "Aadhaar API Error".tr();
        }
        toastError(msg);
        return false;
      }
    } catch (e) {
      toastError(e.toString());
      return false;
    }
  }

  void showAadhaarOtpEntry([String? otpCode]) {
    TextEditingController otpTEC = TextEditingController(text: otpCode);
    bool isVerifyingOtp = false;

    showDialog(
      context: viewContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Aadhaar OTP".tr()),
              content: TextField(
                controller: otpTEC,
                enabled: !isVerifyingOtp,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  hintText: "Enter 6-digit Aadhaar OTP".tr(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isVerifyingOtp
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: Text("Cancel".tr()),
                ),
                ElevatedButton(
                  onPressed: isVerifyingOtp
                      ? null
                      : () async {
                          if (otpTEC.text.trim().length == 6) {
                            setState(() {
                              isVerifyingOtp = true;
                            });
                            bool success =
                                await submitAadhaarOtp(otpTEC.text.trim());
                            if (success) {
                              Navigator.pop(dialogContext);
                              onAadhaarVerifiedSuccess();
                            } else {
                              setState(() {
                                isVerifyingOtp = false;
                              });
                            }
                          } else {
                            toastError("Enter valid OTP".tr());
                          }
                        },
                  child: isVerifyingOtp
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text("Verify OTP".tr()),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool> submitAadhaarOtp(String otp) async {
    if (aadhaarRefId == null) {
      toastError("Invalid Reference ID".tr());
      return false;
    }
    try {
      final response = await _authRequest.verifyAadhaarOtp(aadhaarRefId!, otp);
      if (response.allGood ||
          (response.body is Map &&
              (response.body['status'] == 'SUCCESS' ||
                  response.body['status'] == 'VALID'))) {
        aadhaarDetails = response.body is Map ? response.body : {};
        return true;
      } else {
        String msg = response.message ?? "";
        if (msg.isEmpty &&
            response.body is Map &&
            response.body['message'] != null) {
          msg = response.body['message'].toString();
        }
        if (msg.isEmpty) {
          msg = "Invalid Aadhaar OTP".tr();
        }
        toastError(msg);
        return false;
      }
    } catch (e) {
      toastError(e.toString());
      return false;
    }
  }

  void onAadhaarVerifiedSuccess() {
    // Check gender
    String? gender;
    if (aadhaarDetails != null) {
      gender = aadhaarDetails!['gender']?.toString().toUpperCase();
    }

    if (gender == 'M' || gender == 'MALE') {
      showDialog(
        context: viewContext,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("Registration Failed".tr()),
            content: Text("Only female can register on Mahila Saarthi.".tr()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK".tr()),
              ),
            ],
          );
        },
      );
      return;
    }

    toastSuccessful("Aadhaar Verified Successfully!".tr());
    // Step 3: Face Liveness
    startFaceLivenessCheck();
  }

  Future<void> startFaceLivenessCheck() async {
    // 1. Forcefully open the Front Camera for a Live Selfie
    setBusy(false);
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 70, // Compress slightly for faster upload
    );

    if (image == null) {
      toastError(
          "Camera closed. Live Selfie is required for verification!".tr());
      return;
    }

    // 2. Save it and show loading state
    File liveSelfie = File(image.path);
    selfieImage =
        liveSelfie; // update the main variable so it goes to backend in register API too

    setBusy(true);
    try {
      final response = await _authRequest.verifyFaceLiveness(liveSelfie);
      if (response.allGood || response.body['status'] == 'SUCCESS') {
        if (response.body['liveness'] == true) {
          toastSuccessful("Face Verified! Live person detected.".tr());
          await finishRegistration();
        } else {
          toastError("Face Liveness Failed. Please take a clear selfie.".tr());
          setBusy(false);
        }
      } else {
        toastError(response.body['message'] ?? "Face Verification Error");
        setBusy(false);
      }
    } catch (e) {
      toastError(e.toString());
      setBusy(false);
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

      // Add Aadhaar details to params
      if (aadhaarNumber != null) params["aadhaar_number"] = aadhaarNumber;
      if (aadhaarDetails != null) {
        params["aadhaar_verified"] = 1;
        params["aadhaar_name"] =
            aadhaarDetails!['name'] ?? aadhaarDetails!['full_name'];
        params["aadhaar_gender"] = aadhaarDetails!['gender'];
        params["aadhaar_dob"] = aadhaarDetails!['dob'];
        params["aadhaar_address"] = aadhaarDetails!['address'] != null
            ? aadhaarDetails!['address'].toString()
            : null;
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
