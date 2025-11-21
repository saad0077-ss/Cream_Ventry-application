// import 'package:cream_ventory/core/utils/expence/add_expence_logics.dart';
// import 'package:cream_ventory/widgets/text_field.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class DateRowWidget extends StatelessWidget {
//   final AddExpenseLogic logic;
//   final void Function(VoidCallback) onDateSelected; // Added callback
  
//   const DateRowWidget({
//     super.key, 
//     required this.logic,
//     required this.onDateSelected,
//   });

//   @override
//   Widget build(BuildContext context) { 
//     return Row(
//       children: [
//         Expanded(
//           child: CustomTextField(
//             controller: logic.invoiceController,
//             hintText: 'Invoice No',
//             labelText: 'Invoice No',
//             readOnly: true,
//             onChanged: (_) {},
//           ),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: GestureDetector(
//             onTap: () => logic.selectDate(context, onDateSelected),
//             child: AbsorbPointer(
//               child: TextField(
//                 decoration: InputDecoration(
//                   labelText: DateFormat('dd/MM/yyyy').format(logic.selectedDate),
//                   border: const OutlineInputBorder(),
//                 ),
//               ),
//             ), 
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:cream_ventory/core/utils/expence/add_expence_logics.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRowWidget extends StatelessWidget {
  final AddExpenseLogic logic;
  final void Function(VoidCallback) onDateSelected;
  
  const DateRowWidget({
    super.key, 
    required this.logic,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) { 
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FD),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8ECF4), width: 1.5),
            ),
            child: TextField(
              controller: logic.invoiceController,
              readOnly: true,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2D3142),
              ),
              decoration: InputDecoration(
                labelText: 'Invoice No',
                labelStyle: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Container(
                  padding: const EdgeInsets.all(12),
                  child: const Icon(
                    Icons.receipt_long,
                    color: Color(0xFF6C63FF),
                    size: 22,
                  ),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 12 ,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => logic.selectDate(context, onDateSelected),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FD),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8ECF4), width: 1.5),
              ),
              child: AbsorbPointer(
                child: TextField(
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2D3142),
                  ),
                  decoration: InputDecoration(
                    labelText: DateFormat('dd MMM yyyy').format(logic.selectedDate),
                    labelStyle: const TextStyle(
                      color: Color(0xFF2D3142),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(12),
                      child: const Icon(
                        Icons.calendar_today_rounded, 
                        color: Color(0xFF6C63FF),
                        size: 20,
                      ),
                    ),
                    suffixIcon: const Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xFF6B7280),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 4 ,
                      vertical: 14 ,
                    ),
                  ),
                ),
              ), 
            ),
          ),
        ),
      ],
    );
  }
}