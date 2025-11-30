import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offline_ecommerce/domain/entities/product_entity.dart';
import '../cubits/product/product_cubit.dart';

class ProductFormDialog extends StatefulWidget {
  final ProductEntity? product; // null => Add, not null => Edit
  const ProductFormDialog({super.key, this.product});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late double price;
  late int stock;
  String? description;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      name = widget.product!.name;
      price = widget.product!.price;
      stock = widget.product!.stock;
      description = widget.product!.description;
      imageUrl = widget.product!.imageUrl;
    } else {
      name = '';
      price = 0;
      stock = 0;
      description = null;
      imageUrl = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProductCubit>();
    return AlertDialog(
      title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                onSaved: (val) => name = val!,
              ),
              TextFormField(
                initialValue: price.toString(),
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                onSaved: (val) => price = double.parse(val!),
              ),
              TextFormField(
                initialValue: stock.toString(),
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                onSaved: (val) => stock = int.parse(val!),
              ),
              TextFormField(
                initialValue: description,
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (val) => description = val,
              ),
              TextFormField(
                initialValue: imageUrl,
                decoration: const InputDecoration(labelText: 'Image URL'),
                onSaved: (val) => imageUrl = val,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final product = ProductEntity(
                id: widget.product?.id,
                name: name,
                price: price,
                stock: stock,
                description: description,
                imageUrl: imageUrl,
              );

              if (widget.product == null) {
                cubit.addProduct(product);
              } else {
                cubit.updateProduct(product);
              }

              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        )
      ],
    );
  }
}
