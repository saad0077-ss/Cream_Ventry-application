import 'package:flutter/material.dart';

class CustomFloatingActionButton extends StatelessWidget {
  final VoidCallback onCategoriesTap;
  final VoidCallback onProductsTap;
  final int currentIndex;

  const CustomFloatingActionButton({
    super.key,
    required this.onCategoriesTap,
    required this.onProductsTap,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        if (currentIndex == 0) { 
          onCategoriesTap();
        } else if (currentIndex == 1) {
          onProductsTap();
        }
      },
      backgroundColor: Colors.blueGrey,
      splashColor: Colors.transparent,
      child: const Icon(Icons.add,color: Colors.white,),
    );
  }
}
