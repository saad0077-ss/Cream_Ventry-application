import 'dart:io';
import 'package:cream_ventory/db/functions/party_db.dart';
import 'package:cream_ventory/db/functions/product_db.dart';
import 'package:cream_ventory/db/functions/sale/sale_db.dart';
import 'package:cream_ventory/db/functions/sale/sale_item_db.dart';
import 'package:cream_ventory/db/functions/stock_db.dart';
import 'package:cream_ventory/db/functions/user_db.dart';
import 'package:cream_ventory/db/models/parties/party_model.dart';
import 'package:cream_ventory/db/models/sale/sale_item_model.dart';
import 'package:cream_ventory/db/models/sale/sale_model.dart';
import 'package:cream_ventory/screen/adding/sale/add_item_to_sale.dart';
import 'package:cream_ventory/themes/app_theme/theme.dart';
import 'package:cream_ventory/widgets/app_bar.dart';
import 'package:cream_ventory/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:uuid/uuid.dart';

// Assuming this exists
class AppConstants {
  static const String customerLabel = 'Customer';
  static const String invoiceNoLabel = 'Invoice No';
  static const String dateLabel = 'Date';
  static const String dueDateLabel = 'Due Date';
  static const String noItemsText = 'No items added yet.';
  static const String selectCustomerHint = 'Select a customer';
  static const String noCustomersHint = 'No customers available';
  static const String saveSuccess = 'saved successfully!';
  static const String updateSuccess = 'updated successfully!';
  static const String deleteSuccess = 'deleted successfully!';
  static const String addItemError = 'Please add at least one item to save.';
  static const String selectCustomerError = 'Please select a customer.';
}

// Assuming this exists for business logic
class SaleService {
  static Future<void> saveSale({
    required SaleModel sale,
    required BuildContext context,
    required bool isEditMode,
    required bool isSaveAndNew,
  }) async {
    final items = await SaleItemDB.getSaleItems(userId: sale.userId);
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppConstants.addItemError),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (sale.customerName == null || sale.customerName!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppConstants.selectCustomerError),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    for (var item in items) {
      final product = await ProductDB.getProduct(item.id);
      if (product == null || product.stock < item.quantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Insufficient stock for ${item.productName}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    isEditMode ? await SaleDB.updateSale(sale) : await SaleDB.addSale(sale);
    await SaleItemDB.clearSaleItems();
    await PartyDb.loadParties();
    await PartyDb.updateBalanceAfterSale(sale);
  }
}

const String _fallbackImagePath = 'assets/images/ice2.jpg';

class SaleScreen extends StatefulWidget {
  final SaleModel? sale;
  final TransactionType transactionType;

  const SaleScreen({super.key, this.sale, required this.transactionType});

  @override
  _SaleScreenState createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _invoiceController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _receivedController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();

  bool _isReceivedChecked = false;
  bool get _isEditMode => widget.sale != null;
  bool get _isEditable =>
      !_isEditMode || widget.sale!.status == SaleStatus.open;
  bool get _isCancelled =>
      _isEditMode && widget.sale!.status == SaleStatus.cancelled;
  bool get _isClosed => _isEditMode && widget.sale!.status == SaleStatus.closed;
  double _balanceDue = 0.0;
  List<SaleItemModel> _saleItems = [];

  @override
  void initState() {
    super.initState();
    _receivedController.addListener(_updateBalanceDue);
    SaleItemDB.saleItemNotifier.addListener(_updateSaleItems);
    initializeForm();
  }

