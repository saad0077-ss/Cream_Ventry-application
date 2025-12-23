import 'package:cream_ventory/database/functions/product_db.dart';
import 'package:cream_ventory/database/functions/sale/sale_db.dart';
import 'package:cream_ventory/models/product_model.dart';
import 'package:cream_ventory/models/sale_model.dart';
import 'package:cream_ventory/models/user_model.dart';
import 'package:cream_ventory/screens/home/widgets/home_menu_provider.dart';
import 'package:cream_ventory/screens/home/widgets/home_menu_tile.dart';
import 'package:cream_ventory/screens/home/widgets/home_screen_stat_card.dart';
import 'package:cream_ventory/core/theme/theme.dart';
import 'package:cream_ventory/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScreenHome extends StatefulWidget {
  final UserModel user;
  const ScreenHome({super.key, required this.user});

  @override
  State<ScreenHome> createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> {
  Future<bool> _isNewUser() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'hasLoggedIn_${widget.user.id}';
    final hasLoggedIn = prefs.getBool(key) ?? false;
    if (!hasLoggedIn) {
      await prefs.setBool(key, true);
      return true; // First time user
    }
    return false; // Returning user      
  }

  @override
  void initState() {
    super.initState();
    // Extra safety: refresh when page is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ProductDB.refreshProducts();
      ProductDB.getLowStockAlert();
      SaleDB.refreshSales();
    });
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = HomeMenuProvider.getMenuItems(context);
    final String today = DateFormat('dd MMM yyyy').format(DateTime.now());
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 800;

    return Scaffold(
      appBar: CustomAppBar(
        title: ' HOME',
        automaticallyImplyLeading: false,
        center: false,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.appGradient),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.04,
              vertical: 20.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Message
                FutureBuilder<bool>(
                  future: _isNewUser(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink();
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
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12.r,
                            fontFamily: 'ABeeZee',
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Stat Cards - Responsive Layout
                if (isWideScreen)
                  // Single row with 4 columns for wide screens
                  Row(
                    children: [
                      Expanded(
                        child: ValueListenableBuilder(
                          valueListenable: ProductDB.productNotifier,
                          builder: (context, products, _) {
                            return StatCard<List<ProductModel>>(
                              title: "Total Products",
                              valueListenable: ProductDB.productNotifier,
                              valueBuilder: (products) => "${products.length}",
                              icon: Icons.inventory_2_outlined,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ValueListenableBuilder<List<ProductModel>>(
                          valueListenable: ProductDB.lowStockNotifier,
                          builder: (context, lowStockProducts, _) {
                            return StatCard<List<ProductModel>>(
                              title: "Low Stocks",
                              valueListenable: ProductDB.lowStockNotifier,
                              valueBuilder: (products) => "${products.length}",
                              icon: Icons.warning_amber_outlined,
                              backgroundColor: lowStockProducts.isNotEmpty
                                  ? Colors.orange[50]
                                  : null,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ValueListenableBuilder(
                          valueListenable: SaleDB.saleNotifier,
                          builder: (context, sales, _) {
                            return StatCard<List<SaleModel>>(
                              title: "Today's Orders",
                              valueListenable: SaleDB.saleNotifier,
                              valueBuilder: (sales) => sales
                                  .where((sale) =>
                                      sale.dueDate == today &&
                                      sale.transactionType ==
                                          TransactionType.saleOrder &&
                                      sale.status == SaleStatus.open)
                                  .length
                                  .toString(),
                              icon: Icons.shopping_cart_outlined,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ValueListenableBuilder(
                          valueListenable: SaleDB.saleNotifier,
                          builder: (context, sales, _) {
                            return StatCard<List<SaleModel>>(
                              title: "Today's Sales",
                              valueListenable: SaleDB.saleNotifier,
                              valueBuilder: (sales) => sales
                                  .where(
                                    (sale) =>
                                        sale.date == today &&
                                        (sale.transactionType ==
                                                TransactionType.sale ||
                                            (sale.transactionType ==
                                                    TransactionType.saleOrder &&
                                                sale.status ==
                                                    SaleStatus.closed)) &&
                                        sale.status != SaleStatus.cancelled,
                                  )
                                  .length
                                  .toString(), 
                              icon: Icons.attach_money_outlined,
                            );
                          },
                        ),
                      ),
                    ],
                  )
                else
                  // Two rows with 2 columns each for smaller screens
                  // Replace the smaller screen stat cards section (around line 180-260)
// Two rows with 2 columns each for smaller screens
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ValueListenableBuilder(
                              valueListenable: ProductDB.productNotifier,
                              builder: (context, products, _) {
                                return StatCard<List<ProductModel>>(
                                  title: "Total Products",
                                  valueListenable: ProductDB.productNotifier,
                                  valueBuilder: (products) =>
                                      "${products.length}",
                                  icon: Icons.inventory_2_outlined,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ValueListenableBuilder<List<ProductModel>>(
                              valueListenable: ProductDB.lowStockNotifier,
                              builder: (context, lowStockProducts, _) {
                                return StatCard<List<ProductModel>>(
                                  title: "Low Stocks",
                                  valueListenable: ProductDB.lowStockNotifier,
                                  valueBuilder: (products) =>
                                      "${products.length}",
                                  icon: Icons.warning_amber_outlined,
                                  backgroundColor: lowStockProducts.isNotEmpty
                                      ? Colors.orange[50]
                                      : null,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ValueListenableBuilder(
                              valueListenable: SaleDB.saleNotifier,
                              builder: (context, sales, _) {
                                return StatCard<List<SaleModel>>(
                                  title: "Today's Orders",
                                  valueListenable: SaleDB.saleNotifier,
                                  valueBuilder: (sales) => sales
                                      .where((sale) =>
                                          sale.dueDate == today &&
                                          sale.transactionType ==
                                              TransactionType.saleOrder &&
                                          sale.status == SaleStatus.open)
                                      .length
                                      .toString(),
                                  icon: Icons.shopping_cart_outlined,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ValueListenableBuilder(
                              valueListenable: SaleDB.saleNotifier,
                              builder: (context, sales, _) {
                                return StatCard<List<SaleModel>>(
                                  title: "Today's Sales",
                                  valueListenable: SaleDB.saleNotifier,
                                  valueBuilder: (sales) => sales
                                      .where(
                                        (sale) =>
                                            sale.date == today &&
                                            (sale.transactionType ==
                                                    TransactionType.sale ||
                                                (sale.transactionType ==
                                                        TransactionType
                                                            .saleOrder &&
                                                    sale.status ==
                                                        SaleStatus.closed)) &&
                                            sale.status != SaleStatus.cancelled,
                                      )
                                      .length
                                      .toString(),
                                  icon: Icons.attach_money_outlined,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                const SizedBox(height: 30),

                // Menu Items with Animation
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
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
                            offset: Offset(0, 30 * (1 - value)),
                            child: Opacity(
                              opacity: value,
                              child: Card(
                                elevation: 4,
                                shadowColor: Colors.black.withOpacity(0.1),
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
