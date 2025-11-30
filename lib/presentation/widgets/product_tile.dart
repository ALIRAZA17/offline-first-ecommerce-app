import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offline_ecommerce/domain/entities/product_entity.dart';
import 'package:offline_ecommerce/presentation/widgets/product_form_dialog.dart';
import '../cubits/product/product_cubit.dart';

class ProductTile extends StatelessWidget {
  final ProductEntity product;
  const ProductTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProductCubit>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        title: Text(product.name),
        subtitle: Text('\$${product.price} - Stock: ${product.stock}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => BlocProvider.value(
                    value: context.read<ProductCubit>(),
                    child: ProductFormDialog(product: product),
                  ),
                );
              },
            ),

            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                cubit.deleteProduct(product.id!);
              },
            ),
          ],
        ),
      ),
    );
  }
}
