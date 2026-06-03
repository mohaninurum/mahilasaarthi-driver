import 'dart:async';
import 'dart:ui' as ui;

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mahilasaarthi/constants/app_colors.dart';
import 'package:mahilasaarthi/constants/app_strings.dart';
import 'package:mahilasaarthi/services/http.service.dart';
import 'package:jiffy/jiffy.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class Utils {
  static Widget appLoadingLogo() {
    return Center(
      child: SizedBox(
        width: 120,
        height: 120,
        child: Image.asset(
          'assets/images/ic_logo.png',
          width: 120,
          height: 120,
        ),
      ),
    );
  }

  static void showLoadingDialog(BuildContext context,
      {bool? isDismissible, bool? useLogo = false}) {
    showDialog(
        context: context,
        barrierDismissible: isDismissible != null ? isDismissible : false,
        builder: (BuildContext context) {
          return useLogo! ? appLoadingLogo() : appLoading();
        });
  }

  static Widget appLoading(
      {bool adaptive = false, double? width, double? height}) {
    return Center(
      child: SizedBox(
        width: width,
        height: height,
        child: adaptive
            ? const CircularProgressIndicator.adaptive()
            : const CircularProgressIndicator(), //SvgPicture.asset('assets/svg/ic_icon.svg', width: 50, height: 50,),
      ),
    );
  }

  //
  static bool get isArabic => translator.activeLocale.languageCode == "ar";

  static TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;
  //
  static bool get currencyLeftSided {
    final uiConfig = AppStrings.uiConfig;
    if (uiConfig != null && uiConfig["currency"] != null) {
      final currencylOCATION = uiConfig["currency"]["location"] ?? 'left';
      return currencylOCATION.toLowerCase() == "left";
    } else {
      return true;
    }
  }

  static bool isDark(Color color) {
    return ColorUtils.calculateRelativeLuminance(
            color.red, color.green, color.blue) <
        0.5;
  }

  static bool isPrimaryColorDark([Color? mColor]) {
    final color = mColor ?? AppColor.primaryColor;
    return ColorUtils.calculateRelativeLuminance(
            color.red, color.green, color.blue) <
        0.5;
  }

  static Color textColorByTheme() {
    return isPrimaryColorDark() ? Colors.white : Colors.black;
  }

  static Color textColorByColor(Color color) {
    return isPrimaryColorDark(color) ? Colors.white : Colors.black;
  }

  ///
  Future<Uint8List> getBytesFromCanvas(int width, int height, urlAsset) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final ByteData datai = await rootBundle.load(urlAsset);
    var imaged = await loadImage(new Uint8List.view(datai.buffer));
    canvas.drawImageRect(
      imaged,
      Rect.fromLTRB(
          0.0, 0.0, imaged.width.toDouble(), imaged.height.toDouble()),
      Rect.fromLTRB(0.0, 0.0, width.toDouble(), height.toDouble()),
      new Paint(),
    );

    final img = await pictureRecorder.endRecording().toImage(width, height);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List() ?? Uint8List(0);
  }

  Future<ui.Image> loadImage(Uint8List img) async {
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  static setJiffyLocale() async {
    String cLocale = translator.activeLocale.languageCode;
    List<String> supportedLocales = Jiffy.getAllAvailableLocales();
    if (supportedLocales.contains(cLocale)) {
      await Jiffy.locale(translator.activeLocale.languageCode);
    } else {
      await Jiffy.locale("en");
    }
  }

  //get country code
  static Future<String> getCurrentCountryCode() async {
    String countryCode = "US";
    try {
      //make request to get country code over HTTPS
      final response = await HttpService().dio.get(
            "https://ipinfo.io/json",
          );
      //get the country code
      countryCode = response.data["country"];
    } catch (e) {
      try {
        countryCode = AppStrings.countryCode
            .toUpperCase()
            .replaceAll("AUTO", "")
            .replaceAll("INTERNATIONAL", "")
            .split(",")[0];
      } catch (e) {
        countryCode = "us";
      }
    }

    return countryCode.toUpperCase();
  }

  static String getFormattedPhoneNumber(String rawPhone, String phoneCode) {
    // 1. Remove all spaces, dashes, and parentheses
    String phone = rawPhone.replaceAll(RegExp(r'[\s\-()]'), '');

    // 2. Remove leading zeros
    phone = phone.replaceFirst(RegExp(r'^0+'), '');

    // 3. Check if the phone already starts with the country's phone code (with or without '+')
    if (phone.startsWith('+$phoneCode')) {
      return phone;
    } else if (phone.startsWith(phoneCode)) {
      return '+$phone';
    } else if (phone.startsWith('+')) {
      // Starts with some other country code, return as is
      return phone;
    }

    // 4. Otherwise, prepend the country's phone code
    return '+$phoneCode$phone';
  }
}
