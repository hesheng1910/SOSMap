import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:wemapgl/wemapgl.dart';

import 'ePage.dart';

class ScreenRouteArguments {
  WeMapPlace origin;
  WeMapPlace destination;

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
    WeMapDirection weMapDirection = WeMapDirection(
        originIcon: "assets/symbols/origin.png",
        destinationIcon: "assets/symbols/destination.png");
    if (args?.origin != null) weMapDirection.originPlace = args.origin;
    if (args?.destination != null)
      weMapDirection.destinationPlace = args.destination;

    return weMapDirection;
  }
}
