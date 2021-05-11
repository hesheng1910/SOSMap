import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sosmap/models/request.dart';
import 'package:sosmap/models/user.dart';
import 'package:wemapgl/wemapgl.dart';

class CreateHelpPopup extends StatelessWidget {
  CreateHelpPopup({Key key, this.userModel}) : super(key: key);
  final TextEditingController _typeLocationController = TextEditingController();
  final TextEditingController _typeReasonController = TextEditingController();
  UserModel userModel;
  String _selectedPlaceName;
  String _reason;
  List<String> reasonS = [
    'Gặp tai nạn',
    'Hỏng phương tiện',
    'Thời tiết xấu',
    'Khác'
  ];
  WeMapSearchAPI searchAPI = WeMapSearchAPI();
  Timer t;
  LatLng latLng = new LatLng(20.037, 105.7876);
  RequestModel requestModel;
  @override
  Widget build(BuildContext context) {
    requestModel = RequestModel(
        user: userModel, name: userModel.fullName, tel: userModel.tel);
    return Column(
      children: <Widget>[
        TextField(
            decoration: InputDecoration(
                icon: Icon(
                  Icons.account_circle,
                  color: Colors.grey,
                ),
                labelText: 'Tên người cần giúp',
                labelStyle: TextStyle(color: Colors.grey)),
            controller: TextEditingController(text: userModel.fullName),
            onChanged: (value) => {requestModel.name = value}),
        TextField(
          decoration: InputDecoration(
            icon: Icon(
              Icons.phone,
              color: Colors.grey,
            ),
            labelText: 'Số điện thoại',
            labelStyle: TextStyle(color: Colors.grey),
          ),
          controller: TextEditingController(text: userModel.tel),
          keyboardType: TextInputType.phone,
          onChanged: (value) => {requestModel.tel = value},
        ),
        TypeAheadFormField(
          textFieldConfiguration: TextFieldConfiguration(
            controller: this._typeLocationController,
            decoration: InputDecoration(
              icon: Icon(
                Icons.gps_fixed,
                color: Colors.grey,
              ),
              labelText: 'Vị trí',
              labelStyle: TextStyle(color: Colors.grey),
              suffixIcon: IconButton(
                onPressed: () {
                  this._typeLocationController.clear();
                  requestModel.lat = null;
                  requestModel.lng = null;
                },
                icon: Icon(
                  Icons.clear_outlined,
                  color: Colors.black,
                ),
                iconSize: 18,
              ),
            ),
          ),
          hideSuggestionsOnKeyboardHide: false,
          hideOnEmpty: true,
          suggestionsCallback: (pattern) async {
            return await searchAPI.getSearchResult(
                pattern, latLng, WeMapGeocoder.Pelias);
          },
          itemBuilder: (context, WeMapPlace suggestion) {
            return ListTile(
              title: Text(suggestion.placeName),
            );
          },
          transitionBuilder: (context, suggestionsBox, controller) {
            return FadeTransition(
              child: suggestionsBox,
              opacity: CurvedAnimation(
                  parent: controller, curve: Curves.fastOutSlowIn),
            );
          },
          onSuggestionSelected: (WeMapPlace suggestion) {
            this._typeLocationController.text = suggestion.placeName;
            requestModel.lat = suggestion.location.latitude;
            requestModel.lng = suggestion.location.longitude;
          },
          validator: (value) => value.isEmpty ? 'Chọn vị trí của bạn' : null,
          onSaved: (value) => this._selectedPlaceName = value,
        ),
        TypeAheadFormField(
          textFieldConfiguration: TextFieldConfiguration(
            controller: this._typeReasonController,
            decoration: InputDecoration(
              icon: Icon(
                Icons.warning,
                color: Colors.grey,
              ),
              labelText: 'Vấn đề đang gặp',
              labelStyle: TextStyle(color: Colors.grey),
            ),
          ),
          hideSuggestionsOnKeyboardHide: false,
          hideKeyboard: true,
          suggestionsCallback: (pattern) {
            return reasonS;
          },
          itemBuilder: (context, suggestion) {
            return ListTile(
              title: Text(suggestion),
            );
          },
          transitionBuilder: (context, suggestionsBox, controller) {
            return FadeTransition(
              child: suggestionsBox,
              opacity: CurvedAnimation(
                  parent: controller, curve: Curves.fastOutSlowIn),
            );
          },
          onSuggestionSelected: (suggestion) {
            this._typeReasonController.text = suggestion;
          },
          validator: (value) => value.isEmpty ? 'Chọn vấn đề đang gặp' : null,
          onSaved: (value) => requestModel.reason = value,
        ),
        TextField(
          decoration: InputDecoration(
            icon: Icon(
              Icons.edit,
              color: Colors.grey,
            ),
            labelText: 'Lời nhắn',
            labelStyle: TextStyle(color: Colors.grey),
          ),
          controller: TextEditingController(text: ''),
          maxLines: 10,
          minLines: 1,
          onChanged: (value) => requestModel.message = value,
        ),
      ],
    );
  }
}
