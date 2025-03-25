// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_product_relation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ListProductRelation _$ListProductRelationFromJson(Map<String, dynamic> json) =>
    _ListProductRelation(
      listId: (json['listId'] as num).toInt(),
      productId: (json['productId'] as num).toInt(),
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1,
      price: (json['price'] as num?)?.toDouble(),
      isChecked: json['isChecked'] as bool? ?? false,
      position: (json['position'] as num?)?.toInt() ?? 0,
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ListProductRelationToJson(
  _ListProductRelation instance,
) => <String, dynamic>{
  'listId': instance.listId,
  'productId': instance.productId,
  'quantity': instance.quantity,
  'price': instance.price,
  'isChecked': instance.isChecked,
  'position': instance.position,
  'createdAt': instance.createdAt?.toIso8601String(),
};
