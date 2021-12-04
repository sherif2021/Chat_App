part of 'video_calling_bloc.dart';

@immutable
abstract class VideoCallingEvent {}

class CallingCloseEvent extends VideoCallingEvent {
  final bool byRemoteUser;

  CallingCloseEvent(this.byRemoteUser);
}

class CallingAcceptEvent extends VideoCallingEvent {}

class CallingStartEvent extends VideoCallingEvent {}
class CallingCancelEvent extends VideoCallingEvent {}

class CallingDataEvent extends VideoCallingEvent {
  final String event;
  final dynamic payload;

  CallingDataEvent({required this.event, required this.payload});
}