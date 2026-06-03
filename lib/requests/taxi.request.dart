import 'package:mahilasaarthi/constants/api.dart';
import 'package:mahilasaarthi/models/api_response.dart';
import 'package:mahilasaarthi/models/order.dart';
import 'package:mahilasaarthi/services/http.service.dart';

class TaxiRequest extends HttpService {
  //
  Future<Order?> getOnGoingTrip() async {
    final apiResult = await get(
      "${Api.currentTaxiBooking}",
    );
    //
    print("GET CURRENT BOOKING :" + apiResult.data.toString());
    final apiResponse = ApiResponse.fromResponse(apiResult);
    //
    if (apiResponse.allGood) {
      //if there is order
      if (apiResponse.body is Map && apiResponse.body.containsKey("order")) {
        return Order.fromJson(apiResponse.body["order"]);
      } else {
        return null;
      }
    }

    //
    throw apiResponse.body;
  }

  //
  Future<ApiResponse> cancelTrip(int id) async {
    final apiResult = await get(
      "${Api.cancelTaxiBooking}/$id",
    );
    //
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> rateUser(
    int orderId,
    int userId,
    double newTripRating,
    String review,
  ) async {
    //
    final apiResult = await post(
      "${Api.rating}",
      {
        //
        "user_id": userId,
        "order_id": orderId,
        "rating": newTripRating,
        "review": review,
      },
    );
    //
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> rejectAssignment(int orderId, int driverId) async {
    //
    final apiResult = await post(
      "${Api.rejectTaxiBookingAssignment}",
      {
        //
        "driver_id": driverId,
        "order_id": orderId,
      },
    );
    //
    return ApiResponse.fromResponse(apiResult);
  }
}
