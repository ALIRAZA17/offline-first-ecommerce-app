import 'package:injectable/injectable.dart';
import 'product_cubit.dart';

@injectable
class ProductCubitDI extends ProductCubit {
  ProductCubitDI(
    super.getProducts,
    super.getProduct,
    super.add,
    super.update,
    super.delete,
  );
}
