import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sosmap/models/request.dart';
import 'package:sosmap/models/state.dart';
import 'package:sosmap/models/user.dart';
import 'package:sosmap/ui/widgets/card_infomation.dart';
import 'package:sosmap/ui/widgets/create_help.dart';
import 'package:sosmap/ui/widgets/help_info.dart';
import 'package:sosmap/util/auth.dart';
import 'package:sosmap/util/request.dart';
import 'package:sosmap/util/state_widget.dart';
import 'package:sosmap/wemap/route.dart';
import 'package:wemapgl/wemapgl.dart';

import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:rflutter_alert/rflutter_alert.dart';

class FullMap extends StatefulWidget {
  const FullMap();

  @override
  State<StatefulWidget> createState() => FullMapState();
}

class FullMapState extends State<FullMap> {
  FullMapState();
  static final CameraPosition _kInitialPosition = const CameraPosition(
    target: LatLng(21.038282, 105.782885),
    zoom: 11.0,
  );
  StateModel appState;
  static WeMap weMap;
  WeMapController mapController;
  CameraPosition _position;
  bool _isMoving;

  LatLng myLatLng;
  bool reverse = true;
  WeMapPlace place;

  //int _symbolCount;
  Symbol _selectedSymbol;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  WeMapDirections directionAPI = WeMapDirections();

  Stream<QuerySnapshot> listRequest;
  bool _isDrawRouter = false;
  RequestModel _userNeedHelp;
  RequestModel _myHelpRequest;
  @override
  void initState() {
    _position = _kInitialPosition;
    _isMoving = true;
    listRequest = FirebaseFirestore.instance.collection('requests').snapshots();
    weMap = WeMap(
      initialCameraPosition: _kInitialPosition,
      onMapCreated: onMapCreated,
      trackCameraPosition: true,
      compassEnabled: true,
      cameraTargetBounds: CameraTargetBounds.unbounded,
      minMaxZoomPreference: MinMaxZoomPreference.unbounded,
      styleString: WeMapStyles.WEMAP_VECTOR_STYLE,
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      tiltGesturesEnabled: true,
      zoomGesturesEnabled: true,
      myLocationEnabled: true,
      onStyleLoadedCallback: () => _getCurrentLocation(),
      reverse: false,
    );

    super.initState();
  }

  void onMapCreated(WeMapController controller) {
    mapController = controller;

    mapController.addListener(_onMapChanged);
    mapController.onSymbolTapped.add(_onSymbolTapped);
    _extractMapInfo();
  }

  @override
  void dispose() {
    mapController.removeListener(_onMapChanged);
    mapController?.onSymbolTapped?.remove(_onSymbolTapped);
    super.dispose();
  }

