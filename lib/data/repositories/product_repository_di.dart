import 'package:injectable/injectable.dart';
import 'package:offline_ecommerce/data/local/daos/products_dao_di.dart';
import 'package:offline_ecommerce/data/repositories/product_repository_impl.dart';
import '../../domain/repositories/product_repository.dart';

@LazySingleton(as: ProductRepository)
class ProductRepositoryDI extends ProductRepositoryImpl {
  ProductRepositoryDI(ProductsDaoDI super.dao);
}
