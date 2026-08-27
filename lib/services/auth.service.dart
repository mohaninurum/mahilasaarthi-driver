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
    final prefs = await LocalStorageService.getPrefs();
    await prefs?.setBool(AppStrings.firstTimeOnApp, false);
  }

  //
  static bool authenticated() {
    final isAuth =
        LocalStorageService.prefs?.getBool(AppStrings.authenticated) ?? false;
    final token =
        LocalStorageService.prefs?.getString(AppStrings.userAuthToken) ?? "";
    return isAuth && token.isNotEmpty;
  }

  /// Prefer this on cold start so prefs are loaded from disk before routing.
  static Future<bool> authenticatedAsync() async {
    final prefs = await LocalStorageService.getPrefs();
    try {
      await prefs?.reload();
    } catch (_) {}
    final isAuth = prefs?.getBool(AppStrings.authenticated) ?? false;
    final token = prefs?.getString(AppStrings.userAuthToken) ?? "";
    if (token.isNotEmpty) {
      _authToken = token;
    }
    return isAuth && token.isNotEmpty;
  }

  static Future<bool> isAuthenticated() async {
    final prefs = await LocalStorageService.getPrefs();
    return await prefs?.setBool(AppStrings.authenticated, true) ?? false;
  }

  // Token
  static String? _authToken;

  static Future<String> getAuthBearerToken() async {
    if (_authToken != null && _authToken!.trim().isNotEmpty) {
      return _authToken!;
    }
    final prefs = await LocalStorageService.getPrefs();
    _authToken = prefs?.getString(AppStrings.userAuthToken) ?? "";
    return _authToken!;
  }

  static Future<bool> setAuthBearerToken(dynamic token) async {
    if (token == null) return false;
    final tokenStr = token.toString().trim();
    if (tokenStr.isEmpty) return false;
    _authToken = tokenStr;
    final prefs = await LocalStorageService.getPrefs();
    return await prefs?.setString(AppStrings.userAuthToken, tokenStr) ?? false;
  }

  //Locale
  static String getLocale() {
    return LocalStorageService.prefs?.getString(AppStrings.appLocale) ?? "en";
  }

  static Future<bool> setLocale(language) async {
    final prefs = await LocalStorageService.getPrefs();
    return await prefs?.setString(AppStrings.appLocale, language) ?? false;
  }

  //
  //
  static User? currentUser;
  static Future<User> getCurrentUser({bool force = false}) async {
    if (currentUser == null || force) {
      final prefs = await LocalStorageService.getPrefs();
      final userStringObject = prefs?.getString(AppStrings.userKey);
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
    if (jsonObject is Map) {
      String? token;
      if (jsonObject["token"] != null && jsonObject["token"] is String) {
        token = jsonObject["token"].toString();
      } else if (jsonObject["access_token"] != null) {
        token = jsonObject["access_token"].toString();
      } else if (jsonObject["token"] is Map && jsonObject["token"]["token"] != null) {
        token = jsonObject["token"]["token"].toString();
      } else if (jsonObject["fb_token"] != null && jsonObject["fb_token"].toString().trim().isNotEmpty) {
        token = jsonObject["fb_token"].toString();
      }
      if (token != null && token.trim().isNotEmpty) {
        await setAuthBearerToken(token);
        await isAuthenticated();
      }

      if (jsonObject["vehicle"] != null) {
        try {
          await saveVehicle(jsonObject["vehicle"]);
        } catch (e) {
          print("saveVehicle from saveUser error ==> $e");
        }
      }
    }
    try {
      final prefs = await LocalStorageService.getPrefs();
      await prefs?.setString(
        AppStrings.userKey,
        json.encode(
          currentUser!.toJson(),
        ),
      );

      //subscribe to firebase topic
      try {
        if (currentUser?.id != null) {
          FirebaseService()
              .firebaseMessaging
              .subscribeToTopic("${currentUser!.id}");
          FirebaseService()
              .firebaseMessaging
              .subscribeToTopic("d_${currentUser!.id}");
        }
        if (currentUser?.role != null && currentUser!.role.isNotEmpty) {
          FirebaseService()
              .firebaseMessaging
              .subscribeToTopic("${currentUser!.role}");
        }
      } catch (fbError) {
        print("Firebase topic subscribe error ==> $fbError");
      }

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
      final prefs = await LocalStorageService.getPrefs();
      final vehicleStringObject = prefs?.getString(AppStrings.driverVehicleKey);
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
      final prefs = await LocalStorageService.getPrefs();
      await prefs?.setString(
        AppStrings.driverVehicleKey,
        json.encode(
          driverVehicle!.toJson(),
        ),
      );

      return driverVehicle!;
    } catch (error) {
      print("saveVehicle error ==> $error");
      throw error;
    }
  }

  ///
  ///
  //
  static Future<void> logout() async {
    _authToken = null;
    try {
      await HttpService().getCacheManager().clearAll();
    } catch (_) {}
    try {
      final prefs = await LocalStorageService.getPrefs();
      // Clear auth session only — do not wipe language/settings/theme.
      await prefs?.remove(AppStrings.authenticated);
      await prefs?.remove(AppStrings.userAuthToken);
      await prefs?.remove(AppStrings.userKey);
      await prefs?.remove(AppStrings.driverVehicleKey);
      await prefs?.setBool(AppStrings.firstTimeOnApp, false);
    } catch (_) {}
    try {
      if (currentUser != null) {
        FirebaseService()
            .firebaseMessaging
            .unsubscribeFromTopic("${currentUser?.id}");
        FirebaseService()
            .firebaseMessaging
            .unsubscribeFromTopic("d_${currentUser?.id}");
        FirebaseService()
            .firebaseMessaging
            .unsubscribeFromTopic("${currentUser?.role}");
      }
    } catch (_) {}
    currentUser = null;
    driverVehicle = null;
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
