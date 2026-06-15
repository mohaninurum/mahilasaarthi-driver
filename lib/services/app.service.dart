import 'dart:async';
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:mahilasaarthi/models/order.dart';
import 'package:random_string/random_string.dart';
import 'package:rxdart/rxdart.dart';
import 'package:singleton/singleton.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class AppService {
  //

  /// Factory method that reuse same instance automatically
  factory AppService() => Singleton.lazy(() => AppService._());

  /// Private constructor
  AppService._() {}

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  BehaviorSubject<int> homePageIndex = BehaviorSubject<int>();
  BehaviorSubject<bool> refreshAssignedOrders = BehaviorSubject<bool>();
  BehaviorSubject<Order> addToAssignedOrders = BehaviorSubject<Order>();
  bool driverIsOnline = false;
  StreamSubscription? actionStream;
  List<int> ignoredOrders = [];
  AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();

  changeHomePageIndex({int index = 2}) async {
    print("Changed Home Page");
    homePageIndex.add(index);
  }

  //
  void playNotificationSound() {
    try {
      assetsAudioPlayer.stop();
    } catch (error) {
      print("Error stopping audio player: $error");
    }

    try {
      assetsAudioPlayer = AssetsAudioPlayer(); // Get singleton back
      assetsAudioPlayer.open(
        Audio("assets/audio/alert.mp3"),
        autoStart: true,
        loopMode: LoopMode.single,
        notificationSettings: NotificationSettings(
          nextEnabled: false,
          prevEnabled: false,
          stopEnabled: false,
          seekBarEnabled: false,
        ),
        showNotification: true,
        playInBackground: PlayInBackground.enabled,
      );
      assetsAudioPlayer.play(); // Explicit play just in case
    } catch (error) {
      print("Error playing audio: $error");
    }
  }

  void stopNotificationSound() {
    try {
      assetsAudioPlayer.stop();
    } catch (error) {
      print("Error stopping audio player: $error");
    }
  }

  Future<File?> compressFile(File file, {int quality = 50}) async {
    final dir = await path_provider.getTemporaryDirectory();
    final targetPath =
        dir.absolute.path + "/temp_" + randomAlphaNumeric(10) + ".jpg";
    //
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: quality,
    );

    print("File size ==> ${file.lengthSync()}");
    print("Compressed File size ==> ${result?.lengthSync()}");
    return result;
  }

  Future<File> compressImageForUpload(File file) async {
    final path = file.path.toLowerCase();
    if (!path.endsWith('.jpg') &&
        !path.endsWith('.jpeg') &&
        !path.endsWith('.png') &&
        !path.endsWith('.webp') &&
        !path.endsWith('.heic')) {
      return file;
    }

    try {
      final int originalSize = file.lengthSync();
      final int oneMB = 1024 * 1024;
      final int twoMB = 2 * 1024 * 1024;

      // If file is already under 2MB, upload it as is (no quality loss, fits the "up to 2MB only" rule)
      if (originalSize <= twoMB) {
        print("AppService: Image size is already under 2MB ($originalSize bytes). Skipping compression.");
        return file;
      }

      final dir = await path_provider.getTemporaryDirectory();

      // Try compressing with decreasing qualities to find the sweet spot between 1MB and 2MB
      File? bestFile;
      for (int quality in [95, 85, 75, 60, 45]) {
        final targetPath =
            dir.absolute.path + "/optimized_${quality}_" + randomAlphaNumeric(10) + ".jpg";

        var result = await FlutterImageCompress.compressAndGetFile(
          file.absolute.path,
          targetPath,
          quality: quality,
        );

        if (result != null) {
          final compressedFile = File(result.path);
          final int compressedSize = compressedFile.lengthSync();
          print("AppService: Tried quality $quality, got size $compressedSize bytes.");

          // If size is in target range (1MB - 2MB), return immediately
          if (compressedSize >= oneMB && compressedSize <= twoMB) {
            print("AppService: Found optimal quality $quality ($compressedSize bytes).");
            return compressedFile;
          }

          // Track the best candidate that is under 2MB
          if (compressedSize <= twoMB) {
            if (bestFile == null || compressedSize > bestFile.lengthSync()) {
              bestFile = compressedFile;
            }
          } else {
            // Keep the smallest one that is still above 2MB as fallback
            if (bestFile == null || compressedSize < bestFile.lengthSync()) {
              bestFile = compressedFile;
            }
          }
        }
      }

      if (bestFile != null) {
        print("AppService: Selecting best candidate file with size ${bestFile.lengthSync()} bytes.");
        return bestFile;
      }
    } catch (e) {
      print("AppService: Error optimizing image: $e");
    }
    return file;
  }
}
