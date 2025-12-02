import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:offline_ecommerce/core/network/network_info.dart';
import 'package:offline_ecommerce/data/local/daos/sync_queue/sync_queue_dao_di.dart';
import 'package:offline_ecommerce/domain/repositories/product_repository.dart';

@LazySingleton()
class SyncQueueService {
  final SyncQueueDaoDI syncQueueDao;
  final ProductRepository productRepository;
  final NetworkInfo networkInfo;

  SyncQueueService({
    required this.syncQueueDao,
    required this.productRepository,
    required this.networkInfo,
  });

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

        await syncQueueDao.removeJob(job.id);
      } catch (_) {
      }
    }
  }
}
