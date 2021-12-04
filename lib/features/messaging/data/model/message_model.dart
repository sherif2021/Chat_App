import 'dart:convert';

import 'package:chat/features/messaging/data/model/attachment_model.dart';

class MessageModel {
  int? index;
  final String uid;
  final String text;

  String? id;

  bool me;
  bool sent = false;
  bool? seen;
  DateTime time;

  List<AttachmentModel> attachments;

  bool textOverFlow = false;

  MessageModel(
      {this.index,
      this.id,
      required this.uid,
      required this.text,
      required this.me,
      required this.sent,
      required this.time,
      this.seen,
      required this.attachments});

  factory MessageModel.fromMap(Map<String, dynamic> map) => MessageModel(
      index: map['i'] as int?,
      uid: map['uid'],
      text: map['text'],
      id: map['id'],
      me: map['me'] == 1,
      sent: map['sent'] == 1,
      seen: map['seen'] != null ? map['seen'] == 1 : null,
      time: DateTime.fromMillisecondsSinceEpoch(map['time'] as int, isUtc: true)
          .toLocal(),
      attachments: map['attach'] != null && (map['attach'] as String).length > 0
          ? (JsonDecoder().convert(map['attach']) as List)
              .map((e) => AttachmentModel.fromMap(e))
              .toList()
          : []);

  Map<String, dynamic> toMap() => {
        'i': this.index,
        'uid': this.uid,
        'text': this.text,
        'id': this.id ?? '',
        'me': this.me ? 1 : 0,
        'sent': this.sent ? 1 : 0,
        'seen': this.seen != null
            ? this.seen!
                ? 1
                : 0
            : null,
        'time': this.time.toUtc().millisecondsSinceEpoch,
        'attach': JsonEncoder()
            .convert(this.attachments.map((e) => e.toMap()).toList())
      };

  Map<String, dynamic> toJson() => {
        'to': this.uid,
        'text': this.text,
        'i': this.index,
        'attach': this.attachments.map((e) => e.toJson()).toList()
      };

  factory MessageModel.fromJson(Map<String, dynamic> map) => MessageModel(
        uid: map['uid'],
        text: map['text'],
        id: map['id'],
        time:
            DateTime.fromMillisecondsSinceEpoch(map['time'] as int, isUtc: true)
                .toLocal(),
        attachments: map['attach'] != null && (map['attach'] as List).length > 0
            ? (map['attach'] as List)
                .map((e) => AttachmentModel.fromJson(e))
                .toList()
            : [],
        sent: false,
        me: false,
      );
}
