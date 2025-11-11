import 'package:cream_ventory/screens/category/add_category_bottom_sheet.dart';
import 'package:cream_ventory/screens/product/widgets/show_product_add_bottom_sheet.dart';
import 'package:cream_ventory/screens/home/widgets/tap_view_button.dart';
import 'package:cream_ventory/screens/category/categories_listing_screen.dart'; 
import 'package:cream_ventory/screens/product/products_listing_screen.dart';
import 'package:cream_ventory/screens/product/widgets/item_screen_custom_flotting_button.dart';
import 'package:cream_ventory/core/theme/theme.dart';
import 'package:cream_ventory/widgets/app_bar.dart';
import 'package:flutter/material.dart';

class ScreenItems extends StatefulWidget {
  const ScreenItems({super.key});

  @override
  State<ScreenItems> createState() => _ScreenItemsState();
}

class _ScreenItemsState extends State<ScreenItems>
    with SingleTickerProviderStateMixin {
  final GlobalKey<CategoriesTabState> categoriesTabKey = GlobalKey<CategoriesTabState>();
  bool isCategorySelected = true;
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this); 
    tabController.addListener(() {
      setState(() {
        isCategorySelected = tabController.index == 0;
      });
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: CustomAppBar(
        title: 'ITEMS',
        fontSize: 29,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.appGradient), 
        child: Column(
          children: [
            TabButtons(
              isTabOneSelected: isCategorySelected,
              onTapOne: () {
                setState(() {
                  isCategorySelected = true;
                  tabController.index = 0;
                });
              },
              onTapTwo: () {
                setState(() {
                  isCategorySelected = false;
                  tabController.index = 1;
                });
              },
              title1: 'Categories',
              title2: 'Products',
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  CategoriesTab(key: categoriesTabKey),
                  ProductsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: CustomFloatingActionButton(
        currentIndex: tabController.index, 
        onCategoriesTap: () {
          AddCategoryBottomSheet.show(context); // Handle adding category
        },
        onProductsTap: () {
          showAddProductBottomSheet(context); // Handle adding product 
        },
      ),
    );
  }
}