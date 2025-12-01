import 'package:injectable/injectable.dart';
import 'package:offline_ecommerce/data/local/daos/sync_queue/sync_queue_dao.dart';
import 'package:offline_ecommerce/data/local/db/app_database_di.dart';

@LazySingleton()
class SyncQueueDaoDI extends SyncQueueDao {
  SyncQueueDaoDI(AppDatabaseProvider provider) : super(provider.db);
}
