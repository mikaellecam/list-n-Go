import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:listngo/services/product_list_service.dart';
import 'package:listngo/services/product_service.dart';
import 'package:listngo/services/receipt_service.dart';
import 'package:listngo/services/service_locator.dart';
import 'package:listngo/views/widgets/custom_app_bar.dart';

import '../../models/product.dart';
import '../../models/product_list.dart';
import '../../services/permission_helper.dart';
import '../widgets/product_card.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late final TextEditingController _controller;
  final ProductListService productListService = getIt<ProductListService>();
  final ReceiptService receiptService = getIt<ReceiptService>();
  final ProductService productService = getIt<ProductService>();
  bool _isRenaming = false;
  bool _isExpanded = false;

  late final int currentListId;
  late final ProductList currentList;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: productListService.currentList.value!.name,
    );
    currentList = productListService.currentList.value!;
    currentListId = productListService.currentList.value!.id!;
  }

  void toggleExpandOptions() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void startRenaming() {
    setState(() {
      _isRenaming = true;
    });
  }

  void finishRenaming() async {
    setState(() {
      _isRenaming = false;
    });
    String newName = _controller.text;
    if (newName.isEmpty) {
      return;
    }
    productListService.currentList.value!.name = newName;
    productListService.updateList(productListService.currentList.value!);
  }

  Future<void> _handleAddProductToList(Product product) async {
    ProductList? currentList = productListService.currentList.value;

    if (currentList == null) {
      currentList = productListService.findListById(currentListId);

      if (currentList != null) {
        productListService.currentList.value = currentList;
      }
    }

    if (currentList == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur: Impossible de trouver la liste actuelle'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final result = await productListService.addProductToList(
      product,
      quantity: 1.0,
      isChecked: false,
      position: productListService.currentList.value!.products.value.length,
    );

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} ajouté à la liste'),
          backgroundColor: const Color.fromRGBO(247, 147, 76, 1.0),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur: ${productListService.error.value ?? "Impossible d\'ajouter le produit"}',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      appBar: CustomAppBar(
        onBackPressed: () => productListService.currentList.value = null,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 120),
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child:
                                  _isRenaming
                                      ? TextField(
                                        controller: _controller,
                                        autofocus: true,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontFamily: "Lato",
                                          color: Colors.black,
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      )
                                      : Padding(
                                        padding: EdgeInsets.only(left: 15),
                                        child: Text(
                                          currentList.name,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontFamily: "Lato",
                                            color: Colors.black,
                                          ),
                                          softWrap: true,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                            ),
                            _isRenaming
                                ? Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => finishRenaming(),
                                      icon: Icon(Icons.check, size: 30),
                                      color: Color.fromRGBO(247, 147, 76, 1.0),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _isRenaming = false;
                                        });
                                      },
                                      icon: Icon(Icons.close, size: 30),
                                      color: Color.fromRGBO(247, 147, 76, 1.0),
                                    ),
                                  ],
                                )
                                : IconButton(
                                  onPressed: () => startRenaming(),
                                  icon: Icon(Icons.edit, size: 30),
                                  color: Color.fromRGBO(247, 147, 76, 1.0),
                                ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: toggleExpandOptions,
                        icon: const Icon(
                          Icons.add_circle_rounded,
                          color: Color.fromRGBO(247, 147, 76, 1.0),
                          size: 50,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.topRight,
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Text(
                        'Tout sélectionner',
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: "Lato",
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                ValueListenableBuilder<List<Product>>(
                  valueListenable:
                      productListService.currentList.value!.products,
                  builder: (context, products, child) {
                    return Column(
                      children:
                          products
                              .map((product) => ProductCard(product: product))
                              .toList(),
                    );
                  },
                ),
              ],
            ),
          ),

          if (_isExpanded)
            Positioned.fill(
              child: GestureDetector(
                onTap: toggleExpandOptions,
                behavior: HitTestBehavior.translucent,
                child: Container(color: Colors.black.withValues(alpha: 0.5)),
              ),
            ),
          if (_isExpanded)
            Positioned(
              top: 80,
              right: 25,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Scanner un code-barres',
                            style: TextStyle(
                              fontFamily: "Lato",
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FloatingActionButton.small(
                          backgroundColor: const Color.fromRGBO(
                            247,
                            147,
                            76,
                            1.0,
                          ),
                          heroTag: 'scan',
                          onPressed: () async {
                            final hasPermission =
                                await getIt<PermissionHelper>()
                                    .requestCameraPermission(context);
                            if (!hasPermission) return;

                            if (context.mounted) {
                              final barcode = await context.push(
                                '/barcode-scanner',
                              );
                              if (barcode != null && barcode is String) {
                                Product? product = await productService
                                    .getProductByBarcode(barcode);

                                if (product != null) {
                                  await _handleAddProductToList(product);
                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Produit non trouvé pour le code-barres: $barcode',
                                        ),
                                        backgroundColor: Colors.red,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                }
                              }
                            }
                          },
                          child: const Icon(
                            Icons.barcode_reader,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Rechercher un produit',
                          style: TextStyle(
                            fontFamily: "Lato",
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FloatingActionButton.small(
                        backgroundColor: const Color.fromRGBO(
                          247,
                          147,
                          76,
                          1.0,
                        ),
                        heroTag: 'search',
                        onPressed: () {
                          context.push('/search');
                          toggleExpandOptions();
                        },
                        child: const Icon(Icons.search, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: const Color.fromRGBO(247, 147, 76, 1.0),
              ),
              padding: EdgeInsets.symmetric(vertical: 3),
              margin: EdgeInsets.all(25),
              child: TextButton(
                onPressed: () {
                  context.push('/complete-list');
                },
                child: Text(
                  'Courses terminées',
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: "Lato",
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
