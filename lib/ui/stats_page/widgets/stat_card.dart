import 'package:flutter/material.dart';

class StatCard extends StatefulWidget {
  final String title;
  final String value;
  final String? suffix;
  final String description;
  final IconData icon;
  final Color color;
  final bool isInsight;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.description,
    required this.icon,
    required this.color,
    this.suffix,
    this.isInsight = false,
  });

  factory StatCard.insight({
    required String title,
    required String value,
    required String scoreText,
    required bool isPositive,
  }) {
    return StatCard(
      title: title,
      value: value,
      suffix: null,
      description: scoreText,
      color: isPositive ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
      icon: isPositive ? Icons.emoji_events_rounded : Icons.trending_down_rounded,
      isInsight: true,
    );
  }

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isInsight = widget.isInsight;

    if (isInsight) {
      return _buildInsightCard();
    }

    return _buildStandardCard();
  }

  Widget _buildInsightCard() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: _isHovered ? Matrix4.identity().scaled(1.02) : Matrix4.identity(),
        clipBehavior: Clip.hardEdge, 
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.color,
              HSLColor.fromColor(widget.color).withLightness(0.45).toColor(), 
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.4),
              blurRadius: _isHovered ? 30 : 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Transform.rotate(
                angle: -0.2,
                child: Icon(
                  widget.icon,
                  size: 140,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(widget.icon, size: 16, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.title.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  Text(
                    widget.value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)
                      ]
                    ),
                    child: Text(
                      widget.description,
                      style: TextStyle(
                        color: widget.color,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardCard() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: _isHovered ? Matrix4.identity().scaled(1.02) : Matrix4.identity(),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isHovered ? widget.color.withOpacity(0.5) : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(_isHovered ? 0.2 : 0.0),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
            if (!_isHovered)
              BoxShadow(
                color: Colors.blueGrey.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: widget.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(widget.icon, size: 20, color: widget.color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.title.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.blueGrey.shade400,
                            letterSpacing: 1.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Tooltip(
                  message: widget.description,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  verticalOffset: 20, 
                  preferBelow: false,
                  waitDuration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blueGrey.shade100, width: 1),
                    boxShadow: [BoxShadow(color: Colors.blueGrey.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 5))]
                  ),
                  textStyle: TextStyle(color: Colors.blueGrey.shade800, fontSize: 13, fontWeight: FontWeight.w600),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(Icons.info_outline_rounded, size: 20, color: Colors.blueGrey.shade200),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    widget.value,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.blueGrey.shade900,
                      letterSpacing: -1.0,
                    ),
                  ),
                  if (widget.suffix != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        widget.suffix!,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blueGrey.shade400),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}