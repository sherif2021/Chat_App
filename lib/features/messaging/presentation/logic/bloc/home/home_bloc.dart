import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:chat/features/messaging/data/model/message_model.dart';
import 'package:chat/features/messaging/data/model/user_model.dart';
import 'package:chat/features/messaging/repository/messaging_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meta/meta.dart';
import 'package:collection/collection.dart';

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final MessagingRepository messagingRepository;

  List<UserModel> _users = [];

  bool isSearching = false;
  bool isInMessageScreen = false;

  HomeBloc({required this.messagingRepository}) : super(HomeInitial());

  @override
  Stream<HomeState> mapEventToState(
    HomeEvent event,
  ) async* {
    if (event is ConnectWithWebServerEvent) {
      messagingRepository.connectWithWebServer(
          uid: event.uid,
          token: event.token,
          onServerData: onServerData,
          onSessionExpired: onSessionExpired);
    }

    if (event is DisConnectWithWebServerEvent) {
      messagingRepository.disConnectWithWebServer();
    }
    if (event is SearchingStatusEvent) {
      emit(SearchingStatusState());
      emit(LoadUsersState(users: _users));
    }

    if (event is SearchEvent) {
      final searchResult = await messagingRepository.search(event.value);

      if (searchResult != null)
        emit(SearchResultState(
            searchResult.where((e) => e.uid != event.currentUserUID).toList()));
    }
    if (event is UpdateLastMessageEvent) {
      updateLastMessage(event.message);
    }
    if (event is UserInfoChangedEvent){
       emit(UpdateUserDataState( event.user));
    }

    if (event is LoadUsersEvent) {
      final users = await messagingRepository.getAllUsers();
      _users = users;
      emit(LoadUsersState(users: _users));
    }
  }

  void onServerData(String val) async {
    try {
      final value = JsonDecoder().convert(val);

      switch (value['type']) {
        case 'sent':
          final messages = value['data'] as List;
          messages.forEach((msg) {
            final index = msg['i'];
            final id = msg['id'];
            final time = msg['time'];
            messagingRepository.updateMessageIdTime(
                index: index, id: id, time: time);
            emit(UpdateMessageDataStata(id: id, index: index, time: time));
          });
          if (messages.length == 100) messagingRepository.sendStoredMessages();
          break;

        case 'new':
          final messages = (value['data'] as List)
              .map((e) => MessageModel.fromJson(e))
              .toList();

          final Map<String, List<String>> sendStatus = {};

          messagingRepository.saveMessages(messages);

          messages.forEach((e) {
            if (!sendStatus.containsKey(e.uid)) sendStatus[e.uid] = [];
            sendStatus[e.uid]?.add(e.id!);
            emit(NewMessageState(messageModel: e));
          });

          messagingRepository.sendSentStatus(status: sendStatus);

          messages.forEach((e) async {
            await updateLastMessage(e);
          });

          break;

        case 'isSent':
          final List<String> ids = List.from(value['data']);
          messagingRepository.updateMessagesSentStatus(ids: ids, sent: true);
          ids.forEach((e) =>
              emit(UpdateMessageDataStata(index: -1, id: e, isSent: true)));
          messagingRepository.confirmSentStatus(ids: ids);
          break;

        case 'sentConfirm':
          final List<String> ids = List.from(value['data']);
          messagingRepository.updateMessagesSentStatus(ids: ids, sent: true);
          if (ids.length == 1000) messagingRepository.sendStoredSentStatus();
          break;

        case 'isSeen':
          final List<String> ids = List.from(value['data']);
          messagingRepository.updateMessagesSeenStatus(ids: ids, seen: true);
          ids.forEach((e) =>
              emit(UpdateMessageDataStata(index: -1, id: e, isSeen: true)));
          messagingRepository.confirmSeenStatus(ids: ids);
          break;

        case 'seenConfirm':
          final List<String> ids = List.from(value['data']);
          messagingRepository.updateMessagesSeenStatus(ids: ids, seen: true);
          emit(SendingSeenDoneState(ids: ids));
          if (ids.length == 1000) messagingRepository.sendStoredSeenStatus();
          break;

        case 'requestVideoCalling':
          String pic = value['data']['pic'];
          if (!pic.startsWith('http'))
            pic = await FirebaseStorage.instance
                .ref()
                .child(pic)
                .getDownloadURL();

          emit(RequestVideoCallingState(
              uid: value['data']['uid'],
              name: value['data']['name'],
              pic: pic));
          break;
        case 'closeVideoCalling':
          emit(CloseVideoCallingState(uid: value['data']));
          break;

        case 'cancelVideoCalling':
          emit(CancelVideoCallingState(uid: value['data']));
          break;

        case 'acceptingVideoCalling':
          emit(AcceptingVideoCallingState(uid: value['data']));
          break;

        case 'videoCallingData':
          emit(OnVideoCallingDataState(
              uid: value['data']['uid'],
              event: value['data']['event'],
              payload: value['data']['payload']));
          break;
      }
    } catch (e) {}
  }

  void onSessionExpired() {
    emit(SessionExpiredState());
  }

  UserModel? getUser(String uid) {
    return _users.firstWhereOrNull((e) => e.uid == uid);
  }

  Future<UserModel?> loadUserInfo(String uid) async {
    final userInfo = await messagingRepository.getUserInfoByApi(uid);

    if (userInfo != null) {
      if (_users.firstWhereOrNull((e) => e.uid == userInfo.uid) == null)
        _users.add(userInfo);

      if (!(await messagingRepository.isUserExistInDatabase(userInfo.uid)))
        messagingRepository.addUserInDB(userInfo);

      if (!isSearching) emit(LoadUsersState(users: _users));
      return userInfo;
    }
    return null;
  }

  Future<void> updateLastMessage(MessageModel message) async {
    UserModel? user = _users.firstWhereOrNull((e) => e.uid == message.uid);

    if (user == null) user = await loadUserInfo(message.uid);

    if (user != null &&
        (user.lastMessage == null ||
            message.time.isAfter(user.lastMessage!.time))) {
      user.lastMessage = message;
      emit(UpdateUserDataState( user.uid));
    }
  }
}
