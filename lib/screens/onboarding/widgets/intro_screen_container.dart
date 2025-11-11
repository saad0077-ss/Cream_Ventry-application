import 'package:flutter/material.dart';

class IntroBottomContainer extends StatelessWidget {
  final String description;
  final Widget button;
  final double? containerHeight;

  const IntroBottomContainer({
    super.key,
    required this.description,
    required this.button,
    this.containerHeight,
  }); 

  @override
  Widget build(BuildContext context) {

    return Positioned(
      bottom: 16, // Fixed pixel elevation from bottom
      left: 8, // Fixed pixel margin from left
      right: 8, // Fixed pixel margin from right
      child: Container(
        height: containerHeight ?? 300, // Default to 300 pixels (~39% of typical mobile screen height)
        padding: const EdgeInsets.symmetric(
          horizontal: 6, // Fixed pixel padding
        vertical: 26, // Fixed pixel padding
        ),
        decoration: BoxDecoration(
          color: const Color.fromARGB(113, 0, 0, 0),
          borderRadius: const BorderRadius.all(
            Radius.circular(20), // Fixed pixel radius for rounded corners
          ),
          boxShadow: [
            BoxShadow( 
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.3), // Shadow for floating effect
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4), // Shadow slightly below
            ),
          ],
        ), 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16), // Fixed pixel padding
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16, // Fixed pixel font size
                  fontFamily: 'holtwood',
                  color: Colors.white,
                  height: 1.6,
                ),
              ),
            ),
            button,
          ],
        ),
      ),
    );
  }
}