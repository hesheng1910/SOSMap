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

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(0, 144, 74, 1),
      body: Center(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "SOSMap\n",
                style: new TextStyle(
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: "Cùng nhau vượt qua mọi con đường",
                style: new TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.white),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class Home extends StatelessWidget {
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

class MyApp extends StatelessWidget {
  MyApp() {
    //Navigation.initPaths();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        // Replace the 3 second delay with your initialization code:
        future: Future.delayed(Duration(seconds: 3)),
        builder: (context, AsyncSnapshot snapshot) {
          // Show splash screen while waiting for app resources to load:
          if (snapshot.connectionState == ConnectionState.waiting) {
            return MaterialApp(home: Splash());
          } else {
            return Home();
          }
        });
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
