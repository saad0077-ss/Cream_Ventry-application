import 'package:flutter/material.dart';

class PartySearchBar extends StatefulWidget {
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
  State<PartySearchBar> createState() => _PartySearchBarState();
}

class _PartySearchBarState extends State<PartySearchBar> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 600;

    // Mobile values
    const double mobileSpacing = 10;
    const double mobileIconSize = 20;
    const double mobileBorderRadius = 16;
    const double mobileFontSize = 14;
    const double mobileContentPadding = 14;
    const double mobileVerticalPadding = 14;
    const double mobileHorizontalPadding = 12;
    const double mobileButtonHPadding = 16;

    // Large screen values
    const double largeSpacing = 14;
    const double largeIconSize = 24;
    const double largeBorderRadius = 20;
    const double largeFontSize = 16;
    const double largeContentPadding = 16;
    const double largeVerticalPadding = 16;
    const double largeHorizontalPadding = 16;
    const double largeButtonHPadding = 24;

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
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: widget.controller,
                decoration: InputDecoration(
                  hintText: 'Search Parties',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w400,
                  ),
                  fillColor: Colors.white,
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade400,
                          Colors.blue.shade600,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.search_rounded,
                      color: Colors.white,
                      size: iconSize - 4,
                    ),
                  ),
                  suffixIcon: widget.controller?.text.isNotEmpty ?? false
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: Colors.grey.shade400,
                            size: iconSize,
                          ),
                          onPressed: () {
                            widget.controller?.clear();
                            widget.onChanged?.call('');
                          },
                        )
                      : null,
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: contentPadding,
                    horizontal: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(
                      color: Colors.blue.shade400,
                      width: 2,
                    ),
                  ),
                ),
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
                onChanged: widget.onChanged,
              ),
            ),
          ),
          SizedBox(width: spacing),
          MouseRegion(
            onEnter: (_) {
              setState(() => _isHovered = true);
              _animationController.forward();
            },
            onExit: (_) {
              setState(() => _isHovered = false);
              _animationController.reverse();
            },
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _isHovered
                        ? [Colors.blue.shade600, Colors.blue.shade800]
                        : [Colors.blueGrey.shade600, Colors.blueGrey.shade700],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isHovered
                          ? Colors.blue.withOpacity(0.4)
                          : Colors.blueGrey.withOpacity(0.3),
                      blurRadius: _isHovered ? 20 : 12,
                      offset: Offset(0, _isHovered ? 6 : 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: widget.onAddParty,
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      size: iconSize,
                      color: Colors.white,
                    ),
                  ),
                  label: Text(
                    'New Party',
                    style: TextStyle(
                      fontSize: fontSize,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
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
            ),
          ),
        ],
      ),
    );
  }
}