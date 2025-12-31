import 'package:cream_ventory/core/utils/expence/date_amount_format.dart';
import 'package:cream_ventory/database/functions/party_db.dart';
import 'package:cream_ventory/models/party_model.dart';
import 'package:cream_ventory/models/payment_out_model.dart';
import 'package:flutter/material.dart';

class PaymentOutCard extends StatelessWidget {
  final PaymentOutModel payment;
  final VoidCallback onTap;

  const PaymentOutCard({
    super.key,
    required this.payment,
    required this.onTap,
  });

  Color _getPaymentTypeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'cash':
        return const Color(0xFFEF4444);
      case 'upi':
        return const Color(0xFFEC4899);
      case 'card':
        return const Color(0xFFF97316);
      case 'bank transfer':
      case 'bank':
        return const Color(0xFFDC2626);
      case 'cheque':
        return const Color(0xFFE11D48);
      default:
        return const Color(0xFF991B1B);
    }
  }

  IconData _getPaymentTypeIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'cash':
        return Icons.account_balance_wallet_rounded;
      case 'upi':
        return Icons.qr_code_2_rounded;
      case 'card':
        return Icons.credit_card_rounded;
      case 'bank transfer':
      case 'bank':
        return Icons.account_balance_rounded;
      case 'cheque':
        return Icons.receipt_long_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentTypeColor = _getPaymentTypeColor(payment.paymentType);
    final paymentTypeIcon = _getPaymentTypeIcon(payment.paymentType);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(20),
        shadowColor: paymentTypeColor.withOpacity(0.3),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  paymentTypeColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: paymentTypeColor.withOpacity(0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: paymentTypeColor.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Decorative circle
                Positioned(
                  right: -30,
                  top: -30,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: paymentTypeColor.withOpacity(0.08),
                    ),
                  ),
                ),
                // Outgoing payment indicator
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: paymentTypeColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: paymentTypeColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_upward_rounded,
                          size: 12,
                          color: paymentTypeColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'OUT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: paymentTypeColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with icon badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  paymentTypeColor.withOpacity(0.25),
                                  paymentTypeColor.withOpacity(0.15),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: paymentTypeColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              paymentTypeIcon,
                              size: 20,
                              color: paymentTypeColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ✅ FIX: Display current party name
                                ValueListenableBuilder<List<PartyModel>>(
                                  valueListenable: PartyDb.partyNotifier,
                                  builder: (context, parties, child) {
                                    String partyName = payment.partyName;
                                    
                                    // Find current party by ID to get updated name
                                    if (payment.partyId != null && payment.partyId!.isNotEmpty) {
                                      try {
                                        final party = parties.firstWhere(
                                          (p) => p.id == payment.partyId,
                                        );
                                        partyName = party.name;  // ← Current name
                                      } catch (e) {
                                        // Party not found, use cached name
                                      }
                                    }
                                    
                                    return Text(
                                      partyName,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1F2937),
                                        letterSpacing: -0.3,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    );
                                  },
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  payment.paymentType,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: paymentTypeColor,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 40), // Space for OUT badge
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Amount with gradient text effect
                      Row(
                        children: [
                          Icon(
                            Icons.remove_circle_outline_rounded,
                            size: 20,
                            color: paymentTypeColor.withOpacity(0.7),
                          ),
                          const SizedBox(width: 6),
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                paymentTypeColor,
                                paymentTypeColor.withOpacity(0.7),
                              ],
                            ).createShader(bounds),
                            child: Text(
                              FormatUtils.formatAmount(payment.paidAmount),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Footer with glass effect
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.calendar_today_rounded,
                                    size: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  FormatUtils.formatDate(payment.date),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    paymentTypeColor.withOpacity(0.2),
                                    paymentTypeColor.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: paymentTypeColor.withOpacity(0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                '#${payment.receiptNo}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: paymentTypeColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
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
}