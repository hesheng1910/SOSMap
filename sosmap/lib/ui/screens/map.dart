import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sosmap/models/request.dart';
import 'package:sosmap/models/user.dart';
import 'package:sosmap/ui/widgets/card_infomation.dart';
import 'package:sosmap/wemap/ePage.dart';
import 'package:wemapgl/wemapgl.dart';

import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class FullMapPage extends EPage {
  FullMapPage() : super(const Icon(Icons.map), 'Full screen map');

  @override
  Widget build(BuildContext context) {
    return const FullMap();
  }
}

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

  WeMapController mapController;
  CameraPosition _position = _kInitialPosition;
  bool _isMoving = false;
  bool _compassEnabled = true;
  CameraTargetBounds _cameraTargetBounds = CameraTargetBounds.unbounded;
  MinMaxZoomPreference _minMaxZoomPreference = MinMaxZoomPreference.unbounded;
  String _styleString = WeMapStyles.WEMAP_VECTOR_STYLE;
  bool _rotateGesturesEnabled = true;
  bool _scrollGesturesEnabled = true;
  bool _tiltGesturesEnabled = true;
  bool _zoomGesturesEnabled = true;
  bool _myLocationEnabled = true;
  MyLocationTrackingMode _myLocationTrackingMode =
      MyLocationTrackingMode.Tracking;

  LatLng myLatLng = LatLng(21.038282, 105.782885);
  bool reverse = true;
  WeMapPlace place;

  int _symbolCount = 0;
  Symbol _selectedSymbol;

  List<RequestModel> listUser = [
    RequestModel(
        user: UserModel(firstName: 'User1', tel: '123456', rate: 2.6),
        lat: 21.038282,
        lng: 105.782885,
        reason: "Tai nạn",
        message: "Tôi đang bị tai nạn, hãy đến giúp tôi",
        createAt: DateTime(2021, 5, 8, 17, 30)),
    RequestModel(
        user: UserModel(firstName: 'User2', tel: '0886151242'),
        lat: 21.138282,
        lng: 105.982885,
        reason: "Hỏng xe",
        message: "Tôi đang bị hỏng xe, hãy đến giúp tôi",
        createAt: DateTime(2021, 5, 9, 17, 30)),
  ];

  void onMapCreated(WeMapController controller) {
    mapController = controller;
    listUser.forEach((user) {
      _add(LatLng(user.lat, user.lng), user.toJson());
    });
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

  void _remove() {
    mapController.removeSymbol(_selectedSymbol);
    setState(() {
      _selectedSymbol = null;
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
    final WeMap weMap = WeMap(
        onMapCreated: onMapCreated,
        initialCameraPosition: _kInitialPosition,
        trackCameraPosition: true,
        compassEnabled: _compassEnabled,
        cameraTargetBounds: _cameraTargetBounds,
        minMaxZoomPreference: _minMaxZoomPreference,
        styleString: _styleString,
        rotateGesturesEnabled: _rotateGesturesEnabled,
        scrollGesturesEnabled: _scrollGesturesEnabled,
        tiltGesturesEnabled: _tiltGesturesEnabled,
        zoomGesturesEnabled: _zoomGesturesEnabled,
        myLocationEnabled: _myLocationEnabled,
        myLocationTrackingMode: _myLocationTrackingMode,
        myLocationRenderMode: MyLocationRenderMode.GPS,
        reverse: true,
        onPlaceCardClose: () => print("close card"),
        onMapClick: (point, latlng, place) {
          print(point);
          _onUnSelectedSymbol();
        },
        onCameraTrackingDismissed: () {
          this.setState(() {
            _myLocationTrackingMode = MyLocationTrackingMode.None;
          });
        });

    return new Scaffold(
      body: Stack(
        children: <Widget>[
          weMap,
          if (_selectedSymbol != null)
            new Container(
              alignment: Alignment.center,
              child: CardInfomation(
                requestModel: RequestModel.fromJson(_selectedSymbol.data),
                onCloseBtn: _onUnSelectedSymbol,
                onOpenMapBtn: () {
                  setState(() {
                    listUser[0].user.rate = Random().nextDouble() * 5;
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
            onTap: () => print('SECOND CHILD'),
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
