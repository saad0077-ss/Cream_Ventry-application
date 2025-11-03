import 'package:cream_ventory/db/functions/product_db.dart';
import 'package:cream_ventory/db/models/items/products/product_model.dart';
import 'package:cream_ventory/screen/adding/product/show_product_add_bottom_sheet.dart';
import 'package:flutter/material.dart';

class ProductActionsMenu extends StatelessWidget {
  final ProductModel product;
  final String index;

  const ProductActionsMenu({super.key, required this.product, required this.index});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      onSelected: (value) => _handleAction(context, value),
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'edit', child: _MenuItem(icon: Icons.edit, label: 'Edit', color: Colors.blue)),
        const PopupMenuItem(value: 'delete', child: _MenuItem(icon: Icons.delete, label: 'Delete', color: Colors.red)),
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
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Product', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87)),
        content: const Text('Are you sure you want to delete this product?', style: TextStyle(color: Colors.black54)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(BuildContext context) async {
    try {
      await ProductDB.deleteProduct(index);
      _showSnackBar(context, 'Product deleted successfully!', Colors.green);
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('Cannot delete product because it is part of existing sales')) {
        _showCannotDeleteDialog(context);
      } else {
        _showSnackBar(context, 'Failed to delete: $msg', Colors.red);
      }
    }
  }

  void _showSnackBar(BuildContext context, String message, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showCannotDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cannot Delete Product', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87)),
        content: const Text('This product cannot be deleted because it is part of existing sales records.', style: TextStyle(color: Colors.black54)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK', style: TextStyle(color: Colors.blue)))],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MenuItem({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}