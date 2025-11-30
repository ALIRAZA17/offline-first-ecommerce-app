
import 'package:injectable/injectable.dart';
import 'package:offline_ecommerce/domain/entities/product_entity.dart';
import 'package:offline_ecommerce/domain/repositories/product_repository.dart';

@injectable
class GetProductsUseCase {
  final ProductRepository repository;
  GetProductsUseCase(this.repository);

  Future<List<ProductEntity>> call() {
    return repository.getProducts();
  }
}