  void _onMapChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _extractMapInfo();
      });
    });
  }

  void _extractMapInfo() {
    _position = mapController.cameraPosition;
    _isMoving = mapController.isCameraMoving;
  }

  void _onSymbolTapped(Symbol symbol) {
    if (_selectedSymbol != null) {
      _updateSelectedSymbol(
        const SymbolOptions(iconSize: 1.0),
      );
    }
    setState(() {
      _selectedSymbol = symbol;
    });
    _updateSelectedSymbol(
      SymbolOptions(iconSize: 1.4),
    );
  }

  void _onUnSelectedSymbol() {
    if (_selectedSymbol != null)
      _updateSelectedSymbol(
        const SymbolOptions(iconSize: 1.0),
      );
    setState(() {
      _selectedSymbol = null;
    });
  }

  void _updateSelectedSymbol(SymbolOptions changes) {
    mapController.updateSymbol(_selectedSymbol, changes);
  }

  Future<void> _add(LatLng latlng, Map<String, dynamic> requestData) async {
    if (mapController == null) return;
    await mapController.addSymbol(
        SymbolOptions(
          geometry: latlng,
          iconImage: "assets/symbols/help.png",
        ),
        requestData);
    // setState(() {
    //   _symbolCount += 1;
    // });
  }

  void _remove(Symbol symbol) {
    mapController.removeSymbol(symbol);
    // setState(() {
    //   _symbolCount -= 1;
    // });
  }

  void _changePosition() {
    final LatLng current = _selectedSymbol.options.geometry;
    final Offset offset = Offset(
      myLatLng.latitude - current.latitude,
      myLatLng.longitude - current.longitude,
    );
    _updateSelectedSymbol(
      SymbolOptions(
        geometry: LatLng(
          myLatLng.latitude + offset.dy,
          myLatLng.longitude + offset.dx,
        ),
      ),
    );
  }

  void _getCurrentLocation() async {
    LatLng myLocation = await mapController.requestMyLocationLatLng();
    mapController.moveCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: myLocation,
        zoom: 14.0,
      ),
    ));
    _updateCurrentLocation();
  }

  Future<void> _updateCurrentLocation() async {
    LatLng myLocation = await mapController.requestMyLocationLatLng();
    setState(() {
      myLatLng = myLocation;
    });
    UserModel newUser = appState.user;
    newUser.lat = myLocation.latitude;
    newUser.lng = myLocation.longitude;
    Auth.updateUser(newUser);
    StateWidget.of(context).initUser();
  }

  Future<void> _confirmHelp(RequestModel requestModel) {
    RequestModel newRequest = requestModel;
    newRequest.helperId = appState.user.userId;
    newRequest.status = "waiting";
    RequestAPI.editRequestDB(newRequest);
  }

  void _updateHelper(RequestModel requestModel) {
    setState(() {
      _userNeedHelp = requestModel;
    });
  }

  void _updateMyHelp(RequestModel requestModel) {
    setState(() {
      _myHelpRequest = requestModel;
    });
  }

  void _drawRoute() async {
    if (_isDrawRouter) {
      if (_userNeedHelp == null) {
        mapController.clearCircles();
        mapController.clearLines();
      }
      return;
    }
    if (_userNeedHelp == null || _userNeedHelp.place == null) return;
    if (myLatLng == null) {
      await _updateCurrentLocation();
      if (myLatLng == null) {
        print("Không lấy được vị trí");
        return;
      }
    }
    mapController.clearCircles();
    mapController.clearLines();
    List<LatLng> points = [];
    points.add(myLatLng);
    points.add(_userNeedHelp.place.location);
    final json = await directionAPI.getResponseMultiRoute(
        0, points); //0 = car, 1 = bike, 2 = foot
    List<LatLng> _route = directionAPI.getRoute(json);
    List<LatLng> _waypoins = directionAPI.getWayPoints(json);
    if (_route != null) {
      await mapController.addLine(
        LineOptions(
          geometry: _route,
          lineColor: "#00904a",
          lineWidth: 5.0,
          lineOpacity: 1,
        ),
      );
      await mapController.addCircle(CircleOptions(
          geometry: _waypoins[0],
          circleRadius: 8.0,
          circleColor: '#d3d3d3',
          circleStrokeWidth: 1.5,
          circleStrokeColor: '#00904a'));
      for (int i = 1; i < _waypoins.length; i++) {
        await mapController.addCircle(CircleOptions(
            geometry: _waypoins[i],
            circleRadius: 8.0,
            circleColor: '#ffffff',
            circleStrokeWidth: 1.5,
            circleStrokeColor: '#00904a'));
      }
      setState(() {
        _isDrawRouter = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    appState = StateWidget.of(context).state;
    final _createHelpPopup = CreateHelpPopup(userModel: appState.user);

    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          if (weMap != null)
            StreamBuilder<QuerySnapshot>(
                stream: listRequest,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    RequestModel userNeedHelp;
                    RequestModel myHelp;
                    mapController.clearSymbols();
                    snapshot.data.docs.forEach((data) {
                      RequestModel newRequest = RequestModel.fromDocument(data);
                      if (newRequest.place != null) {
                        _add(newRequest.place.location, newRequest.toJson());
                        // Symbol symbol = (mapController.symbols != null &&
                        //         mapController.symbols.length > 0)
                        //     ? mapController.symbols?.firstWhere(
                        //         (element) =>
                        //             RequestModel.fromJson(element.data)
                        //                 .userId ==
                        //             newRequest.userId,
                        //         orElse: () => null)
                        //     : null;
                        // if (symbol == null)
                        //   _add(LatLng(newRequest.lat, newRequest.lng),
                        //       newRequest.toJson());
                        // else {
                        //   Map<String, dynamic> requestJson =
                        //       newRequest.toJson();
                        //   Map<String, dynamic> symbolDataJson = symbol.data;
                        //   if (mapEquals(requestJson, symbolDataJson)) {
                        //   } else {
                        //     _remove(symbol);
                        //     _add(LatLng(newRequest.lat, newRequest.lng),
                        //         newRequest.toJson());
                        //   }
                        // }

                        // Nếu đang trợ giúp ai đó
                        if (newRequest.helperId == appState.user.userId &&
                            newRequest.status == "waiting") {
                          userNeedHelp = newRequest;
                        }
                        if (newRequest.userId == appState.user.userId) {
                          myHelp = newRequest;
                        }
                      }
                    });
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _updateHelper(userNeedHelp);
                      _updateMyHelp(myHelp);
                    });
                  }

                  _drawRoute();
                  return weMap;
                }),
          if (_selectedSymbol != null)
            new Container(
              alignment: Alignment.center,
              child: CardInfomation(
                requestModel: RequestModel.fromJson(_selectedSymbol.data),
                onCloseBtn: _onUnSelectedSymbol,
                onOpenMapBtn: () {
                  WeMapPlace mylocation = WeMapPlace(location: myLatLng);
                  WeMapPlace destination =
                      RequestModel.fromJson(_selectedSymbol.data).place;
                  Navigator.pushNamed(context, '/route-page',
                      arguments: ScreenRouteArguments(mylocation, destination));
                },
                onConfirmBtn: () {
                  _confirmHelp(RequestModel.fromJson(_selectedSymbol.data));
                  _onUnSelectedSymbol();
                },
              ),
            ),
          if (_userNeedHelp != null)
            new SafeArea(
              child: Container(
                alignment: Alignment.topCenter,
                child: HelpInfo(
                  helpRequest: _userNeedHelp,
                  haveHelpRequest: false,
                  myLocation: myLatLng,
                ),
              ),
            ),
          if (_myHelpRequest != null)
            new SafeArea(
              child: Container(
                alignment: Alignment.topCenter,
                child: HelpInfo(
                  helpRequest: _myHelpRequest,
                  haveHelpRequest: true,
                  myLocation: myLatLng,
                ),
              ),
            )
        ],
      ),
      floatingActionButton: SpeedDial(
        /// both default to 16
        marginEnd: 18,
        marginBottom: 20,
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0),

        /// This is ignored if animatedIcon is non null
        // icon: Icons.menu,
        // activeIcon: Icons.close,
        // iconTheme: IconThemeData(color: Colors.grey[50], size: 30),

        /// Transition Builder between label and activeLabel, defaults to FadeTransition.
        // labelTransitionBuilder: (widget, animation) =>
        //     ScaleTransition(scale: animation, child: widget),

        /// The below button size defaults to 56 itself, its the FAB size + It also affects relative padding and other elements
        buttonSize: 56.0,
        visible: true,

        /// If true user is forced to close dial manually
        /// by tapping main button and overlay is not rendered.
        closeManually: false,

        /// If true overlay will render no matter what.
        renderOverlay: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        onOpen: () => print('OPENING DIAL'),
        onClose: () => print('DIAL CLOSED'),
        tooltip: 'Chức năng',
        heroTag: 'speed-dial-hero-tag',
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 8.0,
        shape: CircleBorder(),
        // orientation: SpeedDialOrientation.Down,
        // childMarginBottom: 2,
        // childMarginTop: 2,
        children: [
          SpeedDialChild(
            child: Icon(Icons.place),
            backgroundColor: Colors.orange,
            label: 'Chỉ đường',
            labelStyle: TextStyle(fontSize: 16.0, color: Colors.black),
            labelBackgroundColor: Colors.white,
            onTap: () => Navigator.pushNamed(context, '/route-page'),
            onLongPress: () => print('FIRST CHILD LONG PRESS'),
          ),
          SpeedDialChild(
            child: Icon(Icons.call),
            backgroundColor: Colors.orange,
            label: 'Gọi trợ giúp',
            labelStyle: TextStyle(fontSize: 16.0, color: Colors.black),
            labelBackgroundColor: Colors.white,
            onTap: () {
              Alert(
                  context: context,
                  title: "YÊU CẦU TRỢ GIÚP",
                  content: _createHelpPopup,
                  closeIcon: Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                  style: AlertStyle(
                    animationType: AnimationType.grow,
                    isCloseButton: true,
                    isOverlayTapDismiss: false,
                    descStyle: TextStyle(fontWeight: FontWeight.bold),
                    descTextAlign: TextAlign.start,
                    overlayColor: Colors.black54,
                    animationDuration: Duration(milliseconds: 300),
                    alertBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(
                        color: Colors.green,
                      ),
                    ),
                    titleStyle: TextStyle(
                      color: Colors.green,
                    ),
                    alertAlignment: Alignment.center,
                  ),
                  buttons: [
                    DialogButton(
                      onPressed: () {
                        if (_createHelpPopup.formKey.currentState.validate()) {
                          _createHelpPopup.requestModel.createAt =
                              Timestamp.now();
                          FirebaseFirestore.instance
                              .collection('requests')
                              .doc(appState.user.userId)
                              .set(_createHelpPopup.requestModel.toJson())
                              .then((value) {
                            Navigator.of(context).pop();
                            Alert(
                              context: context,
                              title: "Thông báo",
                              type: AlertType.success,
                              style: AlertStyle(isCloseButton: false),
                              content: Text('Tạo yêu cầu trợ giúp thành công'),
                              buttons: [
                                DialogButton(
                                    child: Text(
                                      'Đóng',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    color: Colors.green)
                              ],
                            ).show();
                          }).catchError((error) => Alert(
                                      context: context,
                                      title: "Thông báo",
                                      type: AlertType.error,
                                      style: AlertStyle(isCloseButton: false),
                                      content: Text(
                                          'Tạo yêu cầu trợ giúp thất bại. Lý do: $error'),
                                      buttons: [
                                        DialogButton(
                                            child: Text(
                                              'Đóng',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16),
                                            ),
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            color: Colors.red)
                                      ]).show());
                          //RequestAPI.addRequestDB(_createHelpPopup.requestModel)
                        }
                      },
                      child: Text(
                        "Tạo yêu cầu",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      color: Colors.green,
                    )
                  ]).show();
            },
            onLongPress: () => print('SECOND CHILD LONG PRESS'),
          ),
          SpeedDialChild(
            child: Icon(Icons.gps_fixed),
            backgroundColor: Colors.orange,
            label: 'Cập nhật vị trí',
            labelStyle: TextStyle(fontSize: 16.0, color: Colors.black),
            labelBackgroundColor: Colors.white,
            onTap: () => _getCurrentLocation(),
            onLongPress: () => print('SECOND CHILD LONG PRESS'),
          ),
        ],
      ),
    );
  }
}
