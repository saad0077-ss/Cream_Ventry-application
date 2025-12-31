import 'package:cream_ventory/screens/controller/category_add_controller.dart';
import 'package:cream_ventory/screens/category/category_add_widgets.dart';
import 'package:cream_ventory/core/theme/theme.dart';
import 'package:cream_ventory/core/utils/category/category_add_utils.dart';
import 'package:flutter/material.dart';
import 'package:cream_ventory/widgets/custom_button.dart';
import 'package:cream_ventory/models/category_model.dart';

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
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.appGradient,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: 16,    
          left: 20,    
          right: 20,   
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setModalState) {
              void updateState() => setModalState(() {});

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 12), 
                  CategoryImagePicker( 
                    controller: controller,
                    onImagePicked: () async {
                      await pickCategoryImage(controller,context);
                      updateState();
                    }
                  ),
                  CategoryErrorText( 

                    errorText: controller.imageError,
                    screenHeight: 800, 
                  ),
                  const SizedBox(height: 16), 
                  CategoryFormFields(
                    controller: controller,
                    screenHeight: 800, 
                  ),
                  const SizedBox(height: 20), 
                  CustomActionButton(
                    height: 53,
                    width: 260,
                    label: widget.isEditing ? "Update" : "Create",
                    backgroundColor:  Colors.blueGrey,
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

  Widget _buildHeader() {
    return const Text(
      "Add Category", // Dynamic title handled below
      style: TextStyle(
        fontSize: 22, // screenWidth * 0.055
        fontWeight: FontWeight.bold,
        fontFamily: 'BalooBhaina',
      ), 
    );
  }
}