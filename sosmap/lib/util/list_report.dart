import 'dart:async';
//import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sosmap/models/list_report.dart';

enum authProblems { UserNotFound, PasswordNotValid, NetworkError, UnknownError }

class ReportAPI {
  static Future<void> addReportDB(ListReportModel listReportModel) async {
    FirebaseFirestore.instance
        .collection('reports')
        .doc(listReportModel.userId)
        .set(listReportModel.toJson());
  }

  static void editReportDB(ListReportModel listReportModel) async {
    FirebaseFirestore.instance
        .collection('reports')
        .doc(listReportModel.userId)
        .update(listReportModel.toJson());
  }

  static Future<ListReportModel> getListReportFirestore(String userId) async {
    if (userId != null) {
      DocumentReference ref =
          FirebaseFirestore.instance.collection('reports').doc(userId);
      var doc = await ref.get();
      if (!doc.exists) return null;
      return FirebaseFirestore.instance
          .collection('reports')
          .doc(userId)
          .get()
          .then((documentSnapshot) =>
              ListReportModel.fromDocument(documentSnapshot));
    } else {
      print('listReport:: firestore userId can not be null');
      return null;
    }
  }
}
