// sale_body_widget.dart
import 'package:cream_ventory/core/theme/theme.dart';
import 'package:flutter/material.dart';

class SaleBodyWidget {
  /// Builds the main body container with a gradient background and fixed bottom buttons
  static Widget buildBody({
    required Size screenSize,
    required List<Widget> scrollableChildren,
    required Widget bottomButtons,
  }) {
    return Container(
      width: screenSize.width,
      height: screenSize.height,
      decoration: const BoxDecoration(gradient: AppTheme.appGradient),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: scrollableChildren,
              ),
            ),
          ),
          bottomButtons,
        ], 
      ),
    );
  }
}