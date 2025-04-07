import 'package:flutter/cupertino.dart';
import 'package:listngo/models/product_list.dart';
import 'package:listngo/services/database_service.dart';

class ProductListService {
  final _db = DatabaseService.instance;

  final ValueNotifier<List<ProductList>> lists = ValueNotifier([]);
  final ValueNotifier<ProductList?> currentList = ValueNotifier(null);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> error = ValueNotifier(null);

  Future<void> loadLists() async {
    isLoading.value = true;
    error.value = null;

    try {
      lists.value = await _getListsFromDb();
    } catch (e) {
      error.value = 'Failed to load lists: $e';
      debugPrint('Failed to load lists: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addList(String name) async {
    isLoading.value = true;
    error.value = null;

    try {
      final newList = ProductList.createNew(name: name);

      final id = await _db.insertProductList(newList);

      if (id > 0) {
        final createdList = await _db.getProductListById(id);
        if (createdList != null) {
          final updatedLists =
              List<ProductList>.from(lists.value)
                ..add(createdList)
                ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

          lists.value = updatedLists;
          return true;
        }
      }

      error.value = 'Failed to create list';
      return false;
    } catch (e) {
      error.value = 'Error creating list: $e';
      debugPrint('Error creating list: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> removeList(ProductList productList) async {
    isLoading.value = true;
    error.value = null;

    try {
      final id = productList.id;
      if (id == null) {
        error.value = 'List ID is null';
        return false;
      }

      await _db.deleteProductList(id);

      lists.value = lists.value.where((list) => list.id != id).toList();
      return true;
    } catch (e) {
      error.value = 'Error deleting list: $e';
      debugPrint('Error deleting list: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<ProductList>> _getListsFromDb() async {
    try {
      return await _db.getAllProductLists();
    } catch (e) {
      debugPrint('Error fetching lists from DB: $e');
      rethrow;
    }
  }

  void dispose() {
    lists.dispose();
    currentList.dispose();
    isLoading.dispose();
    error.dispose();
  }
}
