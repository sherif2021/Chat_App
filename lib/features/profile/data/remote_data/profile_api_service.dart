import 'dart:convert';
import 'package:chat/utility/constants.dart';
import 'package:http/http.dart' as http;

class ProfileApiService {
  Future<Map<String, dynamic>?> getProfileData({required String uid}) async {
    try {
      final result = await http.get(Uri.parse(apiBaseURL + 'profile/$uid'),
          headers: {'apikey': apiKey});
      if (result.statusCode != 200) return null;
      return JsonDecoder().convert(result.body);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> setProfileData(
      {required String uid,
      required String token,
      required Map<String, dynamic> data}) async {
    try {
      final result = await http.post(
        Uri.parse(apiBaseURL + 'profile'),
        body: data,
        headers: {'apikey': apiKey, 'uid': uid, 'token': token},
      );
      if (result.statusCode != 200) return null;
      return JsonDecoder().convert(result.body);
    } catch (e) {
      return null;
    }
  }
}
