import 'package:flutter/material.dart';

import '../models/product_list/product_list.dart';
import '../services/database/database_helper.dart';

class ProductListRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  static const String _tableName = 'Lists';

  Future<int> insertList(ProductList list) async {
    debugPrint('Inserting list: $list');
    Map<String, dynamic> row = Map<String, dynamic>.from(list.toJson());
    debugPrint('Inserting row: $row');

    if (row['createdAt'] != null && row['createdAt'] is DateTime) {
      row['created_at'] = (row['createdAt'] as DateTime).toIso8601String();
      row.remove('createdAt');
    } else if (row['createdAt'] != null) {
      row['created_at'] = row['createdAt'].toString();
      row.remove('createdAt');
    }

    if (row['updatedAt'] != null && row['updatedAt'] is DateTime) {
      row['updated_at'] = (row['updatedAt'] as DateTime).toIso8601String();
      row.remove('updatedAt');
    } else if (row['updatedAt'] != null) {
      row['updated_at'] = row['updatedAt'].toString();
      row.remove('updatedAt');
    }

    if (row['id'] == null) {
      row.remove('id');
    }

    if (row['userId'] != null) {
      row['user_id'] = row['userId'];
      row.remove('userId');
    }

    debugPrint('Row after processing: $row');

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

  Future<ProductList?> getListByName(String name) async {
    List<Map<String, dynamic>> maps = await _databaseHelper.query(
      _tableName,
      where: 'name = ?',
      whereArgs: [name],
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
    Map<String, dynamic> row = Map<String, dynamic>.from(list.toJson());

    row['updated_at'] = DateTime.now().toIso8601String();
    row.remove('updatedAt');

    if (row['createdAt'] != null && row['createdAt'] is DateTime) {
      row['created_at'] = (row['createdAt'] as DateTime).toIso8601String();
      row.remove('createdAt');
    } else if (row['createdAt'] != null) {
      row['created_at'] = row['createdAt'].toString();
      row.remove('createdAt');
    }

    if (row['userId'] != null) {
      row['user_id'] = row['userId'];
      row.remove('userId');
    }

    row.remove('id');

    debugPrint('Updating row: $row');
    return await _databaseHelper.update(_tableName, row, 'id = ?', [list.id]);
  }

  Future<int> deleteList(int id) async {
    return await _databaseHelper.delete(_tableName, 'id = ?', [id]);
  }

  ProductList _mapToProductList(Map<String, dynamic> map) {
    final mutableMap = Map<String, dynamic>.from(map);

    if (mutableMap.containsKey('user_id')) {
      mutableMap['userId'] = mutableMap['user_id'];
      mutableMap.remove('user_id');
    }

    if (mutableMap.containsKey('created_at')) {
      mutableMap['createdAt'] = mutableMap['created_at'];
      mutableMap.remove('created_at');
    }

    if (mutableMap.containsKey('updated_at')) {
      mutableMap['updatedAt'] = mutableMap['updated_at'];
      mutableMap.remove('updated_at');
    }

    try {
      return ProductList.fromJson(mutableMap);
    } catch (e) {
      debugPrint("Error details: $e");
      rethrow;
    }
  }
}
