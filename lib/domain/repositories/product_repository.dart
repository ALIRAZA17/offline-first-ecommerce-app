
import 'package:offline_ecommerce/domain/entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getProducts();
  Future<ProductEntity?> getProduct(int id);
  Future<void> addProduct(ProductEntity product);
  Future<void> updateProduct(ProductEntity product);
  Future<void> deleteProduct(int id);
  Future<void> addProductFromMap(Map<String, dynamic> productMap);
  Future<void> updateProductFromMap(Map<String, dynamic> productMap);
  
}
