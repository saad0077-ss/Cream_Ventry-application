import 'package:cream_ventory/core/utils/party/party_detail_screen_util.dart';
import 'package:cream_ventory/models/sale_model.dart';
import 'package:flutter/material.dart';

class TransactionItem {
  final String type;
  final String date;
  final double amount;
  final double? balanceDue;
  final String refNo;
  final SaleStatus? status;
  final bool isPayment;
  final bool? isIn;

  TransactionItem({
    required this.type,
    required this.date,
    required this.amount,
    this.balanceDue,
    required this.refNo,
    this.status,
    required this.isPayment,
    this.isIn,
  });
}

class TransactionCard extends StatelessWidget {
  final TransactionItem item;

  const TransactionCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final bool cancelled = item.status == SaleStatus.cancelled;
    final bool isSale = !item.isPayment;
    final bool fullyPaid = isSale ? item.balanceDue == 0 : true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 6,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: cancelled
                  ? [Colors.grey[100]!, Colors.grey[200]!]
                  : [Colors.white, const Color(0xFFFDFDFD)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: PartyDetailUtils.getTransactionTypeColor(item.type)
                      .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  PartyDetailUtils.getTransactionTypeIcon(item.type),
                  color: PartyDetailUtils.getTransactionTypeColor(item.type),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.type,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: cancelled ? Colors.grey[600] : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.refNo,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.date,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (cancelled)
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Chip(
                          label: Text(
                            'Cancelled',
                            style: TextStyle(fontSize: 10, color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹ ${item.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: cancelled
                          ? Colors.grey
                          : (item.isPayment
                              ? (item.isIn == true
                                  ? const Color(0xFF0DA95F)
                                  : const Color(0xFFE74C3C))
                              : Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (isSale && !cancelled)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: fullyPaid
                            ? const Color(0xFF0DA95F).withOpacity(0.15)
                            : const Color(0xFFE74C3C).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        fullyPaid
                            ? 'Paid'
                            : 'Due ₹ ${item.balanceDue!.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: fullyPaid
                              ? const Color(0xFF0DA95F)
                              : const Color(0xFFE74C3C),
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