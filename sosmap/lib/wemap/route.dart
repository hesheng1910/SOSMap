import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:wemapgl/wemapgl.dart';

import 'ePage.dart';

class ScreenRouteArguments {
  final WeMapPlace origin;
  final WeMapPlace destination;

  ScreenRouteArguments(this.origin, this.destination);
}

class RoutePage extends EPage {
  RoutePage() : super(const Icon(Icons.directions), 'Direction');
  @override
  Widget build(BuildContext context) {
    return Routing();
  }
}

class Routing extends StatefulWidget {
  const Routing();
  @override
  State createState() => RoutingState();
}

class RoutingState extends State<Routing> {
  @override
  Widget build(BuildContext context) {
//    Size size = MediaQuery.of(context).size;
//    _panelOpened = size.height - MediaQuery.of(context).padding.top;
    final args =
        ModalRoute.of(context).settings.arguments as ScreenRouteArguments;
    return WeMapDirection(
        originIcon: "assets/symbols/origin.png",
        destinationIcon: "assets/symbols/destination.png",
        originPlace: args.origin,
        destinationPlace: args.destination);
  }
}
