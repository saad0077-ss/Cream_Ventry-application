import 'package:cream_ventory/db/functions/product_db.dart';
import 'package:cream_ventory/db/functions/sale/sale_db.dart';
import 'package:cream_ventory/db/models/items/products/product_model.dart';
import 'package:cream_ventory/db/models/sale/sale_model.dart';
import 'package:cream_ventory/db/models/user/user_model.dart';
import 'package:cream_ventory/screen/home/widgets/home_menu_provider.dart';
import 'package:cream_ventory/screen/home/widgets/home_menu_tile.dart';
import 'package:cream_ventory/screen/home/widgets/home_screen_stat_card.dart';
import 'package:cream_ventory/themes/app_theme/theme.dart';
import 'package:cream_ventory/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScreenHome extends StatelessWidget {
  final UserModel user;
  const ScreenHome({super.key, required this.user});

  Future<bool> _isNewUser() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'hasLoggedIn_${user.id}';
    final isNew = !prefs.containsKey(key);
    if (isNew) {
      await prefs.setBool(key, true);
    }
    return isNew;
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = HomeMenuProvider.getMenuItems(context);
    final String today = DateFormat('dd/MM/yyyy').format(DateTime.now());

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
                          isNewUser ? "Welcome to Creamventory" : "Welcome back",
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

                // Total Products + Low Stock
                Row(
                  children: [
                    Expanded(
                      child: StatCard<List<ProductModel>>(
                        title: "Total Products",
                        valueListenable: ProductDB.productNotifier,
                        valueBuilder: (products) => "${products.length}",
                        icon: Icons.inventory_2_outlined,
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
                  ],
                ),

                const SizedBox(height: 20),

                // Today's Orders + Today's Sales
                Row(
                  children: [
                    Expanded(
                      child: StatCard<List<SaleModel>>(
                        title: "Today's Orders",
                        valueListenable: SaleDB.saleNotifier,
                        valueBuilder: (sales) => sales
                            .where((sale) => sale.dueDate == today)
                            .length
                            .toString(),
                        icon: Icons.shopping_cart_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatCard<List<SaleModel>>(
                        title: "Today's Sales",
                        valueListenable: SaleDB.saleNotifier,
                        valueBuilder: (sales) => sales
                            .where((sale) =>
                                sale.date == today &&
                                sale.transactionType != TransactionType.saleOrder)
                            .length
                            .toString(),
                        icon: Icons.attach_money_outlined,
                      ),
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