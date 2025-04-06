import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:listngo/models/product/product.dart'; // Ajustez le chemin d'importation

class ProductController {
  static const String baseUrl =
      'https://world.openfoodfacts.org/api/v2/product';

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

  // Méthode pour mapper les données JSON vers l'objet Product
  Product _mapToProduct(Map<String, dynamic> data, String barcodeStr) {
    // Nom du produit
    final name = data['product_name'] ?? 'Produit sans nom';

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

    // Image
    String? imagePath;
    if (data['image_url'] != null) {
      imagePath = data['image_url'];
    }

    // Nutri-Score
    String? nutriScore;
    if (data['nutriscore_grade'] != null) {
      nutriScore = data['nutriscore_grade'];
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
  }
}
