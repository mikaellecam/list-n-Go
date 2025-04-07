import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:listngo/services/product_list_service.dart';
import 'package:listngo/services/service_locator.dart';
import 'package:listngo/views/widgets/shop_list_old_item.dart';

import '../../models/product_list/product_list.dart';
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

  @override
  void initState() {
    super.initState();
    _loadProductLists();
  }

  Future<void> _loadProductLists() async {
    await _productListService.loadLists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      appBar: AppBar(
        title: Image.asset('assets/app_assets/list-n-go_logo.png', height: 50),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      ),
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
    final TextEditingController textController = TextEditingController();

    try {
      String? name = await showDialog<String>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Nouvelle liste'),
              content: TextField(
                controller: textController,
                autofocus: true,
                decoration: InputDecoration(hintText: 'Nom de la liste'),
                onSubmitted: (value) => context.pop(value),
              ),
              actions: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text('Annuler'),
                ),
                TextButton(
                  onPressed: () => context.pop(textController.text),
                  child: Text('Créer'),
                ),
              ],
            ),
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
    } finally {
      textController.dispose();
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
    return ListView(
      padding: const EdgeInsets.only(top: 10),
      // test affichage //
      children: const [
        ReceiptItem(title: 'Carrefour', date: '5 avril 2025'),
        ReceiptItem(title: 'Biocoop', date: '2 avril 2025'),
      ],
      ////////////////////
    );
  }
}
