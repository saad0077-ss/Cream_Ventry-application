// // lib/screens/profile/widgets/financial_summary_section.dart
// import 'package:cream_ventory/screens/profile/widgets/user_profile_screen_body/user_profile_screen_body_financial_card.dart';
// import 'package:flutter/material.dart';
// import 'package:cream_ventory/core/utils/profile/profile_display_logics.dart';
// import 'package:material_symbols_icons/symbols.dart';


// class FinancialSummarySection extends StatelessWidget {
//   const FinancialSummarySection({
//     super.key,
//     required this.logic,
//     required this.constraints,
//   });

//   final ProfileDisplayLogic logic;
//   final BoxConstraints constraints;

//   @override
//   Widget build(BuildContext context) {
//     final isSmallScreen = constraints.maxWidth < 600;
//     final fontSize = isSmallScreen ? 14.0 : 16.0;

//     return Column(
//       children: [
//         // Income & Expense Row
//         ValueListenableBuilder<double>(
//           valueListenable: logic.totalIncomeNotifier,
//           builder: (_, income, __) => ValueListenableBuilder<double>(
//             valueListenable: logic.totalExpenseNotifier,
//             builder: (_, expense, __) => Row(
//               children: [
//                 Expanded(child: FinancialCard(icon: Symbols.trending_up_rounded, title: 'Total Income', amount: income, color: const Color(0xFF10b981), fontSize: fontSize, isSmallScreen: isSmallScreen)),
//                 const SizedBox(width: 12),
//                 Expanded(child: FinancialCard(icon: Symbols.trending_down_rounded, title: 'Total Expense', amount: expense, color: const Color(0xFFef4444), fontSize: fontSize, isSmallScreen: isSmallScreen)),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),

//         // You Will Get & Give Row
//         ValueListenableBuilder<double>(
//           valueListenable: logic.totalYouWillGetNotifier,
//           builder: (_, get, __) => ValueListenableBuilder<double>(
//             valueListenable: logic.totalYouWillGiveNotifier,
//             builder: (_, give, __) => Row(
//               children: [
//                 Expanded(child: FinancialCard(icon: Symbols.account_balance_wallet_rounded, title: 'You Will Get', amount: get, color: const Color(0xFF10b981), fontSize: fontSize, isSmallScreen: isSmallScreen)),
//                 const SizedBox(width: 12),
//                 Expanded(child: FinancialCard(icon: Symbols.payments_rounded, title: 'You Will Give', amount: give, color: const Color(0xFFef4444), fontSize: fontSize, isSmallScreen: isSmallScreen)),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }