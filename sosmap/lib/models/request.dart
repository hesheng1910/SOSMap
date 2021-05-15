import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sosmap/models/user.dart';

// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

RequestModel requestFromJson(String str) {
  final jsonData = json.decode(str);
  return RequestModel.fromJson(jsonData);
}

String requestToJson(RequestModel data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class RequestModel {
  String userId;
  String name;
  String tel;
  double lat;
  double lng;
  String reason; //Tai nạn, Hỏng xe, Hết xăng, ...
  String message;
  String status;
  String helperId;
  Timestamp createAt;

  RequestModel(
      {this.userId,
      this.name,
      this.tel,
      this.lat,
      this.lng,
      this.reason,
      this.message,
      this.helperId,
      this.status,
      this.createAt});

  factory RequestModel.fromJson(Map<String, dynamic> json) => new RequestModel(
      userId: json["userId"],
      name: json["name"],
      tel: json["tel"],
      lat: json["lat"],
      lng: json["lng"],
      reason: json["reason"],
      message: json["message"],
      status: json["status"],
      helperId: json["helperId"],
      createAt: json["createAt"]);

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "name": name,
        "tel": tel,
        "lat": lat,
        "lng": lng,
        "reason": reason,
        "message": message,
        "helperId": helperId,
        "status": status,
        "createAt": createAt
      };

  factory RequestModel.fromDocument(DocumentSnapshot doc) {
    return RequestModel.fromJson(doc.data());
  }
  @override
  String toString() {
    return "UserId: ${userId}\n Name: ${name}\n Tel: ${tel} \nlat: ${lat} \nlng: ${lng} \nreason: ${reason} \nmessage: ${message}";
  }
}
