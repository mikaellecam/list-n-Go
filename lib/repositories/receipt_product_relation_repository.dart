import '../models/receipt_product_relation/receipt_product_relation.dart';
import '../services/database/database_helper.dart';

class ReceiptProductRelationRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  static const String _tableName = 'ReceiptProductRelation';

  Future<int> insertRelation(ReceiptProductRelation relation) async {
    Map<String, dynamic> row = relation.toJson();

    if (row['createdAt'] != null) {
      row['created_at'] = row['createdAt'].toString();
    }
    row.remove('createdAt');

    row['receipt_id'] = row['receiptId'];
    row.remove('receiptId');
    row['product_id'] = row['productId'];
    row.remove('productId');

    return await _databaseHelper.insert(_tableName, row);
  }

  Future<ReceiptProductRelation?> getRelation(
    int receiptId,
    int productId,
  ) async {
    List<Map<String, dynamic>> maps = await _databaseHelper.query(
      _tableName,
      where: 'receipt_id = ? AND product_id = ?',
      whereArgs: [receiptId, productId],
    );

    if (maps.isEmpty) {
      return null;
    }

    return _mapToRelation(maps.first);
  }

  Future<List<ReceiptProductRelation>> getRelationsByReceiptId(
    int receiptId,
  ) async {
    List<Map<String, dynamic>> maps = await _databaseHelper.query(
      _tableName,
      where: 'receipt_id = ?',
      whereArgs: [receiptId],
      orderBy: 'position ASC',
    );

    return maps.map((map) => _mapToRelation(map)).toList();
  }

  Future<int> updateRelation(ReceiptProductRelation relation) async {
    Map<String, dynamic> row = relation.toJson();

    if (row['createdAt'] != null) {
      row['created_at'] = row['createdAt'].toString();
    }
    row.remove('createdAt');

    row['receipt_id'] = row['receiptId'];
    row.remove('receiptId');
    row['product_id'] = row['productId'];
    row.remove('productId');

    return await _databaseHelper.update(
      _tableName,
      row,
      'receipt_id = ? AND product_id = ?',
      [relation.receiptId, relation.productId],
    );
  }

  Future<int> deleteRelation(int receiptId, int productId) async {
    return await _databaseHelper.delete(
      _tableName,
      'receipt_id = ? AND product_id = ?',
      [receiptId, productId],
    );
  }

  Future<int> deleteAllRelationsForReceipt(int receiptId) async {
    return await _databaseHelper.delete(_tableName, 'receipt_id = ?', [
      receiptId,
    ]);
  }

  ReceiptProductRelation _mapToRelation(Map<String, dynamic> map) {
    map['receiptId'] = map['receipt_id'];
    map['productId'] = map['product_id'];

    if (map['created_at'] != null) {
      map['createdAt'] = DateTime.parse(map['created_at']);
    }

    return ReceiptProductRelation.fromJson(map);
  }
}
