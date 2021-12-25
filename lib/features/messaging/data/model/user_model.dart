import 'dart:math';
import 'dart:ui';

import 'package:chat/features/messaging/data/model/message_model.dart';

class UserModel {
  int? index;
  final String uid;
  String name;
  String? pic;
  DateTime? lastSeen;
  MessageModel? lastMessage;
  late final Color picColor;

  UserModel(
      {this.index,
      required this.uid,
      required this.name,
      this.pic,
      this.lastSeen,
      this.lastMessage}) {
    picColor =
        Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  }

  UserModel copyWith(
      {int? index,
      String? uid,
      String? name,
      String? pic,
      DateTime? lastSeen,
      MessageModel? lastMessage}) {
    return UserModel(
      index: index ?? this.index,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      pic: pic ?? this.pic,
      lastSeen: lastSeen ?? this.lastSeen,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        index: map['i'] as int?,
        uid: map['uid'] as String,
        name: map['name'] as String,
        pic: map['pic'] as String?,
        lastSeen: map['lastSeen'] != 0
            ? DateTime.fromMillisecondsSinceEpoch(map['lastSeen'] as int,
                isUtc: true)
            : null,
      );

  Map<String, dynamic> toMap() => {
        'i': this.index,
        'uid': this.uid,
        'name': this.name,
        'pic': this.pic,
        'lastSeen': this.lastSeen != null
            ? this.lastSeen!.toUtc().millisecondsSinceEpoch
            : 0
      };
}
