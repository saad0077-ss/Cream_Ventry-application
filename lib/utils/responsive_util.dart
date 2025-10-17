import 'package:flutter/material.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockWidth;
  static late double blockHeight;
  static late double textMultiplier;
  static late double imageSizeMultiplier;             
  static late double heightMultiplier;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;

    blockWidth = screenWidth / 100;
    blockHeight = screenHeight / 100;

    textMultiplier = blockHeight;
    imageSizeMultiplier = blockWidth;
    heightMultiplier = blockHeight;   
  }

  /// Example usage:
  /// double width = SizeConfig.blockWidth * 30; // 30% of screen width
  /// double height = SizeConfig.blockHeight * 20; // 20% of screen height
  /// double text = SizeConfig.textMultiplier * 2.5; // Scaled text size
}

enum DeviceType { mobile, tablet, desktop }

class LayoutBuilderHelper { 
  // Breakpoints for different device types
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1200;
  static const double desktopBreakpoint = 1440;

  // Get device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < tabletBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }


  // Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return const EdgeInsets.all(8.0);
      case DeviceType.tablet:
        return const EdgeInsets.all(16.0);
      case DeviceType.desktop:
        return const EdgeInsets.all(24.0);
    }
  }

  // Get responsive font size
  static double getResponsiveFontSize(
    BuildContext context, {
    required double baseFontSize,
  }) {
    final double scaleFactor = getScaleFactor(context);
    return baseFontSize * scaleFactor;
  }

  // Get scale factor based on screen width
  static double getScaleFactor(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return width / 400; // Base scale for mobile
      case DeviceType.tablet:
        return width / 800; // Base scale for tablet
      case DeviceType.desktop:
        return width / 1200; // Base scale for desktop
    }
  }

  // Get responsive widget size
  static double getResponsiveSize(
    BuildContext context, {
    required double baseSize,
  }) {
    final double scaleFactor = getScaleFactor(context);
    return baseSize * scaleFactor;
  }

  // Build responsive layout
  static Widget buildResponsiveLayout({
    required BuildContext context,
    required Widget mobileLayout,
    required Widget tabletLayout,
    required Widget desktopLayout,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        switch (getDeviceType(context)) {
          case DeviceType.mobile:
            return mobileLayout;
          case DeviceType.tablet:
            return tabletLayout;
          case DeviceType.desktop:
            return desktopLayout;
        }
      },
    );
  }

  // Get responsive constraints
  static BoxConstraints getResponsiveConstraints(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return BoxConstraints(maxWidth: width * 0.9);
      case DeviceType.tablet:
        return BoxConstraints(maxWidth: width * 0.8);
      case DeviceType.desktop:
        return BoxConstraints(maxWidth: width * 0.7);
    }
  }

  // Get responsive text style
  static TextStyle getResponsiveTextStyle(
    BuildContext context, {
    required TextStyle baseStyle,
  }) {
    final double fontSize = getResponsiveFontSize(
      context,
      baseFontSize: baseStyle.fontSize ?? 16,
    );
    return baseStyle.copyWith(fontSize: fontSize);
  }
}
