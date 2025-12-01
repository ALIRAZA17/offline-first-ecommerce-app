import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:offline_ecommerce/core/network/network_info.dart';
import 'package:offline_ecommerce/data/local/daos/sync_queue/sync_queue_dao_di.dart';
import 'package:offline_ecommerce/domain/repositories/product_repository.dart';

/// A service that continuously flushes the SyncQueue whenever online
@LazySingleton()
class SyncQueueService {
  final SyncQueueDaoDI syncQueueDao; // inject DI version
  final ProductRepository productRepository; // inject DI version
  final NetworkInfo networkInfo;

  SyncQueueService({
    required this.syncQueueDao,
    required this.productRepository,
    required this.networkInfo,
  });

  /// Flush all pending jobs in order (FIFO)
  Future<void> flushQueue() async {
    if (!await networkInfo.isConnected) return;

    final jobs = await syncQueueDao.getPendingJobs();

    for (final job in jobs) {
      try {
        switch (job.operation) {
          case 'add':
            final productMap = jsonDecode(job.payload);
            await productRepository.addProductFromMap(productMap);
            break;

          case 'update':
            final productMap = jsonDecode(job.payload);
            await productRepository.updateProductFromMap(productMap);
            break;

          case 'delete':
            final payload = jsonDecode(job.payload);
            final id = payload['id'] as int;
            await productRepository.deleteProduct(id);
            break;
        }

        // Remove job from queue after success
        await syncQueueDao.removeJob(job.id);
      } catch (_) {
        // Ignore errors and continue with next job
      }
    }
  }
}
