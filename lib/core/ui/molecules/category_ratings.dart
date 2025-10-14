import 'package:flutter/material.dart';

class CategoryRating {
  final String label;
  final int rating;

  const CategoryRating({required this.label, required this.rating});
}

/// Lista de categorías con estrellas
class CategoryRatings extends StatelessWidget {
  final List<CategoryRating> items;

  /// Estilo
  final double baseWidth;
  final EdgeInsets padding;
  final double starSize;
  final double starGap;

  const CategoryRatings({
    super.key,
    required this.items,
    this.baseWidth = 374,
    this.padding = const EdgeInsets.all(10),
    this.starSize = 18.22,
    this.starGap = 8,
  });

  @override
  Widget build(BuildContext context) {
    // Si no mandan nada, mostramos 5 por defecto como ejemplo
    final data = items.isNotEmpty
        ? items
        : const [
            CategoryRating(label: 'Calidad del trabajo', rating: 4),
            CategoryRating(label: 'Cumplimiento en tiempo', rating: 4),
            CategoryRating(label: 'Relación precio-calidad', rating: 4),
            CategoryRating(label: 'Trato y comunicación', rating: 3),
            CategoryRating(label: 'Puntualidad', rating: 5),
          ];

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: baseWidth),
      child: Container(
        width: baseWidth,
        color: Colors.white,
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < data.length; i++) ...[
              _CategoryRow(
                label: data[i].label,
                rating: data[i].rating.clamp(0, 5),
                starSize: starSize,
                starGap: starGap,
              ),
              if (i != data.length - 1) const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String label;
  final int rating;
  final double starSize;
  final double starGap;

  const _CategoryRow({
    required this.label,
    required this.rating,
    required this.starSize,
    required this.starGap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Texto a la izquierda, que puede partir en varias líneas si no cabe
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Colors.black,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(width: 10),
        _StarsRow(rating: rating, size: starSize, gap: starGap),
      ],
    );
  }
}

class _StarsRow extends StatelessWidget {
  final int rating;
  final double size;
  final double gap;

  const _StarsRow({
    required this.rating,
    required this.size,
    required this.gap,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> stars = [];
    for (int i = 0; i < 5; i++) {
      final filled = i < rating;
      stars.add(
        Icon(
          filled ? Icons.star : Icons.star_border,
          size: size,
          color: filled ? const Color(0xFFFFC107) : Colors.black,
        ),
      );
      if (i != 4) stars.add(SizedBox(width: gap));
    }
    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }
}
