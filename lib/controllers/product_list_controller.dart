import 'package:flutter/material.dart';
import 'package:listngo/models/product_list/product_list.dart';
import 'package:listngo/repositories/product_list_repository.dart';
import 'package:listngo/services/service_locator.dart';
import 'package:listngo/state/product_list_manager.dart';

import '../views/widgets/dialogs/create_product_list_dialog.dart';

class ProductListController {
  final ProductListRepository _productListRepository = ProductListRepository();
  final ProductListManager _productListManager = getIt<ProductListManager>();

  Future<List<ProductList>> getProductLists() async {
    return await _productListRepository.getAllLists();
  }

  Future<void> createProductList(BuildContext context) async {
    String? name = await showDialog(
      context: context,
      builder: (context) => CreateProductListDialog(),
    );

    debugPrint('Product list name: $name');

    if (name != null && name.isNotEmpty) {
      // TODO Replace with actual user ID when auth is implemented
      final currentUserId = 1;
      final success = await _productListManager.addList(name, currentUserId);
      if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _productListManager.errorNotifier.value ?? 'Failed to add list',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> isProductListNameTaken(String listName) async {
    return (await _productListRepository.getListByName(listName)) == null
        ? false
        : true;
  }
}
