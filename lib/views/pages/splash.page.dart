import 'package:flutter/material.dart';
import 'package:mahilasaarthi/constants/app_images.dart';
import 'package:mahilasaarthi/view_models/splash.vm.dart';
import 'package:mahilasaarthi/widgets/base.page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  String _trSafe(String text) {
    try {
      return text.tr();
    } catch (_) {
      return text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      // Explicit white background prevents grey flash before theme loads
      backgroundColor: Colors.white,
      body: ViewModelBuilder<SplashViewModel>.reactive(
        viewModelBuilder: () => SplashViewModel(context),
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, model, child) {
          // Always show the logo + status text — no grey retry screen
          return Container(
            color: Colors.white,
            child: VStack(
              [
                Image.asset(AppImages.appLogo)
                    .wh(context.percentWidth * 45, context.percentWidth * 45)
                    .box
                    .clip(Clip.antiAlias)
                    .roundedSM
                    .makeCentered()
                    .py12(),
                if (model.isBusy)
                  VStack([
                    _trSafe("Loading Please wait...").text.gray500.makeCentered(),
                    const SizedBox(height: 12),
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ).centered(),
                  ])
                else
                  _trSafe("Loading Please wait...").text.gray500.makeCentered(),
              ],
            ).centered(),
          );
        },
      ),
    );
  }
}
