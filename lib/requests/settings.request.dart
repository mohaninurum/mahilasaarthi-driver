import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:mahilasaarthi/constants/api.dart';
import 'package:mahilasaarthi/models/api_response.dart';
import 'package:mahilasaarthi/services/http.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class SettingsRequest extends HttpService {
  //
  Future<ApiResponse> appSettings() async {
    final apiResult = await get(Api.appSettings);
    log("APP SETING : " + apiResult.data.toString());
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> emergencyContacts() async {
    final apiResult = await get(Api.emergencyContacts);
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> appOnboardings() async {
    try {
      final apiResult = await get(Api.appOnboardings);
      return ApiResponse.fromResponse(apiResult);
    } on DioError catch (error) {
      if (error.type == DioErrorType.other) {
        String msg1 = "Connection failed. Please check that your have internet connection on this device.";
        String msg2 = "Try again later";
        try {
          msg1 = msg1.tr();
          msg2 = msg2.tr();
        } catch (_) {}
        throw "$msg1\n$msg2";
      }
      throw error;
    } catch (error) {
      throw error;
    }
  }
}
