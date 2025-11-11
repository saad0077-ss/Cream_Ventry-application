// sale_screen.dart
import 'package:cream_ventory/models/sale_model.dart';
import 'package:cream_ventory/screens/controller/sale_add_screen_controller.dart';
import 'package:cream_ventory/screens/sale/widgets/sale_add_screen/sale_add_screen_action_buttons_widget.dart';
import 'package:cream_ventory/screens/sale/widgets/sale_add_screen/sale_add_screen_body_widget.dart';
import 'package:cream_ventory/screens/sale/widgets/sale_add_screen/sale_add_screen_form_fields_widget.dart';
import 'package:cream_ventory/screens/sale/widgets/sale_add_screen/sale_add_screen_items_section_widget.dart';
import 'package:cream_ventory/screens/sale/widgets/sale_add_screen/sale_add_screen_scaffold_widget.dart';
import 'package:cream_ventory/screens/sale/widgets/sale_add_screen/sale_add_screen_status_warning_widget.dart';
import 'package:cream_ventory/core/utils/sale/sale_add_screen_utils.dart';
import 'package:flutter/material.dart';

class SaleScreen extends StatefulWidget {
  final SaleModel? sale;
  final TransactionType transactionType;

  const SaleScreen({super.key, this.sale, required this.transactionType});

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  late final SaleScreenController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SaleScreenController(
      sale: widget.sale,
      transactionType: widget.transactionType,
      context: context,
      setState: setState,
    );
    _controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return SaleScaffoldWidget.buildScaffold(
      title: _controller.isEditMode
          ? 'Edit ${widget.transactionType == TransactionType.sale ? "Sale" : "Sale Order"}'
          : 'Add ${widget.transactionType == TransactionType.sale ? "Sale" : "Sale Order"}',
      onBackPressed: () async {
        final shouldPop = await _controller.handleBackNavigation();
        if (shouldPop && mounted) {
          Navigator.pop(context);
        }
      },
      body: SaleBodyWidget.buildBody(
        screenSize: screenSize,
        scrollableChildren: [
          SaleStatusWarningWidget.buildStatusWarning(
            isCancelled: _controller.isCancelled,
            isClosed: _controller.isClosed,
            transactionType: widget.transactionType.toString().split('.').last,
          ),
          SaleFormFieldsWidget.buildFormFields(
            invoiceController: _controller.invoiceController,
            dateController: _controller.dateController,
            customerController: _controller.customerController,
            dueDateController: _controller.dueDateController,
            isEditable: _controller.isEditable,
            transactionType: widget.transactionType,
            onDateTap: () =>
                SaleAddUtils.selectDate(context, _controller.dateController),
            onDueDateTap: () => SaleAddUtils.selectDueDate(
                context, _controller.dueDateController),
            onCustomerChanged: _controller.onCustomerChanged,
          ),
          SaleItemsSectionWidget.buildItemsSection(
            balanceDue: _controller.balanceDue,
            isEditable: _controller.isEditable,
            onAddItem: _controller.onAddItem,
            onItemTap: _controller.onItemTap,
            receivedController: _controller.receivedController,
            isReceivedChecked: _controller.isReceivedChecked,
            onReceivedChanged: _controller.onReceivedChanged,
          ),
        ],
        bottomButtons: SaleActionButtonsWidget.buildActionButtons(
          isEditMode: _controller.isEditMode,
          isEditable: _controller.isEditable,
          onDelete: () {
            if (_controller.isEditMode) {
              SaleAddUtils.deleteSale(
                sale: widget.sale!,
                context: context,
                transactionType: widget.transactionType,
              ).then((_) {
                if (mounted) {
                  Navigator.pop(context);
                }
              });
            }
          },
          onUpdate: () => _controller.saveSale(isSaveAndNew: false),
          onSaveAndNew: () => _controller.saveSale(isSaveAndNew: true),
          onSave: () => _controller.saveSale(isSaveAndNew: false),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}