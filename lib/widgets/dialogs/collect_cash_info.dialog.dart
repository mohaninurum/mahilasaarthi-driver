import 'package:flutter/material.dart';
import 'package:mahilasaarthi/constants/app_strings.dart';
import 'package:mahilasaarthi/extensions/dynamic.dart';
import 'package:mahilasaarthi/models/order.dart';
import 'package:mahilasaarthi/utils/ui_spacer.dart';
import 'package:mahilasaarthi/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class CollectCashInfoDialog extends StatelessWidget {
  const CollectCashInfoDialog(this.order, {Key? key}) : super(key: key);

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: VStack(
        [
          //
          "Order Payment".tr().text.semiBold.xl.make(),
          UiSpacer.verticalSpace(space: 5),
          UiSpacer.divider(),
          UiSpacer.verticalSpace(),
          HStack(
            [
              "Payment method".tr().text.sm.thin.make().expand(),
              UiSpacer.horizontalSpace(space: 10),
              "${order.paymentMethod?.name}".text.semiBold.sm.make(),
            ],
          ),
          UiSpacer.verticalSpace(space: 5),
          HStack(
            [
              "Amount".tr().text.sm.thin.make().expand(),
              UiSpacer.horizontalSpace(space: 10),
              "${AppStrings.currencySymbol} ${order.total}"
                  .currencyFormat()
                  .text
                  .semiBold
                  .lg
                  .make(),
            ],
          ),
          UiSpacer.verticalSpace(),
          "Instruction".tr().text.semiBold.base.make(),
          UiSpacer.verticalSpace(space: 5),
          "Please confirm you have collected order amount from customer. Once you confirm order will be marked as completed/delivered"
              .tr()
              .text
              .light
              .sm
              .make(),
          UiSpacer.verticalSpace(),
          CustomButton(
            title: "Yes, Collected".tr(),
            onPressed: () {
              context.pop();
            },
          )
        ],
      ).p20(),
    );
  }
}
