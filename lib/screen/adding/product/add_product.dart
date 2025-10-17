import 'dart:io';
import 'package:cream_ventory/db/functions/category_db.dart';
import 'package:cream_ventory/db/functions/product_db.dart';
import 'package:cream_ventory/db/functions/user_db.dart';
import 'package:cream_ventory/db/models/items/category/category_model.dart';
import 'package:cream_ventory/db/models/items/products/product_model.dart';
import 'package:cream_ventory/themes/app_theme/theme.dart';
import 'package:cream_ventory/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

void showAddProductBottomSheet(
  BuildContext context, {
  ProductModel? existingProduct,
  String? productKey,
}) {
  showModalBottomSheet(
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    context: context,
    builder: (context) => Container(
      decoration: BoxDecoration(
        gradient: AppTheme.appGradient,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25))
      ),
      child: AddProductBottomSheet(
        existingProduct: existingProduct,
        productKey: productKey,
      ),
    ),
  );
}
 
class AddProductBottomSheet extends StatefulWidget {
  final ProductModel? existingProduct;
  final String? productKey;

  const AddProductBottomSheet({
    super.key,
    this.existingProduct,
    this.productKey,
  });

  @override
  AddProductBottomSheetState createState() => AddProductBottomSheetState();
}

class AddProductBottomSheetState extends State<AddProductBottomSheet> {
  final nameController = TextEditingController();
  final stockController = TextEditingController();
  final salePriceController = TextEditingController();
  final purchasePriceController = TextEditingController();

  String? nameError;
  String? stockError;
  String? salePriceError;
  String? purchasePriceError;
  String? categoryError;
  String? imageError;

