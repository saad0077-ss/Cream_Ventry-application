// add_item_category_product_selection_widget.dart
import 'package:cream_ventory/database/functions/category_db.dart';
import 'package:cream_ventory/models/category_model.dart';
import 'package:cream_ventory/models/product_model.dart';
import 'package:flutter/material.dart';

class AddItemCategoryProductSelectionWidget {
  /// Builds the category and product selection section with enhanced UI
  static Widget buildCategoryProductSelection({
    required String? selectedCategoryId,
    required String? selectedProductId,
    required List<ProductModel> products,
    required ValueChanged<String?> onCategoryChanged,
    required ValueChanged<String?> onProductChanged,
    required TextEditingController quantityController,
    required TextEditingController rateController,
  }) {
    // Get the selected product to display stock
    ProductModel? selectedProduct;
    if (selectedProductId != null && products.isNotEmpty) {
      try {
        selectedProduct = products.firstWhere((p) => p.id == selectedProductId);
      } catch (e) {
        selectedProduct = null;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ValueListenableBuilder<List<CategoryModel>>(
        valueListenable: CategoryDB.categoryNotifier,
        builder: (context, categories, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header
              const Text(
                'Item Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 20),
              
              // Category Dropdown
              _buildEnhancedDropdown<String>(
                label: 'Item Category',
                value: selectedCategoryId,
                icon: Icons.category_outlined,
                items: categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      ),
                    )
                    .toList(),
                onChanged: onCategoryChanged,
                hint: 'Select a category',
              ),
              const SizedBox(height: 16),
              
              // Product Dropdown
              _buildEnhancedDropdown<String>(
                label: 'Item Name',
                value: selectedProductId,
                icon: Icons.shopping_bag_outlined,
                items: products
                    .map(
                      (product) => DropdownMenuItem(
                        value: product.id,
                        child: Text(product.name),
                      ),
                    )
                    .toList(),
                onChanged: onProductChanged,
                hint: 'Select a product',
              ),
              const SizedBox(height: 16),
              
              // Quantity and Rate Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildEnhancedTextField(
                          controller: quantityController,
                          label: 'Quantity',
                          icon: Icons.production_quantity_limits_outlined,
                          keyboardType: TextInputType.number,
                        ),
                        // Stock Display
                        if (selectedProduct != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 16,
                                  color: selectedProduct.stock > 10
                                      ? const Color(0xFF27AE60)
                                      : selectedProduct.stock > 0
                                          ? const Color(0xFFF39C12)
                                          : const Color(0xFFE74C3C),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Available Stock: ${selectedProduct.stock}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: selectedProduct.stock > 10
                                        ? const Color(0xFF27AE60)
                                        : selectedProduct.stock > 0
                                            ? const Color(0xFFF39C12)
                                            : const Color(0xFFE74C3C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildEnhancedTextField(
                      controller: rateController,
                      label: 'Rate (Price)',
                      icon: Icons.currency_rupee,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

  /// Enhanced dropdown with custom styling
  static Widget _buildEnhancedDropdown<T>({
    required String label,
    required T? value,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF34495E),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE0E0E0),
              width: 1.5,
            ),
          ),
          child: DropdownButtonFormField<T>(
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: const Color(0xFF3498DB),
                size: 22,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 15,
              ),
            ),
            value: value,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF3498DB),
            ),
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF2C3E50),
              fontWeight: FontWeight.w500,
            ),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            items: items,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  /// Enhanced text field with custom styling
  static Widget _buildEnhancedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF34495E),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE0E0E0),
              width: 1.5, 
            ),
          ),
          child: TextField(
            controller: controller, 
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF2C3E50),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: const Color(0xFF3498DB),
                size: 22,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}