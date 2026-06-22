import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mahilasaarthi/constants/api.dart';
import 'package:mahilasaarthi/models/api_response.dart';
import 'package:mahilasaarthi/models/user.dart';
import 'package:mahilasaarthi/services/http.service.dart';
import 'package:mahilasaarthi/services/app.service.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class AuthRequest extends HttpService {

  Future<ApiResponse> CallDriverApi({
    from,to
  }) async {
    var headers = {
      'cache-control': 'no-cache'
    };
    var request = http.Request('POST',
        Uri.parse('https://s-ct3.sarv.com/v2/clickToCall/para?user_id=90495227&token=E5S20zVZOVlU9CNnhPjC&from=$from&to=$to'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    print("Error Code" );
    print(response.statusCode.toString() );

    return Future(() => ApiResponse());
  }
  //
  Future<ApiResponse> loginRequest({
    required String email,
    required String password,
  }) async {
    final apiResult = await post(
      Api.login,
      {
        "email": email,
        "password": password,
        "role": "driver",
      },
    );
    log("LOGIN REGISTER : " + apiResult.data.toString());

    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> registerRequest({
    required Map<String, dynamic> vals,
    List<File>? docs,
    File? photo,
  }) async {
    final postBody = {
      ...vals,
    };

    FormData formData = FormData.fromMap(postBody);
    if ((docs ?? []).isNotEmpty) {
      for (File file in docs!) {
        final optimizedFile = await AppService().compressImageForUpload(file);
        formData.files.addAll([
          MapEntry("documents[]", await MultipartFile.fromFile(optimizedFile.path)),
        ]);
      }
    }
    if (photo != null) {
      final optimizedPhoto = await AppService().compressImageForUpload(photo);
      formData.files.add(
        MapEntry("photo", await MultipartFile.fromFile(optimizedPhoto.path)),
      );
    }

    final apiResult = await postCustomFiles(
      Api.newAccount,
      null,
      formData: formData,
    );
    print("API RESponsE");
    print(apiResult.statusCode.toString());
    print(apiResult.statusMessage.toString());
    //
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> verifyFirebaseToken(
    String phoneNumber,
    String firebaseVerificationId,
  ) async {
    //
    final apiResult = await post(
      Api.verifyFirebaseOtp,
      {
        "phone": phoneNumber,
        "firebase_id_token": firebaseVerificationId,
      },
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse;
    } else {
      throw "${apiResponse.message}";
    }
  }

  //
  Future<ApiResponse> qrLoginRequest({
    required String code,
  }) async {
    final apiResult = await post(
      Api.qrlogin,
      {
        "code": code,
        "role": "driver",
      },
    );

    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> resetPasswordRequest({
    required String phone,
    required String password,
    String? firebaseToken,
    String? customToken,
  }) async {
    final apiResult = await post(
      Api.forgotPassword,
      {
        "phone": phone,
        "password": password,
        "firebase_id_token": firebaseToken,
        "verification_token": customToken,
      },
    );

    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> logoutRequest() async {
    final apiResult = await get(Api.logout);
    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> updateProfile({
    File? photo,
    String? name,
    String? email,
    String? phone,
    bool? isOnline,
  }) async {
    Map<String, dynamic> body = {
      "_method": "PUT",
    };
    if (name != null) body["name"] = name;
    if (email != null) body["email"] = email;
    if (phone != null) body["phone"] = phone;
    if (isOnline != null) body["is_online"] = isOnline ? 1 : 0;

    if (photo != null) {
      body["photo"] = await MultipartFile.fromFile(photo.path);
      final apiResult = await postWithFiles(Api.updateProfile, body);
      return ApiResponse.fromResponse(apiResult);
    } else {
      final apiResult = await post(Api.updateProfile, body);
      return ApiResponse.fromResponse(apiResult);
    }
  }

  Future<ApiResponse> updatePassword({
    required String password,
    required String new_password,
    required String new_password_confirmation,
  }) async {
    final apiResult = await post(
      Api.updatePassword,
      {
        "_method": "PUT",
        "password": password,
        "new_password": new_password,
        "new_password_confirmation": new_password_confirmation,
      },
    );
    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> verifyPhoneAccount(String phone) async {
    final apiResult = await get(
      Api.verifyPhoneAccount,
      queryParameters: {
        "phone": phone,
      },
    );

    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> sendOTP(String phoneNumber,
      {bool isLogin = false}) async {
    final apiResult = await post(
      Api.sendOtp,
      {
        "phone": phoneNumber,
        "is_login": isLogin,
      },
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse;
    } else {
      throw "${apiResponse.message}";
    }
  }

  Future<ApiResponse> verifyOTP(String phoneNumber, String code,
      {bool isLogin = false}) async {
    final apiResult = await post(
      Api.verifyOtp,
      {
        "phone": phoneNumber,
        "code": code,
        "is_login": isLogin,
      },
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse;
    } else {
      throw "${apiResponse.message}";
    }
  }

  Future<User> getMyDetails() async {
    //
    final apiResult = await get(Api.myProfile);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return User.fromJson(apiResponse.body);
    } else {
      throw "${apiResponse.message}";
    }
  }

  Future<ApiResponse> deleteProfile({
    required String password,
    String? reason,
  }) async {
    final apiResult = await post(
      Api.accountDelete,
      {
        "_method": "DELETE",
        "password": password,
        "reason": reason,
      },
    );
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> submitDocumentsRequest({required List<File> docs}) async {
    FormData formData = FormData.fromMap({});
    for (File file in docs) {
      final optimizedFile = await AppService().compressImageForUpload(file);
      formData.files.addAll([
        MapEntry("documents[]", await MultipartFile.fromFile(optimizedFile.path)),
      ]);
    }

    final apiResult = await postCustomFiles(
      Api.documentSubmission,
      null,
      formData: formData,
    );
    return ApiResponse.fromResponse(apiResult);
  }

  // --- Cashfree Verification APIs ---
  Future<ApiResponse> generateAadhaarOtp(String aadhaarNumber) async {
    final apiResult = await post(
      Api.generateAadhaarOtp,
      {
        "aadhaar_number": aadhaarNumber,
      },
    );
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> verifyAadhaarOtp(String refId, String otp) async {
    final apiResult = await post(
      Api.verifyAadhaarOtp,
      {
        "ref_id": refId,
        "otp": otp,
      },
    );
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> verifyFaceLiveness(File photo) async {
    final optimizedPhoto = await AppService().compressImageForUpload(photo);
    FormData formData = FormData.fromMap({});
    formData.files.add(
      MapEntry("image", await MultipartFile.fromFile(optimizedPhoto.path)),
    );
    
    final apiResult = await postCustomFiles(
      Api.verifyFaceLiveness,
      null,
      formData: formData,
    );
    return ApiResponse.fromResponse(apiResult);
  }
}
