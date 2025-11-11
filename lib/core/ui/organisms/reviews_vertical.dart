import 'package:flutter/material.dart';
// ⚠️ Ajusta esta ruta a la tuya real:

import 'reviews_carousel.dart' show ReviewInfo, StorageUrlResolver;

/// Lista vertical de reseñas
class ReviewsVertical extends StatelessWidget {
  final List<ReviewInfo> reviews;

  /// Dimensiones de cada tarjeta
  final double itemWidth;
  final double itemHeight;

  final StorageUrlResolver? storageUrlResolver;

  final Map<String, String> Function(String resolvedUrl)? httpHeadersResolver;

  const ReviewsVertical({
    super.key,
    required this.reviews,
    this.itemWidth = 380,
    this.itemHeight = 160,
    this.storageUrlResolver,
    this.httpHeadersResolver,
  });

  @override
  Widget build(BuildContext context) {
    // Ordena por fecha (más reciente primero) o por ageRank si no hay fecha
    final data = [...(reviews.isNotEmpty ? reviews : _fallback)]
      ..sort((a, b) {
        if (a.createdAt != null && b.createdAt != null) {
          return b.createdAt!.compareTo(a.createdAt!);
        }
        return (a.ageRank ?? 999).compareTo(b.ageRank ?? 999);
      });

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: itemWidth),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: data.length,
            separatorBuilder: (_, __) => Container(
              height: 1,
              margin: const EdgeInsets.symmetric(vertical: 8),
              color: const Color(0xFFC4C4C4),
            ),
            itemBuilder: (context, i) {
              return _ReviewTile(
                info: data[i],
                width: itemWidth,
                height: itemHeight,
                storageUrlResolver: storageUrlResolver,
                httpHeadersResolver: httpHeadersResolver,
              );
            },
          ),
        ),
      ),
    );
  }

  // Fallback de prueba
  static const _fallback = <ReviewInfo>[
    ReviewInfo(
      name: 'Carlos Pinzón',
      location: 'Yautepec, Morelos',
      avatarUrl: 'https://picsum.photos/seed/carlos/200',
      rating: 4,
      timeAgoText: 'Hace 1 semana',
      comment: 'Excelente trabajo realizado, muy puntual y perfeccionista.',
      ageRank: 0,
    ),
    ReviewInfo(
      name: 'Kike Eslava',
      location: 'Cuautla, Morelos',
      avatarUrl: 'https://picsum.photos/seed/kike/200',
      rating: 4,
      timeAgoText: 'Hace 2 semanas',
      comment: 'Atento y responsable, se nota la experiencia en cada detalle.',
      ageRank: 1,
    ),
    ReviewInfo(
      name: 'Esteban García',
      location: 'Ayala, Morelos',
      avatarUrl: 'https://picsum.photos/seed/esteban/200',
      rating: 5,
      timeAgoText: 'Hace 3 semanas',
      comment:
          'Servicio excelente, materiales de primera y resultado impecable.',
      ageRank: 2,
    ),
  ];
}

class _ReviewTile extends StatelessWidget {
  final ReviewInfo info;
  final double width;
  final double height;
  final StorageUrlResolver? storageUrlResolver;
  final Map<String, String> Function(String url)? httpHeadersResolver;

  const _ReviewTile({
    required this.info,
    required this.width,
    required this.height,
    this.storageUrlResolver,
    this.httpHeadersResolver,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width, // 380
      height: height, // 160
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER (avatar + nombre/ubicación)
            SizedBox(
              height: 70,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _Avatar(
                    urlOrAsset: info.avatarUrl,
                    storagePath: info.avatarStoragePath,
                    size: 64,
                    storageUrlResolver: storageUrlResolver,
                    httpHeadersResolver: httpHeadersResolver,
                  ),
                  const SizedBox(width: 10),
                  // Bloque superior compacto (no se expande más que su fila)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          info.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          info.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _StarsRow(rating: info.rating, size: 12, gap: 6),
                            const SizedBox(width: 16),
                            Flexible(
                              child: Text(
                                info.timeAgoText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w300,
                                  fontSize: 10,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // COMENTARIO (se expande a todo el ancho disponible)
            Expanded(
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  info.comment,
                  // Permite varias líneas dentro de la altura restante.
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Colors.black,
                    height: 1.25,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String urlOrAsset;
  final String? storagePath;
  final double size;
  final StorageUrlResolver? storageUrlResolver;
  final Map<String, String> Function(String url)? httpHeadersResolver;

  const _Avatar({
    required this.urlOrAsset,
    this.storagePath,
    this.size = 64,
    this.storageUrlResolver,
    this.httpHeadersResolver,
  });

  bool get _isHttp =>
      urlOrAsset.startsWith('http://') || urlOrAsset.startsWith('https://');
  bool get _isAsset => urlOrAsset.startsWith('assets/');

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (storagePath != null && storageUrlResolver != null) {
      child = FutureBuilder<String>(
        future: storageUrlResolver!(storagePath!),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return _placeholder();
          }
          if (!snap.hasData || snap.data == null) {
            return _errorIcon();
          }
          final resolvedUrl = snap.data!;
          final headers = httpHeadersResolver != null
              ? httpHeadersResolver!(resolvedUrl)
              : null;
          return Image.network(
            resolvedUrl,
            headers: headers,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _errorIcon(),
          );
        },
      );
    } else if (_isHttp) {
      child = Image.network(
        urlOrAsset,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _errorIcon(),
      );
    } else if (_isAsset) {
      child = Image.asset(
        urlOrAsset,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _errorIcon(),
      );
    } else {
      child = _errorIcon();
    }

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  Widget _placeholder() => Container(
    color: const Color(0xFFEAEAEA),
    child: const Center(
      child: SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    ),
  );

  Widget _errorIcon() =>
      const Icon(Icons.person, size: 40, color: Color(0xFF9E9E9E));
}

class _StarsRow extends StatelessWidget {
  final int rating;
  final double size;
  final double gap;
  const _StarsRow({required this.rating, this.size = 12, this.gap = 6});

  @override
  Widget build(BuildContext context) {
    final List<Widget> stars = [];
    for (int i = 0; i < 5; i++) {
      final filled = i < rating;
      stars.add(
        Icon(
          filled ? Icons.star : Icons.star_border,
          size: size,
          color: filled ? const Color(0xFFFFC107) : Colors.black87,
        ),
      );
      if (i != 4) stars.add(SizedBox(width: gap));
    }
    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }
}
