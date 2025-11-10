import 'dart:io';
import 'package:cream_ventory/db/functions/party_db.dart';
import 'package:cream_ventory/db/functions/product_db.dart';
import 'package:cream_ventory/db/functions/sale/sale_db.dart';
import 'package:cream_ventory/db/functions/sale/sale_item_db.dart';
import 'package:cream_ventory/db/functions/user_db.dart';
import 'package:cream_ventory/db/models/sale/sale_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class AppConstants {
  static const String customerLabel = 'Customer';
  static const String invoiceNoLabel = 'Invoice No';
  static const String dateLabel = 'Date';
  static const String dueDateLabel = 'Due Date';
  static const String noItemsText = 'No items added yet.';
  static const String selectCustomerHint = 'Select a customer';
  static const String noCustomersHint = 'No customers available';
  static const String saveSuccess = 'saved successfully!';
  static const String updateSuccess = 'updated successfully!';
  static const String deleteSuccess = 'deleted successfully!';
  static const String addItemError = 'Please add at least one item to save.';
  static const String selectCustomerError = 'Please select a customer.';
}

class SaleAddUtils {
  static const String _fallbackImagePath = 'assets/images/ice2.jpg';

  static Future<void> initializeForm({
    required SaleModel? sale,
    required TextEditingController customerController,
    required TextEditingController invoiceController,
    required TextEditingController dateController,
    required TextEditingController receivedController,
    required TextEditingController dueDateController,
    required bool isEditMode,
    required TransactionType transactionType,
    required Function() updateBalanceDue,
  }) async {
    debugPrint('SaleAddUtils.initializeForm called, isEditMode: $isEditMode');
    try {
      await PartyDb.loadParties();
      await SaleItemDB.init();
      if (isEditMode) {
        final currentSale = sale!;
        customerController.text = currentSale.customerName ?? '';
        invoiceController.text = currentSale.invoiceNumber;
        dateController.text = currentSale.date;
        receivedController.text = currentSale.receivedAmount.toString();
        dueDateController.text = currentSale.dueDate ?? '';
        await SaleItemDB.loadItemsForEdit(currentSale.items);
        debugPrint('Form initialized for edit mode, saleId: ${currentSale.id}');
      } else {
        dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
        if (transactionType == TransactionType.saleOrder) {
          dueDateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
        }
        await SaleDB.init();
        final latestInvoice = await SaleDB.getLatestInvoiceNumber();
        invoiceController.text = (latestInvoice + 1).toString();
        debugPrint('Form initialized for new sale, invoice: ${invoiceController.text}');
      }
      updateBalanceDue();
    } catch (error) {
      debugPrint('Error in initializeForm: $error');
      throw Exception('Failed to initialize form: $error');
    }
  }

