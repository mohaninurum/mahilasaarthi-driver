import 'package:flutter/material.dart';
import 'package:mahilasaarthi/services/app.service.dart';

class ToastService {
  static void _show(String msg, Color bgColor) {
    final context =
        AppService().navigatorKey.currentContext ??
        AppService().navigatorKey.currentState?.overlay?.context;
    if (context == null) {
      debugPrint('[ToastService] No context available, cannot show toast: $msg');
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static void toastSuccessful(String msg) => _show(msg, Colors.green.shade700);

  static void toastError(String msg, {dynamic length}) =>
      _show(msg, Colors.red.shade700);
}
