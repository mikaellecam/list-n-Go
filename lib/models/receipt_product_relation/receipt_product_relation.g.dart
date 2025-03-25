// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_product_relation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReceiptProductRelation _$ReceiptProductRelationFromJson(
  Map<String, dynamic> json,
) => _ReceiptProductRelation(
  receiptId: (json['receiptId'] as num).toInt(),
  productId: (json['productId'] as num).toInt(),
  quantity: (json['quantity'] as num?)?.toDouble() ?? 1,
  price: (json['price'] as num?)?.toDouble(),
  position: (json['position'] as num?)?.toInt() ?? 0,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ReceiptProductRelationToJson(
  _ReceiptProductRelation instance,
) => <String, dynamic>{
  'receiptId': instance.receiptId,
  'productId': instance.productId,
  'quantity': instance.quantity,
  'price': instance.price,
  'position': instance.position,
  'createdAt': instance.createdAt?.toIso8601String(),
};
