import 'package:injectable/injectable.dart';
import 'package:offline_ecommerce/data/local/daos/products/products_dao_di.dart';
import 'package:offline_ecommerce/data/local/daos/sync_queue/sync_queue_dao_di.dart';
import 'package:offline_ecommerce/data/repositories/product_repository_impl.dart';
import '../remote/product_remote_data_source.dart';
import '../../core/network/network_info.dart';
import '../../domain/repositories/product_repository.dart';

@LazySingleton(as: ProductRepository)
class ProductRepositoryDI extends ProductRepositoryImpl {
  ProductRepositoryDI(
    ProductsDaoDI productsDao,
    SyncQueueDaoDI syncQueueDao,
    ProductRemoteDataSource remoteDataSource,
    NetworkInfo networkInfo,
  ) : super(
          productsDao: productsDao,
          syncQueueDao: syncQueueDao,
          remoteDataSource: remoteDataSource,
          networkInfo: networkInfo,
        );
}
