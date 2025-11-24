// // lib/screens/profile/widgets/financial_card.dart
// import 'package:flutter/material.dart';

// class FinancialCard extends StatelessWidget {
//   const FinancialCard({
//     super.key,
//     required this.icon,
//     required this.title,
//     required this.amount,
//     required this.color,
//     required this.fontSize,
//     required this.isSmallScreen,
//   });

//   final IconData icon;
//   final String title;
//   final double amount;
//   final Color color;
//   final double fontSize;
//   final bool isSmallScreen;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 5))],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
//             child: Icon(icon, color: color, size: isSmallScreen ? 24 : 28),
//           ),
//           const SizedBox(height: 12),
//           Text(title, style: TextStyle(fontSize: fontSize - 2, color: Colors.grey.shade600, fontWeight: FontWeight.w600, fontFamily: 'ABeeZee')),
//           const SizedBox(height: 6),
//           Text('₹${amount.toStringAsFixed(2)}', style: TextStyle(fontSize: fontSize + 6, color: color, fontWeight: FontWeight.bold, fontFamily: 'ABeeZee')),
//         ],
//       ),
//     );
//   }
// }