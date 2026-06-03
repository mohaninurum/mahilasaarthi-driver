import 'dart:async';
import 'dart:io';

import 'package:awesome_drawer_bar/awesome_drawer_bar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mahilasaarthi/constants/app_upgrade_settings.dart';
import 'package:mahilasaarthi/views/pages/order/assigned_orders.page.dart';
import 'package:mahilasaarthi/view_models/home.vm.dart';
import 'package:mahilasaarthi/views/pages/shared/widgets/app_menu.dart';
import 'package:mahilasaarthi/views/pages/taxi/taxi_order.page.dart';
import 'package:mahilasaarthi/widgets/busy_indicator.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:upgrader/upgrader.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:mahilasaarthi/views/pages/profile/account_delete.page.dart';
import 'widgets/home_menu.view.dart';

class HomePage extends StatefulWidget {
  HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final awesomeDrawerBarController = AwesomeDrawerBarController();

  bool canCloseApp = false;
  //
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        //
        if (!canCloseApp) {
          canCloseApp = true;
          Timer(Duration(seconds: 1), () {
            canCloseApp = false;
          });
          //
          Fluttertoast.showToast(
            msg: "Press back again to close".tr(),
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: const Color(0xAA000000),
            textColor: Colors.white,
            fontSize: 14.0,
          );
          return false;
        }
        return true;
      },
      child: ViewModelBuilder<HomeViewModel>.reactive(
        viewModelBuilder: () => HomeViewModel(context),
        onViewModelReady: (vm) {
          vm.initialise();
        },
        builder: (context, vm, child) {
          return Scaffold(
            body: UpgradeAlert(
              upgrader: Upgrader(
                showIgnore: !AppUpgradeSettings.forceUpgrade(),
                shouldPopScope: () => !AppUpgradeSettings.forceUpgrade(),
                dialogStyle: Platform.isIOS
                    ? UpgradeDialogStyle.cupertino
                    : UpgradeDialogStyle.material,
              ),
              child: vm.currentUser?.deleteRequest == true
                  ? AccountDeletePage()
                  : Stack(
                      children: [
                        //home view
                        vm.currentUser == null
                            ? BusyIndicator().centered()
                            : !vm.currentUser!.isTaxiDriver
                                ? AssignedOrdersPage()
                                : TaxiOrderPage(),

                        //
                        AppHamburgerMenu(
                          ontap: () {
                            openMenuBottomSheet(context);
                          },
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  void openMenuBottomSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return HomeMenuView().h(context.percentHeight * 90);
      },
    );
  }
}
