import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sosmap/models/request.dart';
import 'package:sosmap/models/state.dart';
import 'package:sosmap/ui/widgets/card_infomation.dart';
import 'package:sosmap/ui/widgets/create_help.dart';
import 'package:sosmap/util/state_widget.dart';
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

  LatLng myLatLng = LatLng(21.038282, 105.782885);
  bool reverse = true;
  WeMapPlace place;

  int _symbolCount = 0;
  Symbol _selectedSymbol;
  @override
  void initState() {
    _position = _kInitialPosition;
    _isMoving = false;
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
      onStyleLoadedCallback: () => print('map style loaded'),
      // myLocationTrackingMode: _myLocationTrackingMode,
      // myLocationRenderMode: MyLocationRenderMode.GPS,
      reverse: false,
      // onPlaceCardClose: () => print("close card"),
      // onMapClick: (point, latlng, place) {
      //   print(point);
      //   _onUnSelectedSymbol();
      // },
      // onCameraTrackingDismissed: () {
      //   this.setState(() {
      //     _myLocationTrackingMode = MyLocationTrackingMode.None;
      //   });
      // }
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
    setState(() {
      _extractMapInfo();
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
    await mapController.addSymbol(
        SymbolOptions(
          geometry: latlng,
          iconImage: "assets/symbols/help.png",
        ),
        requestData);
    setState(() {
      _symbolCount += 1;
    });
  }

  void _remove(Symbol symbol) {
    mapController.removeSymbol(symbol);
    setState(() {
      _symbolCount -= 1;
    });
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
  }

  @override
  Widget build(BuildContext context) {
    appState = StateWidget.of(context).state;
    final _createHelpPopup = CreateHelpPopup(userModel: appState.user);

    // if (mapController != null &&
    //     mapController.symbols != null &&
    //     mapController.symbols.length > 0)
    //   mapController.symbols.forEach((element) {
    //     _remove(element);
    //   });

    CollectionReference requestModels =
        FirebaseFirestore.instance.collection('requests');
    requestModels.snapshots().listen((result) {
      result.docs.forEach((request) {
        RequestModel requestData = RequestModel.fromJson(request.data());
        if (mapController.symbols.firstWhere(
                (element) =>
                    element.data["lat"] == requestData.lat &&
                    element.data["lng"] == requestData.lng,
                orElse: () => null) ==
            null)
          _add(LatLng(requestData.lat, requestData.lng), requestData.toJson());
      });
    });

    return new Scaffold(
      body: Stack(
        children: <Widget>[
          if (weMap != null) weMap,
          if (_selectedSymbol != null)
            new Container(
              alignment: Alignment.center,
              child: CardInfomation(
                requestModel: RequestModel.fromJson(_selectedSymbol.data),
                onCloseBtn: _onUnSelectedSymbol,
                onOpenMapBtn: () {
                  setState(() {
                    //listUser[0].user.rate = Random().nextDouble() * 5;
                  });
                },
                onConfirmBtn: () => {},
              ),
            ),
          WeMapSearchBar(
            location: myLatLng,
            onSelected: (_place) {
              setState(() {
                place = _place;
                print(_place.placeName);
              });
              mapController.moveCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: place.location,
                    zoom: 14.0,
                  ),
                ),
              );
              mapController.showPlaceCard?.call(place);
            },
            onClearInput: () {
              setState(() {
                place = null;
                //mapController.showPlaceCard(place);
              });
            },
          ),
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
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => Navigator.pushNamed(context, '/route-page'),
            onLongPress: () => print('FIRST CHILD LONG PRESS'),
          ),
          SpeedDialChild(
            child: Icon(Icons.call),
            backgroundColor: Colors.orange,
            label: 'Gọi trợ giúp',
            labelStyle: TextStyle(fontSize: 18.0),
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
                      onPressed: () => {
                        FirebaseFirestore.instance
                            .collection('requests')
                            .doc()
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
                                  onPressed: () => Navigator.of(context).pop(),
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
                                    ]).show())
                        //RequestAPI.addRequestDB(_createHelpPopup.requestModel)
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
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => _getCurrentLocation(),
            onLongPress: () => print('SECOND CHILD LONG PRESS'),
          ),
        ],
      ),
    );
  }
}
