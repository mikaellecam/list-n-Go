import 'package:flutter/cupertino.dart';
import 'package:listngo/models/product_list.dart';
import 'package:listngo/services/database_service.dart';
import 'package:listngo/services/service_locator.dart';

class ProductListService {
  final db = getIt<DatabaseService>();

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

      final id = await db.insertProductList(newList);

      if (id > 0) {
        final createdList = await db.getProductListById(id);
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

      await db.deleteProductList(id);

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

  Future<bool> updateList(ProductList productList) async {
    isLoading.value = true;
    error.value = null;

    try {
      final id = productList.id;
      if (id == null) {
        error.value = 'List ID is null';
        return false;
      }

      await db.updateProductList(productList);

      lists.value =
          lists.value
              .map((list) => list.id == id ? productList : list)
              .toList();
      return true;
    } catch (e) {
      error.value = 'Error updating list: $e';
      debugPrint('Error updating list: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<ProductList>> _getListsFromDb() async {
    try {
      return await db.getAllProductLists();
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
