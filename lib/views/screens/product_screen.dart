import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:listngo/models/product.dart';
import 'package:listngo/services/product_service.dart';

import '../widgets/custom_app_bar.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  bool inModification = false;
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

  // Méthode pour charger un produit fictif modifiable
  void loadLocalProduct() {
    try {
      // Création d'un produit fictif que vous pouvez modifier
      final product = Product(
        id: 99,
        barcode: 1234567890123,
        name: "Mon Produit Local Test",
        keywords: ["test", "local", "modifiable"],
        quantity: "500g",
        isApi: false,
        // Important: false pour pouvoir modifier
        imagePath:
            "https://images.openfoodfacts.org/images/products/893/521/090/1767/front_fr.3.400.jpg",
        nutriScore: "A",
        createdAt: DateTime.now(),
      );

      // Mettre à jour le produit actuel
      _productService.currentProduct.value = product;

      // Mettre à jour les variables de visibilité
      setState(() {
        checkVisibility();
      });

      debugPrint('Produit local chargé avec succès');
    } catch (e) {
      debugPrint('Erreur lors du chargement du produit local: $e');
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
    loadLocalProduct();
    //_productService = getIt<ProductService>();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      appBar: CustomAppBar(),
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
                      ), // Espace pour le bouton
                      child: Column(
                        children: [
                          // Image en haut
                          Container(
                            height: screenHeight * 0.25,
                            width: double.infinity,
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

                          // Container avec les détails du produit avec coins arrondis
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.only(
                              top: 25,
                              bottom: 120,
                              // Beaucoup d'espace en bas pour dépasser le bouton
                              left: 30,
                              right: 15,
                            ),
                            constraints: BoxConstraints(
                              minHeight:
                                  constraints.maxHeight -
                                  screenHeight * 0.25 +
                                  100,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Nom du produit et boutons d'édition
                                Wrap(
                                  alignment: WrapAlignment.start,
                                  crossAxisAlignment: WrapCrossAlignment.center,
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
                                    _productService.currentProduct.value!.isApi
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
                                            context.push('/create-product');
                                          },
                                        ),
                                    _productService.currentProduct.value!.isApi
                                        ? SizedBox.shrink()
                                        : IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () {
                                            // Action de suppression
                                          },
                                        ),
                                  ],
                                ),

                                const SizedBox(height: 30),

                                // Unité (poids/volume/litre)
                                if (visibleQuantity)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
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
                                          padding: const EdgeInsets.fromLTRB(
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
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                              fontFamily: 'Lato',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                const SizedBox(height: 30),

                                // Nutri-Score
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
