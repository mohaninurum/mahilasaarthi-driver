import 'package:firestore_chat/firestore_chat.dart';
import 'package:flutter/material.dart';
import 'package:mahilasaarthi/constants/app_routes.dart';
import 'package:mahilasaarthi/constants/app_ui_settings.dart';
import 'package:mahilasaarthi/models/new_taxi_order.dart';
import 'package:mahilasaarthi/models/order.dart';
import 'package:mahilasaarthi/models/user.dart';
import 'package:mahilasaarthi/requests/auth.request.dart';
import 'package:mahilasaarthi/requests/order.request.dart';
import 'package:mahilasaarthi/requests/taxi.request.dart';
import 'package:mahilasaarthi/services/app.service.dart';
import 'package:mahilasaarthi/services/chat.service.dart';
import 'package:mahilasaarthi/services/order_manager.service.dart';
import 'package:mahilasaarthi/services/taxi/new_taxi_booking.service.dart';
import 'package:mahilasaarthi/services/taxi/ongoing_taxi_booking.service.dart';
import 'package:mahilasaarthi/services/taxi/taxi_google_map_manager.service.dart';
import 'package:mahilasaarthi/services/taxi/taxi_location.service.dart';
import 'package:mahilasaarthi/view_models/base.view_model.dart';
import 'package:mahilasaarthi/widgets/bottomsheets/user_rating.bottomsheet.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:rxdart/rxdart.dart';
import 'package:velocity_x/velocity_x.dart';

class TaxiViewModel extends MyBaseViewModel {
  TaxiViewModel(BuildContext context) {
    this.viewContext = context;
  }

  OrderRequest orderRequest = OrderRequest();
  TaxiRequest taxiRequest = TaxiRequest();
  //services
  late TaxiLocationService taxiLocationService;
  late NewTaxiBookingService newTaxiBookingService;
  late OnGoingTaxiBookingService onGoingTaxiBookingService;
  late TaxiGoogleMapManagerService taxiGoogleMapManagerService;
  AppService appService = AppService();
  BehaviorSubject<Widget?> uiStream = BehaviorSubject<Widget?>();
  //
  Order? onGoingOrderTrip;
  Order? finishedOrderTrip;
  NewTaxiOrder? newOrder;

  @override
  void initialise() async {
    super.initialise();
    print("TaxiViewModel: Initialising...");
    //
    taxiGoogleMapManagerService = TaxiGoogleMapManagerService(this);
    await taxiGoogleMapManagerService.setSourceAndDestinationIcons();
    newTaxiBookingService = NewTaxiBookingService(this);
    onGoingTaxiBookingService = OnGoingTaxiBookingService(this);
    taxiLocationService = TaxiLocationService(this);

    //get the driver online status from the server api
    print("TaxiViewModel: Calling getOnlineDriverState...");
    await getOnlineDriverState();
    print(
        "TaxiViewModel: getOnlineDriverState complete. Online: ${appService.driverIsOnline}");

    // Load the status of driver free/online from firebase
    print("TaxiViewModel: Calling monitorOnlineStatusListener...");
    await OrderManagerService().monitorOnlineStatusListener(
      appService: appService,
    );
    print("TaxiViewModel: monitorOnlineStatusListener active.");

    //update the new taxi booking service listener
    print(
        "TaxiViewModel: calling toggleVisibility with ${appService.driverIsOnline}...");
    await newTaxiBookingService.toggleVisibility(appService.driverIsOnline);

    //now check for any on going trip
    print("TaxiViewModel: checking for ongoing trip...");
    await checkForOnGoingTrip();
    print("TaxiViewModel: checkForOnGoingTrip complete.");
  }

  checkForOnGoingTrip() async {
    onGoingOrderTrip = await onGoingTaxiBookingService.getOnGoingTrip();
    onGoingTaxiBookingService.loadTripUIByOrderStatus();
  }

//fetch driver online offline
  getOnlineDriverState() async {
    setBusyForObject(appService.driverIsOnline, true);
    try {
      User driverData = await AuthRequest().getMyDetails();
      appService.driverIsOnline = driverData.isOnline;
      //if is online start listening to new trip
      if (appService.driverIsOnline) {
        newTaxiBookingService.startNewOrderListener();
      }
    } catch (error) {
      print("error getting driver data ==> $error");
    }
    setBusyForObject(appService.driverIsOnline, false);
  }

  //update driver state
  Future<bool> syncDriverNewState() async {
    bool updated = false;
    setBusyForObject(appService.driverIsOnline, true);
    try {
      await AuthRequest().updateProfile(
        isOnline: appService.driverIsOnline,
      );
      print(" driver data ==> ${appService.driverIsOnline}");

      updated = true;
    } catch (error) {
      print("error getting driver data ==> $error");
      appService.driverIsOnline = !appService.driverIsOnline;
    }
    setBusyForObject(appService.driverIsOnline, false);
    return updated;
  }

  //
  chatCustomer() {
    //
    Map<String, PeerUser> peers = {
      '${onGoingOrderTrip!.driver!.id}': PeerUser(
        id: '${onGoingOrderTrip!.driver!.id}',
        name: onGoingOrderTrip!.driver!.name,
        image: onGoingOrderTrip!.driver!.photo,
      ),
      '${onGoingOrderTrip!.user.id}': PeerUser(
          id: "${onGoingOrderTrip!.user.id}",
          name: onGoingOrderTrip!.user.name,
          image: onGoingOrderTrip!.user.photo),
    };
    //
    final chatEntity = ChatEntity(
      onMessageSent: ChatService.sendChatMessage,
      mainUser: peers['${onGoingOrderTrip?.driver?.id}']!,
      peers: peers,
      //don't translate this
      path: 'orders/' + onGoingOrderTrip!.code + "/customerDriver/chats",
      title: "Chat with customer".tr(),
      supportMedia: AppUISettings.canDriverChatSupportMedia,
    );
    //
    Navigator.of(viewContext).pushNamed(
      AppRoutes.chatRoute,
      arguments: chatEntity,
    );
  }

  //rate trip
  void showUserRating(Order finishedTrip) async {
    //
    finishedTrip =
        finishedOrderTrip != null ? finishedOrderTrip! : finishedTrip;
    //
    await viewContext.push(
      (context) => UserRatingBottomSheet(
        order: finishedTrip,
        onSubmitted: () {
          viewContext.pop();
          resetOrderListener();
        },
      ),
    );

    //
    resetOrderListener();
  }

  resetOrderListener() {
    //
    onGoingOrderTrip = null;
    notifyListeners();
    newTaxiBookingService.startNewOrderListener();
    taxiLocationService.zoomToLocation();
    taxiGoogleMapManagerService.updateGoogleMapPadding(20);
  }
}
