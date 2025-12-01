import 'package:flutter/material.dart';
import 'package:cream_ventory/models/sale_model.dart';

class SaleCard extends StatelessWidget {
  final String customerName;
  final String amount;
  final String date;
  final String invoiceNumber;
  final TransactionType transactionType;
  final SaleStatus status;
  final VoidCallback onTap;

  const SaleCard({
    super.key,
    required this.customerName,
    required this.amount,
    required this.date,
    required this.invoiceNumber,
    required this.transactionType,
    required this.status,
    required this.onTap,
  });

  // Helper method to get transaction type label
  String _getTypeLabel() {
    switch (transactionType) {
      case TransactionType.sale:
        return 'Sale';
      case TransactionType.saleOrder:
        return 'Sale Order';
    }
  }

  // Helper method to get transaction type colors
  Color _getTypeColor() {
    switch (transactionType) {
      case TransactionType.sale:
        return Colors.green.shade700;
      case TransactionType.saleOrder:
        return Colors.orange.shade700;
    }
  }

  Color _getTypeBackgroundColor() {
    switch (transactionType) {
      case TransactionType.sale:
        return Colors.green.shade50;
      case TransactionType.saleOrder:
        return Colors.orange.shade50;
    }
  }

  Color _getTypeBorderColor() {
    switch (transactionType) {
      case TransactionType.sale:
        return Colors.green.shade300;
      case TransactionType.saleOrder:
        return Colors.orange.shade300;
    }
  }

  // Helper method to get status label
  String _getStatusLabel() {
    switch (status) {
      case SaleStatus.open:
        return 'Open';
      case SaleStatus.closed:
        return 'Closed';
      case SaleStatus.cancelled:
        return 'Cancelled';
    }
  }

  // Helper method to get status color
  Color _getStatusColor() {
    switch (status) {
      case SaleStatus.open:
        return Colors.blue.shade700;
      case SaleStatus.closed:
        return Colors.green.shade700;
      case SaleStatus.cancelled:
        return Colors.red.shade700;
    }
  }

  // Helper method to get status background color
  Color _getStatusBackgroundColor() {
    switch (status) {
      case SaleStatus.open:
        return Colors.blue.shade50;
      case SaleStatus.closed:
        return Colors.green.shade50;
      case SaleStatus.cancelled:
        return Colors.red.shade50;
    }
  }

  // Helper method to get status border color
  Color _getStatusBorderColor() {
    switch (status) {
      case SaleStatus.open:
        return Colors.blue.shade300;
      case SaleStatus.closed:
        return Colors.green.shade300;
      case SaleStatus.cancelled:
        return Colors.red.shade300;
    }
  }

  // Helper method to get status icon
  IconData _getStatusIcon() {
    switch (status) {
      case SaleStatus.open:
        return Icons.lock_open;
      case SaleStatus.closed:
        return Icons.check_circle_outline;
      case SaleStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 900;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? 20 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row - Invoice Number, Type Label, and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // Invoice Number Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade400,
                                  Colors.blue.shade600,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              invoiceNumber,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isDesktop ? 13 : 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          // Type Label Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getTypeBackgroundColor(),
                              border: Border.all(
                                color: _getTypeBorderColor(),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getTypeLabel(),
                              style: TextStyle(
                                color: _getTypeColor(),
                                fontSize: isDesktop ? 11 : 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          // Status Badge - Only show for Sale Orders
                          if (transactionType == TransactionType.saleOrder)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusBackgroundColor(),
                                border: Border.all(
                                  color: _getStatusBorderColor(),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getStatusIcon(),
                                    size: isDesktop ? 14 : 13,
                                    color: _getStatusColor(),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _getStatusLabel().toUpperCase(),
                                    style: TextStyle(
                                      color: _getStatusColor(),
                                      fontSize: isDesktop ? 11 : 10,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: isDesktop ? 18 : 16,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Customer Name
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.person_outline,
                        size: isDesktop ? 22 : 20,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Customer',
                            style: TextStyle(
                              fontSize: isDesktop ? 12 : 11,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            customerName,
                            style: TextStyle(
                              fontSize: isDesktop ? 16 : 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Amount and Date Row
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.shade100,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Amount
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Amount',
                              style: TextStyle(
                                fontSize: isDesktop ? 11 : 10,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              amount,
                              style: TextStyle(
                                fontSize: isDesktop ? 20 : 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Date
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: isDesktop ? 14 : 13,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                date,
                                style: TextStyle(
                                  fontSize: isDesktop ? 13 : 12,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Factory constructor to create SaleCard from SaleModel
  factory SaleCard.fromSaleModel({
    required SaleModel sale,
    required VoidCallback onTap,
  }) {
    return SaleCard( 
      customerName: sale.customerName ?? 'Walk-in Customer',
      amount: '₹${sale.total.toStringAsFixed(2)}',
      date: sale.date,
      invoiceNumber: sale.invoiceNumber,
      transactionType: sale.transactionType ?? TransactionType.sale,
      status: sale.status,
      onTap: onTap,
    );
  }
}