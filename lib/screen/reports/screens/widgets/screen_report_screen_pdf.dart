// lib/utils/pdf/pdf_export.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

typedef RowBuilder<T> = List<String> Function(T item);

/// Generic PDF exporter – beautiful table + total row
Future<void> exportListToPdf<T>({
  required BuildContext context,
  required String title,
  required String periodInfo,
  required List<String> headers,
  required List<T> items,
  required RowBuilder<T> rowBuilder,
  // Optional: column index that contains the numeric amount (default = last column)
  int amountColumnIndex = -1,
  String fontAsset = 'assets/fonts/Roboto-Regular.ttf',
}) async {
  if (items.isEmpty) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('No data to export')));
    return;
  }

  // -----------------------------------------------------------------
  // 1. Load font
  // -----------------------------------------------------------------
  final fontData = await rootBundle.load(fontAsset);
  final ttf = pw.Font.ttf(fontData);
  final boldTtf = pw.Font.ttf(
    await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
  );

  // -----------------------------------------------------------------
  // 2. Prepare data + calculate total (only if amount column is given)
  // -----------------------------------------------------------------
  final List<List<String>> rows = items.map(rowBuilder).toList();

  double total = 0.0;
  if (amountColumnIndex >= 0 && amountColumnIndex < headers.length) {
    for (final row in rows) {
      final cell = row[amountColumnIndex].replaceAll(RegExp(r'[^0-9\.\-]'), '');
      if (cell.isNotEmpty) {
        total += double.tryParse(cell) ?? 0.0;
      }
    }
  }

  // -----------------------------------------------------------------
  // 3. Build the PDF
  // -----------------------------------------------------------------
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // ---- Title -------------------------------------------------
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  font: boldTtf,
                  fontSize: 26,
                  color: PdfColors.blue900,
                ),     
              ),
              pw.SizedBox(width: 8),       

              // ---- Period info -------------------------------------------
              pw.Text(
                periodInfo,
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 14,
                  color: PdfColors.grey800,
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 24),

          // ---- Table -------------------------------------------------
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            defaultColumnWidth: const pw.FlexColumnWidth(),
            columnWidths: {}, // let pw decide equal width
            children: [
              // Header row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: headers
                    .map(
                      (h) => pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 6,
                        ),
                        child: pw.Text(
                          h,
                          style: pw.TextStyle(
                            font: boldTtf,
                            fontSize: 13,
                            color: PdfColors.grey900,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),

              // Data rows – zebra striping
              ...rows.asMap().entries.map((entry) {
                final idx = entry.key;
                final row = entry.value;
                final isEven = idx % 2 == 0;

                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: isEven ? PdfColors.grey50 : PdfColors.white,
                  ),
                  children: row
                      .map(
                        (cell) => pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 6,
                          ),
                          child: pw.Text(
                            cell,
                            style: pw.TextStyle(font: ttf, fontSize: 12),
                          ),
                        ),
                      )
                      .toList(),
                );
              }),

              // ---- Divider before total ---------------------------------
              pw.TableRow(
                children: [
                  pw.Divider(height: 2, thickness: 2, color: PdfColors.grey600),
                  ...List.filled(
                    headers.length - 1,
                    pw.Divider(
                      height: 2,
                      thickness: 2,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),

              // ---- Total row --------------------------------------------
              if (amountColumnIndex >= 0)
                pw.TableRow(
                  children: List.generate(headers.length, (i) {
                    if (i == amountColumnIndex) {
                      return pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 6,
                        ),
                        child: pw.Align(
                          alignment: pw.Alignment.centerRight,
                          child: pw.Text(
                            'Total: ${total.toStringAsFixed(2)}',
                            style: pw.TextStyle(
                              font: boldTtf,
                              fontSize: 13,
                              color: PdfColors.blue900,
                            ),
                          ),
                        ),
                      );
                    }
                    return pw.SizedBox(); // empty cell
                  }),
                ),
            ],
          ),
        ],
      ),
    ),
  );

  // -----------------------------------------------------------------
  // 4. Save & open
  // -----------------------------------------------------------------
  try {
    final dir = await getTemporaryDirectory();
    final fileName =
        '${title.toLowerCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('PDF saved!'),
        backgroundColor: Colors.blueGrey,
        action: SnackBarAction(
          label: 'Open',
          textColor: Colors.white,
          onPressed: () => OpenFile.open(file.path),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $e'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
      ),
    );
  }
}
