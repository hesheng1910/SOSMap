import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

UserModel userFromJson(String str) {
  final jsonData = json.decode(str);
  return UserModel.fromJson(jsonData);
}

String userToJson(UserModel data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class UserModel {
  String userId;
  String fullName;
  String email;
  String tel;
  double rate;
  double lat;
  double lng;
  String tokens;
  String avatarUrl;

  UserModel({
    this.userId,
    this.avatarUrl,
    this.fullName,
    this.email,
    this.tel,
    this.rate,
    this.lat,
    this.lng,
    this.tokens,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => new UserModel(
      userId: json["userId"],
      avatarUrl: json['avatarUrl'],
      fullName: json["fullName"],
      email: json["email"],
      tel: json["tel"],
      rate: json["rate"],
      lat: json["lat"],
      lng: json["lng"],
      tokens: json["tokens"]);

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "avatarUrl": avatarUrl,
        "fullName": fullName,
        "email": email,
        "tel": tel,
        "rate": rate,
        "lat": lat,
        "lng": lng,
        "tokens": tokens,
      };

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    return UserModel.fromJson(doc.data());
  }
}
