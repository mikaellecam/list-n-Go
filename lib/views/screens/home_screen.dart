import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:listngo/models/receipt.dart';
import 'package:listngo/services/product_list_service.dart';
import 'package:listngo/services/receipt_service.dart';
import 'package:listngo/services/service_locator.dart';
import 'package:listngo/views/widgets/custom_app_bar.dart';
import 'package:listngo/views/widgets/receipt_card.dart';

import '../../models/product_list.dart';
import '../widgets/list_card.dart';
import '../widgets/search_bar_with_add.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;
  final ProductListService _productListService = getIt<ProductListService>();
  final ReceiptService _receiptService = getIt<ReceiptService>();
  late final TextEditingController _listCreationController;

  @override
  void initState() {
    super.initState();
    _loadProductLists();
    _listCreationController = TextEditingController();
  }

  Future<void> _loadProductLists() async {
    await _productListService.loadListsWithProducts();
  }

  Future<void> _loadReceiptLists() async {
    await _receiptService.loadReceiptsWithProducts();
  }

  @override
  void dispose() {
    _listCreationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      appBar: CustomAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTabButton(context, 0, Icons.shopping_cart, "Listes"),
              const SizedBox(width: 8),
              _buildTabButton(context, 1, Icons.receipt, "Tickets"),
            ],
          ),

          // Affichage conditionnel de la barre de recherche
          const SizedBox(height: 10),
          SearchBarWithAdd(
            showAddButton: _selectedTab == 0,
            onAddButtonPressed: _createNewList,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _selectedTab == 0 ? _buildListView() : _buildFavoritesView(),
          ),
        ],
      ),
    );
  }

  Future<void> _createNewList() async {
    try {
      String? name = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return Container(
            color: const Color.fromARGB(255, 243, 243, 243),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nouvelle liste',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromRGBO(247, 147, 76, 1.0),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _listCreationController,
                  style: TextStyle(color: Colors.black),
                  autofocus: false,
                  decoration: InputDecoration(
                    hintText: 'Nom de la liste',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color.fromRGBO(247, 176, 91, 1.0),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color.fromRGBO(247, 176, 91, 1.0),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color.fromRGBO(247, 147, 76, 1.0),
                        width: 2,
                      ),
                    ),
                  ),
                  onSubmitted: (value) => context.pop(value),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        'Annuler',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed:
                          () => context.pop(_listCreationController.text),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(
                          247,
                          147,
                          76,
                          1.0,
                        ),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: Text('Créer'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      );

      if (name != null && name.isNotEmpty) {
        await _productListService.addList(name);

        if (_productListService.error.value != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_productListService.error.value!),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors de la création de la liste"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _productListService.error.value = null;
      _loadProductLists();
    }
  }

  Widget _buildTabButton(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) {
    bool isSelected = _selectedTab == index;

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.45,
      child: ElevatedButton.icon(
        onPressed:
            () => setState(() {
              _selectedTab = index;
            }),
        icon: Icon(
          icon,
          color:
              isSelected
                  ? Colors.white
                  : const Color.fromRGBO(247, 147, 76, 1.0),
        ),
        label: Text(
          label,
          style: TextStyle(
            color:
                isSelected
                    ? Colors.white
                    : const Color.fromRGBO(247, 147, 76, 1.0),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSelected
                  ? const Color.fromRGBO(247, 147, 76, 1.0)
                  : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: Color.fromRGBO(247, 147, 76, 1.0)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ValueListenableBuilder<List<ProductList>>(
      valueListenable: _productListService.lists,
      builder: (context, lists, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: _productListService.isLoading,
          builder: (context, isLoading, child) {
            if (isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            if (lists.isEmpty) {
              return Center(
                child: Text(
                  "Aucune liste de courses",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _loadProductLists,
              child: ListView.builder(
                itemCount: lists.length,
                itemBuilder: (context, index) {
                  final list = lists[index];
                  return ListCard(
                    productList: list,
                    onTap: () {
                      _productListService.currentList.value = list;
                      context.push('/product', extra: list);
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFavoritesView() {
    return ValueListenableBuilder<List<Receipt>>(
      valueListenable: _receiptService.receipts,
      builder: (context, lists, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: _receiptService.isLoading,
          builder: (context, isLoading, child) {
            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (lists.isEmpty) {
              return Center(
                child: Text(
                  "Aucun ticket disponible",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: _loadReceiptLists,
              child: ListView.builder(
                itemCount: lists.length,
                itemBuilder: (context, index) {
                  final list = lists[index];
                  return ReceiptCard(
                    receipt: list,
                    onTap: () {
                      _receiptService.currentReceipt.value = list;
                      context.push('/purchase-history');
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
