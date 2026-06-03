import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mahilasaarthi/constants/api.dart';
import 'package:mahilasaarthi/models/api_response.dart';
import 'package:mahilasaarthi/models/vehicle.dart';
import 'package:mahilasaarthi/services/app.service.dart';
import 'package:mahilasaarthi/services/http.service.dart';

class VehicleRequest extends HttpService {
  //
  Future<List<Vehicle>> vehicles() async {
    final apiResult = await get(Api.vehicles);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    return (apiResponse.body as List).map((e) => Vehicle.fromJson(e)).toList();
  }

  Future<ApiResponse> newVehicleRequest({
    required Map<String, dynamic> vals,
    List<File>? docs,
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

    final apiResult = await postCustomFiles(
      Api.driverVehicleRegister,
      null,
      formData: formData,
    );
    //
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> makeActive(int id) async {
    final apiResult = await post(
      Api.activateVehicle.replaceAll("{id}", "$id"),
      {},
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse;
    }
    throw "${apiResponse.message}";
  }
}
