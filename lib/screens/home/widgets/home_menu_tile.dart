import 'package:cream_ventory/screens/home/widgets/home_menu_provider.dart';
import 'package:flutter/material.dart';

class HomeMenuTile extends StatelessWidget {
  final HomeMenuItem item;

  const HomeMenuTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {

    final isSmallScreen = MediaQuery.of(context).size.width <= 350;

    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),   
          ],
        ),
        child: IntrinsicHeight(
          child: Column( 
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: isSmallScreen ? 30 : 40,
                height: isSmallScreen ? 30 : 40,
                decoration: BoxDecoration(
                  gradient: item.gradient,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: item.icon,
              ),
              const SizedBox(height: 12),
              Text(
                item.title,
                style:  TextStyle(
                  fontSize: isSmallScreen ? 14 : 18,
                  color: Colors.black87,
                  fontFamily: 'holtwood',
                ),
                maxLines: 1, 
                overflow: TextOverflow.ellipsis, 
              ),
              const SizedBox(height: 4),
              Text(
                item.subtitle ?? '',
                style:  TextStyle(
                  fontSize: isSmallScreen ? 5 : 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,  
                  fontFamily: 'ABeeZee',
                ),
                maxLines: isSmallScreen ? 1 : 2,
                overflow: TextOverflow.ellipsis, // 👈 avoids overflow
              ),
            ],
          ),
        ),
      ),
    );
  }
}
