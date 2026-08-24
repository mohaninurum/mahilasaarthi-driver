import 'package:flutter/material.dart';
import 'package:flutter_overboard/flutter_overboard.dart';
import 'package:mahilasaarthi/constants/app_images.dart';
import 'package:mahilasaarthi/constants/app_routes.dart';
import 'package:mahilasaarthi/requests/settings.request.dart';
import 'package:mahilasaarthi/services/app.service.dart';
import 'package:mahilasaarthi/services/auth.service.dart';
import 'package:mahilasaarthi/utils/ui_spacer.dart';
import 'package:mahilasaarthi/utils/utils.dart';
import 'package:mahilasaarthi/widgets/custom_image.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'base.view_model.dart';
import 'package:velocity_x/velocity_x.dart';

class OnboardingViewModel extends MyBaseViewModel {
  OnboardingViewModel(BuildContext context, this.finishLoading) {
    this.viewContext = context;
  }

  final Function finishLoading;

  List<PageModel> onBoardData = [];

  initialise() {
    final bgColor = viewContext.theme.colorScheme.background;
    final textColor =
        Utils.textColorByColor(viewContext.theme.colorScheme.background);

    onBoardData = [
      PageModel(
        color: bgColor,
        titleColor: textColor,
        bodyColor: textColor,
        imageAssetPath: AppImages.onboarding1,
        title: "Delivery made easy".tr(),
        body: "Get notified as soon as an order is available for delivery".tr(),
        doAnimateImage: true,
      ),
      PageModel(
        color: bgColor,
        titleColor: textColor,
        bodyColor: textColor,
        imageAssetPath: AppImages.onboarding2,
        title: "Chat with vendor/customer".tr(),
        body:
            "Call/Chat with vendor/driver boy for update about your order and more"
                .tr(),
        doAnimateImage: true,
      ),
      PageModel(
        color: bgColor,
        titleColor: textColor,
        bodyColor: textColor,
        imageAssetPath: AppImages.onboarding3,
        title: "Earning".tr(),
        body: "You get commissions from every delivery made".tr(),
        doAnimateImage: true,
      ),
    ];
    //
    loadOnboardingData();
  }

  loadOnboardingData() async {
    setBusy(true);
    try {
      final apiResponse = await SettingsRequest().appOnboardings();
      final listData = apiResponse.data;
      //load the data
      if (apiResponse.allGood && listData is List && listData.isNotEmpty) {
        final mOnBoardDatas = listData.map(
          (e) {
            return PageModel.withChild(
              child: VStack(
                [
                  Padding(
                    padding: new EdgeInsets.only(bottom: 25.0),
                    child: CustomImage(
                      imageUrl: "${e['photo']}",
                      width: viewContext.percentWidth * 50,
                      height: viewContext.percentWidth * 50,
                      boxFit: BoxFit.cover,
                    ).centered(),
                  ),
                  "${e["title"]}".tr().text.xl3.bold.make(),
                  UiSpacer.vSpace(5),
                  "${e["description"]}".tr().text.lg.hairLine.make(),
                ],
              ).p20(),
              color: viewContext.theme.colorScheme.background,
              doAnimateChild: true,
            );
          },
        ).toList();
        //
        if (mOnBoardDatas.isNotEmpty) {
          onBoardData = mOnBoardDatas;
        }
      }
    } catch (error) {
      print("Error loading onboarding data: $error");
    } finally {
      setBusy(false);
      finishLoading();
    }
  }

  void onDonePressed() async {
    try {
      await AuthServices.firstTimeCompleted();
    } catch (e) {
      print("Error marking first time completed: $e");
    }

    try {
      final navState = AppService().navigatorKey.currentState;
      if (navState != null) {
        navState.pushNamedAndRemoveUntil(
          AppRoutes.loginRoute,
          (route) => false,
        );
      } else {
        Navigator.of(viewContext).pushNamedAndRemoveUntil(
          AppRoutes.loginRoute,
          (route) => false,
        );
      }
    } catch (e) {
      print("Error navigating from onboarding: $e");
    }
  }
}
