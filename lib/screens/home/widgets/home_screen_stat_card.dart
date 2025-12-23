import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatCard<T> extends StatelessWidget {
  final String title;
  final ValueListenable<T> valueListenable;
  final String Function(T) valueBuilder;
  final TextStyle? titleStyle;
  final TextStyle? valueStyle;
  final IconData? icon;
  final double blurSigma;
  final EdgeInsets padding;
  final double borderRadius;
  final Color? backgroundColor;
  final List<Color>? gradientColors;

  const StatCard({
    super.key,
    required this.title,
    required this.valueListenable,
    required this.valueBuilder,
    this.titleStyle,
    this.valueStyle,
    this.icon,
    this.blurSigma = 10.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    this.borderRadius = 16.0,
    this.backgroundColor, 
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {

    final islargeScreen = MediaQuery.of(context).size.width > 600;
    final isSmallScreen = MediaQuery.of(context).size.width <= 350;
    
    final defaultGradient = [
      Colors.white.withOpacity(0.95),
      const Color(0xFFF8F9FA).withOpacity(0.98),
      Colors.white.withOpacity(0.95),
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors ?? defaultGradient,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.grey.withOpacity(0.15),
                width: 1.5,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.5),
                  Colors.white.withOpacity(0.3),
                ],
              ),
            ),
            child: Padding(
              padding: padding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (icon != null) ...[
                    Row(
                      children: [
                        Container(
                          padding:  EdgeInsets.all(isSmallScreen ? 6 : 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF667eea).withOpacity(0.95),
                                const Color(0xFF764ba2).withOpacity(1.0),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF667eea).withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            icon,
                            size: isSmallScreen ? 10 : 20.r, 
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 8: 12.w), 
                        Expanded( 
                          child: Text(
                            title,
                            style: titleStyle ??
                                TextStyle(
                                  fontSize: isSmallScreen ? 10  : 12.r,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                  letterSpacing: 0.2,
                                ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                  ] else ...[
                    Text(
                      title,
                      style: titleStyle ??
                          TextStyle(
                            fontFamily: 'ABeeZee',
                            fontSize:islargeScreen? 16.r :13.r,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            letterSpacing: 0.8,
                          ),
                    ),
                    SizedBox(height: 10.h),
                  ],
                  ValueListenableBuilder<T>(
                    valueListenable: valueListenable,
                    builder: (context, value, _) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.3),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              )),
                              child: child,
                            ),
                          );
                        },
                        child: ShaderMask(
                          key: ValueKey(value),
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              Colors.black87,
                              Colors.black87,
                            ],
                          ).createShader(bounds),
                          child: Text(
                            valueBuilder(value),
                            style: valueStyle ??
                                TextStyle(
                                  fontSize: 30.r,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'ABeeZee', 
                                  color: Colors.black87,
                                  letterSpacing: -0.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.1),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    height: 3,
                    width: 40.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF667eea),
                          Color(0xFF764ba2),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF667eea).withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
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