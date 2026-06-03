import 'package:mahilasaarthi/constants/api.dart';
import 'package:mahilasaarthi/models/api_response.dart';
import 'package:mahilasaarthi/services/http.service.dart';

class DriverTypeRequest extends HttpService {
  //
  Future<ApiResponse> switchType(Map payload) async {
    final apiResult = await post(Api.driverTypeSwitch, payload);
    return ApiResponse.fromResponse(apiResult);
  }
}
