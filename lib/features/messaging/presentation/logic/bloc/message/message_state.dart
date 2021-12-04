part of 'message_bloc.dart';

@immutable
abstract class MessageState {}

class MessageInitial extends MessageState {}

class MessagesLoadedState extends MessageState {
  final List<MessageModel> messages;
  final int initialScrollIndex;

  MessagesLoadedState(
      {required this.messages, required this.initialScrollIndex});
}

class UserInfoChangedState extends MessageState {
  final String user;

  UserInfoChangedState(this.user);
}

class EmojiChangeState extends MessageState {
  final bool show;

  EmojiChangeState({required this.show});
}

class ChangeImagesSelectedState extends MessageState {}
