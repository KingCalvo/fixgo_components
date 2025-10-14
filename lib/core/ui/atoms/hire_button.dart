import 'package:flutter/material.dart';

/// Botón “Contratar”
class HireButton extends StatefulWidget {
  const HireButton({
    Key? key,
    this.label = 'Contratar',
    this.onPressed,
    this.baseWidth = 392,
    this.baseHeight = 40,
    this.backgroundColor = const Color(0xFFF86117),
    this.textColor = Colors.white,
  }) : super(key: key);

  final String label;
  final VoidCallback? onPressed;

  /// Medidas de diseño (se escalan responsivamente)
  final double baseWidth;
  final double baseHeight;

  final Color backgroundColor;
  final Color textColor;

  @override
  State<HireButton> createState() => _HireButtonState();
}

class _HireButtonState extends State<HireButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth.isFinite ? c.maxWidth : widget.baseWidth;
        final h = c.maxHeight.isFinite ? c.maxHeight : widget.baseHeight;

        return AnimatedScale(
          scale: _pressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          child: Material(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(4),
            elevation: 4,
            shadowColor: Colors.black.withValues(alpha: 0.35),
            child: InkWell(
              onTap: widget.onPressed, // navegarás más adelante
              onHighlightChanged: (v) => setState(() => _pressed = v),
              borderRadius: BorderRadius.circular(4),
              splashColor: Colors.white.withValues(alpha: 0.16),
              highlightColor: Colors.white.withValues(alpha: 0.10),
              child: SizedBox(
                width: w,
                height: h,
                child: Center(
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
