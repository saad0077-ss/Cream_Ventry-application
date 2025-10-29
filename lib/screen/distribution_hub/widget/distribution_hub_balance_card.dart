import 'package:flutter/material.dart';

Widget buildSummaryCard({
  required IconData icon,
  required Color iconColor,
  required String title,
  required String value,
  required Color valueColor,
  String? percentage,
  Color? percentageColor,
  required bool isSmallScreen,
  required VoidCallback onTap,
  String? currentFilter,
}) {
  // Define base colors
  final isGetCard = title == "You'll Get";
  final isGiveCard = title == "You'll Give";
  // Determine if the card is selected based on the current filter
  final isSelected = (isGetCard && currentFilter == 'get') || (isGiveCard && currentFilter == 'give');

  final baseColor = isGetCard ? Colors.green : Colors.red;
  final nonSelectedColor = Colors.white;

  // Determine card color based on filter state and selection
  final cardColor = isSelected ? baseColor.shade50 : nonSelectedColor;

  return GestureDetector(
    onTap: onTap, // Handle tap
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      // Scale down slightly when not selected to enhance the selected card
      transform: Matrix4.identity()..scale(isSelected ? 1.05 : 1.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        // Enhance shadow effect
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isSelected ? 0.15 : 0.05),
            spreadRadius: isSelected ? 3 : 1,
            blurRadius: isSelected ? 10 : 5,
            offset: const Offset(0, 4),
          ),
        ],
        // Add a subtle border when selected
        border: isSelected
            ? Border.all(color: baseColor.shade400, width: 2)
            : null,
      ),
      child: Container(
        width: isSmallScreen ? 170 : 250,
        height: isSmallScreen ? 100 : 150, 
        padding: const EdgeInsets.all(13), // Slightly increased padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [ 
            Row(
              children: [
                // Animated icon container
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(10), // Slightly larger padding
                  decoration: BoxDecoration(
                    // More vivid color for selected state
                    color: isSelected ? baseColor.withOpacity(0.5) : iconColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: isSmallScreen ? 16 : 23, // Slightly larger icon
                  ),
                ),
                const SizedBox(width: 8), // Increased space
                Expanded(
                  child: Text( 
                    title,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 15 : 17,
                      fontFamily: 'ABeeZee',
                      fontWeight: FontWeight.w700, // Slightly bolder title
                      color: Colors.grey[800],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Value text
            Text(
              value,
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 20, // Larger value text
                fontFamily: 'ABeeZee',
                fontWeight: FontWeight.w900, // Extra bold for the value
                color: valueColor,
              ),
            ),
            // Percentage text
            if (percentage != null && percentageColor != null) ...[
              const SizedBox(height: 2),
              Text(   
                percentage,
                style: TextStyle(
                  fontSize: isSmallScreen ? 13 : 15, // Slightly larger percentage text
                  fontFamily: 'ABeeZee',
                  color: percentageColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}