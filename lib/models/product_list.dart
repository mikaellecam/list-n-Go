class ProductList {
  final int? id;
  String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductList({
    this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

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
}
