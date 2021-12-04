import 'package:chat/features/profile/data/model/profile_model.dart';
import 'package:chat/features/profile/data/remote_data/profile_api_service.dart';

class ProfileRepository {
  final _profileApiService = ProfileApiService();

  Future<ProfileModel?> getProfileData({required String uid}) async {
    final result = await _profileApiService.getProfileData(uid: uid);
    return result == null ? null : ProfileModel.fromMap(result);
  }

  Future<bool> setProfileData(
      {required String uid,
      required String token,
      required ProfileModel profileModel}) async {
    return await _profileApiService.setProfileData(
                uid: uid, token: token, data: profileModel.toMap()) !=
            null
        ? true
        : false;
  }
}
