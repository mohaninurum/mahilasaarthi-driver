import 'dart:io';

import 'package:cool_alert/cool_alert.dart';
import 'package:custom_faqs/custom_faqs.dart';
import 'package:flutter/material.dart';
import 'package:mahilasaarthi/views/pages/payment_account/payment_account.page.dart';
import 'package:mahilasaarthi/views/pages/profile/account_delete.page.dart';
import 'package:mahilasaarthi/views/pages/splash.page.dart';
import 'package:mahilasaarthi/widgets/bottomsheets/earning.bottomsheet.dart';
import 'package:mahilasaarthi/constants/api.dart';
import 'package:mahilasaarthi/constants/app_routes.dart';
import 'package:mahilasaarthi/constants/app_strings.dart';
import 'package:mahilasaarthi/models/user.dart';
import 'package:mahilasaarthi/requests/auth.request.dart';
import 'package:mahilasaarthi/services/auth.service.dart';
import 'package:mahilasaarthi/view_models/base.view_model.dart';
import 'package:mahilasaarthi/widgets/cards/language_selector.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:package_info/package_info.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:velocity_x/velocity_x.dart';

class ProfileViewModel extends MyBaseViewModel {
  //
  String appVersionInfo = "";
  User? currentUser;

  //
  AuthRequest _authRequest = AuthRequest();

  ProfileViewModel(BuildContext context) {
    this.viewContext = context;
  }

  void initialise() async {
    PackageInfo.fromPlatform().then((packageInfo) {
      String versionName = packageInfo.version;
      String versionCode = packageInfo.buildNumber;
      appVersionInfo = "$versionName($versionCode)";
      notifyListeners();
    }).catchError((error) {
      print("Error loading package info: $error");
    });

    try {
      currentUser = await AuthServices.getCurrentUser(force: true);
      notifyListeners();
    } catch (error) {
      print("Error loading local user: $error");
    }

    try {
      final updatedUser = await _authRequest.getMyDetails();
      currentUser = updatedUser;
      notifyListeners();
    } catch (error) {
      print("Error fetching updated profile in ProfileViewModel ==> $error");
    }
    setBusy(false);
  }

  /**
   * Edit Profile
   */

  openEditProfile() async {
    final result = await Navigator.of(viewContext).pushNamed(
      AppRoutes.editProfileRoute,
    );

    if (result != null && result is bool && result) {
      initialise();
    }
  }

  /**
   * Change Password
   */

  openChangePassword() async {
    Navigator.of(viewContext).pushNamed(
      AppRoutes.changePasswordRoute,
    );
  }

  /**
   * Delivery addresses
   */
  openDeliveryAddresses() {
    Navigator.of(viewContext).pushNamed(
      AppRoutes.deliveryAddressesRoute,
    );
  }

  //
  openFavourites() {
    Navigator.of(viewContext).pushNamed(
      AppRoutes.favouritesRoute,
    );
  }

  //Earning
  showEarning() async {
    showModalBottomSheet(
      context: viewContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return EarningBottomSheet();
      },
    );
  }

  /**
   * Logout
   */
  logoutPressed() async {
    CoolAlert.show(
      context: viewContext,
      type: CoolAlertType.confirm,
      title: "Logout".tr(),
      text: "Are you sure you want to logout?".tr(),
      onConfirmBtnTap: () {
        Navigator.pop(viewContext);
        processLogout();
      },
    );
  }

  void processLogout() async {
    //
    CoolAlert.show(
      context: viewContext,
      type: CoolAlertType.loading,
      title: "Logout".tr(),
      text: "Logging out Please wait...".tr(),
      barrierDismissible: false,
    );

    //
    final apiResponse = await _authRequest.logoutRequest();

    //
    Navigator.pop(viewContext);

    if (!apiResponse.allGood) {
      //
      CoolAlert.show(
        context: viewContext,
        type: CoolAlertType.error,
        title: "Logout",
        text: apiResponse.message,
      );
    } else {
      //
      await AuthServices.logout();
      Navigator.of(viewContext).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SplashPage()),
        (route) => false,
      );
    }
  }

  openWallet() async {
    Navigator.of(viewContext).pushNamed(
      AppRoutes.walletRoute,
    );
  }

  openPaymentAccounts() async {
    Navigator.push(viewContext, MaterialPageRoute(builder: (context) => PaymentAccountPage()));
  }

  openNotification() async {
    Navigator.of(viewContext).pushNamed(
      AppRoutes.notificationsRoute,
    );
  }

  openPhonepe() async {
    Navigator.of(viewContext).pushNamed(
      AppRoutes.notificationsRoute,
    );
  }

  /**
   * App Rating & Review
   */
  openReviewApp() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (Platform.isAndroid) {
      inAppReview.openStoreListing(appStoreId: AppStrings.appStoreId);
    } else if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    } else {
      inAppReview.openStoreListing(appStoreId: AppStrings.appStoreId);
    }
  }

  openFaqs() {
    viewContext.nextPage(
      CustomFaqPage(
        title: 'Faqs'.tr(),
        link: Api.baseUrl + Api.faqs,
      ),
    );
  }

  //
  openPrivacyPolicy() async {
    final url = Api.privacyPolicy;
    openWebpageLink(url);
  }

  openTerms() {
    final url = Api.terms;
    openWebpageLink(url);
  }

  //
  openContactUs() async {
    final url = Api.contactUs;
    openWebpageLink(url);
  }

  openLivesupport() async {
    final url = Api.inappSupport;
    openWebpageLink(url);
  }

  //
  changeLanguage() async {
    showModalBottomSheet(
      context: viewContext,
      builder: (context) {
        return AppLanguageSelector();
      },
    );
  }

  deleteAccount() {
    viewContext.nextPage(AccountDeletePage());
  }
}



