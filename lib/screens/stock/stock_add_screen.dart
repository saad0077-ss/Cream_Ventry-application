import 'package:cream_ventory/database/functions/product_db.dart';
import 'package:cream_ventory/models/product_model.dart';
import 'package:cream_ventory/models/sale_model.dart';
import 'package:cream_ventory/core/theme/theme.dart';
import 'package:cream_ventory/widgets/app_bar.dart';
import 'package:cream_ventory/widgets/custom_button.dart';
import 'package:cream_ventory/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddStock extends StatefulWidget {
  final ProductModel product;
  final ({int quantity, double price, String date, bool isAdd})? editData;

  const AddStock({super.key, required this.product, this.editData});

  @override
  State<AddStock> createState() => _AddStockState();
}

class _AddStockState extends State<AddStock> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  bool isAddStockSelected = true;
  DateTime selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    if (widget.editData != null) {
      final data = widget.editData!;
      quantityController.text = data.quantity.toString();
      priceController.text = data.price.toStringAsFixed(2);
      isAddStockSelected = data.isAdd;

      try {
        selectedDate = DateFormat('dd MMM yyyy').parse(data.date);
      } catch (e) {
        selectedDate = DateTime.now();
      }
    } else {
      selectedDate = DateTime.now();
      // Pre-fill with product's purchase price for restocking
      priceController.text = widget.product.purchasePrice.toStringAsFixed(2);
    }

    dateController.text = DateFormat('dd MMM yyyy').format(selectedDate);
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  } 

  Future<void> _saveAdjustment() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      // Validation
      final qtyText = quantityController.text.trim();
      final priceText = priceController.text.trim();

      if (qtyText.isEmpty || priceText.isEmpty) {
        _showSnackBar('Please fill all required fields');
        return;
      }

      final int quantity = int.tryParse(qtyText) ?? 0;
      final double price = double.tryParse(priceText) ?? 0.0;

      if (quantity <= 0 || price < 0) {
        _showSnackBar('Quantity must be positive and price cannot be negative');
        return;
      }

      if (quantity > 1000000 || price > 1000000) {
        _showSnackBar('Value too large');
        return;
      }

      // Get current product state to verify
      final currentProduct = await ProductDB.getProduct(widget.product.id);
      if (currentProduct == null) {
        _showSnackBar('Product not found');
        return;
      }

      // Apply stock change using ProductDB methods with transaction tracking
      if (isAddStockSelected) {
        // Add stock (Restock)
        final notes = notesController.text.trim().isEmpty 
            ? 'Stock added on ${DateFormat('dd MMM yyyy').format(selectedDate)}'
            : notesController.text.trim();

        await ProductDB.restockProduct(
          widget.product.id,
          quantity,
          purchasePrice: price,
          notes: notes,
        );

        _showSnackBar(
          'Stock added successfully! New stock: ${currentProduct.stock + quantity}',
          backgroundColor: Colors.green,
        );
      } else {
        // Reduce stock
        if (currentProduct.stock < quantity) {
          _showSnackBar(
            'Insufficient stock! Available: ${currentProduct.stock}, Requested: $quantity',
          );
          return;
        }

        // Show confirmation dialog for stock reduction
        final confirm = await _showConfirmationDialog(
          'Reduce Stock',
          'Are you sure you want to reduce $quantity units from stock?\n\n'
              'Current Stock: ${currentProduct.stock}\n'
              'After Reduction: ${currentProduct.stock - quantity}',
        );

        if (!confirm) {
          return;
        }

        // Use stock adjustment type for manual reductions
        // Note: This creates a Sale transaction. If you want a different type,
        // you may need to add an "adjustment" method to ProductDB
        await ProductDB.reduceStockForSale(
          widget.product.id,
          quantity,
          TransactionType.sale,
          saleId: null, // No sale reference for manual adjustments
        );

        _showSnackBar(
          'Stock reduced successfully! New stock: ${currentProduct.stock - quantity}',
          backgroundColor: Colors.orange,
        );
      }

      if (mounted) {
        // Small delay to show the snackbar before closing
        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      debugPrint('Error adjusting stock: $e');
      _showSnackBar('Error: ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<bool> _showConfirmationDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSnackBar(String message, {Color? backgroundColor}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.editData != null ? 'Edit Adjustment' : 'Adjust Stock',
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.appGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              // Product Info Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Current Stock:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${widget.product.stock} units',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Purchase Price:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '₹ ${widget.product.purchasePrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Add / Reduce Radio
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio<bool>(
                        value: true,
                        groupValue: isAddStockSelected,
                        onChanged: (_) => setState(() {
                          isAddStockSelected = true;
                          // Reset price to purchase price when switching to add
                          if (quantityController.text.isEmpty) {
                            priceController.text = widget.product.purchasePrice
                                .toStringAsFixed(2);
                          }
                        }),
                        activeColor: Colors.green,
                      ),
                      const Text(
                        'Add Stock',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 30),
                      Radio<bool>(
                        value: false,
                        groupValue: isAddStockSelected,
                        onChanged: (_) => setState(() {
                          isAddStockSelected = false;
                          // Reset price to sale price when switching to reduce
                          if (quantityController.text.isEmpty) {
                            priceController.text = widget.product.salePrice
                                .toStringAsFixed(2);
                          }
                        }),
                        activeColor: Colors.orange,
                      ),
                      const Text(
                        'Reduce Stock',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Date Field
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: CustomTextField(
                    labelText: 'Transaction Date',
                    controller: dateController,
                    suffixIcon: const Icon(
                      Icons.calendar_today,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Quantity
              CustomTextField(
                labelText: 'Quantity *',
                controller: quantityController,
                keyboardType: TextInputType.number,
                suffixIcon: const Icon(Icons.inventory_2, color: Colors.blue),
              ),
              const SizedBox(height: 20),  

              // Price per unit
              CustomTextField(
                labelText: isAddStockSelected
                    ? 'Purchase Price per unit *'
                    : 'Reference Price per unit *',
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                suffixIcon: const Icon(
                  Icons.currency_rupee,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),

              // Notes (optional, only for adding stock)
              if (isAddStockSelected)
                CustomTextField(
                  labelText: 'Notes (Optional)',
                  controller: notesController,
                  maxLines: 3,
                  suffixIcon: const Icon(Icons.note, color: Colors.blue),
                ),

              const SizedBox(height: 12),

              // Info text
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isAddStockSelected
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isAddStockSelected
                        ? Colors.green.withOpacity(0.3)
                        : Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: isAddStockSelected ? Colors.green : Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isAddStockSelected
                            ? 'This will add stock and create a restock transaction record.'
                            : 'This will reduce stock and create a stock reduction record. Cannot be undone.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isAddStockSelected
                              ? Colors.green[800]
                              : Colors.orange[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Save Button
              Center(
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : CustomActionButton(
                        label: widget.editData != null
                            ? 'Update'
                            : isAddStockSelected
                            ? 'Add Stock'
                            : 'Reduce Stock',
                        backgroundColor: isAddStockSelected
                            ? Colors.green
                            : Colors.orange,
                        onPressed: _saveAdjustment,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 18 ,
                        ),
                      ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    dateController.dispose();
    quantityController.dispose();
    priceController.dispose();
    notesController.dispose();
    super.dispose();
  }
}
