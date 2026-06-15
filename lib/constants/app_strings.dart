import 'dart:convert';
import 'package:mahilasaarthi/services/local_storage.service.dart';
import 'package:supercharged/supercharged.dart';

class AppStrings {
  //
  static String get appName => env('app_name');
  static String get companyName => env('company_name');
  static String get googleMapApiKey => env('google_maps_key');
  static String get fcmApiKey => env('fcm_key');
  static String get currencySymbol => env('currency');
  static String get countryCode => env('country_code');

  //
  static bool get enableOtp => ["1", 1, "true", true].contains(env('enble_otp'));
  static bool get enableOTPLogin => ["1", 1, "true", true].contains(env('enableOTPLogin'));
  static bool get enableEmailLogin => ["1", 1, "true", true].contains(env('enableEmailLogin'));
  static bool get enableProfileUpdate => ["1", 1, "true", true].contains(env('enableProfileUpdate'));
  //

  static bool get enableProofOfDelivery => ["1", 1, "true", true].contains(env('enableProofOfDelivery'));
  static bool get signatureVerify =>
      env('orderVerificationType') == "signature";
  static bool get verifyOrderByPhoto => env('orderVerificationType') == "photo";
  static bool get enableDriverWallet => ["1", 1, "true", true].contains(env('enableDriverWallet'));
  static bool get enableChat => ["1", 1, "true", true].contains(env('enableChat'));
  static bool get partnersCanRegister =>
      ["1", 1, "true", true].contains(env('partnersCanRegister'));
  static double get driverSearchRadius =>
      double.tryParse((env('driverSearchRadius') ?? 10).toString()) ?? 10.0;
  static int get maxDriverOrderAtOnce =>
      int.tryParse((env('maxDriverOrderAtOnce') ?? 1).toString()) ?? 1;

  static double get distanceCoverLocationUpdate =>
      double.tryParse((env('distanceCoverLocationUpdate') ?? 10).toString()) ?? 10.0;
  static int get timePassLocationUpdate =>
      int.tryParse((env('timePassLocationUpdate') ?? 10).toString()) ?? 10;
  //
  static int get alertDuration {
    final duration = int.tryParse(env('alertDuration').toString());
    if (duration == null || duration < 10) {
      return 10;
    }
    return duration;
  }

  static bool get driverMatchingNewSystem {
    final val = env('autoassignmentsystem');
    print(
        "AppStrings: driverMatchingNewSystem autoassignmentsystem raw value: '$val' (type: ${val.runtimeType})");
    final isNew = ["1", 1, "true", true].contains(val);
    print("AppStrings: driverMatchingNewSystem resolved to: $isNew");
    return isNew;
  }

  //
  static String get otpGateway => env('otpGateway')?.toString() ?? "none";
  static bool get isFirebaseOtp => otpGateway.toLowerCase() == "firebase";
  static bool get isCustomOtp =>
      !["none", "firebase"].contains(otpGateway.toLowerCase());
  static String get emergencyContact =>
      LocalStorageService.prefs?.getString('customDriverSOS') ?? "112";

  //UI Configures
  static dynamic get uiConfig {
    return env('ui') ?? null;
  }

  static bool get qrcodeLogin {
    final auth = env('auth');
    if (auth is Map) {
      return ["1", 1, "true", true].contains(auth['qrcodeLogin']);
    }
    return false;
  }

  //DONT'T TOUCH
  static const String notificationChannel = "high_importance_channel";

  //START DON'T TOUNCH
  //for app usage
  static String firstTimeOnApp = "first_time";
  static String authenticated = "authenticated";
  static String userAuthToken = "auth_token";
  static String userKey = "user";
  static String driverVehicleKey = "driver_vehicle";
  static String appLocale = "locale";
  static String notificationsKey = "notifications";
  static String appCurrency = "currency";
  static String appColors = "colors";
  static String appRemoteSettings = "appRemoteSettings";
  static String onlineOnApp = "online";
  //END DON'T TOUNCH

  //
  //Change to your app store id
  static String appStoreId = "";

  //
  //saving
  static Future<bool> saveAppSettingsToLocalStorage(String colorsMap) async {
    return await LocalStorageService.prefs!
        .setString(AppStrings.appRemoteSettings, colorsMap);
  }

  static dynamic appSettingsObject;
  static Future<void> getAppSettingsFromLocalStorage() async {
    appSettingsObject =
        LocalStorageService.prefs!.getString(AppStrings.appRemoteSettings);
    if (appSettingsObject != null) {
      appSettingsObject = jsonDecode(appSettingsObject);
    }
  }

  static dynamic env(String ref) {
    //
    getAppSettingsFromLocalStorage();
    //
    return appSettingsObject != null ? appSettingsObject[ref] : "";
  }
}
