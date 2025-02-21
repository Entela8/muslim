import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NavCard extends StatefulWidget {
  final String title;
  final Widget destination;
  final IconData? icon;

  const NavCard({
    super.key,
    required this.title,
    required this.destination,
    this.icon,
  });

  @override
  State<NavCard> createState() => _NavCardState();
}

class _NavCardState extends State<NavCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: SizedBox(
          width: 300,
          child: Card(
            elevation: _isPressed ? 2 : 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color.fromARGB(255, 45, 45, 45),
                    const Color.fromARGB(255, 25, 25, 25),
                  ],
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTapDown: (_) {
                    setState(() => _isPressed = true);
                    _controller.forward();
                  },
                  onTapUp: (_) {
                    setState(() => _isPressed = false);
                    _controller.reverse();
                  },
                  onTapCancel: () {
                    setState(() => _isPressed = false);
                    _controller.reverse();
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            widget.destination,
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null)
                          Icon(widget.icon,
                              color: Colors.white.withValues(alpha: 0.9),
                              size: 28),
                        if (widget.icon != null) const SizedBox(width: 12),
                        Text(
                          widget.title,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
