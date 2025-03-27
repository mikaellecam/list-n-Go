import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:listngo/repositories/product_list_repository.dart';
import 'package:listngo/services/service_locator.dart';

import '../models/product_list/product_list.dart';

class ProductListManager {
  final ProductListRepository _repository = getIt<ProductListRepository>();

  final ValueNotifier<List<ProductList>> listsNotifier =
      ValueNotifier<List<ProductList>>([]);

  final ValueNotifier<ProductList?> currentListNotifier =
      ValueNotifier<ProductList?>(null);

  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);

  final ValueNotifier<String?> errorNotifier = ValueNotifier<String?>(null);

  List<ProductList> get productLists => listsNotifier.value;

  ProductList? get currentList => currentListNotifier.value;

  Future<void> loadLists() async {
    if (isLoadingNotifier.value) return;
    isLoadingNotifier.value = true;
    errorNotifier.value = null;
    int? previouslySelectedId = currentListNotifier.value?.id;

    try {
      final lists = await _repository.getAllLists();
      listsNotifier.value = List.from(lists);

      if (previouslySelectedId != null) {
        final ProductList? newListInstance = lists.firstWhereOrNull(
          (l) => l.id == previouslySelectedId,
        );
        setCurrentList(newListInstance);
        if (newListInstance == null) {
          debugPrint(
            'Previously selected list ID $previouslySelectedId no longer exists after reload. Selection cleared.',
          );
        }
      }
    } catch (e) {
      errorNotifier.value = 'Failed to load lists: $e';
    } finally {
      isLoadingNotifier.value = false;
    }
  }

  Future<bool> addList(String name, int userId) async {
    isLoadingNotifier.value = true;
    errorNotifier.value = null;
    try {
      final newListData = ProductList.createNew(userId: userId, name: name);
      final newId = await _repository.insertList(newListData);

      if (newId > 0) {
        final createdList = await _repository.getListById(newId);
        if (createdList != null) {
          final updatedList =
              List<ProductList>.from(listsNotifier.value)
                ..add(createdList)
                ..sort((a, b) => (b.updatedAt).compareTo(a.updatedAt));
          listsNotifier.value = updatedList;
          return true;
        } else {
          throw Exception("Failed to retrieve the newly created list.");
        }
      } else {
        throw Exception("Failed to insert the list into the database.");
      }
    } catch (e) {
      errorNotifier.value = 'Failed to add list: $e';
      return false;
    } finally {
      isLoadingNotifier.value = false;
    }
  }

  Future<bool> updateList(ProductList listToUpdate) async {
    isLoadingNotifier.value = true;
    errorNotifier.value = null;
    bool wasCurrentList = currentListNotifier.value?.id == listToUpdate.id;

    try {
      if (listToUpdate.id == null) {
        throw Exception("Cannot update a list without an ID.");
      }
      final rowsAffected = await _repository.updateList(listToUpdate);
      if (rowsAffected > 0) {
        final updatedListFromDb = await _repository.getListById(
          listToUpdate.id!,
        );
        if (updatedListFromDb != null) {
          final currentLists = List<ProductList>.from(listsNotifier.value);
          final index = currentLists.indexWhere(
            (l) => l.id == updatedListFromDb.id,
          );
          if (index != -1) {
            currentLists[index] = updatedListFromDb;
            currentLists.sort((a, b) => (b.updatedAt).compareTo(a.updatedAt));
            listsNotifier.value = currentLists;

            if (wasCurrentList) {
              setCurrentList(updatedListFromDb);
            }
          } else {
            await loadLists();
          }
        } else {
          await loadLists();
        }
        return true;
      } else {
        throw Exception("Failed to update the list in the database.");
      }
    } catch (e) {
      debugPrint('Error updating product list: $e');
      errorNotifier.value = 'Failed to update list: $e';
      return false;
    } finally {
      isLoadingNotifier.value = false;
    }
  }

  Future<bool> deleteList(int listId) async {
    bool wasCurrentList = currentListNotifier.value?.id == listId;

    isLoadingNotifier.value = true;
    errorNotifier.value = null;
    try {
      final rowsAffected = await _repository.deleteList(listId);

      if (rowsAffected > 0) {
        final currentLists = List<ProductList>.from(listsNotifier.value);
        currentLists.removeWhere((list) => list.id == listId);
        listsNotifier.value = currentLists;

        if (wasCurrentList) {
          debugPrint(
            'Deleted list ID $listId was the current list. Clearing selection.',
          );
          setCurrentList(null);
        }
        return true;
      } else {
        debugPrint(
          'Warning: List ID $listId not found for deletion or delete failed.',
        );
        if (wasCurrentList && !listsNotifier.value.any((l) => l.id == listId)) {
          setCurrentList(null);
        }
        return false;
      }
    } catch (e) {
      debugPrint('Error deleting product list: $e');
      errorNotifier.value = 'Failed to delete list: $e';
      return false;
    } finally {
      isLoadingNotifier.value = false;
    }
  }

  void setCurrentList(ProductList? list) {
    if (currentListNotifier.value?.id != list?.id) {
      currentListNotifier.value = list;
    }
  }

  void dispose() {
    listsNotifier.dispose();
    isLoadingNotifier.dispose();
    errorNotifier.dispose();
  }
}
