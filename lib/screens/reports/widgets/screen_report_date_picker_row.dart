import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class DatePickerRow extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onSelectStart;
  final VoidCallback onSelectEnd;

  const DatePickerRow({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onSelectStart,
    required this.onSelectEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildPicker('From', startDate, onSelectStart),
        _buildPicker('To', endDate, onSelectEnd),
      ],
    );
  }

  Widget _buildPicker(String label, DateTime? date, VoidCallback onTap) {
    final fmt = DateFormat('dd MMM yyyy');
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 17)),
        SizedBox(width: 10.w),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 30.h,
            width: 113.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(color: const Color(0xFF9E9E9E)),
              color: Colors.blueGrey,
            ),
            alignment: Alignment.center, 
            child: date == null
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.date_range, size: 19),
                      SizedBox(width: 4),
                      Text(
                        'Select date',
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                    ],
                  )
                : Text(fmt.format(date), style: const TextStyle(fontSize: 15,color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
