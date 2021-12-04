import 'dart:convert';
import 'package:chat/features/messaging/data/model/user_model.dart';
import 'package:chat/utility/constants.dart';
import 'package:http/http.dart' as http;

class MessagingApiService {
  Future<String?> requestVideoCalling(
      {required String uid,
      required String token,
      required String caller}) async {
    try {
      final result = await http.post(Uri.parse(apiBaseURL + 'videoCalling'),
          body: {'caller': caller},
          headers: {'apikey': apiKey, 'uid': uid, 'token': token});

      if (result.statusCode == 200)
        return JsonDecoder().convert(result.body)['status'];
      else
        return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<UserModel>?> search(String value) async {
    final result = await http.post(Uri.parse(apiBaseURL + 'search'),
        body: {'value': value}, headers: {'apikey': apiKey});

    if (result.statusCode == 200 && result.body.length > 2)
      return (JsonDecoder().convert(result.body) as List)
          .map((e) => UserModel.fromMap(e))
          .toList();
    else
      return null;
  }
  Future<UserModel?> getUserInfo(String uid) async{
    final result = await http.get(Uri.parse(apiBaseURL + 'info/$uid'), headers: {'apikey': apiKey});
    if (result.statusCode == 200) return UserModel.fromMap(JsonDecoder().convert(result.body));
    return null;
  }
}
