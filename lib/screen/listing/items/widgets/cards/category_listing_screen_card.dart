import 'package:cream_ventory/db/models/items/category/category_model.dart';
import 'package:cream_ventory/screen/detailing/category/category_details_screen.dart';
import 'package:cream_ventory/utils/adding/image_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key, required this.cat, required this.isDesktop});

  final CategoryModel cat;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {      
    // Responsive values
    final double cardHeight = isDesktop ? 70.h : 100.h;    
    final double imageSize = isDesktop ? 90.h : 60.h;
    final double horizontalPadding = isDesktop ? 16.w : 20.w;
    final double fontSize = isDesktop ? 22 : 21;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.12),
      child: Container(
        height: cardHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), 
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight, 
          ), 
        ),
        child: Material(
          color: Colors.transparent, 
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () { 
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryDetailsPage(category: cat),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 9,
              ),
              child: Row(
                children: [
                  // IMAGE - Fixed size with proper isAsset parameter
                  Container(
                    width: imageSize,
                    height: imageSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image(
                        image: ImageUtils.getImage(
                          cat.imagePath,
                          isAsset: cat.isAsset, // Pass the isAsset flag
                        ),
                        fit: BoxFit.cover, 
                        errorBuilder: (_, __, ___) =>
                            _buildErrorIcon(imageSize),
                      ),
                    ),
                  ),

                  SizedBox(width: 19.w),

                  // TEXT
                  Expanded(
                    child: Text(
                      cat.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'ADLaM',
                        color: Colors.black87,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildErrorIcon(double size) {
    return Container(
      width: size,
      height: size,
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: size * 0.5,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}