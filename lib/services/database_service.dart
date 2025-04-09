import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/list_product_relation.dart';
import '../models/product.dart';
import '../models/product_list.dart';

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
        quantity TEXT,
        type TEXT,
        date TEXT,
        image_path TEXT,
        nutri_score TEXT,
        fat TEXT,
        saturated_fat TEXT,
        sugar TEXT, 
        salt TEXT,
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
    return maps.map((map) => ProductList.fromMap(map)).toList();
  }

  Future<ProductList?> getProductListById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Lists',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return ProductList.fromMap(maps.first);
  }

  Future<int> insertProductList(ProductList list) async {
    final db = await database;
    return await db.insert('Lists', list.toMap());
  }

  Future<int> updateProductList(ProductList list) async {
    final db = await database;
    return await db.update(
      'Lists',
      list.toMap(),
      where: 'id = ?',
      whereArgs: [list.id],
    );
  }

  Future<int> deleteProductList(int id) async {
    final db = await database;
    return await db.delete('Lists', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Products',
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  Future<List<Product>> searchProducts(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Products',
      where: 'name LIKE ? OR keywords LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  Future<Product?> getProductByBarcode(int barcode) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Products',
      where: 'barcode = ?',
      whereArgs: [barcode],
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Product.fromMap(maps.first);
  }

  Future<Product?> getProductById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Products',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Product.fromMap(maps.first);
  }

  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('Products', product.toMap());
  }

  Future<int> updateProduct(Product product) async {
    if (product.id == null) {
      throw ArgumentError('Cannot update a product without an id');
    }

    final db = await database;
    return await db.update(
      'Products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('Products', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> addProductToList(
    int listId,
    int productId, {
    double quantity = 1.0,
    double? price,
    bool isChecked = false,
    int position = 0,
  }) async {
    final db = await database;

    try {
      final List<Map<String, dynamic>> exisitingRelations = await db.query(
        'ListProductRelation',
        where: 'list_id = ? AND product_id = ?',
        whereArgs: [listId, productId],
      );

      if (exisitingRelations.isNotEmpty) {
        await db.update(
          'ListProductRelation',
          {
            'quantity': quantity,
            'price': price,
            'is_checked': isChecked ? 1 : 0,
            'position': position,
          },
          where: 'list_id = ? AND product_id = ?',
          whereArgs: [listId, productId],
        );
        return 1;
      } else {
        final relation = ListProductRelation.createNew(
          listId: listId,
          productId: productId,
          quantity: quantity,
          isChecked: isChecked,
          position: position,
        );

        await db.insert('ListProductRelation', relation.toMap());
        return 1;
      }
    } catch (e) {
      debugPrint('Error adding product to list: $e');
      return -1;
    }
  }

  Future<int> removeProductFromList(int listId, int productId) async {
    final db = await database;

    try {
      return await db.delete(
        'ListProductRelation',
        where: 'list_id = ? AND product_id = ?',
        whereArgs: [listId, productId],
      );
    } catch (e) {
      debugPrint('Error removing product from list: $e');
      return -1;
    }
  }

  Future<ValueNotifier<List<Product>>> getProductsInList(int listId) async {
    final db = await database;

    try {
      final List<Map<String, dynamic>> relations = await db.query(
        'ListProductRelation',
        where: 'list_id = ?',
        whereArgs: [listId],
      );

      if (relations.isEmpty) {
        return ValueNotifier([]);
      }

      ValueNotifier<List<Product>> products = ValueNotifier([]);

      for (var relation in relations) {
        final productId = relation['product_id'];

        final List<Map<String, dynamic>> productMaps = await db.query(
          'Products',
          where: 'id = ?',
          whereArgs: [productId],
        );

        if (productMaps.isNotEmpty) {
          products.value.add(Product.fromMap(productMaps.first));
        }
      }

      return products;
    } catch (e) {
      debugPrint('Error getting products in list: $e');
      return ValueNotifier([]);
    }
  }

  Future<Map<int, ListProductRelation>> getProductRelationsInList(
    int listId,
  ) async {
    final db = await database;

    try {
      final List<Map<String, dynamic>> relations = await db.query(
        'ListProductRelation',
        where: 'list_id = ?',
        whereArgs: [listId],
      );

      Map<int, ListProductRelation> result = {};

      for (var relationMap in relations) {
        final relation = ListProductRelation.fromMap(relationMap);
        result[relation.productId] = relation;
      }

      return result;
    } catch (e) {
      debugPrint('Error getting product relations in list: $e');
      return {};
    }
  }

  Future<ProductList?> getProductListWithProducts(int listId) async {
    final db = await database;

    try {
      final List<Map<String, dynamic>> listMaps = await db.query(
        'Lists',
        where: 'id = ?',
        whereArgs: [listId],
      );

      if (listMaps.isEmpty) {
        return null;
      }

      final productList = ProductList.fromMap(listMaps.first);

      final products = await getProductsInList(listId);

      final relations = await getProductRelationsInList(listId);

      return ProductList(
        id: productList.id,
        name: productList.name,
        createdAt: productList.createdAt,
        updatedAt: productList.updatedAt,
        products: products,
        productRelations: relations,
      );
    } catch (e) {
      debugPrint('Error getting product list with products: $e');
      return null;
    }
  }
}
