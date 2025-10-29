// sale_body_widget.dart
import 'package:cream_ventory/themes/app_theme/theme.dart';
import 'package:flutter/material.dart';

class SaleBodyWidget {
  /// Builds the main body container with a gradient background
  static Widget buildBody({
    required Size screenSize,
    required List<Widget> children,
  }) {
    return SingleChildScrollView(
      child: Container(
        width: screenSize.width,
        height: screenSize.height,
        decoration: const BoxDecoration(gradient: AppTheme.appGradient),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }
}