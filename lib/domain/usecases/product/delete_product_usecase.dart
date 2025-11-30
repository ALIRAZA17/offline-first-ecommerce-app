import 'package:injectable/injectable.dart';
import 'package:offline_ecommerce/domain/repositories/product_repository.dart';

@injectable
class DeleteProductUseCase {
  final ProductRepository repository;
  DeleteProductUseCase(this.repository);

  Future<void> call(int id) {
    return repository.deleteProduct(id);
  }
}
