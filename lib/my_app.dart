import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:mahilasaarthi/constants/app_theme.dart';
import 'package:mahilasaarthi/services/app.service.dart';
import 'package:mahilasaarthi/services/overlay.service.dart';
import 'package:mahilasaarthi/views/pages/splash.page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'constants/app_strings.dart';
import 'package:mahilasaarthi/services/router.service.dart' as router;

import 'main.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  // @override
  // Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
  //   if(state ==  0){
  //     OverlayService().closeFloatingBubble();
  //
  //   }else{
  //     bool status = await FlutterOverlayWindow.isPermissionGranted();
  //
  //   if(status){
  //     OverlayService().showFloatingBubble();
  //   }else{
  //      await FlutterOverlayWindow.requestPermission();
  //   }
  //
  //   }
  // }

//   @override
//   Future<void> initState() async {
//     super.initState();
//     bool  statuss = await FlutterOverlayWindow.isPermissionGranted() ;
// if(statuss){
//   WidgetsBinding.instance.addObserver(
//       LifecycleEventHandler(
//         resumeCallBack: () async {
//           print("APP RESUMNE");
//           OverlayService().closeFloatingBubble();
//
//         }, suspendingCallBack: () async {
//       },closed: () async{
//         OverlayService().closeFloatingBubble();
//       },)
//   );
//   WidgetsBinding.instance.addObserver(this);
//
// }else{
//   bool  status = await FlutterOverlayWindow.requestPermission() ?? false;
//
// }
//   }

  // @override
  // void dispose() {
  //   WidgetsBinding.instance.removeObserver(this);
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    // Safe getters to prevent RangeError / Empty list if translator failed to initialize
    Locale safeLocale;
    try {
      safeLocale = translator.activeLocale;
    } catch (_) {
      safeLocale = const Locale('en');
    }

    Iterable<LocalizationsDelegate<dynamic>>? safeDelegates;
    try {
      final delegates = translator.delegates;
      if (delegates.isNotEmpty) {
        safeDelegates = delegates;
      }
    } catch (_) {}

    Iterable<Locale> safeLocals = const [Locale('en'), Locale('hi')];
    try {
      final locals = translator.locals();
      if (locals.isNotEmpty) {
        safeLocals = locals;
      }
    } catch (_) {}

    return AdaptiveTheme(
      light: AppTheme().lightTheme(),
      dark: AppTheme().darkTheme(),
      initial: AdaptiveThemeMode.system,
      builder: (theme, darkTheme) {
        return MaterialApp(
          navigatorKey: AppService().navigatorKey,
          debugShowCheckedModeBanner: false,
          title: AppStrings.appName,
          onGenerateRoute: router.generateRoute,
          // initialRoute: _startRoute,
          localizationsDelegates: safeDelegates,
          locale: safeLocale,
          supportedLocales: safeLocals,
          home: SplashPage(),
          theme: AppTheme().lightTheme(),
          // darkTheme: AppTheme().lightTheme(),
        );
      },
    );
  }
}
