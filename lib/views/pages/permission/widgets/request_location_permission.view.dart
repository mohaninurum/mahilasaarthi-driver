import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mahilasaarthi/utils/ui_spacer.dart';
import 'package:mahilasaarthi/view_models/permission.vm.dart';
import 'package:mahilasaarthi/widgets/buttons/custom_button.dart';
import 'package:mahilasaarthi/widgets/buttons/custom_text_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class RequestLocationPermissionView extends StatefulWidget {
  const RequestLocationPermissionView(this.vm, {Key? key}) : super(key: key);

  final PermissionViewModel vm;

  @override
  State<RequestLocationPermissionView> createState() =>
      _RequestLocationPermissionViewState();
}

class _RequestLocationPermissionViewState
    extends State<RequestLocationPermissionView> {
  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        UiSpacer.vSpace(),
        "Location Permission".tr().text.xl3.extraBlack.center.makeCentered(),

        //more info
        VStack(
          [
            UiSpacer.vSpace(),
            "Mahila Saarthi Driver requires location access to find nearby ride requests, calculate routes, and guide you to pickup and dropoff points."
                .tr()
                .text
                .lg
                .wordSpacing(2)
                .center
                .gray700
                .makeCentered(),
            UiSpacer.vSpace(),
            "Location access allows us to connect you with nearby riders efficiently. Tap \"Grant Permission\" to proceed or \"Not Now\" to skip for now."
                .tr()
                .text
                .lg
                .wordSpacing(2)
                .center
                .gray700
                .makeCentered(),
            UiSpacer.vSpace(15),
            VxBox(
              child: HStack(
                [
                  Icon(
                    widget.vm.currentLat != null
                        ? Icons.my_location
                        : Icons.location_off,
                    color: widget.vm.currentLat != null
                        ? Colors.green
                        : Colors.orange,
                    size: 28,
                  ),
                  UiSpacer.hSpace(12),
                  VStack(
                    [
                      (widget.vm.currentLat != null
                              ? "Current Location Detected"
                              : "Location Not Detected Yet")
                          .tr()
                          .text
                          .semiBold
                          .lg
                          .make(),
                      if (widget.vm.isFetchingLocation)
                        "Fetching location...".tr().text.sm.gray500.make()
                      else if (widget.vm.currentLat != null)
                        "Lat: ${widget.vm.currentLat!.toStringAsFixed(4)}, Long: ${widget.vm.currentLng!.toStringAsFixed(4)}"
                            .text
                            .sm
                            .gray600
                            .make()
                      else
                        "Tap Grant Permission to get location".tr().text.sm.gray500.make(),
                    ],
                  ).expand(),
                ],
              ).p16(),
            )
                .roundedSM
                .color(widget.vm.currentLat != null
                    ? Colors.green.shade50
                    : Colors.orange.shade50)
                .border(
                    color: widget.vm.currentLat != null
                        ? Colors.green.shade300
                        : Colors.orange.shade300)
                .make()
                .wFull(context),
            UiSpacer.vSpace(),
          ],
        ).scrollVertical().expand(),

        UiSpacer.vSpace(),
        CustomButton(
          shapeRadius: 25,
          title: "Grant Permission".tr(),
          onPressed: widget.vm.handleLocationPermission,
        ),
        UiSpacer.vSpace(10),
        Visibility(
          visible: !Platform.isIOS,
          child: CustomTextButton(
            title: "Not Now".tr(),
            onPressed: widget.vm.nextStep,
          ).wFull(context),
        ),
        UiSpacer.vSpace(10),
      ],
    ).p32().safeArea();
  }
}
