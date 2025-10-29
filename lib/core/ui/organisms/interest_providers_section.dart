import 'package:flutter/material.dart';

// Componente que muestra proveedores de interés, lo usa el cliente.

class InterestedProviderData {
  final String title;
  final String description;
  final double rating;
  final String photoUrl;

  const InterestedProviderData({
    required this.title,
    required this.description,
    required this.rating,
    required this.photoUrl,
  });
}

class InterestingProvidersSection extends StatefulWidget {
  /// Nuevo: título configurable
  final String title;

  /// Lista completa (se ordena y se toma el top 7 internamente)
  final List<InterestedProviderData> items;

  /// Cuántos mostrar al inicio
  final int initialVisible;

  /// Callbacks (preparadas para navegación en el futuro).
  final void Function(InterestedProviderData item)? onKnow;
  final void Function(InterestedProviderData item)? onHire;

  final double baseWidth;

  const InterestingProvidersSection({
    super.key,
    required this.items,
    this.title = 'También te podría interesar',
    this.initialVisible = 3,
    this.onKnow,
    this.onHire,
    this.baseWidth = 412,
  });

  @override
  State<InterestingProvidersSection> createState() =>
      _InterestingProvidersSectionState();
}

class _InterestingProvidersSectionState
    extends State<InterestingProvidersSection>
    with TickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    // Ordenar por rating desc
    final sorted = [...widget.items]
      ..sort((a, b) => b.rating.compareTo(a.rating));

    // Tomar solo TOP 7
    final top = sorted.take(7).toList();

    final maxVisible = top.length; // <= 7
    final collapsed = maxVisible.clamp(0, widget.initialVisible);
    final visibleCount = _expanded ? maxVisible : collapsed;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: widget.baseWidth),
      child: Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              height: 1,
              width: double.infinity,
              color: const Color(0xFFC4C4C4),
            ),

            const SizedBox(height: 10),

            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: Column(
                children: List.generate(visibleCount, (i) {
                  final item = top[i];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: i == visibleCount - 1 ? 0 : 10,
                    ),
                    child: _InterestedCard(
                      item: item,
                      onKnow: () => widget.onKnow?.call(item),
                      onHire: () => widget.onHire?.call(item),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 10),

            // Ver más / Ver menos (solo si hay más de initialVisible dentro del top 7)
            if (maxVisible > collapsed)
              _SeeMoreBar(
                expanded: _expanded,
                onTap: () => setState(() => _expanded = !_expanded),
              ),
          ],
        ),
      ),
    );
  }
}

/// Card individual
class _InterestedCard extends StatefulWidget {
  final InterestedProviderData item;
  final VoidCallback? onKnow;
  final VoidCallback? onHire;

  const _InterestedCard({required this.item, this.onKnow, this.onHire});

  @override
  State<_InterestedCard> createState() => _InterestedCardState();
}

class _InterestedCardState extends State<_InterestedCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: Material(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(8),
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        child: InkWell(
          onHighlightChanged: (v) => setState(() => _pressed = v),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen izquierda
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.item.photoUrl,
                    width: 56,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 86,
                      height: 100,
                      color: const Color(0xFFE0E0E0),
                      child: const Icon(Icons.store, color: Colors.black54),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Texto + estrellas + botones
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      Text(
                        widget.item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Descripción
                      Text(
                        widget.item.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w300,
                          fontSize: 10,
                          color: Colors.black,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Estrellas + botones
                      Row(
                        children: [
                          const SizedBox(width: 4),
                          _StarsRow12(rating: widget.item.rating),
                          const Spacer(),
                          _SmallActionButton(
                            label: 'Conocer',
                            color: const Color(0xFF2E7D32),
                            onTap: widget.onKnow,
                          ),
                          const SizedBox(width: 10),
                          _SmallActionButton(
                            label: 'Contratar',
                            color: const Color(0xFFF86117),
                            onTap: widget.onHire,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Barra "Ver más"
class _SeeMoreBar extends StatefulWidget {
  final bool expanded;
  final VoidCallback onTap;

  const _SeeMoreBar({required this.expanded, required this.onTap});

  @override
  State<_SeeMoreBar> createState() => _SeeMoreBarState();
}

class _SeeMoreBarState extends State<_SeeMoreBar> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.99 : 1,
      duration: const Duration(milliseconds: 90),
      child: Material(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(6),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.18),
        child: InkWell(
          onHighlightChanged: (v) => setState(() => _pressed = v),
          borderRadius: BorderRadius.circular(6),
          onTap: widget.onTap,
          child: SizedBox(
            width: double.infinity,
            height: 24,
            child: Row(
              children: [
                const SizedBox(width: 10),
                Text(
                  widget.expanded ? 'Ver menos' : 'Ver más',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                Icon(
                  widget.expanded
                      ? Icons.expand_less_rounded
                      : Icons.chevron_right_rounded,
                  size: 18,
                  color: Colors.black.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Estrellas
class _StarsRow12 extends StatelessWidget {
  final double rating;
  const _StarsRow12({required this.rating});

  @override
  Widget build(BuildContext context) {
    final int full = rating.floor();
    final bool half = (rating - full) >= 0.5;

    return Row(
      children: List.generate(5, (i) {
        IconData icon;
        Color color;
        if (i < full) {
          icon = Icons.star;
          color = const Color(0xFFFFC107);
        } else if (i == full && half) {
          icon = Icons.star_half;
          color = const Color(0xFFFFC107);
        } else {
          icon = Icons.star_border;
          color = Colors.black;
        }
        return Padding(
          padding: EdgeInsets.only(right: i == 4 ? 0 : 5),
          child: Icon(icon, size: 12, color: color),
        );
      }),
    );
  }
}

class _SmallActionButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _SmallActionButton({
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  State<_SmallActionButton> createState() => _SmallActionButtonState();
}

class _SmallActionButtonState extends State<_SmallActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      child: Material(
        color: widget.color,
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onHighlightChanged: (v) => setState(() => _pressed = v),
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(4),
          splashColor: Colors.white.withValues(alpha: 0.15),
          child: SizedBox(
            width: 82,
            height: 18,
            child: Center(
              child: Text(
                widget.label,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
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
