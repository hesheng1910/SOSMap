import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:location/location.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sosmap/models/state.dart';
import 'package:sosmap/ui/screens/map.dart';
import 'package:sosmap/ui/screens/profile.dart';
import 'package:sosmap/util/state_widget.dart';
import 'package:sosmap/ui/screens/sign_in.dart';
import 'package:sosmap/ui/widgets/loading.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import '../../main.dart';
import 'history.dart';
import 'package:overlay_support/overlay_support.dart';

class HomeScreen extends StatefulWidget {
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  GlobalKey _scaffold = GlobalKey();
  StateModel appState;
  bool _loadingVisible = false;
  TabController _tabController;
  bool hasNoti = false;
  var _tabItems = <TabItem>[
    TabItem(
      icon: Icon(CupertinoIcons.map_fill),
      title: 'Bản đồ',
    ),
    TabItem(
      icon: Icon(CupertinoIcons.square_favorites_alt_fill),
      title: 'Lịch sử',
    ),
    TabItem(
      icon: Icon(CupertinoIcons.profile_circled),
      title: 'Hồ sơ',
    ),
  ];
  @override
  void initState() {
    getPermissions();
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });
  }

  void getPermissions() async {
    final location = Location();
    final hasPermissions = await location.hasPermission();
    if (hasPermissions != PermissionStatus.GRANTED) {
      await location.requestPermission();
    }
  }

  final List<Widget> _widgetOptions = <Widget>[
    FullMap(),
    HistoryScreen(),
    ProfilePage(),
  ];
  Widget build(BuildContext context) {
    appState = StateWidget.of(context).state;
    if (appState == null) return SignInScreen();
    if ((appState.firebaseUserAuth == null ||
        appState.user == null ||
        appState.settings == null)) {
      return SignInScreen();
    } else {
      if (appState.isLoading) {
        _loadingVisible = true;
      } else {
        _loadingVisible = false;
      }

      FirebaseMessaging.instance
          .getInitialMessage()
          .then((RemoteMessage message) {
        if (message != null) {
          print('Có notification');
          print(message.data);
        }
      });
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification notification = message.notification;
        AndroidNotification android = message.notification?.android;
        if (notification != null && android != null) {
          FlutterAppBadger.updateBadgeCount(1);
          flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channel.id,
                  channel.name,
                  channel.description,
                  // TODO add a proper drawable resource to android, for now using
                  //      one that already exists in example app.
                  //icon: 'launch_background',
                  color: Color.fromRGBO(0, 144, 74, 1),
                ),
              ));
          if (message.data.containsKey('type') &&
              (message.data['type'] == 'waiting' ||
                  message.data['type'] == 'cancel')) {
            Alert(
                    context: _scaffold.currentContext,
                    type: message.data['type'] == 'waiting'
                        ? AlertType.success
                        : AlertType.error,
                    title: message.data['type'] == 'waiting'
                        ? 'NHẬN ĐƯỢC TRỢ GIÚP'
                        : 'TRỢ GIÚP BỊ HUỶ',
                    closeIcon: Icon(
                      Icons.close,
                      color: Colors.red,
                    ),
                    content: Text(message.notification.body),
                    style: AlertStyle(
                        isButtonVisible: false,
                        overlayColor: Colors.black54,
                        titleStyle: TextStyle(
                            color: message.data['type'] == 'waiting'
                                ? Colors.green
                                : Colors.red)))
                .show();
          }
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        FlutterAppBadger.removeBadge();
        print('A new onMessageOpenedApp event was published!');
        if (message.data.containsKey('type') &&
            (message.data['type'] == 'waiting' ||
                message.data['type'] == 'cancel')) {
          Alert(
                  context: _scaffold.currentContext,
                  type: message.data['type'] == 'waiting'
                      ? AlertType.success
                      : AlertType.error,
                  title: message.data['type'] == 'waiting'
                      ? 'NHẬN ĐƯỢC TRỢ GIÚP'
                      : 'TRỢ GIÚP BỊ HUỶ',
                  closeIcon: Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                  content: Text(message.notification.body),
                  style: AlertStyle(
                      isButtonVisible: false,
                      overlayColor: Colors.black54,
                      titleStyle: TextStyle(
                          color: message.data['type'] == 'waiting'
                              ? Colors.green
                              : Colors.red)))
              .show();
        }
      });

      return Scaffold(
        backgroundColor: Colors.white,
        key: _scaffold,
        body: LoadingScreen(
          child: IndexedStack(
            children: _widgetOptions,
            index: _selectedIndex,
          ),
          inAsyncCall: _loadingVisible,
        ),
        bottomNavigationBar: ConvexAppBar(
          items: _tabItems,
          initialActiveIndex: _selectedIndex,
          controller: _tabController,
          backgroundColor: Theme.of(context).primaryColor,
          // gradient: RadialGradient(
          //   center: const Alignment(0, 0), // near the top right
          //   radius: 5,
          //   colors: [Colors.green, Colors.blue, Colors.redAccent],
          // ),
          onTap: _onItemTapped,
        ),
      );
    }
  }
}
