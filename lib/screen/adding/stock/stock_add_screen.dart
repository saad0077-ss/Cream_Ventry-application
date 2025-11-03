import 'package:cream_ventory/db/functions/product_db.dart';
import 'package:cream_ventory/db/functions/stock_db.dart';
import 'package:cream_ventory/db/functions/user_db.dart';
import 'package:cream_ventory/db/models/items/products/product_model.dart';
import 'package:cream_ventory/db/models/items/products/stock_model.dart';
import 'package:cream_ventory/themes/app_theme/theme.dart';
import 'package:cream_ventory/widgets/app_bar.dart';
import 'package:cream_ventory/widgets/custom_button.dart';
import 'package:cream_ventory/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AddStock extends StatefulWidget {
  final ProductModel product;
  final StockModel? editTransaction;

  const AddStock({super.key, required this.product, this.editTransaction});

  @override
  _AddStockState createState() => _AddStockState();
}

class _AddStockState extends State<AddStock> {
  final TextEditingController adjustmentDateController =
      TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  bool isAddStockSelected = true;
  DateTime? selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.editTransaction != null) {
      final transaction = widget.editTransaction!;
      quantityController.text = transaction.quantity.toString();
      priceController.text = (transaction.total / transaction.quantity)
          .toStringAsFixed(2);
      adjustmentDateController.text = transaction.date;
      try {
        selectedDate = DateFormat('dd/MM/yyyy').parse(transaction.date);
      } catch (e) {
        debugPrint('Error parsing date: ${transaction.date}, $e');
        selectedDate = DateTime.now();
        adjustmentDateController.text = DateFormat(
          'dd/MM/yyyy',
        ).format(selectedDate!);
      }
      isAddStockSelected = transaction.type == 'Stock Added';
    } else {
      selectedDate = DateTime.now();
      adjustmentDateController.text = DateFormat(
        'dd/MM/yyyy',
      ).format(selectedDate!);
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        adjustmentDateController.text = DateFormat(
          'dd/MM/yyyy',
        ).format(pickedDate);
      });
    }
  }

  void saveTransactionAndUpdateStock() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      // Validate inputs
      if (selectedDate == null ||
          quantityController.text.isEmpty ||
          priceController.text.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
        return;
      }

      final quantity = int.tryParse(quantityController.text) ?? 0.0;
      final price = double.tryParse(priceController.text) ?? 0.0;

      if (quantity <= 0 || price <= 0) { 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quantity and price must be positive')),
        );
        return;
      }

      // Additional validation for large inputs
      if (quantity > 1000000 || price > 1000000) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quantity or price is too large')),
        );
        return;
      }

      double previousStock = widget.product.stock.toDouble();
      double updatedStock;

      if (widget.editTransaction != null) {
        // Editing: Restore old stock first
        final oldQty = widget.editTransaction!.quantity;
        updatedStock = widget.editTransaction!.type == 'Stock Added'
            ? previousStock - oldQty
            : previousStock + oldQty;
        debugPrint(
          'Editing: Restored stock for ${widget.product.name} from $previousStock to $updatedStock (Old Qty: $oldQty, Type: ${widget.editTransaction!.type})',
        );

        // Apply new adjustment
        updatedStock = isAddStockSelected
            ? updatedStock + quantity
            : updatedStock - quantity;
      } else {
        // Adding new
        updatedStock = isAddStockSelected
            ? previousStock + quantity
            : previousStock - quantity;
      }

      if (updatedStock < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot reduce stock below zero')),
        );
        return;
      }

      final user = await UserDB.getCurrentUser();
      final userId = user.id;

      final stock = StockModel(
        id: widget.editTransaction?.id ?? const Uuid().v4(),
        productId: widget.product.id,
        type: isAddStockSelected ? 'Stock Added' : 'Stock Removed',
        date: DateFormat('dd/MM/yyyy').format(selectedDate!),
        quantity: quantity as int,
        total: quantity * price,
        userId: userId
      );

      final updatedProduct = ProductModel(
        name: widget.product.name,
        stock: updatedStock.toInt(),
        salePrice: widget.product.salePrice,
        purchasePrice: widget.product.purchasePrice,  
        category: widget.product.category,
        imagePath: widget.product.imagePath,
        id: widget.product.id,
        isAsset: widget.product.isAsset,
        creationDate: widget.product.creationDate,
        userId: userId
      );

      // Perform updates atomically
      if (widget.editTransaction != null) {
        debugPrint(
          'Updating stock transaction: ID=${stock.id}, Product=${widget.product.name}, Type=${stock.type}, Quantity=$quantity',
        );
        await StockDB.updateStock(stock.id, stock);
      } else {  
        debugPrint(
          'Adding stock transaction: ID=${stock.id}, Product=${widget.product.name}, Type=${stock.type}, Quantity=$quantity',
        );
        await StockDB.addStock(stock);
      }

      debugPrint(
        'Updating product: ${widget.product.name}, Old Stock=$previousStock, New Stock=$updatedStock',
      );
      await ProductDB.updateProduct(widget.product.id, updatedProduct);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.editTransaction != null
                ? 'Transaction updated successfully'
                : '${isAddStockSelected ? 'Added' : 'Reduced'} stock successfully',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      debugPrint('Error saving stock transaction: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving transaction: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.editTransaction != null ? 'Edit Stock' : 'Adjust Stock',
      ),
      body: Container(
        height: screenHeight,
        width: screenWidth,
        decoration: const BoxDecoration(gradient: AppTheme.appGradient),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio<bool>(
                    value: true,
                    groupValue: isAddStockSelected,
                    onChanged: (value) {
                      setState(() {
                        isAddStockSelected = value!;
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                  const Text('Add Stock'),
                  const SizedBox(width: 20),
                  Radio<bool>(
                    value: false,
                    groupValue: isAddStockSelected,
                    onChanged: (value) {
                      setState(() {
                        isAddStockSelected = value!;
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                  const Text('Reduce Stock'),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => pickDate(context),
                child: AbsorbPointer(
                  child: CustomTextField(
                    labelText: 'Adjustment Date',
                    controller: adjustmentDateController,
                    suffixIcon: const Icon(
                      Icons.calendar_today,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                labelText: 'Quantity',
                controller: quantityController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                labelText: 'Enter Price',
                controller: priceController,
                keyboardType: TextInputType.number,
              ),
              const Spacer(),
              Center(
                child: CustomActionButton(
                  label: widget.editTransaction != null
                      ? 'Update Stock'
                      : isAddStockSelected
                      ? 'Add Stock'
                      : 'Reduce Stock',
                  backgroundColor: Color.fromARGB(255, 85, 172, 213) ,
                  onPressed: _isSaving ? () {} : saveTransactionAndUpdateStock,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    adjustmentDateController.dispose();
    quantityController.dispose();
    priceController.dispose();
    super.dispose();
  }
}
