import 'dart:io';
import 'package:mahilasaarthi/services/background_order.service.dart';
import 'package:mahilasaarthi/services/location.service.dart';
import 'package:mahilasaarthi/services/order_manager.service.dart';
import 'package:mahilasaarthi/services/taxi_background_order.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import 'app_permission_handler.service.dart';

class AppbackgroundService {
  //

  startBg() async {
    print("AppbackgroundService: startBg starting...");
    try {
      final permitted =
          await AppPermissionHandlerService().handleLocationRequest();
      print(
          "AppbackgroundService: handleLocationRequest permitted: $permitted");
      if (!permitted) {
        print(
            "AppbackgroundService: Location permission not permitted. Returning.");
        return;
      }
      print("AppbackgroundService: Preparing location listener...");
      await LocationService().prepareLocationListener();
      print("AppbackgroundService: Starting OrderManagerService listener...");
      await OrderManagerService().startListener();
      print(
          "AppbackgroundService: Initializing BackgroundOrderService and TaxiBackgroundOrderService...");
      BackgroundOrderService();
      TaxiBackgroundOrderService();
    } catch (e, stack) {
      print("AppbackgroundService: Exception in startBg: $e");
      print("AppbackgroundService: Stacktrace: $stack");
    }
  }

  void stopBg() {
    // Platform.isAndroid
    // if (Platform.isAndroid) {
    //   bool enabled = FlutterBackground.isBackgroundExecutionEnabled;
    //   if (enabled) {
    //     FlutterBackground.disableBackgroundExecution();
    //   }
    // }
    // OrderManagerService().stopListener();
  }
}
