part of 'home_bloc.dart';

@immutable
abstract class HomeEvent {}

class ConnectWithWebServerEvent extends HomeEvent {
  final String uid;
  final String token;

  ConnectWithWebServerEvent({required this.uid, required this.token});
}

class SearchingStatusEvent extends HomeEvent {}

class UserInfoChangedEvent extends HomeEvent {
  final String user;

  UserInfoChangedEvent(this.user);
}

class UpdateLastMessageEvent extends HomeEvent {
  final MessageModel message;

  UpdateLastMessageEvent(this.message);
}

class SearchEvent extends HomeEvent {
  final String currentUserUID;

  final String value;

  SearchEvent({required this.value, required this.currentUserUID});
}

class DisConnectWithWebServerEvent extends HomeEvent {}

class LoadUsersEvent extends HomeEvent {}
