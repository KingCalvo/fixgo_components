import 'package:flutter/material.dart';

/// Datos del botón flotante del bot
class BotFabData {
  final String? imageAsset; // usa uno u otro
  final String? imageUrl;
  final VoidCallback? onTap;

  const BotFabData({this.imageAsset, this.imageUrl, this.onTap});
}

/// Botón flotante
class BotFab extends StatefulWidget {
  final BotFabData data;
  final double size;
  final EdgeInsets margin;

  const BotFab({
    super.key,
    required this.data,
    this.size = 62,
    this.margin = const EdgeInsets.only(right: 16, bottom: 16),
  });

  @override
  State<BotFab> createState() => _BotFabState();
}

class _BotFabState extends State<BotFab> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      value: 0.0,
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _tapDown(TapDownDetails _) {
    _controller.forward();
    setState(() => _pressed = true);
  }

  void _tapUp(TapUpDetails _) {
    _controller.reverse();
    setState(() => _pressed = false);
    widget.data.onTap?.call();
  }

  void _tapCancel() {
    _controller.reverse();
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final double s = widget.size;
    return Padding(
      padding: widget.margin,
      child: ScaleTransition(
        scale: _scale,
        child: Material(
          color: const Color(0xFF2E2E2E),
          shape: const CircleBorder(),
          elevation: _pressed ? 3 : 6,
          shadowColor: Colors.black.withValues(alpha: 0.28),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTapDown: _tapDown,
            onTapUp: _tapUp,
            onTapCancel: _tapCancel,
            splashColor: Colors.white.withValues(alpha: 0.15),
            child: SizedBox(
              width: s,
              height: s,
              child: Center(child: _buildImage()),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    const double iw = 50, ih = 42;
    const placeholder = Icon(
      Icons.smart_toy_rounded,
      size: 36,
      color: Colors.white,
    );

    if (widget.data.imageAsset != null) {
      return Image.asset(
        widget.data.imageAsset!,
        width: iw,
        height: ih,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => placeholder,
      );
    }
    if (widget.data.imageUrl != null) {
      return Image.network(
        widget.data.imageUrl!,
        width: iw,
        height: ih,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => placeholder,
      );
    }
    return placeholder;
  }
}
