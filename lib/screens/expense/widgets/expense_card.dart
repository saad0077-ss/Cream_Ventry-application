import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cream_ventory/models/expence_model.dart';

class ExpenseCard extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback? onTap;

  const ExpenseCard({
    super.key,
    required this.expense,
    this.onTap,
  });

  // Category icon & color mapping
  Map<String, dynamic> _getCategoryStyle(String category) {
    final styles = {
      'Food': {'icon': Icons.restaurant_rounded, 'color': const Color(0xFFFF6B6B), 'bg': const Color(0xFFFFE8E8)},
      'Transport': {'icon': Icons.directions_car_rounded, 'color': const Color(0xFF4ECDC4), 'bg': const Color(0xFFE8FAF8)},
      'Shopping': {'icon': Icons.shopping_bag_rounded, 'color': const Color(0xFFA66CFF), 'bg': const Color(0xFFF3EEFF)},
      'Bills': {'icon': Icons.receipt_long_rounded, 'color': const Color(0xFFFFB347), 'bg': const Color(0xFFFFF4E5)},
      'Entertainment': {'icon': Icons.movie_rounded, 'color': const Color(0xFF6C9BCF), 'bg': const Color(0xFFE8F1FA)},
      'Health': {'icon': Icons.favorite_rounded, 'color': const Color(0xFFFF8BA7), 'bg': const Color(0xFFFFEDF1)},
      'Education': {'icon': Icons.school_rounded, 'color': const Color(0xFF5B8FB9), 'bg': const Color(0xFFE8F0F6)},
      'Salary': {'icon': Icons.account_balance_wallet_rounded, 'color': const Color(0xFF27AE60), 'bg': const Color(0xFFE8F8EE)},
    };
    return styles[category] ?? {
      'icon': Icons.receipt_outlined,
      'color': const Color(0xFF64748B),
      'bg': const Color(0xFFF1F5F9),
    };
  }

  @override
  Widget build(BuildContext context) {
    final style = _getCategoryStyle(expense.category);
    final Color iconColor = style['color'];
    final Color bgColor = style['bg'];
    final IconData icon = style['icon'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          splashColor: iconColor.withOpacity(0.1),
          highlightColor: iconColor.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Animated Icon Container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: iconColor.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 26,
                  ),
                ),

                const SizedBox(width: 16),

                // Title, Description & Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.category,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(expense.date),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Amount with styled container
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFDC2626),
                        const Color(0xFFEF4444),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFDC2626).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    '₹${_formatAmount(expense.totalAmount)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return ''; 
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatAmount(double amount) { 
    if (amount >= 1000) {
      return NumberFormat('#,##0', 'en_IN').format(amount.toInt());
    }
    return amount.toStringAsFixed(0);
  }
}