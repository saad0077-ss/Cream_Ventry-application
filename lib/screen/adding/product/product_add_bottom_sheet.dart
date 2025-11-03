import 'dart:io';
import 'dart:typed_data';
import 'package:cream_ventory/db/functions/category_db.dart';
import 'package:cream_ventory/db/models/items/category/category_model.dart';
import 'package:cream_ventory/db/models/items/products/product_model.dart';
import 'package:cream_ventory/utils/adding/product/product_form_utils.dart';
import 'package:cream_ventory/widgets/custom_button.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  final ImagePicker picker = ImagePicker();

  String? nameError;
  String? stockError;
  String? salePriceError;
  String? purchasePriceError;
  String? categoryError;
  String? imageError;

  CategoryModel? selectedCategory;
  File? selectedImage;
  Uint8List? selectedImageBytes; // Added for web
  String? creationDate;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    ProductFormUtils.initializeFields(
      context: context,
      existingProduct: widget.existingProduct,
      setStateCallback: setState,
      nameController: nameController,
      stockController: stockController,
      salePriceController: salePriceController,
      purchasePriceController: purchasePriceController,
      creationDateCallback: (value) => creationDate = value,
      selectedCategoryCallback: (value) => selectedCategory = value,
      selectedImageCallback: (value) => selectedImage = value,
      selectedImageBytesCallback: (value) => selectedImageBytes = value,
      categoryErrorCallback: (value) => categoryError = value,
      isLoadingCallback: (value) => isLoading = value,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    stockController.dispose();
    salePriceController.dispose();
    purchasePriceController.dispose();
    super.dispose();
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
              widget.existingProduct == null ? 'Add Product' : 'Edit Product',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => ProductFormUtils.pickImage(
                context: context,
                picker: picker,
                setStateCallback: setState,
                selectedImageCallback: (value) => selectedImage = value,
                selectedImageBytesCallback: (value) => selectedImageBytes = value,
                imageErrorCallback: (value) => imageError = value,
              ),
              child: (kIsWeb ? selectedImageBytes == null : selectedImage == null)
                  ? Column(
                      children: [
                        Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 235, 226, 226),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color.fromARGB(96, 3, 3, 3),
                              width: 3,
                            ),
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
                      child: kIsWeb
                          ? Image.memory(
                              selectedImageBytes!,
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
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
                if (categoryList.isEmpty) {
                  return const Text('No categories available.');
                }
                final uniqueCategoryList = categoryList.toList();
                if (selectedCategory != null &&
                    !uniqueCategoryList.any((category) => category.id == selectedCategory!.id)) {
                  setState(() {
                    selectedCategory = null;
                    categoryError = 'Selected category not found. Please choose another.';
                  });
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<CategoryModel>(
                      value: selectedCategory,
                      hint: const Text('Select Category'),
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
                      items: uniqueCategoryList.map<DropdownMenuItem<CategoryModel>>(
                        (CategoryModel category) => DropdownMenuItem<CategoryModel>(
                          value: category,
                          child: Text(category.name),
                        ),
                      ).toList(),
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
              label: widget.existingProduct == null ? 'Create Product' : 'Update Product',
              backgroundColor: const Color.fromARGB(255, 85, 172, 213),
               onPressed: () => ProductFormUtils.addButton(
                context: context,
                existingProduct: widget.existingProduct,
                nameController: nameController,
                stockController: stockController,
                salePriceController: salePriceController,
                purchasePriceController: purchasePriceController,
                selectedCategory: selectedCategory,
                selectedImage: selectedImage,
                selectedImageBytes: selectedImageBytes,
                creationDate: creationDate,
                setStateCallback: setState,
                nameErrorCallback: (value) => nameError = value,
                stockErrorCallback: (value) => stockError = value,
                salePriceErrorCallback: (value) => salePriceError = value,
                purchasePriceErrorCallback: (value) => purchasePriceError = value,
                categoryErrorCallback: (value) => categoryError = value,
                imageErrorCallback: (value) => imageError = value,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}