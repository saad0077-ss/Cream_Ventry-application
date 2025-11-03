// lib/utils/pdf/pdf_export.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// ──────────────────────────────────────────────────────────────
// NEW: universal_html – works everywhere, only active on web
// ──────────────────────────────────────────────────────────────
import 'package:universal_html/html.dart' as uhtml;
 
// ──────────────────────────────────────────────────────────────
// Generic PDF exporter – works for every report
// ──────────────────────────────────────────────────────────────
Future<void> exportReportToPdf<T>({
  required BuildContext context,
  required String title,
  required String periodInfo,
  required List<String> headers,
  required List<T> items,   
  required List<String> Function(T) rowBuilder,
  int amountColumnIndex = -1,
  String fontAsset = 'assets/fonts/Roboto-Regular.ttf',
}) async {
  // ------------------- spinner -------------------
  final overlay = OverlayEntry(
    builder: (_) => const Center(
      child: SizedBox(width: 36, height: 36, child: CircularProgressIndicator(strokeWidth: 2)),
    ),
  );
  Overlay.of(context).insert(overlay);

  try {
    // ------------------- fonts -------------------
    final regular = pw.Font.ttf(await rootBundle.load(fontAsset));
    final bold = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf'));

    // ------------------- data + total -------------------
    final rows = items.map(rowBuilder).toList();
    double total = 0.0;
    if (amountColumnIndex >= 0 && amountColumnIndex < headers.length) {
      for (final r in rows) {
        final cell = r[amountColumnIndex].replaceAll(RegExp(r'[^0-9\.\-]'), '');
        total += double.tryParse(cell) ?? 0.0;
      }
    }

    // ------------------- PDF document -------------------
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(title,
                    style: pw.TextStyle(font: bold, fontSize: 26, color: PdfColors.blue900)),
                pw.Text(periodInfo,
                    style: pw.TextStyle(font: regular, fontSize: 14, color: PdfColors.grey800)),
              ],
            ),
            pw.SizedBox(height: 24),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: .5),
              defaultColumnWidth: const pw.FlexColumnWidth(),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: headers
                      .map((h) => pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                            child: pw.Text(h,
                                style: pw.TextStyle(font: bold, fontSize: 13, color: PdfColors.grey900)),
                          ))
                      .toList(),
                ),
                ...rows.asMap().entries.map((e) {
                  final idx = e.key;
                  final row = e.value;
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(
                        color: idx % 2 == 0 ? PdfColors.grey50 : PdfColors.white),
                    children: row
                        .map((cell) => pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                              child: pw.Text(cell, style: pw.TextStyle(font: regular, fontSize: 12)),
                            ))
                        .toList(),
                  );
                }),
                pw.TableRow(
                  children: List.filled(headers.length,
                       pw.Divider(height: 2, thickness: 2, color: PdfColors.grey600)),
                ),
                if (amountColumnIndex >= 0)
                  pw.TableRow(
                    children: List.generate(headers.length, (i) {
                      if (i == amountColumnIndex) {
                        return pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                          child: pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text('Total: ${total.toStringAsFixed(2)}',
                                style: pw.TextStyle(font: bold, fontSize: 13, color: PdfColors.blue900)),
                          ),
                        );
                      }
                      return  pw.SizedBox();
                    }),
                  ),
              ],
            ),
          ],
        ),
      ),
    );

    final pdfBytes = await pdf.save();

    // ────────────────────── PLATFORM HANDLING ──────────────────────
    if (kIsWeb) {
      // ─── WEB: Use universal_html (no conditional import needed) ───
      final blob = uhtml.Blob([pdfBytes], 'application/pdf');
      final url = uhtml.Url.createObjectUrlFromBlob(blob);
      final fileName = '${title.toLowerCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      uhtml.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();

      uhtml.window.open(url, '_blank');
      uhtml.Url.revokeObjectUrl(url);
    } else {
      // ─── MOBILE: Save + open ───
      final dir = await getTemporaryDirectory();
      final fileName = '${title.toLowerCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(pdfBytes);
      await OpenFile.open(file.path);
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.red),
      );
    }
  } finally {
    overlay.remove();
  }
}