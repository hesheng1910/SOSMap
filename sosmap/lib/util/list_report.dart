import 'dart:async';
//import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sosmap/models/list_report.dart';
import 'package:sosmap/models/report.dart';
import 'package:sosmap/models/request.dart';

enum authProblems { UserNotFound, PasswordNotValid, NetworkError, UnknownError }

class RequestAPI {
  static void addRequestDB(ListReportModel listReportModel) async {
    FirebaseFirestore.instance
        .collection('reports')
        .doc(listReportModel.userId)
        .set(listReportModel.toJson());
  }

  static void editRequestDB(ListReportModel listReportModel) async {
    FirebaseFirestore.instance
        .collection('reports')
        .doc(listReportModel.userId)
        .update(listReportModel.toJson());
  }

  static Future<ListReportModel> getListReportFirestore(String userId) async {
    if (userId != null) {
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
