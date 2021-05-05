import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
// To parse this JSON data, do
//
//     final settings = settingsFromJson(jsonString);

SettingModels settingsFromJson(String str) {
  final jsonData = json.decode(str);
  return SettingModels.fromJson(jsonData);
}

String settingsToJson(SettingModels data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class SettingModels {
  String settingsId;

  SettingModels({
    this.settingsId,
  });

  factory SettingModels.fromJson(Map<String, dynamic> json) =>
      new SettingModels(
        settingsId: json["settingsId"],
      );

  Map<String, dynamic> toJson() => {
        "settingsId": settingsId,
      };

  factory SettingModels.fromDocument(DocumentSnapshot doc) {
    return SettingModels.fromJson(doc.data());
  }
}
