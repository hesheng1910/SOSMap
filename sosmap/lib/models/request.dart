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
  UserModel user;
  double lat;
  double lng;
  String reason; //Tai nạn, Hỏng xe, Hết xăng, ...
  String message;
  String status;
  UserModel helper;
  DateTime createAt;

  RequestModel(
      {this.user,
      this.lat,
      this.lng,
      this.reason,
      this.message,
      this.helper,
      this.status,
      this.createAt});

  factory RequestModel.fromJson(Map<String, dynamic> json) => new RequestModel(
      user: json["user"],
      lat: json["lat"],
      lng: json["lng"],
      reason: json["reason"],
      message: json["message"],
      status: json["status"],
      helper: json["helper"],
      createAt: json["createAt"]);

  Map<String, dynamic> toJson() => {
        "user": user,
        "lat": lat,
        "lng": lng,
        "reason": reason,
        "message": message,
        "helper": helper,
        "status": status,
        "createAt": createAt
      };

  factory RequestModel.fromDocument(DocumentSnapshot doc) {
    return RequestModel.fromJson(doc.data());
  }
}
