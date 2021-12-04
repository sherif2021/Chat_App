import 'dart:convert';
import 'package:chat/utility/constants.dart';
import 'package:http/http.dart' as http;

class AuthApiService {
  Future<Map<String, dynamic>?> login(
      {required String uid, required String phoneNumber}) async {
    try {
      final result = await http.post(Uri.parse(apiBaseURL + 'login'),
          body: {'uid': uid, 'phoneNumber': phoneNumber},
          headers: {'apikey': apiKey});
      if (result.statusCode != 200) return null;
      return JsonDecoder().convert(result.body);
    } catch (e) {
      return null;
    }
  }
}
