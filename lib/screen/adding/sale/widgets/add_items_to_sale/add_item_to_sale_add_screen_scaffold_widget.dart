// add_item_scaffold_widget.dart
import 'package:cream_ventory/widgets/app_bar.dart';
import 'package:flutter/material.dart';

class AddItemScaffoldWidget {
  /// Builds the main scaffold for the add item to sale screen
  static Widget buildScaffold({
    required String title,
    required Widget body,
  }) {
    return Scaffold(
      appBar: CustomAppBar(
        title: title,
      ),
      body: body,
    );
  }
}