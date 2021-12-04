import 'package:chat/features/messaging/data/model/user_model.dart';
import 'package:chat/core/app_database.dart';
import 'package:chat/utility/constants.dart';

class UserDatabase {
  Future<List<UserModel>> getAllUsers({int? limit}) async {
    final db = await AppDatabase.getInstance();
    final result = await db.query(userTable, limit: limit);
    return result.map((e) => UserModel.fromMap(e)).toList();
  }

  Future<bool> isUserExist(String uid) async {
    final db = await AppDatabase.getInstance();
    return (await db.query(userTable, where: 'uid = ?', whereArgs: [uid]))
            .length >
        0;
  }

  Future<int> insertUser(UserModel userModel) async {
    final db = await AppDatabase.getInstance();
    return await db.insert(userTable, userModel.toMap());
  }

  Future<bool> updateUser(UserModel userModel) async {
    final db = await AppDatabase.getInstance();
    return ( await db.update(userTable, userModel.toMap(),where: 'uid = ?', whereArgs: [userModel.uid])) > -1;
  }
}
