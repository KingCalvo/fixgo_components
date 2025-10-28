import 'package:flutter/material.dart';

enum RoleSwitchValue { cliente, proveedor }

// Switch de dos posiciones: Cliente / Proveedor
class RoleSwitch extends StatefulWidget {
  final RoleSwitchValue value;
  final ValueChanged<RoleSwitchValue>? onChanged;

  final String leftLabel; // "Cliente"
  final String rightLabel; // "Proveedor"

  final Color backgroundColor;
  final Color selectedColor;
  final Color unselectedColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;

  /// Tamaño base (ahora más grande por defecto)
  final double baseWidth;
  final double baseHeight;
  final double borderRadius;

  const RoleSwitch({
    super.key,
    this.value = RoleSwitchValue.cliente,
    this.onChanged,
    this.leftLabel = 'Cliente',
    this.rightLabel = 'Proveedor',
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.selectedColor = const Color(0xFFF86117),
    this.unselectedColor = const Color(0xFFFFFFFF),
    this.selectedTextColor = const Color(0xFFFFFFFF),
    this.unselectedTextColor = const Color(0xFF424242),
    this.baseWidth = 392, // antes 352
    this.baseHeight = 44, // antes 35
    this.borderRadius = 10, // un poco más redondeado
  });

  @override
  State<RoleSwitch> createState() => _RoleSwitchState();
}

class _RoleSwitchState extends State<RoleSwitch> {
  bool _pressingLeft = false;
  bool _pressingRight = false;

  void _tap(RoleSwitchValue v) {
    if (widget.value != v) {
      widget.onChanged?.call(v);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth.isFinite ? c.maxWidth : widget.baseWidth;
        final h = c.maxHeight.isFinite ? c.maxHeight : widget.baseHeight;
        final scaleX = w / widget.baseWidth;
        final scaleY = h / widget.baseHeight;
        final scale = (scaleX < scaleY ? scaleX : scaleY);

        final width = widget.baseWidth * scale;
        final height = widget.baseHeight * scale;

        final isLeftSelected = widget.value == RoleSwitchValue.cliente;

        return Center(
          child: SizedBox(
            width: width,
            height: height,
            child: Container(
              // SIN sombra aquí (solo marco y fondo)
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cliente
                  _Segment(
                    label: widget.leftLabel,
                    selected: isLeftSelected,
                    selectedColor: widget.selectedColor,
                    unselectedColor: widget.unselectedColor,
                    selectedTextColor: widget.selectedTextColor,
                    unselectedTextColor: widget.unselectedTextColor,
                    onTap: () => _tap(RoleSwitchValue.cliente),
                    pressing: _pressingLeft,
                    onHighlightChanged: (v) =>
                        setState(() => _pressingLeft = v),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(widget.borderRadius),
                      bottomLeft: Radius.circular(widget.borderRadius),
                    ),
                  ),

                  // Proveedor
                  _Segment(
                    label: widget.rightLabel,
                    selected: !isLeftSelected,
                    selectedColor: widget.selectedColor,
                    unselectedColor: widget.unselectedColor,
                    selectedTextColor: widget.selectedTextColor,
                    unselectedTextColor: widget.unselectedTextColor,
                    onTap: () => _tap(RoleSwitchValue.proveedor),
                    pressing: _pressingRight,
                    onHighlightChanged: (v) =>
                        setState(() => _pressingRight = v),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(widget.borderRadius),
                      bottomRight: Radius.circular(widget.borderRadius),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool selected;
  final Color selectedColor;
  final Color unselectedColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;
  final VoidCallback? onTap;
  final bool pressing;
  final ValueChanged<bool>? onHighlightChanged;
  final BorderRadius borderRadius;

  const _Segment({
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.selectedTextColor,
    required this.unselectedTextColor,
    required this.onTap,
    required this.pressing,
    required this.onHighlightChanged,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? selectedColor : unselectedColor;
    final fg = selected ? selectedTextColor : unselectedTextColor;

    return Expanded(
      child: AnimatedScale(
        scale: pressing ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Container(
            // SOMBRA SOLO CUANDO ESTÁ SELECCIONADO
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              boxShadow: selected
                  ? const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: bg,
              borderRadius: borderRadius,
              child: InkWell(
                onTap: onTap,
                onHighlightChanged: onHighlightChanged,
                splashColor: Colors.white.withValues(alpha: 0.18),
                highlightColor: Colors.white.withValues(alpha: 0.10),
                borderRadius: borderRadius,
                child: Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      fontSize: 17, // un poquito más grande
                    ).copyWith(color: fg),
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
