import 'package:drift/drift.dart';
import '../../db/app_database.dart';

part 'products_dao.g.dart';

@DriftAccessor(tables: [Products])
class ProductsDao extends DatabaseAccessor<AppDatabase> with _$ProductsDaoMixin {
  final AppDatabase db;

  ProductsDao(this.db) : super(db);

  /// Get all products
  Future<List<Product>> getAllProducts() => select(products).get();

  /// Get a single product by local primary key id
  Future<Product?> getProductById(int id) =>
      (select(products)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  /// Get a single product by remote (supabase) id
  Future<Product?> getProductByRemoteId(int remoteId) =>
      (select(products)..where((tbl) => tbl.remoteId.equals(remoteId)))
          .getSingleOrNull();

  /// Insert a product. Returns inserted local row id (primary key).
  Future<int> insertProduct(ProductsCompanion product) =>
      into(products).insert(product);

  /// Insert multiple products
  Future<void> insertProducts(List<ProductsCompanion> productsList) async {
    await batch((batch) {
      batch.insertAll(products, productsList);
    });
  }

  /// Update a product (replace by local primary key)
  Future<bool> updateProduct(Product product) => update(products).replace(product);

  /// Delete a product by local primary key
  Future<int> deleteProduct(int id) =>
      (delete(products)..where((tbl) => tbl.id.equals(id))).go();

  /// Clear all products
  Future<int> clearProducts() => delete(products).go();

  /// Watch all products as a stream
  Stream<List<Product>> watchAllProducts() {
    return select(products).watch();
  }
}