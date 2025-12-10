// lib/ui/quiz_page/widgets/breadcrumb.dart

import 'package:flutter/material.dart';

class Breadcrumb extends StatelessWidget {
  final String text;
  final VoidCallback onBack;
  const Breadcrumb({super.key, required this.text, required this.onBack});
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_rounded, color: Colors.blueAccent)),
        Text(text, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600)),
      ],
    );
  }
}