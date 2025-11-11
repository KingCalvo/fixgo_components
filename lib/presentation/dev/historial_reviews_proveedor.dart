import 'package:flutter/material.dart';
import '../../core/ui/ui.dart';

// Ajusta imports a tus rutas reales:
/* import 'package:flutter_fixgo_login/core/components/organisms/app_top_bar.dart';
import 'package:flutter_fixgo_login/core/components/molecules/info_bar.dart';
import 'package:flutter_fixgo_login/core/components/organisms/profile_header.dart';
import 'package:flutter_fixgo_login/core/widgets/molecules/category_ratings.dart';
import 'package:flutter_fixgo_login/core/widgets/molecules/filters_services_date.dart';
import 'package:flutter_fixgo_login/core/widgets/organisms/reviews_vertical.dart';
import 'package:flutter_fixgo_login/core/widgets/organisms/reviews_carousel.dart'
    show ReviewInfo;
 */
class HistorialReviewsProveedorPage extends StatefulWidget {
  const HistorialReviewsProveedorPage({super.key});

  @override
  State<HistorialReviewsProveedorPage> createState() =>
      _HistorialReviewsProveedorPageState();
}

class _HistorialReviewsProveedorPageState
    extends State<HistorialReviewsProveedorPage> {
  // Header del proveedor simulado
  ProviderProfileHeaderData _header = const ProviderProfileHeaderData(
    name: 'Juan Pérez',
    rating: 4.7,
    reviews: 128,
    imageUrl: 'https://picsum.photos/seed/prov-header/400/400',
  );

  // Calificaciones por categoría (simulado)
  final List<CategoryRating> _categoryItems = const [
    CategoryRating(label: 'Calidad del trabajo', rating: 4),
    CategoryRating(label: 'Cumplimiento en tiempo', rating: 4),
    CategoryRating(label: 'Relación precio-calidad', rating: 4),
    CategoryRating(label: 'Trato y comunicación', rating: 3),
    CategoryRating(label: 'Puntualidad', rating: 5),
  ];

  // Reseñas simuladas
  late List<ReviewInfo> _allReviews;

  // Filtro fecha actual
  DateTimeRange? _selectedRange;

  // Expandir/cerrar “ver todas”
  bool _showAll = false;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _allReviews = [
      ReviewInfo(
        name: 'José Pérez',
        location: 'Cuautla, Mor.',
        avatarUrl: 'https://picsum.photos/seed/jose/200',
        rating: 5,
        timeAgoText: 'Hoy',
        comment: 'Excelente servicio. Muy profesional. ',
        createdAt: DateTime(now.year, now.month, now.day, 10, 0, 0), // hoy
        ageRank: 0,
      ),
      ReviewInfo(
        name: 'Ana Torres',
        location: 'Cuernavaca, Mor.',
        avatarUrl: 'https://picsum.photos/seed/ana/200',
        rating: 4,
        timeAgoText: 'Hace 1 día',
        comment: 'Llegó a tiempo y resolvió rápido.',
        createdAt: now.subtract(const Duration(days: 1)), // esta semana
        ageRank: 1,
      ),
      ReviewInfo(
        name: 'Carlos Ruiz',
        location: 'Jiutepec, Mor.',
        avatarUrl: 'https://picsum.photos/seed/carlos/200',
        rating: 4,
        timeAgoText: 'Hace 2 días',
        comment: 'Cuidadoso con los detalles.',
        createdAt: now.subtract(const Duration(days: 2)), // esta semana
        ageRank: 2,
      ),
      ReviewInfo(
        name: 'Laura Méndez',
        location: 'Temixco, Mor.',
        avatarUrl: 'https://picsum.photos/seed/laura/200',
        rating: 4,
        timeAgoText: 'Hace 8 días',
        comment: 'Buen trato y precio razonable.',
        createdAt: now.subtract(
          const Duration(days: 8),
        ), // fuera de “esta semana”, dentro del mes
        ageRank: 3,
      ),
      ReviewInfo(
        name: 'María López',
        location: 'Cuernavaca, Mor.',
        avatarUrl: 'https://picsum.photos/seed/maria/200',
        rating: 5,
        timeAgoText: 'Hace 20 días',
        comment: 'Trabajo impecable y buena comunicación. ¡Recomendado! ',
        createdAt: now.subtract(const Duration(days: 20)),
        ageRank: 4,
      ),
      ReviewInfo(
        name: 'Esteban García',
        location: 'Ayala, Mor.',
        avatarUrl: 'https://picsum.photos/seed/esteban/200',
        rating: 5,
        timeAgoText: 'Hace 25 días',
        comment: 'Gran calidad en materiales, volvería a contratar.',
        createdAt: now.subtract(const Duration(days: 25)),
      ),
    ];
  }

  // Ordenar + Filtrar por _selectedRange
  List<ReviewInfo> get _filteredSorted {
    final list = List<ReviewInfo>.from(_allReviews);

    // Orden: createdAt desc; si no hay, por ageRank asc
    list.sort((a, b) {
      if (a.createdAt != null && b.createdAt != null) {
        return b.createdAt!.compareTo(a.createdAt!);
      }
      return (a.ageRank ?? 999).compareTo(b.ageRank ?? 999);
    });

    final range = _selectedRange;
    if (range == null) return list;

    return list.where((r) {
      final dt = r.createdAt;
      if (dt == null) return true; // si no hay fecha, no filtrar
      final start = _startOfDay(range.start);
      final end = _endOfDay(range.end);
      final afterStart = dt.isAfter(start) || _isSameDay(dt, start);
      final beforeEnd = dt.isBefore(end) || _isSameDay(dt, end);
      return afterStart && beforeEnd;
    }).toList();
  }

  // Top 3 por defecto
  List<ReviewInfo> get _top3 => _filteredSorted.take(3).toList();

  void _onFilterChanged(FilterVariant variant, String key, String value) {
    if (variant == FilterVariant.fecha) {
      setState(() {
        _selectedRange = _rangeForPeriod(value);
        _showAll = false;
      });
    }
  }

  DateTimeRange? _rangeForPeriod(String period) {
    final now = DateTime.now();

    switch (period) {
      case 'Hoy':
        final start = _startOfDay(now);
        final end = _endOfDay(now);
        return DateTimeRange(start: start, end: end);

      case 'Esta semana':
        final weekday = now.weekday;
        final monday = _startOfDay(now.subtract(Duration(days: weekday - 1)));
        final sunday = _endOfDay(monday.add(const Duration(days: 6)));
        return DateTimeRange(start: monday, end: sunday);

      case 'Este mes':
        final first = DateTime(now.year, now.month, 1);
        final nextMonth = (now.month == 12)
            ? DateTime(now.year + 1, 1, 1)
            : DateTime(now.year, now.month + 1, 1);
        final last = _endOfDay(nextMonth.subtract(const Duration(days: 1)));
        return DateTimeRange(start: _startOfDay(first), end: last);

      default:
        return null;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day, 0, 0, 0);
  DateTime _endOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59, 999);

  @override
  Widget build(BuildContext context) {
    const double maxBodyWidth = 412;

    final filtered = _filteredSorted;
    final toShow = _showAll ? filtered : _top3;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top bar
            const SliverToBoxAdapter(
              child: AppTopBar(role: AppUserRole.proveedor),
            ),

            // InfoBar
            const SliverToBoxAdapter(
              child: InfoBar(title: 'Historial de calificaciones'),
            ),

            // Profile header sin flecha/config
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: maxBodyWidth),
                  child: SizedBox(
                    width: double.infinity,
                    height: 319,
                    child: ProfileHeaderCard(
                      data: _header,
                      isEditing: false,
                      onBack: null,
                      onSettings: null,
                    ),
                  ),
                ),
              ),
            ),

            // Category ratings
            const SliverToBoxAdapter(child: SizedBox(height: 15)),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: maxBodyWidth),
                  child: CategoryRatings(items: _categoryItems),
                ),
              ),
            ),

            // Encabezado "Reseñas" + filtro fecha
            const SliverToBoxAdapter(child: SizedBox(height: 25)),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: maxBodyWidth),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        const Text(
                          'Reseñas',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 150),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: FilterPill(
                              variant: FilterVariant.fecha,
                              onChanged: _onFilterChanged,
                              dateOptions: const [
                                'Hoy',
                                'Esta semana',
                                'Este mes',
                              ],
                              showSelectionInLabel: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ReviewsVertical
            const SliverToBoxAdapter(child: SizedBox(height: 15)),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: maxBodyWidth),
                  child: ReviewsVertical(
                    reviews: toShow,
                    itemWidth: 380,
                    itemHeight: 160,
                  ),
                ),
              ),
            ),

            // Ver todas / Ver menos (si hay más de 5 resultados)
            if (filtered.length > 5) ...[
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: maxBodyWidth),
                    child: _SeeMoreBar(
                      expanded: _showAll,
                      onTap: () => setState(() => _showAll = !_showAll),
                    ),
                  ),
                ),
              ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

/// Barra “Ver todas/Ver menos”
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
          splashColor: Colors.black.withValues(alpha: 0.06),
          child: SizedBox(
            width: double.infinity,
            height: 24,
            child: Row(
              children: [
                const SizedBox(width: 10),
                Text(
                  widget.expanded ? 'Ver menos' : 'Ver todas las reseñas',
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
