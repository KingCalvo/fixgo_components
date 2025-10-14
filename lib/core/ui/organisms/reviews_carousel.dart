import 'package:flutter/material.dart';

class ReviewInfo {
  final String name; // "Carlos Pinzón"
  final String location; // "Yautepec, Morelos"
  final String avatarUrl; // Firebase/URL
  final int rating; // 0..5 (entero)
  final String timeAgoText; // "Hace 1 semana"
  final String comment; // texto de reseña
  final DateTime? createdAt; // opcional (si viene de BD)
  final int?
  ageRank; // opcional: 0 = más reciente (fallback si no hay createdAt)

  const ReviewInfo({
    required this.name,
    required this.location,
    required this.avatarUrl,
    required this.rating,
    required this.timeAgoText,
    required this.comment,
    this.createdAt,
    this.ageRank,
  });
}

/// Carrusel horizontal de reseñas
/// - Ancho base 969, alto mínimo 158
/// - Si hay >4-5 reseñas, aparece scroll horizontal.
/// - Cada columna: 230x157 aprox., separadas por una línea vertical.
class ReviewsCarousel extends StatelessWidget {
  final List<ReviewInfo> reviews;

  // Dimensiones base (puedes ajustarlas si lo necesitas)
  final double baseWidth;
  final double minHeight;
  final double columnWidth;
  final double columnHeight;

  const ReviewsCarousel({
    super.key,
    required this.reviews,
    this.baseWidth = 969,
    this.minHeight = 158,
    this.columnWidth = 230,
    this.columnHeight = 157,
  });

  @override
  Widget build(BuildContext context) {
    // Ordenar: de menor tiempo a mayor (más reciente primero)
    final data = [...(reviews.isNotEmpty ? reviews : _fallback)]
      ..sort((a, b) {
        if (a.createdAt != null && b.createdAt != null) {
          return b.createdAt!.compareTo(a.createdAt!); // más nuevo primero
        }
        return (a.ageRank ?? 999).compareTo(b.ageRank ?? 999);
      });

    return Center(
      child: SizedBox(
        width: baseWidth, // mantiene tamaño real
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _buildColumns(data),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildColumns(List<ReviewInfo> items) {
    final List<Widget> out = [];
    for (int i = 0; i < items.length; i++) {
      out.add(
        _ReviewColumn(info: items[i], width: columnWidth, height: columnHeight),
      );
      if (i != items.length - 1) {
        out.add(
          Container(
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: const Color(0xFFC4C4C4),
          ),
        );
      }
    }
    return out;
  }

  // Fallback para la galería (demo)
  static const _fallback = <ReviewInfo>[
    ReviewInfo(
      name: 'Carlos Pinzón',
      location: 'Yautepec, Morelos',
      avatarUrl: 'https://picsum.photos/seed/carlos/200',
      rating: 4,
      timeAgoText: 'Hace 1 semana',
      comment: 'Excelente trabajo realizado es muy puntual y perfeccionista.',
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
      name: 'Esteban Garcia',
      location: 'Ayala, Morelos',
      avatarUrl: 'https://picsum.photos/seed/esteban/200',
      rating: 4,
      timeAgoText: 'Hace 4 semanas',
      comment:
          'El servicio fue excelente, materiales de primera y resultado impecable.',
      ageRank: 2,
    ),
    ReviewInfo(
      name: 'Enrique Calvo',
      location: 'Yautepec, Morelos',
      avatarUrl: 'https://picsum.photos/seed/enrique/200',
      rating: 4,
      timeAgoText: 'Hace 5 semanas',
      comment:
          'Responsable y amable, cumplió con los tiempos y el resultado fue bueno.',
      ageRank: 3,
    ),
    ReviewInfo(
      name: 'María López',
      location: 'Cuernavaca, Morelos',
      avatarUrl: 'https://picsum.photos/seed/maria/200',
      rating: 5,
      timeAgoText: 'Hace 2 meses',
      comment: 'Trabajo impecable y muy buena comunicación. ¡Recomendado!',
      ageRank: 4,
    ),
  ];
}

class _ReviewColumn extends StatelessWidget {
  final ReviewInfo info;
  final double width;
  final double height;

  const _ReviewColumn({
    required this.info,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        height: height,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Encabezado con avatar redondo + nombre + ubicación
            SizedBox(
              height: 73,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _Avatar(url: info.avatarUrl, size: 70),
                  const SizedBox(width: 10),
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
                            fontWeight:
                                FontWeight.w500, // Regular visual fuerte
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
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // Estrellas + tiempo
            Row(
              children: [
                _StarsRow(rating: info.rating, size: 12, gap: 6),
                const SizedBox(width: 29),
                Text(
                  info.timeAgoText,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w300,
                    fontSize: 10,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Comentario
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                info.comment,
                maxLines: 3,
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
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String url;
  final double size;
  const _Avatar({required this.url, this.size = 70});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.person, size: 40, color: Color(0xFF9E9E9E)),
      ),
    );
  }
}

class _StarsRow extends StatelessWidget {
  final int rating; // 0..5
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
