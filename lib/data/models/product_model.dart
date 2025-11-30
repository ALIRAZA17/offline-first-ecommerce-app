import 'package:drift/drift.dart';
import 'package:offline_ecommerce/data/local/db/app_database.dart';
import 'package:offline_ecommerce/domain/entities/product_entity.dart';

class ProductModel {
  final int? id;
  final String name;
  final double price;
  final int stock;
  final String? description;
  final String? imageUrl;

  ProductModel({
    this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.description,
    this.imageUrl,
  });

  /// Convert Drift row -> Model
  factory ProductModel.fromDrift(Product row) {
    return ProductModel(
      id: row.id,
      name: row.name,
      price: row.price,
      stock: row.stock,
      description: row.description,
      imageUrl: row.imageUrl,
    );
  }

  /// Convert Model -> Drift Companion
  ProductsCompanion toCompanion() {
    return ProductsCompanion.insert(
      name: name,
      price: price,
      stock: stock,
      description: Value(description),
      imageUrl: Value(imageUrl),
    );
  }

  /// Convert Model -> Entity
  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      name: name,
      price: price,
      stock: stock,
      description: description,
      imageUrl: imageUrl,
    );
  }

  /// Convert Entity -> Model
  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      price: entity.price,
      stock: entity.stock,
      description: entity.description,
      imageUrl: entity.imageUrl,
    );
  }
}
