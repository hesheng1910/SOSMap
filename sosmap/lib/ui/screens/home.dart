import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:sosmap/models/state.dart';
import 'package:sosmap/ui/screens/map.dart';
import 'package:sosmap/ui/screens/profile.dart';
import 'package:sosmap/util/state_widget.dart';
import 'package:sosmap/ui/screens/sign_in.dart';
import 'package:sosmap/ui/widgets/loading.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'history.dart';

class HomeScreen extends StatefulWidget {
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  StateModel appState;
  bool _loadingVisible = false;
  TabController _tabController;
  var _tabItems = <TabItem>[
    TabItem(
      icon: Icon(Icons.map),
      title: 'Bản đồ',
    ),
    TabItem(
      icon: Icon(Icons.history),
      title: 'Lịch sử',
    ),
    TabItem(
      icon: Icon(Icons.person),
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

      final List<Widget> _widgetOptions = <Widget>[
        FullMap(),
        HistoryScreen(),
        ProfilePage(),
      ];
      return Scaffold(
        backgroundColor: Colors.white,
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
          style: TabStyle.textIn,
          curve: Curves.bounceInOut,
          controller: _tabController,
          backgroundColor: Theme.of(context).primaryColor,
          gradient: RadialGradient(
            center: const Alignment(0, 0), // near the top right
            radius: 5,
            colors: [Colors.green, Colors.blue, Colors.redAccent],
          ),
          onTap: _onItemTapped,
        ),
      );
    }
  }
}
