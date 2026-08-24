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
import 'package:mahilasaarthi/services/app.service.dart';
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
  //
  loadAppSettings() async {
    setBusy(true);
    try {
      final appSettingsObject = await settingsRequest.appSettings();
      // Fetch emergency contacts explicitly
      try {
        final emergencyResult = await settingsRequest.emergencyContacts();
        if (emergencyResult.body is Map && emergencyResult.body["driverEmergencyContact"] != null) {
          final driverSOS = emergencyResult.body["driverEmergencyContact"] ?? "112";
          await LocalStorageService.prefs?.setString('customDriverSOS', driverSOS);
        }
      } catch (e) {
        print("Emergency contacts fetch error: $e");
      }
      
      //app settings
      try {
        if (appSettingsObject.body is Map && appSettingsObject.body["strings"] != null) {
          await updateAppVariables(appSettingsObject.body["strings"]);
        }
      } catch (e) {
        print("updateAppVariables error: $e");
      }
      //colors
      try {
        if (appSettingsObject.body is Map && appSettingsObject.body["colors"] != null) {
          await updateAppTheme(appSettingsObject.body["colors"]);
        }
      } catch (e) {
        print("updateAppTheme error: $e");
      }
    } catch (error) {
      print("Error loading app settings ==> $error");
      // Show a user-friendly message on timeout / no internet
      try {
        final isDioTimeout = error.toString().contains('connectTimeout') ||
            error.toString().contains('timed out');
        final msg = isDioTimeout
            ? "Server connection timed out. Using cached settings."
            : "Could not load settings. Please check your internet.";
        final ctx = AppService().navigatorKey.currentContext ?? viewContext;
        if (ctx != null) {
          ScaffoldMessenger.of(ctx).showSnackBar(
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
        }
      } catch (_) {}
    } finally {
      setBusy(false);
      await loadNextPage();
    }
  }

  //
  updateAppVariables(dynamic json) async {
    try {
      await AppStrings.saveAppSettingsToLocalStorage(jsonEncode(json));
    } catch (e) {
      print("Error saving app variables: $e");
    }
  }

  //theme change
  updateAppTheme(dynamic colorJson) async {
    try {
      await AppColor.saveColorsToLocalStorage(jsonEncode(colorJson));
      final ctx = AppService().navigatorKey.currentContext ?? viewContext;
      if (ctx != null) {
        AdaptiveTheme.of(ctx).setTheme(
          light: AppTheme().lightTheme(),
          dark: AppTheme().darkTheme(),
          notify: true,
        );
        await AdaptiveTheme.of(ctx).persist();
      }
    } catch (e) {
      print("Error updating theme: $e");
    }
  }

  //
  loadNextPage() async {
    try {
      await Utils.setJiffyLocale();
    } catch (e) {
      print("Error setting Jiffy locale: $e");
    }

    final contextToUse = AppService().navigatorKey.currentContext ?? viewContext;

    try {
      if (AuthServices.firstTimeOnApp()) {
        if (contextToUse != null) {
          await showModalBottomSheet(
            context: contextToUse,
            builder: (context) {
              return AppLanguageSelector();
            },
          );
        }
      }
    } catch (e) {
      print("Error opening language selector: $e");
    }

    final targetRoute = !AuthServices.authenticated()
        ? AppRoutes.welcomeRoute
        : AppRoutes.homeRoute;

    try {
      if (AppService().navigatorKey.currentState != null) {
        AppService().navigatorKey.currentState!.pushNamedAndRemoveUntil(
          targetRoute,
          (route) => false,
        );
      } else if (viewContext != null) {
        Navigator.of(viewContext).pushNamedAndRemoveUntil(
          targetRoute,
          (route) => false,
        );
      }
    } catch (e) {
      print("Navigation error: $e");
    }

    try {
      RemoteMessage? initialMessage =
          await FirebaseService().firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        FirebaseService().saveNewNotification(initialMessage);
        FirebaseService().notificationPayloadData = initialMessage.data;
        FirebaseService().selectNotification("");
      }
    } catch (e) {
      print("Firebase messaging initial message error: $e");
    }
  }
}
