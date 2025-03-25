import 'package:listngo/services/database/database_helper.dart';

class DatabaseService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<void> initDatabase() async {
    await _databaseHelper.database;
  }
  // TODO: Implement the rest of the database operations

  String keywordsToString(List<String> keywords) {
    return keywords.join(',');
  }

  List<String> stringToKeywords(String keywordsString) {
    if (keywordsString.isEmpty) return [];
    return keywordsString.split(',');
  }

  Future<int> insertProduct(Map<String, dynamic> product) async {
    final db = await _databaseHelper.database;

    if (product['keywords'] is List<String>) {
      product['keywords'] = keywordsToString(product['keywords']);
    }

    return await db.insert('Products', product);
  }
}
