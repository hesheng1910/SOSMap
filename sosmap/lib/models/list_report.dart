import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sosmap/models/report.dart';

// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

ListReportModel requestFromJson(String str) {
  final jsonData = json.decode(str);
  return ListReportModel.fromJson(jsonData);
}

String requestToJson(ListReportModel data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class ListReportModel {
  String userId;
  List<ReportModel> listReport;

  ListReportModel({this.userId, this.listReport});

  factory ListReportModel.fromJson(Map<String, dynamic> json) =>
      new ListReportModel(
          userId: json["userId"], listReport: json["listReport"]);

  Map<String, dynamic> toJson() => {"userId": userId, "listReport": listReport};

  factory ListReportModel.fromDocument(DocumentSnapshot doc) {
    return ListReportModel.fromJson(doc.data());
  }
}
