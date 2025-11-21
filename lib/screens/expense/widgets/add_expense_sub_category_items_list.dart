import 'package:cream_ventory/screens/expense/widgets/adding_expense_screen_dotted_fields.dart';
import 'package:cream_ventory/core/utils/expence/add_expence_logics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ItemsListWidget extends StatefulWidget {
  final AddExpenseLogic logic;
  final Function(VoidCallback) onChanged;

  const ItemsListWidget({
    super.key,
    required this.logic,
    required this.onChanged,
  });

  @override
  State<ItemsListWidget> createState() => _ItemsListWidgetState();
}

class _ItemsListWidgetState extends State<ItemsListWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.logic.billedItems.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.logic.billedItems.length,
                itemBuilder: (context, index) {
                  var item = widget.logic.billedItems[index];
                  return _buildItemCard(item, index);
                },
              ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No items added yet',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap "Add New Item" to get started',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item, int index) {
    final amount = ((item['qty'] as int) * (item['rate'] as double));

    return Container(
      key: ValueKey(item['id']),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item number header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Item ${index + 1}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
              _buildDeleteButton(item, index),
            ],
          ),
          const SizedBox(height: 16),

          // Item Name field with label
          _buildLabeledField(
            label: 'Item Name',
            child: _buildItemField(item, 'name', 'Enter item name'),
          ),
          const SizedBox(height: 14),

          // Qty and Rate in a row
          Row(
            children: [
              Expanded(
                child: _buildLabeledField(
                  label: 'Quantity',
                  child: _buildItemField(item, 'qty', '0', isNumber: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLabeledField(
                  label: 'Rate (₹)',
                  child: _buildItemField(item, 'rate', '0.00', isDecimal: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Amount display with label
          _buildLabeledField(
            label: 'Total Amount',
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade50, Colors.green.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Center(
                child: Text(
                  '₹${amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Label above each field
  Widget _buildLabeledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _buildDeleteButton(Map<String, dynamic> item, int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey('${item['id']}_remove'),
        onTap: () => widget.logic.removeItem(index, widget.onChanged, context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline_rounded, color: Colors.red.shade500, size: 18),
              const SizedBox(width: 4),
              Text(
                'Remove',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.red.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemField(
    Map<String, dynamic> item,
    String key,
    String hint, {
    bool isNumber = false,
    bool isDecimal = false,
  }) {
    return DottedTextField(
      key: ValueKey('${item['id']}_$key'),
      hintText: hint,
      controller: item['${key}Controller'] as TextEditingController,
      keyboardType: isNumber
          ? TextInputType.number
          : (isDecimal
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text),
      inputFormatters: isNumber
          ? [FilteringTextInputFormatter.digitsOnly]
          : (isDecimal
              ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))]
              : null),
      onChanged: (value) {
        if (isNumber) {
          item[key] = int.tryParse(value) ?? 0;
        } else if (isDecimal) {
          item[key] = double.tryParse(value) ?? 0.0;
        } else {
          item[key] = value;
        }

        if (key == 'qty' || key == 'rate') {
          widget.logic.calculateTotal();
        }

        widget.onChanged(() => setState(() {}));
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class AddItemButtonWidget extends StatelessWidget {
  final AddExpenseLogic logic;
  final Function(VoidCallback) onPressed;

  const AddItemButtonWidget({
    super.key,
    required this.logic,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => logic.addNewItem(onPressed),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade500, Colors.blue.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Add New Item',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 