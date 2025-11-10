import 'package:cream_ventory/db/functions/product_db.dart';
import 'package:cream_ventory/db/models/items/category/category_model.dart';
import 'package:cream_ventory/db/models/items/products/product_model.dart';
import 'package:cream_ventory/screen/listing/items/widgets/cards/product_listing_screen_card.dart';
import 'package:cream_ventory/screen/listing/items/widgets/product_listing_screen_filter_bottom_sheet.dart';
import 'package:cream_ventory/themes/font_helper/font_helper.dart';
import 'package:cream_ventory/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ProductsTab extends StatefulWidget {
  const ProductsTab({super.key});

  @override
  State<ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> {
  // ---------- FILTER STATE ----------
  CategoryModel? selectedCategory;
  String? selectedDateFilter; // only: null, 'today', 'last7days', 'last30days'

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // ---------- RESPONSIVE ----------
  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900;

  @override
  void initState() {
    super.initState();
    ProductDB.refreshProducts();

    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---------- DATE FILTER (NO CUSTOM RANGE) ----------
  List<ProductModel> filterByDate(List<ProductModel> products) {
    if (selectedDateFilter == null) return products;

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    return products.where((product) {
      // Parse creationDate safely (fallback to tryParse)
      final creationDate = DateTime.tryParse(product.creationDate);
      if (creationDate == null) return false;

      switch (selectedDateFilter) {
        case 'today':
          return creationDate.isAfter(todayStart.subtract(const Duration(seconds: 1))) &&
                 creationDate.isBefore(todayStart.add(const Duration(days: 1)));

        case 'last7days':
          final sevenDaysAgo = now.subtract(const Duration(days: 7));
          return creationDate.isAfter(sevenDaysAgo);

        case 'last30days':
          final thirtyDaysAgo = now.subtract(const Duration(days: 30));
          return creationDate.isAfter(thirtyDaysAgo);

        default:
          return true;
      }
    }).toList()
      ..sort((a, b) => a.category.name.toLowerCase().compareTo(b.category.name.toLowerCase()));
  }

  // ---------- FILTER BOTTOM SHEET ----------
  void _showFilterBottomSheet(
    BuildContext context,
    List<CategoryModel> categories,
  ) {
    showProductFilterBottomSheet(
      context: context,
      categories: categories,
      selectedCategory: selectedCategory,
      selectedDateFilter: selectedDateFilter,
      onClearFilters: () {
        setState(() {
          selectedCategory = null;
          selectedDateFilter = null;
          _searchController.clear();
          _searchQuery = '';
        });
      },
      onCategoryChanged: (cat) => setState(() => selectedCategory = cat),
      onDateFilterChanged: (filter) =>
          setState(() => selectedDateFilter = filter),
      // Remove these if not needed in bottom sheet:
      // onStartDateChanged: ...
      // onEndDateChanged: ...
      // onPickDate: ...
    );
  }

  // ---------- REUSABLE CARD ----------
  Widget _buildProductCard(ProductModel product, String key) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: _isDesktop(context) ? 12 : 8,
        left: _isDesktop(context) ? 8 : 0,
        right: _isDesktop(context) ? 8 : 0,
      ),
      child: ItemCard(product: product, index: key),
    );
  }
  

  // ---------- MAIN BUILD ----------
  @override
  Widget build(BuildContext context) {
    final bool isDesktop = _isDesktop(context);


    return Column(
      children: [
        // ---- SEARCH + FILTER BAR ----
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ValueListenableBuilder<List<ProductModel>>(
            valueListenable: ProductDB.productNotifier,
            builder: (context, products, _) {
              final categories = products
                  .map((e) => e.category)
                  .toSet()
                  .toList()
                ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

              return CustomSearchBar(
                controller: _searchController,
                hintText: 'Search Products',
                onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                onFilterPressed: () => _showFilterBottomSheet(context, categories),
              );
            },
          ),
        ),
        const SizedBox(height: 8),

        // ---- PRODUCT LIST / GRID ----
        Expanded(
          child: ValueListenableBuilder<List<ProductModel>>(
            valueListenable: ProductDB.productNotifier,
            builder: (context, products, _) {
              // 1. Category filter
              var filtered = selectedCategory == null
                  ? products
                  : products.where((p) => p.category.id == selectedCategory!.id).toList();

              // 2. Date filter
              filtered = filterByDate(filtered);

              // 3. Search filter
              final searched = _searchQuery.isEmpty
                  ? filtered
                  : filtered.where((p) => p.name.toLowerCase().contains(_searchQuery)).toList();

              // ---- EMPTY STATE ----
              if (searched.isEmpty) {
                return Center(
                  child: Text(
                    'No products found.',
                    style: AppTextStyles.emptyListText,
                  ),
                );
              }

              // ---- OPEN BOX ONCE (for keys) ----
              return FutureBuilder<Box<ProductModel>>(
                future: Hive.openBox<ProductModel>('productBox'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading products'));
                  }

                  final box = snapshot.data!;
                  final boxKeys = box.keys.cast<String>().toList();

                  String keyFor(ProductModel p) {
                    final idx = products.indexOf(p);
                    return idx >= 0 ? boxKeys[idx] : '';
                  } 

                  final child = isDesktop
                      ? GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisExtent: 170,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                          ), 
                          itemCount: searched.length,
                          itemBuilder: (context, i) {
                            final product = searched[i];
                            return _buildProductCard(product, keyFor(product));
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          itemCount: searched.length,
                          itemBuilder: (context, i) {
                            final product = searched[i];
                            return _buildProductCard(product, keyFor(product));
                          },
                        );

                  return RefreshIndicator(
                    onRefresh: () async => ProductDB.refreshProducts(),
                    child: child,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}            