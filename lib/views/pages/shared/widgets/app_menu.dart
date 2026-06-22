import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:mahilasaarthi/utils/utils.dart';
import 'package:velocity_x/velocity_x.dart';

class AppHamburgerMenu extends StatelessWidget {
  const AppHamburgerMenu({
    Key? key,
    required this.ontap,
  }) : super(key: key);

  final Function ontap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      left: Utils.isArabic ? null : 12,
      right: !Utils.isArabic ? null : 12,
      child: VxBox(
        child: Icon(
          FlutterIcons.menu_fea,
        ).p4(),
      )
          .p8
          .color(context.theme.colorScheme.background)
          .roundedSM
          .outerShadow
          // .shadowXl
          .make()
          .onTap(() => ontap())
          .safeArea(),
    );
  }
}
