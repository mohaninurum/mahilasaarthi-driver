import 'dart:convert';

import 'package:mahilasaarthi/constants/app_strings.dart';
import 'package:mahilasaarthi/models/user.dart';
import 'package:mahilasaarthi/models/vehicle.dart';
import 'package:mahilasaarthi/services/firebase.service.dart';
import 'package:mahilasaarthi/services/location.service.dart';

import 'http.service.dart';
import 'local_storage.service.dart';

class AuthServices {
  //
  static bool firstTimeOnApp() {
    return LocalStorageService.prefs?.getBool(AppStrings.firstTimeOnApp) ??
        true;
  }

  static firstTimeCompleted() async {
    await LocalStorageService.prefs?.setBool(AppStrings.firstTimeOnApp, false);
  }

  //
  static bool authenticated() {
    return LocalStorageService.prefs?.getBool(AppStrings.authenticated) ??
        false;
  }

  static Future<bool> isAuthenticated() async {
    return await LocalStorageService.prefs?.setBool(AppStrings.authenticated, true) ?? false;
  }

  // Token
  static Future<String> getAuthBearerToken() async {
    return LocalStorageService.prefs?.getString(AppStrings.userAuthToken) ?? "";
  }

  static Future<bool> setAuthBearerToken(token) async {
    return await LocalStorageService.prefs
        ?.setString(AppStrings.userAuthToken, token) ?? false;
  }

  //Locale
  static String getLocale() {
    return LocalStorageService.prefs?.getString(AppStrings.appLocale) ?? "en";
  }

  static Future<bool> setLocale(language) async {
    return await LocalStorageService.prefs?.setString(AppStrings.appLocale, language) ?? false;
  }

  //
  //
  static User? currentUser;
  static Future<User> getCurrentUser({bool force = false}) async {
    if (currentUser == null || force) {
      final userStringObject =
          LocalStorageService.prefs?.getString(AppStrings.userKey);
      final userObject = json.decode(userStringObject ?? "{}");
      currentUser = User.fromJson(userObject);
    }
    return currentUser!;
  }

  ///
  ///
  ///
  static Future<User> saveUser(dynamic jsonObject) async {
    currentUser = User.fromJson(jsonObject);
    if (jsonObject is Map && jsonObject["vehicle"] != null) {
      try {
        await saveVehicle(jsonObject["vehicle"]);
      } catch (e) {
        print("saveVehicle from saveUser error ==> $e");
      }
    }
    try {
      await LocalStorageService.prefs?.setString(
        AppStrings.userKey,
        json.encode(
          currentUser!.toJson(),
        ),
      );

      //subscribe to firebase topic
      FirebaseService().firebaseMessaging.subscribeToTopic("${currentUser!.id}");
      FirebaseService()
          .firebaseMessaging
          .subscribeToTopic("d_${currentUser!.id}");
      FirebaseService()
          .firebaseMessaging
          .subscribeToTopic("${currentUser!.role}");

      return currentUser!;
    } catch (error) {
      print("saveUser error ==> $error");
      throw error;
    }
  }

  //VEHICLE DETAILS
  //
  static Vehicle? driverVehicle;
  static Future<Vehicle?> getDriverVehicle({bool force = false}) async {
    if (driverVehicle == null || force) {
      final vehicleStringObject = LocalStorageService.prefs
          ?.getString(AppStrings.driverVehicleKey);
      //
      if (vehicleStringObject == null || vehicleStringObject.isEmpty) {
        driverVehicle = null;
      } else {
        final vehicleObject = json.decode(vehicleStringObject);
        driverVehicle = Vehicle.fromJson(vehicleObject);
      }
    }
    return driverVehicle;
  }

  ///
  ///
  ///
  static Future<Vehicle> saveVehicle(dynamic jsonObject) async {
    driverVehicle = Vehicle.fromJson(jsonObject);
    try {
      //
      await LocalStorageService.prefs?.setString(
        AppStrings.driverVehicleKey,
        json.encode(
          driverVehicle!.toJson(),
        ),
      );
      //sync vehicle data with free,is_online status with firebase

      return driverVehicle!;
    } catch (error) {
      print("saveVehicle error ==> $error");
      throw error;
    }
  }

  ///
  ///
  //
  static logout() async {
    try {
      await HttpService().getCacheManager().clearAll();
    } catch (_) {}
    try {
      await LocalStorageService.prefs?.clear();
      await LocalStorageService.prefs?.setBool(AppStrings.firstTimeOnApp, false);
    } catch (_) {}
    try {
      FirebaseService()
          .firebaseMessaging
          .unsubscribeFromTopic("${currentUser?.id}");
      FirebaseService()
          .firebaseMessaging
          .unsubscribeFromTopic("d_${currentUser?.id}");
      FirebaseService()
          .firebaseMessaging
          .unsubscribeFromTopic("${currentUser?.role}");
    } catch (_) {}
  }

  //
  static Future<void> syncDriverData(Map<String, dynamic> body) async {
    try {
      //
      final driver = User.fromJson(body["user"]);
      final assignedOrders = int.tryParse(
            body["user"]["assigned_orders"].toString(),
          ) ??
          0;
      final vehicle = Vehicle.fromJson(body["vehicle"]);
      //sync vehicle data with free,is_online status with firebase
      // LocationService().firebaseFireStore.
      final driverDoc = await LocationService()
          .firebaseFireStore
          .collection("drivers")
          .doc(driver.id.toString())
          .get();

      //
      final docRef = driverDoc.reference;

      if (driverDoc.data() == null) {
        docRef.set(
          {
            "id": driver.id,
            "free": assignedOrders <= 0 ? 1 : 0,
            "online": driver.isOnline ? 1 : 0,
            "vehicle_type_id": vehicle.vehicleType.id,
          },
        );
      } else {
        docRef.update(
          {
            "id": driver.id,
            "free": assignedOrders <= 0 ? 1 : 0,
            "online": driver.isOnline ? 1 : 0,
            "vehicle_type_id": vehicle.vehicleType.id,
          },
        );
      }
    } catch (error) {
      print("error ==> $error");
    }
  }
}
