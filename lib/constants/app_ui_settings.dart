import 'package:mahilasaarthi/constants/app_strings.dart';

class AppUISettings extends AppStrings {
  //CHAT UI
  static bool get canVendorChat {
    final ui = AppStrings.env('ui');
    if (ui is! Map || ui["chat"] is! Map) {
      return true;
    }
    return ui['chat']["canVendorChat"] == "1";
  }

  static bool get canCustomerChat {
    final ui = AppStrings.env('ui');
    if (ui is! Map || ui["chat"] is! Map) {
      return true;
    }
    return ui['chat']["canCustomerChat"] == "1";
  }

  static bool get canDriverChat {
    final ui = AppStrings.env('ui');
    if (ui is! Map || ui["chat"] is! Map) {
      return true;
    }
    return ui['chat']["canDriverChat"] == "1";
  }

  static bool get canDriverChatSupportMedia {
    final ui = AppStrings.env('ui');
    if (ui is! Map || ui["chat"] is! Map) {
      return true;
    }
    try {
      dynamic isSupportMedia =
          ui['chat']["canDriverChatSupportMedia"] ?? false;
      return (isSupportMedia is bool
          ? isSupportMedia
          : int.parse("$isSupportMedia") == 1);
    } catch (e) {
      return false;
    }
  }

  static bool get enableDriverTypeSwitch {
    final canSwitch = AppStrings.env('enableDriverTypeSwitch');
    if (canSwitch == null) {
      return false;
    }
    if (canSwitch is bool) {
      return canSwitch;
    } else if (canSwitch is int) {
      return canSwitch == 1;
    } else {
      return int.tryParse("$canSwitch") == 1;
    }
  }

  //call
  static bool get canCallVendor {
    final ui = AppStrings.env('ui');
    if (ui is! Map || ui["call"] is! Map) {
      return true;
    }
    return [1, "1"]
        .contains(ui['call']["canDriverVendorCall"]);
  }

  static bool get canCallCustomer {
    final ui = AppStrings.env('ui');
    if (ui is! Map || ui["call"] is! Map) {
      return true;
    }
    return [1, "1"]
        .contains(ui['call']["canCustomerDriverCall"]);
  }
}
