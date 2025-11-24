// // lib/screens/profile/widgets/info_row.dart
// import 'package:flutter/material.dart';

// class InfoRow extends StatelessWidget {
//   const InfoRow({
//     super.key,
//     required this.icon,
//     required this.label,
//     required this.text,
//     required this.color,
//     required this.isEmpty,
//     required this.fontSize,
//     this.isMultiline = false,
//   });

//   final IconData icon;
//   final String label;
//   final String text;
//   final Color color;
//   final bool isEmpty;
//   final double fontSize;
//   final bool isMultiline;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: isEmpty ? Colors.grey.shade50 : color.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: isEmpty ? Colors.grey.shade300 : color.withOpacity(0.3)),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(color: isEmpty ? Colors.grey.shade200 : color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
//             child: Icon(icon, color: isEmpty ? Colors.grey.shade500 : color, size: 20),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(label, style: TextStyle(fontSize: fontSize - 2, fontWeight: FontWeight.w600, color: Colors.grey.shade600, fontFamily: 'ABeeZee')),
//                 const SizedBox(height: 6),
//                 Text(
//                   text,
//                   style: TextStyle(
//                     fontSize: fontSize,
//                     color: isEmpty ? Colors.grey.shade500 : Colors.black87,
//                     fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
//                     height: 1.4,
//                     fontFamily: 'ABeeZee',
//                   ),
//                   maxLines: isMultiline ? 4 : 1,
//                   overflow: isMultiline ? TextOverflow.fade : TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ), 
//     );
//   }
// }