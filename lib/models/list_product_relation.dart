class ListProductRelation {
  final int listId;
  final int productId;
  final double quantity;
  final double? price;
  final bool isChecked;
  final int position;
  final DateTime? createdAt;

  ListProductRelation({
    required this.listId,
    required this.productId,
    this.quantity = 1,
    this.price,
    this.isChecked = false,
    this.position = 0,
    this.createdAt,
  });

  factory ListProductRelation.fromMap(Map<String, dynamic> map) {
    return ListProductRelation(
      listId: map['list_id'],
      productId: map['product_id'],
      quantity: map['quantity'] ?? 1.0,
      price: map['price'],
      isChecked: map['is_checked'] == 1,
      position: map['position'] ?? 0,
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'list_id': listId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
      'is_checked': isChecked ? 1 : 0,
      'position': position,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
