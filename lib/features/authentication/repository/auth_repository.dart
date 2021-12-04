import 'package:chat/features/authentication/data/model/UserModel.dart';
import 'package:chat/features/authentication/data/remote_data/auth_api_service.dart';

class AuthRepository {
  final _authApiService = AuthApiService();

  Future<AuthUserModel?> login(
      {required String uid, required String phoneNumber}) async {
    final result =
        await _authApiService.login(uid: uid, phoneNumber: phoneNumber);

    return result == null ? null : AuthUserModel.fromMap(result);
  }
}
