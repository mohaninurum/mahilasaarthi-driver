import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mahilasaarthi/utils/ui_spacer.dart';
import 'package:mahilasaarthi/view_models/permission.vm.dart';
import 'package:mahilasaarthi/widgets/buttons/custom_button.dart';
import 'package:mahilasaarthi/widgets/buttons/custom_text_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class RequestBGPermissionView extends StatefulWidget {
  const RequestBGPermissionView(this.vm, {Key? key}) : super(key: key);

  final PermissionViewModel vm;

  @override
  State<RequestBGPermissionView> createState() =>
      _RequestBGPermissionViewState();
}

class _RequestBGPermissionViewState extends State<RequestBGPermissionView> {
  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        UiSpacer.vSpace(),
        "Background Service Permission"
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
            "Mahila Saarthi Driver requires background execution to keep your online driver status active and ensure instant receipt of new ride notifications."
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
          onPressed: widget.vm.handleBackgroundPermission,
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
