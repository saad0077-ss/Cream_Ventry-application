import 'package:cream_ventory/database/functions/product_db.dart';
import 'package:cream_ventory/models/product_model.dart';
import 'package:cream_ventory/screens/product/widgets/show_product_add_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class ProductActionsMenu extends StatelessWidget {
  final ProductModel product;
  final String index;

  const ProductActionsMenu({super.key, required this.product, required this.index});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      // Beautiful gradient icon
      icon: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6EE2F5), Color(0xFF6454F0)],
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 26),
      ),
      offset: const Offset(0, 60),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 20,
      shadowColor: Colors.black.withOpacity(0.25),
      color: Colors.white.withOpacity(0.97),
      surfaceTintColor: Colors.transparent,
      onSelected: (value) => _handleAction(context, value),
      itemBuilder: (context) => [
        // Edit Item
        PopupMenuItem(
          value: 'edit',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.edit_outlined, color: Colors.blueAccent, size: 22),
              ),
              const SizedBox(width: 14),
              const Text(
                'Edit Product',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
            ],
          ),
        ),
        // Delete Item
        PopupMenuItem(
          value: 'delete',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
              ),
              const SizedBox(width: 14),
              Text(
                'Delete Product',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.red.shade700),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleAction(BuildContext context, String value) async {
    if (value == 'edit') {
      showAddProductBottomSheet(context, existingProduct: product, productKey: index);
    } else if (value == 'delete') {
      final confirm = await _showDeleteDialog(context);
      if (confirm == true) await _deleteProduct(context);
    }
  }

  Future<bool?> _showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 10,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFEBEE), Color(0xFFFFCDD2)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 48,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Delete Product",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5),
                  children: [
                    const TextSpan(text: "Are you sure you want to delete "),
                    TextSpan(
                      text: "'${product.name}'",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const TextSpan(text: "? This action cannot be undone."),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                      ),
                      child: const Text("Cancel", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      child: const Text("Delete", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteProduct(BuildContext context) async {
    try {
      await ProductDB.deleteProduct(index);
      _showSnackBar(context, 'Product deleted successfully!', isSuccess: true);
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('Cannot delete product because it is part of existing sales')) {
        _showCannotDeleteDialog(context);
      } else {
        _showSnackBar(context, 'Failed to delete: $msg', isSuccess: false);
      }
    }
  }

  void _showSnackBar(BuildContext context, String message, {required bool isSuccess}) {
    showTopSnackBar(
      Overlay.of(context),
      isSuccess
          ? CustomSnackBar.success(
              message: message,
              backgroundColor: Colors.green.shade600,
            )
          : CustomSnackBar.error(
              message: message,
              backgroundColor: Colors.red.shade600,
            ),
      displayDuration: const Duration(seconds: 3),
    );
  }

  void _showCannotDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 10,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFF3E0), Color(0xFFFFCC80)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 15, spreadRadius: 2),
                  ],
                ),
                child: Icon(Icons.receipt_long_outlined, size: 48, color: Colors.orange.shade700),
              ),
              const SizedBox(height: 20),
              const Text(
                "Cannot Delete Product",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5),
                  children: [
                    const TextSpan(text: "The product "),
                    TextSpan(text: "'${product.name}'", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                    const TextSpan(text: " is part of existing "),
                    const TextSpan(text: "sales records", style: TextStyle(fontWeight: FontWeight.w600)),
                    const TextSpan(text: ".\n\nIt cannot be deleted to maintain data integrity."),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                  child: const Text("Understood", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  } 
}