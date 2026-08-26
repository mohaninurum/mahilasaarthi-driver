import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:mahilasaarthi/constants/app_colors.dart';
import 'package:mahilasaarthi/my_app.dart';
import 'package:mahilasaarthi/services/auth.service.dart';
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

@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FloatingAppBubble(),
    ),
  );
}

// Global flag to check if translator initialized successfully
bool _translatorReady = false;

@pragma("vm:entry-point")
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await runZonedGuarded(
    () async {

      // Initialize Google Maps Renderer (Latest) to prevent legacy platform view surface crashes
      final GoogleMapsFlutterPlatform mapsImplementation =
          GoogleMapsFlutterPlatform.instance;
      if (mapsImplementation is GoogleMapsFlutterAndroid) {
        try {
          await mapsImplementation
              .initializeWithRenderer(AndroidMapRenderer.latest);
        } catch (e) {
          print("Google Maps Android Renderer init error: $e");
        }
      }

      // Custom ErrorWidget.builder to prevent Grey Screen of Death in Release Mode / Play Console
      ErrorWidget.builder = (FlutterErrorDetails details) {
        print("Flutter Release Error caught by builder: ${details.exception}");
        return Material(
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/app_icon.png',
                  width: 100,
                  height: 100,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.drive_eta, size: 80, color: Colors.blue),
                ),
                const SizedBox(height: 20),
                const CircularProgressIndicator(),
                Text('${details.exception}\n"${details.stack}'),
              ],
            ),
          ),
        );
      };

      try {
        // setting up firebase notifications
        await Firebase.initializeApp();
      } catch (e) {
        print("Firebase init error: $e");
      }

      try {
        await LocalStorageService.getPrefs();
        AppColor.getColorsFromLocalStorage();
      } catch (e) {
        print("LocalStorageService init error: $e");
      }

      try {
        final savedLocale = AuthServices.getLocale();
        final initialLang = (savedLocale.isNotEmpty && savedLocale != "null") ? savedLocale : 'en';
        await translator.init(
          localeType: LocalizationDefaultType.asDefined,
          language: initialLang,
          languagesList: AppLanguages.codes,
          assetsDirectory: 'assets/lang/',
        );
        _translatorReady = true;
      } catch (e) {
        print("Translator init error: $e");
        _translatorReady = false;
      }

      try {
        await NotificationService.clearIrrelevantNotificationChannels();
        await NotificationService.initializeAwesomeNotification();
        await NotificationService.listenToActions();
        await FirebaseService().setUpFirebaseMessaging();
      } catch (e) {
        print("Notification/Firebase Messaging init error: $e");
      }

      try {
        LocationServiceWatcher.listenToDelayLocationUpdate();
      } catch (e) {
        print("LocationServiceWatcher init error: $e");
      }

      // Run app! Wrap in LocalizedApp only if translator is ready
      if (_translatorReady) {
        runApp(
          LocalizedApp(
            child: MyApp(),
          ),
        );
      } else {
        runApp(MyApp());
      }
    },
    (error, stackTrace) {
      print("Global Error: $error");
      try {
        FirebaseCrashlytics.instance.recordError(error, stackTrace);
      } catch (e) {
        print("Crashlytics error: $e");
      }
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



//67d6878ad6fc0516ae5c1302