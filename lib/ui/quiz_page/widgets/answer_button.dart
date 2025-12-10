// lib/ui/quiz_page/widgets/answer_button.dart

import 'package:flutter/material.dart';

class AnswerButton extends StatelessWidget {
  final String text;
  final Color? bgColor;
  final Color? textColor;
  final Color borderColor;
  final VoidCallback? onTap;
  const AnswerButton({super.key, required this.text, this.bgColor, this.textColor, required this.borderColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor == Colors.transparent ? Colors.grey.shade200 : borderColor, width: 2),
          ),
          child: Center(child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16))),
        ),
      ),
    );
  }
}