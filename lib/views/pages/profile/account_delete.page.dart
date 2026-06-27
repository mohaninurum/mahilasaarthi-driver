import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:mahilasaarthi/services/custom_form_builder_validator.service.dart';
import 'package:mahilasaarthi/utils/ui_spacer.dart';
import 'package:mahilasaarthi/utils/utils.dart';
import 'package:mahilasaarthi/view_models/account_delete.vm.dart';
import 'package:mahilasaarthi/widgets/base.page.dart';
import 'package:mahilasaarthi/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../services/auth.service.dart';
import '../splash.page.dart';

class AccountDeletePage extends StatelessWidget {
  const AccountDeletePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AccountDeleteViewModel>.reactive(
      viewModelBuilder: () => AccountDeleteViewModel(context),
      disposeViewModel: false,
      builder: (context, vm, child) {
        return BasePage(
          showAppBar: true,
          showLeadingAction: AuthServices.currentUser?.deleteRequest == true ? false : Navigator.canPop(context),
          elevation: 0,
          title: "Request Account Deletion".tr(),
          appBarItemColor: Utils.textColorByTheme(),
          backgroundColor: context.theme.colorScheme.background,
          body: AuthServices.currentUser?.deleteRequest == true
              ? VStack([
                  UiSpacer.vSpace(20),
                  Icon(
                    Icons.pending_actions,
                    size: 60,
                    color: Colors.orange,
                  ).centered(),
                  UiSpacer.vSpace(15),
                  "Your account deletion request is pending admin approval."
                      .tr()
                      .text
                      .xl
                      .center
                      .make()
                      .centered(),
                  UiSpacer.vSpace(30),
                  CustomButton(
                    title: "Logout".tr(),
                    color: Colors.red,
                    onPressed: () async {
                      await AuthServices.logout();
                      context.nextAndRemoveUntilPage(
                        SplashPage(),
                      );
                    },
                  ).wFull(context),
                  UiSpacer.vSpace(20),
                ]).scrollVertical(
                  padding: EdgeInsets.all(Vx.dp20),
                )
              : FormBuilder(
                  key: vm.formBuilderKey,
                  autovalidateMode: AutovalidateMode.disabled,
                  child: VStack(
                    [
                      UiSpacer.vSpace(5),
                      //description
                      "You are about to request account deletion. Please enter your password below."
                          .tr()
                          .text
                          .light
                          .make(),
                      UiSpacer.vSpace(12),
                      UiSpacer.divider(),
                      UiSpacer.vSpace(),
                      //verification section
                      "Enter your account password to confirm account deletion request"
                          .tr()
                          .text
                          .light
                          .make(),

                      //verification coe input
                      UiSpacer.vSpace(10),
                      FormBuilderTextField(
                        name: "password",
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Password".tr(),
                          border: OutlineInputBorder(),
                        ),
                        validator: CustomFormBuilderValidator.required,
                      ),
                      //submit btn
                      UiSpacer.vSpace(10),
                      CustomButton(
                        title: "Submit".tr(),
                        loading: vm.isBusy,
                        onPressed: vm.processAccountDeletion,
                      ).wFull(context)
                    ],
                  ),
                ).scrollVertical(
                  padding: EdgeInsets.fromLTRB(
                    Vx.dp20,
                    Vx.dp20,
                    Vx.dp20,
                    context.mq.viewInsets.bottom + Vx.dp20,
                  ),
                ),
        );
      },
    );
  }
}
