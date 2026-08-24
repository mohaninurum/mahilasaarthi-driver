import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mahilasaarthi/constants/app_strings.dart';
import 'package:mahilasaarthi/services/local_storage.service.dart';
import 'package:velocity_x/velocity_x.dart';

class AppColor {
  static Color _safeHexColor(String colorRef, Color defaultColor) {
    try {
      final hex = colorEnv(colorRef);
      if (hex.isEmpty || hex == "#000000") return defaultColor;
      return Vx.hexToColor(hex);
    } catch (_) {
      return defaultColor;
    }
  }

  static int _safeHexInt(String colorRef, int defaultColorInt) {
    try {
      final hex = colorEnv(colorRef);
      if (hex.isEmpty || hex == "#000000") return defaultColorInt;
      return Vx.getColorFromHex(hex);
    } catch (_) {
      return defaultColorInt;
    }
  }

  static Color get accentColor => _safeHexColor('accentColor', const Color(0xFF5E17EB));
  static Color get primaryColor => _safeHexColor('primaryColor', const Color(0xFF5E17EB));
  static Color get primaryColorDark => _safeHexColor('primaryColorDark', const Color(0xFF3B0CA7));
  static Color get cursorColor => accentColor;

  //material color
  static MaterialColor get accentMaterialColor => MaterialColor(
        _safeHexInt('accentColor', 0xFF5E17EB),
        <int, Color>{
          50: accentColor,
          100: accentColor,
          200: accentColor,
          300: accentColor,
          400: accentColor,
          500: accentColor,
          600: accentColor,
          700: accentColor,
          800: accentColor,
          900: accentColor,
        },
      );
  static MaterialColor get primaryMaterialColor => MaterialColor(
        _safeHexInt('primaryColor', 0xFF5E17EB),
        <int, Color>{
          50: primaryColor,
          100: primaryColor,
          200: primaryColor,
          300: primaryColor,
          400: primaryColor,
          500: primaryColor,
          600: primaryColor,
          700: Vx.hexToColor(colorEnv('primaryColor')),
          800: Vx.hexToColor(colorEnv('primaryColor')),
          900: Vx.hexToColor(colorEnv('primaryColor')),
        },
      );
  static Color get primaryMaterialColorDark =>
      Vx.hexToColor(colorEnv('primaryColorDark'));
  static Color get cursorMaterialColor => accentColor;

  //onboarding colors
  static Color get onboarding1Color =>
      Vx.hexToColor(colorEnv('onboarding1Color'));
  static Color get onboarding2Color =>
      Vx.hexToColor(colorEnv('onboarding2Color'));
  static Color get onboarding3Color =>
      Vx.hexToColor(colorEnv('onboarding3Color'));

  static Color get onboardingIndicatorDotColor =>
      Vx.hexToColor(colorEnv('onboardingIndicatorDotColor'));
  static Color get onboardingIndicatorActiveDotColor =>
      Vx.hexToColor(colorEnv('onboardingIndicatorActiveDotColor'));

  //Shimmer Colors
  static Color shimmerBaseColor = Colors.grey.shade300;
  static Color shimmerHighlightColor = Colors.grey.shade200;

  //inputs
  static Color get inputFillColor => Colors.grey.shade200;
  static Color get iconHintColor => Colors.grey.shade500;

  static Color get openColor => Vx.hexToColor(colorEnv('openColor'));
  static Color get closeColor => Vx.hexToColor(colorEnv('closeColor'));
  static Color get deliveryColor => Vx.hexToColor(colorEnv('deliveryColor'));
  static Color get pickupColor => Vx.hexToColor(colorEnv('pickupColor'));
  static Color get ratingColor => Vx.hexToColor(colorEnv('ratingColor'));
  static Color get deliveredColor => getStausColor("delivered");

  static Color getStausColor(String status) {
    //'pending','preparing','enroute','failed','cancelled','delivered'
    switch (status) {
      case "pending":
        return Vx.hexToColor(colorEnv('pendingColor'));

      case "preparing":
        return Vx.hexToColor(colorEnv('preparingColor'));

      case "enroute":
        return Vx.hexToColor(colorEnv('enrouteColor'));

      case "failed":
        return Vx.hexToColor(colorEnv('failedColor'));

      case "cancelled":
        return Vx.hexToColor(colorEnv('cancelledColor'));

      case "delivered":
        return Vx.hexToColor(colorEnv('deliveredColor'));
      case "successful":
        return Vx.hexToColor(colorEnv('successfulColor'));

      default:
        return Vx.hexToColor(colorEnv('pendingColor'));
    }
  }

  //saving
  static Future<bool> saveColorsToLocalStorage(String colorsMap) async {
    try {
      appColorsObject = jsonDecode(colorsMap);
    } catch (e) {
      print("Error decoding colors map: $e");
    }
    return await LocalStorageService.prefs
        ?.setString(AppStrings.appColors, colorsMap) ?? false;
  }

  static dynamic appColorsObject;
  static void getColorsFromLocalStorage() {
    try {
      if (appColorsObject != null) return;
      final colorsStr = LocalStorageService.prefs?.getString(AppStrings.appColors);
      if (colorsStr != null && colorsStr.isNotEmpty) {
        appColorsObject = jsonDecode(colorsStr);
      }
    } catch (e) {
      print("Error reading colors from local storage: $e");
    }
  }

  static String colorEnv(String colorRef) {
    try {
      getColorsFromLocalStorage();
      final selectedColor =
          appColorsObject != null ? appColorsObject[colorRef] : "#000000";
      if (selectedColor == null || selectedColor.toString().isEmpty) {
        return "#000000";
      }
      return selectedColor.toString();
    } catch (_) {
      return "#000000";
    }
  }
}
