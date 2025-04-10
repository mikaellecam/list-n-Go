import 'package:flutter/cupertino.dart';
import 'package:listngo/models/product.dart';
import 'package:listngo/models/receipt_product_relation.dart';

class Receipt {
  final int? id;
  String? name;
  double? price;
  String? imagePath;
  final DateTime? createdAt;
  ValueNotifier<List<Product>> products = ValueNotifier([]);
  Map<int, ReceiptProductRelation> productRelations = {};

  Receipt({
    this.id,
    this.name,
    this.price,
    this.imagePath,
    this.createdAt,
    ValueNotifier<List<Product>>? products,
    Map<int, ReceiptProductRelation>? productRelations,
  }) {
    this.products = products ?? ValueNotifier([]);
    this.productRelations = productRelations ?? {};
  }

  factory Receipt.fromMap(Map<String, dynamic> map) {
    return Receipt(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      imagePath: map['image_path'],
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (id != null) {
      map['id'] = id;
    }

    if (name != null) {
      map['name'] = name;
    }

    if (price != null) {
      map['price'] = price;
    }

    if (imagePath != null) {
      map['image_path'] = imagePath;
    }

    if (createdAt != null) {
      map['created_at'] = createdAt!.toIso8601String();
    }

    return map;
  }

  void addProduct(Product product, ReceiptProductRelation relation) {
    final newList = List<Product>.from(products.value)..add(product);
    products.value = newList;
    productRelations[product.id!] = relation;
  }

  void removeProduct(int productId) {
    final newList = List<Product>.from(products.value)
      ..removeWhere((product) => product.id == productId);
    products.value = newList;
    productRelations.remove(productId);
  }
}
