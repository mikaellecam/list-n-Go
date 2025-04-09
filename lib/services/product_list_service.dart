import 'package:flutter/cupertino.dart';
import 'package:listngo/models/product.dart';
import 'package:listngo/models/product_list.dart';
import 'package:listngo/services/database_service.dart';
import 'package:listngo/services/service_locator.dart';

import '../models/list_product_relation.dart';

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

  Future<void> loadListsWithProducts() async {
    isLoading.value = true;
    error.value = null;

    try {
      final basicLists = await _getListsFromDb();
      debugPrint(
        'Loaded ${basicLists.length} basic lists, now loading products...',
      );

      List<ProductList> completeLists = [];

      for (final list in basicLists) {
        if (list.id != null) {
          final completeList = await db.getProductListWithProducts(list.id!);
          debugPrint("completeList: ${completeList?.hashCode}");
          if (completeList != null) {
            completeLists.add(completeList);
            debugPrint(
              'Loaded list: ${completeList.name} with ${completeList.products.value.length} products',
            );
          } else {
            completeLists.add(list);
            debugPrint('Could not load products for list: ${list.name}');
          }
        } else {
          completeLists.add(list);
        }
      }

      lists.value = completeLists;
      print("hashcodes: ${lists.value.first.hashCode}");
      debugPrint('All lists loaded with products');
    } catch (e) {
      error.value = 'Failed to load lists with products: $e';
      debugPrint('Failed to load lists with products: $e');
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

  Future<bool> addProductToList(
    ProductList productList,
    Product product, {
    double quantity = 1.0,
    bool isChecked = false,
    int position = 0,
  }) async {
    isLoading.value = true;
    error.value = null;

    try {
      final listId = productList.id;
      final productId = product.id;

      if (listId == null) {
        error.value = 'List ID is null';
        return false;
      }

      if (productId == null) {
        error.value = 'Product ID is null';
        return false;
      }

      final actualList = findListById(listId) ?? productList;

      final result = await db.addProductToList(
        listId,
        productId,
        quantity: quantity,
        isChecked: isChecked,
        position: position,
      );

      if (result > 0) {
        final relation = ListProductRelation.createNew(
          listId: listId,
          productId: productId,
          quantity: quantity,
          isChecked: isChecked,
          position: position,
        );

        final existingProductIndex = actualList.products.value.indexWhere(
          (p) => p.id == productId,
        );

        if (existingProductIndex >= 0) {
          actualList.productRelations[productId] = relation;
        } else {
          actualList.addProduct(product, relation);
        }

        if (currentList.value?.id == listId &&
            currentList.value != actualList) {
          currentList.value = actualList;
        }

        return true;
      } else {
        error.value = 'Failed to add product to list';
        return false;
      }
    } catch (e) {
      error.value = 'Error adding product to list: $e';
      debugPrint('Error adding product to list: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadProductsForList(int listId) async {
    isLoading.value = true;
    error.value = null;

    try {
      final completeList = await db.getProductListWithProducts(listId);

      if (completeList != null) {
        final index = lists.value.indexWhere((list) => list.id == listId);
        if (index >= 0) {
          final updatedLists = List<ProductList>.from(lists.value);
          updatedLists[index] = completeList;
          lists.value = updatedLists;
        }
      } else {
        error.value = 'Could not load list with products';
      }
    } catch (e) {
      error.value = 'Error loading products for list: $e';
      debugPrint('Error loading products for list: $e');
    } finally {
      isLoading.value = false;
    }
  }

  ProductList? findListById(int id) {
    print("lists: ${lists.value}");
    final index = lists.value.indexWhere((list) => list.id == id);
    if (index >= 0) {
      print('hashcode inside findListById: ${lists.value[index].hashCode}');
      return lists.value[index];
    }
    return null;
  }
}
