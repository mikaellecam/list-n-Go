import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:listngo/models/product.dart';
import 'package:listngo/models/product_list.dart';
import 'package:listngo/services/product_list_service.dart';
import 'package:listngo/services/product_service.dart';
import 'package:listngo/services/service_locator.dart';
import 'package:listngo/views/widgets/custom_app_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ProductService _productService = getIt<ProductService>();
  final ProductListService _productListService = getIt<ProductListService>();
  late final ProductList productList;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _productService.error.addListener(_onErrorChanged);
    productList = getIt<ProductListService>().currentList.value!;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _productService.error.removeListener(_onErrorChanged);
    super.dispose();
  }

  void _onErrorChanged() {
    if (_productService.error.value != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_productService.error.value!)));
    }
  }

  void _performSearch(String query) {
    if (query.isEmpty) return;
    setState(() {
      _isSearching = true;
    });
    _productService.searchProduct(query).then((_) {
      setState(() {
        _isSearching = false;
      });
    });
  }

  void _addProductToList(Product product) {
    _productListService.addProductToList(product).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} ajouté à ${productList.name}'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'ajout du produit à ${productList.name}'),
          ),
        );
      }
    });
  }

  // Widget pour afficher l'image du produit selon sa source
  Widget _displayProductImage(Product product, {double size = 50}) {
    if (product.imagePath == null || product.imagePath!.isEmpty) {
      return Icon(Icons.shopping_bag, size: size);
    }

    // Si le produit n'est pas isApi (donc un produit local), utiliser File
    if (!product.isApi) {
      return SizedBox(
        width: size,
        height: size,
        child: Image.file(
          File(product.imagePath!),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print("Erreur de chargement de l'image locale: $error");
            return Icon(Icons.image_not_supported, size: size);
          },
        ),
      );
    } else {
      // Pour les produits API, utiliser Image.network
      return SizedBox(
        width: size,
        height: size,
        child: Image.network(
          product.imagePath!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                color: const Color.fromRGBO(247, 147, 76, 1.0),
                value:
                    loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print("Erreur de chargement de l'image réseau: $error");
            return Icon(Icons.image_not_supported, size: size);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => context.push('/create-product'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF9945E),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Créer un produit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Rechercher un produit',
                prefixIcon: const Icon(Icons.search),
                hintStyle: const TextStyle(color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Color.fromRGBO(247, 176, 91, 1.0),
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Color.fromRGBO(247, 176, 91, 1.0),
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Color.fromRGBO(247, 147, 76, 1.0),
                    width: 2.5,
                  ),
                ),
              ),
              onSubmitted: _performSearch,
            ),
          ),
          const SizedBox(height: 16),
          /*Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Produits conseillés',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
            ),
          ),*/
          Expanded(
            child: ValueListenableBuilder<List<Product>>(
              valueListenable: _productService.productsSearched,
              builder: (context, products, child) {
                if (_isSearching) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (products.isEmpty) {
                  return _buildSuggestionProductsList();
                }

                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _buildProductListItem(product);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionProductsList() {
    final suggestedProducts = [
      'Tomates',
      'Viande hachée',
      'Courgettes',
      'Sauce soja salée',
      'Semoule',
      'Nutella',
    ];

    return ListView.builder(
      itemCount: suggestedProducts.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.history, color: Colors.grey),
          title: Text(suggestedProducts[index]),
          onTap: () => _performSearch(suggestedProducts[index]),
        );
      },
    );
  }

  Widget _buildProductListItem(Product product) {
    return ListTile(
      leading: _displayProductImage(product, size: 50),
      title: InkWell(
        onTap: () => _addProductToCurrentProduct(product),
        child: Text(product.name),
      ),
      subtitle: Text(product.quantity ?? ''),
      trailing: IconButton(
        icon: const Icon(Icons.add_circle, color: Color(0xFFF9945E)),
        onPressed: () => _addProductToList(product),
      ),
    );
  }

  void _addProductToCurrentProduct(Product product) {
    _productService.currentProduct.value = product;
    context.push('/product');
    return;
  }
}
