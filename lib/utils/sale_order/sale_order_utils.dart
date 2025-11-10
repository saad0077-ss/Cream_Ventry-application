import 'package:cream_ventory/db/functions/sale/sale_db.dart';
import 'package:cream_ventory/db/functions/product_db.dart';
import 'package:cream_ventory/db/functions/user_db.dart';
import 'package:cream_ventory/db/models/sale/sale_model.dart';
import 'package:flutter/material.dart';

class SaleUtils {
  static List<SaleModel> filterSaleOrders(
    List<SaleModel> sales,
    String query,
    String filter,
  ) {
    final saleOrders = sales
        .where((sale) => sale.transactionType == TransactionType.saleOrder)
        .toList();
    final filteredOrders = saleOrders.where((sale) {
      final searchQuery = query.toLowerCase();
      return (sale.customerName?.toLowerCase() ?? '').contains(searchQuery) ||
          sale.invoiceNumber.toLowerCase().contains(searchQuery);
    }).toList();
    return filteredOrders
        .where(
          (sale) =>
              filter == 'ALL' ||
              (filter == 'Open orders'
                  ? sale.status == SaleStatus.open
                  : filter == 'Closed orders'
                  ? sale.status == SaleStatus.closed
                  : sale.status == SaleStatus.cancelled),
        )
        .toList();
  }

  static String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  static bool validateSaleOrderForClosing(SaleModel sale) {
    if (sale.status != SaleStatus.open) {
      return false;
    }
    if (sale.balanceDue < 0) {
      return false;
    }
    if (sale.items.isEmpty) {
      return false;
    }
    return true;
  }

  static bool validateSaleOrderForCancellation(SaleModel sale) {
    if (sale.status != SaleStatus.open) {
      return false;
    }
    return true;
  }

  static void handleCloseSale(
    BuildContext context,
    SaleModel sale,
    VoidCallback refresh,
  ) {
    if (!validateSaleOrderForClosing(sale)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invalid sale order for closing'),
          backgroundColor: Colors.red[600],
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Close Sale Order'),
        content: const Text('Are you sure you want to close this sale order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final user = await UserDB.getCurrentUser();
              final userId = user.id;
              final updatedSaleOrder = SaleModel(
                id: sale.id,
                invoiceNumber: sale.invoiceNumber,
                date: sale.date,
                customerName: sale.customerName,
                items: sale.items,
                total: sale.total,
                receivedAmount: sale.receivedAmount,
                balanceDue: sale.balanceDue,
                dueDate: sale.dueDate,
                transactionType: TransactionType.saleOrder,
                status: SaleStatus.closed,
                convertedToSaleId: null,
                userId: userId,
              );

              try {
                await SaleDB.updateSale(updatedSaleOrder);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Sale order #${sale.invoiceNumber} closed successfully',
                    ),
                    backgroundColor: Colors.green[600],
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                refresh();
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to close sale order: $error'),
                    backgroundColor: Colors.red[600],
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text('Close', style: TextStyle(color: Colors.red[600])),
          ),
        ],
      ),
    );
  }

  static void handleCancelSale(
    BuildContext context,
    SaleModel sale,
    VoidCallback refresh,
  ) {
    if (!validateSaleOrderForCancellation(sale)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invalid sale order for cancellation'),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Cancel Sale Order'),
        content: const Text('Are you sure you want to cancel this sale order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final user = await UserDB.getCurrentUser();
              final userId = user.id;
              final updatedSaleOrder = SaleModel(
                id: sale.id,
                invoiceNumber: sale.invoiceNumber,
                date: sale.date,
                customerName: sale.customerName,
                items: sale.items,
                total: sale.total,
                receivedAmount: sale.receivedAmount,
                balanceDue: sale.balanceDue,
                dueDate: sale.dueDate,
                transactionType: TransactionType.saleOrder,
                status: SaleStatus.cancelled,
                convertedToSaleId: null,
                userId: userId,
              );

              try {
                // Restock each product in the sale order
                for (var item in sale.items) {
                  final productId = item.id;
                  final quantity = item.quantity;
                  
                  // Restore stock using ProductDB
                  await ProductDB.cancelSale(productId, quantity);
                }

                // Update sale order status
                await SaleDB.updateSale(updatedSaleOrder);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Sale order #${sale.invoiceNumber} cancelled and products restocked successfully',
                      ),
                      backgroundColor: Colors.green[600],
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  refresh();
                }
              } catch (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to cancel sale order: $error'),
                      backgroundColor: Colors.red[600],
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: Text(
              'Cancel Order',
              style: TextStyle(color: Colors.red[600]),
            ),
          ),
        ],
      ),
    );
  }
}