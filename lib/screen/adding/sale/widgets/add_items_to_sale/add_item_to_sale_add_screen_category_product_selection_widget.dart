// add_item_category_product_selection_widget.dart
import 'package:cream_ventory/db/functions/category_db.dart';
import 'package:cream_ventory/db/models/items/category/category_model.dart';
import 'package:cream_ventory/db/models/items/products/product_model.dart';
import 'package:flutter/material.dart';

class AddItemCategoryProductSelectionWidget {
  /// Builds the category and product selection section
  static Widget buildCategoryProductSelection({
    required String? selectedCategoryId,
    required String? selectedProductId,
    required List<ProductModel> products,
    required ValueChanged<String?> onCategoryChanged,
    required ValueChanged<String?> onProductChanged,
    required TextEditingController quantityController,
    required TextEditingController rateController,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ValueListenableBuilder<List<CategoryModel>>(
        valueListenable: CategoryDB.categoryNotifier,
        builder: (context, categories, _) {
          return Column(
            children: [
              // Category Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Item Category',
                  border: OutlineInputBorder(),
                ),
                value: selectedCategoryId,
                items: categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      ),
                    )
                    .toList(),
                onChanged: onCategoryChanged,
              ),
              const SizedBox(height: 12),
              // Product Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
                value: selectedProductId,
                items: products
                    .map(
                      (product) => DropdownMenuItem(
                        value: product.id,
                        child: Text(product.name),
                      ),
                    )
                    .toList(),
                onChanged: onProductChanged,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: rateController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Rate(Price)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}