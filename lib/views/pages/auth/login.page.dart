import 'package:flutter/material.dart';
import 'package:mahilasaarthi/constants/app_colors.dart';
import 'package:mahilasaarthi/constants/app_images.dart';
import 'package:mahilasaarthi/constants/app_strings.dart';
import 'package:mahilasaarthi/utils/ui_spacer.dart';
import 'package:mahilasaarthi/view_models/login.view_model.dart';
import 'package:mahilasaarthi/views/pages/auth/login/compain_login_type.view.dart';
import 'package:mahilasaarthi/views/pages/auth/login/email_login.view.dart';
import 'package:mahilasaarthi/views/pages/auth/login/otp_login.view.dart';
import 'package:mahilasaarthi/widgets/base.page.dart';
import 'package:mahilasaarthi/widgets/buttons/custom_text_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../view_models/profile.vm.dart';
import 'login/scan_login.view.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LoginViewModel>.reactive(
      viewModelBuilder: () => LoginViewModel(context),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return BasePage(
          backgroundColor: context.theme.colorScheme.background,
          body: VStack(
            [
              UiSpacer.vSpace(9 * context.percentHeight),
              // Align(alignment: Alignment.centerRight,child: Padding(
              //   padding:  EdgeInsets.symmetric(horizontal: 10),
              //   child: GestureDetector(onTap: (){ProfileViewModel(context).changeLanguage();},child: Icon(Icons.language,color: AppColor.primaryColor,size: 35,)),
              // )),
              // SizedBox(height: 10,),

              //
              HStack(
                [
                  VStack(
                    [
                      "Welcome Back".tr().text.xl2.semiBold.make(),
                      "Login to continue".tr().text.light.make(),
                    ],
                  ).expand(),
                  UiSpacer.hSpace(),
                  Image.asset(AppImages.appLogo)
                      .wh(60, 60)
                      .box
                      .roundedFull
                      .clip(Clip.antiAlias)
                      .make()
                      .p12(),
                ],
                crossAlignment: CrossAxisAlignment.center,
                alignment: MainAxisAlignment.center,
              ),

              //form
              //LOGIN Section
              //both login type
              if (AppStrings.enableOTPLogin && AppStrings.enableEmailLogin)
                CombinedLoginTypeView(model),
              //only email login
              if (AppStrings.enableEmailLogin && !AppStrings.enableOTPLogin)
                EmailLoginView(model),
              //only otp login
              if (AppStrings.enableOTPLogin && !AppStrings.enableEmailLogin)
                OTPLoginView(model),

              ScanLoginView(model),
              20.heightBox,

              //registration link
              Visibility(
                visible: AppStrings.partnersCanRegister,
                child: CustomTextButton(
                  title: "Become a partner".tr(),
                  onPressed: model.openRegistrationlink,
                )
                    .wFull(context)
                    .box
                    .roundedSM
                    .border(color: AppColor.primaryColor)
                    .make(),
              ),
              10.heightBox,
              Align(alignment: Alignment.center,child: Padding(
                padding:  EdgeInsets.symmetric(horizontal: 10),
                child: GestureDetector(onTap: (){ProfileViewModel(context).changeLanguage();},child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Languages",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),),
                    SizedBox(width: 5,),
                    Icon(Icons.language,color: AppColor.primaryColor,size: 35,),
                  ],
                )),
              )),
              //
            ],
          ).wFull(context).p20().scrollVertical().pOnly(
                bottom: context.mq.viewInsets.bottom,
              ),
        );
      },
    );
  }
}
