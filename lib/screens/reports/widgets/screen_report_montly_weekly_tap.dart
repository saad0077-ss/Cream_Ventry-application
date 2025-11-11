import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Assuming these are defined in your constants file
const Color logoColor = Colors.blueGrey;
const Color mainColor = Colors.white;

class PeriodFilter extends StatelessWidget {
  final String selectedPeriod;
  final Function(String) onPeriodChanged;

  const PeriodFilter({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35.h,
      width: 150.w,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(50)),
        border: Border.all(color: Colors.blueGrey, width: 2),
      ),
      child: Row(
        children: [
          _buildFilterButton(context, 'Monthly'),
          _buildFilterButton(context, 'Weekly'),
        ],
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context, String period) {
    bool isSelected = selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          onPeriodChanged(period);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: 40.h,
          decoration: BoxDecoration(
            color: isSelected ?logoColor : mainColor, // Green for period filter
            borderRadius: period == 'Monthly'
                ? const BorderRadius.only(
                    topLeft: Radius.circular(50),
                    bottomLeft: Radius.circular(50),
                  ) 
                : const BorderRadius.only(
                    topRight: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
          ),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: isSelected ? mainColor : logoColor,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              child: Text(period),
            ),
          ),
        ),
      ),
    );
  }
}