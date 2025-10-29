import 'dart:io';
import 'package:cream_ventory/db/models/items/category/category_model.dart';
import 'package:cream_ventory/screen/items/screen/category/screens/category_detail_page.dart';
import 'package:flutter/material.dart';

class CategoryCard extends StatefulWidget {
  const CategoryCard({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
    required this.cat,
    required this.onDelete,
  });

  final double screenHeight;
  final double screenWidth;
  final CategoryModel cat;
  final VoidCallback onDelete;

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _borderAnimation;

  @override
  void initState() {
    super.initState(); 
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _borderAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 10 + (_controller.value * 8), // Dynamic elevation
            shadowColor: Colors.black.withOpacity(0.12 + _controller.value * 0.1),
            margin: EdgeInsets.symmetric(
              vertical: widget.screenHeight * 0.015,
              horizontal: widget.screenWidth * 0.03,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Colors.white, Color(0xFFF8F9FA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Color.lerp(
                    Colors.transparent,
                    const Color(0xFF6C5CE7).withOpacity(0.4),
                    _borderAnimation.value,
                  )!,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color.lerp(
                      Colors.transparent,
                      const Color(0xFF6C5CE7).withOpacity(0.3),
                      _borderAnimation.value,
                    )!,
                    blurRadius: 12 * _borderAnimation.value,
                    spreadRadius: 2 * _borderAnimation.value,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.white.withOpacity(0.1),
                  onTapDown: (_) => _controller.forward(),
                  onTapUp: (_) {
                    _controller.reverse();
                    Navigator.push(
                      context,    
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 400),
                        pageBuilder: (_, __, ___) =>
                            CategoryDetailsPage(category: widget.cat),
                        transitionsBuilder:
                            (_, animation, __, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.95, end: 1.0)
                                  .animate(CurvedAnimation(
                                      parent: animation, curve: Curves.easeOut)),
                              child: child,
                            ),
                          );
                        },
                      ),
                    );
                  },
                  onTapCancel: () => _controller.reverse(),
                  child: Padding(
                    padding: EdgeInsets.all(widget.screenWidth * 0.04),
                    child: Row(
                      children: [
                        Hero(
                          tag: 'category-image-${widget.cat.id}',
                          child: Container(
                            width: widget.screenWidth * 0.20,
                            height: widget.screenWidth * 0.20,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: _buildImageWithFade(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 28),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.cat.name.toUpperCase(),
                                style: TextStyle(
                                  fontSize: widget.screenWidth * 0.05,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'ADLaM',
                                  color: const Color(0xFF2D3436),
                                  letterSpacing: 0.8,
                                  shadows: [
                                    Shadow(
                                      offset: const Offset(0, 1),
                                      blurRadius: 1,
                                      color: Colors.black, 
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ), 
                              const SizedBox(height: 4),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageWithFade() {
    final imageWidget = cat.isAsset
        ? Image.asset(
            cat.imagePath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildErrorIcon(),
          )
        : File(cat.imagePath).existsSync()
            ? Image.file(
                File(cat.imagePath),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildErrorIcon(),
              )
            : _buildErrorIcon();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: imageWidget,
    );
  }

  Widget _buildErrorIcon() {
    return Container(
      key: const ValueKey('error'),
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: widget.screenWidth * 0.10,
          color: Colors.grey[600], 
        ),
      ),
    );
  }

  // Keep reference to avoid rebuild issues
  CategoryModel get cat => widget.cat;
}