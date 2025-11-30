import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'product_state.dart';

import 'package:offline_ecommerce/domain/entities/product_entity.dart';
import 'package:offline_ecommerce/domain/usecases/product/get_products_usecase.dart';
import 'package:offline_ecommerce/domain/usecases/product/get_product_usecase.dart';
import 'package:offline_ecommerce/domain/usecases/product/add_product_usecase.dart';
import 'package:offline_ecommerce/domain/usecases/product/update_product_usecase.dart';
import 'package:offline_ecommerce/domain/usecases/product/delete_product_usecase.dart';

/// Annotate with @injectable so Injectable knows to register this in GetIt
@injectable
class ProductCubit extends Cubit<ProductState> {
  final GetProductsUseCase getProductsUseCase;
  final GetProductUseCase getProductUseCase;
  final AddProductUseCase addProductUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final DeleteProductUseCase deleteProductUseCase;

  /// Positional parameters are easier for Injectable
  ProductCubit(
    this.getProductsUseCase,
    this.getProductUseCase,
    this.addProductUseCase,
    this.updateProductUseCase,
    this.deleteProductUseCase,
  ) : super(ProductInitial());

  /// Load all products
  Future<void> loadProducts() async {
    emit(ProductLoading());
    try {
      final products = await getProductsUseCase();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  /// Add product
  Future<void> addProduct(ProductEntity product) async {
    emit(ProductLoading());
    try {
      await addProductUseCase(product);
      emit(ProductAdded());
      await loadProducts();
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  /// Update product
  Future<void> updateProduct(ProductEntity product) async {
    emit(ProductLoading());
    try {
      await updateProductUseCase(product);
      emit(ProductUpdated());
      await loadProducts();
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  /// Delete product
  Future<void> deleteProduct(int id) async {
    emit(ProductLoading());
    try {
      await deleteProductUseCase(id);
      emit(ProductDeleted());
      await loadProducts();
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> seedDummyProducts() async {
    final dummy = [
      ProductEntity(name: "Wireless Earbuds", price: 29.99, stock: 120),
      ProductEntity(name: "Smart LED Bulb", price: 9.99, stock: 300),
      ProductEntity(name: "Bluetooth Speaker", price: 49.99, stock: 80),
      ProductEntity(name: "USB-C Cable", price: 5.49, stock: 500),
      ProductEntity(name: "Gaming Mouse", price: 25.00, stock: 50),
      ProductEntity(name: "Laptop Stand", price: 19.99, stock: 60),
      ProductEntity(name: "Water Bottle", price: 12.99, stock: 200),
      ProductEntity(name: "Notebook", price: 3.99, stock: 100),
      ProductEntity(name: "Phone Holder", price: 7.99, stock: 150),
      ProductEntity(name: "Desk Lamp", price: 15.99, stock: 70),
    ];

    for (final p in dummy) {
      await addProduct(p);
    }

    await loadProducts();
  }
}
