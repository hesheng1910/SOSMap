import 'package:flutter/material.dart';
import 'package:sosmap/ui/screens/profile.dart';
import 'package:sosmap/ui/screens/reviews.dart';

class TabBarProfile extends StatelessWidget {
  final List<Widget> widgets = <Widget>[
    ProfilePage(),
    ListReview()
  ];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            flexibleSpace: new Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children:[
                TabBar(
                  tabs: [
                  Tab(text: "Hồ Sơ"),
                  Tab(text: "Đánh Giá"),
                  ],
                ),
              ]
            ),
          ),
          body: TabBarView(
            children: widgets,
          ),
        ),
      ),
    );
  }
}