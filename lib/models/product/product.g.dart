// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  id: (json['id'] as num).toInt(),
  barcode: (json['barcode'] as num?)?.toInt(),
  name: json['name'] as String,
  keywords:
      (json['keywords'] as List<dynamic>?)?.map((e) => e as String).toList(),
  price: (json['price'] as num?)?.toDouble(),
  isApi: json['isApi'] as bool? ?? true,
  date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
  imagePath: json['imagePath'] as String?,
  nutriScore: json['nutriScore'] as String?,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  'id': instance.id,
  'barcode': instance.barcode,
  'name': instance.name,
  'keywords': instance.keywords,
  'price': instance.price,
  'isApi': instance.isApi,
  'date': instance.date?.toIso8601String(),
  'imagePath': instance.imagePath,
  'nutriScore': instance.nutriScore,
  'createdAt': instance.createdAt?.toIso8601String(),
};
