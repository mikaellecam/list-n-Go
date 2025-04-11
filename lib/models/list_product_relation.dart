class ListProductRelation {
  final int listId;
  final int productId;
  double quantity;
  bool isChecked;
  int position;
  final DateTime createdAt;

  ListProductRelation({
    required this.listId,
    required this.productId,
    this.quantity = 1.0,
    this.isChecked = false,
    this.position = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ListProductRelation.createNew({
    required int listId,
    required int productId,
    double quantity = 1.0,
    bool isChecked = false,
    int position = 0,
  }) {
    return ListProductRelation(
      listId: listId,
      productId: productId,
      quantity: quantity,
      isChecked: isChecked,
      position: position,
    );
  }

  ListProductRelation copyWith({
    int? listId,
    int? productId,
    double? quantity,
    bool? isChecked,
    int? position,
    DateTime? createdAt,
  }) {
    return ListProductRelation(
      listId: listId ?? this.listId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      isChecked: isChecked ?? this.isChecked,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ListProductRelation.fromMap(Map<String, dynamic> map) {
    return ListProductRelation(
      listId: map['list_id'],
      productId: map['product_id'],
      quantity: map['quantity'] ?? 1.0,
      isChecked: map['is_checked'] == 1,
      position: map['position'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'list_id': listId,
      'product_id': productId,
      'quantity': quantity,
      'is_checked': isChecked ? 1 : 0,
      'position': position,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
