import 'package:drift/drift.dart';
import 'package:offline_ecommerce/data/local/daos/products_dao.dart';
import 'package:offline_ecommerce/data/models/product_model.dart';
import 'package:offline_ecommerce/domain/entities/product_entity.dart';
import 'package:offline_ecommerce/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductsDao productsDao;

  ProductRepositoryImpl(this.productsDao);

  @override
  Future<List<ProductEntity>> getProducts() async {
    final rows = await productsDao.getAllProducts();
    return rows.map((row) => ProductModel.fromDrift(row).toEntity()).toList();
  }

  @override
  Future<ProductEntity?> getProduct(int id) async {
    final row = await productsDao.getProductById(id);
    if (row == null) return null;

    return ProductModel.fromDrift(row).toEntity();
  }

  @override
  Future<void> addProduct(ProductEntity product) async {
    final model = ProductModel.fromEntity(product);
    await productsDao.insertProduct(model.toCompanion());
  }

  @override
  Future<void> updateProduct(ProductEntity product) async {
    final model = ProductModel.fromEntity(product);

    final row = await productsDao.getProductById(product.id!);
    if (row == null) return;

    final updatedRow = row.copyWith(
      name: model.name,
      price: model.price,
      stock: model.stock,
      description: Value(model.description),
      imageUrl: Value(model.imageUrl),
    );

    await productsDao.updateProduct(updatedRow);
  }

  @override
  Future<void> deleteProduct(int id) async {
    await productsDao.deleteProduct(id);
  }
}
