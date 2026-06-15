import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:mahilasaarthi/my_app.dart';
import 'package:mahilasaarthi/services/general_app.service.dart';
import 'package:mahilasaarthi/services/local_storage.service.dart';
import 'package:mahilasaarthi/services/firebase.service.dart';
import 'package:mahilasaarthi/services/location_watcher.service.dart';
import 'package:mahilasaarthi/services/notification.service.dart';
import 'package:mahilasaarthi/services/overlay.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'constants/app_languages.dart';
import 'views/overlays/floating_app_bubble.view.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
//ssll handshake error
// class MyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return super.createHttpClient(context)
//       ..badCertificateCallback =
//           (X509Certificate cert, String host, int port) => true;
//   }
// }

// @pragma("vm:entry-point")
// void overlayMain() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(
//     const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: FloatingAppBubble(),
//     ),
//   );
// }

void main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      //setting up firebase notifications
      await Firebase.initializeApp();

      // if (kDebugMode) {
      //   // Force disable Crashlytics collection while doing every day development.
      //   // Temporarily toggle this to true if you want to test crash reporting in your app.
      //   await FirebaseCrashlytics.instance
      //       .setCrashlyticsCollectionEnabled(false);
      // } else {
      //   // Handle Crashlytics enabled status when not in Debug,
      //   // e.g. allow your users to opt-in to crash reporting.
      // }

      //
      await translator.init(
        localeType: LocalizationDefaultType.asDefined,
        languagesList: AppLanguages.codes,
        assetsDirectory: 'assets/lang/',
      );
      //
      await LocalStorageService.getPrefs();

      await NotificationService.clearIrrelevantNotificationChannels();
      await NotificationService.initializeAwesomeNotification();
      await NotificationService.listenToActions();
      await FirebaseService().setUpFirebaseMessaging();
      // FirebaseMessaging.onBackgroundMessage(
      //   GeneralAppService.onBackground  MessageHandler,
      // );
      LocationServiceWatcher.listenToDelayLocationUpdate();
      //

      //prevent ssl error
      // HttpOverrides.global = new MyHttpOverrides();
      // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
      // final bool? status = await FlutterOverlayWindow.requestPermission();
      // Run app!
      runApp(
        LocalizedApp(
          child: MyApp(),
        ),
      );
    },
    (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    },
  );
}




class LifecycleEventHandler extends WidgetsBindingObserver {
  final AsyncCallback resumeCallBack;
  final AsyncCallback suspendingCallBack;
  final AsyncCallback closed;

  LifecycleEventHandler({
    required this.resumeCallBack,
    required this.suspendingCallBack,
    required this.closed,
  });

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    print('state >>>>>>>>>>>>>>>>>>>>>> : ${state}');
    switch (state) {
      case AppLifecycleState.resumed:
          await resumeCallBack();
        break;
      case AppLifecycleState.inactive:
        await suspendingCallBack();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        await closed();
        break;
      default:
        break;
    }
  }
}