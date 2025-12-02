import 'package:drift/drift.dart';
import '../../db/app_database.dart';

part 'sync_queue_dao.g.dart';

@DriftAccessor(tables: [SyncQueue])
class SyncQueueDao extends DatabaseAccessor<AppDatabase>
    with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);

  Future<int> enqueue({
    required String operation,
    required String tableName,
    required String payload,
  }) {
    return into(syncQueue).insert(
      SyncQueueCompanion.insert(
        operation: operation,
        tablename: tableName,
        payload: payload,
        createdAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<SyncQueueData>> getPendingJobs() {
    return (select(
      syncQueue,
    )..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)])).get();
  }

  Future<void> removeJob(int id) {
    return (delete(syncQueue)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<void> clearQueue() async {
    await delete(syncQueue).go();
  }
}
