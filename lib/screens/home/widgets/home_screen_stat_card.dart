import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatCard<T> extends StatelessWidget {
  final String title; // Card title (e.g., "Total Products")
  final ValueListenable<T> valueListenable; // Reactive data source
  final String Function(T) valueBuilder; // Converts value to display string
  final TextStyle? titleStyle; // Optional title style override
  final TextStyle? valueStyle; // Optional value style override
  final IconData? icon; // Optional icon next to title
  final double blurSigma; // Blur intensity for BackdropFilter
  final EdgeInsets padding; // Custom padding
  final double borderRadius; // Corner radius
  final Color? backgroundColor; // Optional background color override

  const StatCard({
    super.key,
    required this.title,
    required this.valueListenable,
    required this.valueBuilder,
    this.titleStyle,
    this.valueStyle,
    this.icon,
    this.blurSigma = 10.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 18 , vertical: 16), 
    this.borderRadius = 16.0,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {    
    return Card(
      elevation: 5, // No elevation to emphasize blur
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(color: Colors.black.withOpacity(0.3), width: 1),
      ),  
      clipBehavior: Clip.antiAlias,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),  
          ], 
            
            ),
            child: Padding(
              padding: padding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [  
                        ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 5,
                              sigmaY: 5,
                            ), 
                            child: Container( 
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.transparent,
                              ),
                              child: AnimatedScale(
                                scale: 1.2, // Placeholder for future animation    
                                duration: const Duration(milliseconds: 200), 
                                child: Icon(
                                  icon,
                                  size: 20.r,
                                  color: const Color(0xFF8B0000), // Deep Crimson Red
                                ),
                              ),
                            ),
                          ),
                        ),
                         SizedBox(width: 2.w), // Space between icon and title
                        Expanded(
                          child: Text(
                            title,
                            style: titleStyle ??
                                TextStyle( 
                                  fontSize: 12.r,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  letterSpacing: 0.5,
                                ),
                          ), 
                        ),
                      ],
                    ),
                     SizedBox(height: 5.h),
                  ] else ...[
                    Text(
                      title,
                      style: titleStyle ??
                          TextStyle(
                            fontFamily: 'ABeeZee',
                            fontSize: 12.r,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                offset: const Offset(1, 1),
                                blurRadius: 9,
                              ),
                            ],
                          ),
                    ),
                     SizedBox(height: 8.h),
                  ],
                  ValueListenableBuilder<T>(
                    valueListenable: valueListenable,
                    builder: (context, value, _) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: Text(
                          valueBuilder(value),
                          key: ValueKey(value),
                          style: valueStyle ??
                               TextStyle(
                                fontSize: 24.r, 
                                fontWeight: FontWeight.w900,
                                fontFamily: 'ABeeZee',
                                color: Colors.black,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(1, 1),
                                    blurRadius: 3,
                                  ), 
                                ],
                              ),
                        ),
                      );
                    },
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