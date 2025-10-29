import 'package:cream_ventory/db/models/sale/sale_model.dart';
import 'package:cream_ventory/screen/adding/sale/sale_add_screen.dart';
import 'package:cream_ventory/screen/sale_order/widgets/info_column.dart';
import 'package:flutter/material.dart';

class SaleOrderCard extends StatelessWidget {
  final bool isOpen;
  final bool isCancelled;
  final String orderNumber;
  final String date;
  final String advance;
  final String balance;
  final String dueDate;
  final String customerName;
  final String? closeButtonText;
  final String? cancelButtonText;
  final VoidCallback? onCloseButtonPressed;
  final VoidCallback? onCancelButtonPressed;
  final SaleModel sale;

  const SaleOrderCard({
    super.key,
    required this.isOpen,
    required this.isCancelled,
    required this.orderNumber,
    required this.date,
    required this.advance,
    required this.balance,
    required this.dueDate,
    required this.customerName,
    required this.closeButtonText,
    this.cancelButtonText,
    required this.onCloseButtonPressed,
    this.onCancelButtonPressed,
    required this.sale,
  });

  @override
  Widget build(BuildContext context) {
    // Determine status text and colors based on sale status
    final statusText = isOpen ? 'OPEN' : isCancelled ? 'CANCELLED' : 'CLOSED';
    final statusColor = isOpen
        ? Colors.orange
        : isCancelled
            ? Colors.grey
            : Colors.green;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: InkWell(
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SaleScreen(
                sale: sale,
                transactionType: TransactionType.saleOrder,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: isOpen
                    ? [Colors.white, Colors.orange[50]!]
                    : isCancelled  
                        ? [Colors.white, Colors.grey[50]!]
                        : [Colors.white, Colors.green[50]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: isOpen
                    ? Colors.orange[200]!
                    : isCancelled
                        ? Colors.grey[200]!
                        : Colors.green[200]!,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: statusColor[400]!,
                                ),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  color: statusColor[800],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              customerName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              orderNumber,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              date,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey[300], height: 1, thickness: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      isOpen
                          ? Expanded(
                              child: InfoColumn(
                                title: 'Advance',
                                value: advance,
                                icon: Icons.payment,
                                color: Colors.blue[700]!,
                              ),
                            )
                          : const Spacer(),
                      Expanded(
                        child: InfoColumn(
                          title: 'Balance',
                          value: balance,
                          icon: Icons.account_balance_wallet,
                          color: Colors.red[700]!,
                        ),
                      ),
                      Expanded(
                        child: InfoColumn(
                          title: 'Due Date',
                          value: dueDate,
                          icon: Icons.calendar_today,
                          color: Colors.purple[700]!,
                        ),
                      ),
                    ],
                  ),
                  if (isOpen) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (closeButtonText != null && onCloseButtonPressed != null)
                          ElevatedButton(
                            onPressed: onCloseButtonPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[600],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              elevation: 2,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  closeButtonText!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(width: 8),
                        if (cancelButtonText != null && onCancelButtonPressed != null)
                          ElevatedButton(
                            onPressed: onCancelButtonPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[600],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              elevation: 2,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.cancel,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  cancelButtonText!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),   
    );
  }
}  