import 'package:cream_ventory/db/functions/sale/sale_db.dart';
import 'package:cream_ventory/db/models/sale/sale_model.dart';
import 'package:cream_ventory/screen/adding/sale/sale_add_screen.dart';
import 'package:cream_ventory/screen/listing/sale/screens/sale_order_listing_screen_card.dart';
import 'package:cream_ventory/themes/app_theme/theme.dart';
import 'package:cream_ventory/utils/sale_order/sale_order_utils.dart';
import 'package:cream_ventory/widgets/app_bar.dart';
import 'package:flutter/material.dart';

class SaleOrder extends StatefulWidget {
  const SaleOrder({super.key});

  @override
  State<SaleOrder> createState() => _SaleOrderState();
}

class _SaleOrderState extends State<SaleOrder> {
  String selectedFilter = 'ALL';
  final List<String> filters = ['ALL', 'Open orders', 'Closed orders', 'Cancelled orders'];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override   
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'SALE ORDERS'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(
              builder: (context) => SaleScreen(transactionType: TransactionType.saleOrder),
            ))
            .then((_) => setState(() {})),
        backgroundColor: Colors.blueGrey ,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.appGradient,
        ), 
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,       
                child: SizedBox(
                  child: Row(
                    children: filters.map((filter) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            selectedFilter = filter;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.blueGrey,width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          backgroundColor: selectedFilter == filter ? Colors.blueGrey: Colors.transparent,
                          foregroundColor: selectedFilter == filter ? Colors.red[700] : Colors.black87,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: selectedFilter == filter ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    )).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search Order',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red[300]!)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blueGrey, width: 2)),
                  prefixIcon: Icon(Icons.search, color: Colors.blue),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ValueListenableBuilder<List<SaleModel>>(
                  valueListenable: SaleDB.saleNotifier,
                  builder: (context, sales, _) { 
                    final filteredOrders = SaleUtils.filterSaleOrders(
                      sales,
                      _searchController.text,
                      selectedFilter,
                    );
                    if (filteredOrders.isEmpty) {
                      return const Center(child: Text('No sale orders found.', style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500)));
                    }
                    return ListView.builder(
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final sale = filteredOrders[index];
                        final isOpen = sale.status == SaleStatus.open;
                        final isCancelled = sale.status == SaleStatus.cancelled;
                        return SaleOrderCard(
                          isOpen: isOpen,
                          isCancelled: isCancelled,
                          orderNumber: sale.invoiceNumber,
                          date: sale.date,
                          advance: SaleUtils.formatCurrency(sale.receivedAmount),
                          balance: SaleUtils.formatCurrency(sale.balanceDue),
                          dueDate: sale.dueDate ?? 'N/A',
                          customerName: sale.customerName ?? 'Unknown Customer',
                          closeButtonText: 'Close Sale',
                          cancelButtonText: 'Cancel Sale',
                          onCloseButtonPressed: () => SaleUtils.handleCloseSale(context, sale, () => setState(() {})),
                          onCancelButtonPressed: () => SaleUtils.handleCancelSale(context, sale, () => setState(() {})),
                          sale: sale,
                        );       
                      },
                    );   
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}     