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

  UserModel({this.userId, this.fullName, this.email, this.tel, this.rate});

  factory UserModel.fromJson(Map<String, dynamic> json) => new UserModel(
      userId: json["userId"],
      fullName: json["fullName"],
      email: json["email"],
      tel: json["tel"],
      rate: json["rate"]);

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "fullName": fullName,
        "email": email,
        "tel": tel,
        "rate": rate
      };

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    return UserModel.fromJson(doc.data());
  }
}
