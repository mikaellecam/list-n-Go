import 'package:flutter/material.dart';
import 'package:listngo/models/product.dart';
import 'package:listngo/services/product_service.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int _quantitySelected = 1;
  bool visibleNutriscore = false;
  bool visibleQuantity = false;
  final ProductService _productService = ProductService();

  Future<void> loadProductFromAPI() async {
    try {
      final String barcode = "8852018101024";
      final product = await _productService.getProductByBarcode(barcode);

      if (product == null) {
        debugPrint('Produit non trouvé pour ce code-barres: $barcode');
      } else {
        setState(() {
          checkVisibility();
        });
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement du produit depuis l\'API: $e');
    }
  }

  void checkVisibility() {
    // Met à jour les variables de visibilité
    if (_productService.currentProduct.value != null &&
        _productService.currentProduct.value!.nutriScore != null &&
        _productService.currentProduct.value!.nutriScore! != "") {
      visibleNutriscore = true;
    }

    if (_productService.currentProduct.value != null &&
        _productService.currentProduct.value!.quantity != null &&
        _productService.currentProduct.value!.quantity! != "") {
      visibleQuantity = true;
    }
  }

  @override
  void initState() {
    super.initState();
    loadProductFromAPI();
    //_productService = getIt<ProductService>();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text("Détails du produit")),
      // Occuper tout l'espace vertical disponible
      body: ValueListenableBuilder<Product?>(
        valueListenable: _productService.currentProduct,
        builder: (context, product, child) {
          if (product == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color.fromRGBO(247, 147, 76, 1.0),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                height: constraints.maxHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.only(
                        bottom: 82,
                      ), // Hauteur du bouton + padding
                      child: Column(
                        children: [
                          // Image en haut
                          SizedBox(
                            width: double.infinity,
                            height: screenHeight * 0.25,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                              ),
                              child:
                                  _productService
                                                  .currentProduct
                                                  .value!
                                                  .imagePath !=
                                              null &&
                                          _productService
                                              .currentProduct
                                              .value!
                                              .imagePath!
                                              .isNotEmpty
                                      ? Image.network(
                                        _productService
                                            .currentProduct
                                            .value!
                                            .imagePath!,
                                        fit: BoxFit.contain,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return const Icon(
                                            Icons.image_not_supported,
                                            size: 64,
                                            color: Colors.grey,
                                          );
                                        },
                                      )
                                      : const Icon(
                                        Icons.image_not_supported,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                            ),
                          ),

                          // Container avec les infos du produit
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Colonne pour le titre et les boutons de modification/suppression
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      alignment: WrapAlignment.start,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        Text(
                                          product.name,
                                          style: const TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontFamily: 'Lato',
                                          ),
                                        ),
                                        _productService
                                                .currentProduct
                                                .value!
                                                .isApi
                                            ? SizedBox.shrink()
                                            : IconButton(
                                              icon: Icon(
                                                Icons.edit,
                                                color: Color.fromRGBO(
                                                  247,
                                                  147,
                                                  76,
                                                  1.0,
                                                ),
                                              ),
                                              onPressed: () {
                                                // Action d'édition
                                              },
                                            ),
                                        _productService
                                                .currentProduct
                                                .value!
                                                .isApi
                                            ? SizedBox.shrink()
                                            : IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () {
                                                // Action de suppression
                                              },
                                            ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Row pour les boutons de quantité, alignée à droite
                                const SizedBox(height: 30),

                                // Unité (poids/volume/litre)
                                SizedBox(
                                  width: double.infinity,
                                  child:
                                      visibleQuantity
                                          ? Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.baseline,
                                            textBaseline:
                                                TextBaseline.alphabetic,
                                            children: [
                                              const Text(
                                                'Unité ',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  fontFamily: 'Lato',
                                                ),
                                              ),
                                              const Text(
                                                '(poids/volume/litre) ',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                  fontFamily: 'Lato',
                                                ),
                                              ),
                                              const Text(
                                                ':',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  fontFamily: 'Lato',
                                                ),
                                              ),
                                              // Utilisation d'Expanded pour occuper l'espace restant
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                        0,
                                                        0,
                                                        75,
                                                        0,
                                                      ),
                                                  child: Text(
                                                    _productService
                                                        .currentProduct
                                                        .value!
                                                        .quantity!,
                                                    // Valeur à récupérer du produit si disponible
                                                    textAlign: TextAlign.right,
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                      fontFamily: 'Lato',
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                          : SizedBox.shrink(),
                                ),

                                const SizedBox(height: 30),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Nutri-Score :',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontFamily: 'Lato',
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 30,
                                      ),
                                      child: SizedBox(
                                        width: 170,
                                        child: _buildNutriScoreImage(
                                          _productService
                                              .currentProduct
                                              .value!
                                              .nutriScore!,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 40),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0,
                                      ),
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(),
                                          icon: const Icon(
                                            Icons.remove,
                                            color: Colors.grey,
                                            size: 30,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              if (_quantitySelected > 0) {
                                                _quantitySelected--;
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '$_quantitySelected',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 24,
                                        fontFamily: 'Lato',
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15.0,
                                      ),
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Color.fromRGBO(
                                            247,
                                            147,
                                            76,
                                            1.0,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(),
                                          icon: const Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _quantitySelected++;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Afficher le code-barres s'il est disponible
                                if (product.barcode != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 30.0),
                                    child: Center(
                                      child: Text(
                                        'Code-barres: ${product.barcode}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                          fontFamily: 'Lato',
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bouton fixe en bas de l'écran
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              offset: Offset(0, -2),
                              blurRadius: 4.0,
                            ),
                          ],
                        ),
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              // Action pour ajouter à la liste
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(
                                247,
                                147,
                                76,
                                1.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                            ),
                            child: const Text(
                              'Ajouter à la liste',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Lato',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Calculé Nutri-Score
  Widget _buildNutriScoreImage(String? nutriScore) {
    String imagePath;

    if (nutriScore == null || nutriScore.isEmpty) {
      imagePath = "";
    } else {
      String grade = nutriScore.toUpperCase().substring(0, 1);

      switch (grade) {
        case 'A':
          imagePath =
              "https://upload.wikimedia.org/wikipedia/commons/thumb/7/7d/Nutri-score-A.svg/170px-Nutri-score-A.svg.png";
          break;
        case 'B':
          imagePath =
              "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Nutri-score-B.svg/180px-Nutri-score-B.svg.png";
          break;
        case 'C':
          imagePath =
              "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Nutri-score-C.svg/180px-Nutri-score-C.svg.png";
          break;
        case 'D':
          imagePath =
              "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d6/Nutri-score-D.svg/180px-Nutri-score-D.svg.png";
          break;
        case 'E':
          imagePath =
              "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8a/Nutri-score-E.svg/180px-Nutri-score-E.svg.png";
          break;
        default:
          imagePath =
              "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8a/Nutri-score-E.svg/180px-Nutri-score-E.svg.png";
      }
    }

    return Image.network(
      imagePath,
      fit: BoxFit.fill,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade200,
          child: const Center(
            child: Text(
              'Nutri-Score non disponible',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
