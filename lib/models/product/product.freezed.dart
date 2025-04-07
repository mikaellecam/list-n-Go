// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Product {

 int get id; int? get barcode; String get name; List<String>? get keywords; double? get price; bool get isApi; DateTime? get date; String? get imagePath; String? get nutriScore; DateTime? get createdAt;
/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductCopyWith<Product> get copyWith => _$ProductCopyWithImpl<Product>(this as Product, _$identity);

  /// Serializes this Product to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Product&&(identical(other.id, id) || other.id == id)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.keywords, keywords)&&(identical(other.price, price) || other.price == price)&&(identical(other.isApi, isApi) || other.isApi == isApi)&&(identical(other.date, date) || other.date == date)&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath)&&(identical(other.nutriScore, nutriScore) || other.nutriScore == nutriScore)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,barcode,name,const DeepCollectionEquality().hash(keywords),price,isApi,date,imagePath,nutriScore,createdAt);

@override
String toString() {
  return 'Product(id: $id, barcode: $barcode, name: $name, keywords: $keywords, price: $price, isApi: $isApi, date: $date, imagePath: $imagePath, nutriScore: $nutriScore, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ProductCopyWith<$Res>  {
  factory $ProductCopyWith(Product value, $Res Function(Product) _then) = _$ProductCopyWithImpl;
@useResult
$Res call({
 int id, int? barcode, String name, List<String>? keywords, double? price, bool isApi, DateTime? date, String? imagePath, String? nutriScore, DateTime? createdAt
});




}
/// @nodoc
class _$ProductCopyWithImpl<$Res>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._self, this._then);

  final Product _self;
  final $Res Function(Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? barcode = freezed,Object? name = null,Object? keywords = freezed,Object? price = freezed,Object? isApi = null,Object? date = freezed,Object? imagePath = freezed,Object? nutriScore = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,barcode: freezed == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,keywords: freezed == keywords ? _self.keywords : keywords // ignore: cast_nullable_to_non_nullable
as List<String>?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,isApi: null == isApi ? _self.isApi : isApi // ignore: cast_nullable_to_non_nullable
as bool,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,imagePath: freezed == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String?,nutriScore: freezed == nutriScore ? _self.nutriScore : nutriScore // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _Product implements Product {
  const _Product({required this.id, this.barcode, required this.name, final  List<String>? keywords, this.price, this.isApi = true, this.date, this.imagePath, this.nutriScore, this.createdAt}): _keywords = keywords;
  factory _Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

@override final  int id;
@override final  int? barcode;
@override final  String name;
 final  List<String>? _keywords;
@override List<String>? get keywords {
  final value = _keywords;
  if (value == null) return null;
  if (_keywords is EqualUnmodifiableListView) return _keywords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  double? price;
@override@JsonKey() final  bool isApi;
@override final  DateTime? date;
@override final  String? imagePath;
@override final  String? nutriScore;
@override final  DateTime? createdAt;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductCopyWith<_Product> get copyWith => __$ProductCopyWithImpl<_Product>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Product&&(identical(other.id, id) || other.id == id)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._keywords, _keywords)&&(identical(other.price, price) || other.price == price)&&(identical(other.isApi, isApi) || other.isApi == isApi)&&(identical(other.date, date) || other.date == date)&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath)&&(identical(other.nutriScore, nutriScore) || other.nutriScore == nutriScore)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,barcode,name,const DeepCollectionEquality().hash(_keywords),price,isApi,date,imagePath,nutriScore,createdAt);

@override
String toString() {
  return 'Product(id: $id, barcode: $barcode, name: $name, keywords: $keywords, price: $price, isApi: $isApi, date: $date, imagePath: $imagePath, nutriScore: $nutriScore, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ProductCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$ProductCopyWith(_Product value, $Res Function(_Product) _then) = __$ProductCopyWithImpl;
@override @useResult
$Res call({
 int id, int? barcode, String name, List<String>? keywords, double? price, bool isApi, DateTime? date, String? imagePath, String? nutriScore, DateTime? createdAt
});




}
/// @nodoc
class __$ProductCopyWithImpl<$Res>
    implements _$ProductCopyWith<$Res> {
  __$ProductCopyWithImpl(this._self, this._then);

  final _Product _self;
  final $Res Function(_Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? barcode = freezed,Object? name = null,Object? keywords = freezed,Object? price = freezed,Object? isApi = null,Object? date = freezed,Object? imagePath = freezed,Object? nutriScore = freezed,Object? createdAt = freezed,}) {
  return _then(_Product(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,barcode: freezed == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,keywords: freezed == keywords ? _self._keywords : keywords // ignore: cast_nullable_to_non_nullable
as List<String>?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,isApi: null == isApi ? _self.isApi : isApi // ignore: cast_nullable_to_non_nullable
as bool,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,imagePath: freezed == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String?,nutriScore: freezed == nutriScore ? _self.nutriScore : nutriScore // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
