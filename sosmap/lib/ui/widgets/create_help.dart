import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sosmap/models/request.dart';
import 'package:sosmap/models/user.dart';
import 'package:wemapgl/wemapgl.dart';
import 'package:intl/intl.dart';

class CreateHelpPopup extends StatelessWidget {
  CreateHelpPopup({Key key, this.userModel}) : super(key: key);
  final formKey = GlobalKey<FormState>();
  final TextEditingController _typeLocationController = TextEditingController();
  final TextEditingController _typeReasonController = TextEditingController();
  final TextEditingController _typeMoneyController =
      new MaskedTextController(mask: '000.000.000');
  UserModel userModel;
  String _selectedPlaceName;
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
    var formatter = NumberFormat('###,###,000');

    requestModel = RequestModel(
        userId: userModel.userId, name: userModel.fullName, tel: userModel.tel);
    return Form(
      key: formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty)
                  return "Trường này là bắt buộc";
                return null;
              },
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.account_circle),
                  labelText: 'Tên người cần giúp',
                  labelStyle: TextStyle(color: Colors.grey)),
              controller: TextEditingController(text: userModel.fullName),
              onChanged: (value) => {requestModel.name = value}),
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty)
                return "Trường này là bắt buộc";
              return null;
            },
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.phone),
              labelText: 'Số điện thoại',
              labelStyle: TextStyle(color: Colors.grey),
            ),
            controller: TextEditingController(text: userModel.tel),
            keyboardType: TextInputType.phone,
            maxLength: 11,
            buildCounter: (BuildContext context,
                    {int currentLength, int maxLength, bool isFocused}) =>
                null,
            onChanged: (value) => {requestModel.tel = value},
          ),
          TypeAheadFormField(
            textFieldConfiguration: TextFieldConfiguration(
              controller: this._typeLocationController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.gps_fixed),
                labelText: 'Vị trí',
                labelStyle: TextStyle(color: Colors.grey),
                suffixIcon: IconButton(
                  onPressed: () {
                    this._typeLocationController.clear();
                    requestModel.place = null;
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
              requestModel.place = suggestion;
            },
            validator: (value) {
              if (value.isEmpty) return 'Chọn vị trí của bạn';
              if (requestModel.place == null) return 'Vị trí không hợp lệ';
              return null;
            },
            onSaved: (value) => this._selectedPlaceName = value,
          ),
          TypeAheadFormField(
            textFieldConfiguration: TextFieldConfiguration(
              controller: this._typeReasonController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.warning),
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
              requestModel.reason = suggestion;
            },
            validator: (value) => value.isEmpty ? 'Chọn vấn đề đang gặp' : null,
            onSaved: (value) => requestModel.reason = value,
          ),
          TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.message),
              labelText: 'Lời nhắn',
              labelStyle: TextStyle(color: Colors.grey),
            ),
            controller: TextEditingController(text: ''),
            maxLines: 10,
            minLines: 1,
            onChanged: (value) => requestModel.message = value,
          ),
          TextField(
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.money),
                labelText: 'Phí giúp đỡ',
                labelStyle: TextStyle(color: Colors.grey),
                suffixText: 'VND',
                hintText: 'Miễn phí',
                hintStyle: const TextStyle(color: Colors.grey),
                suffixStyle: const TextStyle(color: Colors.green)),
            controller: _typeMoneyController,
            keyboardType: TextInputType.number,
            maxLength: 11,
            buildCounter: (BuildContext context,
                    {int currentLength, int maxLength, bool isFocused}) =>
                null,
            onChanged: (value) =>
                {requestModel.price = value.replaceAll(RegExp('[.]'), '')},
          ),
        ],
      ),
    );
  }
}
