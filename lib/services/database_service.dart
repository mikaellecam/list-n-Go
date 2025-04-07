import 'dart:async';
import 'dart:io';

import 'package:listngo/models/product_list/product_list.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static DatabaseService get instance => _instance;

  static Database? _database;

  static const String _databaseName = 'listngo.db';

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        barcode INTEGER,
        name TEXT NOT NULL,
        keywords TEXT,
        price REAL,
        type TEXT,
        date TEXT,
        image_path TEXT,
        nutri_score TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE VIEW LatestProducts AS
      SELECT p.*
      FROM Products p
      JOIN (
        SELECT barcode, MAX(date) as latest_date
        FROM Products
        GROUP BY barcode
      ) latest ON p.barcode = latest.barcode AND p.date = latest.latest_date
    ''');

    await db.execute('''
      CREATE TABLE Lists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE ListProductRelation (
        list_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity REAL NOT NULL DEFAULT 1,
        price REAL,
        is_checked INTEGER DEFAULT 0,
        position INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (list_id, product_id),
        FOREIGN KEY (list_id) REFERENCES Lists (id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES Products (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE Receipt (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        price REAL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE ReceiptProductRelation (
        receipt_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity REAL NOT NULL DEFAULT 1,
        price REAL,
        position INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (receipt_id, product_id),
        FOREIGN KEY (receipt_id) REFERENCES Receipt (id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES Products (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<int> insert(String table, Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    Database db = await instance.database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
  }) async {
    Database db = await instance.database;
    return await db.query(
      table,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> row,
    String where,
    List<dynamic> whereArgs,
  ) async {
    Database db = await instance.database;
    return await db.update(table, row, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table,
    String where,
    List<dynamic> whereArgs,
  ) async {
    Database db = await instance.database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<int> clear(String table) async {
    Database db = await instance.database;
    return await db.delete(table);
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<List<ProductList>> getAllProductLists() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Lists',
      orderBy: 'updated_at DESC',
    );
    return maps.map((map) => _mapDbToProductList(map)).toList();
  }

  Future<ProductList?> getProductListById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Lists',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return _mapDbToProductList(maps.first);
  }

  Future<int> insertProductList(ProductList list) async {
    final db = await database;
    return await db.insert('Lists', _mapProductListToDb(list));
  }

  Future<int> updateProductList(ProductList list) async {
    final db = await database;
    return await db.update(
      'Lists',
      _mapProductListToDb(list),
      where: 'id = ?',
      whereArgs: [list.id],
    );
  }

  Future<int> deleteProductList(int id) async {
    final db = await database;
    return await db.delete('Lists', where: 'id = ?', whereArgs: [id]);
  }

  Map<String, dynamic> _mapProductListToDb(ProductList list) {
    final map = <String, dynamic>{
      'name': list.name,
      'created_at': list.createdAt.toIso8601String(),
      'updated_at': list.updatedAt.toIso8601String(),
    };

    if (list.id != null) {
      map['id'] = list.id;
    }

    return map;
  }

  ProductList _mapDbToProductList(Map<String, dynamic> map) {
    return ProductList(
      id: map['id'],
      name: map['name'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}
