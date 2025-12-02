import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offline_ecommerce/core/di/connectivity_di.dart';
import 'package:offline_ecommerce/core/di/injection.dart';
import 'package:offline_ecommerce/core/network/supabase_initializer.dart';
import 'package:offline_ecommerce/data/local/daos/sync_queue/sync_queue_service.dart';
import 'package:offline_ecommerce/presentation/pages/product_page.dart';
import 'package:offline_ecommerce/presentation/cubits/product/product_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseInitializer.initialize();

  await configureDependencies();

  final syncService = getIt<SyncQueueService>();
  await syncService.flushQueue();

  final connectivity =
      getIt<ConnectivityDI>().connectivity;
  connectivity.onConnectivityChanged.listen((_) async {
    await syncService.flushQueue();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Offline E-commerce',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeWrapper(),
    );
  }
}

class HomeWrapper extends StatelessWidget {
  const HomeWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProductCubit>()..loadProducts(),
      child: const ProductPage(),
    );
  }
}
