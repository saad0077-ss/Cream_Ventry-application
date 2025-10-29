// lib/widgets/report_list_container.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

typedef ItemWidgetBuilder<T> = Widget Function(BuildContext context, T item, int index);

class ReportListContainer<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final ItemWidgetBuilder<T> itemBuilder;
  final VoidCallback onExportPressed;   // PDF button callback
  final bool isEmpty;

  const ReportListContainer({
    super.key,
    required this.title,
    required this.items,
    required this.itemBuilder,
    required this.onExportPressed,
    this.isEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blueGrey, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Header + Export button ----
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                height: 36,
                child: ElevatedButton.icon(
                  onPressed: onExportPressed,
                  icon: const Icon(Icons.picture_as_pdf, size: 18),
                  label: Text('Generate', style: TextStyle(fontSize: 13.r)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      side: const BorderSide(color: Colors.black26),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ---- List or empty message ----
          isEmpty || items.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No data found in this date range',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (ctx, i) => itemBuilder(ctx, items[i], i),
                ),
        ],
      ),
    );
  }
}