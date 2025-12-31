import 'package:cream_ventory/core/constants/font_helper.dart';
import 'package:cream_ventory/database/functions/product_db.dart';
import 'package:cream_ventory/database/functions/stock_transaction_db.dart';
import 'package:cream_ventory/models/product_model.dart';
import 'package:cream_ventory/models/stock_transaction_model.dart';
import 'package:cream_ventory/screens/stock/stock_add_screen.dart';
import 'package:cream_ventory/core/theme/theme.dart';
import 'package:cream_ventory/core/utils/image_util.dart';
import 'package:cream_ventory/widgets/app_bar.dart';
import 'package:cream_ventory/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class ProductDetailsPage extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late ProductModel currentProduct;
  List<StockTransactionModel> transactions = [];
  bool isLoadingTransactions = true;

  @override
  void initState() {
    super.initState();
    currentProduct = widget.product;
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => isLoadingTransactions = true);
    try {
      final txns = await StockTransactionDB.getTransactionsByProduct(
        widget.product.id
      );
      if (mounted) {
        setState(() {
          transactions = txns;
          isLoadingTransactions = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading transactions: $e');
      if (mounted) {
        setState(() => isLoadingTransactions = false);
      }
    }
  }

  void _refreshProduct() async {
    final updated = await ProductDB.getProduct(widget.product.id);
    if (updated != null && mounted) {
      setState(() {
        currentProduct = updated;
      });
    }
    await _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: CustomAppBar(title: 'Product Details', fontSize: 27),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(gradient: AppTheme.appGradient),
        child: ValueListenableBuilder(
          valueListenable: ProductDB.productNotifier,
          builder: (context, List<ProductModel> products, _) {
            final latestProduct = products.firstWhere(
              (p) => p.id == widget.product.id,
              orElse: () => widget.product,
            );

            currentProduct = latestProduct;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Card
                  Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0, 
                      vertical: 20.0
                    ),
                    elevation: 6,
                    shadowColor: Colors.black.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)
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
                            // Image + Name + Category
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
                                    child: Image(
                                      image: ImageUtils.getImage(
                                        latestProduct.imagePath,
                                        fallback: 'assets/image/product_placeholder.png',
                                      ),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => 
                                        Center(
                                          child: Icon(
                                            Icons.broken_image, 
                                            color: Colors.red[300], 
                                            size: 32
                                          ),
                                        ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        latestProduct.name,
                                        style: AppTextStyles.bold18.copyWith(
                                          fontSize: 22,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Category: ${latestProduct.category.name}',
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

                            // Prices & Stock
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildInfoColumn(
                                  title: 'Sale Price',
                                  value: '₹ ${latestProduct.salePrice.toStringAsFixed(2)}',
                                  style: AppTextStyles.textBold.copyWith(
                                    color: Colors.green[700]
                                  ),
                                ),
                                _buildInfoColumn(
                                  title: 'Purchase Price',
                                  value: '₹ ${latestProduct.purchasePrice.toStringAsFixed(2)}',
                                  style: AppTextStyles.textBold.copyWith(
                                    color: Colors.blue[700]
                                  ),
                                ),
                                _buildInfoColumn(
                                  title: 'In Stock',
                                  value: latestProduct.stock.toString(),
                                  style: AppTextStyles.stockGreen.copyWith(
                                    fontSize: 18
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Total Stock Value
                            _buildInfoColumn(
                              title: 'Total Stock Value',
                              value: '₹ ${(latestProduct.stock * latestProduct.salePrice).toStringAsFixed(2)}',
                              style: AppTextStyles.textBold.copyWith(
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Stock Transaction History Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Stock Transaction History',
                          style: AppTextStyles.bold18.copyWith(
                            fontSize: 20,
                            color: Colors.black87,
                          ),
                        ),
                        if (transactions.isNotEmpty)
                          Text(
                            '${transactions.length} records',
                            style: AppTextStyles.w500.copyWith(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Transaction List
                  if (isLoadingTransactions)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (transactions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        color: Colors.amber[50],
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, 
                                color: Colors.orange[700], 
                                size: 28
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'No stock transactions yet. Add stock to see transaction history here.',
                                  style: TextStyle(
                                    fontSize: 15, 
                                    color: Colors.orange[900]
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final txn = transactions[index];
                        return _buildTransactionCard(txn);
                      },
                    ),

                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            );
          },
        ),
      ),

      // Adjust Stock Button
      floatingActionButton: CustomActionButton(  
        height: 53, 
        width: 260, 
        label: 'Adjust Stock',
        backgroundColor: Colors.blueGrey,
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddStock(product: currentProduct),
            ),
          );
          _refreshProduct();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildTransactionCard(StockTransactionModel txn) {
    final isIncrease = txn.isStockIncrease;
    final color = isIncrease ? Colors.green : Colors.red;
    final icon = isIncrease ? Icons.add_circle : Icons.remove_circle;

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        txn.typeDisplayName,
                        style: AppTextStyles.textBold.copyWith(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        txn.date,
                        style: AppTextStyles.w500.copyWith(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${isIncrease ? '+' : '-'}${txn.quantity}',
                  style: AppTextStyles.textBold.copyWith(
                    fontSize: 18,
                    color: color,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailItem(
                  'Price/Unit',
                  '₹ ${txn.pricePerUnit.toStringAsFixed(2)}',
                ),
                _buildDetailItem(
                  'Total Value',
                  '₹ ${txn.totalValue.toStringAsFixed(2)}',
                ),
                _buildDetailItem(
                  'Stock After',
                  txn.stockAfterTransaction.toString(),
                ),
              ],
            ),

            // Notes if available
            if (txn.notes != null && txn.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.note, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        txn.notes!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Reference ID if available
            if (txn.referenceId != null && txn.referenceId!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Ref: ${txn.referenceId!.substring(0, 8)}...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.w500.copyWith(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
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
            color: Colors.grey[600]
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: style),
      ],
    );
  }
}