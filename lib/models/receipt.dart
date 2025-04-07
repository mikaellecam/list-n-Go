class Receipt {
  final int? id;
  final String? name;
  final double? price;
  final DateTime? createdAt;

  Receipt({this.id, this.name, this.price, this.createdAt});

  factory Receipt.fromMap(Map<String, dynamic> map) {
    return Receipt(
      id: map['id'],
      name: map['name'],
      price: map['price'],
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

    if (createdAt != null) {
      map['created_at'] = createdAt!.toIso8601String();
    }

    return map;
  }
}
