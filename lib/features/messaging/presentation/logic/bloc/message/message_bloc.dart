import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:chat/features/messaging/data/model/attachment_model.dart';
import 'package:chat/features/messaging/data/model/message_model.dart';
import 'package:chat/features/messaging/data/model/user_model.dart';
import 'package:chat/features/messaging/repository/messaging_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:meta/meta.dart';
import 'package:collection/collection.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

part 'message_event.dart';

part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {

  final MessagingRepository messagingRepository;

  final List<String> _sendingSeenMessages = [];

  final keyboardVisibilityController = KeyboardVisibilityController();
  late StreamSubscription<bool> keyboardVisibilityStream;

  final itemScrollController = ItemScrollController();
  final itemPositionsListener = ItemPositionsListener.create();

  List<MessageModel> _messages = [];
  List<String> images = [];
  bool _isSendingSeen = false;
  bool _isSeenAllMessages = false;
  bool isEmojiShow = false;

  MessageBloc({required UserModel user, required this.messagingRepository})
      : super(MessageInitial()) {

    loadMessages( user);
    keyboardVisibilityStream =
        keyboardVisibilityController.onChange.listen((bool visible) {
      if (visible && isEmojiShow) add(EmojiEvent(show: false));
    });

    itemPositionsListener.itemPositions.addListener(() {
      _handleSeenMessages(user.uid);
    });

  }

  @override
  Future<void> close() {
    keyboardVisibilityStream.cancel();
    return super.close();
  }

  @override
  Stream<MessageState> mapEventToState(
    MessageEvent event,
  ) async* {
    if (event is EmojiEvent) {
      isEmojiShow = event.show;
      emit(EmojiChangeState(show: event.show));
    }

    if (event is ChangeImagesSelectedEvent) emit(ChangeImagesSelectedState());
  }

  void loadMessages(UserModel user) async{

    final messages = await messagingRepository.getAllMessages(uid: user.uid);
      _messages = messages;

      int initialScrollIndex = 0;

      if (_messages.length > 0 &&
          (_messages.last.me || _messages.last.seen != null))
        initialScrollIndex = _messages.length - 1;
      else {
        final lastSeenMessage =
            _messages.lastIndexWhere((e) => !e.me && e.seen != null);
        if (lastSeenMessage > -1) initialScrollIndex = lastSeenMessage;
      }
      emit(MessagesLoadedState(
          messages: _messages, initialScrollIndex: initialScrollIndex));

    final userInfo = await messagingRepository.getUserInfoByApi(user.uid);

    if (userInfo != null && userInfo.uid == user.uid &&(userInfo.name != user.name || userInfo.pic != user.pic)){
        user.name = userInfo.name;
        user.pic = userInfo.pic;
        emit(UserInfoChangedState(user.uid));
        messagingRepository.updateUserInDB(user);
    }
  }

  Future<MessageModel> sendMessage(
      {required String token,
      required UserModel receiver,
      required String text}) async {
    final message = MessageModel(
        uid: receiver.uid,
        text: text,
        me: true,
        seen: false,
        sent: false,
        time: DateTime.now().toLocal(),
        attachments:
            images.map((e) => AttachmentModel(type: 1, path: e)).toList());

    if (images.isNotEmpty) {
      images.clear();
      emit(ChangeImagesSelectedState());
    }

    _messages.add(message);
    emit(MessagesLoadedState(messages: _messages, initialScrollIndex: 0));

    if (_messages.length > 3)
      itemScrollController.scrollTo(
          index: _messages.length - 1, duration: Duration(milliseconds: 300));

    message.index = (await messagingRepository.saveMessages([message])).first;
    messagingRepository.sendMessages(messages: [message]);

    return message;
  }

  void addMessage({required MessageModel messageModel}) {
    _messages.add(messageModel);

    emit(MessagesLoadedState(messages: _messages, initialScrollIndex: 0));

    if (_isSeenAllMessages && _messages.length > 3 && _messages[itemPositionsListener.itemPositions.value.last.index] == _messages[_messages.length - 2]) {
      itemScrollController.scrollTo(index: _messages.length - 1, duration: Duration(milliseconds: 300));
    }
    _isSendingSeen = false;
    _isSeenAllMessages = false;
  }

  void messageUpdateData(
      {required int index,
      required String id,
      bool? isSent,
      bool? isSeen,
      int? time}) {
    MessageModel? message =
        _messages.firstWhereOrNull((e) => e.index == index || id == e.id);

    if (message != null) {
      message.id = id;
      message.sent = isSent ?? message.sent;
      message.seen = isSeen ?? message.seen;
      if (time != null)
        message.time =
            DateTime.fromMillisecondsSinceEpoch(time, isUtc: true).toLocal();
      emit(MessagesLoadedState(messages: _messages, initialScrollIndex: 0));
    }
  }

  void removeSendingSeen({required List<String> ids, required String userUID}) {
    _sendingSeenMessages.removeWhere((e) => ids.contains(e));
    _isSendingSeen = false;
    if (_sendingSeenMessages.isNotEmpty)
      messagingRepository
          .sendSeenStatus(status: {userUID: _sendingSeenMessages});
  }

  void _handleSeenMessages(String userUID) {
    if (!_isSeenAllMessages) {
      final List<String> unSeenMessages = [];

      itemPositionsListener.itemPositions.value.forEach((item) {
        final MessageModel? message = _messages[item.index];
        if (message != null &&
            !message.me &&
            message.seen == null &&
            !_sendingSeenMessages.contains(message.id!)) {
          message.seen = false;
          unSeenMessages.add(message.id!);
        }
        if (item.index == _messages.length - 1) _isSeenAllMessages = true;
      });

      if (unSeenMessages.isNotEmpty) {
        messagingRepository.updateMessagesSeenStatus(
            ids: unSeenMessages, seen: false);
        _sendingSeenMessages.addAll(unSeenMessages);
      }
      if (_sendingSeenMessages.isNotEmpty && !_isSendingSeen) {
        messagingRepository
            .sendSeenStatus(status: {userUID: _sendingSeenMessages});
        _isSendingSeen = true;
      }
    }
  }
}
