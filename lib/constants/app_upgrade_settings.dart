import 'dart:io';

import 'package:mahilasaarthi/constants/app_strings.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppUpgradeSettings extends AppStrings {
  static Future<bool> showUpgrade() async {
    await AppStrings.getAppSettingsFromLocalStorage();
    final upgrade = AppStrings.env('upgrade');
    if (upgrade is Map && upgrade["driver"] is Map) {
      final driverData = upgrade["driver"];
      final androidNewVersion =
          int.tryParse(driverData["android"].toString()) ?? 0;
      final iosNewVersion =
          int.tryParse(driverData["ios"].toString()) ?? 0;

      final packageInfo = await PackageInfo.fromPlatform();
      final currentBuildNumber =
          int.tryParse(packageInfo.buildNumber) ?? 0;

      return currentBuildNumber <
          (Platform.isIOS ? iosNewVersion : androidNewVersion);
    }
    return false;
  }

  static bool forceUpgrade() {
    final upgrade = AppStrings.env('upgrade');
    if (upgrade is Map && upgrade["driver"] is Map) {
      final driverData = upgrade["driver"];
      final force = int.tryParse(driverData["force"].toString()) ?? 0;
      return force == 1;
    }
    return false;
  }
}
