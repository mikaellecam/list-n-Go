import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:listngo/services/product_list_service.dart';
import 'package:listngo/services/service_locator.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/list_product_relation.dart';
import '../models/product.dart';
import '../models/product_list.dart';
import '../models/receipt.dart';
import '../models/receipt_product_relation.dart';

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
        fat REAL,
        saturated_fat REAL,
        sugar REAL, 
        salt REAL,
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
  CREATE TABLE Receipts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    price REAL,
    image_path TEXT,
    created_at TEXT
  )
''');

    await db.execute('''
  CREATE TABLE ReceiptProductRelation (
    receipt_id INTEGER,
    product_id INTEGER,
    quantity REAL DEFAULT 1.0,
    position INTEGER DEFAULT 0,
    created_at TEXT,
    PRIMARY KEY (receipt_id, product_id),
    FOREIGN KEY (receipt_id) REFERENCES receipts (id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
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
    bool isChecked = false,
    int position = 0,
  }) async {
    final db = await database;

    try {
      final List<Map<String, dynamic>> existingRelations = await db.query(
        'ListProductRelation',
        where: 'list_id = ? AND product_id = ?',
        whereArgs: [listId, productId],
      );

      if (existingRelations.isNotEmpty) {
        await db.update(
          'ListProductRelation',
          {
            'quantity': quantity,
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
      // TODO Possibly remove the Product entry if it is not used in any other list
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
      ProductList? existingList = getIt<ProductListService>().findListById(
        listId,
      );

      ProductList? productList = existingList;

      if (productList == null) {
        final List<Map<String, dynamic>> listMaps = await db.query(
          'Lists',
          where: 'id = ?',
          whereArgs: [listId],
        );

        if (listMaps.isEmpty) {
          return null;
        }

        productList = ProductList.fromMap(listMaps.first);
      }

      if (productList.products.value.isNotEmpty) {
        productList.products.value = [];
      }
      productList.productRelations.clear();

      final List<Map<String, dynamic>> relations = await db.query(
        'ListProductRelation',
        where: 'list_id = ?',
        whereArgs: [listId],
        orderBy: 'position ASC',
      );

      List<Product> products = [];

      for (var relation in relations) {
        final productId = relation['product_id'] as int;

        if (productId <= 0) continue;

        final listRelation = ListProductRelation.fromMap(relation);

        final Product? product = await getProductById(productId);
        if (product != null) {
          productList.productRelations[productId] = listRelation;
          products.add(product);
        } else {
          await delete(
            'ListProductRelation',
            'list_id = ? AND product_id = ?',
            [listId, productId],
          );
        }
      }
      productList.products.value = products;

      return productList;
    } catch (e) {
      debugPrint('Error getting product list with products: $e');
      return null;
    }
  }

  Future<int> insertReceipt(Receipt receipt) async {
    final db = await database;
    return await db.insert('Receipts', receipt.toMap());
  }

  Future<Receipt?> getReceiptById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Receipts',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    return Receipt.fromMap(maps.first);
  }

  Future<List<Receipt>> getAllReceipts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Receipts',
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Receipt.fromMap(maps[i]);
    });
  }

  Future<int> updateReceipt(Receipt receipt) async {
    final db = await database;
    return await db.update(
      'Receipts',
      receipt.toMap(),
      where: 'id = ?',
      whereArgs: [receipt.id],
    );
  }

  Future<int> deleteReceipt(int id) async {
    final db = await database;
    await db.delete(
      'ReceiptProductRelation',
      where: 'receipt_id = ?',
      whereArgs: [id],
    );
    return await db.delete('Receipts', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> addProductToReceipt(ReceiptProductRelation relation) async {
    final db = await database;
    return await db.insert('ReceiptProductRelation', relation.toMap());
  }

  Future<int> removeProductFromReceipt(int receiptId, int productId) async {
    final db = await database;
    return await db.delete(
      'ReceiptProductRelation',
      where: 'receipt_id = ? AND product_id = ?',
      whereArgs: [receiptId, productId],
    );
  }

  Future<Receipt?> getReceiptWithProducts(int receiptId) async {
    try {
      final db = await database;

      final receiptMaps = await db.query(
        'Receipts',
        where: 'id = ?',
        whereArgs: [receiptId],
      );

      if (receiptMaps.isEmpty) {
        return null;
      }

      final receipt = Receipt.fromMap(receiptMaps.first);

      final relationMaps = await db.query(
        'ReceiptProductRelation',
        where: 'receipt_id = ?',
        whereArgs: [receiptId],
        orderBy: 'position ASC',
      );

      final Map<int, ReceiptProductRelation> relations = {};
      final List<int> productIds = [];

      for (var relationMap in relationMaps) {
        final relation = ReceiptProductRelation.fromMap(relationMap);
        relations[relation.productId] = relation;
        productIds.add(relation.productId);
      }

      if (productIds.isEmpty) {
        return receipt;
      }

      final productMaps = await db.query(
        'Products',
        where: 'id IN (${List.filled(productIds.length, '?').join(', ')})',
        whereArgs: productIds,
      );

      final List<Product> products = [];

      for (var productMap in productMaps) {
        final product = Product.fromMap(productMap);
        if (product.id != null) {
          products.add(product);
        }
      }

      products.sort((a, b) {
        final posA = relations[a.id!]?.position ?? 0;
        final posB = relations[b.id!]?.position ?? 0;
        return posA.compareTo(posB);
      });

      return Receipt(
        id: receipt.id,
        name: receipt.name,
        price: receipt.price,
        imagePath: receipt.imagePath,
        createdAt: receipt.createdAt,
        products: ValueNotifier(products),
        productRelations: relations,
      );
    } catch (e) {
      print('Error getting receipt with products: $e');
      return null;
    }
  }

  Future<int> checkProductInList(int productId, int productListId) async {
    try {
      final db = await database;

      return await db.update(
        'ListProductRelation',
        {'is_checked': 1},
        where: 'list_id = ? AND product_id = ?',
        whereArgs: [productId, productListId],
      );
    } catch (e) {
      debugPrint('Error checking product in list: $e');
      return 0;
    }
  }
}
