import 'package:flutter/material.dart';

class LogoNameCard extends StatelessWidget {
  final String logoAsset;
  final String title;
  final Color backgroundColor;
  final Color titleColor;
  final double titleFontSize;
  final double baseWidth;
  final double baseHeight;
  final double padding;
  final double borderRadius;

  const LogoNameCard({
    super.key,
    required this.logoAsset,
    this.title = 'FixGo',
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.titleColor = const Color(0xFF424242),
    this.titleFontSize = 80,
    this.baseWidth = 352,
    this.baseHeight = 111,
    this.padding = 10,
    this.borderRadius = 8,
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
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo 91×91
                    const SizedBox(
                      width: 91,
                      height: 91,
                      child: _SafeAssetImage(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Text(
                          title,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w800,
                            fontSize: titleFontSize,
                            color: titleColor,
                            height: 1.0,
                            shadows: const [
                              Shadow(
                                color: Color(0x33000000),
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
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

/// Usa el asset que llega por el constructor del padre mediante InheritedWidget local.
/// Simplifica el build: el path real lo recibe el padre y lo inyecta con Image.asset().
class _SafeAssetImage extends StatelessWidget {
  const _SafeAssetImage();

  @override
  Widget build(BuildContext context) {
    // Buscamos el LogoNameCard ancestro para leer el asset (no expone Inherited, así que usamos context.findAncestorWidgetOfExactType)
    final parent = context.findAncestorWidgetOfExactType<LogoNameCard>();
    final path = parent?.logoAsset ?? '';

    return Image.asset(
      path,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Container(
        decoration: BoxDecoration(
          color: const Color(0x14000000),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.image_not_supported, color: Color(0x99000000)),
      ),
    );
  }
}
