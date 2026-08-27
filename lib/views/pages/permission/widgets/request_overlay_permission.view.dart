import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mahilasaarthi/extensions/dynamic.dart';
import 'package:mahilasaarthi/utils/ui_spacer.dart';
import 'package:mahilasaarthi/view_models/permission.vm.dart';
import 'package:mahilasaarthi/widgets/buttons/custom_button.dart';
import 'package:mahilasaarthi/widgets/buttons/custom_text_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:velocity_x/velocity_x.dart';

class RequestOverlayPermissionView extends StatefulWidget {
  const RequestOverlayPermissionView(this.vm, {Key? key}) : super(key: key);

  final PermissionViewModel vm;

  @override
  State<RequestOverlayPermissionView> createState() =>
      _RequestOverlayPermissionViewState();
}

class _RequestOverlayPermissionViewState
    extends State<RequestOverlayPermissionView> {
  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        UiSpacer.vSpace(),
        VStack(
          [
            //header
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                String appName = "Driver App".tr();
                if (snapshot.hasData) {
                  appName = snapshot.data!.appName;
                }
                return VStack(
                  [
                    //title
                    "Allow %s to display over other apps"
                        .tr()
                        .fill([appName])
                        .text
                        .xl3
                        .center
                        .extraBlack
                        .make()
                        .py12(),
                    UiSpacer.vSpace(10),
                    //sub-body
                    "Allow %s to display over other apps in order to receive orders when you are using other apps or app is in background."
                        .tr()
                        .fill([appName])
                        .text
                        .wordSpacing(2)
                        .lg
                        .center
                        .gray700
                        .makeCentered(),
                    UiSpacer.vSpace(),
                  ],
                );
              },
            ),

            UiSpacer.vSpace(),
            "This permission enables floating widgets and pop-up ride notifications over other apps so you never miss an incoming trip request while navigating or using other apps."
                .tr()
                .text
                .wordSpacing(2)
                .lg
                .center
                .gray700
                .makeCentered(),
            UiSpacer.vSpace(),
          ],
          crossAlignment: CrossAxisAlignment.center,
        ).scrollVertical().expand(),
        CustomButton(
          shapeRadius: 25,
          title: "Go to settings".tr(),
          onPressed: widget.vm.handleOverlayPermission,
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
