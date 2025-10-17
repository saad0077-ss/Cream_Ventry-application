import 'package:cream_ventory/db/functions/category_db.dart';
import 'package:cream_ventory/db/models/items/category/category_model.dart';
import 'package:cream_ventory/screen/items/screen/category/widgets/category_card.dart';
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
      await CategoryDB.refreshNotifierForCurrentUser();

      // Update state
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load categories: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03,
        vertical: screenHeight * 0.02,
      ),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ValueListenableBuilder<List<CategoryModel>>(
              valueListenable: CategoryDB.categoryNotifier,
              builder: (context, categories, _) {
                if (categories.isEmpty) {
                  return const Center(child: Text('No categories available.'));
                }
 
                return ListView.builder(    
                  itemCount: categories.length,            
                  itemBuilder: (context, index) {
                    final cat = categories[index];   
                    return CategoryCard(
                      key: ValueKey(cat.id),
                      screenHeight: screenHeight,   
                      screenWidth: screenWidth,
                      cat: cat,
                      onDelete: () async {
                        if (cat.userId != null) {
                          final success = await CategoryDB.deleteCategory(cat.id);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Category deleted successfully')),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sample categories cannot be deleted.')),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}