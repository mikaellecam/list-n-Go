import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:listngo/models/product.dart';

import '../../services/product_list_service.dart';
import '../../services/product_service.dart';
import '../../services/service_locator.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final Function(bool)?
  onCheckedChanged; // Callback pour notifier le parent du changement d'état

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

    // Récupérer la liste courante
    final currentList = _productListService.currentList.value;
    if (currentList != null &&
        currentList.id != null &&
        widget.product.id != null) {
      // Vérifier si le produit est dans la liste
      final relation = currentList.productRelations[widget.product.id!];
      if (relation != null) {
        // Initialiser avec les valeurs de la relation spécifique à ce produit
        _quantity = relation.quantity.toInt();
        _isChecked = relation.isChecked;
      }
    }
  }

  // S'assurer que les données sont à jour si les relations changent
  @override
  void didUpdateWidget(ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Vérifier si nous devons mettre à jour notre état local
    final currentList = _productListService.currentList.value;
    if (currentList != null && widget.product.id != null) {
      final relation = currentList.productRelations[widget.product.id!];
      if (relation != null) {
        // Ne mettre à jour que si la relation a changé pour éviter une boucle infinie
        if (_quantity != relation.quantity.toInt() ||
            _isChecked != relation.isChecked) {
          setState(() {
            _quantity = relation.quantity.toInt();
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
        _updateProductQuantity();
      }
    });
  }

  void _subtractQuantity() {
    setState(() {
      if (_quantity > 1) {
        _quantity--;
        _updateProductQuantity();
      }
    });
  }

  // Cette méthode doit être implémentée car elle n'existe pas dans le ProductListService
  // Nous allons devoir recréer la relation et l'ajouter à la liste
  void _updateProductQuantity() async {
    // Obtenir la liste courante et sa version actuelle
    final currentList = _productListService.currentList.value;
    if (currentList != null &&
        currentList.id != null &&
        widget.product.id != null) {
      try {
        // Sauvegarder l'état coché actuel
        final currentRelation =
            currentList.productRelations[widget.product.id!];
        final isCheckedState = currentRelation?.isChecked ?? _isChecked;
        final position = currentRelation?.position ?? 0;

        // Supprimer spécifiquement ce produit
        await _productListService.removeProductFromList(
          widget.product,
          listId: currentList.id!,
        );

        // Puis réajouter avec la nouvelle quantité, mais conserver l'état coché
        await _productListService.addProductToList(
          widget.product,
          quantity: _quantity.toDouble(),
          isChecked: isCheckedState,
          position: position,
        );
      } catch (e) {
        debugPrint('Erreur lors de la mise à jour de la quantité: $e');
      }
    }
  }

  void _toggleCheck() async {
    // Mettre à jour l'état local en premier
    bool newCheckedState = !_isChecked;

    setState(() {
      _isChecked = newCheckedState;
    });

    // Obtenir la liste courante et sa version actuelle
    final currentList = _productListService.currentList.value;
    if (currentList != null &&
        currentList.id != null &&
        widget.product.id != null) {
      try {
        // Supprimer spécifiquement ce produit
        await _productListService.removeProductFromList(
          widget.product,
          listId: currentList.id!,
        );

        // Puis réajouter avec le nouvel état
        await _productListService.addProductToList(
          widget.product,
          quantity: _quantity.toDouble(),
          isChecked: newCheckedState,
          // Conserver la position d'origine si elle existe
          position:
              currentList.productRelations[widget.product.id!]?.position ?? 0,
        );

        // Appeler le callback pour notifier le parent du changement d'état
        if (widget.onCheckedChanged != null) {
          widget.onCheckedChanged!(newCheckedState);
        }
      } catch (e) {
        // En cas d'erreur, revenir à l'état précédent
        setState(() {
          _isChecked = !newCheckedState;
        });
        debugPrint('Erreur lors de la mise à jour de l\'état: $e');
      }
    }
  }

  void _navigateToProductDetails() {
    // Mettre à jour le produit courant dans le service
    _productService.currentProduct.value = widget.product;
    // Naviguer vers la page de détail du produit
    context.push('/product');
  }

  // Widget pour afficher l'image du produit selon sa source
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

    // Si le produit n'est pas isApi (donc un produit local), utiliser File
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
      // Pour les produits API, utiliser Image.network
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
        onTap: _navigateToProductDetails,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.5),
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
                                bool? confirm = await showDialog(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: const Text('Confirmation'),
                                        content: const Text(
                                          'Êtes-vous sûr de vouloir supprimer cet élément ?',
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () => context.pop(false),
                                            child: const Text('Annuler'),
                                          ),
                                          TextButton(
                                            onPressed: () => context.pop(true),
                                            child: const Text('Supprimer'),
                                          ),
                                        ],
                                      ),
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
                            // Bouton cocher
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
