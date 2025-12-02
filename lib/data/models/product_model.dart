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

  factory ProductModel.fromDrift(Product row) {
    return ProductModel(
      id: row.remoteId,
      name: row.name,
      price: row.price,
      stock: row.stock,
      description: row.description,
      imageUrl: row.imageUrl,
    );
  }

  ProductsCompanion toCompanion() {
    return ProductsCompanion.insert(
      name: name,
      price: price,
      stock: stock,
      description: Value(description),
      imageUrl: Value(imageUrl),
      remoteId: Value(id),
    );
  }

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

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      stock: map['stock'] as int,
      description: map['description'] as String?,
      imageUrl: map['image_url'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'price': price,
      'stock': stock,
      'description': description,
      'image_url': imageUrl,
    };
  }
}
