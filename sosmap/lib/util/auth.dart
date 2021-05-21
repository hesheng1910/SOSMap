import 'dart:async';
//import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sosmap/models/user.dart';
import 'package:sosmap/models/settings.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum authProblems { UserNotFound, PasswordNotValid, NetworkError, UnknownError }

class Auth {
  static Future<String> signUp(String email, String password) async {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    return userCredential.user.uid;
  }

  static void addUserSettingsDB(UserModel user) async {
    checkUserExist(user.userId).then((value) {
      if (!value) {
        print("user ${user.fullName} ${user.email} added");
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.userId)
            .set(user.toJson());
        _addSettings(new SettingModels(
          settingsId: user.userId,
        ));
      } else {
        print("user ${user.fullName} ${user.email} exists");
      }
    });
  }

  static void updateUser(UserModel user) {
    checkUserExist(user.userId).then((value) {
      if (!value) {
        print("Không tồn tại user");
      } else {
        print("update user thành công");
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.userId)
            .update(user.toJson());
      }
    });
  }

  static Future<bool> checkUserExist(String userId) async {
    bool exists = false;
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .get()
          .then((doc) {
        if (doc.exists)
          exists = true;
        else
          exists = false;
      });
      return exists;
    } catch (e) {
      return false;
    }
  }

  static void _addSettings(SettingModels settings) async {
    FirebaseFirestore.instance
        .collection("settings")
        .doc(settings.settingsId)
        .set(settings.toJson());
  }

  static Future<String> signIn(String email, String password) async {
    UserCredential user = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    return user.user.uid;
  }

  static Future<UserModel> getUserFirestore(String userId) async {
    if (userId != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get()
          .then((documentSnapshot) => UserModel.fromDocument(documentSnapshot));
    } else {
      print('firestore userId can not be null');
      return null;
    }
  }

  static Future<void> updateUserFirestore(String userId, var data) async {
    if (userId != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fullName': data['fullName'],
        'tel': data['telephone'],
        'email': data['email']
      });
    } else {
      print('firestore userId can not be null');
      return null;
    }
  }

  static Future<SettingModels> getSettingsFirestore(String settingsId) async {
    if (settingsId != null) {
      return FirebaseFirestore.instance
          .collection('settings')
          .doc(settingsId)
          .get()
          .then((documentSnapshot) =>
              SettingModels.fromDocument(documentSnapshot));
    } else {
      print('no firestore settings available');
      return null;
    }
  }

  static Future<String> storeUserLocal(UserModel user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storeUser = userToJson(user);
    await prefs.setString('user', storeUser);
    return user.userId;
  }

  static Future<String> storeSettingsLocal(SettingModels settings) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storeSettings = settingsToJson(settings);
    await prefs.setString('settings', storeSettings);
    return settings.settingsId;
  }

  static Future<User> getCurrentFirebaseUser() async {
    User currentUser = FirebaseAuth.instance.currentUser;
    return currentUser;
  }

  static Future<UserModel> getUserLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('user') != null) {
      UserModel user = userFromJson(prefs.getString('user'));
      //print('USER: $user');
      return user;
    } else {
      return null;
    }
  }

  static Future<SettingModels> getSettingsLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('settings') != null) {
      SettingModels settings = settingsFromJson(prefs.getString('settings'));
      //print('SETTINGS: $settings');
      return settings;
    } else {
      return null;
    }
  }

  static Future<void> signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    FirebaseAuth.instance.signOut();
  }

  static Future<void> forgotPasswordEmail(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  static String getExceptionText(Exception e) {
    if (e is PlatformException) {
      switch (e.message) {
        case 'There is no user record corresponding to this identifier. The user may have been deleted.':
          return 'Không tồn tại tài khoản sử dụng Email này.';
          break;
        case 'The password is invalid or the user does not have a password.':
          return 'Mật khẩu không hợp lệ.';
          break;
        case 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
          return 'Không có kết nối mạng.';
          break;
        case 'The email address is already in use by another account.':
          return 'Email này đã được sử dụng cho một tài khoản khác.';
          break;
        default:
          return 'Xảy ra lỗi không xác định.';
      }
    } else {
      return 'Xảy ra lỗi không xác định.';
    }
  }

  /*static Stream<User> getUserFirestore(String userId) {
    print("...getUserFirestore...");
    if (userId != null) {
      //try firestore
      return Firestore.instance
          .collection("users")
          .where("userId", isEqualTo: userId)
          .snapshots()
          .map((QuerySnapshot snapshot) {
        return snapshot.documents.map((doc) {
          return User.fromDocument(doc);
        }).first;
      });
    } else {
      print('firestore user not found');
      return null;
    }
  }*/

  /*static Stream<Settings> getSettingsFirestore(String settingsId) {
    print("...getSettingsFirestore...");
    if (settingsId != null) {
      //try firestore
      return Firestore.instance
          .collection("settings")
          .where("settingsId", isEqualTo: settingsId)
          .snapshots()
          .map((QuerySnapshot snapshot) {
        return snapshot.documents.map((doc) {
          return Settings.fromDocument(doc);
        }).first;
      });
    } else {
      print('no firestore settings available');
      return null;
    }
  }*/
}
