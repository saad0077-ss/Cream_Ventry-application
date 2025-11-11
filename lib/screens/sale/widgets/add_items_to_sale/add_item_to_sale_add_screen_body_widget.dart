// add_item_body_widget.dart
import 'package:cream_ventory/core/theme/theme.dart';
import 'package:flutter/material.dart';

class AddItemBodyWidget {
  /// Builds the main body container with a gradient background
  static Widget buildBody({
    required List<Widget> children,
    required Size screenSize,
  }) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.appGradient),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: screenSize.height - kToolbarHeight - 24.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }
}