import 'dart:convert';

import 'package:chat/features/messaging/data/model/message_model.dart';
import 'package:chat/core/app_database.dart';
import 'package:chat/utility/constants.dart';

class MessageDatabase {
  Future<List<int>> saveMessages(List<MessageModel> messages) async {
    final db = await AppDatabase.getInstance();
    final batch = db.batch();
    messages.forEach((message) => batch.insert(messageTable, message.toMap()));
    return (await batch.commit()).cast();
  }

  Future<List<MessageModel>> getAllMessages({required String uid}) async {
    final db = await AppDatabase.getInstance();
    return (await db.query(messageTable, where: 'uid = ?', whereArgs: [uid]))
        .map((e) => MessageModel.fromMap(e))
        .toList();
  }

  Future<List<MessageModel>> getStoredMessages() async {
    final db = await AppDatabase.getInstance();
    return (await db.query(messageTable,
            where: 'me = 1 AND id = ""', limit: 100))
        .map((e) => MessageModel.fromMap(e))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getStoredSeenMessages() async {
    final db = await AppDatabase.getInstance();
    return await db.query(messageTable,
        where: 'me = 0 AND seen = 0', columns: ['uid', 'id'], limit: 1000);
  }

  Future<List<Map<String, dynamic>>> getStoredSentMessages() async {
    final db = await AppDatabase.getInstance();
    return await db.query(messageTable,
        where: 'me = 0 AND sent = 0', columns: ['uid', 'id'], limit: 1000);
  }

  Future<void> deleteAllMessages({required String uid}) async {
    final db = await AppDatabase.getInstance();
    db.delete(messageTable, where: 'uid = ?', whereArgs: [uid]);
  }

  Future<void> updateMessageIdTime(
      {required int index, required String id, required int time}) async {
    final db = await AppDatabase.getInstance();
    db.update(messageTable, {'id': id, 'time': time},
        where: 'i = ?', whereArgs: [index]);
  }

  Future<void> updateMessagesSentStatus(
      {required List<String> ids, required bool? sent}) async {
    final db = await AppDatabase.getInstance();
    final joinedIds = ids.join('", "');
    await db.rawUpdate(
        'UPDATE $messageTable SET sent = ${sent != null ? sent ? 1 : 0 : null} WHERE id IN ("$joinedIds")');
  }

  Future<void> updateMessagesSeenStatus(
      {required List<String> ids, required bool? seen}) async {
    final db = await AppDatabase.getInstance();
    final joinedIds = ids.join('", "');
    await db.rawUpdate(
        'UPDATE $messageTable SET seen = ${seen != null ? seen ? 1 : 0 : null} WHERE id IN ("$joinedIds")');
  }

  Future<void> updateMessage(MessageModel message) async{
    final db = await AppDatabase.getInstance();

    await db.update(messageTable, message.toMap(), where: "i = ?", whereArgs: [message.index]);

  }
}
