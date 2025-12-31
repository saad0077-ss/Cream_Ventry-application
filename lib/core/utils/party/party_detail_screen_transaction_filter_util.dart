import 'package:cream_ventory/screens/party/widgets/party_detail_screen_transaction_card.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class TransactionFilterUtils {
  static List<TransactionItem> applyFilters(
    List<TransactionItem> list,
    Set<String> selectedTypes,
    DateTimeRange? dateRange,
  ) {
    var filtered =
        list.where((item) => selectedTypes.contains(item.type)).toList();

    if (dateRange != null) {
      filtered = filtered.where((item) {
        final itemDate = DateFormat('dd MMM yyyy').parse(item.date);
        return itemDate.isAfter(dateRange.start.subtract(Duration(days: 1))) &&
            itemDate.isBefore(dateRange.end.add(Duration(days: 1)));
      }).toList();
    }

    return filtered;
  }

  static List<TransactionItem> sortByDate(List<TransactionItem> list) {
    list.sort(
      (a, b) => DateFormat('dd MMM yyyy').parse(b.date).compareTo(
            DateFormat('dd MMM yyyy').parse(a.date),
          ),
    );
    return list;
  }
}    