  static Future<void> selectDate(
      BuildContext context, TextEditingController dateController) async {
    debugPrint('Selecting date');
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      debugPrint('Date selected: ${dateController.text}');
    }
  }

  static Future<void> selectDueDate(
      BuildContext context, TextEditingController dueDateController) async {
    debugPrint('Selecting due date');
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      dueDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      debugPrint('Due date selected: ${dueDateController.text}');
    }
  }

  static Future<void> saveSale({
    required SaleModel sale,
    required BuildContext context,
    required bool isEditMode,
    required bool isSaveAndNew,
  }) async {
    debugPrint('SaleAddUtils.saveSale called for sale: ${sale.id}');
    try {
      final items = await SaleItemDB.getSaleItems(userId: sale.userId);
      debugPrint('Items fetched: ${items.length}');
      if (items.isEmpty) {
        debugPrint('Validation failed: No items');
        if (context.mounted) {
          showSnackBarInSales(context, AppConstants.addItemError, Colors.red);
        }
        return;
      }
      if (sale.customerName == null || sale.customerName!.isEmpty) {
        debugPrint('Validation failed: No customer');
        if (context.mounted) {
          showSnackBarInSales(context, AppConstants.selectCustomerError, Colors.red);
        }
        return;
      }
      for (var item in items) {
        final product = await ProductDB.getProduct(item.id);
        debugPrint('Checking stock for ${item.productName}, stock: ${product?.stock}, required: ${item.quantity}');
        if (product == null || product.stock < item.quantity) {
          if (context.mounted) {
            showSnackBarInSales(context, 'Insufficient stock for ${item.productName}', Colors.red);
          }
          return;
        }
      }
      debugPrint('All validations passed, saving sale');
      isEditMode ? await SaleDB.updateSale(sale) : await SaleDB.addSale(sale);
      await SaleItemDB.clearSaleItems();
      await PartyDb.loadParties();
      await PartyDb.updateBalanceAfterSale(sale);
      debugPrint('Sale saved successfully');
    } catch (e) {
      debugPrint('Error in saveSale: $e');    
      if (context.mounted) {
        showSnackBarInSales(context, 'Failed to save sale: $e', Colors.red);
      }
      rethrow;
    }
  }

  static Future<void> deleteSale({
    required SaleModel sale,
    required BuildContext context,
    required TransactionType transactionType,
  }) async {
    debugPrint('SaleAddUtils.deleteSale called for sale: ${sale.id}');
    if (context.mounted) {
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        title: 'Confirm Delete',
        text: 'Are you sure you want to delete this ${transactionType == TransactionType.sale ? "sale" : "sale order"}? This will restore the stock for all items.',
        confirmBtnText: 'Delete',
        cancelBtnText: 'Cancel',
        confirmBtnColor: Colors.red,
        onConfirmBtnTap: () async {
          Navigator.pop(context);
          try {
            for (var item in sale.items) {
              debugPrint('Restocking ${item.productName}, quantity: ${item.quantity}');
              await ProductDB.restockProduct(item.id, item.quantity);
            }
            await SaleDB.deleteSale(sale.id);
            await SaleItemDB.clearSaleItems();
            debugPrint('Sale deleted successfully');
            if (context.mounted) {
              showSnackBarInSales(
                context,
                '${transactionType == TransactionType.sale ? "Sale" : "Sale Order"} ${AppConstants.deleteSuccess}',
                Colors.green,
              );
            }
          } catch (error) {
            debugPrint('Error deleting sale: $error');
            if (context.mounted) {
              showSnackBarInSales(context, 'Failed to delete: $error', Colors.red);
            }
          }
        },
      );
    }
  }

  static Future<bool> handleBackNavigation({
    required BuildContext context,
    required SaleModel? sale,
    required TransactionType transactionType,
    required TextEditingController customerController,
    required TextEditingController invoiceController,
    required TextEditingController dateController,
    required TextEditingController receivedController,
    required TextEditingController dueDateController,
    required bool isEditMode,
    required bool isEditable,
  }) async {
    debugPrint('Handling back navigation, isEditMode: $isEditMode');
    bool hasUnsavedChanges = false;
    final user = await UserDB.getCurrentUser();
    final items = await SaleItemDB.getSaleItems(userId: user.id);

    if (isEditMode && isEditable) {
      final currentSale = sale!;
      hasUnsavedChanges = customerController.text != (currentSale.customerName ?? '') ||
          invoiceController.text != currentSale.invoiceNumber ||
          dateController.text != currentSale.date ||
          double.tryParse(receivedController.text) != currentSale.receivedAmount ||
          dueDateController.text != (currentSale.dueDate ?? '') ||
          items.length != currentSale.items.length ||
          items.any((item) => !currentSale.items.contains(item));
    } else if (!isEditMode) {
      hasUnsavedChanges = items.isNotEmpty ||
          customerController.text.isNotEmpty ||
          receivedController.text.isNotEmpty ||
          (dueDateController.text.isNotEmpty && transactionType == TransactionType.saleOrder);
    }

    if (hasUnsavedChanges) {
      debugPrint('Unsaved changes detected');
      if (context.mounted) {
        return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Confirm Cancel'),
                content: Text(
                  'Are you sure you want to cancel this ${transactionType == TransactionType.sale ? "sale" : "sale order"}? All unsaved changes will be lost, and stock will be restored.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () async {
                      try {
                        for (var item in items) {
                          debugPrint(
                            'Canceling sale - Product: ${item.productName}, ID: ${item.id}, Quantity Restored: ${item.quantity}',
                          );
                          await ProductDB.restockProduct(item.id, item.quantity);
                        }
                        await SaleItemDB.clearSaleItems();
                        if (context.mounted) {
                          Navigator.pop(context, true);
                        }
                        debugPrint('Back navigation confirmed, stock restored');
                      } catch (error) {
                        debugPrint('Error restoring stock: $error');
                        if (context.mounted) {
                          showSnackBarInSales(context, 'Failed to restore stock: $error', Colors.red);
                          Navigator.pop(context, false);
                        }
                      }
                    },
                    child: const Text('Yes', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ) ??
            false;
      }
    } else {
      debugPrint('No unsaved changes, clearing items');
      await SaleItemDB.clearSaleItems();
      return true;
    }
    return false;
  }

  static ImageProvider getImageProvider(String? imagePath) {
    debugPrint('Loading image for path: $imagePath');
    if (imagePath != null && imagePath.isNotEmpty) {
      try {
        final file = File(imagePath);
        if (file.existsSync()) {
          return FileImage(file);
        }
      } catch (e) {
        debugPrint('Invalid image file at $imagePath: $e');
      }
    }
    debugPrint('Using fallback image');
    return const AssetImage(_fallbackImagePath);
  }

  static void showSnackBarInSales(BuildContext context, String message, Color color) { 
    debugPrint('Showing SnackBar: $message');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: color,
        ),
      );
    }
  }
}