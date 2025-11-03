import 'package:flutter/material.dart';

// Componentes tuyos
/* import 'package:flutter_fixgo_login/core/components/organisms/app_top_bar.dart';
import 'package:flutter_fixgo_login/core/widgets/organisms/service_card.dart';
import 'package:flutter_fixgo_login/core/utils/service_images.dart';
import 'package:flutter_fixgo_login/core/components/molecules/filters.dart'; */
import '../../core/ui/ui.dart';
import '../../core/utils/service_images.dart';
import '../../presentation/dev/solicitudes_cercanas.dart';

// Nuevas Solicitudes – Proveedor

class NuevasSolicitudesProveedor extends StatefulWidget {
  const NuevasSolicitudesProveedor({Key? key, this.onGoToSolicitudesCercanas})
    : super(key: key);

  final VoidCallback? onGoToSolicitudesCercanas;

  @override
  State<NuevasSolicitudesProveedor> createState() =>
      _NuevasSolicitudesProveedorState();
}

class NoAnimationPageRoute<T> extends PageRouteBuilder<T> {
  NoAnimationPageRoute({required Widget page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      );
}

enum _Tabs { cercanas, nuevas }

class _NuevasSolicitudesProveedorState
    extends State<NuevasSolicitudesProveedor> {
  // Por defecto seleccionado "Nuevas solicitudes"
  _Tabs _tab = _Tabs.nuevas;

  void _goToCercanas() {
    if (widget.onGoToSolicitudesCercanas != null) {
      widget.onGoToSolicitudesCercanas!();
      return;
    }
    Navigator.of(context).pushReplacement(
      NoAnimationPageRoute(page: const SolicitudesCercanasProveedor()),
    );
  }

  // Filtros
  String? _selectedService;
  DateTimeRange? _selectedRange;

  // Simulación de datos:
  final List<_RequestItem> _items = [
    _RequestItem(
      data: ServiceRequestData(
        customerName: 'Rocío Martínez',
        customerPhotoUrl: 'https://picsum.photos/seed/rc1/200',
        rating: 4.7,
        serviceType: 'Electricidad',
        title: 'Cambio de apagadores',
        materialSource: 'Proveedor',
        location: 'Cuernavaca, Mor.',
        dateText: '03/11/2025',
        timeText: '18:40 Hrs',
        placeImageUrl: 'https://picsum.photos/seed/el1/400/280',
        description: 'Reemplazo de 3 apagadores con revisión de corto.',
        miniImages: const [],
        totalText: r'$950 MXN',
        serviceNumber: '21001',
      ),
    ),
    _RequestItem(
      data: ServiceRequestData(
        customerName: 'Carlos Ruiz',
        customerPhotoUrl: 'https://picsum.photos/seed/carl/200',
        rating: 4.2,
        serviceType: 'Plomería',
        title: 'Fuga en lavabo',
        materialSource: 'Propio',
        location: 'Cuernavaca, Mor.',
        dateText: '04/11/2025',
        timeText: '15:30 Hrs',
        placeImageUrl: 'https://picsum.photos/seed/plom1/400/280',
        description: 'Cambio de trampa y ajuste de tuercas.',
        miniImages: const ['lib/assets/mini1.png', 'lib/assets/mini2.png'],
        totalText: r'$650 MXN',
        serviceNumber: '21002',
      ),
    ),
    _RequestItem(
      data: ServiceRequestData(
        customerName: 'Laura Gómez',
        customerPhotoUrl: 'https://picsum.photos/seed/laur/200',
        rating: 4.5,
        serviceType: 'Pintura',
        title: 'Pintar recámara principal',
        materialSource: 'Proveedor',
        location: 'Jiutepec, Mor.',
        dateText: '04/11/2025',
        timeText: '11:00 Hrs',
        placeImageUrl: 'https://picsum.photos/seed/paint1/400/280',
        description: 'Preparación de muros, sellador y 2 manos de pintura.',
        miniImages: const [],
        totalText: r'$1,100 MXN',
        serviceNumber: '21003',
      ),
    ),
    _RequestItem(
      data: ServiceRequestData(
        customerName: 'María López',
        customerPhotoUrl: 'https://picsum.photos/seed/marl/200',
        rating: 4.8,
        serviceType: 'Jardinería',
        title: 'Poda y retiro de residuos',
        materialSource: 'Proveedor',
        location: 'Temixco, Mor.',
        dateText: '05/11/2025',
        timeText: '09:00 Hrs',
        placeImageUrl: 'https://picsum.photos/seed/jard1/400/280',
        description: 'Poda de seto y corte de césped frontal.',
        miniImages: const [],
        totalText: r'$800 MXN',
        serviceNumber: '21004',
      ),
    ),
  ];

  // Acciones por tarjeta
  Future<void> _rejectAt(int index) async {
    final item = _filteredAndSortedItems()[index];
    setState(() {
      _items.removeWhere(
        (e) => e.data.serviceNumber == item.data.serviceNumber,
      );
    });
  }

  Future<void> _confirmAt(int index) async {
    final item = _filteredAndSortedItems()[index];
    // Después: enviar a Supabase con estado "pendiente"
    setState(() {
      _items.removeWhere(
        (e) => e.data.serviceNumber == item.data.serviceNumber,
      );
    });
  }

  DateTime _parseDateTime(ServiceRequestData d) {
    try {
      final dp = d.dateText.split('/');
      final tp = d.timeText.split(' ').first.split(':');
      final year = int.parse(dp[2]);
      final month = int.parse(dp[1]);
      final day = int.parse(dp[0]);
      final hour = int.parse(tp[0]);
      final minute = int.parse(tp[1]);
      return DateTime(year, month, day, hour, minute);
    } catch (_) {
      // fallback: solo fecha
      final dp = d.dateText.split('/');
      return DateTime(int.parse(dp[2]), int.parse(dp[1]), int.parse(dp[0]));
    }
  }

  // Filtrado
  List<_RequestItem> _filteredAndSortedItems() {
    Iterable<_RequestItem> list = _items;

    if (_selectedService != null &&
        _selectedService!.isNotEmpty &&
        _selectedService!.toLowerCase() != 'todos') {
      list = list.where(
        (e) =>
            e.data.serviceType.toLowerCase() == _selectedService!.toLowerCase(),
      );
    }

    if (_selectedRange != null) {
      list = list.where((e) {
        final dt = _parseDateTime(e.data);
        return dt.isAfter(
              _selectedRange!.start.subtract(const Duration(milliseconds: 1)),
            ) &&
            dt.isBefore(
              _selectedRange!.end.add(const Duration(milliseconds: 1)),
            );
      });
    }

    final result = list.toList();
    result.sort(
      (a, b) => _parseDateTime(b.data).compareTo(_parseDateTime(a.data)),
    );
    return result;
  }

  DateTimeRange? _convertirRango(dynamic val) {
    if (val == null) return null;
    if (val is DateTimeRange) return val;

    if (val is Map) {
      final s = val['start'];
      final e = val['end'];
      if (s is DateTime && e is DateTime) {
        return DateTimeRange(start: s, end: e);
      }
    }

    if (val is String) {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart
          .add(const Duration(days: 1))
          .subtract(const Duration(milliseconds: 1));

      switch (val.trim().toLowerCase()) {
        case 'hoy':
          return DateTimeRange(start: todayStart, end: todayEnd);
        case 'esta semana':
        case 'semana':
          final weekday = todayStart.weekday;
          final startOfWeek = todayStart.subtract(Duration(days: weekday - 1));
          final endOfWeek = startOfWeek
              .add(const Duration(days: 7))
              .subtract(const Duration(milliseconds: 1));
          return DateTimeRange(start: startOfWeek, end: endOfWeek);
        case 'este mes':
        case 'mes':
          final startOfMonth = DateTime(todayStart.year, todayStart.month, 1);
          final startOfNextMonth = DateTime(
            todayStart.year,
            todayStart.month + 1,
            1,
          );
          final endOfMonth = startOfNextMonth.subtract(
            const Duration(milliseconds: 1),
          );
          return DateTimeRange(start: startOfMonth, end: endOfMonth);
        case 'últimos 7 días':
        case 'ultimos 7 dias':
        case '7 días':
        case '7 dias':
          final start7 = todayStart.subtract(const Duration(days: 6));
          return DateTimeRange(start: start7, end: todayEnd);
      }

      // "dd/mm/yyyy - dd/mm/yyyy"
      final re = RegExp(
        r'(\d{2})/(\d{2})/(\d{4})\s*-\s*(\d{2})/(\d{2})/(\d{4})',
      );
      final m = re.firstMatch(val);
      if (m != null) {
        final d1 = int.parse(m.group(1)!);
        final m1 = int.parse(m.group(2)!);
        final y1 = int.parse(m.group(3)!);
        final d2 = int.parse(m.group(4)!);
        final m2 = int.parse(m.group(5)!);
        final y2 = int.parse(m.group(6)!);
        final start = DateTime(y1, m1, d1);
        final end = DateTime(y2, m2, d2, 23, 59, 59, 999);
        return DateTimeRange(start: start, end: end);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredAndSortedItems();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: AppTopBar(role: AppUserRole.proveedor),
            ),

            // Switch “Solicitudes cercanas” / “Nuevas solicitudes”
            SliverToBoxAdapter(
              child: Center(
                child: SizedBox(
                  width: 412,
                  height: 46,
                  child: _SwitchHeader(
                    tab: _tab,
                    onTapCercanas: _goToCercanas, // <-- sin setState aquí
                    onTapNuevas: () {
                      // Ya estamos en "Nuevas"; no animes nada extra
                    },
                  ),
                ),
              ),
            ),

            // Título + filtros
            const SliverPadding(padding: EdgeInsets.only(top: 10)),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 412),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Solicitudes',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 60),
                        // Filtro: servicios
                        FilterPill(
                          variant: FilterVariant.servicios,
                          onChanged: (variant, key, val) {
                            setState(() => _selectedService = val.toString());
                          },
                        ),
                        const SizedBox(width: 10),
                        // Filtro: fecha
                        FilterPill(
                          variant: FilterVariant.fecha,
                          onChanged: (variant, key, val) {
                            setState(
                              () => _selectedRange = _convertirRango(val),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Lista de solicitudes
            SliverPadding(
              padding: const EdgeInsets.only(top: 10, bottom: 16),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 402),
                    child: Column(
                      children: [
                        for (int i = 0; i < items.length; i++) ...[
                          _SolicitudCardItem(
                            item: items[i],
                            onReject: () => _rejectAt(i),
                            onConfirm: () => _confirmAt(i),
                          ),
                          if (i != items.length - 1) const SizedBox(height: 10),
                        ],
                        if (items.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              'No hay solicitudes que coincidan con tus filtros.',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 13,
                                color: Colors.black.withValues(alpha: 0.65),
                              ),
                            ),
                          ),
                      ],
                    ),
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

class _SwitchHeader extends StatelessWidget {
  const _SwitchHeader({
    required this.tab,
    required this.onTapCercanas,
    required this.onTapNuevas,
  });

  final _Tabs tab;
  final VoidCallback onTapCercanas;
  final VoidCallback onTapNuevas;

  @override
  Widget build(BuildContext context) {
    const underlineWidth = 192.0;
    final isLeft = tab == _Tabs.cercanas;

    return Stack(
      children: [
        Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTapCercanas,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text(
                      'Solicitudes Cercanas',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 40),
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTapNuevas,
                  child: const Text(
                    'Nuevas solicitudes',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        // Subrayado animado
        AnimatedAlign(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          alignment: isLeft ? Alignment.bottomLeft : Alignment.bottomRight,
          child: const Padding(
            padding: EdgeInsets.only(bottom: 2, left: 6, right: 6),
            child: SizedBox(
              width: underlineWidth,
              height: 4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x40000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SolicitudCardItem extends StatelessWidget {
  const _SolicitudCardItem({
    Key? key,
    required this.item,
    required this.onReject,
    required this.onConfirm,
  }) : super(key: key);

  final _RequestItem item;
  final VoidCallback onReject;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    // Autocompletar miniImages según tipo de servicio si viene vacío
    final resolvedData = (item.data.miniImages.isEmpty)
        ? item.data.copyWith(
            miniImages: serviceMiniImages(item.data.serviceType),
          )
        : item.data;

    return ServiceRequestCard(
      variant: ServiceCardVariant.solicitud,
      data: resolvedData,
      onReject: onReject,
      onConfirm: onConfirm,
      autoHeight: true,
    );
  }
}

class _RequestItem {
  final ServiceRequestData data;
  _RequestItem({required this.data});

  _RequestItem copyWith({ServiceRequestData? data}) =>
      _RequestItem(data: data ?? this.data);
}

extension _CopyServiceRequestData on ServiceRequestData {
  ServiceRequestData copyWith({
    String? customerName,
    String? customerPhotoUrl,
    double? rating,
    String? serviceType,
    String? title,
    String? materialSource,
    String? location,
    String? dateText,
    String? timeText,
    String? placeImageUrl,
    String? description,
    List<String>? miniImages,
    String? totalText,
    String? serviceNumber,
    ProposalStatus? proposalStatus,
    String? estimatedTimeText,
    ServiceStatus? serviceStatus,
  }) {
    return ServiceRequestData(
      customerName: customerName ?? this.customerName,
      customerPhotoUrl: customerPhotoUrl ?? this.customerPhotoUrl,
      rating: rating ?? this.rating,
      serviceType: serviceType ?? this.serviceType,
      title: title ?? this.title,
      materialSource: materialSource ?? this.materialSource,
      location: location ?? this.location,
      dateText: dateText ?? this.dateText,
      timeText: timeText ?? this.timeText,
      placeImageUrl: placeImageUrl ?? this.placeImageUrl,
      description: description ?? this.description,
      miniImages: miniImages ?? this.miniImages,
      totalText: totalText ?? this.totalText,
      serviceNumber: serviceNumber ?? this.serviceNumber,
      proposalStatus: proposalStatus ?? this.proposalStatus,
      estimatedTimeText: estimatedTimeText ?? this.estimatedTimeText,
      serviceStatus: serviceStatus ?? this.serviceStatus,
    );
  }
}
