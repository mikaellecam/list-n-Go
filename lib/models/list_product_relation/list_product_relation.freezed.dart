// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'list_product_relation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ListProductRelation {

 int get listId; int get productId; double get quantity; double? get price; bool get isChecked; int get position; DateTime? get createdAt;
/// Create a copy of ListProductRelation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListProductRelationCopyWith<ListProductRelation> get copyWith => _$ListProductRelationCopyWithImpl<ListProductRelation>(this as ListProductRelation, _$identity);

  /// Serializes this ListProductRelation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListProductRelation&&(identical(other.listId, listId) || other.listId == listId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.price, price) || other.price == price)&&(identical(other.isChecked, isChecked) || other.isChecked == isChecked)&&(identical(other.position, position) || other.position == position)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,listId,productId,quantity,price,isChecked,position,createdAt);

@override
String toString() {
  return 'ListProductRelation(listId: $listId, productId: $productId, quantity: $quantity, price: $price, isChecked: $isChecked, position: $position, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ListProductRelationCopyWith<$Res>  {
  factory $ListProductRelationCopyWith(ListProductRelation value, $Res Function(ListProductRelation) _then) = _$ListProductRelationCopyWithImpl;
@useResult
$Res call({
 int listId, int productId, double quantity, double? price, bool isChecked, int position, DateTime? createdAt
});




}
/// @nodoc
class _$ListProductRelationCopyWithImpl<$Res>
    implements $ListProductRelationCopyWith<$Res> {
  _$ListProductRelationCopyWithImpl(this._self, this._then);

  final ListProductRelation _self;
  final $Res Function(ListProductRelation) _then;

/// Create a copy of ListProductRelation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? listId = null,Object? productId = null,Object? quantity = null,Object? price = freezed,Object? isChecked = null,Object? position = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
listId: null == listId ? _self.listId : listId // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,isChecked: null == isChecked ? _self.isChecked : isChecked // ignore: cast_nullable_to_non_nullable
as bool,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _ListProductRelation implements ListProductRelation {
  const _ListProductRelation({required this.listId, required this.productId, this.quantity = 1, this.price, this.isChecked = false, this.position = 0, this.createdAt});
  factory _ListProductRelation.fromJson(Map<String, dynamic> json) => _$ListProductRelationFromJson(json);

@override final  int listId;
@override final  int productId;
@override@JsonKey() final  double quantity;
@override final  double? price;
@override@JsonKey() final  bool isChecked;
@override@JsonKey() final  int position;
@override final  DateTime? createdAt;

/// Create a copy of ListProductRelation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListProductRelationCopyWith<_ListProductRelation> get copyWith => __$ListProductRelationCopyWithImpl<_ListProductRelation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListProductRelationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListProductRelation&&(identical(other.listId, listId) || other.listId == listId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.price, price) || other.price == price)&&(identical(other.isChecked, isChecked) || other.isChecked == isChecked)&&(identical(other.position, position) || other.position == position)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,listId,productId,quantity,price,isChecked,position,createdAt);

@override
String toString() {
  return 'ListProductRelation(listId: $listId, productId: $productId, quantity: $quantity, price: $price, isChecked: $isChecked, position: $position, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ListProductRelationCopyWith<$Res> implements $ListProductRelationCopyWith<$Res> {
  factory _$ListProductRelationCopyWith(_ListProductRelation value, $Res Function(_ListProductRelation) _then) = __$ListProductRelationCopyWithImpl;
@override @useResult
$Res call({
 int listId, int productId, double quantity, double? price, bool isChecked, int position, DateTime? createdAt
});




}
/// @nodoc
class __$ListProductRelationCopyWithImpl<$Res>
    implements _$ListProductRelationCopyWith<$Res> {
  __$ListProductRelationCopyWithImpl(this._self, this._then);

  final _ListProductRelation _self;
  final $Res Function(_ListProductRelation) _then;

/// Create a copy of ListProductRelation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? listId = null,Object? productId = null,Object? quantity = null,Object? price = freezed,Object? isChecked = null,Object? position = null,Object? createdAt = freezed,}) {
  return _then(_ListProductRelation(
listId: null == listId ? _self.listId : listId // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,isChecked: null == isChecked ? _self.isChecked : isChecked // ignore: cast_nullable_to_non_nullable
as bool,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
