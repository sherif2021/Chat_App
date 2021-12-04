part of 'profile_cubit.dart';

@immutable
abstract class ProfileState {}

class ProfileInitialState extends ProfileState {}

class ProfileLoadingState extends ProfileState {}

class ProfileFieldToFetchState extends ProfileState {}

class ProfileFetchedState extends ProfileState {}

class ProfileChangedDataState extends ProfileState {
  final bool status;
  final String? name;
  final String? picUrl;
  final bool? notification;
  final bool? online;

  ProfileChangedDataState(
      {required this.status,
      this.name,
      this.picUrl,
      this.notification,
      this.online});
}
