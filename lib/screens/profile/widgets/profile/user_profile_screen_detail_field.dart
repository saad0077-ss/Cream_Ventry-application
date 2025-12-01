// lib/screens/profile/widgets/detail_field.dart
import 'package:flutter/material.dart';

class DetailField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isEmpty;
  final int maxLines;

  const DetailField({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.isEmpty,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
              fontFamily: 'ABeeZee',
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isEmpty ? Colors.grey.shade400 : const Color(0xFF667EEA),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      color: isEmpty ? Colors.grey.shade500 : const Color(0xFF334155),
                      fontWeight: FontWeight.w500,
                      fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                      fontFamily: 'ABeeZee',
                    ),
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}