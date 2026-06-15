import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mahilasaarthi/constants/app_images.dart';
import 'package:mahilasaarthi/services/app.service.dart';
import 'package:mahilasaarthi/services/location.service.dart';
import 'package:mahilasaarthi/utils/ui_spacer.dart';
import 'package:mahilasaarthi/widgets/buttons/custom_text_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:schedulers/schedulers.dart';
import 'package:velocity_x/velocity_x.dart';

class LocationServiceWatcher {
  //
  static bool alertDialogShown = false;
  static int schedulerDuration = 60;
  //
  static void listenToDelayLocationUpdate() async {
    //
    IntervalScheduler scheduler;
    if (!kDebugMode) {
      scheduler = IntervalScheduler(delay: Duration(minutes: 5));
    } else {
      scheduler =
          IntervalScheduler(delay: Duration(seconds: schedulerDuration));
    }
    scheduler.run(
      () async {
        // print("Schedule called ==> #YES");
        //check of last update time is less than 5min ago
        int timeDiff = DateTime.now().millisecondsSinceEpoch;
        timeDiff -= LocationService().lastUpdated;
        //
        if (timeDiff > 300000 && AppService().driverIsOnline) {
          //show alert dialog if driver is yet to be shown a dialog
          final result = await showModalBottomSheet(
            context: AppService().navigatorKey.currentContext!,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) {
              return VStack(
                [
                  UiSpacer.slideIndicator(),
                  UiSpacer.verticalSpace(),
                  Image.asset(AppImages.noLocation),
                  "Stationary Location".tr().text.xl2.semiBold.makeCentered(),
                  "You haven't move for a while now. You might have to move around/close to hotspot area to get orders"
                      .tr()
                      .text
                      .makeCentered(),
                  CustomTextButton(
                    title: "Don't remind me again".tr(),
                    onPressed: () {
                      scheduler.dispose();
                      Navigator.pop(context, true);
                    },
                  ),
                ],
                crossAlignment: CrossAxisAlignment.center,
              )
                  .p20()
                  .scrollVertical()
                  .hThreeForth(context)
                  .box
                  .color(context.theme.colorScheme.background)
                  .topRounded()
                  .make();
            },
          );

          //
          if (result != null && result) {
            return;
          }
        }
        //increase the next scheduler time/seconds
        schedulerDuration += 10;
        listenToDelayLocationUpdate();
      },
    );
  }
}



