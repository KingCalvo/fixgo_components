import 'package:flutter/material.dart';

/// Botón “Publicar trabajo”
class PublishButton extends StatefulWidget {
  const PublishButton({
    Key? key,
    this.label = 'Publicar trabajo',
    this.onPressed,
    this.baseWidth = 392,
    this.baseHeight = 24,
    this.backgroundColor = const Color(0xFF2E7D32),
    this.textColor = Colors.white,
  }) : super(key: key);

  final String label;
  final VoidCallback? onPressed;

  final double baseWidth;
  final double baseHeight;

  final Color backgroundColor;
  final Color textColor;

  @override
  State<PublishButton> createState() => _PublishButtonState();
}

class _PublishButtonState extends State<PublishButton> {
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
              onTap: widget.onPressed,
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
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: widget.textColor,
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
