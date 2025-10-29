import 'package:cream_ventory/screen/adding/controller/category_add_controller.dart';
import 'package:cream_ventory/screen/adding/category/category_add_widgets.dart';
import 'package:cream_ventory/themes/app_theme/theme.dart';
import 'package:cream_ventory/utils/adding/category/category_add_utils.dart';
import 'package:flutter/material.dart';
import 'package:cream_ventory/widgets/custom_button.dart';
import 'package:cream_ventory/db/models/items/category/category_model.dart';

class AddCategoryBottomSheet {
  static void show(
    BuildContext context, {
    CategoryModel? categoryToEdit,
    bool isEditing = false,
  }) {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      context: context,
      builder: (context) => _CategoryBottomSheetContent(
        categoryToEdit: categoryToEdit,
        isEditing: isEditing,
      ),
    );
  }
}

class _CategoryBottomSheetContent extends StatefulWidget {
  final CategoryModel? categoryToEdit;
  final bool isEditing;

  const _CategoryBottomSheetContent({
    this.categoryToEdit,
    required this.isEditing,
  });

  @override
  State<_CategoryBottomSheetContent> createState() =>
      _CategoryBottomSheetContentState();
}

class _CategoryBottomSheetContentState
    extends State<_CategoryBottomSheetContent> {
  late CategoryAddController controller;

  @override
  void initState() {
    super.initState();
    controller = CategoryAddController(
      categoryToEdit: widget.categoryToEdit,
      isEditing: widget.isEditing,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.appGradient,borderRadius: BorderRadius.vertical(top: Radius.circular(25)),), 
      child: Padding(
        padding: EdgeInsets.only(
          top: screenHeight * 0.02,
          left: screenWidth * 0.05,
          right: screenWidth * 0.05,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setModalState) {
              void updateState() => setModalState(() {});
      
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(screenWidth),
                  SizedBox(height: screenHeight * 0.015),                         
                  CategoryImagePicker( 
                    controller: controller,
                    onImagePicked: () async {
                      await pickCategoryImage(controller);
                      updateState();
                    },
                  ),
                  CategoryErrorText(
                    errorText: controller.imageError,
                    screenHeight: screenHeight,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  CategoryFormFields(
                    controller: controller,
                    screenHeight: screenHeight,
                  ),
                  SizedBox(height: screenHeight * 0.025),
                  CustomActionButton(
                    label: widget.isEditing ? "Update" : "Create",
                    backgroundColor: Colors.black,
                    onPressed: () async {
                      controller.validateFields();
                      updateState();
                      
                      if (controller.isFormValid) {
                        await saveCategory(
                          controller: controller,
                          context: context,
                          isEditing: widget.isEditing,
                          categoryToEdit: widget.categoryToEdit,
                        );
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
    return Text(
      widget.isEditing ? "Edit Category" : "Add Category",
      style: TextStyle(
        fontSize: screenWidth * 0.055,
        fontWeight: FontWeight.bold,
        fontFamily: 'BalooBhaina', 
      ),
    );
  }
}  