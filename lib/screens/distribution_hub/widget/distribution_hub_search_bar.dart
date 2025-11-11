import 'package:flutter/material.dart';

class PartySearchBar extends StatelessWidget {
  final VoidCallback onAddParty;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const PartySearchBar({
    super.key,
    required this.onAddParty,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // --------------------------------------------------------------
    // 1. Detect screen width From this screenWidth it will detect the size of the size 
    //    if the screen width is greater than 600 then the pixel will change for all font , borderRadius
    // --------------------------------------------------------------
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 600;

    // Mobile (≤600px)
    const double mobileSpacing = 8;
    const double mobileIconSize = 20;
    const double mobileBorderRadius = 18;
    const double mobileFontSize = 14;
    const double mobileContentPadding = 12;
    const double mobileVerticalPadding = 12;
    const double mobileHorizontalPadding = 8;
    const double mobileButtonHPadding = 13;

    // Large (>600px) – **all in pixels**, larger
    const double largeSpacing = 12;
    const double largeIconSize = 28;
    const double largeBorderRadius = 24;
    const double largeFontSize = 18;
    const double largeContentPadding = 16;
    const double largeVerticalPadding = 16;
    const double largeHorizontalPadding = 16;
    const double largeButtonHPadding = 20;

    // --------------------------------------------------------------
    // 3. Choose values based on screen size
    // --------------------------------------------------------------
    final double spacing = isLargeScreen ? largeSpacing : mobileSpacing;
    final double iconSize = isLargeScreen ? largeIconSize : mobileIconSize;
    final double borderRadius = isLargeScreen ? largeBorderRadius : mobileBorderRadius;
    final double fontSize = isLargeScreen ? largeFontSize : mobileFontSize;
    final double contentPadding = isLargeScreen ? largeContentPadding : mobileContentPadding;
    final double verticalPadding = isLargeScreen ? largeVerticalPadding : mobileVerticalPadding;
    final double horizontalPadding = isLargeScreen ? largeHorizontalPadding : mobileHorizontalPadding;
    final double buttonHPadding = isLargeScreen ? largeButtonHPadding : mobileButtonHPadding;

    
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding,
        horizontal: horizontalPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Search Parties',
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search, color: Colors.blue, size: iconSize),
                filled: true,
                contentPadding: EdgeInsets.symmetric(vertical: contentPadding),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(fontSize: fontSize),
              onChanged: onChanged,
            ),
          ),
          SizedBox(width: spacing),
          Center( 
            child: ElevatedButton.icon(
              onPressed: onAddParty,
              icon: Icon(Icons.add, size: iconSize, color: Colors.white),
              label: Text(
                'New Party',
                style: TextStyle(fontSize: fontSize, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                elevation: 0,
                padding: EdgeInsets.symmetric(
                  vertical: verticalPadding,
                  horizontal: buttonHPadding,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}