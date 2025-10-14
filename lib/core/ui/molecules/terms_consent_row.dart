import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Fila de aceptación de términos:
/// - Base 352×24, fondo blanco.
/// - Izquierda: checkbox.
/// - Derecha: texto "Al seleccionar la casilla, acepto los términos del servicio"
///   con “términos del servicio” subrayado y clickable.
/// - Componente CONTROLADO: el padre guarda `value` y procesa `onChanged`.
class TermsConsentRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  final VoidCallback? onTermsTap;

  final double baseWidth;
  final double baseHeight;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;

  const TermsConsentRow({
    super.key,
    required this.value,
    this.onChanged,
    this.onTermsTap,
    this.baseWidth = 352,
    this.baseHeight = 24,
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth.isFinite ? c.maxWidth : baseWidth;
        final h = c.maxHeight.isFinite ? c.maxHeight : baseHeight;
        final scaleX = w / baseWidth;
        final scaleY = h / baseHeight;
        final scale = (scaleX < scaleY ? scaleX : scaleY);

        return Center(
          child: SizedBox(
            width: baseWidth * scale,
            height: baseHeight * scale,
            child: Container(
              color: backgroundColor,
              child: Padding(
                padding: padding,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _TinyCheckbox(value: value, onChanged: onChanged),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        textScaleFactor:
                            scale, // respeta escalado del contenedor
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w300, // Light
                            fontSize: 10,
                            color: Color(0xFF212121),
                            height: 1.2,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Al seleccionar la casilla, acepto los ',
                            ),
                            TextSpan(
                              text: 'términos del servicio',
                              style: const TextStyle(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w300,
                              ),
                              recognizer: (onTermsTap == null)
                                  ? null
                                  : (TapGestureRecognizer()
                                      ..onTap = onTermsTap),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TinyCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  const _TinyCheckbox({required this.value, this.onChanged});

  @override
  State<_TinyCheckbox> createState() => _TinyCheckboxState();
}

class _TinyCheckboxState extends State<_TinyCheckbox> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
        onTap: widget.onChanged == null
            ? null
            : () => widget.onChanged!(!widget.value),
        onHighlightChanged: (v) => setState(() => _pressed = v),
        splashColor: Colors.black.withValues(alpha: 0.06),
        child: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: const Color(0xFF9E9E9E), width: 1.8),
            color: widget.value ? const Color(0xFF1A73E8) : Colors.white,
          ),
          alignment: Alignment.center,
          child: widget.value
              ? const Icon(Icons.check, size: 12, color: Colors.white)
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
