import 'package:drift/drift.dart';
import '../../db/app_database.dart';

part 'sync_queue_dao.g.dart';

@DriftAccessor(tables: [SyncQueue])
class SyncQueueDao extends DatabaseAccessor<AppDatabase>
    with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);

  /// Add a job to the queue
  Future<int> enqueue({
    required String operation, // "add" | "update" | "delete"
    required String tableName, // e.g. "products"
    required String payload, // JSON string
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

  /// Retrieve all queued jobs ordered by creation time (FIFO)
  Future<List<SyncQueueData>> getPendingJobs() {
    return (select(
      syncQueue,
    )..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)])).get();
  }

  /// Delete a job after successful remote sync
  Future<void> removeJob(int id) {
    return (delete(syncQueue)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// For debugging: clear whole queue
  Future<void> clearQueue() async {
    await delete(syncQueue).go();
  }
}
