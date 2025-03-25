import 'package:freezed_annotation/freezed_annotation.dart';

part 'receipt_product_relation.freezed.dart';
part 'receipt_product_relation.g.dart';

@freezed
abstract class ReceiptProductRelation with _$ReceiptProductRelation {
  const factory ReceiptProductRelation({
    required int receiptId,
    required int productId,
    @Default(1) double quantity,
    double? price,
    @Default(0) int position,
    DateTime? createdAt,
  }) = _ReceiptProductRelation;

  factory ReceiptProductRelation.fromJson(Map<String, dynamic> json) =>
      _$ReceiptProductRelationFromJson(json);
}
