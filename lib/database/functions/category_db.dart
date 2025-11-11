import 'package:cream_ventory/database/functions/user_db.dart';
import 'package:cream_ventory/models/category_model.dart';
import 'package:cream_ventory/models/sample_category.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CategoryDB {
  static const String _boxName = 'categoryBox';
  static late Box<CategoryModel> _box;
  static final ValueNotifier<List<CategoryModel>> categoryNotifier = ValueNotifier([]);

  static Future<void> initialize() async {
    try {
      _box = Hive.isBoxOpen(_boxName) 
          ? Hive.box<CategoryModel>(_boxName)
          : await Hive.openBox<CategoryModel>(_boxName);

      await refreshCategories(); // ← Only one call

      debugPrint('CategoryDB initialized: ${_box.values.length} total categories');
    } catch (e) {   
      debugPrint('Error initializing CategoryDB: $e'); 
    }
  }

  // ====== ONLY ONE REFRESH METHOD ======
  static Future<void> refreshCategories() async {
    try {
      final user = await UserDB.getCurrentUser();
      final userId = user.id;

      final List<CategoryModel> allCategories = _box.values.where((cat) {
        return cat.userId == null || cat.userId == userId;
      }).toList();

      // Optional: sort for consistent order
      allCategories.sort((a, b) => a.name.compareTo(b.name));

      categoryNotifier.value = allCategories;  
      debugPrint('Refreshed: ${allCategories.length} categories (user: $userId)'); 
    } catch (e) {
      debugPrint('Error in refreshCategories: $e');
    }
  }
  // ======================================

  static Future<void> addCategory(CategoryModel category) async {
    try {
      if (_box.containsKey(category.id)) {
        debugPrint('Category ${category.id} exists');
        return;
      }
      await _box.put(category.id, category);
      await refreshCategories(); // ← ONLY THIS
      debugPrint('Added: ${category.name}');
    } catch (e) {
      debugPrint('Add error: $e');
    }
  }

  static Future<bool> deleteCategory(String id) async {
    try {
      if (!_box.containsKey(id)) return false;
      await _box.delete(id);
      await refreshCategories(); // ← ONLY THIS
      return true;
    } catch (e) {
      debugPrint('Delete error: $e');
      return false;
    }
  }

  static Future<bool> editCategory(
    String id,
    String newName,
    String description,
    String imagePath,
  ) async {
    try {
      final category = _box.get(id);
      if (category == null) return false;

      final updated = CategoryModel(
        id: id,
        name: newName,
        imagePath: imagePath,
        discription: description,
        isAsset: category.isAsset,
        userId: category.userId,
      );
      await _box.put(id, updated);
      await refreshCategories(); // ← ONLY THIS
      return true;
    } catch (e) {
      debugPrint('Edit error: $e');
      return false;
    }
  }

  static Future<void> loadSampleCategories() async {
    try {
      final hasSamples = _box.values.any((cat) => cat.userId == null);
      if (hasSamples) {
        debugPrint('Samples exist');
      } else {
        final samples = SampleCategories.getSamples();
        for (var cat in samples) {
          if (!_box.containsKey(cat.id)) {
            await _box.put(cat.id, cat);
          }
        }
        debugPrint('Loaded ${samples.length} sample categories');
      }
      await refreshCategories(); // ← ONLY THIS
    } catch (e) {
      debugPrint('Sample load error: $e');
      rethrow;
    }
  }

  static Future<List<CategoryModel>> getCategoriesByUserId() async {
    final user = await UserDB.getCurrentUser();
    return _box.values.where((cat) => cat.userId == user.id).toList();
  }

  static CategoryModel? getCategoryById(String id) => _box.get(id);

  static Future<void> clearAllCategories() async {
    try {
      final user = await UserDB.getCurrentUser();
      final toDelete = _box.values.where((c) => c.userId == user.id);
      for (var c in toDelete) {
        await _box.delete(c.id);
      }
      await refreshCategories();
    } catch (e) {
      debugPrint('Clear error: $e');
    }
  }


}