import 'package:cream_ventory/screen/adding/expense/widgets/adding_expense_screen_dotted_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TransactionDetailsCard extends StatefulWidget {
  final bool isPaymentIn; // Determines if this is for Payment In or Payment Out
  final String amount; // Received or Paid amount
  final String selectedPaymentType;
  final ValueChanged<String> onAmountChanged;
  final ValueChanged<String?> onPaymentTypeChanged;

  const TransactionDetailsCard({
    super.key,
    required this.isPaymentIn,
    required this.amount,
    required this.selectedPaymentType,
    required this.onAmountChanged,
    required this.onPaymentTypeChanged,
  });

  @override
  State<TransactionDetailsCard> createState() => _TransactionDetailsCardState();
}

class _TransactionDetailsCardState extends State<TransactionDetailsCard> {
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.amount);
  }

  @override
  void didUpdateWidget(TransactionDetailsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller text if widget.amount changes
    if (oldWidget.amount != widget.amount) {
      _amountController.text = widget.amount;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.grey[200]?.withOpacity(0.95),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transaction Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.isPaymentIn ? 'Received' : 'Paid',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DottedTextField(
                    hintText: '0.00',
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}')),
                    ],   
                    onChanged: widget.onAmountChanged,   
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Payment Type',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: widget.selectedPaymentType,
                    decoration: InputDecoration(
                      labelText: 'Select Payment Type',
                      labelStyle: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.black87,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      suffixIcon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.black54,
                        size: 24,
                      ),
                    ),
                    icon: const SizedBox.shrink(),
                    items: ['Cash', 'GPay', 'PhonePe'].map((String paymentType) {
                      return DropdownMenuItem<String>(
                        value: paymentType,
                        child: Row(
                          children: [
                            Icon(
                              paymentType == 'Cash'
                                  ? Icons.money
                                  : Icons.payment,
                              color: Colors.black54,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              paymentType,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: widget.onPaymentTypeChanged,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}