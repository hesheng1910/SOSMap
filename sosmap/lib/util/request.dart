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
        .doc(requestModel.userId)
        .set(requestModel.toJson());
  }

  static void editRequestDB(RequestModel requestModel) async {
    FirebaseFirestore.instance
        .collection('requests')
        .doc(requestModel.userId)
        .update(requestModel.toJson());
  }

  static Future<List<RequestModel>> getRequestFirestore() async {
    //return FirebaseFirestore.instance.collection('request').snapshots();
  }
}
