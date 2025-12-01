import 'package:cream_ventory/core/constants/font_helper.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangeSelector extends StatefulWidget {
  final void Function(DateTime startDate, DateTime endDate)? onDateRangeChanged;

  const DateRangeSelector({super.key, this.onDateRangeChanged});

  @override
  _DateRangeSelectorState createState() => _DateRangeSelectorState();
}

class _DateRangeSelectorState extends State<DateRangeSelector>
    with SingleTickerProviderStateMixin {
  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now();
  String selectedOption = "This Month";
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
    _animationController!.forward();
    _setDateRange("This Month");
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final currentContext = context;
    if (!mounted) return;

    DateTime? pickedDate = await showDatePicker(
      context: currentContext,
      initialDate: isStart ? selectedStartDate : selectedEndDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade600,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogBackgroundColor: Colors.white,
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
        selectedOption = "Custom";
        _notifyDateRangeChanged();
      });
    }
  }

  void _setDateRange(String option) {
    final now = DateTime.now();
    if (mounted) {
      setState(() {
        selectedOption = option;
        switch (option) {
          case "Today":
            selectedStartDate = DateTime(now.year, now.month, now.day);
            selectedEndDate = selectedStartDate;
            break;
          case "Yesterday":
            final yesterday = now.subtract(const Duration(days: 1));
            selectedStartDate = DateTime(
              yesterday.year,
              yesterday.month,
              yesterday.day,
            );
            selectedEndDate = selectedStartDate;
            break;
          case "This Month":
            selectedStartDate = DateTime(now.year, now.month, 1);
            selectedEndDate = DateTime(now.year, now.month + 1, 0);
            break;
          case "Last Month":
            selectedStartDate = DateTime(now.year, now.month - 1, 1);
            selectedEndDate = DateTime(now.year, now.month, 0);
            break;
          case "All":
            selectedStartDate = DateTime(2000);
            selectedEndDate = DateTime(2100);
            break;
          case "Custom":
            break;
        }
        _notifyDateRangeChanged();
      });
    }
  }

  void _notifyDateRangeChanged() {
    if (widget.onDateRangeChanged != null && mounted) {
      widget.onDateRangeChanged!(selectedStartDate, selectedEndDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    // Return simple container if animation not ready
    if (_fadeAnimation == null) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation!,
      child: Container(
        margin: EdgeInsets.all(isTablet ? 16 : 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.blue.shade50.withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.blue.shade100,
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24 : 35,
            vertical: isTablet ? 20 : 20,
          ),
          child: isTablet
              ? _buildTabletLayout()
              : _buildMobileLayout(),
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDropdownSection(),
        _buildDivider(),
        _buildDateRangeSection(),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildDropdownSection(),
        const SizedBox(height: 16),
        _buildDateRangeSection(),
      ],
    );
  }

  Widget _buildDropdownSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100, width: 1),
      ),
      child: DropdownButton2<String>(
        value: selectedOption,
        underline: const SizedBox(),
        style: AppTextStyles.dateRange.copyWith(
          color: Colors.blue.shade900,
          fontWeight: FontWeight.w600,
        ),
        iconStyleData: IconStyleData(
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.blue.shade700,
          ),
          iconSize: 28,
        ),
        items: [
          "Today",
          "Yesterday",
          "This Month",
          "Last Month",
          "All",
          "Custom",
        ]
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Row(
                  children: [
                    Icon(
                      _getIconForOption(e),
                      size: 18,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(e),
                  ],
                ),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value != null && mounted) {
            _setDateRange(value);
          }
        },
        buttonStyleData: const ButtonStyleData(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade100.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          offset: const Offset(0, -5),
        ),
        menuItemStyleData: MenuItemStyleData(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          overlayColor: MaterialStateProperty.all(
            Colors.blue.shade50.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade100.withOpacity(0.3),
            Colors.blue.shade200,
            Colors.blue.shade100.withOpacity(0.3),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeSection() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDateButton(
          date: selectedStartDate,
          isStart: true,
          icon: Icons.event_outlined,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(
            Icons.arrow_forward_rounded,
            color: Colors.blue.shade400,
            size: 20,
          ),
        ),
        _buildDateButton(
          date: selectedEndDate,
          isStart: false,
          icon: Icons.event_available_outlined,
        ),
      ],
    );
  }

  Widget _buildDateButton({
    required DateTime date,
    required bool isStart,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () => _pickDate(context, isStart),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade500,
              Colors.blue.shade700,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade300.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isStart ? 'Start Date' : 'End Date',
                  style: AppTextStyles.dateRange.copyWith(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('dd MMM yyyy').format(date),
                  style: AppTextStyles.dateRange.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForOption(String option) {
    switch (option) {
      case "Today":
        return Icons.today_rounded;
      case "Yesterday":
        return Icons.history_rounded;
      case "This Month":
        return Icons.calendar_month_rounded;
      case "Last Month": 
        return Icons.calendar_today_rounded; 
      case "All":
        return Icons.all_inclusive_rounded;
      case "Custom":
        return Icons.tune_rounded;
      default:
        return Icons.calendar_month_rounded;
    }
  }
}