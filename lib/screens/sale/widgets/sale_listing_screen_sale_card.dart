import 'package:flutter/material.dart';
import 'package:cream_ventory/models/sale_model.dart';

class SaleCard extends StatelessWidget {
  final String customerName;
  final double total;
  final double receivedAmount;
  final double balanceDue;
  final String date;
  final String invoiceNumber;
  final TransactionType transactionType;
  final SaleStatus status;
  final VoidCallback onTap;

  const SaleCard({
    super.key,
    required this.customerName,
    required this.total,
    required this.receivedAmount,
    required this.balanceDue,
    required this.date,
    required this.invoiceNumber,
    required this.transactionType,
    required this.status,
    required this.onTap,
  });

  // Helper methods (unchanged, just moved up)
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

  String _getTypeLabel() =>
      transactionType == TransactionType.sale ? 'Sale' : 'Sale Order';

  Color _getTypeColor() => transactionType == TransactionType.sale
      ? Colors.green.shade700
      : Colors.orange.shade700;

  Color _getTypeBackgroundColor() => transactionType == TransactionType.sale
      ? Colors.green.shade50
      : Colors.orange.shade50;

  Color _getTypeBorderColor() => transactionType == TransactionType.sale
      ? Colors.green.shade300
      : Colors.orange.shade300;

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

  IconData _getStatusIcon() {
    switch (status) {
      case SaleStatus.open:
        return Icons.lock_open;
      case SaleStatus.closed:
        return Icons.check_circle;
      case SaleStatus.cancelled:
        return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 900;
    final isCancelled = status == SaleStatus.cancelled;

    return Opacity(
      opacity: isCancelled ? 0.6 : 1.0, // Dim cancelled cards
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isCancelled
                    ? [Colors.grey.shade100, Colors.grey.shade50]
                    : [Colors.white, Colors.grey.shade50],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isCancelled ? Colors.grey.shade300 : Colors.grey.shade200,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
                  // Header: Invoice + Type + Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            // Invoice Number
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                                  Colors.blue.shade400,
                                  Colors.blue.shade600
                                ]),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                invoiceNumber,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isDesktop ? 13 : 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            // Type Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getTypeBackgroundColor(),
                                border:
                                    Border.all(color: _getTypeBorderColor()),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _getTypeLabel(),
                                style: TextStyle(
                                    color: _getTypeColor(),
                                    fontSize: isDesktop ? 11 : 10,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            // Status Badge (only for Sale Orders)
                            if (transactionType == TransactionType.saleOrder)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getStatusBackgroundColor(),
                                  border: Border.all(
                                      color: _getStatusBorderColor()),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(_getStatusIcon(),
                                        size: 14, color: _getStatusColor()),
                                    const SizedBox(width: 4),
                                    Text(
                                      _getStatusLabel().toUpperCase(),
                                      style: TextStyle(
                                          color: _getStatusColor(),
                                          fontSize: isDesktop ? 11 : 10,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios,
                          size: isDesktop ? 18 : 16,
                          color: Colors.grey.shade400),
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
                            borderRadius: BorderRadius.circular(10)),
                        child: Icon(Icons.person_outline,
                            size: isDesktop ? 22 : 20,
                            color: Colors.blue.shade700),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          customerName,
                          style: TextStyle(
                            fontSize: isDesktop ? 16 : 15,
                            fontWeight: FontWeight.w600,
                            color: isCancelled
                                ? Colors.grey.shade600
                                : Colors.grey.shade900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Payment Summary Box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isCancelled
                          ? Colors.grey.shade100
                          : Colors.green.shade50.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isCancelled
                              ? Colors.grey.shade300
                              : Colors.green.shade200),
                    ),
                    child: Column(
                      children: [
                        // Total Amount
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Amount',
                                style: TextStyle(
                                    fontSize: isDesktop ? 13 : 12,
                                    color: Colors.grey.shade700)),
                            Text(
                              '₹${total.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: isDesktop ? 18 : 17,
                                fontWeight: FontWeight.w700,
                                color: isCancelled
                                    ? Colors.grey.shade600
                                    : Colors.green.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Received Amount
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.check_circle,
                                    size: 16, color: Colors.green.shade600),
                                SizedBox(width: 6),
                                Text('Received',
                                    style: TextStyle(
                                        fontSize: isDesktop ? 13 : 12,
                                        color: Colors.grey.shade700)),
                              ],
                            ),
                            Text(
                              '₹${receivedAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: isDesktop ? 16 : 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade700),
                            ),
                          ],
                        ),
                        if (balanceDue > 0) ...[
                          const SizedBox(height: 6),
                          // Balance Due
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.schedule,
                                      size: 16, color: Colors.orange.shade600),
                                  SizedBox(width: 6),
                                  Text('Balance Due',
                                      style: TextStyle(
                                          fontSize: isDesktop ? 13 : 12,
                                          color: Colors.orange.shade800,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                              Text(
                                '₹${balanceDue.toStringAsFixed(2)}',
                                style: TextStyle(
                                    fontSize: isDesktop ? 16 : 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.orange.shade700),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.calendar_today,
                          size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(date,
                          style: TextStyle(
                              fontSize: isDesktop ? 13 : 12,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Updated Factory Constructor
  factory SaleCard.fromSaleModel({
    required SaleModel sale,
    required VoidCallback onTap,
  }) {
    return SaleCard(
      customerName: sale.customerName ?? 'Walk-in Customer',
      total: sale.total,
      receivedAmount: sale.receivedAmount,
      balanceDue: sale.balanceDue,
      date: sale.date,
      invoiceNumber: sale.invoiceNumber,
      transactionType: sale.transactionType ?? TransactionType.sale,
      status: sale.status,
      onTap: onTap,
    );
  }
}
