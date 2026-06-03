import 'package:mahilasaarthi/constants/api.dart';
import 'package:mahilasaarthi/models/api_response.dart';
import 'package:mahilasaarthi/models/currency.dart';
import 'package:mahilasaarthi/models/earning.dart';
import 'package:mahilasaarthi/services/http.service.dart';

class EarningRequest extends HttpService {
  //
  Future<List<dynamic>> getEarning() async {
    final apiResult = await get(Api.earning);

    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return [
        Currency.fromJSON(apiResponse.body["currency"]),
        Earning.fromJson(apiResponse.body["earning"]),
      ];
    } else {
      throw "${apiResponse.message}";
    }
  }
}
