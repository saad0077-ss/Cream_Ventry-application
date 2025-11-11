import 'package:cream_ventory/database/functions/category_db.dart';
import 'package:cream_ventory/models/category_model.dart';
import 'package:cream_ventory/screens/category/widgets/category_listing_screen_card.dart';
import 'package:flutter/material.dart';

class CategoriesTab extends StatefulWidget {
  const CategoriesTab({super.key});

  @override
  State<CategoriesTab> createState() => CategoriesTabState();
}

class CategoriesTabState extends State<CategoriesTab> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      // Refresh notifier to include samples + current user's categories
      await CategoryDB.loadSampleCategories();

      // Update state
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of( 
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load categories: $e')));
    }
  }

  bool get _isDesktop => MediaQuery.of(context).size.width >= 900;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ValueListenableBuilder<List<CategoryModel>>(
              valueListenable: CategoryDB.categoryNotifier,
              builder: (context, categories, _) {
                if (categories.isEmpty) {
                  return const Center(child: Text('No categories available.'));
                }

                if (!_isDesktop) {
                  return ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CategoryCard(
                          isDesktop: _isDesktop,
                          key: ValueKey(cat.id),
                          cat: cat,
                        ),
                      ); 
                    },
                  );
                }

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 170,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CategoryCard(
                        isDesktop: _isDesktop,
                        key: ValueKey(cat.id), 
                        cat: cat,
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
