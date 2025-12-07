import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'qr_code_dialog.dart';

class TransactionDetailsCard extends StatefulWidget {
  final bool isPaymentIn;
  final String amount;
  final String selectedPaymentType;
  final ValueChanged<String> onAmountChanged;
  final ValueChanged<String?> onPaymentTypeChanged;
  final String upiId;
  final String businessName;

  const TransactionDetailsCard({
    super.key,
    required this.isPaymentIn,
    required this.amount,
    required this.selectedPaymentType,
    required this.onAmountChanged,
    required this.onPaymentTypeChanged,
    this.upiId = 'creamventory@sbi',
    this.businessName = 'CreamVentory', 
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
    if (oldWidget.amount != widget.amount && 
      _amountController.text != widget.amount &&
      !_amountController.selection.isValid) {
    _amountController.text = widget.amount;
  }
  }

  @override
  void dispose() {   
    _amountController.dispose();
    super.dispose();
  }

  // Payment type configuration
  final Map<String, Map<String, dynamic>> _paymentTypes = {
    'Cash': {
      'icon': Icons.payments_outlined,
      'color': Colors.green,
    },
    'GPay': {
      'icon': Icons.account_balance_wallet_outlined,
      'color': Colors.blue,
    },
    'PhonePe': {
      'icon': Icons.phone_android_outlined,
      'color': Colors.purple,
    },
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.receipt_long_outlined,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Transaction Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Amount Field
            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    widget.isPaymentIn ? 'Received' : 'Paid',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      onChanged: widget.onAmountChanged,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Icon(
                          Icons.currency_rupee,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Payment Type Dropdown
            Row(
              children: [
                const SizedBox(
                  width: 100,
                  child: Text(
                    'Payment',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      value: widget.selectedPaymentType,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                      ),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey.shade600,
                        size: 24,
                      ),
                      dropdownColor: Colors.white,
                      elevation: 8,
                      borderRadius: BorderRadius.circular(12),
                      isExpanded: true,
                      items: _paymentTypes.keys.map((String paymentType) {
                        final config = _paymentTypes[paymentType]!;
                        return DropdownMenuItem<String>(
                          value: paymentType,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: (config['color'] as Color).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  config['icon'] as IconData,
                                  color: config['color'] as Color,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                paymentType,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        widget.onPaymentTypeChanged(value);
                        if (value == 'GPay' || value == 'PhonePe') {
                          QRCodeDialog.show(
                            context: context,
                            paymentType: value!,
                            amount: widget.amount,
                            upiId: widget.upiId,
                            businessName: widget.businessName,
                          );
                        }
                      },
                      selectedItemBuilder: (BuildContext context) {
                        return _paymentTypes.keys.map((String paymentType) {
                          final config = _paymentTypes[paymentType]!;
                          return Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: (config['color'] as Color).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  config['icon'] as IconData,
                                  color: config['color'] as Color,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                paymentType,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          );
                        }).toList();
                      }, 
                    ),
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