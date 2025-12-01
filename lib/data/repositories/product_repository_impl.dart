import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:offline_ecommerce/data/local/daos/products/products_dao.dart';
import 'package:offline_ecommerce/data/local/daos/sync_queue/sync_queue_dao.dart';
import 'package:offline_ecommerce/data/local/db/app_database.dart';
import 'package:offline_ecommerce/data/models/product_model.dart';
import 'package:offline_ecommerce/domain/entities/product_entity.dart';
import 'package:offline_ecommerce/domain/repositories/product_repository.dart';
import '../remote/product_remote_data_source.dart';
import '../../core/network/network_info.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductsDao productsDao;
  final SyncQueueDao syncQueueDao;
  final ProductRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ProductRepositoryImpl({
    required this.productsDao,
    required this.syncQueueDao,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  /// Offline-first getProducts
  @override
  Future<List<ProductEntity>> getProducts() async {
    // Step 1: Read from local DB first
    final localProducts = await productsDao.getAllProducts();
    final products = localProducts
        .map((row) => ProductModel.fromDrift(row).toEntity())
        .toList();

    // Step 2: Background sync with remote
    if (await networkInfo.isConnected) {
      try {
        final remoteProducts = await remoteDataSource.getProducts();

        // Clear local DB and insert fresh remote data
        await productsDao.clearProducts();
        await productsDao.insertProducts(
          remoteProducts.map((p) => p.toCompanion()).toList(),
        );
      } catch (_) {
        // Ignore errors, local products still shown
      }
    }

    return products;
  }

  @override
  Future<ProductEntity?> getProduct(int id) async {
    final local = await productsDao.getProductById(id);
    if (local != null) return ProductModel.fromDrift(local).toEntity();

    if (await networkInfo.isConnected) {
      try {
        final remoteProducts = await remoteDataSource.getProducts();
        final product = remoteProducts.firstWhere((p) => p.id == id);
        await productsDao.insertProduct(product.toCompanion());
        return product.toEntity();
      } catch (_) {}
    }

    return null;
  }

  /// Offline-first add
  @override
  Future<void> addProduct(ProductEntity product) async {
    final model = ProductModel.fromEntity(product);

    // Always insert locally
    await productsDao.insertProduct(model.toCompanion());

    if (await networkInfo.isConnected) {
      try {
        final remoteProduct = await remoteDataSource.addProduct(model);

        // Update local DB with remote ID
        final row = await productsDao.getProductById(model.id ?? 0);
        if (row != null) {
          final updatedRow = Product(
            id: remoteProduct.id!,
            name: remoteProduct.name,
            price: remoteProduct.price,
            stock: remoteProduct.stock,
            description: remoteProduct.description,
            imageUrl: remoteProduct.imageUrl,
          );
          await productsDao.updateProduct(updatedRow);
        }
      } catch (_) {
        // If fails, enqueue
        await syncQueueDao.enqueue(
          operation: 'add',
          tableName: 'products',
          payload: jsonEncode(model.toMap()),
        );
      }
    } else {
      // Offline → enqueue
      await syncQueueDao.enqueue(
        operation: 'add',
        tableName: 'products',
        payload: jsonEncode(model.toMap()),
      );
    }
  }

  /// Offline-first update
  @override
  Future<void> updateProduct(ProductEntity product) async {
    final model = ProductModel.fromEntity(product);

    // Update local DB
    final row = await productsDao.getProductById(model.id!);
    if (row != null) {
      final updatedRow = row.copyWith(
        name: model.name,
        price: model.price,
        stock: model.stock,
        description: Value(model.description),
        imageUrl: Value(model.imageUrl),
      );
      await productsDao.updateProduct(updatedRow);
    }

    // Try remote if online, else enqueue
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateProduct(model);
      } catch (_) {
        await syncQueueDao.enqueue(
          operation: 'update',
          tableName: 'products',
          payload: jsonEncode(model.toMap()),
        );
      }
    } else {
      await syncQueueDao.enqueue(
        operation: 'update',
        tableName: 'products',
        payload: jsonEncode(model.toMap()),
      );
    }
  }

  /// Offline-first delete
  @override
  Future<void> deleteProduct(int id) async {
    // Delete locally
    await productsDao.deleteProduct(id);

    // Try remote if online, else enqueue
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteProduct(id);
      } catch (_) {
        await syncQueueDao.enqueue(
          operation: 'delete',
          tableName: 'products',
          payload: jsonEncode({'id': id}),
        );
      }
    } else {
      await syncQueueDao.enqueue(
        operation: 'delete',
        tableName: 'products',
        payload: jsonEncode({'id': id}),
      );
    }
  }

  @override
  Future<void> addProductFromMap(Map<String, dynamic> map) async {
    final product = ProductModel.fromMap(map).toEntity();
    await addProduct(product);
  }

  @override
  Future<void> updateProductFromMap(Map<String, dynamic> map) async {
    final product = ProductModel.fromMap(map).toEntity();
    await updateProduct(product);
  }
}
