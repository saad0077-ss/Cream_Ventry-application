import 'package:cream_ventory/core/constants/font_helper.dart';
import 'package:flutter/material.dart';

class SummaryCard extends StatefulWidget {
  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.gradientColors,
  });

  final String title;
  final String value;
  final IconData? icon;
  final List<Color>? gradientColors;

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final gradientColors = widget.gradientColors ??
        [
          Colors.blue.shade400,
          Colors.blue.shade600,
        ];

    return Expanded(
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _isHovered = true);
          _controller.forward();
        },
        onExit: (_) {
          setState(() => _isHovered = false);
          _controller.reverse();
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Card(
            elevation: _isHovered ? 12 : 6,
            shadowColor: gradientColors.first.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors.first.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -10,
                    bottom: -10,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: EdgeInsets.all(isTablet ? 28.0 : 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon
                        if (widget.icon != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              widget.icon,
                              color: Colors.white,
                              size: isTablet ? 28 : 24,
                            ),
                          ),
                        SizedBox(height: widget.icon != null ? 16 : 8),
                        // Title
                        Text(
                          widget.title,
                          style: AppTextStyles.summaryCard.copyWith(
                            fontSize: isTablet ? 18 : 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.95),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Value
                        Text(
                          widget.value,
                          style: AppTextStyles.summaryCard.copyWith(
                            fontSize: isTablet ? 32 : 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ], 
              ),
            ),
          ),
        ),
      ),
    );
  }
}