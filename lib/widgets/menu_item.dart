import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:mahilasaarthi/utils/ui_spacer.dart';
import 'package:mahilasaarthi/utils/utils.dart';
import 'package:velocity_x/velocity_x.dart';

class MenuItem extends StatelessWidget {
  const MenuItem({
    this.title,
    this.child,
    this.divider = true,
    this.topDivider = false,
    this.suffix,
    this.prefix,
    this.onPressed,
    Key? key,
  }) : super(key: key);

  //
  final String? title;
  final Widget? child;
  final bool divider;
  final bool topDivider;
  final Widget? suffix;
  final Widget? prefix;
  final Function? onPressed;

  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        //
        topDivider
            ? Divider(
                height: 1,
                thickness: 2,
              )
            : SizedBox.shrink(),

        //
        HStack(
          [
            prefix ?? UiSpacer.emptySpace(),

            //
            (child ?? "$title".text.lg.light.make()).expand(),
            //
            suffix ??
                Icon(
                  !Utils.isArabic
                      ? FlutterIcons.right_ant
                      : FlutterIcons.left_ant,
                  size: 16,
                ),
          ],
        ).py12().px8(),

        //
        divider
            ? Divider(
                height: 1,
                thickness: 2,
              )
            : SizedBox.shrink(),
      ],
    ).onInkTap(
      onPressed != null ? () => onPressed!() : null,
    );
  }
}
