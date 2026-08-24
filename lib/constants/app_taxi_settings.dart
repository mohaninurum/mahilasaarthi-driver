import 'package:mahilasaarthi/constants/app_strings.dart';
import 'package:supercharged/supercharged.dart';

class AppTaxiSettings extends AppStrings {
  static bool get requiredBookingCode {
    final taxi = AppStrings.env('taxi');
    if (taxi is! Map || taxi["requestBookingCode"] == null) {
      return false;
    }
    return true;
  }

  static bool get requiredBookingCodeBeforeTrip {
    return true;
  }

  static bool get requiredBookingCodeAfterTrip {
    final taxi = AppStrings.env('taxi');
    if (taxi is! Map || taxi["requestBookingCode"] == null) {
      return false;
    }
    return ["both", "after"]
        .contains(taxi["requestBookingCode"]);
  }

  //
  static bool get showTaxiPickupInfo {
    final taxi = AppStrings.env('taxi');
    if (taxi is! Map || taxi["showTaxiPickupInfo"] == null) {
      return true;
    }

    //
    if (taxi["showTaxiPickupInfo"] is bool) {
      return taxi["showTaxiPickupInfo"];
    }

    //
    int value =
        taxi["showTaxiPickupInfo"].toString().toInt() ?? 0;
    return value == 1;
  }

  static bool get showTaxiDropoffInfo {
    final taxi = AppStrings.env('taxi');
    if (taxi is! Map || taxi["showTaxiDropoffInfo"] == null) {
      return true;
    }

    //
    if (taxi["showTaxiDropoffInfo"] is bool) {
      return taxi["showTaxiDropoffInfo"];
    }

    //
    int value =
        taxi["showTaxiDropoffInfo"].toString().toInt() ?? 0;
    return value == 1;
  }
}
