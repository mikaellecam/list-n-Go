import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:listngo/models/product.dart';
import 'package:listngo/services/product_list_service.dart';
import 'package:listngo/services/product_service.dart';

import '../../models/product_list.dart';
import '../../services/service_locator.dart';
import '../widgets/custom_app_bar.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  // Utiliser un Map pour gérer la visibilité de tous les champs
  Map<String, bool> visibilityMap = {
    'nutriscore': false,
    'quantity': false,
    'nutritionalValues': false,
    'fat': false,
    'saturatedFat': false,
    'sugar': false,
    'salt': false,
  };

  final ProductService productService = getIt<ProductService>();
  final ProductListService productListService = getIt<ProductListService>();
  late final ProductList productList;

  bool _isProductInCurrentList = false;

  // Modification de la méthode _addProductToList pour garantir la mise à jour du bouton
  void _addProductToList(Product product) {
    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => const Center(
            child: CircularProgressIndicator(
              color: Color.fromRGBO(247, 147, 76, 1.0),
            ),
          ),
    );

    productListService
        .addProductToList(product)
        .then((success) {
          // Fermer l'indicateur de chargement
          if (context.canPop()) Navigator.of(context).pop();

          if (success) {
            // Mettre à jour l'état pour refléter que le produit est maintenant dans la liste
            setState(() {
              _isProductInCurrentList = true;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${product.name} ajouté à ${productList.name}'),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Erreur lors de l\'ajout du produit à ${productList.name}',
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        })
        .catchError((error) {
          // Fermer l'indicateur de chargement en cas d'erreur
          if (context.canPop()) Navigator.of(context).pop();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $error'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        });
  }

  // Modification de la méthode de vérification pour ne pas écraser l'état d'ajout manuel
  void checkIfProductInCurrentList() {
    // Ne pas mettre à jour si _isProductInCurrentList est déjà true
    if (_isProductInCurrentList) return;

    final product = productService.currentProduct.value;
    final currentList = productListService.currentList.value;

    if (product == null || currentList == null || product.id == null) {
      _isProductInCurrentList = false;
      return;
    }

    // Vérifier si le produit est dans la liste des produits de la liste courante
    _isProductInCurrentList = currentList.products.value.any(
      (p) => p.id == product.id,
    );
  }

  void checkVisibility() {
    final product = productService.currentProduct.value;
    if (product == null) return;

    // Vérification de Nutriscore - seulement A, B, C, D ou E sont valides
    final validNutriScores = ['A', 'B', 'C', 'D', 'E'];
    visibilityMap['nutriscore'] =
        product.nutriScore != null &&
        validNutriScores.contains(product.nutriScore!.toUpperCase());

    // Vérification de Quantity
    visibilityMap['quantity'] =
        product.quantity != null && product.quantity!.isNotEmpty;

    // Vérification des valeurs nutritionnelles individuelles
    visibilityMap['fat'] = product.fat != null;
    visibilityMap['saturatedFat'] = product.saturatedFat != null;
    visibilityMap['sugar'] = product.sugar != null;
    visibilityMap['salt'] = product.salt != null;

    // Vérification si au moins une valeur nutritionnelle est disponible
    visibilityMap['nutritionalValues'] =
        visibilityMap['fat']! ||
        visibilityMap['saturatedFat']! ||
        visibilityMap['sugar']! ||
        visibilityMap['salt']!;
  }

  // Méthode pour ajouter le produit à la liste courante
  Future<void> _addProductToCurrentList() async {
    final product = productService.currentProduct.value;
    final currentList = productListService.currentList.value;

    if (product == null || currentList == null || product.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur: Impossible d\'ajouter le produit à la liste'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const Center(
            child: CircularProgressIndicator(
              color: Color.fromRGBO(247, 147, 76, 1.0),
            ),
          ),
    );

    try {
      final result = await productListService.addProductToList(
        product,
        quantity: 1,
        isChecked: false,
        position: productListService.currentList.value!.products.value.length,
      );

      // Fermer le dialogue de chargement
      if (context.canPop()) context.pop();

      if (result) {
        setState(() {
          _isProductInCurrentList = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${product.name} ajouté à la liste ${currentList.name}',
            ),
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
    } catch (e) {
      // Fermer le dialogue de chargement en cas d'erreur
      if (context.canPop()) context.pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Méthode pour naviguer vers la liste des produits
  void _navigateToProductList() {
    context.push('/list');
  }

  @override
  void initState() {
    super.initState();
    checkVisibility();
    checkIfProductInCurrentList();

    productList = getIt<ProductListService>().currentList.value!;

    if (productService.currentProduct.value != null) {
      print(
        "Produit chargé: ${productService.currentProduct.value.toString()}",
      );
    }
  }

  // Widget pour afficher l'image du produit
  Widget _displayProductImage(Product product) {
    if (product.imagePath == null || product.imagePath!.isEmpty) {
      return const Icon(
        Icons.image_not_supported,
        size: 64,
        color: Colors.grey,
      );
    }

    // Si le produit n'est pas isApi (donc un produit local), utiliser File
    if (!product.isApi) {
      return Image.file(
        File(product.imagePath!),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          print("Erreur de chargement de l'image locale: $error");
          return const Icon(
            Icons.image_not_supported,
            size: 64,
            color: Colors.grey,
          );
        },
      );
    } else {
      // Pour les produits API, utiliser Image.network
      return Image.network(
        product.imagePath!,
        fit: BoxFit.contain,
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
          return const Icon(
            Icons.image_not_supported,
            size: 64,
            color: Colors.grey,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      appBar: CustomAppBar(
        onBackPressed: () => productService.currentProduct.value = null,
        backgroundColor: Colors.white,
      ),
      body: ValueListenableBuilder<Product?>(
        valueListenable: productService.currentProduct,
        builder: (context, product, child) {
          if (product == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color.fromRGBO(247, 147, 76, 1.0),
              ),
            );
          }

          // Mettre à jour la visibilité à chaque construction du widget
          checkVisibility();

          // Vérifier également si le produit est dans la liste courante à chaque build
          checkIfProductInCurrentList();

          return LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  // Contenu défilable
                  SingleChildScrollView(
                    // Espace pour le bouton fixe en bas
                    padding: const EdgeInsets.only(bottom: 82),
                    child: Column(
                      children: [
                        // Image en haut
                        Container(
                          height: screenHeight * 0.25,
                          width: double.infinity,
                          child: _displayProductImage(product),
                        ),

                        // Container avec les détails du produit avec coins arrondis
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(
                            top: 25,
                            bottom: 50,
                            left: 30,
                            right: 15,
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
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontFamily: 'Lato',
                                    ),
                                  ),
                                  product.isApi
                                      ? const SizedBox.shrink()
                                      : IconButton(
                                        icon: const Icon(
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
                                  product.isApi
                                      ? const SizedBox.shrink()
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
                              if (visibilityMap['quantity']!)
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    const Text(
                                      'Unité :',
                                      style: TextStyle(
                                        fontSize: 18,
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
                                          product.quantity!,
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontFamily: 'Lato',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                              if (visibilityMap['quantity']!)
                                const SizedBox(height: 30),

                              // Nutri-Score (à condition qu'il soit visible)
                              if (visibilityMap['nutriscore']!)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Nutri-Score :',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontFamily: 'Lato',
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 50),
                                      child: SizedBox(
                                        width: 140,
                                        child: _buildNutriScoreImage(
                                          product.nutriScore!,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                              if (visibilityMap['nutriscore']! &&
                                  visibilityMap['nutritionalValues']!)
                                const SizedBox(height: 30),

                              // SECTION - Valeurs nutritionnelles (conditionnelle)
                              if (visibilityMap['nutritionalValues']!) ...[
                                // Titre de la section
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 15),
                                  child: Text(
                                    'Valeurs nutritionnelles :',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontFamily: 'Lato',
                                    ),
                                  ),
                                ),

                                // Conteneur pour les indicateurs nutritionnels en style de liste
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                  ),
                                  child: Column(
                                    children: [
                                      // Matières grasses (Fat)
                                      if (visibilityMap['fat']!) ...[
                                        _buildNutrientIndicator(
                                          'Matières grasses',
                                          product.fat?.toString(),
                                        ),
                                        const Divider(height: 24),
                                      ],

                                      // Acides gras saturés (Saturated Fat)
                                      if (visibilityMap['saturatedFat']!) ...[
                                        _buildNutrientIndicator(
                                          'Acides gras saturés',
                                          product.saturatedFat?.toString(),
                                        ),
                                        if (visibilityMap['sugar']! ||
                                            visibilityMap['salt']!)
                                          const Divider(height: 24),
                                      ],

                                      // Sucres (Sugar)
                                      if (visibilityMap['sugar']!) ...[
                                        _buildNutrientIndicator(
                                          'Sucres',
                                          product.sugar?.toString(),
                                        ),
                                        if (visibilityMap['salt']!)
                                          const Divider(height: 24),
                                      ],

                                      // Sel (Salt)
                                      if (visibilityMap['salt']!)
                                        _buildNutrientIndicator(
                                          'Sel',
                                          product.salt?.toString(),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bouton fixe en bas de l'écran (conditionnel en fonction de si le produit est déjà dans la liste)
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
                          onPressed:
                              productListService.currentList.value == null
                                  ? null // Désactiver le bouton si pas de liste courante
                                  : (_isProductInCurrentList
                                      ? _navigateToProductList // Naviguer vers la liste si déjà présent
                                      : () => _addProductToList(
                                        productService.currentProduct.value!,
                                      )), // Ajouter à la liste sinon
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _isProductInCurrentList
                                    ? Colors
                                        .green // Vert si déjà présent
                                    : const Color.fromRGBO(
                                      247,
                                      147,
                                      76,
                                      1.0,
                                    ), // Orange sinon
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            // Bouton grisé si pas de liste courante
                            disabledBackgroundColor: Colors.grey,
                          ),
                          child: Text(
                            productListService.currentList.value == null
                                ? 'Aucune liste sélectionnée'
                                : (_isProductInCurrentList
                                    ? 'Déjà dans la liste - Voir la liste'
                                    : 'Ajouter à la liste'),
                            style: const TextStyle(
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
              );
            },
          );
        },
      ),
    );
  }

  // Widget pour afficher un indicateur nutritionnel
  Widget _buildNutrientIndicator(String label, String? levelStr) {
    // Convertir la chaîne en double si possible
    double? levelValue;
    try {
      if (levelStr != null && levelStr.isNotEmpty) {
        // Supprimer toute unité (g, mg, etc.) et convertir en double
        final cleanedStr = levelStr.replaceAll(RegExp(r'[^0-9.]'), '');
        levelValue = double.tryParse(cleanedStr);
      }
    } catch (e) {
      debugPrint('Erreur de conversion: $e');
    }

    // Fonction pour déterminer le niveau basé sur les seuils
    String getNutrientLevel(String nutrientType, double? value) {
      if (value == null) return 'unknown';

      switch (nutrientType) {
        case 'Matières grasses':
          if (value <= 3.0) return 'low';
          if (value <= 17.5) return 'moderate';
          return 'high';

        case 'Acides gras saturés':
          if (value <= 1.5) return 'low';
          if (value <= 5.0) return 'moderate';
          return 'high';

        case 'Sucres':
          if (value <= 5.0) return 'low';
          if (value <= 22.5) return 'moderate';
          return 'high';

        case 'Sel':
          if (value <= 0.3) return 'low';
          if (value <= 1.5) return 'moderate';
          return 'high';

        default:
          return 'unknown';
      }
    }

    // Déterminer le niveau en fonction du type de nutriment et de sa valeur
    final String level = getNutrientLevel(label, levelValue);

    // Définir les couleurs en fonction du niveau
    Color getColorForLevel(String level) {
      switch (level) {
        case 'high':
          return Colors.red.shade400;
        case 'moderate':
          return Colors.orange.shade400;
        case 'low':
          return Colors.green.shade400;
        default:
          return Colors.grey;
      }
    }

    // Définir le texte à afficher
    String getLevelText(String level, double? value) {
      String baseText = '';
      switch (level) {
        case 'high':
          baseText = 'Élevé';
          break;
        case 'moderate':
          baseText = 'Modéré';
          break;
        case 'low':
          baseText = 'Faible';
          break;
        default:
          return 'Non disponible';
      }

      // Ajouter la valeur numérique si disponible
      if (value != null) {
        return '$baseText (${value.toStringAsFixed(1)}g/100g)';
      }
      return baseText;
    }

    // Récupérer couleur et texte
    final color = getColorForLevel(level);
    final levelText = getLevelText(level, levelValue);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Nom du nutriment (en noir comme le reste du texte)
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontFamily: 'Lato',
          ),
        ),

        // Indicateur visuel et texte (aligné à droite)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cercle de couleur
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),

            // Texte du niveau
            Text(
              levelText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'Lato',
              ),
            ),
          ],
        ),
      ],
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
}
