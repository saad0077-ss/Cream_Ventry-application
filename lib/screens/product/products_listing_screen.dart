import 'package:cream_ventory/core/constants/font_helper.dart';
import 'package:cream_ventory/database/functions/product_db.dart';
import 'package:cream_ventory/models/category_model.dart';
import 'package:cream_ventory/models/product_model.dart';
import 'package:cream_ventory/screens/product/widgets/product_listing_screen_card.dart';
import 'package:cream_ventory/screens/product/widgets/product_listing_screen_filter_delog.dart';
import 'package:cream_ventory/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart'; // Required for date formatting

class ProductsTab extends StatefulWidget {
  const ProductsTab({super.key});

  @override
  State<ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> {
  // ---------- FILTER STATE ----------
  CategoryModel? selectedCategory;
  String? selectedDateFilter; // 'today', 'last7days', 'last30days', null
  DateTimeRange? selectedDateRange; // Custom date range (null = not used)

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
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductModel> filterByDate(List<ProductModel> products) {
  if (selectedDateFilter == null && selectedDateRange == null) {
    return products;
  }

  final now = DateTime.now();
  final todayMidnight = DateTime(now.year, now.month, now.day);

  return products.where((product) {
    final creationDateStr = product.creationDate;
    if (creationDateStr.isEmpty) return false;

    final creationDate = DateTime.tryParse(creationDateStr);
    if (creationDate == null) return false;

    // === Custom Date Range (highest priority) ===
    if (selectedDateRange != null) {
      final start = DateTime(selectedDateRange!.start.year, selectedDateRange!.start.month, selectedDateRange!.start.day);
      final end = DateTime(selectedDateRange!.end.year, selectedDateRange!.end.month, selectedDateRange!.end.day)
          .add(const Duration(days: 1))
          .subtract(const Duration(seconds: 1)); // inclusive end

      return creationDate.isAfter(start.subtract(const Duration(seconds: 1))) &&
             creationDate.isBefore(end.add(const Duration(seconds: 1)));
    }

    // === Quick Filters ===
    DateTime? cutoffDate;

    switch (selectedDateFilter) {
      case 'today':
        cutoffDate = todayMidnight;
        break;
      case 'last7days':
        // Today + last 6 days = 7 days total
        cutoffDate = todayMidnight.subtract(const Duration(days: 6));
        break;
      case 'last30days':
        // Today + last 29 days = 30 days total
        cutoffDate = todayMidnight.subtract(const Duration(days: 29));
        break;
      default:
        return true;
    }

    // Include products from cutoffDate 00:00 onwards
    return creationDate.isAfter(cutoffDate.subtract(const Duration(seconds: 1)));
  }).toList()
    ..sort((a, b) => a.category.name.toLowerCase().compareTo(b.category.name.toLowerCase()));
}

  // Helper to get readable label for quick filters
 String _getDateFilterLabel(String filter) {
  switch (filter) {
    case 'today': return 'Today';
    case 'last7days': return 'Last 7 Days';
    case 'last30days': return 'Last 30 Days';
    default: return '';
  }        
}

  void _showFilterBottomSheet(
      BuildContext context, List<CategoryModel> categories) {
    showProductFilterDialog(
      context: context,
      categories: categories,
      selectedCategory: selectedCategory,
      selectedDateFilter: selectedDateFilter,
      selectedDateRange: selectedDateRange,
      onClearFilters: () {
        setState(() {
          selectedCategory = null;
          selectedDateFilter = null;
          selectedDateRange = null;
          _searchController.clear();
          _searchQuery = '';
        });
      },
      onCategoryChanged: (cat) => setState(() => selectedCategory = cat),
      onDateFilterChanged: (filter) => setState(() {
        selectedDateFilter = filter;
        selectedDateRange = null;
      }),
      onDateRangeChanged: (range) => setState(() {
        selectedDateRange = range;
        selectedDateFilter = null;
      }),
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
          padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 12),
          child: ValueListenableBuilder<List<ProductModel>>(
            valueListenable: ProductDB.productNotifier,
            builder: (context, products, _) {
              final categories = products
                  .map((e) => e.category) 
                  .toSet()
                  .toList()
                ..sort((a, b) =>
                    a.name.toLowerCase().compareTo(b.name.toLowerCase()));

              return CustomSearchBar(  
                controller: _searchController,
                hintText: 'Search Products',
                onChanged: (v) =>
                    setState(() => _searchQuery = v.toLowerCase()), 
                onFilterPressed: () =>
                    _showFilterBottomSheet(context, categories),
              );
            },
          ),
        ),

        // ---- ACTIVE FILTER CHIPS ----
        if (selectedCategory != null ||
            selectedDateFilter != null ||
            selectedDateRange != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (selectedCategory != null)
                  Chip(
                    label: Text(selectedCategory!.name),
                    backgroundColor: Colors.blue.shade50,
                    deleteIconColor: Colors.blue.shade700,
                    onDeleted: () => setState(() => selectedCategory = null),
                  ),
                if (selectedDateFilter != null)
                  Chip(
                    label: Text(_getDateFilterLabel(selectedDateFilter!)),
                    backgroundColor: Colors.green.shade50,
                    deleteIconColor: Colors.green.shade700,
                    onDeleted: () => setState(() => selectedDateFilter = null),
                  ),
                if (selectedDateRange != null)
                  Chip(
                    label: Text(
                      '${DateFormat('dd MMM').format(selectedDateRange!.start)} - ${DateFormat('dd MMM yyyy').format(selectedDateRange!.end)}',
                    ),
                    backgroundColor: Colors.purple.shade50,
                    deleteIconColor: Colors.purple.shade700,
                    onDeleted: () => setState(() => selectedDateRange = null),
                  ),
              ],
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
                  : products
                      .where((p) => p.category.id == selectedCategory!.id)
                      .toList();

              // 2. Date filter (quick + custom)
              filtered = filterByDate(filtered);

              // 3. Search filter
              final searched = _searchQuery.isEmpty
                  ? filtered
                  : filtered
                      .where((p) => p.name.toLowerCase().contains(_searchQuery))
                      .toList();

              // ---- EMPTY STATE ----
              if (searched.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        selectedCategory != null ||
                                selectedDateFilter != null ||
                                selectedDateRange != null ||
                                _searchQuery.isNotEmpty
                            ? 'No products match your filters.'
                            : 'No products yet.',
                        style: AppTextStyles.emptyListText,
                        textAlign: TextAlign.center,
                      ),
                    ],
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
                    return idx >= 0 && idx < boxKeys.length ? boxKeys[idx] : '';
                  }

                  final child = isDesktop
                      ? GridView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
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
