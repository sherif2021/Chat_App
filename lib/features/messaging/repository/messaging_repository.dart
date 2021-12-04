import 'dart:convert';
import 'dart:io';
import 'package:chat/features/messaging/data/local_data/message_db.dart';
import 'package:chat/features/messaging/data/local_data/user_db.dart';
import 'package:chat/features/messaging/data/model/message_model.dart';
import 'package:chat/utility/custom_websocket.dart';
import 'package:chat/features/messaging/data/remote_data/messaging_api_service.dart';
import 'package:chat/utility/constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:chat/features/messaging/data/model/user_model.dart';
import 'package:collection/collection.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class MessagingRepository {
  final _messagingApiService = MessagingApiService();
  final _userDB = UserDatabase();
  final _messageDB = MessageDatabase();
  final List<int> uploadingMessageAttachments = [];

  bool allMessagesSent = false, allSent = false, allSeen = false;
  String? _uid, _token;

  CustomWebSocket? _customWebSocket;

  Future<void> connectWithWebServer(
      {required String uid,
      required String token,
      required Function(String val) onServerData,
      required Function onSessionExpired}) async {
    if (_customWebSocket != null)
      _customWebSocket?.forcingConnect();
    else {
      _uid = uid;
      _token = token;
      _customWebSocket = CustomWebSocket(
          url: webServerURL,
          onData: onServerData,
          onOpen: loadStoredData,
          onSessionExpired: onSessionExpired,
          headers: {
            'apikey': apiKey,
            'uid': uid,
            'token': token,
            'fcmToken': await FirebaseMessaging.instance.getToken()
          })
        ..connect();

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        _customWebSocket?.headers['fcmToken'] = newToken;
        _customWebSocket?.forcingClose();
        _customWebSocket?.forcingConnect();
      });
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    return await _userDB.getAllUsers();
  }

  Future<List<MessageModel>> getAllMessages({required String uid}) async {
    return await _messageDB.getAllMessages(uid: uid);
  }

  // for test
  Future<void> deleteAllMessages({required String uid}) async {
    await _messageDB.deleteAllMessages(uid: uid);
  }

  Future<List<int>> saveMessages(List<MessageModel> messages) async {
    return await _messageDB.saveMessages(messages);
  }

  Future<void> sendMessages({required List<MessageModel> messages}) async {
    messages.forEach((e) async {
      if (e.attachments.firstWhereOrNull((e) => e.url == null) != null &&
          !uploadingMessageAttachments.contains(e.index)) {
        uploadingMessageAttachments.add(e.index!);

        while ((await _uploadAttachments(e)) == false)
          await Future.delayed(Duration(seconds: 5));

        uploadingMessageAttachments.remove(e.index!);
        sendMessages(messages: [e]);
      }
    });

    final acceptMessages = messages.map((e) {
      if (!uploadingMessageAttachments.contains(e.index!)) return e.toJson();
    }).toList();

    if (acceptMessages.isNotEmpty)
      _sendData({'type': 'send', 'data': acceptMessages});
  }

  Future<bool> _uploadAttachments(MessageModel message) async {
    bool status = false;

    message.attachments.removeWhere((attachment) =>
        attachment.path.isEmpty || !File(attachment.path).existsSync());

    for (int i = 0; i < message.attachments.length; i++) {
      final attachment = message.attachments[i];

      try {
        if (attachment.url == null || attachment.url!.isEmpty) {
          final filePath = 'pics/${Uuid().v4()}.jpg';
          final uploadResult = await FirebaseStorage.instance
              .ref()
              .child(filePath)
              .putFile(File(attachment.path));

          if (uploadResult.totalBytes == uploadResult.bytesTransferred) {
            attachment.url =
                await FirebaseStorage.instance.ref(filePath).getDownloadURL();
            attachment.path = "";
            await _messageDB.updateMessage(message);
            status = true;
          }
        }
      } catch (e) {}
    }
    return status;
  }

  void sendSentStatus({required Map<String, List<String>> status}) {
    _sendData({'type': 'sendStatus', 'data': status});
  }

  void confirmSentStatus({required List<String> ids}) {
    _sendData({'type': 'sentConfirm', 'data': ids});
  }

  void sendSeenStatus({required Map<String, List<String>> status}) {
    _sendData({'type': 'seenStatus', 'data': status});
  }

  void confirmSeenStatus({required List<String> ids}) {
    _sendData({'type': 'seenConfirm', 'data': ids});
  }

  Future<void> updateMessageIdTime(
      {required int index, required String id, required int time}) async {
    await _messageDB.updateMessageIdTime(index: index, id: id, time: time);
  }

  Future<void> updateMessagesSentStatus(
      {required List<String> ids, required bool? sent}) async {
    await _messageDB.updateMessagesSentStatus(ids: ids, sent: sent);
  }

  Future<void> updateMessagesSeenStatus(
      {required List<String> ids, required bool? seen}) async {
    await _messageDB.updateMessagesSeenStatus(ids: ids, seen: seen);
  }

  Future<void> loadStoredData() async {
    allMessagesSent = false;
    allSent = false;
    allSeen = false;

    sendStoredMessages();
    sendStoredSeenStatus();
    sendStoredSentStatus();
  }

  Future<void> sendStoredMessages() async {
    final messages = await _messageDB.getStoredMessages();
    if (messages.isNotEmpty) sendMessages(messages: messages);
    if (messages.length < 100) allMessagesSent = true;
    if (allMessagesSent && allSent && allSeen) _sendUserIsReady();
  }

  Future<void> sendStoredSeenStatus() async {
    final result = await _messageDB.getStoredSeenMessages();
    final Map<String, List<String>> status = {};
    result.forEach((e) {
      if (!status.containsKey(e['uid'])) status[e['uid']] = [];
      status[e['uid']]!.add(e['id']);
    });
    if (status.isNotEmpty) sendSeenStatus(status: status);

    if (result.length < 1000) allSeen = true;
    if (allMessagesSent && allSent && allSeen) _sendUserIsReady();
  }

  Future<void> sendStoredSentStatus() async {
    final result = await _messageDB.getStoredSentMessages();
    final Map<String, List<String>> status = {};
    result.forEach((e) {
      if (!status.containsKey(e[e['uid']])) status[e['uid']] = [];
      status[e['uid']]!.add(e['id']);
    });
    if (status.isNotEmpty) sendSentStatus(status: status);
    if (result.length < 1000) allSent = true;
    if (allMessagesSent && allSent && allSeen) _sendUserIsReady();
  }

  void _sendUserIsReady() {
    _sendData({'type': 'ready'});
  }

  ///        VIDEO CALLIng        ////
  Future<String?> requestVideoCalling({required String caller}) async {
    return await _messagingApiService.requestVideoCalling(
        uid: _uid!, token: _token!, caller: caller);
  }

  void sendAcceptVideoCalling({required String uid}) {
    _sendData({'type': 'acceptVideoCalling', 'data': uid});
  }

  void sendCloseVideoCalling({required String uid}) {
    _sendData({'type': 'closeVideoCalling', 'data': uid});
  }

  void sendCancelVideoCalling({required String uid}) {
    _sendData({'type': 'cancelVideoCalling', 'data': uid});
  }

  void sendVideoCallingData({required dynamic data}) {
    _sendData({'type': 'onVideoCallingData', 'data': data});
  }

  ///        VIDEO CALLIng        ////

  Future<List<UserModel>?> search(String value) async {
    return await _messagingApiService.search(value);
  }

  Future<bool> isUserExistInDatabase(String uid) async {
    return await _userDB.isUserExist(uid);
  }

  Future<bool> addUserInDB(UserModel userModel) async {
    final result = await _userDB.insertUser(userModel);
    if (result > -1) {
      userModel.index = result;
      return true;
    }
    return false;
  }

  Future<bool> updateUserInDB(UserModel userModel) async {
    return await _userDB.updateUser(userModel);
  }

  Future<UserModel?> getUserInfoByApi(String uid) async {
    return await _messagingApiService.getUserInfo(uid);
  }

  void disConnectWithWebServer() {
    _customWebSocket?.forcingClose();
  }

  void _sendData(Map<String, dynamic> data) {
    if (_customWebSocket != null)
      _customWebSocket?.sendData(JsonEncoder().convert(data));
  }
}
