import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sosmap/models/state.dart';
import 'package:sosmap/models/user.dart';
import 'package:sosmap/models/settings.dart';
import 'package:sosmap/util/auth.dart';

class StateWidget extends StatefulWidget {
  final StateModel state;
  final Widget child;

  StateWidget({
    @required this.child,
    this.state,
  });

  // Returns data of the nearest widget _StateDataWidget
  // in the widget tree.
  static _StateWidgetState of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<_StateDataWidget>())
        .data;
  }

  @override
  _StateWidgetState createState() => new _StateWidgetState();
}

class _StateWidgetState extends State<StateWidget> {
  StateModel state;
  //GoogleSignInAccount googleAccount;
  //final GoogleSignIn googleSignIn = new GoogleSignIn();

  @override
  void initState() {
    super.initState();
    if (widget.state != null) {
      state = widget.state;
    } else {
      state = new StateModel(isLoading: true);
      initUser();
    }
  }

  Future<Null> initUser() async {
    //print('...initUser...');
    User firebaseUserAuth = await Auth.getCurrentFirebaseUser();
    if (firebaseUserAuth == null) return null;
    UserModel user = await Auth.getUserFirestore(firebaseUserAuth.uid);
    SettingModels settings = await Auth.getSettingsLocal();
    setState(() {
      state.isLoading = false;
      state.firebaseUserAuth = firebaseUserAuth;
      state.user = user;
      state.settings = settings;
    });
  }

  Future<void> logOutUser() async {
    await Auth.signOut();
    User firebaseUserAuth = await Auth.getCurrentFirebaseUser();
    setState(() {
      state.user = null;
      state.settings = null;
      state.firebaseUserAuth = firebaseUserAuth;
    });
  }

  Future<void> logInUser(email, password) async {
    String userId = await Auth.signIn(email, password);
    print(userId);
    UserModel user = await Auth.getUserFirestore(userId);
    print(user.email);
    await Auth.storeUserLocal(user);
    SettingModels settings = await Auth.getSettingsFirestore(userId);
    await Auth.storeSettingsLocal(settings);
    await initUser();
  }

  @override
  Widget build(BuildContext context) {
    return new _StateDataWidget(
      data: this,
      child: widget.child,
    );
  }
}

class _StateDataWidget extends InheritedWidget {
  final _StateWidgetState data;

  _StateDataWidget({
    Key key,
    @required Widget child,
    @required this.data,
  }) : super(key: key, child: child);

  // Rebuild the widgets that inherit from this widget
  // on every rebuild of _StateDataWidget:
  @override
  bool updateShouldNotify(_StateDataWidget old) => true;
}
