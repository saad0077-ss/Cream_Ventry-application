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
  final isGetCard = title == "You'll Get";
  final isGiveCard = title == "You'll Give";
  final isSelected = (isGetCard && currentFilter == 'get') || (isGiveCard && currentFilter == 'give');

  final baseColor = isGetCard ? Colors.green : Colors.red;
  final nonSelectedColor = Colors.white;

  final cardColor = isSelected ? baseColor.shade50 : nonSelectedColor;

  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      transform: Matrix4.identity()..scale(isSelected ? 1.05 : 1.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isSelected ? 0.15 : 0.05),
            spreadRadius: isSelected ? 3 : 1,
            blurRadius: isSelected ? 10 : 5,
            offset: const Offset(0, 4),
          ),
        ],
    
        border: isSelected
            ? Border.all(color: baseColor.shade400, width: 2)
            : null,
      ),
      child: Container(
        width: isSmallScreen ? 170 : 250,
        height: isSmallScreen ? 100 : 150, 
        padding: const EdgeInsets.all(13),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [ 
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected ? baseColor.withOpacity(0.5) : iconColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: isSmallScreen ? 16 : 23, 
                  ),
                ),
                const SizedBox(width: 8), 
                Expanded(
                  child: Text( 
                    title,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 15 : 17,
                      fontFamily: 'ABeeZee',
                      fontWeight: FontWeight.w700, 
                      color: Colors.grey[800],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 20, 
                fontFamily: 'ABeeZee',
                fontWeight: FontWeight.w900, 
                color: valueColor,
              ),
            ),
            if (percentage != null && percentageColor != null) ...[
              const SizedBox(height: 2),
              Text(   
                percentage,
                style: TextStyle(
                  fontSize: isSmallScreen ? 13 : 15, 
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