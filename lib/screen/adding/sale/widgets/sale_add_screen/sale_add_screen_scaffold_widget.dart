// sale_scaffold_widget.dart
import 'package:cream_ventory/widgets/app_bar.dart';
import 'package:flutter/material.dart';

class SaleScaffoldWidget {
  /// Builds the main scaffold for the sale screen
  static Widget buildScaffold({
    required String title,
    required VoidCallback onBackPressed,
    required Widget body,
  }) {
    return Scaffold(
      appBar: CustomAppBar(
        title: title,
        fontSize: 30,
        onBackPressed: onBackPressed,
      ),
      body: body,
    );
  }
}