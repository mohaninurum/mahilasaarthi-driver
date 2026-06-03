import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:mahilasaarthi/constants/app_strings.dart';
import 'package:mahilasaarthi/extensions/dynamic.dart';
import 'package:mahilasaarthi/view_models/profile.vm.dart';
import 'package:mahilasaarthi/widgets/base.page.dart';
import 'package:mahilasaarthi/widgets/cards/profile.card.dart';
import 'package:mahilasaarthi/widgets/menu_item.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ViewModelBuilder<ProfileViewModel>.reactive(
        viewModelBuilder: () => ProfileViewModel(context),
        onViewModelReady: (model) => model.initialise(),
        builder: (context, model, child) {
          return BasePage(
            body: VStack(
              [
                //
                "Settings".tr().text.xl2.semiBold.make(),
                "Profile & App Settings".tr().text.lg.light.make(),

                //profile card
                ProfileCard(model).py12(),

                //menu
                VxBox(
                  child: VStack(
                    [
                      //
                      MenuItem(
                        title: "Payment".tr(),
                        onPressed: model.openPhonepe,
                      ),
                      //
                      MenuItem(
                        title: "Notifications".tr(),
                        onPressed: model.openNotification,
                      ),

                      //
                      MenuItem(
                        title: "Rate & Review".tr(),
                        onPressed: model.openReviewApp,
                      ),

                      MenuItem(
                        title: "Faqs".tr(),
                        onPressed: model.openFaqs,
                      ),

                      //
                      MenuItem(
                        title: "Version".tr(),
                        suffix: model.appVersionInfo.text.make(),
                      ),

                      //
                      MenuItem(
                        title: "Privacy Policy".tr(),
                        onPressed: model.openPrivacyPolicy,
                      ),
                      //
                      MenuItem(
                        title: "Terms & Conditions".tr(),
                        onPressed: model.openTerms,
                      ),
                      //
                      MenuItem(
                        title: "Contact Us".tr(),
                        onPressed: model.openContactUs,
                      ),
                      MenuItem(
                        title: "Live support".tr(),
                        onPressed: model.openLivesupport,
                      ),
                      //
                      MenuItem(
                        title: "Language".tr(),
                        divider: false,
                        suffix: Icon(
                          FlutterIcons.language_ent,
                        ),
                        onPressed: model.changeLanguage,
                      ),
                    ],
                  ),
                )
                    .border(color: Theme.of(context).cardColor)
                    .color(Theme.of(context).cardColor)
                    .shadow
                    .roundedSM
                    .make(),

                //
                "Copyright ©%s %s all right reserved"
                    .tr()
                    .fill([
                      "${DateTime.now().year}",
                      AppStrings.companyName,
                    ])
                    .text
                    .center
                    .sm
                    .makeCentered()
                    .py20(),
              ],
            ).p20().scrollVertical(),
          );
        },
      ),
    );
  }
}
