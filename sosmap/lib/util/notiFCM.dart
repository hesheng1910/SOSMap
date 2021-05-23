import 'dart:convert';
import 'package:http/http.dart' as http;

class NotiFCM {
  static String constructFCMPayload(
      String token, String title, String message, String type) {
    return jsonEncode({
      'token': token,
      'notification': {
        'title': title,
        'body': message,
      },
      'data': {'type': type},
    });
  }

  static Future<void> sendPushMessage(
      String token, String title, String message, String type) async {
    try {
      await http.post(
        Uri.parse('https://sosmap.herokuapp.com/api/fcm/sosmap'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: constructFCMPayload(token, title, message, type),
      );
      print('FCM request for device sent!');
    } catch (e) {
      print(e);
    }
  }
}
