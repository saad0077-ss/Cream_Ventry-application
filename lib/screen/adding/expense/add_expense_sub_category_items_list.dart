import 'package:cream_ventory/screen/adding/expense/adding_expense_screen_dotted_fields.dart';
import 'package:cream_ventory/utils/adding/expence/add_expence_logics.dart';
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
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.logic.billedItems.length,
      itemBuilder: (context, index) {
        var item = widget.logic.billedItems[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            key: ValueKey(item['id']),
            children: [
              Expanded(child: _buildItemField(item, 'name', 'Name')),
              const SizedBox(width: 5),
              Expanded(
                child: _buildItemField(item, 'qty', 'Qty', isNumber: true),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _buildItemField(item, 'rate', 'Rate', isDecimal: true),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Center(
                  child: Text(
                    '₹${((item['qty'] as int) * (item['rate'] as double)).toStringAsFixed(2)}',
                  ),
                ),
              ),
              IconButton(
                key: ValueKey('${item['id']}_remove'),
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () =>
                    widget.logic.removeItem(index, widget.onChanged, context),
              ),
            ],
          ),
        );
      },
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
                : null),
      inputFormatters: isNumber
          ? [FilteringTextInputFormatter.digitsOnly]
          : (isDecimal
                ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))]
                : null),
      onChanged: (value) {
        // Update the item value
        if (isNumber) {
          item[key] = int.tryParse(value) ?? 0;
        } else if (isDecimal) {
          item[key] = double.tryParse(value) ?? 0.0;
        } else {
          item[key] = value;
        }

        // Trigger rebuild and recalculation
        if (key == 'qty' || key == 'rate') {
          widget.logic.calculateTotal();
        }

        // Call setState to rebuild the UI immediately
        widget.onChanged(() {
          // Force rebuild of parent widget
          setState(() {});
        });
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        hintText: hint, // Optional: can rely on widget's hintText
        hintStyle: const TextStyle(color: Colors.black54, fontSize: 16),
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
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: () => logic.addNewItem(onPressed),
        child: const Text('+ Add Item'),
      ),
    );
  }
}
