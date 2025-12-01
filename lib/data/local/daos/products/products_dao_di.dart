import 'package:injectable/injectable.dart';
import 'package:offline_ecommerce/data/local/daos/products/products_dao.dart';
import 'package:offline_ecommerce/data/local/db/app_database_di.dart';

@LazySingleton()
class ProductsDaoDI extends ProductsDao {
  ProductsDaoDI(AppDatabaseProvider provider) : super(provider.db);
}
