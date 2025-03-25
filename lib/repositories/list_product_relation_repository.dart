import '../models/list_product_relation/list_product_relation.dart';
import '../services/database/database_helper.dart';

class ListProductRelationRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  static const String _tableName = 'ListProductRelation';

  Future<int> insertRelation(ListProductRelation relation) async {
    Map<String, dynamic> row = relation.toJson();

    row['is_checked'] = relation.isChecked ? 1 : 0;
    row.remove('isChecked');

    if (row['createdAt'] != null) {
      row['created_at'] = row['createdAt'].toString();
    }
    row.remove('createdAt');

    row['list_id'] = row['listId'];
    row.remove('listId');
    row['product_id'] = row['productId'];
    row.remove('productId');

    return await _databaseHelper.insert(_tableName, row);
  }

  Future<ListProductRelation?> getRelation(int listId, int productId) async {
    List<Map<String, dynamic>> maps = await _databaseHelper.query(
      _tableName,
      where: 'list_id = ? AND product_id = ?',
      whereArgs: [listId, productId],
    );

    if (maps.isEmpty) {
      return null;
    }

    return _mapToRelation(maps.first);
  }

  Future<List<ListProductRelation>> getRelationsByListId(int listId) async {
    List<Map<String, dynamic>> maps = await _databaseHelper.query(
      _tableName,
      where: 'list_id = ?',
      whereArgs: [listId],
      orderBy: 'position ASC',
    );

    return maps.map((map) => _mapToRelation(map)).toList();
  }

  Future<int> updateRelation(ListProductRelation relation) async {
    Map<String, dynamic> row = relation.toJson();

    row['is_checked'] = relation.isChecked ? 1 : 0;
    row.remove('isChecked');

    if (row['createdAt'] != null) {
      row['created_at'] = row['createdAt'].toString();
    }
    row.remove('createdAt');

    row['list_id'] = row['listId'];
    row.remove('listId');
    row['product_id'] = row['productId'];
    row.remove('productId');

    return await _databaseHelper.update(
      _tableName,
      row,
      'list_id = ? AND product_id = ?',
      [relation.listId, relation.productId],
    );
  }

  Future<int> deleteRelation(int listId, int productId) async {
    return await _databaseHelper.delete(
      _tableName,
      'list_id = ? AND product_id = ?',
      [listId, productId],
    );
  }

  Future<int> deleteAllRelationsForList(int listId) async {
    return await _databaseHelper.delete(_tableName, 'list_id = ?', [listId]);
  }

  ListProductRelation _mapToRelation(Map<String, dynamic> map) {
    map['listId'] = map['list_id'];
    map['productId'] = map['product_id'];
    map['isChecked'] = map['is_checked'] == 1;

    if (map['created_at'] != null) {
      map['createdAt'] = DateTime.parse(map['created_at']);
    }

    return ListProductRelation.fromJson(map);
  }
}
