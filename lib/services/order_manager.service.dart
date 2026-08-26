import 'dart:async';
import 'dart:isolate';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mahilasaarthi/constants/app_strings.dart';
import 'package:mahilasaarthi/models/new_order.dart';
import 'package:mahilasaarthi/models/new_taxi_order.dart';
import 'package:mahilasaarthi/services/auth.service.dart';
import 'package:mahilasaarthi/services/background_order.service.dart';
import 'package:mahilasaarthi/services/firebase_order_handler.service.dart';
import 'package:mahilasaarthi/services/local_storage.service.dart';
import 'package:mahilasaarthi/services/taxi_background_order.service.dart';
import 'package:schedulers/schedulers.dart';
import 'package:singleton/singleton.dart';

import 'app.service.dart';

import 'package:mahilasaarthi/services/order_assignment.service.dart';

class OrderManagerService {
  //
  /// Factory method that reuse same instance automatically
  factory OrderManagerService() =>
      Singleton.lazy(() => OrderManagerService._());

  /// Private constructor
  OrderManagerService._() {}

  //
  FirebaseFirestore firebaseFireStore = FirebaseFirestore.instance;
  StreamSubscription<DocumentSnapshot>? newOrderDocsRefSubscription;
  StreamSubscription<DocumentSnapshot>? driverNewOrderDocsRefSubscription;
  StreamSubscription<dynamic>? firebaseOrderHandlerServiceSubscription;
  IntervalScheduler? driverNewOrderDataScheduler;
  final alertDriverNewOrderAlert = "can_notify_driver";

  //listen to driver new order firebase node
  startListener() async {
    print(
        "OrderManagerService: startListener called. MatchingNewSystem: ${AppStrings.driverMatchingNewSystem}");
    //for new driver matching system
    if (AppStrings.driverMatchingNewSystem) {
      final vehicle = await AuthServices.getDriverVehicle();
      String firebaseCollection = "searchingOrders";
      if (vehicle != null) {
        firebaseCollection = "searchingTaxiOrders";
      }
      print(
          "OrderManagerService: Starting NEW matching system listener on collection: $firebaseCollection");

      firebaseOrderHandlerServiceSubscription?.cancel();
      firebaseOrderHandlerServiceSubscription =
          firebaseFireStore.collection(firebaseCollection).snapshots().listen(
        (snapshot) async {
          print(
              "OrderManagerService: [NEW matching] received snapshot with ${snapshot.docs.length} docs");
          for (var doc in snapshot.docs) {
            final newOrderAlertData = doc.data();
            final docRef = doc.reference.path;

            print(
                "OrderManagerService: [NEW matching] Processing doc: $docRef");

            bool canHandleOrder =
                await OrderAssignmentService.driverCanHandleOrder(
              newOrderAlertData,
              docRef,
            );
            print(
                "OrderManagerService: [NEW matching] driverCanHandleOrder result: $canHandleOrder");

            if (canHandleOrder) {
              final hasVehicle =
                  newOrderAlertData.containsKey("vehicle_type_id");
              //if is taxi
              if (hasVehicle) {
                NewTaxiOrder nTOrder = NewTaxiOrder.fromJson(newOrderAlertData);
                nTOrder.docRef = docRef;
                print(
                    "OrderManagerService: [NEW matching] processing taxi order: ${nTOrder.id}");
                TaxiBackgroundOrderService().processOrderNotification(nTOrder);
              } else {
                NewOrder newOrder = NewOrder.fromJson(newOrderAlertData);
                newOrder.docRef = docRef;
                print(
                    "OrderManagerService: [NEW matching] processing regular order: ${newOrder.id}");
                BackgroundOrderService().processOrderNotification(newOrder);
              }

              //auto allow the
              await Future.delayed(Duration(seconds: AppStrings.alertDuration));
              //schedule a data delete functon/action
              scheduleClearDriverNewOrderListener();
            }
          }
        },
        onError: (error) {
          print(
              "OrderManagerService: [NEW matching] Error listening to $firebaseCollection: $error");
        },
      );
    }
    //old driver matching from firebase notification
    else {
      final driverId = (await AuthServices.getCurrentUser()).id.toString();
      final newOrderDocsRef =
          firebaseFireStore.collection("driver_new_order").doc(driverId);
      print(
          "OrderManagerService: Starting OLD matching system listener on doc: driver_new_order/$driverId");
      //close any previous listener
      newOrderDocsRefSubscription?.cancel();
      //start the data listener
      newOrderDocsRefSubscription = newOrderDocsRef.snapshots().listen(
        (docSnapshot) async {
          //
          final newOrderAlertData = docSnapshot.data();
          print("ORDER MANAGER SERVCIE==> ${newOrderAlertData}");
          if (newOrderAlertData == null) {
            print(
                "OrderManagerService: [OLD matching] received null/empty data for driver: $driverId");
            return;
          }

          print("OrderManagerService: [OLD matching] received update");
          print("New order metadata ===> ${docSnapshot.metadata}");
          if (!docSnapshot.exists) {
            print(
                "OrderManagerService: [OLD matching] document does not exist anymore");
            return;
          }
          //
          // if (canShowAlert()) {
          final hasVehicle = newOrderAlertData.containsKey("vehicle_type_id");
          //if is taxi
          if (hasVehicle) {
            final newTaxiOrder = NewTaxiOrder.fromJson(newOrderAlertData);
            newTaxiOrder.docRef = newOrderDocsRef.path;
            print(
                "OrderManagerService: [OLD matching] processing taxi order: ${newTaxiOrder.id}");
            TaxiBackgroundOrderService().processOrderNotification(newTaxiOrder);
          } else {
            final newOrder = NewOrder.fromJson(newOrderAlertData);
            newOrder.docRef = newOrderDocsRef.path;
            print(
                "OrderManagerService: [OLD matching] processing regular order: ${newOrder.id}");
            BackgroundOrderService().processOrderNotification(newOrder);
          }

          //auto allow the
          await Future.delayed(Duration(seconds: AppStrings.alertDuration));
          //schedule a data delete functon/action
          scheduleClearDriverNewOrderListener();
        },
        onError: (error) {
          print(
              "OrderManagerService: [OLD matching] Error listening to doc: $error");
        },
      );
    }
  }

