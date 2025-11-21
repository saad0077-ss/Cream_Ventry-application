import 'package:cream_ventory/database/functions/expense_category_db.dart';
import 'package:cream_ventory/models/expense_category_model.dart';
import 'package:cream_ventory/core/utils/expence/add_expence_logics.dart';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class CategoryDropdownWidget extends StatefulWidget {
  final AddExpenseLogic logic;
  final Future<List<ExpenseCategoryModel>>? categoryListFuture;
  final Function(Future<List<ExpenseCategoryModel>>) onCategoriesUpdated;

  const CategoryDropdownWidget({
    super.key,
    required this.logic,
    required this.categoryListFuture,
    required this.onCategoriesUpdated,
  });

  @override
  State<CategoryDropdownWidget> createState() => _CategoryDropdownWidgetState();
}

class _CategoryDropdownWidgetState extends State<CategoryDropdownWidget> {
  // Permanent, non-deletable categories
  static const List<String> protectedCategories = ['Fuel', 'Lunch', 'Breakfast'];

  // Get unique sorted user categories (case-insensitive)
  List<String> _getUniqueUserCategories(List<ExpenseCategoryModel> categories) {
    final seen = <String>{};
    final unique = <String>[];

    for (final cat in categories) {
      final lower = cat.name.trim().toLowerCase();
      if (!seen.contains(lower)) {
        seen.add(lower);
        unique.add(cat.name.trim());
      }
    }
    unique.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return unique;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.info(
        message: message,
        backgroundColor: isError ? Colors.red.shade600 : Colors.orange,
      ),
      displayDuration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ExpenseCategoryModel>>(
      future: widget.categoryListFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
          return const SizedBox(
            height: 56,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
          );
        }

        final userCategories = _getUniqueUserCategories(snapshot.data!);
        final allCategories = [...protectedCategories, ...userCategories];
        final dropdownItems = [...allCategories, 'Add New Category'];

        // Auto-select first valid category if current one is invalid
        if (!allCategories.contains(widget.logic.selectedCategory) ||
            widget.logic.selectedCategory == 'Add New Category') {
          widget.logic.selectedCategory = allCategories.first;
        }

        return DropdownButtonFormField<String>(
          value: widget.logic.selectedCategory,
          hint: const Text('Choose category', style: TextStyle(color: Colors.grey)),
          decoration: InputDecoration(
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            prefixIcon: const Icon(Icons.category_outlined, color: Colors.deepPurple),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
          dropdownColor: Colors.white,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
          style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500),
          isExpanded: true,
          items: dropdownItems.map((item) {
            final isAddNew = item == 'Add New Category';
            final isProtected = protectedCategories.contains(item);
            final isDeletable = !isAddNew && !isProtected;

            return DropdownMenuItem<String>(
              value: item, 
              child: Row(
                children: [
                  Icon(
                    isAddNew
                        ? Icons.add_circle_outline
                        : (isProtected ? Icons.lock_outline : Icons.label_outline),
                    color: isAddNew
                        ? Colors.green.shade600
                        : (isProtected ? Colors.blue.shade700 : Colors.deepPurple.shade400),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontWeight: isAddNew || isProtected ? FontWeight.w600 : FontWeight.w500,
                        color: isAddNew
                            ? Colors.green.shade700
                            : (isProtected ? Colors.blue.shade800 : Colors.black87),
                        fontSize: 15.5,
                      ),
                    ),
                  ),
                  // Delete button - only for user-created categories
                  if (isDeletable)
                    GestureDetector(
                      onTap: () async {
                        Navigator.of(context, rootNavigator: true).pop(); 
              
                        final confirmed = await _showDeleteDialog(item);
                        if (!confirmed || !mounted) return;
              
                        final deleted = await ExpenseCategoryDB.deleteCategoryByName(item);
                        if (!deleted || !mounted) return; 
              
                        _showSnackBar('"$item" Category deleted');
              
                        // Refresh categories
                        final updated = await ExpenseCategoryDB.getCategories();   
                        widget.onCategoriesUpdated(Future.value(updated));
              
                        // Reset selection if deleted category was active
                        if (widget.logic.selectedCategory == item) {       
                          widget.logic.selectedCategory = protectedCategories.first;
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration( 
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(child: Icon(Icons.delete_outline, color: Colors.red.shade600, size: 18)),
                      ),
                    ),
                ],
              ),
            );
          }).toList(), 
          onChanged: (value) async {
            if (value == 'Add New Category') {
              final newName = await _showAddCategoryDialog();
              if (newName == null || newName.trim().isEmpty || !mounted) return;

              final trimmed = newName.trim();
              final exists = allCategories.any((c) => c.toLowerCase() == trimmed.toLowerCase());

              if (exists) {
                _showSnackBar("Category already exists!", isError: true);
                return;
              } 

              await ExpenseCategoryDB.addCategory(trimmed);
              if (!mounted) return;

              final updated = await ExpenseCategoryDB.getCategories();
              widget.onCategoriesUpdated(Future.value(updated));
              widget.logic.selectedCategory = trimmed;
            } else if (value != null) {
              widget.logic.selectedCategory = value;
            }
          },
          validator: (value) {
            if (value == null || value == 'Add New Category') {
              return 'Please select a valid category';
            }
            return null;
          },
        );
      },
    );
  }

  // Delete Confirmation Dialog
  Future<bool> _showDeleteDialog(String categoryName) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            icon: Icon(Icons.warning_amber_rounded, color: Colors.red.shade600, size: 40),
            title: const Text('Delete Category?', style: TextStyle(fontWeight: FontWeight.bold)),
            content: Text('Are you sure you want to delete "$categoryName"?\n\nThis cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.delete_forever, size: 18),
                label: const Text('Delete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  // Add New Category Dialog
  Future<String?> _showAddCategoryDialog() async {
    final controller = TextEditingController();
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.add_box_outlined, color: Colors.deepPurple),
            SizedBox(width: 12),
            Text('New Category', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: 'e.g. Food, Acom, Entertainment',
            prefixIcon: const Icon(Icons.category_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, controller.text),
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Add'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
} 