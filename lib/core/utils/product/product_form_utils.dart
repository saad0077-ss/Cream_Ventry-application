import 'dart:convert';
import 'dart:io';
import 'package:cream_ventory/database/functions/category_db.dart';
import 'package:cream_ventory/database/functions/product_db.dart';
import 'package:cream_ventory/database/functions/user_db.dart';
import 'package:cream_ventory/models/category_model.dart';
import 'package:cream_ventory/models/product_model.dart';
import 'package:cream_ventory/core/utils/product/product_add_image_picking_utils.dart';
import 'package:cream_ventory/core/utils/product/product_add_validation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

// Import top_snackbar_flutter
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

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
      await CategoryDB.loadSampleCategories();
      final categories = CategoryDB.categoryNotifier.value;

      setStateCallback(() {
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
      });
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

    debugPrint('🖼️ Loading image for product: ${existingProduct.name}');
    debugPrint('🖼️ Image path: ${existingProduct.imagePath}');
    debugPrint('🖼️ Is asset: ${existingProduct.isAsset}');
    debugPrint('🖼️ Is web: $kIsWeb');

    // Handle image loading
    if (kIsWeb) {
      try {
        final imageBytes = base64Decode(existingProduct.imagePath);
        debugPrint(
            '✅ Web: Successfully decoded image, bytes length: ${imageBytes.length}');
        selectedImageBytesCallback(imageBytes);
        selectedImageCallback(null);
      } catch (e) {
        debugPrint('❌ Error decoding image for web: $e');
        selectedImageBytesCallback(null);
        selectedImageCallback(null);
      }
    } else {
      try {
        if (existingProduct.isAsset) {
          debugPrint('⚠️ Product is marked as asset, skipping file load');
          selectedImageCallback(null);
          selectedImageBytesCallback(null);
        } else {
          final imageFile = File(existingProduct.imagePath);
          final exists = imageFile.existsSync();
          debugPrint('📁 Image file exists: $exists');

          if (exists) {
            debugPrint('✅ Mobile: Successfully loaded image file');
            selectedImageCallback(imageFile);
            selectedImageBytesCallback(null);
          } else {
            debugPrint(
                '❌ Image file does not exist: ${existingProduct.imagePath}');
            selectedImageCallback(null);
            selectedImageBytesCallback(null);
          }
        }
      } catch (e) {    
        debugPrint('❌ Error loading image for mobile: $e');
        selectedImageCallback(null);
        selectedImageBytesCallback(null);
      }
    }

    if (categories.isNotEmpty) {
      selectedCategoryCallback(categories.firstWhere(
        (c) => c.id == existingProduct.category.id,
        orElse: () => categories.first,
      ));
    } else {
      categoryErrorCallback(
          'No categories available. Please add a category first.');
    }
  }

  static void _initializeNewProductFields(
    List<CategoryModel> categories,
    void Function(String?) creationDateCallback,
    void Function(CategoryModel?) selectedCategoryCallback,
    void Function(String?) categoryErrorCallback,
  ) {
    creationDateCallback(
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()));
    if (categories.isNotEmpty) {
      selectedCategoryCallback(categories.first);
    } else {
      categoryErrorCallback(
          'No categories available. Please add a category first.');
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
      selectedImageBytes: selectedImageBytes,
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
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.success(
            message: existingProduct == null
                ? 'Product added successfully!'
                : 'Product updated successfully!',
            icon: const Icon(Icons.check_circle, color: Colors.white, size: 40),
            backgroundColor: Colors.green.shade600,
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      _handleError(context, 'Failed to save product: $e');
    }
  }

  // Unified error handler using top_snackbar_flutter
  static void _handleError(BuildContext context, String message) {
    debugPrint(message);
    if (context.mounted) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: message,
          backgroundColor: Colors.red.shade600,
          icon: const Icon(Icons.error_outline, color: Colors.white, size: 40),
        ),
      );
    }
  }
}
