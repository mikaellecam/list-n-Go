import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_list.freezed.dart';
part 'product_list.g.dart';

DateTime _defaultDateTimeNow() => DateTime.now();

@freezed
abstract class ProductList with _$ProductList {
  const factory ProductList({
    int? id,
    required int userId,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ProductList;

  factory ProductList.fromJson(Map<String, dynamic> json) =>
      _$ProductListFromJson(json);

  factory ProductList.createNew({required int userId, required String name}) {
    final now = DateTime.now();
    return ProductList(
      userId: userId,
      name: name,
      createdAt: now,
      updatedAt: now,
    );
  }
}
