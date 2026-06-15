import 'dart:async';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mahilasaarthi/models/new_order.dart';
import 'package:mahilasaarthi/requests/order.request.dart';
import 'package:mahilasaarthi/services/app.service.dart';
import 'package:mahilasaarthi/view_models/base.view_model.dart';
import 'package:velocity_x/velocity_x.dart';

class NewOrderAlertViewModel extends MyBaseViewModel {
  //
  OrderRequest orderRequest = OrderRequest();
  NewOrder newOrder;
  bool canDismiss = false;
  CountDownController countDownTimerController = CountDownController();
  NewOrderAlertViewModel(this.newOrder, BuildContext context) {
    this.viewContext = context;
  }

  StreamSubscription<DocumentSnapshot>? orderAlertSubscription;

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
    AppService().stopNotificationSound();
    if (viewContext.mounted && !canDismiss) {
      canDismiss = true;
      Navigator.pop(viewContext);
    }
  }

  @override
  void dispose() {
    orderAlertSubscription?.cancel();
    super.dispose();
  }

  void processOrderAcceptance() async {
    setBusy(true);
    try {
      await Future.wait([
        orderRequest.acceptNewOrder(newOrder.id!),
        // Wait for the swipe animation to finish before disposing
        Future.delayed(const Duration(milliseconds: 500)),
      ]);
      AppService().stopNotificationSound();

      //
      if (viewContext.mounted) {
        Navigator.pop(viewContext, true);
      }
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

      //
      canDismiss = true;
    }
    setBusy(false);
    //
    if (canDismiss) {
      AppService().stopNotificationSound();
      if (viewContext.mounted) {
        Navigator.pop(viewContext);
      }
    }
  }

  void countDownCompleted(bool started) {
    print('Countdown Ended');
    if (started) {
      if (isBusy) {
        canDismiss = true;
      } else {
        AppService().stopNotificationSound();
        if (viewContext.mounted) {
          Navigator.pop(viewContext);
        }
      }
    }
  }
}



