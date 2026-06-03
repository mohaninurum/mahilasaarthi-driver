import 'dart:io';
import 'package:firestore_chat/firestore_chat.dart';
import 'package:flutter/material.dart';
import 'package:mahilasaarthi/constants/app_routes.dart';
import 'package:mahilasaarthi/constants/app_strings.dart';
import 'package:mahilasaarthi/constants/app_ui_settings.dart';
import 'package:mahilasaarthi/models/api_response.dart';
import 'package:mahilasaarthi/models/delivery_address.dart';
import 'package:mahilasaarthi/models/order.dart';
import 'package:mahilasaarthi/models/order_stop.dart';
import 'package:mahilasaarthi/requests/order.request.dart';
import 'package:mahilasaarthi/services/app.service.dart';
import 'package:mahilasaarthi/services/chat.service.dart';
import 'package:mahilasaarthi/view_models/base.view_model.dart';
import 'package:mahilasaarthi/views/pages/order/widgets/photo_verification.page.dart';
import 'package:mahilasaarthi/views/pages/order/widgets/scanner_verification_dialog.dart';
import 'package:mahilasaarthi/views/pages/order/widgets/signature_verification.page.dart';
import 'package:mahilasaarthi/views/pages/order/widgets/verification_dialog.dart';
import 'package:mahilasaarthi/widgets/dialogs/collect_cash_info.dialog.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/overlay.service.dart';
import '../services/taxi/taxi_trip_booking_code.service.dart';
import '../views/pages/taxi/widgets/taxi_booking_code_verification_bottomsheet.dart';
import '../widgets/bottomsheets/user_rating.bottomsheet.dart';

class OrderDetailsViewModel extends MyBaseViewModel {
  //
  Order order;
  OrderRequest orderRequest = OrderRequest();
  bool changed = false;

  //
  OrderDetailsViewModel(BuildContext context, this.order) {
    this.viewContext = context;
  }

  initialise() {
    fetchOrderDetails();
  }

  openPaymentPage() {
    launchUrlString(order.paymentLink);
  }

  void callVendor() {
    launchUrlString("tel:${order.vendor?.phone}");
  }

  void callCustomer() {
    launchUrlString("tel:${order.user.phone}");
  }

  void callRecipient() {
    launchUrlString("tel:${order.recipientPhone}");
  }

  chatVendor() {
    //
    Map<String, PeerUser> peers = {
      '${order.driver!.id}': PeerUser(
        id: '${order.driver!.id}',
        name: order.driver!.name,
        image: order.driver!.photo,
      ),
      'vendor_${order.vendor!.id}': PeerUser(
        id: "vendor_${order.vendor!.id}",
        name: order.vendor!.name,
        image: order.vendor!.logo,
      ),
    };
    //
    final chatEntity = ChatEntity(
      onMessageSent: ChatService.sendChatMessage,
      mainUser: peers['${order.driver?.id}']!,
      peers: peers,
      //don't translate this
      path: 'orders/' + order.code + "/driverVendor/chats",
      title: "Chat with vendor".tr(),
      supportMedia: AppUISettings.canDriverChatSupportMedia,
    );
    //
    Navigator.of(viewContext).pushNamed(
      AppRoutes.chatRoute,
      arguments: chatEntity,
    );
  }

  chatCustomer() {
    //
    Map<String, PeerUser> peers = {
      '${order.driver!.id}': PeerUser(
        id: '${order.driver!.id}',
        name: order.driver!.name,
        image: order.driver!.photo,
      ),
      '${order.user.id}': PeerUser(
          id: "${order.user.id}",
          name: order.user.name,
          image: order.user.photo),
    };
    //
    final chatEntity = ChatEntity(
      onMessageSent: ChatService.sendChatMessage,
      mainUser: peers['${order.driver?.id}']!,
      peers: peers,
      //don't translate this
      path: 'orders/' + order.code + "/customerDriver/chats",
      title: "Chat with customer".tr(),
      supportMedia: AppUISettings.canDriverChatSupportMedia,
    );
    //
    Navigator.of(viewContext).pushNamed(
      AppRoutes.chatRoute,
      arguments: chatEntity,
    );
  }

  void fetchOrderDetails() async {
    setBusy(true);
    try {
      order = await orderRequest.getOrderDetails(id: order.id);
      clearErrors();
    } catch (error) {
      print("Error ==> $error");
      setError(error);
      toastError("$error");
    }
    setBusy(false);
  }

