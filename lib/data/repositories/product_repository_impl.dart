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

  @override
  Future<List<ProductEntity>> getProducts() async {
    final localProducts = await productsDao.getAllProducts();
    final products = localProducts
        .map((row) => ProductModel.fromDrift(row).toEntity())
        .toList();

    if (await networkInfo.isConnected) {
      try {
        final remoteProducts = await remoteDataSource.getProducts();

        await productsDao.clearProducts();

        final companions = remoteProducts
            .map((p) => p.toCompanion())
            .toList(growable: false);

        await productsDao.insertProducts(companions);
      } catch (_) {
      }
    }

    return products;
  }

  @override
  Future<ProductEntity?> getProduct(int id) async {
    final local = await productsDao.getProductByRemoteId(id);
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

  @override
  Future<void> addProduct(ProductEntity product) async {
    final model = ProductModel.fromEntity(product);
    final localRowId = await productsDao.insertProduct(model.toCompanion());

    if (await networkInfo.isConnected) {
      try {
        final remoteProduct = await remoteDataSource.addProduct(model);

        final localRow = await productsDao.getProductById(localRowId);
        if (localRow != null) {
          final updatedRow = localRow.copyWith(
            remoteId: Value(remoteProduct.id),
          );
          await productsDao.updateProduct(updatedRow);
        }
      } catch (e) {
        await syncQueueDao.enqueue(
          operation: 'add',
          tableName: 'products',
          payload: jsonEncode(model.toMap()),
        );
      }
    } else {
      await syncQueueDao.enqueue(
        operation: 'add',
        tableName: 'products',
        payload: jsonEncode(model.toMap()),
      );

      print("[ADD] Offline → enqueueing");
    }
  }

  @override
  Future<void> updateProduct(ProductEntity product) async {
    final model = ProductModel.fromEntity(product);

    Product? localRow;
    if (model.id != null) {
      localRow = await productsDao.getProductByRemoteId(model.id!);
    }

    if (localRow == null) {
      final allLocal = await productsDao.getAllProducts();
      final maybe = allLocal.firstWhere(
        (r) => r.name == model.name && (r.remoteId == null),
        orElse: () => null as Product,
      );
      if (maybe != null) {
        localRow = maybe;
      }
    }

    final updatedRow = localRow.copyWith(
      name: model.name,
      price: model.price,
      stock: model.stock,
      description: Value(model.description),
      imageUrl: Value(model.imageUrl),
    );
    await productsDao.updateProduct(updatedRow);

    final isOnline = await networkInfo.isConnected;

    if (isOnline) {
      try {
        if (model.id == null) {
          final newRemote = await remoteDataSource.addProduct(model);
          await productsDao.insertProduct(newRemote.toCompanion());
        } else {
          await remoteDataSource.updateProduct(model);
        }

        return;
      } catch (e) {
        await syncQueueDao.enqueue(
          operation: 'update',
          tableName: 'products',
          payload: jsonEncode(model.toMap()),
        );

        return;
      }
    }

    await syncQueueDao.enqueue(
      operation: 'update',
      tableName: 'products',
      payload: jsonEncode(model.toMap()),
    );
  }

  @override
  Future<void> deleteProduct(int id) async {
    final localRow = await productsDao.getProductByRemoteId(id);
    if (localRow != null) {
      await productsDao.deleteProduct(localRow.id);
    }

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
