import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sosmap/models/request.dart';

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
  RequestModel request;
  int rate;
  String reviewMessage;
  Timestamp createAt;

  ReportModel({this.request, this.rate, this.reviewMessage, this.createAt});

  factory ReportModel.fromJson(Map<String, dynamic> json) => new ReportModel(
      request: RequestModel.fromJson(json["requestId"]),
      rate: json["rate"],
      reviewMessage: json["reviewMessage"],
      createAt: json["createAt"]);

  Map<String, dynamic> toJson() => {
        "requestId": request.toJson(),
        "rate": rate,
        "reviewMessage": reviewMessage,
        "createAt": createAt
      };

  factory ReportModel.fromDocument(DocumentSnapshot doc) {
    return ReportModel.fromJson(doc.data());
  }
}
