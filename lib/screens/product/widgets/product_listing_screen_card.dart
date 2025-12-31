
import 'package:cream_ventory/models/product_model.dart';
import 'package:cream_ventory/screens/product/widgets/product_listing_screen_card_product_actions_menu.dart';
import 'package:cream_ventory/screens/product/widgets/product_listing_screen_card_product_details.dart';
import 'package:cream_ventory/screens/product/widgets/product_listing_screen_card_product_image.dart';
import 'package:flutter/material.dart';
import 'package:cream_ventory/screens/product/product_detailing_screen.dart';
   
class ItemCard extends StatelessWidget {
  final ProductModel product;
  final String index;


  const ItemCard({super.key, required this.product, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailsPage(product: product),
        ),
      ),
      child: Card(
        elevation: 5,
        shadowColor: Colors.grey.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductImage(imagePath: product.imagePath),
                const SizedBox(width: 16), 
                Expanded(child: ProductDetails(product: product)),
                ProductActionsMenu(product: product, index: index),
              ],
            ),
          ),
        ),
      ),
    );
  }
}