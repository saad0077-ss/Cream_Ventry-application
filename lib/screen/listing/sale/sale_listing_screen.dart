import 'package:cream_ventory/db/functions/sale/sale_db.dart';
import 'package:cream_ventory/db/models/sale/sale_model.dart' show SaleModel, TransactionType;
import 'package:cream_ventory/screen/adding/sale/sale_add_screen.dart';
import 'package:cream_ventory/screen/listing/sale/screens/sale_listing_screen_body.dart';
import 'package:cream_ventory/themes/app_theme/theme.dart';
import 'package:cream_ventory/widgets/app_bar.dart';
import 'package:cream_ventory/widgets/custom_button.dart';
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
    debugPrint('Fetched Sales: $fetchedSales');
    final dateFormat = DateFormat('dd/MM/yyyy');

    // Filter for sales only (exclude sale orders)
    List<SaleModel> filtered = fetchedSales.where((sale) => sale.transactionType == TransactionType.sale || sale.transactionType == TransactionType.saleOrder).toList();

    if (startDate != null && endDate != null) {
      debugPrint('Filtering with startDate: $startDate, endDate: $endDate');
      filtered = filtered.where((sale) {
        try {
          DateTime saleDate = dateFormat.parse(sale.date);
          bool isAfter = saleDate.isAfter(startDate!.subtract(const Duration(days: 1)));
          bool isBefore = saleDate.isBefore(endDate!.add(const Duration(days: 1)));
          debugPrint('Sale: ${sale.id}, Date: ${sale.date}, Parsed: $saleDate, isAfter: $isAfter, isBefore: $isBefore');
          return isAfter && isBefore;
        } catch (e) {
          debugPrint('Error parsing date for sale ${sale.id}: $e');
          return false;
        }
      }).toList();
      debugPrint('Filtered Sales: $filtered');
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final totalSale = sales.fold<double>(
      0,
      (sum, sale) => sum + sale.total, 
    );

    return Scaffold(
      appBar: CustomAppBar(title: 'ALL SALE'),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(gradient: AppTheme.appGradient),
        child: Stack(
          children: [
            BodyOfSale(
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
            Positioned(
              bottom: screenWidth * 0.1,
              left: screenWidth * 0.3,
              child: CustomActionButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (context) =>  SaleScreen(transactionType: TransactionType.sale),
                        ),
                      )
                      .then((_) => _fetchSales());
                },
                label: 'Add Sale',
                backgroundColor: Colors.green,
              ),
            ),
          ],
        ),
      ), 
    );
  }
}