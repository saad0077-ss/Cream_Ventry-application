import 'package:cream_ventory/db/models/sale/sale_model.dart';
import 'package:cream_ventory/screen/adding/expense/add_expense_screen.dart';
import 'package:cream_ventory/screen/adding/payments/payment-in/payment_in_add_screen.dart';
import 'package:cream_ventory/screen/adding/payments/payment-out/payment_out_add_screen.dart';
import 'package:cream_ventory/screen/adding/sale/sale_add_screen.dart';
import 'package:flutter/material.dart';

class TransactionBottomSheet extends StatelessWidget {

  const TransactionBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(  
                child: Center(
                  child: Text(
                    'Transactions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context); // Close the bottom sheet
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Grid of options
          GridView.count(
            crossAxisCount: 3, // 3 items per row to match the image
            shrinkWrap: true, // To fit within the bottom sheet
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            physics: const NeverScrollableScrollPhysics(), // Disable scrolling
            children: [
              _buildOptionCard(
                context,
                icon: Icons.description,
                label: 'Sale Invoice',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SaleScreen(transactionType: TransactionType.sale)),
                  );
                },

              ),
              _buildOptionCard(
                context,
                icon: Icons.arrow_upward,
                label: 'Payment-Out',
                onTap: () {
                  Navigator.pop(context);
                   Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => PaymentOutScreen()),
                  );
                },
              ), 
              _buildOptionCard(
                context,
                icon: Icons.arrow_downward,
                label: 'Payment-In',
                onTap: () {
                  Navigator.pop(context);
                   Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => PaymentInScreen()),
                  );
                },
              ),
              _buildOptionCard(
                context,
                icon: Icons.account_balance_wallet,
                label: 'Expense',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => AddExpensePage()));
      
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Helper method to build each option card
  Widget _buildOptionCard(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap,}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blue[100], // Light blue background for the icon
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.blue[800], // Darker blue for the icon
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Static method to show the bottom sheet
   void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return  TransactionBottomSheet();
      },
    );
  }
}