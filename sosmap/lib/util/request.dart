import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sosmap/models/request.dart';

enum authProblems { UserNotFound, PasswordNotValid, NetworkError, UnknownError }

class RequestAPI {
  static void addRequestDB(RequestModel requestModel) async {
    FirebaseFirestore.instance
        .collection('requests')
        .doc(requestModel.userId)
        .set(requestModel.toJson());
  }

  static void editRequestDB(RequestModel requestModel) async {
    FirebaseFirestore.instance
        .collection('requests')
        .doc(requestModel.userId)
        .update(requestModel.toJson());
  }

  static Future<void> deleteRequestDB(String requestID) async {
    FirebaseFirestore.instance.collection('requests').doc(requestID).delete();
  }

  static Future<List<RequestModel>> getRequestFirestore() async {
    //return FirebaseFirestore.instance.collection('request').snapshots();
  }
}
