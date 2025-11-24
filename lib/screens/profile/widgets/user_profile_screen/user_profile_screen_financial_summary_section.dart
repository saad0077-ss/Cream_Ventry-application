// lib/screens/profile/widgets/financial_summary_section.dart
import 'package:cream_ventory/core/utils/profile/profile_display_logics.dart';
import 'package:cream_ventory/screens/profile/widgets/user_profile_screen/user_profile_screen_section_card.dart';
import 'package:cream_ventory/screens/profile/widgets/user_profile_screen/user_profile_screen_stat_card.dart';
import 'package:flutter/material.dart';

class FinancialSummarySection extends StatelessWidget {
  final ProfileDisplayLogic logic;

  const FinancialSummarySection({super.key, required this.logic});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      icon: Icons.account_balance_wallet_rounded,
      iconColor: const Color(0xFF10B981),
      title: 'Financial Summary',
      child: Column(
        children: [
          ValueListenableBuilder<double>(
            valueListenable: logic.totalIncomeNotifier,
            builder: (_, income, __) => ValueListenableBuilder<double>(
              valueListenable: logic.totalExpenseNotifier,
              builder: (_, expense, __) => Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.trending_up_rounded,
                      value: '₹${income.toStringAsFixed(2)}',
                      label: 'Total Income',
                      color: const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: Icons.trending_down_rounded,
                      value: '₹${expense.toStringAsFixed(2)}',
                      label: 'Total Expense',
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<double>(
            valueListenable: logic.totalYouWillGetNotifier,
            builder: (_, get, __) => ValueListenableBuilder<double>(
              valueListenable: logic.totalYouWillGiveNotifier,
              builder: (_, give, __) => Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.account_balance_wallet_rounded,
                      value: '₹${get.toStringAsFixed(2)}',
                      label: 'You Will Get',
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: Icons.payments_rounded,
                      value: '₹${give.toStringAsFixed(2)}',
                      label: 'You Will Give',
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}