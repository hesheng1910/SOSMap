import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wemapgl/wemapgl.dart';

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
  WeMapPlace place;
  String reason; //Tai nạn, Hỏng xe, Hết xăng, ...
  String message;
  String status;
  String helperId;
  String price;
  Timestamp createAt;

  RequestModel(
      {this.userId,
      this.name,
      this.tel,
      this.place,
      this.reason,
      this.message,
      this.helperId,
      this.status,
      this.price,
      this.createAt});

  factory RequestModel.fromJson(Map<String, dynamic> json) => new RequestModel(
      userId: json["userId"],
      name: json["name"],
      tel: json["tel"],
      place: json["place"] != null
          ? WeMapPlace.fromMapObject(json["place"])
          : null,
      reason: json["reason"],
      message: json["message"],
      status: json["status"],
      helperId: json["helperId"],
      price: json["price"],
      createAt: json["createAt"]);

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "name": name,
        "tel": tel,
        "place": place?.toMap(),
        "reason": reason,
        "message": message,
        "helperId": helperId,
        "status": status,
        "price": price,
        "createAt": createAt
      };

  factory RequestModel.fromDocument(DocumentSnapshot doc) {
    return RequestModel.fromJson(doc.data());
  }
  @override
  String toString() {
    return "UserId: ${userId}\n Name: ${name}\n Tel: ${tel} \nlat: \nreason: ${reason} \nmessage: ${message}";
  }
}
