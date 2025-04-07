class ReceiptProductRelation {
  final int receiptId;
  final int productId;
  final double quantity;
  final double? price;
  final int position;
  final DateTime? createdAt;

  ReceiptProductRelation({
    required this.receiptId,
    required this.productId,
    this.quantity = 1,
    this.price,
    this.position = 0,
    this.createdAt,
  });

  factory ReceiptProductRelation.fromMap(Map<String, dynamic> map) {
    return ReceiptProductRelation(
      receiptId: map['receipt_id'],
      productId: map['product_id'],
      quantity: map['quantity'] ?? 1.0,
      price: map['price'],
      position: map['position'] ?? 0,
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'receipt_id': receiptId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
      'position': position,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
