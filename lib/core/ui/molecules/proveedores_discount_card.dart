import 'package:flutter/material.dart';

class ProviderCategoryTag {
  final String label;
  final String? iconAssetPath;
  const ProviderCategoryTag({required this.label, this.iconAssetPath});
}

class ProviderDiscountData {
  final String providerName;
  final String providerPhotoUrl;
  final List<ProviderCategoryTag> categories;
  final String discountText;

  const ProviderDiscountData({
    required this.providerName,
    required this.providerPhotoUrl,
    required this.categories,
    required this.discountText,
  });
}

class ProviderDiscountCard extends StatelessWidget {
  final ProviderDiscountData data;

  final double baseWidth;
  final double baseHeight;

  const ProviderDiscountCard({
    super.key,
    required this.data,
    this.baseWidth = 346,
    this.baseHeight = 184, // ← antes 178
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth.isFinite ? c.maxWidth : baseWidth;
        final h = c.maxHeight.isFinite ? c.maxHeight : baseHeight;
        final scaleW = w / baseWidth;
        final scaleH = h / baseHeight;
        final scale = scaleW < scaleH ? scaleW : scaleH;

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
        color: const Color(0xFFF0F5FF),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(15), // padding solicitado
      child: Column(
        mainAxisSize: MainAxisSize.min, // ayuda a ajustar la altura
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 10,
            ), // 🔹 mueve la imagen a la derecha
            child: SizedBox(
              width: 70,
              height: 78,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _AvatarCircle(url: data.providerPhotoUrl, size: 70),
              ),
            ),
          ),

          const SizedBox(height: 5),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  data.providerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 30),
              Flexible(
                flex: 0,
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: data.categories
                      .take(3)
                      .map(
                        (c) => _CategoryChip(
                          label: c.label,
                          iconAssetPath: c.iconAssetPath,
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          // (3) Descuento
          Text(
            data.discountText,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              fontSize: 25,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  final String url;
  final double size;
  const _AvatarCircle({required this.url, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.person, size: 28, color: Color(0xFF9E9E9E)),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final String? iconAssetPath;
  const _CategoryChip({required this.label, this.iconAssetPath});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 25, minWidth: 70),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFD4D4D4),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFC3C0C0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: iconAssetPath == null
                  ? const Icon(Icons.handyman, size: 18, color: Colors.black54)
                  : Image.asset(
                      iconAssetPath!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image,
                        size: 18,
                        color: Colors.black54,
                      ),
                    ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
    );
  }
}
