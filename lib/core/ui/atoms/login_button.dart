import 'package:flutter/material.dart';

/// Botón primario para iniciar sesión (presentación pura).
/// - Base 378×28, responsivo mediante escalado interno.
/// - Color #F86117, radio 4, sombra, ripple y animación de “press”.
/// - Recibe un `payload` opcional que se pasa al callback cuando funcione.
///
/// Úsalo desde Presentación; no hace llamadas a red ni a BD.
class LoginButton extends StatefulWidget {
  final String label;
  final void Function(Object? payload)? onPressed;
  final Object? payload;

  /// Colores/estilo
  final Color backgroundColor;
  final Color textColor;

  /// Medidas base para el escalado responsivo.
  final double baseWidth;
  final double baseHeight;
  final double borderRadius;

  const LoginButton({
    super.key,
    this.label = 'Iniciar sesión',
    this.onPressed,
    this.payload,
    this.backgroundColor = const Color(0xFFF86117),
    this.textColor = Colors.white,
    this.baseWidth = 378,
    this.baseHeight = 28,
    this.borderRadius = 4,
  });

  @override
  State<LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth.isFinite ? c.maxWidth : widget.baseWidth;
        final h = c.maxHeight.isFinite ? c.maxHeight : widget.baseHeight;
        final scaleX = w / widget.baseWidth;
        final scaleY = h / widget.baseHeight;
        final scale = (scaleX < scaleY ? scaleX : scaleY);

        return Center(
          child: AnimatedScale(
            scale: _pressed ? 0.98 : 1.0,
            duration: const Duration(milliseconds: 90),
            curve: Curves.easeOut,
            child: SizedBox(
              width: widget.baseWidth * scale,
              height: widget.baseHeight * scale,
              child: Material(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                elevation: 4,
                shadowColor: Colors.black.withValues(alpha: 0.35),
                child: InkWell(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  splashColor: Colors.white.withValues(alpha: 0.18),
                  highlightColor: Colors.white.withValues(alpha: 0.10),
                  onHighlightChanged: (v) => setState(() => _pressed = v),
                  onTap: widget.onPressed == null
                      ? null
                      : () => widget.onPressed!(widget.payload),
                  child: Center(
                    child: Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400, // Regular
                        fontSize: 16,
                        color: widget.textColor,
                      ),
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
