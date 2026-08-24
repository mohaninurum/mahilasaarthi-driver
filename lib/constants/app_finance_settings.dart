import 'package:mahilasaarthi/constants/app_strings.dart';

class AppFinanceSettings extends AppStrings {
  static bool get collectDeliveryFeeInCash {
    try {
      final finance = AppStrings.env('finance');
      if (finance is Map && finance["delivery"] is Map) {
        final allowCashDeliveryFee = finance["delivery"]["collectDeliveryCash"];
        if (allowCashDeliveryFee == "1" || allowCashDeliveryFee == 1) {
          return true;
        }
      }
    } catch (error) {}

    return false;
  }
}
