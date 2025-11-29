import 'package:drift/drift.dart';
import '../db/app_database.dart';

part 'products_dao.g.dart';

@DriftAccessor(tables: [Products])
class ProductsDao extends DatabaseAccessor<AppDatabase> with _$ProductsDaoMixin {
  final AppDatabase db;

  ProductsDao(this.db) : super(db);

  /// Get all products
  Future<List<Product>> getAllProducts() => select(products).get();

  /// Get a single product by id
  Future<Product?> getProductById(int id) =>
      (select(products)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  /// Insert a product
  Future<int> insertProduct(ProductsCompanion product) => into(products).insert(product);

  /// Insert multiple products
  Future<void> insertProducts(List<ProductsCompanion> productsList) async {
    await batch((batch) {
      batch.insertAll(products, productsList);
    });
  }

  /// Update a product
  Future<bool> updateProduct(Product product) => update(products).replace(product);

  /// Delete a product
  Future<int> deleteProduct(int id) =>
      (delete(products)..where((tbl) => tbl.id.equals(id))).go();

  /// Clear all products
  Future<int> clearProducts() => delete(products).go();
}
