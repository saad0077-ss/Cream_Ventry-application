// lib/utils/pdf/pdf_export.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as uhtml;
import 'package:intl/intl.dart';

// ──────────────────────────────────────────────────────────────
// COOL PDF EXPORTER with modern design + branding
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
  Color? accentColor, // Optional custom accent color
  String? companyName, // Optional company name
}) async {
  // ------------------- Spinner -------------------
  final overlay = OverlayEntry(
    builder: (_) => Container(
      color: Colors.black45,
      child: const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 48, height: 48, child: CircularProgressIndicator(strokeWidth: 3)),
                SizedBox(height: 16),
                Text('Generating PDF...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  Overlay.of(context).insert(overlay);

  try {
    // ------------------- Fonts -------------------
    final regular = pw.Font.ttf(await rootBundle.load(fontAsset));
    final bold = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf'));

    // ------------------- Load App Icon -------------------
    final iconData = await rootBundle.load('assets/icon/Designer.png');
    final iconImage = pw.MemoryImage(iconData.buffer.asUint8List());

    // ------------------- Calculate totals -------------------
    final rows = items.map(rowBuilder).toList();
    double total = 0.0;
    if (amountColumnIndex >= 0 && amountColumnIndex < headers.length) {
      for (final r in rows) {
        final cell = r[amountColumnIndex].replaceAll(RegExp(r'[^0-9\.\-]'), '');
        total += double.tryParse(cell) ?? 0.0;
      }
    }

    // ------------------- Color scheme -------------------
    final primaryColor = accentColor != null
        ? PdfColor.fromInt(accentColor.value)
        : PdfColors.indigo700;
    final accentLight = PdfColors.indigo50;
    final textDark = PdfColors.grey900;
    final textMuted = PdfColors.grey600;

    // ------------------- PDF Document -------------------
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateFormat = DateFormat('MMMM dd, yyyy • hh:mm a');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // ═══════════════════ BRANDED HEADER SECTION ═══════════════════
          pw.Container(
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [primaryColor, PdfColors.indigo900],
                begin: pw.Alignment.topLeft,
                end: pw.Alignment.bottomRight,
              ),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
              boxShadow: [
                pw.BoxShadow(
                  color: PdfColors.grey400,
                  offset: const PdfPoint(0, 4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // ─── App Icon ───
                pw.Container(
                  width: 60,
                  height: 60,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white, 
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                    
                  ),
                  child: pw.ClipRRect(   
                    horizontalRadius: 12,
                    verticalRadius: 12,
                    child: pw.Image(iconImage, fit: pw.BoxFit.cover),
                  ),
                ),
                pw.SizedBox(width: 20),

                // ─── Title & Info ───
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (companyName != null) ...[
                        pw.Text(
                          companyName,
                          style: pw.TextStyle(
                            font: bold,
                            fontSize: 12,
                            color: PdfColors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                      ],
                      pw.Text(
                        title.toUpperCase(),
                        style: pw.TextStyle(
                          font: bold,
                          fontSize: 26,
                          color: PdfColors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        periodInfo,
                        style: pw.TextStyle(
                          font: regular,
                          fontSize: 13,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // ─── Record Badge ───
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                    border: pw.Border.all(color: PdfColors.white, width: 1),
                  ),   
                  child: pw.Column(
                    children: [
                      pw.Text(
                        '${items.length}',
                        style: pw.TextStyle(
                          font: bold,
                          fontSize: 24,
                          color: PdfColors.black ,
                        ),
                      ),
                      pw.Text(
                        'Records',
                        style: pw.TextStyle(
                          font: regular,
                          fontSize: 10,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 32),

          // ═══════════════════ TABLE SECTION ═══════════════════
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300, width: 1),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              boxShadow: [
                pw.BoxShadow(
                  color: PdfColors.grey200,
                  offset: const PdfPoint(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: pw.Table(
              border: pw.TableBorder.symmetric(
                inside: const pw.BorderSide(color: PdfColors.grey200, width: 0.5),
              ),
              defaultColumnWidth: const pw.FlexColumnWidth(),
              children: [
                // ─── Header Row ───
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: accentLight,
                    borderRadius: const pw.BorderRadius.only(
                      topLeft: pw.Radius.circular(8),
                      topRight: pw.Radius.circular(8),
                    ),
                  ),
                  children: headers
                      .map((h) => pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                            child: pw.Text(
                              h.toUpperCase(),
                              style: pw.TextStyle(
                                font: bold,
                                fontSize: 11,
                                color: primaryColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ))
                      .toList(),
                ),

                // ─── Data Rows ───
                ...rows.asMap().entries.map((e) {
                  final idx = e.key;
                  final row = e.value;
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: idx % 2 == 0 ? PdfColors.white : PdfColors.grey50,
                    ),
                    children: row.asMap().entries.map((entry) {
                      final colIdx = entry.key;
                      final cell = entry.value;
                      final isAmountCol = colIdx == amountColumnIndex;

                      return pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        child: pw.Text(
                          cell,
                          style: pw.TextStyle(
                            font: isAmountCol ? bold : regular,
                            fontSize: 11,
                            color: isAmountCol ? textDark : textMuted,
                          ),
                          textAlign: isAmountCol ? pw.TextAlign.right : pw.TextAlign.left,
                        ),
                      );
                    }).toList(),
                  );
                }),
              ],
            ),
          ),

          // ═══════════════════ TOTAL SECTION ═══════════════════
          if (amountColumnIndex >= 0) ...[
            pw.SizedBox(height: 24),
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                gradient: pw.LinearGradient(
                  colors: [accentLight, PdfColors.white],
                  begin: pw.Alignment.topLeft,
                  end: pw.Alignment.bottomRight,
                ),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                border: pw.Border.all(color: primaryColor, width: 2),
                boxShadow: [
                  pw.BoxShadow(
                    color: PdfColors.grey300,
                    offset: const PdfPoint(0, 2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL AMOUNT',
                    style: pw.TextStyle(
                      font: bold,
                      fontSize: 16,
                      color: textDark,
                      letterSpacing: 1,
                    ),
                  ),
                  pw.Text(
                    NumberFormat.currency(symbol: '\$').format(total),
                    style: pw.TextStyle(
                      font: bold,
                      fontSize: 24,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],

          pw.SizedBox(height: 32),

          // ═══════════════════ FOOTER SECTION ═══════════════════
          pw.Divider(color: PdfColors.grey300, thickness: 1),
          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    width: 32,
                    height: 32,
                    decoration: pw.BoxDecoration(
                      color: accentLight,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                    ),
                    child: pw.ClipRRect(
                      horizontalRadius: 6,
                      verticalRadius: 6,
                      child: pw.Image(iconImage, fit: pw.BoxFit.cover),
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Generated on',
                        style: pw.TextStyle(font: regular, fontSize: 9, color: textMuted),
                      ),
                      pw.Text(
                        dateFormat.format(now),
                        style: pw.TextStyle(font: bold, fontSize: 10, color: textDark),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: pw.BoxDecoration(
                  color: accentLight,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  border: pw.Border.all(color: primaryColor.flatten(), width: 1),
                ),
                child: pw.Text(
                  'Confidential Report',
                  style: pw.TextStyle(
                    font: bold,
                    fontSize: 9,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 16),
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(font: regular, fontSize: 9, color: textMuted),
          ),
        ),
      ),
    );

    final pdfBytes = await pdf.save();

    // ────────────────────── PLATFORM HANDLING ──────────────────────
    if (kIsWeb) {
      // ─── WEB: Download + Preview ───
      final blob = uhtml.Blob([pdfBytes], 'application/pdf');
      final url = uhtml.Url.createObjectUrlFromBlob(blob);
      final fileName = '${title.toLowerCase().replaceAll(' ', '_')}_${now.millisecondsSinceEpoch}.pdf';

      uhtml.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();

      uhtml.window.open(url, '_blank');
      uhtml.Url.revokeObjectUrl(url);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('PDF generated successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      // ─── MOBILE: Save + Open ───
      final dir = await getTemporaryDirectory();
      final fileName = '${title.toLowerCase().replaceAll(' ', '_')}_${now.millisecondsSinceEpoch}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(pdfBytes);
      await OpenFile.open(file.path);
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Export failed: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  } finally {
    overlay.remove();
  }
}