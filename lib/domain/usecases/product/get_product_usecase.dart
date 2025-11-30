
import 'package:injectable/injectable.dart';
import 'package:offline_ecommerce/domain/entities/product_entity.dart';
import 'package:offline_ecommerce/domain/repositories/product_repository.dart';

@injectable
class GetProductUseCase {
  final ProductRepository repository;
  GetProductUseCase(this.repository);

  Future<ProductEntity?> call(int id) {
    return repository.getProduct(id);
  }
}
