import 'package:supercharged/supercharged.dart';

class User {
  int id;
  String name;
  String? email;
  String? phone;
  String photo;
  String role;
  int? vendorId;
  double rating;
  bool isOnline = false;
  bool isTaxiDriver = false;
  bool documentRequested;
  bool pendingDocumentApproval;
  bool deleteRequest;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.photo,
    required this.role,
    required this.vendorId,
    required this.rating,
    required this.isOnline,
    required this.isTaxiDriver,
    this.documentRequested = false,
    this.pendingDocumentApproval = false,
    this.deleteRequest = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> userMap = json;
    if (json.containsKey("user") && json["user"] is Map<String, dynamic>) {
      userMap = json["user"];
    } else if (json.containsKey("data") && json["data"] is Map<String, dynamic>) {
      if (json["data"].containsKey("user") && json["data"]["user"] is Map<String, dynamic>) {
        userMap = json["data"]["user"];
      } else {
        userMap = json["data"];
      }
    }

    return User(
      id: int.tryParse(userMap['id']?.toString() ?? "0") ?? 0,
      name: userMap['name']?.toString() ?? "",
      email: userMap['email']?.toString(),
      phone: userMap['phone']?.toString(),
      photo: (userMap['photo'] ?? "")
          .toString()
          .replaceAll("///mahila-sarthi.mytechbro.com//", "/")
          .replaceAll("mahila-sarthi.mytechbro.com/mahila-sarthi.mytechbro.com", "mahila-sarthi.mytechbro.com"),
      role: userMap['role_name']?.toString() ?? userMap['role']?.toString() ?? "driver",
      vendorId: userMap['vendor_id'] != null ? int.tryParse(userMap['vendor_id'].toString()) : null,
      rating: double.tryParse(userMap['rating']?.toString() ?? "5.0") ?? 5.0,
      isOnline: userMap['is_online'] == true ||
          userMap['is_online']?.toString() == "1" ||
          userMap['is_online']?.toString().toLowerCase() == "true",
      isTaxiDriver: userMap['is_taxi_driver'] == true ||
          userMap['is_taxi_driver']?.toString() == "1" ||
          userMap['is_taxi_driver']?.toString().toLowerCase() == "true" ||
          userMap['is_taxi_driver'] == null,
      documentRequested: userMap["document_requested"] == true || userMap["document_requested"].toString() == "1",
      pendingDocumentApproval: userMap["pending_document_approval"] == true || userMap["pending_document_approval"].toString() == "1",
      deleteRequest: (int.tryParse(userMap['delete_request']?.toString() ?? "0") ?? 0) == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photo': photo,
      'role_name': role,
      'vendor_id': vendorId,
      'rating': rating,
      'is_online': isOnline ? 1 : 0,
      'is_taxi_driver': isTaxiDriver ? 1 : 0,
      'document_requested': documentRequested,
      'pending_document_approval': pendingDocumentApproval,
      'delete_request': deleteRequest ? 1 : 0,
    };
  }
}
