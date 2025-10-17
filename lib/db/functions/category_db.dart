import 'package:cream_ventory/db/functions/user_db.dart';
import 'package:cream_ventory/db/models/items/category/category_model.dart';
import 'package:cream_ventory/db/models/items/category/sample_category.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

// This class is responsible for managing the categories in the application.
// It provides methods to add, delete, and retrieve categories from the Hive database.
// It also provides a notifier to update the UI when categories change.
class CategoryDB {
  static const String _boxName = 'categoryBox';
  static late Box<CategoryModel> _box;
  static final ValueNotifier<List<CategoryModel>> categoryNotifier =
      ValueNotifier([]);

  /// Initialize the CategoryDB and open the Hive box if needed
  static Future<void> initialize() async {
    try {
      // Open the box if not already open
      if (!Hive.isBoxOpen(_boxName)) {
        _box = await Hive.openBox<CategoryModel>(_boxName);
      } else {
        _box = Hive.box<CategoryModel>(_boxName);
      }
      // Always load sample categories if they don't exist (shared for all users)
      await loadSampleCategories();
      // Initialize notifier with samples only (user-specific will be added on login)
      _refreshNotifier(null); // null indicates samples only
      debugPrint(
        'CategoryDB initialized with ${_box.values.length} categories',
      );
    } catch (e) {
      debugPrint('Error initializing CategoryDB: $e');
    }
  }

  // Method to add a category
  static Future<void> addCategory(CategoryModel category) async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;
    try {
      if (_box.containsKey(category.id)) {
        debugPrint(
          'Category with id ${category.id} already exists. Skipping add.',
        );
        return;
      }
      await _box.put(category.id, category);
      _refreshNotifier(userId); // Now includes samples + user categories

      debugPrint('Added category: ${category.toString()}');
    } catch (e) {
      debugPrint('Error adding category: $e');
    }
  }

  // Method to delete a category
  static Future<bool> deleteCategory(String id) async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;
    try {
      final category = _box.get(id);
      if (category == null) {
        debugPrint('Category with id $id not found');
        return false;
      } 
      await _box.delete(id);
      _refreshNotifier(userId); // Now includes samples + user categories (samples unaffected)

      debugPrint('Deleted category with id: $id');
      return true;
    } catch (e) {
      debugPrint('Error deleting category: $e');
      return false;
    }
  }

  static Future<List<CategoryModel>> getCategoriesByUserId() async {
    try {
      final user = await UserDB.getCurrentUser();
      final userId = user.id;
      final categories = _box.values
          .where((cat) => cat.userId == userId)
          .toList();
      debugPrint(
        'Retrieved ${categories.length} categories for userId $userId',
      );
      return categories;
    } catch (e) {
      debugPrint('Error retrieving categories by userId: $e');
      return [];
    }
  }

  // Method to edit an existing category
  static Future<bool> editCategory(
    String id,
    String newName,
    String description,
    String imagePath,
  ) async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;
    try {
      final category = _box.get(id);
      if (category == null) {
        debugPrint('Category with id $id not found for editing');
        return false;
      }
      final updatedCategory = CategoryModel(
        id: category.id,
        name: newName,
        imagePath: imagePath,
        discription: description,
        isAsset: category.isAsset,
      );
      await _box.put(id, updatedCategory);
      _refreshNotifier(userId); // Now includes samples + user categories

      debugPrint('Updated category: ${updatedCategory.toString()}');
      return true;
    } catch (e) {
      debugPrint('Error editing category: $e');
      return false;
    }
  }

  /// Load sample categories (shared, with userId: null). Always load if not present.
  static Future<void> loadSampleCategories() async {
    try {
      // Check if sample categories already exist
      final existingSampleCategories = _box.values
          .where((cat) => cat.userId == null)
          .toList();
      if (existingSampleCategories.isNotEmpty) {
        debugPrint('Sample categories already exist, skipping load');
        return;
      }

      final sampleData = SampleCategories.getSamples();
      for (var category in sampleData) {
        if (!_box.containsKey(category.id)) {
          await _box.put(category.id, category);
          debugPrint('Added sample category: ${category.toString()}');
        } else {
          debugPrint(
            'Sample category with id ${category.id} already exists. Skipping add.',
          );
        }
      }
      // Notify with samples only (user-specific refresh will happen later)
      categoryNotifier.value = _box.values
          .where((cat) => cat.userId == null)
          .toList();
      debugPrint('Loaded ${sampleData.length} sample categories');
    } catch (e) {
      debugPrint('Error loading sample categories: $e');
      throw Exception('Failed to load sample categories: $e');
    }                           
  }

  // Method to get a category by ID
  static CategoryModel? getCategoryById(String id) {
    try {
      final category = _box.get(id);
      if (category == null) {
        debugPrint('Category with id $id not found');
        return null;
      }
      debugPrint('Retrieved category by id $id: ${category.toString()}');
      return category;
    } catch (e) {
      debugPrint('Error retrieving category by id $id: $e');
      return null;
    }
  }

  // Optional: Add a listenable for reactive updates
  static ValueListenable<Box<CategoryModel>> getCategoryListenable() {
    return Hive.box<CategoryModel>(_boxName).listenable();
  }

  static Future<void> clearAllCategories() async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;
    try {
      // Delete all categories for the given userId (exclude sample categories with null userId)
      final categoriesToDelete = _box.values
          .where((cat) => cat.userId == userId)
          .toList();
      for (var category in categoriesToDelete) {
        await _box.delete(category.id);
        debugPrint(
          'Deleted category with id ${category.id} for userId $userId',
        );
      }
      _refreshNotifier(userId); // Refresh to show samples only now
    } catch (e) {
      debugPrint('Error clearing categories: $e');
      throw Exception('Failed to clear categories: $e');
    }
  }

  /// Refresh the notifier with samples + categories for the given userId
  /// If userId is null, refresh with samples only.
  static void _refreshNotifier(String? userId) {
    if (userId == null) {
      categoryNotifier.value = _box.values
          .where((cat) => cat.userId == null)
          .toList();
    } else {
      categoryNotifier.value = _box.values
          .where((cat) => cat.userId == userId || cat.userId == null)
          .toList();
    }

  }

  /// Public method to refresh notifier for the current user (includes samples + user categories)
  static Future<void> refreshNotifierForCurrentUser() async {
    try {
      final user = await UserDB.getCurrentUser();
      final userId = user.id;
      _refreshNotifier(userId);
      debugPrint('Refreshed notifier for userId $userId with samples + user categories');
    } catch (e) {
      debugPrint('Error refreshing notifier for current user: $e');
    }
  }
}