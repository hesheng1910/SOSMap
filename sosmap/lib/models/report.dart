import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

ReportModel requestFromJson(String str) {
  final jsonData = json.decode(str);
  return ReportModel.fromJson(jsonData);
}

String requestToJson(ReportModel data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class ReportModel {
  String helperId;
  String requestId;
  int rate;
  String reviewMessage;
  Timestamp createAt;

  ReportModel(
      {this.helperId,
      this.requestId,
      this.rate,
      this.reviewMessage,
      this.createAt});

  factory ReportModel.fromJson(Map<String, dynamic> json) => new ReportModel(
      helperId: json["helperId"],
      requestId: json["requestId"],
      rate: json["rate"],
      reviewMessage: json["reviewMessage"],
      createAt: json["createAt"]);

  Map<String, dynamic> toJson() => {
        "helperId": helperId,
        "requestId": requestId,
        "rate": rate,
        "reviewMessage": reviewMessage,
        "createAt": createAt
      };

  factory ReportModel.fromDocument(DocumentSnapshot doc) {
    return ReportModel.fromJson(doc.data());
  }
}
