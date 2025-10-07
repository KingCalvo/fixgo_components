import 'package:flutter/material.dart';

/// Componente "ServiceOptionsCard" (responsive)
/// Se adapta al ancho disponible hasta un máximo de 402.
class ServiceOptionsCard extends StatefulWidget {
  final VoidCallback? onSendMessage;
  final VoidCallback? onCall;
  final VoidCallback? onCancel;
  final VoidCallback? onReport;
  final VoidCallback? onConclude;

  const ServiceOptionsCard({
    Key? key,
    this.onSendMessage,
    this.onCall,
    this.onCancel,
    this.onReport,
    this.onConclude,
  }) : super(key: key);

  @override
  State<ServiceOptionsCard> createState() => _ServiceOptionsCardState();
}

class _ServiceOptionsCardState extends State<ServiceOptionsCard> {
  bool _acceptedTerms = false;

  @override
  Widget build(BuildContext context) {
    // Valores "máximos" solicitados
    const double maxWidth = 402;
    const double paddingAll = 10;
    const Color strokeColor = Color.fromRGBO(0, 0, 0, 0.7);
    const Color dividerColor = Color(0xFFC4C4C4);
    const Color inputBorderColor = Color(0xFFE6E6E6);
    const Color inputTextColor = Color(0xFF484747);

    return LayoutBuilder(
      builder: (context, constraints) {
        // ancho real que usaremos: como máximo maxWidth, pero no mayor al disponible
        final double available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : maxWidth;
        final double contentWidth = available.clamp(0, maxWidth);

        // ancho interior descontando padding (equivalente a tu 382)
        final double innerWidth = (contentWidth - paddingAll * 2).clamp(
          0,
          maxWidth,
        );

        // tamaños fijos de los icon-buttons (mantengo 37.57 solicitado)
        const double iconBtnSize = 37.57;
        const double smallBtnHeight = 24;
        const double smallBtnRequestedWidth = 165;

        return Center(
          child: Container(
            width: contentWidth,
            padding: const EdgeInsets.all(paddingAll),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: strokeColor),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // linea superior (innerWidth)
                Container(width: innerWidth, height: 1.5, color: dividerColor),

                const SizedBox(height: 8),

                // Row input + chat button + phone button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // input flexible (antes 283.99). Ahora ocupa el espacio restante
                    Expanded(
                      child: Container(
                        height: 37.57,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: inputBorderColor,
                            width: 6.53,
                          ),
                        ),
                        child: Text(
                          'Envía un mensaje',
                          style: TextStyle(color: inputTextColor, fontSize: 14),
                        ),
                      ),
                    ),

                    const SizedBox(width: 11),

                    // botón chat (ancho fijo iconBtnSize)
                    _animatedButton(
                      onTap: widget.onSendMessage,
                      width: iconBtnSize,
                      height: iconBtnSize,
                      borderRadius: BorderRadius.circular(6),
                      backgroundColor: Colors.white,
                      borderColor: inputBorderColor,
                      borderWidth: 6.53,
                      child: const Icon(
                        Icons.chat_bubble_outline,
                        size: 18,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(width: 11),

                    // botón teléfono
                    _animatedButton(
                      onTap: widget.onCall,
                      width: iconBtnSize,
                      height: iconBtnSize,
                      borderRadius: BorderRadius.circular(6),
                      backgroundColor: Colors.white,
                      borderColor: inputBorderColor,
                      borderWidth: 6.53,
                      child: const Icon(
                        Icons.phone_outlined,
                        size: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // linea intermedia (innerWidth)
                Container(width: innerWidth, height: 1.5, color: dividerColor),

                const SizedBox(height: 8),

                // Row: Cancelar, Reportar, Icon Alert
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // "Cancelar" - permitimos que sea flexible pero con un ancho mínimo razonable
                    Flexible(
                      flex: 0,
                      child: _animatedButton(
                        onTap: widget.onCancel,
                        width: smallBtnRequestedWidth > innerWidth
                            ? null
                            : smallBtnRequestedWidth,
                        height: smallBtnHeight,
                        borderRadius: BorderRadius.circular(4),
                        backgroundColor: const Color(0xFFD41E1E),
                        borderColor: const Color(0xFFD41E1E),
                        borderWidth: 4,
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 15),

                    // "Reportar" - si no cabe se reducirá
                    Flexible(
                      child: _animatedButton(
                        onTap: widget.onReport,
                        width: smallBtnRequestedWidth > innerWidth
                            ? null
                            : smallBtnRequestedWidth,
                        height: smallBtnHeight,
                        borderRadius: BorderRadius.circular(4),
                        backgroundColor: const Color(0xFFF86117),
                        borderColor: const Color(0xFFF86117),
                        borderWidth: 4,
                        child: const Text(
                          'Reportar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 15),

                    // Icon alert circular (22x22) sin animación y sin ser botón
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.error_outline,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // "Concluir" - ocupa todo el ancho interno
                _animatedButton(
                  onTap: _acceptedTerms ? widget.onConclude : null,
                  width: null, // null => ocupa todo el espacio disponible
                  height: smallBtnHeight,
                  borderRadius: BorderRadius.circular(4),
                  backgroundColor: const Color(0xFF2E7D32),
                  borderColor: const Color(0xFF2E7D32),
                  borderWidth: 4,
                  child: const Text(
                    'Concluir',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // Checkbox + texto (se adapta con Expanded)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () =>
                          setState(() => _acceptedTerms = !_acceptedTerms),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: _acceptedTerms ? Colors.green : Colors.white,
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: _acceptedTerms
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        'Al seleccionar el botón, Concluir los términos del servicio',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Botón con animación; si [width] es null ocupa el espacio disponible (flexible).
  Widget _animatedButton({
    required Widget child,
    required VoidCallback? onTap,
    double? width,
    required double height,
    required BorderRadius borderRadius,
    required Color backgroundColor,
    required double borderWidth,
    required Color borderColor,
    EdgeInsets? padding,
  }) {
    final Widget btn = _ScaleOnTap(
      enabled: true,
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: onTap != null
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: child,
      ),
    );

    // Si width == null devolvemos Expanded para tomar el espacio disponible,
    // si width está definido devolvemos el btn tal cual.
    if (width == null) {
      return SizedBox(width: double.infinity, child: btn);
    } else {
      return btn;
    }
  }
}

/// Efecto de escala al tocar el hijo.
class _ScaleOnTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;

  const _ScaleOnTap({
    Key? key,
    required this.child,
    this.onTap,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<_ScaleOnTap> createState() => _ScaleOnTapState();
}

class _ScaleOnTapState extends State<_ScaleOnTap> {
  bool _pressed = false;

  void _onTapDown(TapDownDetails d) {
    if (!widget.enabled) return;
    setState(() => _pressed = true);
  }

  void _onTapUp(TapUpDetails d) {
    if (!widget.enabled) return;
    setState(() => _pressed = false);
    if (widget.onTap != null) widget.onTap!();
  }

  void _onTapCancel() {
    if (!widget.enabled) return;
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final double scale = _pressed ? 0.92 : 1.0;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
