import 'package:flutter/cupertino.dart';
import 'package:listngo/models/list_product_relation.dart';
import 'package:listngo/models/product.dart';

class ProductList {
  final int? id;
  String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  ValueNotifier<List<Product>> products = ValueNotifier([]);
  Map<int, ListProductRelation> productRelations = {};

  ProductList({
    this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    ValueNotifier<List<Product>>? products,
    Map<int, ListProductRelation>? productRelations,
  }) {
    this.products = products ?? ValueNotifier([]);
    this.productRelations = productRelations ?? {};
  }

  factory ProductList.createNew({required String name}) {
    final now = DateTime.now();
    return ProductList(name: name, createdAt: now, updatedAt: now);
  }

  factory ProductList.fromMap(Map<String, dynamic> map) {
    return ProductList(
      id: map['id'],
      name: map['name'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  void addProduct(Product product, ListProductRelation relation) {
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

  @override
  String toString() {
    return "ProductList(id: $id, name: $name, createdAt: $createdAt, updatedAt: $updatedAt, products: ${products.value}, productRelations: $productRelations)";
  }

  // TODO : Probably add an init method here, fetching all of the products linked to the list
}
