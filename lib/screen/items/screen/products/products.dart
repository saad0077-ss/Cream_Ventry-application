import 'package:cream_ventory/db/functions/product_db.dart';
import 'package:cream_ventory/db/models/items/category/category_model.dart';
import 'package:cream_ventory/db/models/items/products/product_model.dart';
import 'package:cream_ventory/screen/items/screen/products/widgets/product_card.dart';
import 'package:cream_ventory/themes/font_helper/font_helper.dart';
import 'package:cream_ventory/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class ProductsTab extends StatefulWidget {
  const ProductsTab({super.key});

  @override
  State<ProductsTab> createState() => ProductsTabState();
}

class ProductsTabState extends State<ProductsTab> {
  CategoryModel? selectedCategory;
  String? selectedDateFilter;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    // Filter products based on selected date filter
    List<ProductModel> filteredProducts = products.where((product) {
      try {
        final creationDate = formatter.parse(product.creationDate);
        final now = DateTime.now();
        switch (selectedDateFilter) {
          case 'today':
            return creationDate.day == now.day &&
                creationDate.month == now.month &&
                creationDate.year == now.year;
          case 'last7days':
            return creationDate.isAfter(now.subtract(const Duration(days: 7)));
          case 'last30days':   
            return creationDate.isAfter(now.subtract(const Duration(days: 30)));
          case 'Custom':
            if (selectedStartDate == null || selectedEndDate == null) return true;
            return creationDate.isAfter(selectedStartDate!) &&
                creationDate.isBefore(selectedEndDate!.add(const Duration(days: 1)));
          default:
            return true;
        }
      } catch (e) {
        print('Error parsing creationDate for product ${product.name}: $e');
        return false;
      }
    }).toList();

    // Sort filtered products by category name (alphabetically)
    filteredProducts.sort((a, b) {
      return a.category.name.toLowerCase().compareTo(b.category.name.toLowerCase());
    });

    return filteredProducts;
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    if (!mounted) return;

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate:
          isStart
              ? (selectedStartDate ?? DateTime.now())
              : (selectedEndDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              surface: Color.fromARGB(208, 117, 114, 114),
              onSurface: Colors.white,
            ), dialogTheme: DialogThemeData(backgroundColor: const Color.fromARGB(208, 117, 114, 114)),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      setState(() {
        if (isStart) {
          selectedStartDate = pickedDate;
        } else {
          selectedEndDate = pickedDate;
        }
        selectedDateFilter = "Custom";
      });
    }
  }

  void showFilterBottomSheet(
    BuildContext context,
    List<CategoryModel> categories, 
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      backgroundColor: const Color.fromARGB(255, 21, 21, 21),
      builder: (sheetContext) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [ 
                // Category Section
                const Text(
                  'Category',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: const Text(
                    'All Categories',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    setState(() {
                      selectedCategory = null;
                    });
                    Navigator.pop(sheetContext);
                  },
                  tileColor:
                      selectedCategory == null
                          ? Colors.black.withOpacity(0.2)
                          : null,
                ),
                ...categories.map((category) {
                  return ListTile(
                    title: Text(
                      category.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      setState(() {
                        selectedCategory = category;
                      });
                      Navigator.pop(sheetContext);
                    },
                    tileColor:
                        selectedCategory == category
                            ? Colors.black.withOpacity(0.2)
                            : null,
                  );
                }),
                const Divider(color: Colors.white54),
                // Date Section
                const Text(
                  'Date',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: const Text(
                    'Today',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    setState(() {
                      selectedDateFilter = 'today';
                    });
                    Navigator.pop(sheetContext);
                  },
                  tileColor:
                      selectedDateFilter == 'today'
                          ? Colors.black.withOpacity(0.2)
                          : null,
                ),
                ListTile(
                  title: const Text(
                    'Last 7 Days',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    setState(() {
                      selectedDateFilter = 'last7days';
                    });
                    Navigator.pop(sheetContext);
                  },
                  tileColor:
                      selectedDateFilter == 'last7days'
                          ? Colors.black.withOpacity(0.2)
                          : null,
                ),
                ListTile(
                  title: const Text(
                    'Last 30 Days',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    setState(() {
                      selectedDateFilter = 'last30days';
                    });
                    Navigator.pop(sheetContext);
                  },
                  tileColor:
                      selectedDateFilter == 'last30days'
                          ? Colors.black.withOpacity(0.2)
                          : null,
                ),
                ListTile(
                  title: const Text(
                    'Custom Date Range',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    if (mounted) {
                      _pickDate(context, true).then((_) {
                        if (mounted && selectedStartDate != null) {
                          _pickDate(context, false);
                        }
                      });
                    }
                  },
                  tileColor:
                      selectedDateFilter == 'Custom'
                          ? Colors.black.withOpacity(0.2)
                          : null,
                ),
                const Divider(color: Colors.white54),
                // Clear Filters
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedCategory = null;
                        selectedDateFilter = null;
                        selectedStartDate = null;
                        selectedEndDate = null;
                        _searchController.clear();
                        _searchQuery = '';
                      });
                      Navigator.pop(sheetContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Clear All Filters'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [ 
        SizedBox(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Column(
              children: [
                ValueListenableBuilder<List<ProductModel>>(
                  valueListenable: ProductDB.productNotifier,
                  builder: (context, products, _) {
                    // Ensure unique categories by comparing category IDs or names
                    final categories = products
                        .map((e) => e.category)
                        .toSet()
                        .toList()
                      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

                    return CustomSearchBar(
                      controller: _searchController,
                      hintText: 'Search Products',
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                      onFilterPressed: () {
                        showFilterBottomSheet(context, categories);
                      },
                    );
                  },
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ValueListenableBuilder<List<ProductModel>>(
                    valueListenable: ProductDB.productNotifier,
                    builder: (context, products, _) {
                      var filteredProducts =
                          selectedCategory == null
                              ? products
                              : products
                                  .where((p) => p.category.id == selectedCategory!.id)
                                  .toList();

                      filteredProducts = filterByDate(filteredProducts);

                      final searchedProducts =
                          _searchQuery.isEmpty
                              ? filteredProducts
                              : filteredProducts
                                  .where(
                                    (p) => p.name.toLowerCase().contains(
                                      _searchQuery,
                                    ),
                                  )
                                  .toList();

                      if (searchedProducts.isEmpty) {
                        return Center(
                          child: Text(
                            'No products found.',
                            style: AppTextStyles.emptyListText,
                          ),
                        );
                      }

                      return FutureBuilder<Box<ProductModel>>(
                        future: Hive.openBox<ProductModel>('productBox'),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            return const Center(
                              child: Text('Error loading products'),
                            );
                          } 

                          final box = snapshot.data!;
                          final boxKeys = box.keys.toList();

                          return ListView.builder(
                            itemCount: searchedProducts.length,   
                            itemBuilder: (context, index) {
                              final product = searchedProducts[index];
                              final key = boxKeys[products.indexOf(product)] as String;
                              return ItemCard(product: product, index: key);    
                            },
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
      ],
    );
  }
}   