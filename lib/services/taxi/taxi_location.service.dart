import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mahilasaarthi/constants/app_strings.dart';
import 'package:mahilasaarthi/services/app_permission_handler.service.dart';
import 'package:mahilasaarthi/services/location.service.dart';
import 'package:mahilasaarthi/view_models/taxi/taxi.vm.dart';
import 'package:georange/georange.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supercharged/supercharged.dart';
import 'package:rxdart/rxdart.dart';

class TaxiLocationService {
  //
  TaxiViewModel? taxiViewModel;
  StreamSubscription? myLocationListener;
  BehaviorSubject<int> etaStream = BehaviorSubject<int>();
  Timer? _timer;
  Timer? _etaTimer;
  Marker? driverMarker;

  //
  TaxiLocationService(this.taxiViewModel) {
    //
    startLocationListener();
  }

  dispose() {
    myLocationListener?.cancel();
    _timer?.cancel();
    _etaTimer?.cancel();
  }

  //
  startLocationListener() async {
    bool isGranted = await AppPermissionHandlerService().isLocationGranted();
    if (!isGranted) {
      taxiViewModel?.taxiGoogleMapManagerService.canShowMap = false;
      taxiViewModel?.notifyListeners();
      requestLocationPermissionForGoogleMap();
      return;
    }

    taxiViewModel?.taxiGoogleMapManagerService.canShowMap = true;
    taxiViewModel?.notifyListeners();

    // Prepare location service and sync initial position
    await LocationService().prepareLocationListener();
    if (LocationService().currentLocation?.latitude != null &&
        LocationService().currentLocation?.longitude != null) {
      final lat = LocationService().currentLocation!.latitude!;
      final lng = LocationService().currentLocation!.longitude!;
      updateDriverMarker(LatLng(lat, lng), 0.0);
      zoomToLocation();
    }

    startListeningToDriverLocation();
  }

  void updateDriverMarker(LatLng pos, double heading) {
    if (taxiViewModel == null) return;
    driverMarker = Marker(
      markerId: taxiViewModel!.taxiGoogleMapManagerService.driverMarkerId,
      position: pos,
      rotation: heading,
      icon: taxiViewModel?.taxiGoogleMapManagerService.driverIcon ??
          BitmapDescriptor.defaultMarker,
      anchor: Offset(0.5, 0.5),
    );

    taxiViewModel!.taxiGoogleMapManagerService.gMapMarkers.removeWhere(
      (marker) =>
          marker.markerId ==
          taxiViewModel!.taxiGoogleMapManagerService.driverMarkerId,
    );
    taxiViewModel!.taxiGoogleMapManagerService.gMapMarkers.add(driverMarker!);
    taxiViewModel?.notifyListeners();
  }

  //
  startListeningToDriverLocation() async {
    //
    myLocationListener?.cancel();
    //
    myLocationListener = LocationService().getNewLocationStream().listen(
      (event) {
        updateDriverMarker(LatLng(event.latitude, event.longitude), event.heading);
        zoomToLocation();
      },
    );
  }

  zoomToLocation() async {
    //
    try {
      LatLng? targetPos = driverMarker?.position;
      if (targetPos == null && LocationService().currentLocation?.latitude != null) {
        targetPos = LatLng(
          LocationService().currentLocation!.latitude!,
          LocationService().currentLocation!.longitude!,
        );
      }
      if (targetPos != null) {
        taxiViewModel!.taxiGoogleMapManagerService.googleMapController
            ?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: targetPos,
              zoom: 16,
            ),
          ),
        );
      }
    } catch (error) {
      print("Error animating camera: $error");
    }

    //
    pauseAutoZoomToLocation();
  }

  pauseAutoZoomToLocation() async {
    _timer?.cancel();
  }

  handleAutoZoomToLocation() async {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      zoomToLocation();
    });
  }

  bool isRequestingPermission = false;

  void requestLocationPermissionForGoogleMap() async {
    if (isRequestingPermission) return;
    isRequestingPermission = true;
    try {
      await AppPermissionHandlerService().handleForegroundLocationOnlyRequest();
      startLocationListener();
    } finally {
      isRequestingPermission = false;
    }
  }

  //ETA section
  startETAListener(LatLng latLng) async {
    _etaTimer?.cancel();
    _etaTimer = Timer.periodic(Duration(seconds: 10), (Timer timer) {
      calculatedETAToLocation(latLng);
    });
  }

  calculatedETAToLocation(LatLng latLng) {
    if (driverMarker == null) return;
    //
    final startPoint = Point(
      latitude: driverMarker!.position.latitude,
      longitude: driverMarker!.position.longitude,
    );
    final endPoint = Point(
      latitude: latLng.latitude,
      longitude: latLng.longitude,
    );
    final distance = GeoRange().distance(startPoint, endPoint);
    final taxiEnv = AppStrings.env("taxi");
    final drivingSpeed = (taxiEnv is Map ? taxiEnv["drivingSpeed"] : null) ?? "50";
    double speed = double.tryParse(drivingSpeed.toString()) ?? 50.0;
    if (speed <= 0) speed = 50.0;
    double etaInHours = distance / speed;
    final eta = (etaInHours * 60).ceil();
    etaStream.add(eta);
  }
}
