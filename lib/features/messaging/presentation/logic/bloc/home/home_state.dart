part of 'home_bloc.dart';

@immutable
abstract class HomeState {}

class HomeInitial extends HomeState {}

class LoadUsersState extends HomeState {
  final List<UserModel> users;

  LoadUsersState({required this.users});
}

class UpdateUserDataState extends HomeState {
  final String uid;

  UpdateUserDataState( this.uid);
}

class SearchingStatusState extends HomeState {}

class SearchResultState extends HomeState {
  final List<UserModel> result;

  SearchResultState(this.result);
}

class SessionExpiredState extends HomeState {}

class UpdateMessageDataStata extends HomeState {
  final int index;
  final String id;
  final bool? isSent;
  final bool? isSeen;
  final int? time;

  UpdateMessageDataStata(
      {required this.index,
      required this.id,
      this.isSeen,
      this.isSent,
      this.time});
}

class SendingSeenDoneState extends HomeState {
  final List<String> ids;

  SendingSeenDoneState({required this.ids});
}

class NewMessageState extends HomeState {
  final MessageModel messageModel;

  NewMessageState({required this.messageModel});
}

class RequestVideoCallingState extends HomeState {
  final String uid;
  final String name;
  final String pic;

  RequestVideoCallingState(
      {required this.uid, required this.name, required this.pic});
}

class AcceptingVideoCallingState extends HomeState {
  final String uid;

  AcceptingVideoCallingState({required this.uid});
}

class CloseVideoCallingState extends HomeState {
  final String uid;

  CloseVideoCallingState({required this.uid});
}

class CancelVideoCallingState extends HomeState {
  final String uid;

  CancelVideoCallingState({required this.uid});
}

class OnVideoCallingDataState extends HomeState {
  final String uid;
  final String event;
  final dynamic payload;

  OnVideoCallingDataState(
      {required this.uid, required this.event, required this.payload});
}
