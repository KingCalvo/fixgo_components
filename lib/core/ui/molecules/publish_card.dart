import 'package:flutter/material.dart';

// Muestra información para ayudar al cliente a publicar una solicitud de servicio

class PublishPromptCard extends StatelessWidget {
  final VoidCallback? onPublish;

  /// Dimensiones base del diseño
  final double baseWidth;
  final double baseHeight;

  static const String _kImageAsset = 'lib/assets/PublicarCard.png';

  const PublishPromptCard({
    super.key,
    this.onPublish,
    this.baseWidth = 400,
    this.baseHeight = 100,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth.isFinite ? c.maxWidth : baseWidth;
        final h = c.maxHeight.isFinite ? c.maxHeight : baseHeight;
        final scale = (w / baseWidth < h / baseHeight)
            ? w / baseWidth
            : h / baseHeight;

        return SizedBox(
          width: baseWidth * scale,
          height: baseHeight * scale,
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.topLeft,
            child: _content(context),
          ),
        );
      },
    );
  }

  Widget _content(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2E2E2E).withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildFixedImage(),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text.rich(
                    TextSpan(
                      children: const [
                        TextSpan(
                          text: '¿Tienes un presupuesto? ',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text:
                              'Publícalo y los proveedores cercanos te contactan',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    softWrap: true,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: _PublishButton(onTap: onPublish),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedImage() {
    const placeholder = SizedBox(
      width: 74,
      height: 74,
      child: Center(
        child: Icon(Icons.handyman_rounded, size: 44, color: Colors.white),
      ),
    );

    return Image.asset(
      _kImageAsset,
      width: 74,
      height: 74,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => placeholder,
    );
  }
}

class _PublishButton extends StatefulWidget {
  final VoidCallback? onTap;
  const _PublishButton({this.onTap});

  @override
  State<_PublishButton> createState() => _PublishButtonState();
}

class _PublishButtonState extends State<_PublishButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      value: 0.0,
    );

    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
    setState(() => _pressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    setState(() => _pressed = false);
  }

  void _onTapCancel() {
    _controller.reverse();
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Material(
        color: const Color(0xFFF86117),
        borderRadius: BorderRadius.circular(4),
        elevation: _pressed ? 2 : 6,
        shadowColor: Colors.black.withValues(alpha: 0.25),
        child: InkWell(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(4),
          splashColor: Colors.white.withValues(alpha: 0.15),
          child: const SizedBox(
            width: 183,
            height: 21,
            child: Center(
              child: Text(
                'Publicar',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
