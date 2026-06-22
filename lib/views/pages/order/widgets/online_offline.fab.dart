import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:mahilasaarthi/services/app.service.dart';
import 'package:mahilasaarthi/utils/ui_spacer.dart';
import 'package:mahilasaarthi/view_models/home.vm.dart';
import 'package:mahilasaarthi/widgets/busy_indicator.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class OnlineOfflineFab extends StatelessWidget {
  const OnlineOfflineFab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //
    return ViewModelBuilder<HomeViewModel>.reactive(
      viewModelBuilder: () => HomeViewModel(context),
      onViewModelReady: (homeVm) => homeVm.initialise(),
      builder: (context, homeVm, child) {
        final stateColor =
            AppService().driverIsOnline ? Colors.green : Colors.red;
        final reverseStateColor =
            !AppService().driverIsOnline ? Colors.green : Colors.red;
        //
        return HStack(
          [
            UiSpacer.hSpace(12),
            UiSpacer.expandedSpace(),
            HStack(
              [
                Icon(
                  AppService().driverIsOnline
                      ? FlutterIcons.location_on_mdi
                      : FlutterIcons.location_off_mdi,
                  size: 20,
                  color: stateColor,
                ),
                UiSpacer.hSpace(5),
                (AppService().driverIsOnline
                        ? "You are Online"
                        : "You are Offline")
                    .tr()
                    .text
                    .color(stateColor)
                    .lg
                    .make(),
              ],
            ).centered(),
            UiSpacer.expandedSpace(),
            //action buttons
            homeVm.isBusy
                ? BusyIndicator(color: stateColor).p(15)
                : (!AppService().driverIsOnline ? "GO" : "OFF")
                    .tr()
                    .text
                    .white
                    .bold
                    .xl2
                    .make()
                    .p(10)
                    .box
                    .shadowSm
                    .roundedFull
                    .color(reverseStateColor)
                    .make()
                    .onInkTap(homeVm.toggleOnlineStatus),
          ],
        ).py(0);
        // FloatingActionButton.extended(
        //     icon: Icon(
        //       !AppService().driverIsOnline
        //           ? FlutterIcons.location_off_mdi
        //           : FlutterIcons.location_on_mdi,
        //       color: Colors.white,
        //     ),
        //     label: (AppService().driverIsOnline
        //             ? "You are Online"
        //             : "You are Offline")
        //         .tr()
        //         .text
        //         .white
        //         .make(),
        //     backgroundColor:
        //         (AppService().driverIsOnline ? Colors.green : Colors.red),
        //     onPressed: homeVm.toggleOnlineStatus,
        //   );
      },
    );
  }
}
