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

  factory ListReportModel.fromJson(Map<String, dynamic> json) {
    Iterable i = json['listReport'];
    List<ReportModel> reports =
        i.map((model) => ReportModel.fromJson(model)).toList();
    return new ListReportModel(userId: json["userId"], listReport: reports);
  }
  Map<String, dynamic> toJson() => {
        "userId": userId,
        "listReport": listReport.map((report) => report.toJson()).toList()
      };

  factory ListReportModel.fromDocument(DocumentSnapshot doc) {
    return ListReportModel.fromJson(doc.data());
  }
}
