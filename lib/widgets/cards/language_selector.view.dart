import 'package:flutter/material.dart';
import 'package:flag/flag.dart';
import 'package:mahilasaarthi/constants/app_languages.dart';
import 'package:mahilasaarthi/services/auth.service.dart';
import 'package:mahilasaarthi/utils/ui_spacer.dart';
import 'package:mahilasaarthi/utils/utils.dart';
import 'package:mahilasaarthi/widgets/custom_grid_view.dart';

import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class AppLanguageSelector extends StatelessWidget {
  const AppLanguageSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: VStack(
        [
          //
          "Select your preferred language"
              .tr()
              .text
              .xl
              .semiBold
              .make()
              .py20()
              .px12(),
          UiSpacer.divider(),

          //
          ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: AppLanguages.codes.length,
            itemBuilder: (ctx, index) {
              return VStack(

                [
                  // //
                  // Flag.fromString(
                  //   AppLanguages.flags[index],
                  //   height: 40,
                  //   width: 40,
                  // ),
                  // UiSpacer.verticalSpace(space: 5),
                  //
                  index != 0 ?  Divider(thickness: 0.7,).h(0.5).color(Vx.green50):SizedBox(),
                  8.heightBox,
                  AppLanguages.names[index].text.bold.make().px12(),
                  8.heightBox,
                ],
                crossAlignment: CrossAxisAlignment.start,
                alignment: MainAxisAlignment.center,
              )

                  .box
                  .roundedSM
                  .color(context.canvasColor)
                  .make().onTap(() {
                _onSelected(context, AppLanguages.codes[index]);
              });
            },
          ).expand(),
          // VStack(
          //   [
          //     ...(AppLanguages.codes.mapIndexed((code, index) {
          //       return MenuItem(
          //         title: AppLanguages.names[index],
          //         suffix: Flag.fromString(
          //           AppLanguages.flags[index],
          //           height: 24,
          //           width: 24,
          //         ),
          //         onPressed: () => _onSelected(context, code),
          //       );
          //     }).toList()),
          //   ],
          // ).scrollVertical().expand(),
        ],
      ),
    ).hThreeForth(context);
  }

  void _onSelected(BuildContext context, String code) async {
    await AuthServices.setLocale(code);
    //
    await translator.setNewLanguage(
      context,
      newLanguage: code,
      remember: true,
      restart: true,
    );
    await Utils.setJiffyLocale();
    //
    Navigator.pop(context, true);
  }
}



