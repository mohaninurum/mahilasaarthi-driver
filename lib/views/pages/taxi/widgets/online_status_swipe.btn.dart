import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:mahilasaarthi/services/alert.service.dart';
import 'package:mahilasaarthi/view_models/taxi/taxi.vm.dart';
import 'package:mahilasaarthi/views/pages/permission/permission.page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:swipe_button_widget/swipe_button_widget.dart';
import 'package:velocity_x/velocity_x.dart';

class OnlineStatusSwipeButton extends StatefulWidget {
  const OnlineStatusSwipeButton(this.vm, {Key? key}) : super(key: key);
  final TaxiViewModel vm;

  @override
  State<OnlineStatusSwipeButton> createState() =>
      _OnlineStatusSwipeButtonState();
}

class _OnlineStatusSwipeButtonState extends State<OnlineStatusSwipeButton> {
  //
  ObjectKey viewKey = new ObjectKey(DateTime.now());
  //
  @override
  Widget build(BuildContext context) {
    final driverIsOnline = widget.vm.appService.driverIsOnline;
    //
    return VxBox(
      child: HStack(
        [
          VxBox(
            child: Icon(
              driverIsOnline ? FlutterIcons.close_ant : FlutterIcons.chevrons_right_fea,
              color: Colors.white,
              size: 34,
            ).centered(),
          ).width(100).make(),
          Spacer(),
          (driverIsOnline ? "Go offline" : "Go online")
              .tr()
              .text
              .extraBold
              .xl2
              .white
              .make()
              .px(16),
        ],
      ),
    )
    .color(driverIsOnline ? Colors.red : Colors.green)
    .make()
    .h(50)
    .onInkTap(() async {
      await Future.delayed(const Duration(milliseconds: 500));
      try {
        final newDriverState = !widget.vm.appService.driverIsOnline;
        if (newDriverState) {
          var inUseStatus = await Permission.locationWhenInUse.status;
          var alwaysUseStatus = await Permission.locationAlways.status;
          var systemAlertWindowStatus = await Permission.systemAlertWindow.status;
          final overlayGranted = Platform.isIOS ? true : systemAlertWindowStatus.isGranted;

          if (!inUseStatus.isGranted || !alwaysUseStatus.isGranted || !overlayGranted) {
            context.nextPage(PermissionPage());
            return;
          }
        }
        await widget.vm.newTaxiBookingService.toggleVisibility(newDriverState, showLoading: true);
        setState(() {});
      } catch (error) {
        widget.vm.toastError("$error");
      }
    })
    .h(widget.vm.isBusy ? 0 : 60);
  }
}