  void _updateSaleItems() async {
    try {
      final user = await UserDB.getCurrentUser();
      final userId = user.id;
      final items = await SaleItemDB.getSaleItems(userId: userId);
      setState(() {
        _saleItems = items;
      });
      _updateBalanceDue();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load sale items: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updateBalanceDue() {
    double total = _saleItems.fold(0, (sum, item) => sum + item.subtotal);
    double received = double.tryParse(_receivedController.text) ?? 0.0;
    setState(() {
      _balanceDue = total - received;
    });
  }

  Future<void> initializeForm() async {
    try {
      await PartyDb.loadParties();
      await SaleItemDB.init();
      if (_isEditMode) {
        final sale = widget.sale!;
        _customerController.text = sale.customerName ?? '';
        _invoiceController.text = sale.invoiceNumber;
        _dateController.text = sale.date;
        _receivedController.text = sale.receivedAmount.toString();
        _dueDateController.text = sale.dueDate ?? '';
        _isReceivedChecked = sale.receivedAmount > 0;
        _balanceDue = sale.balanceDue;
        await SaleItemDB.loadItemsForEdit(sale.items);
      } else {
        _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
        if (widget.transactionType == TransactionType.saleOrder) {
          _dueDateController.text = DateFormat(
            'dd/MM/yyyy',
          ).format(DateTime.now());
        }
        await SaleDB.init();
        final latestInvoice = await SaleDB.getLatestInvoiceNumber();
        setState(() {
          _invoiceController.text = (latestInvoice + 1).toString();
        });
      }
      _updateBalanceDue();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to initialize form: $error'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dueDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _saveSale({required bool isSaveAndNew}) async {
    try {
      final user = await UserDB.getCurrentUser();
      final sale = SaleModel(
        id: _isEditMode ? widget.sale!.id : const Uuid().v4(),
        invoiceNumber: _invoiceController.text,
        date: _dateController.text,
        customerName: _customerController.text.isEmpty
            ? null
            : _customerController.text,
        items: _saleItems,
        total: _saleItems.fold(0, (sum, item) => sum + item.subtotal),
        receivedAmount: double.tryParse(_receivedController.text) ?? 0.0,
        balanceDue: _balanceDue,
        dueDate:
            widget.transactionType == TransactionType.saleOrder &&
                _dueDateController.text.isNotEmpty
            ? _dueDateController.text
            : null,
        transactionType: widget.transactionType,
        status: _isEditMode ? widget.sale!.status : SaleStatus.open,
        convertedToSaleId: _isEditMode ? widget.sale!.convertedToSaleId : null,
        userId: user.id,
      );
      await SaleService.saveSale(
        sale: sale,
        context: context,
        isEditMode: _isEditMode,
        isSaveAndNew: isSaveAndNew,
      );
      if (isSaveAndNew && !_isEditMode) {
        setState(() {
          _customerController.clear();
          _invoiceController.text = (int.parse(_invoiceController.text) + 1)
              .toString();
          _dateController.text = DateFormat(
            'dd/MM/yyyy',
          ).format(DateTime.now());
          _receivedController.clear();
          _dueDateController.text =
              widget.transactionType == TransactionType.saleOrder
              ? DateFormat('dd/MM/yyyy').format(DateTime.now())
              : '';
          _isReceivedChecked = false;
          _balanceDue = 0.0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.transactionType == TransactionType.sale ? "Sale" : "Sale Order"} ${AppConstants.saveSuccess}',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      } else {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? '${widget.transactionType == TransactionType.sale ? "Sale" : "Sale Order"} ${AppConstants.updateSuccess}'
                  : '${widget.transactionType == TransactionType.sale ? "Sale" : "Sale Order"} ${AppConstants.saveSuccess}',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error in _saveSale: $e\n$stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteSale() {
    if (!_isEditMode) return;
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'Confirm Delete',
      text:
          'Are you sure you want to delete this ${widget.transactionType == TransactionType.sale ? "sale" : "sale order"}? This will restore the stock for all items.',
      confirmBtnText: 'Delete',
      cancelBtnText: 'Cancel',
      confirmBtnColor: Colors.red,
      onConfirmBtnTap: () async {
        Navigator.pop(context); // Close the alert before processing
        try {
          // Restock each item
          for (var item in widget.sale!.items) {
            await StockDB.restockProduct(item.id, item.quantity);
          }

          // Delete the sale and related items
          await SaleDB.deleteSale(widget.sale!.id);
          await SaleItemDB.clearSaleItems();

          // Close current page and show success message
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${widget.transactionType == TransactionType.sale ? "Sale" : "Sale Order"} ${AppConstants.deleteSuccess}',
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
            ),
          );
        } catch (error) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete: $error'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }
    
  Future<bool> _handleBackNavigation() async {
    bool hasUnsavedChanges = false;
    final user = await UserDB.getCurrentUser();
    final userId = user.id;
    final items = await SaleItemDB.getSaleItems(userId: userId);

    if (_isEditMode && _isEditable) {
      final sale = widget.sale!;
      hasUnsavedChanges =
          _customerController.text != (sale.customerName ?? '') ||
          _invoiceController.text != sale.invoiceNumber ||
          _dateController.text != sale.date ||
          double.tryParse(_receivedController.text) != sale.receivedAmount ||
          _dueDateController.text != (sale.dueDate ?? '') ||
          items.length != sale.items.length ||
          items.any((item) => !sale.items.contains(item));
    } else if (!_isEditMode) {
      hasUnsavedChanges =
          items.isNotEmpty ||
          _customerController.text.isNotEmpty ||
          _receivedController.text.isNotEmpty ||
          (_dueDateController.text.isNotEmpty &&
              widget.transactionType == TransactionType.saleOrder);
    }

    if (hasUnsavedChanges) {
      return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Confirm Cancel'),
              content: Text(
                'Are you sure you want to cancel this ${widget.transactionType == TransactionType.sale ? "sale" : "sale order"}? All unsaved changes will be lost, and stock will be restored.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      for (var item in items) {
                        debugPrint(
                          'Canceling sale - Product: ${item.productName}, ID: ${item.id}, Quantity Restored: ${item.quantity}',
                        );
                        await StockDB.restockProduct(item.id, item.quantity);
                      }
                      await SaleItemDB.clearSaleItems();
                      Navigator.pop(context, true);
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to restore stock: $error'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.red,
                        ),
                      );
                      Navigator.pop(context, false);
                    }
                  },
                  child: const Text('Yes', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ) ??
          false;
    } else {
      await SaleItemDB.clearSaleItems();
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CustomAppBar(
        title: _isEditMode
            ? 'Edit ${widget.transactionType == TransactionType.sale ? "Sale" : "Sale Order"}'
            : 'Add ${widget.transactionType == TransactionType.sale ? "Sale" : "Sale Order"}',
        fontSize: 30,
        onBackPressed: () async {
          bool shouldPop = await _handleBackNavigation();
          if (shouldPop) {
            Navigator.pop(context);
          }
        },
      ),
      body: SingleChildScrollView(
        child: Container(
          width: screenWidth,
          height: screenHeight,
          decoration: const BoxDecoration(gradient: AppTheme.appGradient),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isCancelled || _isClosed) ...[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'This sale order is ${_isCancelled ? "cancelled" : "closed"} and cannot be edited.',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _invoiceController,
                        decoration: const InputDecoration(
                          labelText: AppConstants.invoiceNoLabel,
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true, // Invoice is always read-only
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _dateController,
                        readOnly: true,
                        onTap: _isEditable ? () => _selectDate(context) : null,
                        decoration: const InputDecoration(
                          labelText: AppConstants.dateLabel,
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ValueListenableBuilder<List<PartyModel>>(
                  valueListenable: PartyDb.partyNotifier,
                  builder: (context, parties, _) {
                    if (parties.isEmpty) {
                      return TextField(
                        controller: _customerController,
                        decoration: const InputDecoration(
                          labelText: AppConstants.customerLabel,
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                          hintText: AppConstants.noCustomersHint,
                        ),
                        readOnly: true,
                      );
                    }
                    PartyModel? selectedParty;
                    if (_customerController.text.isNotEmpty) {
                      selectedParty = parties.firstWhere(
                        (party) => party.name == _customerController.text,
                        orElse: () => parties[0],
                      );
                    }
                    return DropdownButtonFormField<PartyModel>(
                      value: selectedParty,
                      hint: const Text(AppConstants.selectCustomerHint),
                      items: parties.map((party) {
                        return DropdownMenuItem<PartyModel>(
                          value: party,
                          child: Text(party.name),
                        );
                      }).toList(),
                      onChanged: _isEditable
                          ? (PartyModel? selected) {
                              if (selected != null) {
                                setState(() {
                                  _customerController.text = selected.name;
                                });
                              }
                            }
                          : null,
                      decoration: const InputDecoration(
                        labelText: AppConstants.customerLabel,
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      isExpanded: true,
                      validator: (value) {
                        if (value == null && _customerController.text.isEmpty) {
                          return AppConstants.selectCustomerError;
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
                if (widget.transactionType == TransactionType.saleOrder) ...[
                  TextField(
                    controller: _dueDateController,
                    readOnly: true,
                    onTap: _isEditable ? () => _selectDueDate(context) : null,
                    decoration: const InputDecoration(
                      labelText: AppConstants.dueDateLabel,
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                ValueListenableBuilder<List<SaleItemModel>>(
                  valueListenable: SaleItemDB.saleItemNotifier,
                  builder: (context, items, _) {
                    double total = items.fold(
                      0,
                      (sum, item) => sum + item.subtotal,
                    );
                    return Column(
                      children: [
                        ExpansionTile(
                          title: Text(
                            'Billed Items (${items.length})',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_drop_down_circle_outlined,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surface,
                          collapsedBackgroundColor: Theme.of(
                            context,
                          ).colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.outline,
                              width: 1.0,
                            ),
                          ),
                          collapsedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.outline,
                              width: 1.0,
                            ),
                          ),
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          childrenPadding: const EdgeInsets.all(8.0),
                          children: items.isEmpty
                              ? [
                                  const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text(
                                      AppConstants.noItemsText,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ]
                              : [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: items.length,
                                    itemBuilder: (context, index) {
                                      final item = items[index];
                                      return InkWell(
                                        onTap: _isEditable
                                            ? () {
                                                Navigator.of(context)
                                                    .push(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            AddItemToSale(
                                                              saleItem: item,
                                                              index: index,
                                                            ),
                                                      ),
                                                    )
                                                    .then((_) {
                                                      _updateBalanceDue();
                                                    });
                                              }
                                            : null,
                                        child: Card(
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12.0,
                                            ),
                                          ),
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                            vertical: 6.0,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        8.0,
                                                      ),
                                                  child: Container(
                                                    width: 60,
                                                    height: 60,
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                        image:
                                                            _getImageProvider(
                                                              item.imagePath,
                                                            ),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12.0),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        item.productName,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 4.0,
                                                      ),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 12.0,
                                                              vertical: 4.0,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                16.0,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          item.categoryName,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 12,
                                                              ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 8.0,
                                                      ),
                                                      Text(
                                                        '${item.quantity} x ₹${item.rate.toStringAsFixed(2)}',
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8.0,
                                                            vertical: 4.0,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8.0,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        '#${item.index}',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8.0),
                                                    Text(
                                                      '₹${item.subtotal.toStringAsFixed(2)}',
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: _isEditable
                              ? () {
                                  Navigator.of(context)
                                      .push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const AddItemToSale(),
                                        ),
                                      )
                                      .then((_) {
                                        _updateBalanceDue();
                                      });
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            elevation: 2,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Add Items',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total Amount',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '₹${total.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: _isReceivedChecked,
                                          onChanged: _isEditable
                                              ? (value) {
                                                  setState(() {
                                                    _isReceivedChecked = value!;
                                                    if (!value) {
                                                      _receivedController
                                                          .clear();
                                                    }
                                                    _updateBalanceDue();
                                                  });
                                                }
                                              : null,
                                        ),
                                        const Text('Received'),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 190,
                                      height: 40,
                                      child: TextField(
                                        controller: _receivedController,
                                        keyboardType: TextInputType.number,
                                        enabled:
                                            _isReceivedChecked && _isEditable,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          prefixText: '₹ ',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Balance Due',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '₹${_balanceDue.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            if (_isEditMode) ...[
                              CustomActionButton(
                                label: 'DELETE',
                                backgroundColor: Colors.red,
                                onPressed:
                                    _deleteSale, // Delete always enabled in edit mode
                              ),
                              CustomActionButton(
                                label: 'UPDATE',
                                backgroundColor: Colors.black,
                                onPressed: () => _isEditable
                                    ? () => _saveSale(isSaveAndNew: false)
                                    : null,
                              ),
                            ] else ...[
                              CustomActionButton(
                                label: 'SAVE & NEW',
                                backgroundColor: Colors.black,
                                onPressed: () => _saveSale(isSaveAndNew: true),
                              ),
                              CustomActionButton(
                                label: 'SAVE',
                                backgroundColor: Colors.red,
                                onPressed: () => _saveSale(isSaveAndNew: false),
                              ),
                            ],
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ImageProvider _getImageProvider(String? imagePath) {
    debugPrint('Loading image for path: $imagePath');
    if (imagePath != null && imagePath.isNotEmpty) {
      try {
        final file = File(imagePath);
        if (file.existsSync()) {
          return FileImage(file);
        }
      } catch (e) {
        debugPrint('Invalid image file at $imagePath: $e');
      }
    }
    debugPrint('Using fallback image');
    return const AssetImage(_fallbackImagePath);
  }

  @override
  void dispose() {
    _customerController.dispose();
    _invoiceController.dispose();
    _dateController.dispose();
    _receivedController.removeListener(_updateBalanceDue);
    _receivedController.dispose();
    _dueDateController.dispose();
    SaleItemDB.saleItemNotifier.removeListener(_updateSaleItems);
    super.dispose();
  }
}
