import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:listngo/models/product/product.dart';

class ProductController {
  static const String baseUrl =
      'https://world.openfoodfacts.org/api/v2/product';
  static const String searchUrl =
      'https://world.openfoodfacts.org/cgi/search.pl';

  // Récupérer un produit
  Future<Product?> getProductByBarcode(String barcode) async {
    try {
      // URL avec code barre
      final url = '$baseUrl/$barcode.json';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        //Parsing du json
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 1) {
          final productData = jsonData['product'];
          return _mapToProduct(productData, barcode);
        } else {
          print('Produit non trouvé: ${jsonData['status_verbose']}');
          return null;
        }
      } else {
        print('Erreur HTTP: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception lors de la récupération du produit: $e');
      return null;
    }
  }

  // Rechercher des produits
  Future<List<Product>> getProductByResearchFromAPI(String searchTerms) async {
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

      print('URI de recherche: $uri');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // Parsing du JSON
        final jsonData = json.decode(response.body);
        print('Réponse reçue, contient ${jsonData.keys.length} clés');

        print('Clés disponibles: ${jsonData.keys.toList()}');

        if (jsonData['products'] != null && jsonData['products'] is List) {
          List<dynamic> productsData = jsonData['products'];
          print('Nombre de produits trouvés: ${productsData.length}');

          List<Product> products = [];

          for (var productData in productsData) {
            String barcode = productData['code'] ?? '';
            print('Traitement du produit avec code: $barcode');

            if (barcode.isNotEmpty) {
              try {
                print(
                  'Champs disponibles pour le produit: ${productData.keys.toList()}',
                );

                Product product = _mapToProduct(productData, barcode);
                products.add(product);
                print('Produit ajouté: ${product.name}');
              } catch (e) {
                print('Erreur lors du mapping d\'un produit: $e');
              }
            }
          }

          print('Nombre total de produits retournés: ${products.length}');
          return products;
        } else {
          print('Format de réponse inattendu ou aucun produit trouvé');
          if (jsonData['products'] == null) {
            print('La clé "products" est absente dans la réponse');
          } else {
            print('La clé "products" n\'est pas une liste');
          }
          return [];
        }
      } else {
        print('Erreur HTTP: ${response.statusCode}');
        // Afficher le contenu de la réponse pour voir l'erreur
        print('Contenu de la réponse: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Exception lors de la recherche de produits: $e');
      print('Détail de l\'exception: ${e.toString()}');
      return [];
    }
  }

  // Mapping
  Product _mapToProduct(Map<String, dynamic> data, String barcodeStr) {
    try {
      // Nom du produit
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
        print('Impossible de convertir le code-barres en entier: $e');
      }

      // Image (plusieurs champs)
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

      // Nutri-Score
      String? nutriScore;
      if (data['nutriscore_grade'] != null) {
        nutriScore = data['nutriscore_grade'];
      } else if (data['nutrition_grades'] != null) {
        nutriScore = data['nutrition_grades'];
      }

      // Création de l'objet
      return Product(
        barcode: barcode,
        name: name,
        keywords: keywords,
        isApi: true,
        imagePath: imagePath,
        nutriScore: nutriScore,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('Exception dans _mapToProduct: $e');
      return Product(
        name: 'Erreur de chargement',
        isApi: true,
        createdAt: DateTime.now(),
      );
    }
  }
}
