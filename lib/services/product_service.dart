import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:listngo/models/product/product.dart';
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

  // Récupérer un produit par code-barres (local et en ligne)
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
          return localProduct;
        }
      } catch (e) {
        debugPrint('Conversion du code-barres en entier impossible: $e');
      }

      // Si non trouvé localement, chercher en ligne
      debugPrint('Produit non trouvé localement, recherche en ligne...');
      final url = '$baseUrl/$barcode.json';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Parsing du json
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 1) {
          final productData = jsonData['product'];
          final product = _mapToProduct(productData, barcode);

          // Sauvegarder le produit dans la base de données locale
          await saveProduct(product);

          return product;
        } else {
          debugPrint('Produit non trouvé: ${jsonData['status_verbose']}');
          return null;
        }
      } else {
        debugPrint('Erreur HTTP: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Exception lors de la récupération du produit: $e');
      return null;
    }
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

                // Sauvegarder le produit dans la base de données locale
                await saveProduct(product);
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

    // Nutri-Score (vérifier plusieurs champs possibles)
    String? nutriScore;
    if (data['nutriscore_grade'] != null) {
      nutriScore = data['nutriscore_grade'];
    } else if (data['nutrition_grades'] != null) {
      nutriScore = data['nutrition_grades'];
    }

    // Création de l'objet
    return Product(
      id: -1,
      barcode: barcode,
      name: name,
      keywords: keywords,
      isApi: true,
      imagePath: imagePath,
      nutriScore: nutriScore,
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

  // Méthodes internes pour accéder à la base de données

  Future<List<Product>> _getProductsFromDb() async {
    isLoading.value = true;
    error.value = null;

    try {
      return await _db.getAllProducts();
    } catch (e) {
      debugPrint('Error fetching products from DB: $e');
      rethrow;
    }
  }

  Future<List<Product>> _searchProductsFromDb(String query) async {
    isLoading.value = true;
    error.value = null;

    try {
      return await _db.searchProducts(query);
    } catch (e) {
      debugPrint('Error searching products in DB: $e');
      rethrow;
    }
  }

  void dispose() {
    productsSearched.dispose();
    currentProduct.dispose();
    isLoading.dispose();
    error.dispose();
  }
}
