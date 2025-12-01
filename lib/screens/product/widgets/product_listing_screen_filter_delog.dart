// lib/screens/product/widgets/product_listing_screen_filter_dialog.dart
import 'package:cream_ventory/models/category_model.dart';
import 'package:cream_ventory/screens/product/widgets/product_filtering_date_filtering_enum.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void showProductFilterDialog({
  required BuildContext context,
  required List<CategoryModel> categories,
  required CategoryModel? selectedCategory,
  required String? selectedDateFilter,
  required DateTimeRange? selectedDateRange,
  required VoidCallback onClearFilters,
  required ValueChanged<CategoryModel?> onCategoryChanged,
  required ValueChanged<String?> onDateFilterChanged,
  required ValueChanged<DateTimeRange?> onDateRangeChanged,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => ProductFilterDialog(
      categories: categories,
      selectedCategory: selectedCategory,
      selectedDateFilter: selectedDateFilter,
      selectedDateRange: selectedDateRange,
      onClearFilters: onClearFilters,
      onCategoryChanged: onCategoryChanged,
      onDateFilterChanged: onDateFilterChanged,
      onDateRangeChanged: onDateRangeChanged,
    ),
  );
}      

class ProductFilterDialog extends StatefulWidget {
  final List<CategoryModel> categories;
  final CategoryModel? selectedCategory;
  final String? selectedDateFilter;
  final DateTimeRange? selectedDateRange;

  final VoidCallback onClearFilters;
  final ValueChanged<CategoryModel?> onCategoryChanged;
  final ValueChanged<String?> onDateFilterChanged;
  final ValueChanged<DateTimeRange?> onDateRangeChanged;

  const ProductFilterDialog({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.selectedDateFilter,
    required this.selectedDateRange,
    required this.onClearFilters,
    required this.onCategoryChanged,
    required this.onDateFilterChanged,
    required this.onDateRangeChanged,
  });

  @override
  State<ProductFilterDialog> createState() => _ProductFilterDialogState();
}

class _ProductFilterDialogState extends State<ProductFilterDialog> {
  late CategoryModel? _tempCategory;
  late DateFilter _tempDateFilter;

  @override
  void initState() {
    super.initState();
    _tempCategory = widget.selectedCategory;

    // Properly restore current date filter state
    if (widget.selectedDateFilter != null) {
      final type = {
        'today': DateFilterType.today,
        'last7days': DateFilterType.last7Days,
        'last30days': DateFilterType.last30Days,
      }[widget.selectedDateFilter];

      _tempDateFilter = DateFilter(type ?? DateFilterType.none);
    } else if (widget.selectedDateRange != null) {
      _tempDateFilter = DateFilter(DateFilterType.custom, widget.selectedDateRange);
    } else {
      _tempDateFilter = const DateFilter(DateFilterType.none);
    }
  }

  void _apply() {
    widget.onCategoryChanged(_tempCategory);

    // Always clear both first
    widget.onDateFilterChanged(null);
    widget.onDateRangeChanged(null);

    // Then apply the active one
    switch (_tempDateFilter.type) {
      case DateFilterType.today:
        widget.onDateFilterChanged('today');
        break;
      case DateFilterType.last7Days:
        widget.onDateFilterChanged('last7days');
        break;
      case DateFilterType.last30Days:
        widget.onDateFilterChanged('last30days');
        break;
      case DateFilterType.custom:
        if (_tempDateFilter.customRange != null) {
          widget.onDateRangeChanged(_tempDateFilter.customRange);
        }
        break;
      case DateFilterType.none:
        // Do nothing — already cleared
        break;
    }

    Navigator.of(context).pop();
  }

  void _reset() {
    setState(() {
      _tempCategory = null;
      _tempDateFilter = const DateFilter(DateFilterType.none);
    });
    widget.onClearFilters();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isCustomSelected = _tempDateFilter.type == DateFilterType.custom;
    final customRange = _tempDateFilter.customRange;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 12,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, const Color(0xFFF5F9FF)],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF42A5F5), Color(0xFF1976D2)]),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.tune_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Filter Products',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Section
                    _sectionTitle('Category'),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _modernChip(
                          label: 'All Categories',
                          icon: Icons.category_outlined,
                          isSelected: _tempCategory == null,
                          onTap: () => setState(() => _tempCategory = null),
                        ),
                        ...widget.categories.map((cat) => _modernChip(
                              label: cat.name,
                              icon: Icons.category_outlined,
                              isSelected: _tempCategory?.id == cat.id,
                              onTap: () => setState(() => setState(() => _tempCategory = cat),
                            )),)
                      ],
                  
                    ),

                    const SizedBox(height: 28),

                    // Date Section
                    _sectionTitle('Date'),
                    const SizedBox(height: 16),

                    // Quick Filters
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _modernChip(
                          label: 'Today',
                          icon: Icons.today_rounded,
                          isSelected: _tempDateFilter.type == DateFilterType.today,
                          onTap: () => setState(() {
                            _tempDateFilter = const DateFilter(DateFilterType.today);
                          }),
                        ),
                        _modernChip(
                          label: 'Last 7 Days',
                          icon: Icons.date_range_rounded,
                          isSelected: _tempDateFilter.type == DateFilterType.last7Days,
                          onTap: () => setState(() {
                            _tempDateFilter = const DateFilter(DateFilterType.last7Days);
                          }),
                        ),
                        _modernChip(
                          label: 'Last 30 Days',
                          icon: Icons.date_range_rounded,
                          isSelected: _tempDateFilter.type == DateFilterType.last30Days,
                          onTap: () => setState(() {
                            _tempDateFilter = const DateFilter(DateFilterType.last30Days);
                          }),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Custom Date Range
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          initialDateRange: customRange,
                          builder: (context, child) => Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(primary: Colors.blue),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          setState(() {
                            _tempDateFilter = DateFilter(DateFilterType.custom, picked);
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          border: Border.all(
                            color: isCustomSelected && customRange != null
                                ? Colors.blue.shade300
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.calendar_today_rounded, color: Colors.blue, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    customRange == null ? 'Custom Date Range' : 'Selected Range',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    customRange == null
                                        ? 'Tap to pick dates'
                                        : '${DateFormat('dd MMM yyyy').format(customRange.start)} - ${DateFormat('dd MMM yyyy').format(customRange.end)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: customRange == null ? Colors.grey[500] : Colors.blue.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (customRange != null)
                              IconButton(
                                icon: const Icon(Icons.close_rounded, size: 20),
                                color: Colors.red.shade400,
                                onPressed: () => setState(() {
                                  _tempDateFilter = const DateFilter(DateFilterType.none);
                                }),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _reset,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFFB0BEC5), width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh_rounded, size: 20),
                          SizedBox(width: 8),
                          Text('Reset', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _apply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded, size: 20, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Apply', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: const BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _modernChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(colors: [Color(0xFF42A5F5), Color(0xFF1976D2)])
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF1976D2) : const Color(0xFFE0E0E0),
            width: 2,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: const Color(0xFF42A5F5).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.white : const Color(0xFF757575)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF212121),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              const Icon(Icons.check_circle, size: 16, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}