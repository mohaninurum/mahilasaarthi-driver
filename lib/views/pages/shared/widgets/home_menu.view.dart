import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:mahilasaarthi/constants/app_ui_settings.dart';
import 'package:mahilasaarthi/utils/ui_spacer.dart';
import 'package:mahilasaarthi/view_models/profile.vm.dart';
import 'package:mahilasaarthi/views/pages/order/orders.page.dart';
import 'package:mahilasaarthi/views/pages/profile/finance.page.dart';
import 'package:mahilasaarthi/views/pages/profile/legal.page.dart';
import 'package:mahilasaarthi/views/pages/profile/support.page.dart';
import 'package:mahilasaarthi/views/pages/profile/widget/document_request.view.dart';
import 'package:mahilasaarthi/views/pages/profile/widget/driver_type.switch.dart';
import 'package:mahilasaarthi/views/pages/vehicle/vehicles.page.dart';
import 'package:mahilasaarthi/widgets/cards/profile.card.dart';
import 'package:mahilasaarthi/widgets/menu_item.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../training/training_screen.dart';

class HomeMenuView extends StatelessWidget {
  const HomeMenuView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProfileViewModel>.reactive(
      viewModelBuilder: () => ProfileViewModel(context),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return Stack(
          children: [
            VStack(
              [
                //profile card
                ProfileCard(model),
                12.heightBox,

                //if driver switch is enabled
                DriverTypeSwitch(),
                //document verification
                DocumentRequestView(),
                Visibility(
                  visible: AppUISettings.enableDriverTypeSwitch ||
                          model.currentUser == null
                      ? false
                      : model.currentUser!.isTaxiDriver,
                  child: MenuItem(
                    title: "Vehicle Details".tr(),
                    onPressed: () {
                      context.nextPage(VehiclesPage());
                    },
                    topDivider: true,
                  ),
                ),
                //

                MenuItem(
                  title: "Driver Training".tr(),
                  onPressed: () {
                    context.nextPage(Training_Screen());
                  },
                ),

                // orders
                MenuItem(
                  title: "Orders".tr(),
                  onPressed: () {
                    context.nextPage(OrdersPage());
                  },
                ),

                MenuItem(
                  title: "Finance".tr(),
                  onPressed: () {
                    context.nextPage(FinancePage());
                  },
                ),

                //menu
                VStack(
                  [
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
                      title: "Legal".tr(),
                      onPressed: () {
                        context.nextPage(LegalPage());
                      },
                    ),
                    MenuItem(
                      title: "Support".tr(),
                      onPressed: () {
                        context.nextPage(SupportPage());
                      },
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

                //
                MenuItem(
                  child: "Logout".tr().text.red500.make(),
                  onPressed: model.logoutPressed,
                  divider: false,
                  suffix: Icon(
                    FlutterIcons.logout_ant,
                    size: 16,
                  ),
                ),

                UiSpacer.vSpace(15),

                //
                ("Version".tr() + " - ${model.appVersionInfo}")
                    .text
                    .center
                    .sm
                    .makeCentered()
                    .py20(),
              ],
            )
                .p(18)
                .scrollVertical()
                .hFull(context)
                .box
                .color(context.colors.background)
                .topRounded(value: 20)
                .make()
                .pOnly(top: 20),

            //close
            IconButton(
              icon: Icon(
                FlutterIcons.close_ant,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ).box.roundedFull.red500.make().positioned(top: 0, right: 20),
          ],
        );
      },
    );
  }
}



