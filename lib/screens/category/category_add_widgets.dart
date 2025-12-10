import 'package:cream_ventory/screens/controller/category_add_controller.dart';
import 'package:cream_ventory/widgets/text_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CategoryImagePicker extends StatefulWidget {
  final CategoryAddController controller;
  final Function onImagePicked;

  const CategoryImagePicker({
    super.key,
    required this.controller,
    required this.onImagePicked,
  });

  @override
  State<CategoryImagePicker> createState() => _CategoryImagePickerState();
}
 
class _CategoryImagePickerState extends State<CategoryImagePicker> {
  @override
  void initState() {
    super.initState();
    // Set up callback to rebuild when image changes
    widget.controller.onImageUpdated = () {
      if (mounted) {
        setState(() {});
      }
    };
  }  

  @override
  Widget build(BuildContext context) {
    // Check if there's an image (web or mobile)
    final hasImage = kIsWeb    
        ? widget.controller.selectedImageBytes != null
        : widget.controller.selectedImage != null;

    return GestureDetector(
      onTap: widget.controller.isPickingImage 
          ? null 
          : () => widget.onImagePicked(),
      child: CircleAvatar(
        radius: 48,
        backgroundColor: hasImage ? null : Colors.grey[200],
        backgroundImage: hasImage
            ? (kIsWeb
                ? MemoryImage(widget.controller.selectedImageBytes!)
                : FileImage(widget.controller.selectedImage!)) as ImageProvider
            : null,
        child: !hasImage
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
      padding: const EdgeInsets.only(top: 8),
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
        const SizedBox(height: 20), 
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