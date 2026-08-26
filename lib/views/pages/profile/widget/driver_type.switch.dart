import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:mahilasaarthi/constants/app_colors.dart';
import 'package:mahilasaarthi/constants/app_strings.dart';
import 'package:mahilasaarthi/constants/app_ui_settings.dart';
import 'package:mahilasaarthi/models/user.dart';
import 'package:mahilasaarthi/requests/driver_type.request.dart';
import 'package:mahilasaarthi/services/alert.service.dart';
import 'package:mahilasaarthi/services/auth.service.dart';
import 'package:mahilasaarthi/services/local_storage.service.dart';
import 'package:mahilasaarthi/utils/ui_spacer.dart';
import 'package:mahilasaarthi/utils/utils.dart';
import 'package:mahilasaarthi/views/pages/splash.page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:swipe_button_widget/swipe_button_widget.dart';
import 'package:velocity_x/velocity_x.dart';

class DriverTypeSwitch extends StatefulWidget {
  const DriverTypeSwitch({Key? key}) : super(key: key);

  @override
  State<DriverTypeSwitch> createState() => _DriverTypeSwitchState();
}

class _DriverTypeSwitchState extends State<DriverTypeSwitch> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: AuthServices.getCurrentUser(force: true),
      builder: (context, snapshot) {
        if (!snapshot.hasData ||
            snapshot.connectionState != ConnectionState.done) {
          return UiSpacer.emptySpace();
        }

        return UiSpacer.emptySpace();
      },
    );
  }

  Future<bool> _processDriverTypeSwitch(User user, BuildContext context) async {
    bool result = false;
    try {
      AlertService.showLoading();

      final payload = {
        "driver_id": user.id,
        "is_taxi": !user.isTaxiDriver,
      };
      final apiResponse = await DriverTypeRequest().switchType(payload);

      if (apiResponse.allGood) {
        //
        final vehicleJson = apiResponse.body['data']["vehicle"] ?? null;
        final driverJson = apiResponse.body['data']["driver"] ?? null;
        final newUserModel = await AuthServices.saveUser(driverJson);
        if (newUserModel.isTaxiDriver && vehicleJson != null) {
          await AuthServices.saveVehicle(vehicleJson);
        } else {
          final prefs = await LocalStorageService.getPrefs();
          await prefs?.remove(AppStrings.driverVehicleKey);
        }

        await AuthServices.getCurrentUser(force: true);
        AlertService.stopLoading();
        //reload app from splash screen
        context.nextAndRemoveUntilPage(SplashPage());
      } else {
        throw "${apiResponse.message}";
      }
      //
      result = true;
    } catch (error) {
      AlertService.stopLoading();
      AlertService.error(text: "$error");
    }
    return result;
  }
}
