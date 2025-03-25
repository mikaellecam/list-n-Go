import '../models/receipt/receipt.dart';
import '../services/database/database_helper.dart';

class ReceiptRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  static const String _tableName = 'Receipt';

  Future<int> insertReceipt(Receipt receipt) async {
    Map<String, dynamic> row = receipt.toJson();
    if (row['id'] == null) {
      row.remove('id');
    }

    if (row['createdAt'] != null) {
      row['created_at'] = row['createdAt'].toString();
    }
    row.remove('createdAt');

    row['user_id'] = row['userId'];
    row.remove('userId');

    return await _databaseHelper.insert(_tableName, row);
  }

  Future<Receipt?> getReceiptById(int id) async {
    List<Map<String, dynamic>> maps = await _databaseHelper.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    return _mapToReceipt(maps.first);
  }

  Future<List<Receipt>> getReceiptsByUserId(int userId) async {
    List<Map<String, dynamic>> maps = await _databaseHelper.query(
      _tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => _mapToReceipt(map)).toList();
  }

  Future<List<Receipt>> getAllReceipts() async {
    List<Map<String, dynamic>> maps = await _databaseHelper.queryAll(
      _tableName,
    );

    return maps.map((map) => _mapToReceipt(map)).toList();
  }

  Future<int> updateReceipt(Receipt receipt) async {
    Map<String, dynamic> row = receipt.toJson();

    if (row['createdAt'] != null) {
      row['created_at'] = row['createdAt'].toString();
    }
    row.remove('createdAt');

    row['user_id'] = row['userId'];
    row.remove('userId');

    return await _databaseHelper.update(_tableName, row, 'id = ?', [
      receipt.id,
    ]);
  }

  Future<int> deleteReceipt(int id) async {
    return await _databaseHelper.delete(_tableName, 'id = ?', [id]);
  }

  Receipt _mapToReceipt(Map<String, dynamic> map) {
    map['userId'] = map['user_id'];

    if (map['created_at'] != null) {
      map['createdAt'] = DateTime.parse(map['created_at']);
    }

    return Receipt.fromJson(map);
  }
}
