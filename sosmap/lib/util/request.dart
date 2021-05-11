import 'dart:async';
//import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sosmap/models/request.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum authProblems { UserNotFound, PasswordNotValid, NetworkError, UnknownError }

class RequestAPI {
  static void addRequestDB(RequestModel requestModel) async {
    FirebaseFirestore.instance
        .collection('requests')
        .doc()
        .set(requestModel.toJson());
  }

  // static Future<List<RequestModel>> getRequestFirestore() async {
  //     Listlist = FirebaseFirestore.instance
  //         .collection('request')
  //         .snapshots()
  //         .listen((result) {
  //             result.docs.forEach((element) {

  //             })
  //          })
  //         .then((documentSnapshot) => RequestModel.fromDocument(documentSnapshot));
  //   }
  //
}
