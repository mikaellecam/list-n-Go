import '../models/product_list/product_list.dart';
import '../services/database/database_helper.dart';

class ProductListRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  static const String _tableName = 'Lists';

  Future<int> insertList(ProductList list) async {
    Map<String, dynamic> row = list.toJson();
    if (row['id'] == null) {
      row.remove('id');
    }

    if (row['createdAt'] != null) {
      row['created_at'] = row['createdAt'].toString();
    }
    row.remove('createdAt');

    if (row['updatedAt'] != null) {
      row['updated_at'] = row['updatedAt'].toString();
    }
    row.remove('updatedAt');

    row['user_id'] = row['userId'];
    row.remove('userId');

    return await _databaseHelper.insert(_tableName, row);
  }

  Future<ProductList?> getListById(int id) async {
    List<Map<String, dynamic>> maps = await _databaseHelper.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    return _mapToProductList(maps.first);
  }

  Future<List<ProductList>> getListsByUserId(int userId) async {
    List<Map<String, dynamic>> maps = await _databaseHelper.query(
      _tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
    );

    return maps.map((map) => _mapToProductList(map)).toList();
  }

  Future<List<ProductList>> getAllLists() async {
    List<Map<String, dynamic>> maps = await _databaseHelper.queryAll(
      _tableName,
    );

    return maps.map((map) => _mapToProductList(map)).toList();
  }

  Future<int> updateList(ProductList list) async {
    Map<String, dynamic> row = list.toJson();

    DateTime now = DateTime.now();
    row['updated_at'] = now.toString();
    row.remove('updatedAt');

    if (row['createdAt'] != null) {
      row['created_at'] = row['createdAt'].toString();
    }
    row.remove('createdAt');

    row['user_id'] = row['userId'];
    row.remove('userId');

    return await _databaseHelper.update(_tableName, row, 'id = ?', [list.id]);
  }

  Future<int> deleteList(int id) async {
    return await _databaseHelper.delete(_tableName, 'id = ?', [id]);
  }

  ProductList _mapToProductList(Map<String, dynamic> map) {
    map['userId'] = map['user_id'];

    if (map['created_at'] != null) {
      map['createdAt'] = DateTime.parse(map['created_at']);
    }
    if (map['updated_at'] != null) {
      map['updatedAt'] = DateTime.parse(map['updated_at']);
    }

    return ProductList.fromJson(map);
  }
}
