import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:listngo/models/product.dart';

import '../../services/product_list_service.dart';
import '../../services/product_service.dart';
import '../../services/service_locator.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final Function(bool)? onCheckedChanged;

  const ProductCard({super.key, required this.product, this.onCheckedChanged});

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isChecked = false;
  int _quantity = 1;
  final ProductService _productService = getIt<ProductService>();
  final ProductListService _productListService = getIt<ProductListService>();

  @override
  void initState() {
    super.initState();

    final currentList = _productListService.currentList.value;

    if (currentList != null &&
        currentList.id != null &&
        widget.product.id != null) {
      final relation = currentList.productRelations[widget.product.id!];

      if (relation != null) {
        _quantity = relation.quantity;
        _isChecked = relation.isChecked;
      }
    }
  }

  @override
  void didUpdateWidget(ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    final currentList = _productListService.currentList.value;
    if (currentList != null && widget.product.id != null) {
      final relation = currentList.productRelations[widget.product.id!];
      if (relation != null) {
        if (_quantity != relation.quantity ||
            _isChecked != relation.isChecked) {
          setState(() {
            _quantity = relation.quantity;
            _isChecked = relation.isChecked;
          });
        }
      }
    }
  }

  void _addQuantity() {
    setState(() {
      if (_quantity < 99) {
        _quantity++;
        _productListService.updateProductQuantityInList(
          widget.product,
          _productListService.currentList.value!,
          _quantity,
        );
      }
    });
  }

  void _subtractQuantity() {
    setState(() {
      if (_quantity > 1) {
        _quantity--;
        _productListService.updateProductQuantityInList(
          widget.product,
          _productListService.currentList.value!,
          _quantity,
        );
      }
    });
  }

  void _toggleCheck() async {
    bool newCheckedState = !_isChecked;

    setState(() {
      _isChecked = newCheckedState;
    });

    final currentList = _productListService.currentList.value;
    if (currentList != null &&
        currentList.id != null &&
        widget.product.id != null) {
      try {
        await _productListService.checkProductInList(
          widget.product,
          currentList,
          _isChecked ? 1 : 0,
        );

        if (widget.onCheckedChanged != null) {
          widget.onCheckedChanged!(newCheckedState);
        }
      } catch (e) {
        setState(() {
          _isChecked = !newCheckedState;
        });
        debugPrint('Erreur lors de la mise à jour de l\'état: $e');
      }
    }
  }

  Widget _displayProductImage() {
    if (widget.product.imagePath == null || widget.product.imagePath!.isEmpty) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.shopping_bag, size: 50, color: Colors.grey[400]),
      );
    }

    if (!widget.product.isApi) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(widget.product.imagePath!),
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print("Erreur de chargement de l'image locale: $error");
            return Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.image_not_supported,
                size: 50,
                color: Colors.grey[400],
              ),
            );
          },
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          widget.product.imagePath!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  color: const Color.fromRGBO(247, 147, 76, 1.0),
                  value:
                      loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print("Erreur de chargement de l'image réseau: $error");
            return Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.image_not_supported,
                size: 50,
                color: Colors.grey[400],
              ),
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
      child: GestureDetector(
        onTap: () {
          _productService.currentProduct.value = widget.product;
          context.push('/product');
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withValues(alpha: 0.5),
          ),
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _displayProductImage(),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.product.name,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        // Indicateur de navigation
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                    if (widget.product.quantity != null &&
                        widget.product.quantity!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          widget.product.quantity!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontFamily: 'Lato',
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Contrôles de quantité
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _subtractQuantity,
                              child: Image.asset(
                                'assets/app_assets/minus_icon.png',
                                width: 40,
                                height: 40,
                              ),
                            ),
                            Text(
                              ' $_quantity ',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            GestureDetector(
                              onTap: _addQuantity,
                              child: Image.asset(
                                'assets/app_assets/plus_orange_icon.png',
                                width: 40,
                                height: 40,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            // Bouton supprimer
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () async {
                                bool?
                                confirm = await showModalBottomSheet<bool>(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  builder: (context) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom:
                                            MediaQuery.of(
                                              context,
                                            ).viewInsets.bottom,
                                        left: 16,
                                        right: 16,
                                        top: 16,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Confirmation',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color.fromRGBO(
                                                    247,
                                                    147,
                                                    76,
                                                    1.0,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.close),
                                                onPressed:
                                                    () => context.pop(false),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Êtes-vous sûr de vouloir supprimer cet élément ?',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              TextButton(
                                                onPressed:
                                                    () => context.pop(false),
                                                child: Text(
                                                  'Annuler',
                                                  style: TextStyle(
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              ElevatedButton(
                                                onPressed:
                                                    () => context.pop(true),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color.fromRGBO(
                                                        247,
                                                        147,
                                                        76,
                                                        1.0,
                                                      ),
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 12,
                                                      ),
                                                ),
                                                child: Text('Supprimer'),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                        ],
                                      ),
                                    );
                                  },
                                );

                                if (confirm == true) {
                                  await _productListService
                                      .removeProductFromList(
                                        widget.product,
                                        listId:
                                            _productListService
                                                .currentList
                                                .value!
                                                .id!,
                                      );
                                }
                              },
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color:
                                    _isChecked
                                        ? const Color.fromRGBO(
                                          247,
                                          147,
                                          76,
                                          1.0,
                                        )
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: const Color.fromRGBO(
                                    247,
                                    147,
                                    76,
                                    1.0,
                                  ),
                                  width: 2,
                                ),
                                boxShadow:
                                    _isChecked
                                        ? [
                                          const BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ]
                                        : [],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(25),
                                  onTap: _toggleCheck,
                                  child: Center(
                                    child: Icon(
                                      _isChecked ? Icons.check : Icons.add,
                                      color:
                                          _isChecked
                                              ? Colors.white
                                              : const Color.fromRGBO(
                                                247,
                                                147,
                                                76,
                                                1.0,
                                              ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
