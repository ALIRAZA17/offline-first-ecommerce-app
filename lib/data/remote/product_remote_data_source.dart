import 'package:injectable/injectable.dart';
import 'package:offline_ecommerce/data/models/product_model.dart';
import 'package:offline_ecommerce/core/network/supabase_initializer.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<ProductModel> addProduct(ProductModel product);
  Future<ProductModel> updateProduct(ProductModel product);
  Future<void> deleteProduct(int id);
}

@LazySingleton(as: ProductRemoteDataSource)
class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final _client = SupabaseInitializer.client;

  @override
  Future<List<ProductModel>> getProducts() async {
    final response = await _client.from('products').select();
    return (response as List).map((e) => ProductModel.fromMap(e)).toList();
  }

  @override
  Future<ProductModel> addProduct(ProductModel product) async {
    final response = await _client
        .from('products')
        .insert(product.toMap())
        .select()
        .single();
    return ProductModel.fromMap(response);
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    if (product.id == null) {
      throw Exception('Product ID is required for update');
    }
    final response = await _client
        .from('products')
        .update(product.toMap())
        .eq('id', product.id!)
        .select()
        .single();
    return ProductModel.fromMap(response);
  }

  @override
  Future<void> deleteProduct(int id) async {
    await _client.from('products').delete().eq('id', id);
  }
}
