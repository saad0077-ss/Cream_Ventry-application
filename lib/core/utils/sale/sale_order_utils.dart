import 'package:cream_ventory/database/functions/sale/sale_db.dart';
import 'package:cream_ventory/database/functions/user_db.dart';
import 'package:cream_ventory/models/sale_model.dart';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

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
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: 'Invalid sale order for closing',
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          width: MediaQuery.of(context).size.width * 0.9, 
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
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: Colors.green[600],
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              Text(
                'Close Sale Order',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              
              // Content
              Text(
                'Are you sure you want to close this sale order?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              
              // Order details
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Order #${sale.invoiceNumber}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Text(
                        'Cancel',
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
                        Navigator.pop(dialogContext);
                        
                        try {
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

                          await SaleDB.updateSale(updatedSaleOrder);
                          
                          if (context.mounted) {
                            showTopSnackBar(
                              Overlay.of(context),
                              CustomSnackBar.success(
                                message: 'Sale order #${sale.invoiceNumber} closed successfully',
                              ),
                            );
                            refresh();
                          }
                        } catch (error) {
                          if (context.mounted) {
                            showTopSnackBar(
                              Overlay.of(context),
                              CustomSnackBar.error(
                                message: 'Failed to close sale order: $error',
                              ),
                            );
                          }
                        } 
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Close Order',
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
    );
  }

  static void handleCancelSale(
    BuildContext context,
    SaleModel sale,
    VoidCallback refresh,
  ) {
     if (!validateSaleOrderForCancellation(sale)) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: 'Invalid sale order for cancellation',
        ), 
      );
      return;
    }
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container( 
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 400),
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
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cancel_outlined,
                  size: 48,
                  color: Colors.red[600],
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              Text(
                'Cancel Sale Order',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              
              // Content
              Text(
                'Are you sure you want to cancel this sale order? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              
              // Order details
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Order #${sale.invoiceNumber}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Text(
                        'No, Keep It',
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
                        Navigator.pop(dialogContext);

                        try {
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

                          await SaleDB.updateSale(updatedSaleOrder);

                          if (context.mounted) {
                            showTopSnackBar(
                              Overlay.of(context),
                              CustomSnackBar.success(
                                message: 'Sale order #${sale.invoiceNumber} cancelled successfully',
                              ),
                            );
                            refresh();
                          }
                        } catch (error) {
                          if (context.mounted) {
                            showTopSnackBar(
                              Overlay.of(context),
                              CustomSnackBar.error(
                                message: 'Failed to cancel sale order: $error',
                              ),
                            ); 
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Yes, Cancel',
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
    );
  }
}