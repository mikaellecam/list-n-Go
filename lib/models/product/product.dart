import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
abstract class Product with _$Product {
  const factory Product({
    int? barcode,
    required String name,
    List<String>? keywords,
    double? price,
    String? type,
    DateTime? date,
    String? imagePath,
    String? nutriScore,
    DateTime? createdAt,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}

class KeywordsConverter implements JsonConverter<List<String>, String> {
  const KeywordsConverter();

  @override
  List<String> fromJson(String json) {
    if (json.isEmpty) return [];
    return json.split(',');
  }

  @override
  String toJson(List<String> keywords) {
    return keywords.join(',');
  }
}
