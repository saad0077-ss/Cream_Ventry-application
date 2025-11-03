import 'package:cream_ventory/screen/adding/controller/category_add_controller.dart';
import 'package:cream_ventory/widgets/text_field.dart';
import 'package:flutter/material.dart';


class CategoryImagePicker extends StatelessWidget {
  final CategoryAddController controller;
  final Function onImagePicked;

  const CategoryImagePicker({
    super.key,
    required this.controller,
    required this.onImagePicked,
  });

  @override
  Widget build(BuildContext context) {
    
    return GestureDetector(
      onTap: controller.isPickingImage ? null : () => onImagePicked(),
      child: CircleAvatar( 
        radius:48,
        backgroundImage: controller.selectedImage != null
            ? FileImage(controller.selectedImage!)
            : null,
        backgroundColor: controller.selectedImage == null
            ? Colors.grey[200]
            : null,
        child: controller.selectedImage == null
            ? Icon(
                Icons.add_a_photo,
                size: 32,
                color: Colors.grey[600],
              )
            : null,
      ),
    );
  }
}

class CategoryErrorText extends StatelessWidget {
  final String? errorText;
  final double screenHeight;

  const CategoryErrorText({
    super.key,
    required this.errorText,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    if (errorText == null) return const SizedBox.shrink();
    
    return Padding(
      padding: EdgeInsets.only(top: 8),
      child: Text(
        errorText!,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 14,
        ),
      ),
    );
  }
}

class CategoryFormFields extends StatelessWidget {
  final CategoryAddController controller;
  final double screenHeight;

  const CategoryFormFields({
    super.key,
    required this.controller,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          labelText: 'Category Name',
          errorText: controller.nameError,
          controller: controller.nameController,
        ),
        SizedBox(height: 20), 
        CustomTextField(
          labelText: 'Category Description',
          errorText: controller.descriptionError,
          controller: controller.descriptionController,
          maxLines: 4,
        ),
      ],
    );
  }
}