import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offline_ecommerce/presentation/cubits/product/product_cubit.dart';
import 'package:offline_ecommerce/presentation/cubits/product/product_state.dart';
import 'package:offline_ecommerce/presentation/widgets/product_form_dialog.dart';
import 'package:offline_ecommerce/presentation/widgets/product_tile.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductLoaded) {
            final products = state.products;
            if (products.isEmpty) {
              return const Center(child: Text('No products available'));
            }
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductTile(product: product);
              },
            );
          } else if (state is ProductError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Use BlocProvider.value to ensure dialogs access the same Cubit
          showDialog(
            context: context,
            builder: (_) => BlocProvider.value(
              value: context.read<ProductCubit>(),
              child: const ProductFormDialog(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
