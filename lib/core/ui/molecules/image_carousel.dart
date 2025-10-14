import 'package:flutter/material.dart';

class ImageCarousel extends StatefulWidget {
  const ImageCarousel({
    Key? key,
    required this.images,
    this.initialIndex = 0,
    this.baseWidth = 230,
    this.baseHeight = 220,
    this.onIndexChanged,
    this.borderRadius = 12,
  }) : super(key: key);

  final List<String> images; // URLs o assets
  final int initialIndex;
  final double baseWidth;
  final double baseHeight;
  final ValueChanged<int>? onIndexChanged;
  final double borderRadius;

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.images.isEmpty
        ? 0
        : widget.initialIndex.clamp(0, widget.images.length - 1);
  }

  void _prev() {
    if (widget.images.isEmpty) return;
    setState(() {
      _index = (_index - 1 + widget.images.length) % widget.images.length;
    });
    widget.onIndexChanged?.call(_index);
  }

  void _next() {
    if (widget.images.isEmpty) return;
    setState(() {
      _index = (_index + 1) % widget.images.length;
    });
    widget.onIndexChanged?.call(_index);
  }

  @override
  Widget build(BuildContext context) {
    final hasImages = widget.images.isNotEmpty;

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth.isFinite ? c.maxWidth : widget.baseWidth;
        final h = c.maxHeight.isFinite ? c.maxHeight : widget.baseHeight;
        final sw = w / widget.baseWidth;
        final sh = h / widget.baseHeight;
        final scale = sw < sh ? sw : sh;

        final boxW = widget.baseWidth * scale;
        final boxH = widget.baseHeight * scale;

        return SizedBox(
          width: boxW,
          height: boxH,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: Container(
                  width: 223 * scale,
                  height: 220 * scale,
                  color: const Color(0xFFEFEFEF),
                  child: hasImages
                      ? _buildImage(widget.images[_index])
                      : const Center(child: Icon(Icons.image, size: 40)),
                ),
              ),

              // Botón anterior
              Positioned(
                left: 4,
                child: _NavIconButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: _prev,
                  tooltip: 'Anterior',
                ),
              ),

              // Botón siguiente
              Positioned(
                right: 4,
                child: _NavIconButton(
                  icon: Icons.chevron_right_rounded,
                  onTap: _next,
                  tooltip: 'Siguiente',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImage(String pathOrUrl) {
    final isNet =
        pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://');
    if (isNet) {
      return Image.network(
        pathOrUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Center(child: Icon(Icons.broken_image, size: 40)),
      );
    }
    return Image.asset(
      pathOrUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Center(child: Icon(Icons.broken_image, size: 40)),
    );
  }
}

class _NavIconButton extends StatefulWidget {
  const _NavIconButton({required this.icon, required this.onTap, this.tooltip});

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  State<_NavIconButton> createState() => _NavIconButtonState();
}

class _NavIconButtonState extends State<_NavIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.92 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 6,
        shadowColor: Colors.black.withValues(alpha: 0.25),
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (v) => setState(() => _pressed = v),
          customBorder: const CircleBorder(),
          splashColor: Colors.black.withValues(alpha: 0.08),
          highlightColor: Colors.black.withValues(alpha: 0.05),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(widget.icon, color: Colors.black, size: 20),
          ),
        ),
      ),
    );
  }
}
