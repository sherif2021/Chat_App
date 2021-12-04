import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:chat/features/profile/data/model/profile_model.dart';
import 'package:chat/features/profile/repository/profile_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository profileRepository;

  late ProfileModel profile;

  ProfileCubit({required this.profileRepository})
      : super(ProfileInitialState());

  Future<void> changeValue({
    String? name,
    String? picUrl,
    String? picPath,
    bool? onlineEnable,
    bool? notificationEnable,
    required String uid,
    required String token,
  }) async {
    profile = profile.copyWith(
        name: name,
        picUrl: picUrl,
        picPath: picPath,
        notificationEnable: notificationEnable,
        onlineEnable: onlineEnable);

    final result = await profileRepository.setProfileData(
        uid: uid, token: token, profileModel: profile);

    emit(ProfileChangedDataState(
        status: result,
        name: name,
        notification: notificationEnable,
        online: onlineEnable,
        picUrl: picUrl));
  }

  void getProfileData({required String uid}) async {
    emit(ProfileLoadingState());

    final result = await profileRepository.getProfileData(uid: uid);
    if (result != null) {
      profile = result;

      emit(ProfileFetchedState());
    } else
      emit(ProfileFieldToFetchState());
  }

  void changeProfilePic(
      {required String filePath,
      required String uid,
      required String token}) async {
    final file = File(filePath);

    if (file.existsSync()) {
      final newPath = 'pics/${Uuid().v4()}.jpg';

      await FirebaseStorage.instance.ref().child(newPath).putFile(file);
      final picUrl =
          await FirebaseStorage.instance.ref().child(newPath).getDownloadURL();

      if (profile.picPath != null && profile.picPath!.isNotEmpty)
        try {
          await FirebaseStorage.instance.ref(profile.picPath).delete();
        } catch (e) {}

      await changeValue(
          picPath: newPath, picUrl: picUrl, uid: uid, token: token);
    }
  }
}
