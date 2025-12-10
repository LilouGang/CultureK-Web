// lib/ui/quiz_page/widgets/diff_card.dart

import 'package:flutter/material.dart';

class DiffCard extends StatefulWidget {
  final String title;
  final Color color;
  final String subtitle;
  final VoidCallback onTap;
  const DiffCard(this.title, this.color, this.subtitle, this.onTap, {super.key});
  @override
  State<DiffCard> createState() => _DiffCardState();
}

class _DiffCardState extends State<DiffCard> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(()=>_hover=true), onExit: (_)=>setState(()=>_hover=false), cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 220, height: 140,
          decoration: BoxDecoration(
            color: _hover ? widget.color : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: widget.color.withOpacity(0.3), width: 2),
            boxShadow: _hover ? [BoxShadow(color: widget.color.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))] : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _hover ? Colors.white : widget.color)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: _hover ? Colors.white24 : widget.color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(widget.subtitle, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _hover ? Colors.white : widget.color)),
              )
            ],
          ),
        ),
      ),
    );
  }
}