// add_item_to_sale_controller.dart
import 'package:cream_ventory/db/functions/user_db.dart';
import 'package:cream_ventory/db/models/items/category/category_model.dart';
import 'package:cream_ventory/db/models/items/products/product_model.dart';
import 'package:cream_ventory/db/models/sale/sale_item_model.dart';
import 'package:cream_ventory/utils/adding/sale/add_item_to_sale_add_screen_utils.dart';
import 'package:flutter/material.dart';

class AddItemToSaleController {
  // Controllers
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _totalAmountController = TextEditingController();

  // State variables
  String? _selectedCategoryId;
  String? _selectedProductId;
  String? _selectedCategoryName;
  List<ProductModel> _products = [];
  bool _isEditMode;

  // Dependencies
  final SaleItemModel? saleItem;
  final int? index;
  final BuildContext context;
  final StateSetter setState;

  AddItemToSaleController({
    required this.saleItem,
    required this.index,
    required this.context,
    required this.setState,
  }) : _isEditMode = saleItem != null {
    _selectedProductId = _isEditMode ? saleItem!.id : null;
    _selectedCategoryName = _isEditMode ? saleItem!.categoryName : null;
  }

  void initialize() {
    AddItemToSaleUtils.initializeForm(
      saleItem: saleItem,
      isEditMode: _isEditMode,
      quantityController: _quantityController,
      rateController: _rateController,
      totalAmountController: _totalAmountController,
      onFormInitialized: (categoryId) {
        if (_isMounted) {
          setState(() {
            _loadProductsByCategory(categoryId);
          });
        }
      },
    );

    _rateController.addListener(_calculateTotal);
    _quantityController.addListener(_calculateTotal);
  }

  void calculateTotal() {
    if (_isMounted) {
      setState(_calculateTotal);
    }
  }

  void _calculateTotal() {
    AddItemToSaleUtils.calculateTotal(
      quantityController: _quantityController,
      rateController: _rateController,
      totalAmountController: _totalAmountController,
    );
  }

  void _loadProductsByCategory(String categoryId) {
    AddItemToSaleUtils.loadProductsByCategory(
      categoryId: categoryId,
      onProductsLoaded: (products, categoryName) {
        if (_isMounted) {
          setState(() {
            _products = products;
            _selectedCategoryName = categoryName;
            _selectedProductId = null;
          });
        }
      },
      isEditMode: _isEditMode,
      rateController: _rateController,
    );
  }

  void onCategoryChanged(String? value) {
    if (_isMounted && value != null) {
      setState(() {
        _selectedCategoryId = value;
        _loadProductsByCategory(value);
      });
    }
  }

  void onProductChanged(String? value) async {
    if (value == null || !_isMounted) return;
    final user = await UserDB.getCurrentUser();
    final selectedProduct = _products.firstWhere(
      (product) => product.id == value,
      orElse: () => ProductModel(
        name: '',
        stock: 0,
        salePrice: 0,
        purchasePrice: 0,
        category: CategoryModel(
          id: '',
          name: '',
          imagePath: '',
          discription: '',
          userId: '',
        ),
        imagePath: '',
        id: '',
        creationDate: DateTime.now().toIso8601String(),
        isAsset: false,
        userId: user.id,
      ),
    );
    setState(() {
      _selectedProductId = value;
      _rateController.text = selectedProduct.salePrice.toStringAsFixed(2);
    });
  }

  void saveSaleItem({required bool saveAndNew}) {
    AddItemToSaleUtils.saveSaleItem(
      context: context,
      selectedProductId: _selectedProductId,
      selectedCategoryName: _selectedCategoryName,
      quantityController: _quantityController,
      rateController: _rateController,
      totalAmountController: _totalAmountController,
      products: _products,
      isEditMode: _isEditMode,
      saleItem: saleItem,
      saveAndNew: saveAndNew,
      clearForm: _clearForm,
      popScreen: () => Navigator.pop(context),
    );
  }

  void _clearForm() {
    if (_isMounted) {
      setState(() {
        _quantityController.clear();
        _rateController.clear();
        _totalAmountController.clear();
        _selectedCategoryId = null;
        _selectedProductId = null;
        _products = [];
      });
    }
  }

  void dispose() {
    _quantityController.dispose();
    _rateController.removeListener(_calculateTotal);
    _rateController.dispose();
    _totalAmountController.dispose();
  }

  // Getters
  bool get isEditMode => _isEditMode;
  String? get selectedCategoryId => _selectedCategoryId;
  String? get selectedProductId => _selectedProductId;
  List<ProductModel> get products => _products;
  TextEditingController get quantityController => _quantityController;
  TextEditingController get rateController => _rateController;
  TextEditingController get totalAmountController => _totalAmountController;

  bool get _isMounted => context.mounted;
}