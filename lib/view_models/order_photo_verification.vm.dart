import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mahilasaarthi/models/api_response.dart';
import 'package:mahilasaarthi/models/order.dart';
import 'package:mahilasaarthi/requests/order.request.dart';
import 'package:mahilasaarthi/view_models/base.view_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderPhotoVerificationViewModel extends MyBaseViewModel {
  //
  Order order;
  OrderRequest orderRequest = OrderRequest();
  //
  final picker = ImagePicker();
  File? newPhoto;
  //
  OrderPhotoVerificationViewModel(BuildContext context, this.order) {
    this.viewContext = context;
  }

  submitPhotoProof() async {
    setBusy(true);
    try {
      ApiResponse apiResponse = await orderRequest.updateOrderWithSignature(
        id: order.id,
        status: "delivered",
        signature: newPhoto,
        typeOfProof: "delivery_photo",
      );
      clearErrors();
      //
      order = Order.fromJson(apiResponse.body["order"]);
      toastSuccessful(apiResponse.body["message"]);
      Navigator.pop(viewContext, order);
    } catch (error) {
      print("Error ==> $error");
      toastError("$error");
    }
    setBusy(false);
  }

  void takeDeliveryPhoto() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      newPhoto = File(pickedFile.path);
    } else {
      newPhoto = null;
    }

    notifyListeners();
  }
}



