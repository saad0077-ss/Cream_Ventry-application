import 'dart:io';
import 'package:cream_ventory/db/models/items/category/category_model.dart';
import 'package:cream_ventory/screen/items/screen/category/screens/category_detail_page.dart';
import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.15),
      margin: EdgeInsets.symmetric(
        vertical: screenHeight * 0.015,
        horizontal: screenWidth * 0.03,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryDetailsPage(category: cat),
              ),
            );
          },
          contentPadding: EdgeInsets.all(screenWidth * 0.04),
          leading: Container(
            width: screenWidth * 0.20,
            height: screenWidth * 0.20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: cat.isAsset
                  ? Image.asset(
                      cat.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildErrorIcon(),
                    )
                  : File(cat.imagePath).existsSync()
                      ? Image.file(
                          File(cat.imagePath),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildErrorIcon(),
                        )
                      : _buildErrorIcon(),
            ),
          ),
          title: Text(
            cat.name.toUpperCase(), 
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.w700,
              fontFamily: 'ADLaM',
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
          ), 
        ),
      ),
    );
  }    

  Widget _buildErrorIcon() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image_not_supported,
          size: screenWidth * 0.10,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}