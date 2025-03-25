import '../models/product/product.dart';
import '../services/database/database_helper.dart';

class ProductRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  static const String _tableName = 'Products';

  Future<int> insertProduct(Product product) async {
    Map<String, dynamic> row = product.toJson();
    if (row['id'] == null) {
      row.remove('id');
    }

    if (row['keywords'] != null) {
      row['keywords'] = (row['keywords'] as List<String>).join(',');
    }

    if (row['date'] != null) {
      row['date'] = row['date'].toString();
    }
    if (row['createdAt'] != null) {
      row['created_at'] = row['createdAt'].toString();
    }
    row.remove('createdAt');

    row['image_path'] = row['imagePath'];
    row.remove('imagePath');
    row['nutri_score'] = row['nutriScore'];
    row.remove('nutriScore');

    return await _databaseHelper.insert(_tableName, row);
  }

  Future<Product?> getProductById(int id) async {
    List<Map<String, dynamic>> maps = await _databaseHelper.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    return _mapToProduct(maps.first);
  }

  Future<Product?> getProductByBarcode(int barcode) async {
    List<Map<String, dynamic>> maps = await _databaseHelper.query(
      'LatestProducts',
      where: 'barcode = ?',
      whereArgs: [barcode],
    );

    if (maps.isEmpty) {
      return null;
    }

    return _mapToProduct(maps.first);
  }

  Future<List<Product>> getAllProducts() async {
    List<Map<String, dynamic>> maps = await _databaseHelper.queryAll(
      'LatestProducts',
    );

    return maps.map((map) => _mapToProduct(map)).toList();
  }

  Future<List<Product>> searchProducts(String query) async {
    List<Map<String, dynamic>> maps = await _databaseHelper.query(
      'LatestProducts',
      where: 'name LIKE ? OR keywords LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );

    return maps.map((map) => _mapToProduct(map)).toList();
  }

  Future<int> updateProduct(Product product, int id) async {
    Map<String, dynamic> row = product.toJson();

    if (row['keywords'] != null) {
      row['keywords'] = (row['keywords'] as List<String>).join(',');
    }

    if (row['date'] != null) {
      row['date'] = row['date'].toString();
    }
    if (row['createdAt'] != null) {
      row['created_at'] = row['createdAt'].toString();
    }
    row.remove('createdAt');

    row['image_path'] = row['imagePath'];
    row.remove('imagePath');
    row['nutri_score'] = row['nutriScore'];
    row.remove('nutriScore');

    return await _databaseHelper.update(_tableName, row, 'id = ?', [id]);
  }

  Future<int> deleteProduct(int id) async {
    return await _databaseHelper.delete(_tableName, 'id = ?', [id]);
  }

  Product _mapToProduct(Map<String, dynamic> map) {
    map['imagePath'] = map['image_path'];
    map['nutriScore'] = map['nutri_score'];

    if (map['keywords'] != null && map['keywords'] is String) {
      map['keywords'] = (map['keywords'] as String).split(',');
    }

    if (map['date'] != null && map['date'] is String) {
      map['date'] = DateTime.parse(map['date']);
    }
    if (map['created_at'] != null) {
      map['createdAt'] = DateTime.parse(map['created_at']);
    }

    return Product.fromJson(map);
  }
}
