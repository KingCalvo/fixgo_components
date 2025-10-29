import 'package:flutter/material.dart';

// Componente Logo + Eslogan para el Login, con logo FIJO interno.

class LogoSloganCard extends StatelessWidget {
  static const String _kLogoAssetPath = 'lib/assets/LogoNaranja.png';

  final String title;
  final String slogan;
  final Color backgroundColor;
  final Color titleColor;
  final Color sloganColor;
  final double baseWidth;
  final double baseHeight;
  final double padding;
  final double borderRadius;

  const LogoSloganCard({
    super.key,
    this.title = 'FixGo',
    this.slogan = 'Tu solución al instante. Repara, mejora y sigue con FixGO.',
    this.backgroundColor = const Color(0xFF1F3C88),
    this.titleColor = Colors.white,
    this.sloganColor = Colors.white,
    this.baseWidth = 378,
    this.baseHeight = 199,
    this.padding = 12,
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
            child: _CardBody(
              title: title,
              slogan: slogan,
              backgroundColor: backgroundColor,
              titleColor: titleColor,
              sloganColor: sloganColor,
              padding: padding,
              borderRadius: borderRadius,
            ),
          ),
        );
      },
    );
  }
}

class _CardBody extends StatelessWidget {
  final String title;
  final String slogan;
  final Color backgroundColor, titleColor, sloganColor;
  final double padding, borderRadius;

  const _CardBody({
    required this.title,
    required this.slogan,
    required this.backgroundColor,
    required this.titleColor,
    required this.sloganColor,
    required this.padding,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    const double logoSize = 91;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: logoSize,
                  height: logoSize,
                  child: const _SafeAssetImage(),
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
                        fontSize: 96,
                        color: titleColor,
                        height: 1.0,
                        shadows: const [
                          Shadow(
                            color: Colors.black38,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Flexible(
              child: Text(
                slogan,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  fontSize: 24,
                  color: Colors.white,
                  height: 1.25,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ).copyWithColor(sloganColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _SafeAssetImage extends StatelessWidget {
  const _SafeAssetImage();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      LogoSloganCard._kLogoAssetPath,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.image_not_supported,
          color: Colors.white,
          size: 36,
        ),
      ),
    );
  }
}

extension _TextColorX on Text {
  Text copyWithColor(Color color) => Text(
    data ?? '',
    key: key,
    style: (style ?? const TextStyle()).copyWith(color: color),
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
  );
}
