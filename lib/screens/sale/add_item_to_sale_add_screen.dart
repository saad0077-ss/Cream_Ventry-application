// add_item_to_sale.dart
import 'package:cream_ventory/models/sale_item_model.dart';
import 'package:cream_ventory/screens/controller/add_item_to_sale_add_screen_controller.dart';
import 'package:cream_ventory/screens/sale/widgets/add_items_to_sale/add_item_to_sale_add_screen_action_button_widget.dart';
import 'package:cream_ventory/screens/sale/widgets/add_items_to_sale/add_item_to_sale_add_screen_body_widget.dart';
import 'package:cream_ventory/screens/sale/widgets/add_items_to_sale/add_item_to_sale_add_screen_category_product_selection_widget.dart';
import 'package:cream_ventory/screens/sale/widgets/add_items_to_sale/add_item_to_sale_add_screen_scaffold_widget.dart';
import 'package:cream_ventory/screens/sale/widgets/add_items_to_sale/add_item_to_sale_add_screen_total_amount_widget.dart';
import 'package:flutter/material.dart';

class AddItemToSale extends StatefulWidget {
  final SaleItemModel? saleItem; // Optional sale item for editing
  final int? index; // Index of the item in the list for updating

  const AddItemToSale({super.key, this.saleItem, this.index});

  @override
  _AddItemToSaleState createState() => _AddItemToSaleState();
}

class _AddItemToSaleState extends State<AddItemToSale> {
  late final AddItemToSaleController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AddItemToSaleController(
      saleItem: widget.saleItem,
      index: widget.index,
      context: context,
      setState: setState,
    );
    _controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return AddItemScaffoldWidget.buildScaffold(
      title: _controller.isEditMode ? 'Edit Item' : 'Add Item to Sale',
      body: AddItemBodyWidget.buildBody(
        screenSize: screenSize,
        children: [
          AddItemCategoryProductSelectionWidget.buildCategoryProductSelection(
            selectedCategoryId: _controller.selectedCategoryId,
            selectedProductId: _controller.selectedProductId,
            products: _controller.products,
            onCategoryChanged: _controller.onCategoryChanged,
            onProductChanged: _controller.onProductChanged,
            quantityController: _controller.quantityController,
            rateController: _controller.rateController,
          ),
          const SizedBox(height: 20),
          const SizedBox(height: 20),  
          AddItemTotalAmountWidget.buildTotalAmount(
            totalAmountController: _controller.totalAmountController,
          ),
          const SizedBox(height: 20),
          AddItemActionButtonsWidget.buildActionButtons( 
            isEditMode: _controller.isEditMode,
            onSaveAndNew: () => _controller.saveSaleItem(saveAndNew: true),
            onSave: () => _controller.saveSaleItem(saveAndNew: false),
            isSmallScreen: screenSize.width <= 1123,
          ),
        ],
      ),           
    );
  }
 
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
} 