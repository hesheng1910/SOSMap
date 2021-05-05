import 'package:firebase_auth/firebase_auth.dart';
import 'package:sosmap/models/user.dart';
import 'package:sosmap/models/settings.dart';

class StateModel {
  bool isLoading;
  User firebaseUserAuth;
  UserModel user;
  SettingModels settings;

  StateModel({
    this.isLoading = false,
    this.firebaseUserAuth,
    this.user,
    this.settings,
  });
}