  CategoryModel? selectedCategory;
  File? selectedImage;
  final ImagePicker picker = ImagePicker();
  String? creationDate;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  Future<void> _initializeFields() async {
    try {
      setState(() {
        isLoading = true;
      });

      await CategoryDB.loadSampleCategories();

      final categories = await CategoryDB.getCategoriesByUserId();
      if (categories.isNotEmpty) {
        CategoryDB.categoryNotifier.value = categories;
      }

      if (widget.existingProduct != null) {
        nameController.text = widget.existingProduct!.name;
        stockController.text = widget.existingProduct!.stock.toString();
        salePriceController.text = widget.existingProduct!.salePrice.toString();
        purchasePriceController.text = widget.existingProduct!.purchasePrice
            .toString();
        creationDate = widget.existingProduct!.creationDate;
        selectedImage = widget.existingProduct!.isAsset
            ? null
            : File(widget.existingProduct!.imagePath);
        debugPrint('Editing product: creationDate = $creationDate');

        final categories = await CategoryDB.getCategoriesByUserId();
        setState(() {
          if (categories.isNotEmpty) {
            selectedCategory = categories.firstWhere(
              (categories) => categories.id == widget.existingProduct!.id,
              orElse: () {
                debugPrint(
                  'No matching category found for id: ${widget.existingProduct!.category.id}',
                );
                return categories.first;
              },
            );
            debugPrint(
              'Matched selectedCategory: ${selectedCategory?.toString() ?? "None"}',
            );
          } else {
            categoryError =
                'No categories available. Please add a category first.';
          }
          isLoading = false;
        });
      } else {
        creationDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
        debugPrint('New product: creationDate = $creationDate');
        await CategoryDB.loadSampleCategories(); // Load samples if no categories exist
        final categories = await CategoryDB.getCategoriesByUserId();
        setState(() {
          if (categories.isNotEmpty) {
            selectedCategory = categories.first; // Default to first category
          } else {
            categoryError =
                'No categories available. Please add a category first.';
          }
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error initializing fields: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    stockController.dispose();
    salePriceController.dispose();
    purchasePriceController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        // Save the image to a permanent location
        final permanentPath = await _saveImagePermanently(File(image.path));
        setState(() {
          selectedImage = File(permanentPath);
          imageError = null;
          debugPrint('Image picked and saved permanently: $permanentPath');
        });
        // Verify if the file exists
        if (await selectedImage!.exists()) {
          debugPrint('Image file exists at: $permanentPath');
        } else {
          debugPrint('Image file does not exist at: $permanentPath');
        }
      } else {
        debugPrint('No image selected');
      }
    } catch (e) {
      debugPrint('Failed to pick image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // New method to save the image to a permanent location
  Future<String> _saveImagePermanently(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final uuid = Uuid();
    final fileName = '${uuid.v4()}.jpg'; // Unique file name
    final permanentPath = '${directory.path}/images/$fileName';
    await Directory('${directory.path}/images').create(recursive: true);
    final savedImage = await image.copy(
      permanentPath,
    ); // Copy to permanent location
    return savedImage.path;
  }

  bool validateFields() {
    setState(() {
      nameError = nameController.text.trim().isEmpty
          ? "Product name is required."
          : null;
      stockError =
          int.tryParse(stockController.text.trim()) == null ||
              int.parse(stockController.text.trim()) < 0
          ? "Stock must be a non-negative number."
          : null;
      salePriceError =
          double.tryParse(salePriceController.text.trim()) == null ||
              double.parse(salePriceController.text.trim()) <= 0
          ? "Sale price must be a positive number."
          : null;
      purchasePriceError =
          double.tryParse(purchasePriceController.text.trim()) == null ||
              double.parse(purchasePriceController.text.trim()) <= 0
          ? "Purchase price must be a positive number."
          : null;
      categoryError = selectedCategory == null
          ? "Please select a category."
          : null;
      imageError = selectedImage == null ? "Please select an image." : null;
    });

    return nameError == null &&
        stockError == null &&
        salePriceError == null &&
        purchasePriceError == null &&
        categoryError == null &&
        imageError == null;
  }

  Future<void> addButton() async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;
    if (validateFields()) {
      final product = ProductModel(
        name: nameController.text.trim(),
        stock: int.parse(stockController.text.trim()),
        salePrice: double.parse(salePriceController.text.trim()),
        purchasePrice: double.parse(purchasePriceController.text.trim()),
        category: selectedCategory!,
        imagePath: selectedImage!.path,
        id: widget.existingProduct == null
            ? const Uuid().v4()
            : widget.existingProduct!.id,
        creationDate: creationDate!,
        isAsset: widget.existingProduct?.isAsset ?? false,
        userId: userId,
      );

      try {
        if (widget.existingProduct == null) {
          await ProductDB.addProduct(product);
        } else {
          await ProductDB.updateProduct(
            product.id,
            createStockTransaction: false,
            product,
          );
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingProduct == null
                  ? 'Product added successfully!'
                  : 'Product updated successfully!',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors in the form.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 20.0,
        left: 20.0,
        right: 20.0, 
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.existingProduct == null ? "Add Product" : "Edit Product",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: pickImage,
              child: selectedImage == null
                  ? Column(
                      children: [
                        Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 235, 226, 226),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color.fromARGB(96, 3, 3, 3),width: 3)
                          ),
                          child: const Icon(
                            Icons.add_a_photo,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                        if (imageError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              imageError!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        selectedImage!,
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<List<CategoryModel>>(
              valueListenable: CategoryDB.categoryNotifier,
              builder: (context, categoryList, _) {
               debugPrint('Category list length: ${categoryList.length}');
                for (var category in categoryList) {
                  debugPrint('Category: ${category.name}, ID: ${category.id}');
                }
                if (categoryList.isEmpty) {
                  return const Text("No categories available.");
                }
                final uniqueCategoryList = categoryList.toList(); // Avoid filtering out samples
                if (selectedCategory != null &&
                    !uniqueCategoryList.any((category) => category.id == selectedCategory!.id)) {
                  selectedCategory = null;
                  categoryError = 'Selected category not found. Please choose another.';
                }    
                debugPrint(
                  'Categories: ${uniqueCategoryList.map((c) => c.toString()).toList()}',
                );
                debugPrint('Selected Category: $selectedCategory'); 
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<CategoryModel>(
                      hint: const Text("Select Category"),
                      initialValue: selectedCategory,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: const OutlineInputBorder(),
                        errorText: categoryError,
                      ),
                      onChanged: (CategoryModel? newValue) {
                        setState(() {
                          selectedCategory = newValue;
                          categoryError = null;
                        });
                      },
                      items: uniqueCategoryList
                          .map<DropdownMenuItem<CategoryModel>>((
                            CategoryModel category,
                          ) {
                            return DropdownMenuItem<CategoryModel>(
                              value: category,
                              child: Text(category.name),
                            );
                          })
                          .toList(),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Product Name',
                border: const OutlineInputBorder(),
                errorText: nameError,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Stock',
                border: const OutlineInputBorder(),
                errorText: stockError,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: salePriceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Sale Price',
                border: const OutlineInputBorder(),
                errorText: salePriceError,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: purchasePriceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Purchase Price',
                border: const OutlineInputBorder(),
                errorText: purchasePriceError,
              ),
            ),
            const SizedBox(height: 20),
            CustomActionButton(
              label: widget.existingProduct == null
                  ? "Create Product"
                  : "Update Product",
              backgroundColor: Colors.black,
              onPressed: () async {
                await addButton();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
