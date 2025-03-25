import '../models/user/user.dart';
import '../services/database/database_helper.dart';

class UserRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  static const String _tableName = 'Users';

  Future<int> insertUser(User user) async {
    Map<String, dynamic> row = user.toJson();
    if (row['id'] == null) {
      row.remove('id');
    }
    if (row['createdAt'] != null) {
      row['created_at'] = row['createdAt'].toString();
    }
    row.remove('createdAt');

    return await _databaseHelper.insert(_tableName, row);
  }

  Future<User?> getUserById(int id) async {
    List<Map<String, dynamic>> maps = await _databaseHelper.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    Map<String, dynamic> userMap = maps.first;
    userMap['createdAt'] =
        userMap['created_at'] != null
            ? DateTime.parse(userMap['created_at'])
            : null;
    userMap['passwordHash'] = userMap['password_hash'];

    return User.fromJson(userMap);
  }

  Future<User?> getUserByEmail(String email) async {
    List<Map<String, dynamic>> maps = await _databaseHelper.query(
      _tableName,
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isEmpty) {
      return null;
    }

    Map<String, dynamic> userMap = maps.first;
    userMap['createdAt'] =
        userMap['created_at'] != null
            ? DateTime.parse(userMap['created_at'])
            : null;
    userMap['passwordHash'] = userMap['password_hash'];

    return User.fromJson(userMap);
  }

  Future<List<User>> getAllUsers() async {
    List<Map<String, dynamic>> maps = await _databaseHelper.queryAll(
      _tableName,
    );

    return maps.map((map) {
      map['createdAt'] =
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null;
      map['passwordHash'] = map['password_hash'];
      return User.fromJson(map);
    }).toList();
  }

  Future<int> updateUser(User user) async {
    Map<String, dynamic> row = user.toJson();
    if (row['createdAt'] != null) {
      row['created_at'] = row['createdAt'].toString();
    }
    row.remove('createdAt');
    row['password_hash'] = row['passwordHash'];
    row.remove('passwordHash');

    return await _databaseHelper.update(_tableName, row, 'id = ?', [user.id]);
  }

  Future<int> deleteUser(int id) async {
    return await _databaseHelper.delete(_tableName, 'id = ?', [id]);
  }
}
