import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offline_ecommerce/core/di/injection.dart';
import 'package:offline_ecommerce/presentation/pages/product_page.dart';
import 'package:offline_ecommerce/presentation/cubits/product/product_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await configureDependencies();

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

/// Provide ProductCubit globally so dialogs/tiles can access it
class HomeWrapper extends StatelessWidget {
  const HomeWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProductCubit>()
        ..loadProducts()
        ..seedDummyProducts(),

      child: const ProductPage(),
    );
  }
}
