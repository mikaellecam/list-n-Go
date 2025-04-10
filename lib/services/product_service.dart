import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:listngo/models/product.dart';
import 'package:listngo/services/database_service.dart';

class ProductService {
  final _db = DatabaseService.instance;

  static const String baseUrl =
      'https://world.openfoodfacts.org/api/v2/product';
  static const String searchUrl =
      'https://world.openfoodfacts.org/cgi/search.pl';

  final ValueNotifier<List<Product>> productsSearched = ValueNotifier([]);
  final ValueNotifier<Product?> currentProduct = ValueNotifier(null);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> error = ValueNotifier(null);

  //Création d'un produit en base
  Future<int> createProduct({
    required String name,
    String? quantity,
    List<String>? keywords,
    String? nutriScore,
    String? imagePath,
  }) async {
    isLoading.value = true;
    error.value = null;

    try {
      final product = Product(
        name: name,
        quantity: quantity,
        keywords: keywords,
        nutriScore: nutriScore,
        imagePath: imagePath,
        isApi: false,
        // Produit créé manuellement
        createdAt: DateTime.now(),
      );

      debugPrint('Création d\'un nouveau produit: ${product.name}');
      final productId = await _db.insertProduct(product);

      if (productId > 0) {
        // Récupérer le produit complet avec l'ID
        final createdProduct = await _db.getProductById(productId);
        if (createdProduct != null) {
          currentProduct.value = createdProduct;
        }
      } else {
        error.value = 'Échec de la création du produit';
      }

      return productId;
    } catch (e) {
      debugPrint('Erreur lors de la création du produit: $e');
      error.value = 'Erreur lors de la création: $e';
      return -1;
    } finally {
      isLoading.value = false;
    }
  }

  // MAJ un produit
  Future<int> updateProduct({
    required int id,
    required String name,
    String? quantity,
    List<String>? keywords,
    String? nutriScore,
    String? imagePath,
  }) async {
    isLoading.value = true;
    error.value = null;

    try {
      // Récupérer le produit existant
      final existingProduct = await _db.getProductById(id);

      if (existingProduct == null) {
        error.value = 'Produit non trouvé';
        return -1;
      }

      if (imagePath != null &&
          existingProduct.imagePath != null &&
          existingProduct.imagePath != imagePath &&
          !existingProduct.isApi) {
        // Supprimer l'ancienne image si elle existe et que le produit n'est pas de l'API
        try {
          final oldFile = File(existingProduct.imagePath!);
          if (await oldFile.exists()) {
            await oldFile.delete();
          }
        } catch (e) {
          debugPrint('Erreur lors de la suppression de l\'ancienne image: $e');
        }
      }

      // Créer un nouveau produit avec les valeurs mises à jour
      final updatedProduct = Product(
        id: existingProduct.id,
        barcode: existingProduct.barcode,
        name: name,
        quantity: quantity,
        keywords: keywords,
        nutriScore: nutriScore,
        isApi: existingProduct.isApi,
        date: existingProduct.date,
        imagePath: imagePath ?? existingProduct.imagePath,
        fat: existingProduct.fat,
        saturatedFat: existingProduct.saturatedFat,
        sugar: existingProduct.sugar,
        salt: existingProduct.salt,
        createdAt: existingProduct.createdAt,
      );

      debugPrint('Mise à jour du produit: ${updatedProduct.name}');
      final result = await _db.updateProduct(updatedProduct);

      if (result > 0) {
        // Mettre à jour le produit courant
        currentProduct.value = updatedProduct;
      } else {
        error.value = 'Échec de la mise à jour du produit';
      }

      return result;
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour du produit: $e');
      error.value = 'Erreur lors de la mise à jour: $e';
      return -1;
    } finally {
      isLoading.value = false;
    }
  }

