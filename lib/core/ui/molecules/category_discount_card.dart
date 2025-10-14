import 'package:flutter/material.dart';

/// Datos para hidratar la card (presentación)
class CategoryDiscountData {
  final String percentText;
  final String subtitle;
  /// Imagen de la categoría (usa uno u otro)
  final String? imageAsset; // asset local 116×116
  final String? imageUrl; // url remota 116×116

  const CategoryDiscountData({
    required this.percentText,
    required this.subtitle,
    this.imageAsset,
    this.imageUrl,
  });
}

/// Card de descuento por categoría
class CategoryDiscountCard extends StatelessWidget {
  final CategoryDiscountData data;

  /// Dimensiones base (responsivo con LayoutBuilder)
  final double baseWidth;
  final double baseHeight;

  const CategoryDiscountCard({
    super.key,
    required this.data,
    this.baseWidth = 346,
    this.baseHeight = 178,
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
            child: _content(),
          ),
        );
      },
    );
  }

  Widget _content() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Center(
        // todo centrado dentro de la card
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Textos a la izquierda
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.percentText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600, // semibold
                      fontSize: 25,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    data.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600, // semibold
                      fontSize: 25,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 30),

            // Imagen 116×116 a la derecha
            SizedBox(
              width: 116,
              height: 116,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildImage(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (data.imageAsset != null) {
      return Image.asset(
        data.imageAsset!,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.image_not_supported,
          size: 48,
          color: Color(0xFF9E9E9E),
        ),
      );
    }
    if (data.imageUrl != null) {
      return Image.network(
        data.imageUrl!,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.image, size: 48, color: Color(0xFF9E9E9E)),
      );
    }
    // Placeholder si no se pasa imagen
    return const Center(
      child: Icon(Icons.nature, size: 64, color: Colors.black87),
    );
  }
}
