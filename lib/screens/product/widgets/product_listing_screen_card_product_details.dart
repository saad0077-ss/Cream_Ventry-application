import 'package:cream_ventory/models/product_model.dart';
import 'package:cream_ventory/screens/product/widgets/product_listing_screen_card_category_tag.dart';
import 'package:flutter/material.dart';

class ProductDetails extends StatelessWidget {
  final ProductModel product;

  const ProductDetails({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87, letterSpacing: 0.5),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Stock: ${product.stock}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54)),
            CategoryTag(product: product),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _priceColumn('Sale Price', '₹${product.salePrice}', Colors.green),
            _priceColumn('Purchase Price', '₹${product.purchasePrice}', Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _priceColumn(String label, String price, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey)),
        Text(price, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}