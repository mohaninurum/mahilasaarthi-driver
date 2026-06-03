import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:mahilasaarthi/constants/app_colors.dart';
import 'package:mahilasaarthi/models/vendor.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../requests/auth.request.dart';
import '../../services/auth.service.dart';
import '../../utils/utils.dart';

class CallButton extends StatelessWidget {
  const CallButton(
    this.vendor, {
    this.size = 24,
    this.phoneModile,
    Key? key,
  }) : super(key: key);

  final Vendor? vendor;
  final String? phoneModile;
  final double size;
  @override
  Widget build(BuildContext context) {
    return Icon(
      FlutterIcons.phone_ant,
      size: size,
      color: Colors.white,
    ).p8().box.color(AppColor.primaryColor).roundedFull.make().onInkTap(() async {
      print(vendor?.phone ?? phoneModile);
      String phone = "";
      phone   = (await AuthServices.getCurrentUser()).phone.toString();

      // launchUrlString("tel://${vendor?.phone ?? phone}");

      Utils.showLoadingDialog(context);
      await AuthRequest().CallDriverApi(from: (phone.toString().contains("+91")) ?(phone.toString().substring(3,phone.length)) : phone,to: ((vendor?.phone ?? phoneModile).toString().contains("+91")) ?((vendor?.phone ?? phoneModile).toString().substring(3,(vendor?.phone ?? phoneModile)!.length)  ):(vendor?.phone ?? phoneModile));
      Navigator.pop(context);
    });
  }
}
