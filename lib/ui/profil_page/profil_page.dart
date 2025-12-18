import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/data_manager.dart';
import 'views/guest_view.dart';
import 'views/user_view.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<DataManager>().currentUser;
    final isGuest = user.id == "guest";

    return Scaffold(
      body: BackgroundPattern(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 40),
            
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.05),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: isGuest
                    ? const GuestView(key: ValueKey('Guest'))
                    : const UserView(key: ValueKey('User')),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BackgroundPattern extends StatelessWidget {
  final Widget child;
  const BackgroundPattern({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: const Color(0xFFF8FAFC)), 
        Positioned.fill(
          child: CustomPaint(
            painter: StripePainter(),
          ),
        ),
        child,
      ],
    );
  }
}

class StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.blueGrey.withOpacity(0.03)
      ..strokeWidth = 2;

    const double step = 10;

    for (double i = -size.height; i < size.width; i += step) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}