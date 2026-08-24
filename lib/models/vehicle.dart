// To parse this JSON data, do
//
//     final vehicle = vehicleFromJson(jsonString);

import 'dart:convert';
import 'package:supercharged/supercharged.dart';

Vehicle vehicleFromJson(String str) => Vehicle.fromJson(json.decode(str));

String vehicleToJson(Vehicle data) => json.encode(data.toJson());

class Vehicle {
  Vehicle({
    required this.id,
    required this.carModelId,
    required this.driverId,
    required this.vehicleTypeId,
    required this.regNo,
    required this.color,
    required this.photo,
    required this.carModel,
    required this.vehicleType,
    required this.verified,
    this.isActive = 0,
  });

  int id;
  int carModelId;
  int driverId;
  int vehicleTypeId;
  String regNo;
  String color;
  int isActive;

  String photo;
  CarModel carModel;
  VehicleType vehicleType;
  bool verified;

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json["id"] ?? 0,
      carModelId: json["car_model_id"] ?? 0,
      driverId: json["driver_id"] ?? 0,
      vehicleTypeId: json["vehicle_type_id"] ?? 0,
      regNo: json["reg_no"] ?? "",
      color: json["color"] ?? "",
      isActive: json["is_active"] == null
          ? 0
          : (json["is_active"] is bool)
              ? json["is_active"]
                  ? 1
                  : 0
              : int.tryParse(json["is_active"].toString()) ?? 0,
      photo: (json["photo"] ?? "").toString().replaceAll("///mahila-sarthi.mytechbro.com//", "/").replaceAll("mahila-sarthi.mytechbro.com/mahila-sarthi.mytechbro.com", "mahila-sarthi.mytechbro.com"),
      carModel: json["car_model"] != null
          ? CarModel.fromJson(json["car_model"])
          : CarModel(id: 0, name: "", carMakeId: 0, carMake: null),
      vehicleType: json["vehicle_type"] != null
          ? VehicleType.fromJson(json["vehicle_type"])
          : VehicleType(
              id: 0,
              name: "",
              slug: "",
              baseFare: 0.0,
              distanceFare: 0.0,
              timeFare: 0.0,
              minFare: 0.0,
              isActive: 0,
              formattedDate: "",
              photo: "",
            ),
      verified: json["verified"] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "car_model_id": carModelId,
        "driver_id": driverId,
        "vehicle_type_id": vehicleTypeId,
        "reg_no": regNo,
        "color": color,
        "is_active": isActive,
        "photo": photo,
        "car_model": carModel.toJson(),
        "vehicle_type": vehicleType.toJson(),
        "verified": verified,
      };
}

class CarModel {
  CarModel({
    required this.id,
    required this.name,
    required this.carMakeId,
    required this.carMake,
  });

  int id;
  String name;
  int carMakeId;
  CarMake? carMake;

  factory CarModel.fromJson(Map<String, dynamic> json) => CarModel(
        id: json["id"] ?? 0,
        name: json["name"] ?? "",
        carMakeId: json["car_make_id"] ?? 0,
        carMake: json["car_make"] != null
            ? CarMake.fromJson(json["car_make"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "car_make_id": carMakeId,
        "car_make": carMake?.toJson(),
      };
}

class CarMake {
  CarMake({
    required this.id,
    required this.name,
  });

  int id;
  String name;

  factory CarMake.fromJson(Map<String, dynamic> json) => CarMake(
        id: json["id"] ?? 0,
        name: json["name"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

class VehicleType {
  VehicleType({
    required this.id,
    required this.name,
    required this.slug,
    required this.baseFare,
    required this.distanceFare,
    required this.timeFare,
    required this.minFare,
    required this.isActive,
    required this.formattedDate,
    required this.photo,
  });

  int id;
  String name;
  String slug;
  double baseFare;
  double distanceFare;
  double timeFare;
  double minFare;
  int isActive;
  String formattedDate;
  String photo;

  factory VehicleType.fromJson(Map<String, dynamic> json) {
    String rawPhoto = (json["photo"] ?? "").toString();
    if (rawPhoto.isNotEmpty) {
      rawPhoto = rawPhoto
          .replaceAll("mahila-sarthi.mytechbro.com", "admin.mahilasaarthi.in")
          .replaceAll("///admin.mahilasaarthi.in//", "admin.mahilasaarthi.in/")
          .replaceAll("https://admin.mahilasaarthi.in//", "https://admin.mahilasaarthi.in/");
      if (!rawPhoto.startsWith("http")) {
        if (!rawPhoto.startsWith("/")) {
          rawPhoto = "/$rawPhoto";
        }
        rawPhoto = "https://admin.mahilasaarthi.in$rawPhoto";
      }
    }
    return VehicleType(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      slug: json["slug"] ?? "",
      baseFare: (json["base_fare"] ?? "0").toString().toDouble() ?? 0.0,
      distanceFare: (json["distance_fare"] ?? "0").toString().toDouble() ?? 0.0,
      timeFare: (json["time_fare"] ?? "0").toString().toDouble() ?? 0.0,
      minFare: (json["min_fare"] ?? "0").toString().toDouble() ?? 0.0,
      isActive: json["is_active"] ?? 0,
      formattedDate: json["formatted_date"] ?? "",
      photo: rawPhoto,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
        "base_fare": baseFare,
        "distance_fare": distanceFare,
        "time_fare": timeFare,
        "min_fare": minFare,
        "is_active": isActive,
        "formatted_date": formattedDate,
        "photo": photo,
      };
}
