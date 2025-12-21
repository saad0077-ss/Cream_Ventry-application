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

  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      transform: Matrix4.identity()..scale(isSelected ? 1.08 : 1.0),
      child: Container(
        width: isSmallScreen ? 170 : 250,
        height: isSmallScreen ? 110 : 160,
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    baseColor.shade50,
                    baseColor.shade100.withOpacity(0.7),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
                ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? baseColor.withOpacity(0.3)
                  : Colors.black.withOpacity(0.08),
              spreadRadius: isSelected ? 2 : 0,
              blurRadius: isSelected ? 20 : 12,
              offset: Offset(0, isSelected ? 8 : 4),
            ),
            if (isSelected)
              BoxShadow(
                color: baseColor.withOpacity(0.15),
                spreadRadius: -2,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
          ],
          border: Border.all(
            color: isSelected
                ? baseColor.shade300.withOpacity(0.6)
                : Colors.grey.shade200,
            width: isSelected ? 2.5 : 1.5,
          ),
        ),
        child: Stack(
          children: [
            // Subtle background pattern
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      baseColor.withOpacity(isSelected ? 0.1 : 0.03),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Main content
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 14 : 18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isSelected
                                ? [
                                    baseColor.shade400,
                                    baseColor.shade600,
                                  ]
                                : [
                                    iconColor.withOpacity(0.15),
                                    iconColor.withOpacity(0.25),
                                  ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: baseColor.withOpacity(0.4),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : [],
                        ),
                        child: Icon(
                          icon,
                          color: isSelected ? Colors.white : iconColor,
                          size: isSmallScreen ? 18 : 24,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontFamily: 'ABeeZee',
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? baseColor.shade900
                                : Colors.grey.shade700,
                            letterSpacing: 0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: isSelected
                              ? [baseColor.shade700, baseColor.shade900]
                              : [valueColor, valueColor.withOpacity(0.7)],
                        ).createShader(bounds),
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 20 : 24,
                            fontFamily: 'ABeeZee',
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5, 
                          ),
                        ),
                      ),
                      if (percentage != null && percentageColor != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, 
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: percentageColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            percentage,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 13,
                              fontFamily: 'ABeeZee',
                              color: percentageColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Selection indicator
            if (isSelected)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: baseColor.shade600,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: baseColor.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}    