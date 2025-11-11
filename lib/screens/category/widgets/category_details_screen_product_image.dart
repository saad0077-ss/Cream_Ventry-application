// lib/screens/category/widgets/product_image_widget.dart
import 'package:flutter/material.dart';
import 'package:cream_ventory/models/product_model.dart';
import 'package:cream_ventory/core/utils/image_util.dart';

class ProductImageWidget extends StatelessWidget {
  final ProductModel product;

  const ProductImageWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image(
          image: ImageUtils.getImage(
            product.imagePath,
            ),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(
              Icons.broken_image,
              color: Colors.red[300],
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}