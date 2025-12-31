// sale_screen_controller.dart
import 'package:cream_ventory/core/constants/sale_add_screen_constant.dart';
import 'package:cream_ventory/database/functions/party_db.dart';
import 'package:cream_ventory/database/functions/sale/sale_item_db.dart';
import 'package:cream_ventory/database/functions/user_db.dart';
import 'package:cream_ventory/models/party_model.dart';
import 'package:cream_ventory/models/sale_item_model.dart';
import 'package:cream_ventory/models/sale_model.dart';
import 'package:cream_ventory/screens/sale/add_item_to_sale_add_screen.dart';
import 'package:cream_ventory/core/utils/sale/sale_add_screen_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class SaleScreenController {
  // Controllers
  late final TextEditingController _customerController;
  late final TextEditingController _invoiceController;
  late final TextEditingController _dateController;
  late final TextEditingController _receivedController;
  late final TextEditingController _dueDateController;

  // State variables
  bool _isReceivedChecked = false;
  double _balanceDue = 0.0;
  List<SaleItemModel> _saleItems = [];
  PartyModel? _selectedParty;  // ← Add this to track selected party

  // Dependencies
  final SaleModel? sale;
  final TransactionType transactionType;
  final BuildContext context;
  final StateSetter setState;

  // Computed properties
  bool get _isEditMode => sale != null;
  bool get _isEditable {
    if (_isEditMode) {
      // For saleOrder, _isEditable is false if status is closed or cancelled
      if (transactionType == TransactionType.saleOrder) {
        return !(sale!.status == SaleStatus.closed ||
            sale!.status == SaleStatus.cancelled);
      }
      // For sale and edit mode, _isEditable is true
      if (transactionType == TransactionType.sale) {
        return true;
      }
    }
    // Default case: true when not in edit mode or when status is open for sale
    return !_isEditMode ||
        (sale!.status == SaleStatus.open &&
            transactionType == TransactionType.sale);
  }

  bool get _isCancelled => _isEditMode && sale!.status == SaleStatus.cancelled;
  bool get _isClosed => _isEditMode && sale!.status == SaleStatus.closed;

  SaleScreenController({
    required this.sale,
    required this.transactionType,
    required this.context,
    required this.setState,
  });

  void initialize() {
    _initializeControllers();
    _setupListeners();
    _initializeForm();
  }

  void _initializeControllers() {
    _customerController = TextEditingController();
    _invoiceController = TextEditingController();
    _dateController = TextEditingController();
    _receivedController = TextEditingController();
    _dueDateController = TextEditingController();
  }

  void _setupListeners() {
    _receivedController.addListener(_updateBalanceDue);
    SaleItemDB.saleItemNotifier.addListener(_updateSaleItems);
  }

  Future<void> _initializeForm() async {
    try {
      await SaleAddUtils.initializeForm(
        sale: sale,
        customerController: _customerController,
        invoiceController: _invoiceController,
        dateController: _dateController,
        receivedController: _receivedController,
        dueDateController: _dueDateController,
        isEditMode: _isEditMode,
        transactionType: transactionType,
        updateBalanceDue: _updateBalanceDue,
      );
      
      // ✅ Load the selected party if in edit mode
      if (_isEditMode && sale != null) {
        _isReceivedChecked = sale!.receivedAmount > 0;
        _balanceDue = sale!.balanceDue;
        
        // Load party by ID if available, fallback to name
        if (sale!.customerId != null && sale!.customerId!.isNotEmpty) {
          _selectedParty = await PartyDb.getPartyById(sale!.customerId!);
          if (_selectedParty != null && _isMounted) {
            setState(() {
              _customerController.text = _selectedParty!.name;
            });
          }
        } else if (sale!.customerName != null && sale!.customerName!.isNotEmpty) {
          // Fallback: find by name for old data
          final parties = PartyDb.partyNotifier.value;
          try {
            _selectedParty = parties.firstWhere(
              (p) => p.name == sale!.customerName,
            );
          } catch (e) {
            debugPrint('Party not found for name: ${sale!.customerName}');
          }
        }
      }
    } catch (error) {
      if (_isMounted) {
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            message: 'Failed to initialize form: $error',
          ),
        );
      }
    }
  }

  void _updateSaleItems() async {
    try {
      final user = await UserDB.getCurrentUser();
      final items = await SaleItemDB.getSaleItems(userId: user.id);
      if (_isMounted) {
        setState(() {
          _saleItems = items;
        });
        _updateBalanceDue();
      }
    } catch (e) {
      if (_isMounted) {
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            message: 'Failed to load sale items: $e',
          ),
        );
      }
    }
  }

  void _updateBalanceDue() {
    final total = _saleItems.fold(0.0, (sum, item) => sum + item.subtotal);
    final received = double.tryParse(_receivedController.text) ?? 0.0;
    if (_isMounted) {
      setState(() {
        _balanceDue = total - received;
      });
    }
  }

  // ✅ UPDATED saveSale method with customerId support
  Future<void> saveSale({required bool isSaveAndNew}) async {
    try {
      final user = await UserDB.getCurrentUser();
      
      // ✅ Determine the customer ID and name
      String? customerId;
      String? customerName;
      
      if (_selectedParty != null) {
        // Use the selected party (most reliable)
        customerId = _selectedParty!.id;
        customerName = _selectedParty!.name;
      } else if (_customerController.text.isNotEmpty) {
        // Try to find party by name (fallback)
        final parties = PartyDb.partyNotifier.value;
        try {
          final party = parties.firstWhere(
            (p) => p.name == _customerController.text,
          );
          customerId = party.id;
          customerName = party.name;
        } catch (e) {
          debugPrint('Party not found for name: ${_customerController.text}');
          // Use name only (for backward compatibility with old data)
          customerName = _customerController.text;
          customerId = null;
        }
      }
      
      // ✅ Create sale model with customerId
      final saleModel = SaleModel(
        id: _isEditMode ? sale!.id : const Uuid().v4(),
        invoiceNumber: _invoiceController.text,
        date: _dateController.text,
        customerId: customerId,  // ← Store party ID
        customerName: customerName,  // ← Keep name for cache/display
        items: _saleItems,
        total: _saleItems.fold(0.0, (sum, item) => sum + item.subtotal),
        receivedAmount: double.tryParse(_receivedController.text) ?? 0.0,
        balanceDue: _balanceDue,
        dueDate: transactionType == TransactionType.saleOrder &&
                _dueDateController.text.isNotEmpty
            ? _dueDateController.text
            : null,
        transactionType: transactionType,
        status: _isEditMode ? sale!.status : SaleStatus.open,
        convertedToSaleId: _isEditMode ? sale!.convertedToSaleId : null,
        userId: user.id,
      );

      // Call saveSale and check if validation passed
      final success = await SaleAddUtils.saveSale(
        sale: saleModel,
        context: context,
        isEditMode: _isEditMode,
        isSaveAndNew: isSaveAndNew,
      );

      // Only proceed if validation passed
      if (!success) {
        debugPrint('Validation failed, not proceeding with save');
        return;
      }

      final message = _isEditMode
          ? '${transactionType == TransactionType.sale ? "Sale" : "Sale Order"} ${AppConstants.updateSuccess}'
          : '${transactionType == TransactionType.sale ? "Sale" : "Sale Order"} ${AppConstants.saveSuccess}';

      if (isSaveAndNew && !_isEditMode) {
        if (_isMounted) {
          setState(() {
            _customerController.clear();
            _selectedParty = null;  // ← Clear selected party
            _invoiceController.text =
                (int.parse(_invoiceController.text) + 1).toString();
            _dateController.text =
                DateFormat('dd MMM yyyy').format(DateTime.now());
            _receivedController.clear();
            _dueDateController.text =
                transactionType == TransactionType.saleOrder
                    ? DateFormat('dd MMM yyyy').format(DateTime.now())
                    : '';
            _isReceivedChecked = false;
            _balanceDue = 0.0;
            _saleItems = [];
          });
          showTopSnackBar(
            Overlay.of(context),
            CustomSnackBar.success(
              message: message,
            ),
          );
        }
      } else {
        if (_isMounted) {
          showTopSnackBar(
            Overlay.of(context),
            CustomSnackBar.success(
              message: message,
            ),
          );
          // Use Future.microtask to ensure snackbar shows before navigation
          Future.microtask(() {
            if (_isMounted) {
              Navigator.pop(context, true);
            }
          });
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error in saveSale: $e\n$stackTrace');
      if (_isMounted) {
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            message: 'An unexpected error occurred: $e',
          ),
        );
      }
    }
  }

  // ✅ UPDATED onCustomerChanged to track selected party
  void onCustomerChanged(PartyModel? selected) {
    if (selected != null && _isMounted) {
      setState(() {
        _selectedParty = selected;  // ← Store the party object
        _customerController.text = selected.name;
      });
      debugPrint('Customer changed: ${selected.name} (ID: ${selected.id})');
    }
  }

  void onReceivedChanged(bool? value) {
    if (value != null && _isMounted) {
      setState(() {
        _isReceivedChecked = value;
        if (!value) {
          _receivedController.clear();
        }
        _updateBalanceDue();
      });
    }
  }

  void onAddItem() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const AddItemToSale()))
        .then((_) => _updateBalanceDue());
  }

  void onItemTap(int index) {
    final item = _saleItems[index];
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => AddItemToSale(saleItem: item, index: index),
          ),
        )
        .then((_) => _updateBalanceDue());
  }

  Future<bool> handleBackNavigation() async {
    return await SaleAddUtils.handleBackNavigation(
      context: context,
      sale: sale,
      transactionType: transactionType,
      customerController: _customerController,
      invoiceController: _invoiceController,
      dateController: _dateController,
      receivedController: _receivedController,
      dueDateController: _dueDateController,
      isEditMode: _isEditMode,
      isEditable: _isEditable,
    );
  }

  void dispose() {
    _customerController.dispose();
    _invoiceController.dispose();
    _dateController.dispose();
    _receivedController.removeListener(_updateBalanceDue);
    _receivedController.dispose();
    _dueDateController.dispose();
    SaleItemDB.saleItemNotifier.removeListener(_updateSaleItems);
  }

  bool get isCancelled => _isCancelled;
  bool get isClosed => _isClosed;
  bool get isEditable => _isEditable;
  bool get isEditMode => _isEditMode;
  List<SaleItemModel> get saleItems => _saleItems;
  double get balanceDue => _balanceDue;
  bool get isReceivedChecked => _isReceivedChecked;
  TextEditingController get customerController => _customerController;
  TextEditingController get invoiceController => _invoiceController; 
  TextEditingController get dateController => _dateController;
  TextEditingController get receivedController => _receivedController;
  TextEditingController get dueDateController => _dueDateController;
  PartyModel? get selectedParty => _selectedParty;  // ← Add getter

  bool get _isMounted => context.mounted;
}