part of 'message_bloc.dart';

@immutable
abstract class MessageEvent {}

class EmojiEvent extends MessageEvent {
  final bool show;

  EmojiEvent({required this.show});
}

class ChangeImagesSelectedEvent extends MessageEvent {}
