import 'package:flutter/material.dart';
import 'package:mahilasaarthi/utils/ui_spacer.dart';
import 'package:mahilasaarthi/view_models/taxi/taxi.vm.dart';
import 'package:mahilasaarthi/widgets/buttons/call.button.dart';
import 'package:mahilasaarthi/widgets/custom_text_form_field.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class TaxiContactView extends StatelessWidget {
  const TaxiContactView(this.vm, {Key? key}) : super(key: key);

  final TaxiViewModel vm;

  @override
  Widget build(BuildContext context) {
    return HStack(
      [
        //
        CustomTextFormField(
          hintText: "Message".tr() + " ${vm.onGoingOrderTrip?.user.name}",
          isReadOnly: true,
          onTap: vm.chatCustomer,
        ).expand(),
        //
        UiSpacer.horizontalSpace(),
        //call
        CallButton(
          null,
          phoneModile: vm.onGoingOrderTrip!.user.phone,
          size: 32,
        ),
      ],
    ).py12();
  }
}
