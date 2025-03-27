import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:listngo/controllers/product_list_controller.dart';
import 'package:listngo/models/product_list/product_list.dart';

import '../../services/service_locator.dart';
import '../../state/product_list_manager.dart';

class ProductListView extends StatefulWidget {
  const ProductListView({super.key});

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  final ProductListManager _productListManager = getIt<ProductListManager>();
  final ProductListController _productListController = ProductListController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_productListManager.productLists.isEmpty) {
        _productListManager.loadLists();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Lists'),
        actions: [
          // Example: Loading Indicator in AppBar
          ValueListenableBuilder<bool>(
            valueListenable: _productListManager.isLoadingNotifier,
            builder: (context, isLoading, child) {
              if (isLoading) {
                return const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink(); // Return empty if not loading
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        // Allow pull-to-refresh
        onRefresh: _productListManager.loadLists,
        child: Column(
          children: [
            // Example: Display Error Message
            ValueListenableBuilder<String?>(
              valueListenable: _productListManager.errorNotifier,
              builder: (context, error, child) {
                if (error != null) {
                  return Container(
                    color: Colors.red.withValues(alpha: 0.1),
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            error,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed:
                              () =>
                                  _productListManager.errorNotifier.value =
                                      null, // Clear error
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            // Use ValueListenableBuilder to reactively build the list UI
            Expanded(
              child: ValueListenableBuilder<List<ProductList>>(
                valueListenable: _productListManager.listsNotifier,
                builder: (context, productLists, child) {
                  if (productLists.isEmpty &&
                      !_productListManager.isLoadingNotifier.value) {
                    return const Center(child: Text('No lists found.'));
                  }
                  if (productLists.isEmpty &&
                      _productListManager.isLoadingNotifier.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ListView.builder(
                    itemCount: productLists.length,
                    itemBuilder: (context, index) {
                      final list = productLists[index];
                      return ListTile(
                        title: Text(list.name),
                        subtitle: Text('Updated: ${list.updatedAt}'),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            final confirm =
                                await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: const Text('Delete List?'),
                                        content: Text(
                                          'Are you sure you want to delete "${list.name}"?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.of(
                                                  context,
                                                ).pop(false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.of(
                                                  context,
                                                ).pop(true),
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                ) ??
                                false;

                            if (confirm) {
                              await _productListManager.deleteList(list.id!);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('List deleted')),
                              );
                            }
                          },
                        ),
                        onTap: () {
                          context.go('/list');
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _productListController.createProductList(context),
        tooltip: 'Add List',
        child: const Icon(Icons.add),
      ),
    );
  }
}
