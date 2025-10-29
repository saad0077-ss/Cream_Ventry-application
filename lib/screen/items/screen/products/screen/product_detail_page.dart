import 'dart:io';
import 'package:cream_ventory/db/functions/product_db.dart';
import 'package:cream_ventory/db/functions/stock_db.dart';
import 'package:cream_ventory/db/models/items/products/product_model.dart';
import 'package:cream_ventory/db/models/items/products/stock_model.dart';
import 'package:cream_ventory/screen/items/screen/products/screen/stock_add_page.dart';
import 'package:cream_ventory/themes/app_theme/theme.dart';
import 'package:cream_ventory/themes/font_helper/font_helper.dart';
import 'package:cream_ventory/widgets/app_bar.dart';
import 'package:cream_ventory/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductDetailsPage extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: CustomAppBar(title: 'Product', fontSize: 27),
      body: Container(

        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(gradient: AppTheme.appGradient),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ValueListenableBuilder(
                valueListenable: ProductDB.productNotifier,
                builder: (context, List<ProductModel> products, _) {
                  final currentProduct = products.firstWhere(
                    (p) => p.id == widget.product.id,
                    orElse: () => widget.product,
                  );
                  // Compute stock from StockDB for consistency
                  return ValueListenableBuilder(
                    valueListenable: StockDB.stockListNotifier,
                    builder: (context, List<StockModel> transactions, _) {
                      final totalStock = transactions
                          .where((tx) => tx.productId == currentProduct.id)
                          .fold<double>(0, (sum, tx) => sum + tx.quantity)
                          .toInt();
                      // Validate consistency
                      if (totalStock != currentProduct.stock) {
                        debugPrint(
                          'Stock inconsistency for product ${currentProduct.id}: '
                          'Product stock=${currentProduct.stock}, StockModel total=$totalStock',
                        );
                      }
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,  
                          vertical: 20.0,
                        ),
                        elevation: 6,
                        shadowColor: Colors.black.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [Colors.white, Colors.grey[50]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.grey[200],
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child:
                                            currentProduct.imagePath.isNotEmpty
                                            ? Image.file(
                                                File(currentProduct.imagePath),
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => Center(
                                                      child: Icon(
                                                        Icons.error,
                                                        color: Colors.red[300],
                                                      ),
                                                    ),
                                              )
                                            : Center(
                                                child: Text(
                                                  'No Image',
                                                  style: AppTextStyles.w500
                                                      .copyWith(
                                                        color: Colors.grey[600],
                                                      ),
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            currentProduct.name,
                                            style: AppTextStyles.bold18
                                                .copyWith(
                                                  fontSize: 22,
                                                  color: Colors.black87,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Category: ${currentProduct.category.name}',
                                            style: AppTextStyles.w500.copyWith(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildInfoColumn(
                                      title: 'Sale Price',
                                      value:
                                          '₹ ${currentProduct.salePrice.toStringAsFixed(2)}',
                                      style: AppTextStyles.textBold.copyWith(
                                        color: Colors.green[700],
                                      ),
                                    ),
                                    _buildInfoColumn(
                                      title: 'Purchase Price',
                                      value:
                                          '₹ ${currentProduct.purchasePrice.toStringAsFixed(2)}',
                                      style: AppTextStyles.textBold.copyWith(
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                    _buildInfoColumn(
                                      title: 'In Stock',
                                      value: currentProduct.stock.toString(),
                                      style: AppTextStyles.stockGreen.copyWith(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildInfoColumn(
                                  title: 'Stock Value',
                                  value:
                                      '₹ ${(totalStock * currentProduct.salePrice).toStringAsFixed(2)}',
                                  style: AppTextStyles.textBold.copyWith(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const Divider(height: 10),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stock Transaction',
                      style: AppTextStyles.transactionTitle,
                    ),
                    const SizedBox(height: 16), 
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Transaction'),
                          Text('Quantity'),
                          Text('Total'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder(
                      valueListenable: StockDB.stockListNotifier,
                      builder: (context, List<StockModel> transactions, _) {
                        final productTransactions =
                            transactions
                                .where(
                                  (tx) => tx.productId == widget.product.id,
                                )
                                .toList()
                              ..sort(
                                (a, b) => DateFormat('dd/MM/yyyy')
                                    .parse(b.date)
                                    .compareTo(
                                      DateFormat('dd/MM/yyyy').parse(a.date),
                                    ),
                              );
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: productTransactions.length,
                          itemBuilder: (context, index) {
                            final transaction = productTransactions[index];
                            return GestureDetector(
                              onTap: transaction.type == 'Opening Balance'
                                  ? null
                                  : () => _navigateToEditTransaction(
                                      context,
                                      transaction,
                                      currentProduct: widget.product,
                                    ),
                              child: Card(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                elevation: transaction.type == 'Opening Balance'
                                    ? 4
                                    : 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 120,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              transaction.type,
                                              style:
                                                  transaction.type ==
                                                      'Opening Balance'
                                                  ? AppTextStyles.bold18
                                                  : AppTextStyles.w500,
                                            ),
                                            Text(
                                              transaction.date,
                                              style:
                                                  AppTextStyles.transactionDate,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        transaction.quantity.toStringAsFixed(1),
                                        style: AppTextStyles.w500,
                                      ),
                                      Text(
                                        '₹ ${transaction.total.toStringAsFixed(2)}',
                                        style: AppTextStyles.w500,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(5.0),
        child: CustomActionButton(
          label: 'Adjust Stock',
          backgroundColor: Colors.black,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddStock(product: widget.product),
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildInfoColumn({
    required String title,
    required String value,
    required TextStyle style,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.w500.copyWith(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: style),
      ],
    );
  }

  void _navigateToEditTransaction(
    BuildContext context,
    StockModel transaction, {
    required ProductModel currentProduct,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            AddStock(product: currentProduct, editTransaction: transaction),
      ),
    );
  }
}
