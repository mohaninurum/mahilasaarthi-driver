import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mahilasaarthi/utils/ui_spacer.dart';
import 'package:mahilasaarthi/view_models/permission.vm.dart';
import 'package:mahilasaarthi/widgets/buttons/custom_button.dart';
import 'package:mahilasaarthi/widgets/buttons/custom_text_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class RequestBGLocationPermissionView extends StatefulWidget {
  const RequestBGLocationPermissionView(this.vm, {Key? key}) : super(key: key);

  final PermissionViewModel vm;

  @override
  State<RequestBGLocationPermissionView> createState() =>
      _RequestBGLocationPermissionViewState();
}

class _RequestBGLocationPermissionViewState
    extends State<RequestBGLocationPermissionView> {
  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        UiSpacer.vSpace(),
        "Background Location Permission"
            .tr()
            .text
            .xl3
            .extraBlack
            .center
            .makeCentered(),
        UiSpacer.vSpace(),
        //more info
        VStack(
          [
            UiSpacer.vSpace(),
            "Mahila Saarthi Driver collects location data to enable ride assignments, route navigation, and customer trip tracking even when the app is closed or not in use when you are Online."
                .tr()
                .text
                .lg
                .wordSpacing(2)
                .center
                .gray700
                .makeCentered(),
            UiSpacer.vSpace(),
            "Your location data is strictly protected and used only to process trips in accordance with our Privacy Policy. We never sell or share your data."
                .tr()
                .text
                .lg
                .wordSpacing(2)
                .center
                .gray700
                .makeCentered(),
            UiSpacer.vSpace(),
          ],
        ).scrollVertical().expand(),
        CustomButton(
          shapeRadius: 25,
          title: "Grant Permission".tr(),
          onPressed: widget.vm.handleBackgroundLocationPermission,
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
