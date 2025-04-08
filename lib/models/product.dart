class Product {
  final int? id;
  final int? barcode;
  final String name;
  final List<String>? keywords;
  final bool isApi;
  final String? quantity; //Poids / Volume ...
  final DateTime? date;
  final String? imagePath;
  final String? nutriScore;
  final DateTime? createdAt;

  Product({
    this.id,
    this.barcode,
    required this.name,
    this.keywords,
    this.quantity,
    this.isApi = true,
    this.date,
    this.imagePath,
    this.nutriScore,
    this.createdAt,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    List<String>? keywordsList;
    if (map['keywords'] != null && map['keywords'].toString().isNotEmpty) {
      keywordsList = map['keywords'].toString().split(',');
    }

    return Product(
      id: map['id'],
      barcode: map['barcode'],
      name: map['name'],
      keywords: keywordsList,
      isApi: map['type'] == 'API',
      quantity: map['quantity'],
      date: map['date'] != null ? DateTime.parse(map['date']) : null,
      imagePath: map['image_path'],
      nutriScore: map['nutri_score'],
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{'name': name};

    if (id != null) {
      map['id'] = id;
    }

    if (barcode != null) {
      map['barcode'] = barcode;
    }

    if (keywords != null && keywords!.isNotEmpty) {
      map['keywords'] = keywords!.join(',');
    } else {
      map['keywords'] = '';
    }

    map['type'] = isApi ? 'API' : 'Custom';

    if (date != null) {
      map['date'] = date!.toIso8601String();
    }

    if (quantity != null) {
      map['quantity'] = quantity;
    }

    if (imagePath != null) {
      map['image_path'] = imagePath;
    }

    if (nutriScore != null) {
      map['nutri_score'] = nutriScore;
    }

    if (createdAt != null) {
      map['created_at'] = createdAt!.toIso8601String();
    }

    return map;
  }
}
