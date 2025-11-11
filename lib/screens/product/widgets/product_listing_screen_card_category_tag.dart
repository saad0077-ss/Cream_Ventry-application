import 'package:cream_ventory/models/product_model.dart';
import 'package:flutter/material.dart';

class CategoryTag extends StatelessWidget {
  final ProductModel product;

  const CategoryTag({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Text(
        product.category.name,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blue.shade700),
      ),
    );
  }
}