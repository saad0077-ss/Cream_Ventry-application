import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Assuming these are defined in your constants file
const Color logoColor = Colors.blueGrey;
const Color mainColor = Colors.white;

class PaymentTypeFilter extends StatelessWidget {
  final String selectedPaymentType;
  final Function(String) onPaymentTypeChanged;

  const PaymentTypeFilter({
    super.key,
    required this.selectedPaymentType,
    required this.onPaymentTypeChanged,
  });

  @override 
  Widget build(BuildContext context) {
        final bool isSmallScreen = MediaQuery.of(context).size.width < 375;

    return Container( 
      height: 35.h, 
      width: isSmallScreen? 150.w: 170.w,
      decoration: BoxDecoration(
        borderRadius:  BorderRadius.all(Radius.circular(50.r)),
        border: Border.all(color: Colors.blueGrey, width: 2),
      ),
      child: Row(
        children: [
          _buildFilterButton(context, 'Payment In'),    
          _buildFilterButton(context, 'Payment Out'),
        ],
      ),
    );
  }   

  Widget _buildFilterButton(BuildContext context, String paymentType) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 375;   
    bool isSelected = selectedPaymentType == paymentType;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          onPaymentTypeChanged(paymentType);
        }, 
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),                   
          curve: Curves.easeInOut,
          height: 40.h,
          decoration: BoxDecoration(
            color: isSelected ? logoColor : mainColor,
            borderRadius: paymentType == 'Payment In'   
                ?  BorderRadius.only(
                    topLeft: Radius.circular(50.r),
                    bottomLeft: Radius.circular(50.r),
                  )
                :  BorderRadius.only(
                    topRight: Radius.circular(50.r),
                    bottomRight: Radius.circular(50.r),
                  ),
          ),          
          child: Center(
            child: AnimatedDefaultTextStyle(   
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              style: TextStyle( 
                color: isSelected ? mainColor : logoColor,
                fontSize: isSmallScreen ?10 : 13.r,
                fontWeight: FontWeight.bold,
              ),
              child: Text(paymentType),
            ),
          ),
        ),
      ),
    );
  }
}