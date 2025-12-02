import 'package:drift/drift.dart';
import '../../db/app_database.dart';

part 'products_dao.g.dart';

@DriftAccessor(tables: [Products])
class ProductsDao extends DatabaseAccessor<AppDatabase> with _$ProductsDaoMixin {
  final AppDatabase db;

  ProductsDao(this.db) : super(db);

  Future<List<Product>> getAllProducts() => select(products).get();

  Future<Product?> getProductById(int id) =>
      (select(products)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<Product?> getProductByRemoteId(int remoteId) =>
      (select(products)..where((tbl) => tbl.remoteId.equals(remoteId)))
          .getSingleOrNull();

  Future<int> insertProduct(ProductsCompanion product) =>
      into(products).insert(product);

  Future<void> insertProducts(List<ProductsCompanion> productsList) async {
    await batch((batch) {
      batch.insertAll(products, productsList);
    });
  }

  Future<bool> updateProduct(Product product) => update(products).replace(product);

  Future<int> deleteProduct(int id) =>
      (delete(products)..where((tbl) => tbl.id.equals(id))).go();

  Future<int> clearProducts() => delete(products).go();

  Stream<List<Product>> watchAllProducts() {
    return select(products).watch();
  }
}