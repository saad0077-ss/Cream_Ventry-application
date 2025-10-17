import 'package:cream_ventory/db/functions/product_db.dart';
import 'package:cream_ventory/db/functions/sale/sale_db.dart';
import 'package:cream_ventory/db/functions/stock_db.dart';
import 'package:cream_ventory/db/functions/user_db.dart';
import 'package:cream_ventory/db/models/items/products/product_model.dart';
import 'package:cream_ventory/db/models/items/products/stock_model.dart';
import 'package:cream_ventory/db/models/sale/sale_model.dart';
import 'package:cream_ventory/db/models/user/user_model.dart';
import 'package:cream_ventory/screen/home/simple_e.dart';
import 'package:cream_ventory/screen/home/widgets/home_menu_provider.dart';
import 'package:cream_ventory/screen/home/widgets/home_menu_tile.dart';
import 'package:cream_ventory/screen/home/widgets/sale_graph.dart';
import 'package:cream_ventory/screen/home/widgets/home_screen_stat_card.dart';
import 'package:cream_ventory/themes/app_theme/theme.dart';
import 'package:cream_ventory/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScreenHome extends StatelessWidget {
  final UserModel user;
  const ScreenHome({super.key, required this.user});

  Future<bool> _isNewUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isNew = !prefs.containsKey('hasLoggedIn_${user.id}');
    if (isNew) {
      await prefs.setBool(
        'hasLoggedIn_${user.id}',
        true,
      ); // Mark user as logged in
    }
    return isNew;
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = HomeMenuProvider.getMenuItems(context);
    final String today = DateFormat('dd/MM/yyyy').format(DateTime.now());

    // Fetch the current user from UserDB for comparison
    final currentUser = UserDB.getCurrentUser(); // Assuming this is a Future
    // Since build is synchronous, we'll handle this asynchronously
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final fetchedUser = await currentUser;
      if (fetchedUser.id != user.id) {
        debugPrint(
          'User ID mismatch! Passed: ${user.id}, Current: ${fetchedUser.id}',
        );
        // Optionally, you can show a snackbar or handle the mismatch
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('User ID mismatch detected!')),
        // );
      } else {
        debugPrint('User ID match confirmed: ${user.id}');
      }
    });

    return Scaffold(
      appBar: CustomAppBar(
        title: ' HOME',
        automaticallyImplyLeading: false,
        center: false,
        notificationIcon: const Icon(Icons.notifications),
        onNotificationPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AweseomSnackBarExample()),  
          );
          // final prefs = await SharedPreferences.getInstance();
          // final currentUserId = prefs.getString('currentUserId');
          // debugPrint("-----------------------------------------------------$currentUserId");
        },
        fontSize: 30,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.appGradient),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.04,
              vertical: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<bool>(
                      future: _isNewUser(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox.shrink(); // Show nothing while loading
                        }
                        final isNewUser = snapshot.data ?? true;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isNewUser
                                  ? "Welcome to Creamventory"
                                  : "Welcome back",   
                              style: const TextStyle(
                                color: Color.fromARGB(255, 55, 56, 57),
                                fontFamily: 'Nosifer',
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              isNewUser
                                  ? "Manage your inventory with ease and efficiency."
                                  : "Good to see you again! Let's manage your inventory.",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontFamily: 'ABeeZee',
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // 🔝 Sales Graph Card
                SizedBox(
                  height: 300, // Define a specific height for SalesGraph
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: SalesGraph(),
                      ), // Use Expanded to fill available space
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: StatCard<List<ProductModel>>(
                            title: "Total Products",
                            valueListenable: ProductDB.productNotifier,
                            valueBuilder: (products) => "${products.length}",
                            icon: Icons.inventory_2_outlined,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: ValueListenableBuilder<List<StockModel>>(
                            valueListenable: StockDB.lowStockNotifier,
                            builder: (context, lowStockList, _) {
                              return FutureBuilder<List<StockModel>>(
                                future: StockDB.getLowStockAlert(
                                  threshold: 5.0,  
                                ),
                                builder: (context, snapshot) {
                                  final lowStockList =
                                      snapshot.data ?? StockDB.lowStockNotifier.value;
                                  final uniqueProductIds = lowStockList
                                      .map((s) => s.productId)
                                      .toSet()
                                      .length;
                                  return StatCard<int>(
                                    title: "Low Stocks",
                                    valueListenable: ValueNotifier(
                                      uniqueProductIds,
                                    ),
                                    valueBuilder: (count) => "$count",
                                    icon: Icons.warning_amber_outlined,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(     
                          child: StatCard<List<SaleModel>>(
                            title: "Today's Orders",
                            valueListenable: SaleDB.saleNotifier,
                            valueBuilder: (sales) =>
                                "${sales.where((sale) => sale.dueDate == today).length}",   
                            icon: Icons.shopping_cart_outlined,
                          ),
                        ),   
                        SizedBox(width: 10),
                        Expanded(
                          child: StatCard<List<SaleModel>>(
                            title: "Today's Sales",
                            valueListenable: SaleDB.saleNotifier,
                            valueBuilder: (sales) => 
                                "${sales.where((sale) => sale.date == today && sale.transactionType != TransactionType.saleOrder).length}",
                            icon: Icons.attach_money_outlined,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: Duration(milliseconds: 300 + (index * 100)),
                        builder: (context, double value, child) {  
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Opacity(
                              opacity: value,
                              child: Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: HomeMenuTile(item: item),
                              ),
                            ),    
                          );
                        },
                      ),
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
}
