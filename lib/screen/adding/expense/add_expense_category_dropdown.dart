import 'package:cream_ventory/db/functions/expense_category_db.dart';
import 'package:cream_ventory/db/models/expence/expense_category_model.dart';
import 'package:cream_ventory/utils/expence/add_expence_logics.dart';
import 'package:flutter/material.dart';

class CategoryDropdownWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return FutureBuilder<List<ExpenseCategoryModel>>(
      future: categoryListFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final categories = snapshot.data!
          ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        final categoryNames = categories.map((e) => e.name).toList();
        final allItems = ['EXPENSE CATEGORY', ...categoryNames, '➕ Add New Category'];

        if (!allItems.contains(logic.selectedCategory)) {
          logic.selectedCategory = 'EXPENSE CATEGORY';
        }

        return DropdownButtonFormField<String>(
          initialValue: logic.selectedCategory,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Expense Category',
          ),
          items: allItems.toSet().map((value) => DropdownMenuItem(
            value: value,
            child: Text(value),
          )).toList(),
          onChanged: (value) async {
            if (value == '➕ Add New Category') {
              final newCategoryName = await _showAddCategoryDialog(context);
              if (newCategoryName != null && newCategoryName.trim().isNotEmpty) {
                final trimmedName = newCategoryName.trim();
                await ExpenseCategoryDB.addCategory(trimmedName);
                
                final updatedList = await ExpenseCategoryDB.getCategories();
                updatedList.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
                onCategoriesUpdated(Future.value(updatedList));
                logic.selectedCategory = trimmedName;
              }
            } else {
              logic.selectedCategory = value!;
            }
          },
          validator: (value) => (value == null || 
            value == 'EXPENSE CATEGORY' || 
            value == '➕ Add New Category') 
            ? 'Please select a category' 
            : null,
        );
      },
    );
  }

  Future<String?> _showAddCategoryDialog(BuildContext context) => showDialog<String>(
    context: context,
    builder: (context) {
      final controller = TextEditingController();
      return AlertDialog(
        title: const Text('Add New Category'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Category Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}