import 'dart:convert';
import 'dart:io';
import 'package:cream_ventory/db/functions/category_db.dart';
import 'package:cream_ventory/db/functions/product_db.dart';
import 'package:cream_ventory/db/functions/user_db.dart';
import 'package:cream_ventory/db/models/items/category/category_model.dart';
import 'package:cream_ventory/db/models/items/products/product_model.dart';
import 'package:cream_ventory/utils/adding/product/product_add_image_picking_utils.dart';
import 'package:cream_ventory/utils/adding/product/product_add_validation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class ProductFormUtils {
  static Future<void> initializeFields({
    required BuildContext context,
    required ProductModel? existingProduct,
    required void Function(VoidCallback) setStateCallback,
    required TextEditingController nameController,
    required TextEditingController stockController,
    required TextEditingController salePriceController,
    required TextEditingController purchasePriceController,
    required void Function(String?) creationDateCallback,
    required void Function(CategoryModel?) selectedCategoryCallback,
    required void Function(File?) selectedImageCallback,
    required void Function(Uint8List?) selectedImageBytesCallback, 
    required void Function(String?) categoryErrorCallback,
    required void Function(bool) isLoadingCallback,
  }) async {
    try {
      isLoadingCallback(true);

      // Load sample categories and refresh - this updates the notifier
      await CategoryDB.loadSampleCategories();
      
      // Just get the current value from the notifier which already has all categories
      final categories = CategoryDB.categoryNotifier.value;

      if (existingProduct != null) {
        _populateExistingProductFields(
          existingProduct,
          categories,
          nameController,
          stockController,
          salePriceController,
          purchasePriceController,
          creationDateCallback,
          selectedCategoryCallback,
          selectedImageCallback,
          selectedImageBytesCallback,
          categoryErrorCallback,
        );
      } else {
        _initializeNewProductFields(
          categories,
          creationDateCallback,
          selectedCategoryCallback,
          categoryErrorCallback,
        );
      }
    } catch (e) {
      _handleError(context, 'Error initializing fields: $e');
    } finally {
      isLoadingCallback(false);
    }
  }

  static void _populateExistingProductFields(
    ProductModel existingProduct,
    List<CategoryModel> categories,
    TextEditingController nameController,
    TextEditingController stockController,
    TextEditingController salePriceController,
    TextEditingController purchasePriceController,
    void Function(String?) creationDateCallback,
    void Function(CategoryModel?) selectedCategoryCallback,
    void Function(File?) selectedImageCallback,
    void Function(Uint8List?) selectedImageBytesCallback,
    void Function(String?) categoryErrorCallback,  
  ) {
    nameController.text = existingProduct.name;
    stockController.text = existingProduct.stock.toString();
    salePriceController.text = existingProduct.salePrice.toString();
    purchasePriceController.text = existingProduct.purchasePrice.toString();
    creationDateCallback(existingProduct.creationDate);
    if (kIsWeb) {
      // For web, assume imagePath is a base64 string
      selectedImageCallback(null);
      try {
        selectedImageBytesCallback(base64Decode(existingProduct.imagePath));
      } catch (e) {
        selectedImageBytesCallback(null);
      }
    } else {
      selectedImageCallback(existingProduct.isAsset ? null : File(existingProduct.imagePath));
      selectedImageBytesCallback(null);
    }

    if (categories.isNotEmpty) {
      selectedCategoryCallback(categories.firstWhere(
        (category) => category.id == existingProduct.category.id,
        orElse: () => categories.first,
      ));
    } else {
      categoryErrorCallback('No categories available. Please add a category first.');
    }
  }

  static void _initializeNewProductFields(
    List<CategoryModel> categories,
    void Function(String?) creationDateCallback,
    void Function(CategoryModel?) selectedCategoryCallback,
    void Function(String?) categoryErrorCallback,
  ) {
    creationDateCallback(DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()));
    if (categories.isNotEmpty) {
      selectedCategoryCallback(categories.first);
    } else {
      categoryErrorCallback('No categories available. Please add a category first.');
    }
  }

  static Future<void> pickImage({
    required BuildContext context,
    required ImagePicker picker,
    required void Function(VoidCallback) setStateCallback,
    required void Function(File?) selectedImageCallback,
    required void Function(Uint8List?) selectedImageBytesCallback,
    required void Function(String?) imageErrorCallback,
  }) async {
    try {
      await ImageUtils.pickAndSaveImage(
        context: context,
        setImagePathCallback: (path) {
          setStateCallback(() {
            if (kIsWeb) {
              selectedImageCallback(null);
            } else {
              selectedImageCallback(path != null ? File(path) : null);
            }
            imageErrorCallback(null);
          });
        },
        setImageBytesCallback: (bytes) {
          setStateCallback(() {
            selectedImageBytesCallback(bytes);
            imageErrorCallback(null);
          });
        },
      );
    } catch (e) {
      _handleError(context, 'Failed to pick image: $e');
    }
  }

  static Future<void> addButton({
    required BuildContext context,
    required ProductModel? existingProduct,
    required TextEditingController nameController,
    required TextEditingController stockController,
    required TextEditingController salePriceController,
    required TextEditingController purchasePriceController,
    required CategoryModel? selectedCategory,
    required File? selectedImage,
    required Uint8List? selectedImageBytes,
    required String? creationDate,
    required void Function(VoidCallback) setStateCallback,
    required void Function(String?) nameErrorCallback,
    required void Function(String?) stockErrorCallback,
    required void Function(String?) salePriceErrorCallback,
    required void Function(String?) purchasePriceErrorCallback,
    required void Function(String?) categoryErrorCallback,
    required void Function(String?) imageErrorCallback,
  }) async {
    if (ValidationUtils.validateFields(
      nameController: nameController,
      stockController: stockController,
      salePriceController: salePriceController,
      purchasePriceController: purchasePriceController,
      selectedCategory: selectedCategory,
      selectedImage: selectedImage,
      setStateCallback: setStateCallback,
      nameErrorCallback: nameErrorCallback,
      stockErrorCallback: stockErrorCallback,
      salePriceErrorCallback: salePriceErrorCallback,
      purchasePriceErrorCallback: purchasePriceErrorCallback,
      categoryErrorCallback: categoryErrorCallback,
      imageErrorCallback: imageErrorCallback,
      selectedImageBytes: selectedImageBytes
    )) {
      final user = await UserDB.getCurrentUser();
      await _saveProduct(
        context,
        existingProduct,
        user.id,
        nameController.text.trim(),
        int.parse(stockController.text.trim()),
        double.parse(salePriceController.text.trim()),
        double.parse(purchasePriceController.text.trim()),
        selectedCategory!,
        kIsWeb ? base64Encode(selectedImageBytes!) : selectedImage!.path,
        creationDate!,
      );
    } else {
      _handleError(context, 'Please fix the errors in the form.');
    }
  }

  static Future<void> _saveProduct(
    BuildContext context,
    ProductModel? existingProduct,
    String userId,
    String name,
    int stock,
    double salePrice,
    double purchasePrice,
    CategoryModel category,
    String imagePath,
    String creationDate,
  ) async {
    try {
      final product = ProductModel(
        name: name,
        stock: stock,
        salePrice: salePrice,
        purchasePrice: purchasePrice,
        category: category,
        imagePath: imagePath,
        id: existingProduct?.id ?? const Uuid().v4(),
        creationDate: creationDate,
        isAsset: existingProduct?.isAsset ?? false,
        userId: userId,
      );

      if (existingProduct == null) {
        await ProductDB.addProduct(product);
      } else {
        await ProductDB.updateProduct(product.id, product);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              existingProduct == null
                  ? 'Product added successfully!'
                  : 'Product updated successfully!',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) { 
      _handleError(context, 'Error: $e');
    }
  }

  static void _handleError(BuildContext context, String message) {
    debugPrint(message);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating, 
        ),
      );
    }
  }
}