  //stop
  bool stopListener() {
    newOrderDocsRefSubscription?.cancel();
    // driverNewOrderDocsRefSubscription?.cancel();
    //
    firebaseOrderHandlerServiceSubscription?.cancel();
    firebaseOrderHandlerServiceSubscription = null;
    FirebaseOrderHandlerService.port.close();
    FirebaseOrderHandlerService.port = ReceivePort();
    return true;
  }

  //This is not monitor if the driver node onf ifrestore has the online/free fields
  //so it can be used in connecting order to drivers
  monitorOnlineStatusListener({
    AppService? appService,
  }) async {
    try {
      final currentUser = await AuthServices.getCurrentUser();
      if (currentUser == null) return;
      final driverId = currentUser.id.toString();
      final driverDoc =
          await firebaseFireStore.collection("drivers").doc(driverId).get();

      bool shouldGoOffline = false;
      //if exists
      if (driverDoc.exists) {
        //
        if (driverDoc.data() != null &&
            (!driverDoc.data()!.containsKey("online") ||
                !driverDoc.data()!.containsKey("free"))) {
          //forcefully update doc value
          await driverDoc.reference.update(
            {
              "online": driverDoc.data()!.containsKey("online")
                  ? driverDoc.get("online")
                  : 1,
              "free": driverDoc.data()!.containsKey("free")
                  ? driverDoc.get("free")
                  : 1,
            },
          );
        }
      } else {
        shouldGoOffline = true;
        await driverDoc.reference.set(
          {
            "online": AppService().driverIsOnline ? 1 : 0,
            "free": 1,
          },
        );
      }
      //set the status to the backend
      if (shouldGoOffline) {
        final prefs = await LocalStorageService.getPrefs();
        await prefs?.setBool(AppStrings.onlineOnApp, false);
        if (appService != null) {
          appService.driverIsOnline = false;
        } else {
          AppService().driverIsOnline = false;
        }
      }
    } catch (error) {
      print("monitorOnlineStatusListener error: $error");
    }
  }

  //
  void scheduleClearDriverNewOrderListener() {
    driverNewOrderDataScheduler?.dispose();
    driverNewOrderDataScheduler = null;

    if (driverNewOrderDataScheduler == null) {
      driverNewOrderDataScheduler = IntervalScheduler(
        delay: Duration(seconds: AppStrings.alertDuration),
      );
    }
    //
    // driverNewOrderDataScheduler?.run(
    //   () => clearDriverNewOrderListener(),
    // );
  }

  //This is delete exipred driver_new_order data
  void clearDriverNewOrderListener() async {
    try {
      final currentUser = await AuthServices.getCurrentUser();
      if (currentUser == null) return;
      final driverId = currentUser.id.toString();
      final driverNewOrderData = await firebaseFireStore
          .collection("driver_new_order")
          .doc(driverId)
          .get();

      //
      if (driverNewOrderData.exists) {
        await firebaseFireStore
            .collection("driver_new_order")
            .doc(driverId)
            .delete();
      }
    } catch (error) {
      print("clearDriverNewOrderListener error: $error");
    }
  }
}
