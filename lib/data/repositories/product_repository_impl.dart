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

        // Clear local DB and insert fresh remote data (preserving remote_id)
        await productsDao.clearProducts();

        final companions = remoteProducts
            .map((p) => p.toCompanion())
            .toList(growable: false);

        await productsDao.insertProducts(companions);
      } catch (_) {
        // Ignore errors, local products still shown
      }
    }

    return products;
  }

  @override
  Future<ProductEntity?> getProduct(int id) async {
    // id here is remote id (supabase id)
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

  /// Offline-first add
  @override
  Future<void> addProduct(ProductEntity product) async {
    final model = ProductModel.fromEntity(product);

    // Always insert locally (remoteId null initially)
    final localRowId = await productsDao.insertProduct(model.toCompanion());

    if (await networkInfo.isConnected) {
      try {
        final remoteProduct = await remoteDataSource.addProduct(model);

        // Update the local row to set remote_id = remoteProduct.id
        final localRow = await productsDao.getProductById(localRowId);
        if (localRow != null) {
          final updatedRow = localRow.copyWith(
            remoteId: Value(remoteProduct.id),
          );
          await productsDao.updateProduct(updatedRow);
        }
      } catch (e) {
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

      print("[ADD] Offline → enqueueing");
    }
  }

  /// Offline-first update
  @override
  Future<void> updateProduct(ProductEntity product) async {
    final model = ProductModel.fromEntity(product);

    // model.id is remote id (nullable)
    // first try to fetch local row by remote id
    Product? localRow;
    if (model.id != null) {
      localRow = await productsDao.getProductByRemoteId(model.id!);
    }

    // If not found by remoteId, maybe the product is local-only (rare). Try to find by name/other heuristics if necessary
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

    // Update local if we have a local primary row
    final updatedRow = localRow.copyWith(
      name: model.name,
      price: model.price,
      stock: model.stock,
      description: Value(model.description),
      imageUrl: Value(model.imageUrl),
    );
    await productsDao.updateProduct(updatedRow);

    // Try remote if online, else enqueue
    final isOnline = await networkInfo.isConnected;
    print("[UPDATE] Network status → ${isOnline ? 'ONLINE' : 'OFFLINE'}");

    if (isOnline) {
      try {
        // if model.id is null we cannot update remote (we must add instead)
        if (model.id == null) {
          final newRemote = await remoteDataSource.addProduct(model);
          // insert the remote product into local DB
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

    // Offline → queue
    await syncQueueDao.enqueue(
      operation: 'update',
      tableName: 'products',
      payload: jsonEncode(model.toMap()),
    );
  }

  /// Offline-first delete
  @override
  Future<void> deleteProduct(int id) async {
    // id is remote id
    // Delete locally: find row by remote id and delete the local primary id
    final localRow = await productsDao.getProductByRemoteId(id);
    if (localRow != null) {
      await productsDao.deleteProduct(localRow.id);
    }

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

  /// Called by the sync queue processor when adding from map
  @override
  Future<void> addProductFromMap(Map<String, dynamic> map) async {
    final product = ProductModel.fromMap(map).toEntity();
    await addProduct(product);
  }

  /// Called by the sync queue processor when updating from map
  @override
  Future<void> updateProductFromMap(Map<String, dynamic> map) async {
    final product = ProductModel.fromMap(map).toEntity();
    await updateProduct(product);
  }
}