  // Recherche des produits en local et en ligne
  Future<void> searchProduct(String query) async {
    isLoading.value = true;
    error.value = null;

    try {
      // Recherche locale
      List<Product> localResults = await _db.searchProducts(query);
      debugPrint(
        '${localResults.length} produits trouvés localement pour: $query',
      );

      // Recherche en ligne
      debugPrint('Recherche en ligne pour: $query');
      List<Product> apiResults = await getProductByResearchFromAPI(query);
      debugPrint('${apiResults.length} produits trouvés en ligne pour: $query');

      List<Product> combinedResults = [...localResults];

      // Ajoute les produits de l'API qui ne sont pas déjà dans les résultats locaux
      for (final apiProduct in apiResults) {
        if (apiProduct.barcode != null &&
            !localResults.any(
              (localProduct) => localProduct.barcode == apiProduct.barcode,
            )) {
          combinedResults.add(apiProduct);
        }
      }

      debugPrint(
        '${combinedResults.length} produits trouvés au total pour: $query',
      );
      productsSearched.value = combinedResults;

      if (combinedResults.isEmpty) {
        error.value = 'Aucun produit trouvé pour: $query';
      }
    } catch (e) {
      debugPrint('Erreur lors de la recherche de produits: $e');
      error.value = 'Erreur lors de la recherche: $e';
      productsSearched.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    isLoading.value = true;
    error.value = null;

    try {
      // Vérifier d'abord si le produit existe dans la base de données locale
      int? numericBarcode;
      try {
        numericBarcode = int.parse(barcode);
        final localProduct = await _db.getProductByBarcode(numericBarcode);

        if (localProduct != null) {
          debugPrint(
            'Produit trouvé dans la base de données locale: ${localProduct.name}',
          );
          currentProduct.value = localProduct;
          return localProduct;
        }
      } catch (e) {
        debugPrint('Conversion du code-barres en entier impossible: $e');
      }

      // Si non trouvé localement, chercher en ligne
      debugPrint('Produit non trouvé localement, recherche en ligne...');
      final url = '$baseUrl/$barcode.json';
      debugPrint('URL de l\'API appelée: $url');

      final response = await http.get(Uri.parse(url));
      debugPrint('Code de statut de la réponse: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Journal de la réponse brute pour le débogage
        debugPrint(
          'Corps de la réponse brute: ${response.body.substring(0, min(200, response.body.length))}...',
        );

        // Parsing du json
        final jsonData = json.decode(response.body);
        debugPrint('Statut JSON: ${jsonData['status']}');

        if (jsonData['status'] == 1) {
          final productData = jsonData['product'];
          final product = _mapToProduct(productData, barcode);
          debugPrint('Produit mappé avec succès: ${product.name}');

          currentProduct.value = product;
          return product;
        } else {
          debugPrint('Produit non trouvé: ${jsonData['status_verbose']}');
          error.value = 'Produit non trouvé: ${jsonData['status_verbose']}';
          return null;
        }
      } else {
        debugPrint('Erreur HTTP: ${response.statusCode}');
        debugPrint('Corps de la réponse: ${response.body}');
        error.value = 'Erreur HTTP: ${response.statusCode}';
        return null;
      }
    } catch (e) {
      debugPrint('Exception lors de la récupération du produit: $e');
      error.value = 'Exception: $e';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // reset du CurrentProduct
  void resetCurrentProduct() {
    currentProduct.value = null;
  }

  // Rechercher des produits en ligne
  Future<List<Product>> getProductByResearchFromAPI(String searchTerms) async {
    isLoading.value = true;
    error.value = null;
    try {
      // Construction de l'URL
      final uri = Uri.parse(searchUrl).replace(
        queryParameters: {
          'search_terms': searchTerms,
          'search_simple': '1',
          'action': 'process',
          'json': '1',
          'page_size': '10',
        },
      );

      debugPrint('URI de recherche: $uri');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // Parsing du JSON
        final jsonData = json.decode(response.body);
        debugPrint('Réponse reçue');

        if (jsonData['products'] != null && jsonData['products'] is List) {
          List<dynamic> productsData = jsonData['products'];
          debugPrint('Nombre de produits trouvés: ${productsData.length}');

          List<Product> products = [];

          for (var productData in productsData) {
            String barcode = productData['code'] ?? '';

            if (barcode.isNotEmpty) {
              try {
                Product product = _mapToProduct(productData, barcode);
                products.add(product);
              } catch (e) {
                debugPrint('Erreur lors du mapping d\'un produit: $e');
              }
            }
          }

          return products;
        } else {
          debugPrint('Format de réponse inattendu ou aucun produit trouvé');
          return [];
        }
      } else {
        debugPrint('Erreur HTTP: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Exception lors de la recherche de produits: $e');
      return [];
    }
  }

  // Méthode pour mapper les données JSON vers l'objet Product
  Product _mapToProduct(Map<String, dynamic> data, String barcodeStr) {
    double? safeToDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return null;
    }

    // Nom du produit (plusieurs champs possibles)
    final name =
        data['product_name'] ??
        data['abbreviated_product_name_fr'] ??
        data['product_name_fr'] ??
        data['abbreviated_product_name'] ??
        'Produit sans nom';

    // Mots clés
    List<String> keywords = [];
    if (data['_keywords'] != null && data['_keywords'] is List) {
      keywords = List<String>.from(data['_keywords']);
    }

    // code-barre
    int? barcode;
    try {
      barcode = int.parse(barcodeStr);
    } catch (e) {
      debugPrint('Impossible de convertir le code-barres en entier: $e');
    }

    // Image (vérifier plusieurs champs possibles)
    String? imagePath;
    if (data['image_front_small_url'] != null) {
      imagePath = data['image_front_small_url'];
    } else if (data['image_small_url'] != null) {
      imagePath = data['image_small_url'];
    } else if (data['image_thumb_url'] != null) {
      imagePath = data['image_thumb_url'];
    } else if (data['image_url'] != null) {
      imagePath = data['image_url'];
    }

    String? quantity;
    if (data['quantity'] != null) {
      quantity = data['quantity'];
    }

    // Nutri-Score (vérifier plusieurs champs possibles)
    String? nutriScore;
    if (data['nutriscore_grade'] != null) {
      nutriScore = data['nutriscore_grade'];
    } else if (data['nutrition_grades'] != null) {
      nutriScore = data['nutrition_grades'];
    }

    // Récupérer les niveaux nutritionnels
    double? fatLevel;
    double? saltLevel;
    double? saturatedFatLevel;
    double? sugarsLevel;

    if (data['nutriments'] != null && data['nutriments'] is Map) {
      Map<String, dynamic> nutrientLevels = data['nutriments'];
      fatLevel = safeToDouble(nutrientLevels['fat']);
      saltLevel = safeToDouble(nutrientLevels['salt']);
      saturatedFatLevel = safeToDouble(nutrientLevels['saturated-fat']);
      sugarsLevel = safeToDouble(nutrientLevels['sugars']);
    }

    // Création de l'objet
    return Product(
      barcode: barcode,
      name: name,
      keywords: keywords,
      quantity: quantity,
      isApi: true,
      imagePath: imagePath,
      nutriScore: nutriScore,
      fat: fatLevel,
      saturatedFat: saturatedFatLevel,
      salt: saltLevel,
      sugar: sugarsLevel,
      createdAt: DateTime.now(),
    );
  }

  // Sauvegarder un product
  Future<int> saveProduct(Product product) async {
    try {
      // Vérifier si le produit existe déjà
      if (product.barcode != null) {
        final existingProduct = await _db.getProductByBarcode(product.barcode!);

        if (existingProduct != null) {
          debugPrint('Produit déjà existant: ${existingProduct.name}');
          return existingProduct.id ?? -1;
        }
      }

      // Insérer un nouveau produit
      debugPrint('Insertion d\'un nouveau produit: ${product.name}');
      return await _db.insertProduct(product);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde du produit: $e');
      return -1;
    }
  }

  void dispose() {
    productsSearched.dispose();
    currentProduct.dispose();
    isLoading.dispose();
    error.dispose();
  }
}
