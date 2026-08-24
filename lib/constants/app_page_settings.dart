import 'package:mahilasaarthi/constants/app_strings.dart';

class AppPageSettings extends AppStrings {
  //
  static int get maxDriverDocumentCount {
    try {
      final pageEnv = AppStrings.env('page');
      if (pageEnv == null || pageEnv is! Map || pageEnv["settings"] == null || pageEnv["settings"] is! Map) {
        return 2;
      }
      return int.parse(
          pageEnv['settings']["driverDocumentCount"].toString());
    } catch (error) {
      return 2;
    }
  }

  static String get driverDocumentInstructions {
    try {
      final pageEnv = AppStrings.env('page');
      if (pageEnv == null || pageEnv is! Map || pageEnv["settings"] == null || pageEnv["settings"] is! Map) {
        return "";
      }
      return pageEnv['settings']["driverDocumentInstructions"]?.toString() ?? "";
    } catch (error) {
      return "";
    }
  }
}
