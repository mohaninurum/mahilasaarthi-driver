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
  bool canDismiss = false;
  CountDownController countDownTimerController = CountDownController();
  NewTaxiOrderAlertViewModel(this.newOrder, BuildContext context) {
    this.viewContext = context;
  }

  initialise() {
    //
    AppService().playNotificationSound();
    //
    countDownTimerController.start();
  }

  void processOrderAcceptance() async {
    setBusy(true);
    try {
      final order = await orderRequest.acceptNewOrder(
        newOrder.id,
        status: "preparing",
      );
      
      // Remove from firebase so other drivers don't see it or we don't get it again
      if (newOrder.docRef != null) {
        try {
          await FirebaseFirestore.instance.doc(newOrder.docRef!).delete();
        } catch (e) {
          print("Error deleting firebase doc: $e");
        }
      }

      AppService().assetsAudioPlayer.stop();
      //
      viewContext.pop(order);
      // return;
    } catch (error) {
      viewContext.showToast(
        msg: "$error",
        bgColor: Colors.red,
        textColor: Colors.white,
        textSize: 20,
      );

      //
      canDismiss = true;
    }
    setBusy(false);
    //
    if (canDismiss) {
      AppService().assetsAudioPlayer.stop();
      viewContext.pop();
    }
  }

  void countDownCompleted(bool started) async {
    print('Countdown Ended');
    if (started) {
      if (isBusy) {
        canDismiss = true;
      } else {
        AppService().assetsAudioPlayer.stop();
        viewContext.pop();
        //STOP NOTIFICATION SOUND
        AppService().stopNotificationSound();
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
