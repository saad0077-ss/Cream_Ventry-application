import 'package:cream_ventory/database/functions/user_db.dart';
import 'package:cream_ventory/models/expense_category_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ExpenseCategoryDB {
  static const String _boxName = 'expenseCategoryBox';
  static final ValueNotifier<List<ExpenseCategoryModel>> categoryNotifier =
      ValueNotifier([]);

  // Initialize the Hive box and update notifier
  static Future<void> init() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox<ExpenseCategoryModel>(_boxName);
      }
      _updateNotifier();
      debugPrint(
        'Hive box "$_boxName" initialized with ${Hive.box<ExpenseCategoryModel>(_boxName).length} categories',
      );
    } catch (e) {
      debugPrint('Error initializing ExpenseCategoryDB: $e');
      throw Exception('Failed to initialize ExpenseCategoryDB: $e');
    }
  }

  // Add a new category
  static Future<void> addCategory(String name) async {
    try {
      final box = await Hive.openBox<ExpenseCategoryModel>(_boxName);                                  
      final user = await UserDB.getCurrentUser();
      final category = ExpenseCategoryModel(name: name.trim(), userId: user.id);
      await box.add(category);
      _updateNotifier();
      debugPrint('Added category: $name');
    } catch (e) {
      debugPrint('Error adding category: $e');
      throw Exception('Failed to add category: $e');
    }
  }

  // Retrieve all categories
  static Future<List<ExpenseCategoryModel>> getCategories() async {
    try {
      final box = await Hive.openBox<ExpenseCategoryModel>(_boxName);
      final user = await UserDB.getCurrentUser();
      final categories = box.values
          .where((category) => category.userId == user.id)
          .toList();
      debugPrint('Fetched ${categories.length} categories');
      return categories;
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return [];
    }
  }

  // Delete a category at the given index
  static Future<bool> deleteCategory(int index) async {
    try {
      final box = await Hive.openBox<ExpenseCategoryModel>(_boxName);
      if (index < 0 || index >= box.length) {
        debugPrint('Invalid index $index for category deletion');
        return false;
      }
      await box.deleteAt(index);
      _updateNotifier();
      debugPrint('Deleted category at index $index');
      return true;
    } catch (e) {
      debugPrint('Error deleting category: $e');
      return false;
    }
  }

  // Add default categories if the box is empty
  static Future<void> addDefaultCategoriesIfEmpty(
    List<String> defaultList,
  ) async {
    final user = await UserDB.getCurrentUser();
    try {
      final box = await Hive.openBox<ExpenseCategoryModel>(_boxName);
      final userCategories = box.values
          .where((category) => category.userId == user.id)
          .toList();
      if (userCategories.isEmpty) {
        for (var name in defaultList) {
          await box.add(ExpenseCategoryModel(name: name, userId: user.id));
          debugPrint('Added default category: $name for userId: ${user.id}');
        }
      } else {
        debugPrint('Categories already exist');
      }
      _updateNotifier();
    } catch (e) {
      debugPrint('Error adding default categories: $e');
      throw Exception('Failed to add default categories: $e');
    }
  }

  // Get a listenable for reactive updates
  static ValueListenable<Box<ExpenseCategoryModel>> getCategoryListenable() {
    return Hive.box<ExpenseCategoryModel>(_boxName).listenable();
  }

  // Update the notifier with the latest categories
  static void _updateNotifier() {     
    
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      final user = await UserDB.getCurrentUser();
      final box = Hive.box<ExpenseCategoryModel>(_boxName);

      final categories = box.values
          .where((category) => category.userId == user.id)
          .toList();
      categoryNotifier.value = categories;
      debugPrint(
        'Notifier updated with ${categoryNotifier.value.length} categories',
      );
    });
  }
}
