import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sosmap/ui/screens/login_page.dart';
import 'package:sosmap/ui/screens/signup_page.dart';

import 'package:sosmap/util/state_widget.dart';
import 'package:sosmap/ui/theme.dart';
import 'package:sosmap/ui/screens/home.dart';
import 'package:sosmap/ui/screens/sign_in.dart';
import 'package:sosmap/ui/screens/sign_up.dart';
import 'package:sosmap/ui/screens/forgot_password.dart';
import 'package:sosmap/wemap/route.dart';

import 'package:wemapgl/wemapgl.dart' as WEMAP;

class MyApp extends StatelessWidget {
  MyApp() {
    //Navigation.initPaths();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOSMap',
      theme: buildTheme(),
      //onGenerateRoute: Navigation.router.generator,
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => HomeScreen(),
        '/signin': (context) => SignInScreen(),
        '/signup': (context) => SignUpScreen(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
        '/route-page': (context) => RoutePage(),
        '/login-page': (context) => LoginPageFourteen(),
        '/signup-page': (context) => SignupThreePage()
      },
    );
  }
}

void main() async {
  WEMAP.Configuration.setWeMapKey('GqfwrZUEfxbwbnQUhtBMFivEysYIxelQ');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  StateWidget stateWidget = new StateWidget(
    child: new MyApp(),
  );
  runApp(stateWidget);
}
