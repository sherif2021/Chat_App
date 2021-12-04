part of 'video_calling_bloc.dart';

@immutable
abstract class VideoCallingState {}

class CallingInitialState extends VideoCallingState {}

class CallingWaitingState extends VideoCallingState {}

class CallingRingingState extends VideoCallingState {}

class CallingOfflineState extends VideoCallingState {}

class CallingErrorState extends VideoCallingState {}

class CallingBusyState extends VideoCallingState {}

class CallingCancelingState extends VideoCallingState {}

class CallingCloseState extends VideoCallingState {
  final bool byRemoteUser;

  CallingCloseState(this.byRemoteUser);
}

class CallingIsActiveState extends VideoCallingState {}
