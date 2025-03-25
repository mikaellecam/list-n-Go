// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'receipt_product_relation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReceiptProductRelation {

 int get receiptId; int get productId; double get quantity; double? get price; int get position; DateTime? get createdAt;
/// Create a copy of ReceiptProductRelation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceiptProductRelationCopyWith<ReceiptProductRelation> get copyWith => _$ReceiptProductRelationCopyWithImpl<ReceiptProductRelation>(this as ReceiptProductRelation, _$identity);

  /// Serializes this ReceiptProductRelation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReceiptProductRelation&&(identical(other.receiptId, receiptId) || other.receiptId == receiptId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.price, price) || other.price == price)&&(identical(other.position, position) || other.position == position)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,receiptId,productId,quantity,price,position,createdAt);

@override
String toString() {
  return 'ReceiptProductRelation(receiptId: $receiptId, productId: $productId, quantity: $quantity, price: $price, position: $position, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ReceiptProductRelationCopyWith<$Res>  {
  factory $ReceiptProductRelationCopyWith(ReceiptProductRelation value, $Res Function(ReceiptProductRelation) _then) = _$ReceiptProductRelationCopyWithImpl;
@useResult
$Res call({
 int receiptId, int productId, double quantity, double? price, int position, DateTime? createdAt
});




}
/// @nodoc
class _$ReceiptProductRelationCopyWithImpl<$Res>
    implements $ReceiptProductRelationCopyWith<$Res> {
  _$ReceiptProductRelationCopyWithImpl(this._self, this._then);

  final ReceiptProductRelation _self;
  final $Res Function(ReceiptProductRelation) _then;

/// Create a copy of ReceiptProductRelation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? receiptId = null,Object? productId = null,Object? quantity = null,Object? price = freezed,Object? position = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
receiptId: null == receiptId ? _self.receiptId : receiptId // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _ReceiptProductRelation implements ReceiptProductRelation {
  const _ReceiptProductRelation({required this.receiptId, required this.productId, this.quantity = 1, this.price, this.position = 0, this.createdAt});
  factory _ReceiptProductRelation.fromJson(Map<String, dynamic> json) => _$ReceiptProductRelationFromJson(json);

@override final  int receiptId;
@override final  int productId;
@override@JsonKey() final  double quantity;
@override final  double? price;
@override@JsonKey() final  int position;
@override final  DateTime? createdAt;

/// Create a copy of ReceiptProductRelation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReceiptProductRelationCopyWith<_ReceiptProductRelation> get copyWith => __$ReceiptProductRelationCopyWithImpl<_ReceiptProductRelation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReceiptProductRelationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReceiptProductRelation&&(identical(other.receiptId, receiptId) || other.receiptId == receiptId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.price, price) || other.price == price)&&(identical(other.position, position) || other.position == position)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,receiptId,productId,quantity,price,position,createdAt);

@override
String toString() {
  return 'ReceiptProductRelation(receiptId: $receiptId, productId: $productId, quantity: $quantity, price: $price, position: $position, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ReceiptProductRelationCopyWith<$Res> implements $ReceiptProductRelationCopyWith<$Res> {
  factory _$ReceiptProductRelationCopyWith(_ReceiptProductRelation value, $Res Function(_ReceiptProductRelation) _then) = __$ReceiptProductRelationCopyWithImpl;
@override @useResult
$Res call({
 int receiptId, int productId, double quantity, double? price, int position, DateTime? createdAt
});




}
/// @nodoc
class __$ReceiptProductRelationCopyWithImpl<$Res>
    implements _$ReceiptProductRelationCopyWith<$Res> {
  __$ReceiptProductRelationCopyWithImpl(this._self, this._then);

  final _ReceiptProductRelation _self;
  final $Res Function(_ReceiptProductRelation) _then;

/// Create a copy of ReceiptProductRelation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? receiptId = null,Object? productId = null,Object? quantity = null,Object? price = freezed,Object? position = null,Object? createdAt = freezed,}) {
  return _then(_ReceiptProductRelation(
receiptId: null == receiptId ? _self.receiptId : receiptId // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
