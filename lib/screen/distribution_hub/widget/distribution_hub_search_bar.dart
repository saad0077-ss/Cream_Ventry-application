import 'package:cream_ventory/utils/responsive_util.dart';
import 'package:flutter/material.dart';


class PartySearchBar extends StatelessWidget {
  final VoidCallback onAddParty;
    final TextEditingController? controller;
  final ValueChanged<String>? onChanged;


  const PartySearchBar({super.key, required this.onAddParty,this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final double spacing = SizeConfig.blockWidth * 2.0;
    final double iconSize = SizeConfig.imageSizeMultiplier * 5 ; 
    final double borderRadius = SizeConfig.blockWidth * 6;
    final double fontSize = SizeConfig.textMultiplier * 1.5;
    final double contentPadding = SizeConfig.blockHeight * 1.5;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: SizeConfig.blockHeight * 1.5,
        horizontal: SizeConfig.blockWidth * 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Search Parties',
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search, color: Colors.blue, size: iconSize),
                filled: true,
                contentPadding: EdgeInsets.symmetric(vertical: contentPadding),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(fontSize: fontSize),
              onChanged: onChanged,
            ),
          ),
          SizedBox(width: spacing),
          Center(
            child: ElevatedButton.icon(         
              onPressed: onAddParty,
              icon: Icon(Icons.add, size: iconSize,color: Colors.white,),
              label: Text(
                'New Party', 
                style: TextStyle(fontSize: fontSize,color: Colors.white),
              ), 
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 80, 82, 84),
                foregroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ), 
                elevation: 0,
                padding: EdgeInsets.symmetric(
                  vertical: SizeConfig.blockHeight * 1.5,
                  horizontal: SizeConfig.blockWidth * 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  } 
} 
