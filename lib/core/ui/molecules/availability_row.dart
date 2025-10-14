import 'package:flutter/material.dart';

class AvailabilityData {
  final String daysLabel;
  final String timeRangeText;

  const AvailabilityData({
    this.daysLabel = 'Lunes a Viernes',
    required this.timeRangeText,
  });
}

/// Row de disponibilidad
class AvailabilityRow extends StatelessWidget {
  final AvailabilityData data;
  final VoidCallback? onEdit;
  final double baseWidth;
  final EdgeInsets padding;

  const AvailabilityRow({
    super.key,
    required this.data,
    this.onEdit,
    this.baseWidth = 412,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: baseWidth),
      child: Container(
        color: Colors.white,
        padding: padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Textos a la izquierda
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Disponible:',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${data.daysLabel}: ${data.timeRangeText}',
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Botón Editar a la derecha
            _EditButton(onTap: onEdit),
          ],
        ),
      ),
    );
  }
}

class _EditButton extends StatefulWidget {
  final VoidCallback? onTap;
  const _EditButton({this.onTap});

  @override
  State<_EditButton> createState() => _EditButtonState();
}

class _EditButtonState extends State<_EditButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      child: Material(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(4),
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.35),
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (v) => setState(() => _pressed = v),
          borderRadius: BorderRadius.circular(4),
          splashColor: Colors.white.withValues(alpha: 0.18),
          highlightColor: Colors.white.withValues(alpha: 0.10),
          child: const SizedBox(
            width: 100,
            height: 20,
            child: Center(child: _EditLabel()),
          ),
        ),
      ),
    );
  }
}

class _EditLabel extends StatelessWidget {
  const _EditLabel();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Text(
          'Editar',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            fontSize: 12,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 6),
        Icon(Icons.edit, size: 18, color: Colors.white),
      ],
    );
  }
}
