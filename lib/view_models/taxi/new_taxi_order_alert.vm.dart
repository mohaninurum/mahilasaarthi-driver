import 'dart:async';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mahilasaarthi/models/new_taxi_order.dart';
import 'package:mahilasaarthi/requests/order.request.dart';
import 'package:mahilasaarthi/requests/taxi.request.dart';
import 'package:mahilasaarthi/services/app.service.dart';
import 'package:mahilasaarthi/services/auth.service.dart';
import 'package:mahilasaarthi/view_models/base.view_model.dart';
import 'package:velocity_x/velocity_x.dart';

class NewTaxiOrderAlertViewModel extends MyBaseViewModel {
  //
  OrderRequest orderRequest = OrderRequest();
  TaxiRequest taxiRequest = TaxiRequest();
  NewTaxiOrder newOrder;
  CountDownController countDownTimerController = CountDownController();
  NewTaxiOrderAlertViewModel(this.newOrder, BuildContext context) {
    this.viewContext = context;
  }

  StreamSubscription<DocumentSnapshot>? orderAlertSubscription;
  bool _isPopped = false;

  void _popContext([dynamic result]) {
    if (!_isPopped) {
      _isPopped = true;
      if (viewContext.mounted) {
        Navigator.pop(viewContext, result);
      }
    }
  }

  initialise() {
    //
    AppService().playNotificationSound();
    //
    countDownTimerController.start();

    // Listen to firestore to auto close if customer cancels
    if (newOrder.docRef != null) {
      orderAlertSubscription = FirebaseFirestore.instance.doc(newOrder.docRef!).snapshots().listen((snapshot) {
        if (!snapshot.exists) {
          _closeSilently();
        } else {
          final data = snapshot.data();
          if (data != null && (data as Map<String, dynamic>)['status'] == 'cancelled') {
            _closeSilently();
          }
        }
      });
    }
  }

  void _closeSilently() {
    if (isBusy) {
      // Do not close silently if we are currently accepting the order.
      // The backend or our own app deleting the document will trigger this listener,
      // and we must not interrupt the acceptance process.
      return;
    }
    AppService().stopNotificationSound();
    _popContext();
  }

  @override
  void dispose() {
    orderAlertSubscription?.cancel();
    super.dispose();
  }

  void processOrderAcceptance() async {
    setBusy(true);
    try {
      final results = await Future.wait([
        orderRequest.acceptNewOrder(
          newOrder.id,
          status: "preparing",
        ),
        // Wait for the swipe animation to finish before disposing
        Future.delayed(const Duration(milliseconds: 500)),
      ]);
      final order = results[0];
      
      orderAlertSubscription?.cancel();
      // Remove from firebase so other drivers don't see it or we don't get it again
      if (newOrder.docRef != null) {
        try {
          await FirebaseFirestore.instance.doc(newOrder.docRef!).delete();
        } catch (e) {
          print("Error deleting firebase doc: $e");
        }
      }

      AppService().stopNotificationSound();
      setBusy(false);
      _popContext(order);
      return;
    } catch (error) {
      if (viewContext.mounted) {
        viewContext.showToast(
          msg: "$error",
          bgColor: Colors.red,
          textColor: Colors.white,
          textSize: 20,
        );
      }
    }
    setBusy(false);
    AppService().stopNotificationSound();
    _popContext();
  }

  void countDownCompleted(bool started) async {
    print('Countdown Ended');
    if (started) {
      if (isBusy) {
        // Do nothing, processOrderAcceptance is running and will handle pop
      } else {
        AppService().stopNotificationSound();
        _popContext();
        //silently reject order assignment
        setBusy(true);
        try {
          //
          await taxiRequest.rejectAssignment(
            newOrder.id,
            AuthServices.currentUser!.id,
          );
        } catch (error) {
          print("error ignoring trip assignment ==> $error");
        }
        setBusy(false);
      }
    }
  }
}



