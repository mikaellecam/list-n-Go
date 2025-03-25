import 'package:freezed_annotation/freezed_annotation.dart';

part 'list_product_relation.freezed.dart';
part 'list_product_relation.g.dart';

@freezed
abstract class ListProductRelation with _$ListProductRelation {
  const factory ListProductRelation({
    required int listId,
    required int productId,
    @Default(1) double quantity,
    double? price,
    @Default(false) bool isChecked,
    @Default(0) int position,
    DateTime? createdAt,
  }) = _ListProductRelation;

  factory ListProductRelation.fromJson(Map<String, dynamic> json) =>
      _$ListProductRelationFromJson(json);
}
