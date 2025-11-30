import 'package:injectable/injectable.dart';
import 'package:offline_ecommerce/domain/entities/product_entity.dart';
import 'package:offline_ecommerce/domain/repositories/product_repository.dart';


@injectable
class UpdateProductUseCase {
  final ProductRepository repository;
  UpdateProductUseCase(this.repository);

  Future<void> call(ProductEntity product) {
    return repository.updateProduct(product);
  }
}
