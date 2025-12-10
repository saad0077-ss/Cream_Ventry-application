import 'dart:convert';
import 'dart:io';
import 'package:cream_ventory/core/constants/sale_add_screen_constant.dart';
import 'package:cream_ventory/database/functions/party_db.dart';
import 'package:cream_ventory/database/functions/product_db.dart';
import 'package:cream_ventory/database/functions/sale/sale_db.dart';
import 'package:cream_ventory/database/functions/sale/sale_item_db.dart';
import 'package:cream_ventory/database/functions/user_db.dart';
import 'package:cream_ventory/models/sale_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

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
        dateController.text = DateFormat('dd MMM yyyy').format(DateTime.now());
        if (transactionType == TransactionType.saleOrder) {
          dueDateController.text =
              DateFormat('dd MMM yyyy').format(DateTime.now());
        }
        await SaleDB.init();
        final latestInvoice = await SaleDB.getLatestInvoiceNumber();
        invoiceController.text = (latestInvoice + 1).toString();
        debugPrint(
            'Form initialized for new sale, invoice: ${invoiceController.text}');
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
      dateController.text = DateFormat('dd MMM yyyy').format(picked);
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
      dueDateController.text = DateFormat('dd MMM yyyy').format(picked);
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
          showTopSnackBar(
            Overlay.of(context),
            CustomSnackBar.error(
              message: AppConstants.addItemError,
            ),
          );
        }
        return;
      }
      if (sale.customerName == null || sale.customerName!.isEmpty) {
        debugPrint('Validation failed: No customer');
        if (context.mounted) {
          showTopSnackBar(
            Overlay.of(context),
            CustomSnackBar.error(
              message: AppConstants.selectCustomerError,
            ),
          );
        }
        return;
      }

      // IMPORTANT: Only check and deduct stock for regular SALES, NOT for sale orders
      // Sale orders will have stock deducted when they are closed
      if (sale.transactionType == TransactionType.sale) {
        for (var item in items) {
          final product = await ProductDB.getProduct(item.id);
          debugPrint(
              'Checking stock for ${item.productName}, stock: ${product?.stock}, required: ${item.quantity}');
          if (product == null || product.stock < item.quantity) {
            if (context.mounted) {
              showTopSnackBar(
                Overlay.of(context),
                CustomSnackBar.error(
                  message: 'Insufficient stock for ${item.productName}',
                ),
              );
            }
            return;
          }
        }
      } else {
        // For sale orders, just validate that products exist (no stock check)       
        debugPrint('Sale Order: Skipping stock validation and deduction');
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
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            message: 'Failed to save sale: $e',
          ),
        );
      }
      rethrow;
    }
  }

  static Future<void> deleteSale({
    required SaleModel sale,
    required BuildContext context,
    required TransactionType transactionType,
  }) async {
    debugPrint('SaleAddUtils.deleteSale called for sale ID: ${sale.id}');

    final bool shouldRestock = sale.status == SaleStatus.closed;
    final String typeLabel =
        transactionType == TransactionType.sale ? "Sale" : "Sale Order";

    final bool? confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 400),
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
              // Icon
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

              // Title
              Text(
                "Delete $typeLabel",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Message
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                      fontSize: 15, color: Colors.grey[700], height: 1.5),
                  children: [
                    const TextSpan(text: "Are you sure you want to delete "),
                    TextSpan(
                      text: "#${sale.invoiceNumber}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    if (sale.customerName != null &&
                        sale.customerName!.isNotEmpty)
                      TextSpan(text: " for ${sale.customerName}"),
                    const TextSpan(text: "?\n"),
                    TextSpan(
                      text: shouldRestock
                          ? "Stock will be restored for all items."
                          : "No stock will be restored (${sale.status == SaleStatus.cancelled ? 'already cancelled' : 'still open'}).",
                      style: TextStyle(
                        fontSize: 14,
                        color: shouldRestock
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: "\n\nThis action cannot be undone."),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        side:
                            BorderSide(color: Colors.grey.shade400, width: 1.5),
                      ),
                      child: const Text("Cancel",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      child: const Text("Delete",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    // User confirmed
    if (confirm == true) {
      try {
        if (shouldRestock) {
          for (var item in sale.items) {
            await ProductDB.restockProduct(item.id, item.quantity);
            debugPrint(
                'Restocked on delete: ${item.productName} x${item.quantity}');
          }
        } else {
          debugPrint('No restock needed — sale status: ${sale.status}');
        }

        await SaleDB.deleteSale(sale.id);
        await SaleItemDB.clearSaleItems();

        if (context.mounted) {
          showTopSnackBar(
            Overlay.of(context),
            CustomSnackBar.success(
              message: '$typeLabel #${sale.invoiceNumber} deleted successfully',
            ),
          );
        }
      } catch (error) {
        debugPrint('Error deleting sale: $error');
        if (context.mounted) {
          showTopSnackBar(
            Overlay.of(context),
            CustomSnackBar.error(
              message: 'Failed to delete: $error',
            ),
          );
        }
      }
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
      hasUnsavedChanges =
          customerController.text != (currentSale.customerName ?? '') ||
              invoiceController.text != currentSale.invoiceNumber ||
              dateController.text != currentSale.date ||
              double.tryParse(receivedController.text) !=
                  currentSale.receivedAmount ||
              dueDateController.text != (currentSale.dueDate ?? '') ||
              items.length != currentSale.items.length ||
              items.any((item) => !currentSale.items.contains(item));
    } else if (!isEditMode) {
      hasUnsavedChanges = items.isNotEmpty ||
          customerController.text.isNotEmpty ||
          receivedController.text.isNotEmpty ||
          (dueDateController.text.isNotEmpty &&
              transactionType == TransactionType.saleOrder);
    }

    if (hasUnsavedChanges) {
      debugPrint('Unsaved changes detected');
      if (context.mounted) {
        return await showDialog<bool>(
              context: context,
              builder: (context) => Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
                backgroundColor: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.warning_rounded,
                          size: 48,
                          color: Colors.orange[700],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      Text(
                        'Unsaved Changes',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Content
                      Text(
                        'Are you sure you want to cancel this ${transactionType == TransactionType.sale ? "sale" : "sale order"}?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        transactionType == TransactionType.sale
                            ? 'All unsaved changes will be lost, and stock will be restored.'
                            : 'All unsaved changes will be lost. (No stock will be restored for sale orders)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey[300]!),
                                ),
                              ),
                              child: Text(
                                'Keep Editing',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                try {
                                  for (var item in items) {
                                    debugPrint(
                                      'Canceling sale - Product: ${item.productName}, ID: ${item.id}, Quantity Restored: ${item.quantity}',
                                    );
                                  }
                                  await SaleItemDB.clearSaleItems();
                                  if (context.mounted) {
                                    Navigator.pop(context, true);
                                  }          
                                  debugPrint(
                                      'Back navigation confirmed, stock restored');
                                } catch (error) {
                                  debugPrint('Error restoring stock: $error');
                                  if (context.mounted) {
                                    showTopSnackBar(
                                      Overlay.of(context),
                                      CustomSnackBar.error(
                                        message:
                                            'Failed to restore stock: $error',
                                      ),
                                    );
                                    Navigator.pop(context, false);
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[600],
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Discard',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
    debugPrint('getImageProvider called with: $imagePath');

    if (imagePath == null || imagePath.trim().isEmpty) {
      debugPrint('Image path is null or empty → using fallback');
      return const AssetImage(_fallbackImagePath);
    }

    final trimmedPath = imagePath.trim();

    // Web: handle base64 or data URL
    if (kIsWeb) {
      try {
        Uint8List bytes;

        if (trimmedPath.startsWith('data:image')) {
          // Full data URL: data:image/png;base64,....
          final uriData = UriData.parse(trimmedPath);
          bytes = uriData.contentAsBytes();
        } else if (trimmedPath.length > 1000 || !trimmedPath.contains('.')) {
          // Likely raw base64 (very long, no file extension)
          bytes = base64Decode(trimmedPath);
        } else {
          // Fallback: treat as raw base64 (in case prefix was removed)
          bytes = base64Decode(trimmedPath);
        }

        debugPrint('Web image loaded successfully from base64/data URL');
        return MemoryImage(bytes);
      } catch (e) {
        debugPrint('Failed to decode web image (base64/data URL): $e');
        return const AssetImage(_fallbackImagePath);
      }
    }

    // Mobile: file path
    else {
      try {
        final file = File(trimmedPath);
        if (file.existsSync()) {
          debugPrint('Mobile image loaded from file: $trimmedPath');
          return FileImage(file);
        } else {
          debugPrint('File does not exist: $trimmedPath');
          return const AssetImage(_fallbackImagePath);
        }
      } catch (e) {
        debugPrint('Error loading file image: $e');
        return const AssetImage(_fallbackImagePath);
      }
    }
  }
}
