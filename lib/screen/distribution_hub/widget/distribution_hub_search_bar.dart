import 'package:flutter/material.dart';

class PartySearchBar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    const double spacing = 8; // Fixed pixel value
    const double iconSize = 20; // Fixed pixel value
    const double borderRadius = 24; // Fixed pixel value
    const double fontSize = 14; // Fixed pixel value
    const double contentPadding = 12; // Fixed pixel value

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12, // Fixed pixel value
        horizontal: 8, // Fixed pixel value
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
                contentPadding: const EdgeInsets.symmetric(vertical: contentPadding),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(fontSize: fontSize),
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: spacing),
          Center(
            child: ElevatedButton.icon(         
              onPressed: onAddParty,
              icon: Icon(Icons.add, size: iconSize, color: Colors.white),
              label: Text(
                'New Party', 
                style: const TextStyle(fontSize: fontSize, color: Colors.white),
              ), 
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 80, 82, 84),
                foregroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),   
                ), 
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  vertical: 12, // Fixed pixel value
                  horizontal: 8, // Fixed pixel value
                ),
              ),
            ),
          ),
        ],
      ),
    );
  } 
}