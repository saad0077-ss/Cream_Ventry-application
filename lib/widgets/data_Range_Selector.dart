import 'package:cream_ventory/core/constants/font_helper.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangeSelector extends StatefulWidget {
  final void Function(DateTime startDate, DateTime endDate)? onDateRangeChanged;

  const DateRangeSelector({super.key, this.onDateRangeChanged});

  @override
  // ignore: library_private_types_in_public_api
  _DateRangeSelectorState createState() => _DateRangeSelectorState();
}

class _DateRangeSelectorState extends State<DateRangeSelector> {
  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now();
  String selectedOption = "This Month";

  @override
  void initState() {
    super.initState();
    _setDateRange("This Month");
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    // Store the context to ensure it's not stale
    final currentContext = context;
    if (!mounted) return; // Early exit if not mounted

    DateTime? pickedDate = await showDatePicker(
      context: currentContext,
      initialDate: isStart ? selectedStartDate : selectedEndDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
            // Arbitrarily wide date range to include everything
            selectedStartDate = DateTime(2000);
            selectedEndDate = DateTime(2100);
            break;
          case "Custom":
            // Do nothing, wait for user selection
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
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        // Prevent navigation issues while date picker is open
        if (Navigator.of(context).userGestureInProgress) {
          return false; // Wait for user interaction to complete
        }
        return true;
      },
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.grey, blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            DropdownButton2<String>(
              value: selectedOption,
              style: AppTextStyles.dateRange,
              items:
                  [
                        "Today",
                        "Yesterday",
                        "This Month",
                        "Last Month",
                        "All",
                        "Custom",
                      ]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              onChanged: (value) {
                if (value != null && mounted) {
                  _setDateRange(value);
                }
              },
              buttonStyleData: ButtonStyleData(
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              dropdownStyleData: DropdownStyleData(
                maxHeight: 200, // optional, max height of dropdown menu
              ),
            ),
            const VerticalDivider(color: Colors.black),
            Row(
              children: [
                GestureDetector(
                  onTap: () => _pickDate(context, true),
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(selectedStartDate),
                    style: AppTextStyles.dateRange,
                  ),
                ),
                const SizedBox(width: 8),
                Text("To", style: AppTextStyles.dateRangeTo),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _pickDate(context, false),
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(selectedEndDate),
                    style: AppTextStyles.dateRange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