  //
  void initiateOrderCompletion() async {
    if (AppStrings.enableProofOfDelivery) {
      //code verification code
      if (!AppStrings.signatureVerify && !AppStrings.verifyOrderByPhoto) {
        showModalBottomSheet(
          context: AppService().navigatorKey.currentContext!,
          isScrollControlled: true,
          builder: (context) {
            return OrderVerificationDialog(
              order: order,
              onValidated: () {
                AppService().navigatorKey.currentContext?.pop();
                processOrderCompletion();
              },
              openQRCodeScanner: () {
                AppService().navigatorKey.currentContext?.pop();
                showQRCodeScanner();
              },
            );
          },
        );
      }
      //verification via photo
      else if (AppStrings.verifyOrderByPhoto) {
        final result = await viewContext.push(
          (context) => PhotoVerificationPage(order: order),
        );
        //
        if (result is Order) {
          order = result;
          notifyListeners();
        } else if (result != null && result) {
          processOrderCompletion();
        }
      }
      //verification via signature
      else {
        final result = await viewContext.push(
          (context) => SignatureVerificationPage(order: order),
        );
        //
        if (result is Order) {
          order = result;
          notifyListeners();
        } else if (result != null && result) {
          processOrderCompletion();
        }
      }
    } else {
      processOrderCompletion();
    }
  }

  //
  showQRCodeScanner() async {
    showDialog(
      context: AppService().navigatorKey.currentContext!,
      builder: (context) {
        return Dialog(
          child: ScanOrderVerificationDialog(
            order: order,
            onValidated: () {
              // AppService().navigatorKey.currentContext.pop();
              processOrderCompletion();
            },
          ),
        );
      },
    );
  }

  void processOrderCompletion() async {
    setBusyForObject(order, true);
    try {
      order = await orderRequest.updateOrder(
        id: order.id,
        status: "delivered",
      );
      //beaware a change as occurred
      changed = true;
      clearErrors();
      //show successful toast
      toastSuccessful("Order completed successfully".tr());

          OverlayService().closeFloatingBubble();

      //show a cash collection dialog if is cash order
      if (order.paymentMethod?.slug == "cash") {
     await showDialog(
          barrierDismissible: false,
          context: viewContext,
          builder: (context) {
            return CollectCashInfoDialog(order);
          },
        );
     await viewContext.push(
           (context) => UserRatingBottomSheet(
         order: order,
         onSubmitted: () {
           viewContext.pop();
         },
       ),
     );
      }
    } catch (error) {
      print("Error ==> $error");
      setErrorForObject(order, error);
      toastError("$error");
    }
    setBusyForObject(order, false);
  }

  //
  void processOrderEnroute() async {
    setBusyForObject(order, true);
    try {
      final result = await showModalBottomSheet(
        context: viewContext,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          return TaxiBookingCodeVerificationBottomSheet(
              order.verificationCode ?? "");
        },
      );

      if (result == null || !(result as bool)) {
        toastError("Please enter pin");
      }else{
        order = await orderRequest.updateOrder(
          id: order.id,
          status: "enroute",
        );

        OverlayService().showFloatingBubble();
        //beaware a change as occurred
        changed = true;
        clearErrors();
      }

    } catch (error) {
      print("Error ==> $error");
      setErrorForObject(order, error);
      viewContext.showToast(
        msg: "$error",
        bgColor: Colors.red,
      );
    }
    setBusyForObject(order, false);
  }

  onBackPressed() {
    //
    AppService().navigatorKey.currentContext?.pop(changed ? order : null);
  }

  //
  routeToLocation(DeliveryAddress deliveryAddress) async {
    try {
      final coords = Coords(
        deliveryAddress.latitude!,
        deliveryAddress.longitude!,
      );
      final title = deliveryAddress.name;
      final availableMaps = await MapLauncher.installedMaps;

      showModalBottomSheet(
        context: AppService().navigatorKey.currentContext!,
        builder: (BuildContext context) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Container(
                child: Wrap(
                  children: <Widget>[
                    for (var map in availableMaps)
                      ListTile(
                        onTap: () => map.showMarker(
                          coords: coords,
                          title: title ?? "",
                        ),
                        title: Text(map.mapName),
                        leading: SvgPicture.asset(
                          map.icon,
                          height: 30.0,
                          width: 30.0,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }

  //
  verifyStop(OrderStop stop) async {
    //code verification code
    if (AppStrings.verifyOrderByPhoto) {
      await viewContext.push(
        (context) => PhotoVerificationPage(
          order: order,
          onsubmit: (photo) {
            processOrderStopVerification(stop, photo);
            viewContext.pop();
          },
        ),
      );
    }
    //verification via signature
    else {
      await viewContext.push(
        (context) => SignatureVerificationPage(
          order: order,
          onsubmit: (photo) {
            processOrderStopVerification(stop, photo);
            viewContext.pop();
          },
        ),
      );
    }
  }

  void processOrderStopVerification(OrderStop stop, File photo) async {
    setBusyForObject(stop, true);
    try {
      ApiResponse apiResponse = await orderRequest.verifyOrderStopRequest(
        id: stop.id,
        signature: photo,
      );
      clearErrors();
      //
      order = Order.fromJson(apiResponse.body["order"]);
      notifyListeners();
      toastSuccessful(apiResponse.body["message"]);
    } catch (error) {
      print("Error ==> $error");
      toastError("$error");
    }
    setBusyForObject(stop, false);
  }
}
