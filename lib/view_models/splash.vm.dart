import 'dart:convert';
import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_background/flutter_background.dart';
import 'package:mahilasaarthi/constants/app_colors.dart';
import 'package:mahilasaarthi/constants/app_routes.dart';
import 'package:mahilasaarthi/constants/app_strings.dart';
import 'package:mahilasaarthi/constants/app_theme.dart';
import 'package:mahilasaarthi/requests/settings.request.dart';
import 'package:mahilasaarthi/services/auth.service.dart';
import 'package:mahilasaarthi/services/firebase.service.dart';
import 'package:mahilasaarthi/services/local_storage.service.dart';
import 'package:mahilasaarthi/utils/utils.dart';
import 'package:mahilasaarthi/views/pages/permission/permission.page.dart';
import 'package:mahilasaarthi/widgets/cards/language_selector.view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'base.view_model.dart';
import 'package:velocity_x/velocity_x.dart';

class SplashViewModel extends MyBaseViewModel {
  SplashViewModel(BuildContext context) {
    this.viewContext = context;
  }

  //
  SettingsRequest settingsRequest = SettingsRequest();

  //
  initialise() async {
    super.initialise();
    await loadAppSettings();
  }

  //

  //
  loadAppSettings() async {
    setBusy(true);
    try {
      final appSettingsObject = await settingsRequest.appSettings();
      // Fetch emergency contacts explicitly
      try {
        final emergencyResult = await settingsRequest.emergencyContacts();
        final driverSOS = emergencyResult.body["driverEmergencyContact"] ?? "112";
        await LocalStorageService.prefs?.setString('customDriverSOS', driverSOS);
      } catch (e) {
        print("Emergency contacts fetch error: $e");
      }
      
      //app settings
      await updateAppVariables(appSettingsObject.body["strings"]);
      //colors
      await updateAppTheme(appSettingsObject.body["colors"]);
      loadNextPage();
    } catch (error) {
      print("Error loading app settings ==> $error");
      // Show a user-friendly message on timeout / no internet
      try {
        final isDioTimeout = error.toString().contains('connectTimeout') ||
            error.toString().contains('timed out');
        final msg = isDioTimeout
            ? "Server connection timed out. Using cached settings."
            : "Could not load settings. Please check your internet.";
        ScaffoldMessenger.of(viewContext).showSnackBar(
          SnackBar(
            content: Text(msg, style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.orange.shade800,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      } catch (_) {}
      // Proceed anyway so the app doesn't freeze on the splash screen.
      try {
        loadNextPage();
      } catch (navError) {
        print("Navigation error after settings failure ==> $navError");
      }
    }
    setBusy(false);
  }

  //
  updateAppVariables(dynamic json) async {
    //
    await AppStrings.saveAppSettingsToLocalStorage(jsonEncode(json));
  }

  //theme change
  updateAppTheme(dynamic colorJson) async {
    //
    await AppColor.saveColorsToLocalStorage(jsonEncode(colorJson));
    //change theme
    // await AdaptiveTheme.of(viewContext).reset();
    AdaptiveTheme.of(viewContext).setTheme(
      light: AppTheme().lightTheme(),
      dark: AppTheme().darkTheme(),
      notify: true,
    );
    await AdaptiveTheme.of(viewContext).persist();
  }

  //
  loadNextPage() async {
    //
    await Utils.setJiffyLocale();
    //
    if (AuthServices.firstTimeOnApp()) {
      //choose language
      await showModalBottomSheet(
        context: viewContext,
        builder: (context) {
          return AppLanguageSelector();
        },
      );
    }

    //
    if (AuthServices.firstTimeOnApp()) {
      Navigator.of(viewContext)
          .pushNamedAndRemoveUntil(AppRoutes.welcomeRoute, (route) => false);
    } else if (!AuthServices.authenticated()) {
      Navigator.of(viewContext)
          .pushNamedAndRemoveUntil(AppRoutes.loginRoute, (route) => false);
    } else {
      // We intentionally do not check permissions here to comply with Google Play policy
      // Permissions will be requested in-context when the driver tries to 'Go Online'
      Navigator.of(viewContext).pushNamedAndRemoveUntil(
        AppRoutes.homeRoute,
        (route) => false,
      );
    }

    //
    RemoteMessage? initialMessage =
        await FirebaseService().firebaseMessaging.getInitialMessage();
    if (initialMessage == null) {
      return;
    }
    FirebaseService().saveNewNotification(initialMessage);
    FirebaseService().notificationPayloadData = initialMessage.data;
    FirebaseService().selectNotification("");
  }
}
