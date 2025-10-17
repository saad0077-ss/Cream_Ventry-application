// utils/date_filter.dart
List<T> filterAndSortByDate<T>(
  List<T> items,
  DateTime startDate,
  DateTime endDate, {
  required DateTime Function(T) getDate,
}) {
  // Filter items by date range
  final filteredItems = items.where((item) {
    final itemDate = getDate(item);
    return itemDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
        itemDate.isBefore(endDate.add(const Duration(days: 1)));
  }).toList();

  // Sort items by date (ascending)
  filteredItems.sort((a, b) => getDate(a).compareTo(getDate(b)));

  return filteredItems;
}