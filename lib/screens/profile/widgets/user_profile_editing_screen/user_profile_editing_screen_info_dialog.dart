import 'package:flutter/material.dart';

void showInfoDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Text(message, style: const TextStyle(fontSize: 15, height: 1.5)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Got it',
            style: TextStyle(
              color: Colors.blue.shade700,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}