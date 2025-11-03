import 'package:cream_ventory/db/models/items/category/category_model.dart';
import 'package:flutter/material.dart';

/// Shows the filter bottom-sheet and returns the selected values via callbacks.
void showProductFilterBottomSheet({
  required BuildContext context,
  required List<CategoryModel> categories,
  required CategoryModel? selectedCategory,
  required String? selectedDateFilter,
  required VoidCallback onClearFilters,
  required ValueChanged<CategoryModel?> onCategoryChanged,
  required ValueChanged<String?> onDateFilterChanged,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    backgroundColor: const Color.fromARGB(255, 21, 21, 21),
    builder: (sheetContext) {
      return _ProductFilterContent(
        categories: categories,
        selectedCategory: selectedCategory,
        selectedDateFilter: selectedDateFilter,
        onClearFilters: onClearFilters, 
        onCategoryChanged: onCategoryChanged,
        onDateFilterChanged: onDateFilterChanged,
        sheetContext: sheetContext,
      );
    },
  );
}

/// Private widget that holds the whole UI of the bottom-sheet.
class _ProductFilterContent extends StatelessWidget {
  const _ProductFilterContent({
    required this.categories,
    required this.selectedCategory,
    required this.selectedDateFilter,
    required this.onClearFilters, 
    required this.onCategoryChanged,
    required this.onDateFilterChanged,
    required this.sheetContext,
  });

  final List<CategoryModel> categories;
  final CategoryModel? selectedCategory;
  final String? selectedDateFilter;
  final VoidCallback onClearFilters;
  final ValueChanged<CategoryModel?> onCategoryChanged;
  final ValueChanged<String?> onDateFilterChanged;
  final BuildContext sheetContext;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- Category ----------
            const Text(
              'Category',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: const Text(
                'All Categories',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                onCategoryChanged(null);
                Navigator.pop(sheetContext);
              },
              tileColor: selectedCategory == null
                  ? Colors.black.withOpacity(0.2)
                  : null,
            ),
            ...categories.map((category) {
              return ListTile(
                title: Text(
                  category.name,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  onCategoryChanged(category);
                  Navigator.pop(sheetContext);
                },
                tileColor: selectedCategory == category
                    ? Colors.black.withOpacity(0.2)
                    : null,
              );
            }),

            const Divider(color: Colors.white54),

            // ---------- Date ----------
            const Text(
              'Date',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),

            _dateTile('Today', 'today'),
            _dateTile('Last 7 Days', 'last7days'),
            _dateTile('Last 30 Days', 'last30days'),

            const Divider(color: Colors.white54),

            // ---------- Clear ----------
            Center(
              child: ElevatedButton(
                onPressed: () {
                  onClearFilters();
                  Navigator.pop(sheetContext);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Clear All Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateTile(String title, String value) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: () {
        onDateFilterChanged(value);
        Navigator.pop(sheetContext);
      },
      tileColor: selectedDateFilter == value
          ? Colors.black.withOpacity(0.2)
          : null,
    );
  }
} 