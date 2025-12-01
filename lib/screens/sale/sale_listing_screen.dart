import 'package:cream_ventory/database/functions/sale/sale_db.dart';
import 'package:cream_ventory/models/sale_model.dart' show SaleModel, TransactionType;
import 'package:cream_ventory/screens/sale/sale_add_screen.dart';
import 'package:cream_ventory/screens/sale/widgets/sale_listing_screen_body.dart';
import 'package:cream_ventory/core/theme/theme.dart';
import 'package:cream_ventory/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SaleReportScreen extends StatefulWidget {
  const SaleReportScreen({super.key});

  @override
  State<SaleReportScreen> createState() => _SaleReportScreenState();
}

class _SaleReportScreenState extends State<SaleReportScreen> {
  List<SaleModel> sales = [];
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    _initializeAndFetchSales();
  }

  Future<void> _initializeAndFetchSales() async {
    await SaleDB.init();
    _fetchSales();
    SaleDB.saleNotifier.addListener(_fetchSales);
  }

  Future<void> _fetchSales() async {
    List<SaleModel> fetchedSales = await SaleDB.getSales();
    final dateFormat = DateFormat('dd MMM yyyy');

    // Filter for sales and sale orders
    List<SaleModel> filtered = fetchedSales
        .where((sale) =>
            sale.transactionType == TransactionType.sale ||
            sale.transactionType == TransactionType.saleOrder)
        .toList();

    if (startDate != null && endDate != null) {
      filtered = filtered.where((sale) {
        try {
          DateTime saleDate = dateFormat.parse(sale.date);
          return saleDate.isAfter(startDate!.subtract(const Duration(days: 1))) &&
                 saleDate.isBefore(endDate!.add(const Duration(days: 1)));
        } catch (e) {
          debugPrint('Error parsing date for sale ${sale.id}: $e');
          return false;
        }
      }).toList();
    }

    setState(() {
      sales = filtered;
    });
  }

  @override
  void dispose() {
    SaleDB.saleNotifier.removeListener(_fetchSales);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalSale = sales.fold<double>(0, (sum, sale) => sum + sale.total);

    return Scaffold(
      appBar: CustomAppBar(title: 'Sales'),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.appGradient),
        child: BodyOfSale( 
          sales: sales,
          totalSale: totalSale,
          onDateRangeChanged: (start, end) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                startDate = start;
                endDate = end;
              });
              _fetchSales();
            });
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey ,
        elevation: 6,
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => SaleScreen(transactionType: TransactionType.sale),
                ),
              )
              .then((_) => _fetchSales());
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}