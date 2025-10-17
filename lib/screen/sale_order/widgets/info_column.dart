import 'package:flutter/material.dart';

class InfoColumn extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const InfoColumn({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: color)),
      ],
    );
  }
}