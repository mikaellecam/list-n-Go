import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_list.freezed.dart';
part 'product_list.g.dart';

@freezed
abstract class ProductList with _$ProductList {
  const factory ProductList({
    int? id,
    required int userId,
    required String name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ProductList;

  factory ProductList.fromJson(Map<String, dynamic> json) =>
      _$ProductListFromJson(json);
}
