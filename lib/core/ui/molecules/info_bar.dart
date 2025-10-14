import 'package:flutter/material.dart';

/// Barra de información con título centrado y botón Back.
/// - El botón back expone callback para conectarlo en Presentación.
class InfoBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final double height;
  final EdgeInsets padding;

  const InfoBar({
    super.key,
    required this.title,
    this.onBack,
    this.height = 45,
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: const Color(0x33000000),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          width: double.infinity,
          height: height,
          child: Padding(
            padding: padding,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Botón Back (a la izquierda)
                Align(
                  alignment: Alignment.centerLeft,
                  child: _BackIconButton(onTap: onBack, iconSize: 24),
                ),
                // Título centrado
                Center(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      fontSize: 24,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BackIconButton extends StatefulWidget {
  final VoidCallback? onTap;
  final double iconSize;
  const _BackIconButton({this.onTap, this.iconSize = 24});

  @override
  State<_BackIconButton> createState() => _BackIconButtonState();
}

class _BackIconButtonState extends State<_BackIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.92 : 1.0,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      child: InkResponse(
        radius: 24,
        onTap: widget.onTap,
        onHighlightChanged: (v) => setState(() => _pressed = v),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            Icons.arrow_back,
            size: widget.iconSize,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
