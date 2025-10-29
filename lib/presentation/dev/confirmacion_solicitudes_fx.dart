import 'package:flutter/material.dart';

import '../../core/ui/ui.dart';
import '../../core/utils/service_images.dart';
/* import '../../../core/utils/service_images.dart'; */

class ConfirmacionSolicitudesPage extends StatefulWidget {
  const ConfirmacionSolicitudesPage({super.key});

  @override
  State<ConfirmacionSolicitudesPage> createState() =>
      _ConfirmacionSolicitudesPageState();
}

class _ConfirmacionSolicitudesPageState
    extends State<ConfirmacionSolicitudesPage> {
  // Simula los resultados de Supabase (reemplazar)
  final List<_ProposalItem> _items = [
    _ProposalItem(
      data: ServiceRequestData(
        customerName: 'Juan Pérez',
        customerPhotoUrl: 'https://picsum.photos/seed/jp/200',
        rating: 4.0,
        serviceType: 'Pintura',
        title: 'Pintar sala y comedor',
        materialSource: 'Propio', // del cliente
        location: 'Yautepec, Mor.',
        dateText: '26/08/2025',
        timeText: '17:20 Hrs',
        placeImageUrl: 'https://picsum.photos/seed/room/300/200',
        description:
            'Resane y alisado de superficies, aplicación de sellador y 2 manos de pintura en muros y techo. Trabajo limpio y detallado. Área: 72 m².',
        miniImages: const ['lib/assets/mini1.png', 'lib/assets/mini2.png'],
        totalText: r'$1,200 MXN',
        serviceNumber: '24569',
        proposalStatus: ProposalStatus.pendiente,
        estimatedTimeText: '1 h 20 min',
      ),
      // En status "Pendiente" para la vista del cliente
      pendingView: ProposalPendingView.cliente,
    ),
    _ProposalItem(
      data: ServiceRequestData(
        customerName: 'Juan Pérez',
        customerPhotoUrl: 'https://picsum.photos/seed/jp2/200',
        rating: 4.0,
        serviceType: 'Pintura',
        title: 'Pintar sala',
        materialSource: 'Proveedor',
        location: 'Cuautla, Mor.',
        dateText: '28/08/2025',
        timeText: '17:20 Hrs',
        placeImageUrl: 'https://picsum.photos/seed/room2/300/200',
        description:
            'Resane y alisado de superficies, aplicación de sellador y 2 manos de pintura en muros y techo. Trabajo limpio y detallado. Área: 72 m².',
        miniImages: const ['lib/assets/mini1.png', 'lib/assets/mini2.png'],
        totalText: r'$1,200 MXN',
        serviceNumber: '24570',
        proposalStatus: ProposalStatus.enviada,
        estimatedTimeText: '1 h',
      ),
      pendingView: null,
    ),
    _ProposalItem(
      data: ServiceRequestData(
        customerName: 'Juan Pérez',
        customerPhotoUrl: 'https://picsum.photos/seed/jp3/200',
        rating: 4.0,
        serviceType: 'Pintura',
        title: 'Pintar comedor',
        materialSource: 'Proveedor',
        location: 'Yautepec, Mor.',
        dateText: '29/08/2025',
        timeText: '17:20 Hrs',
        placeImageUrl: 'https://picsum.photos/seed/room3/300/200',
        description:
            'Resane y alisado de superficies, aplicación de sellador y 2 manos de pintura en muros y techo. Trabajo limpio y detallado. Área: 72 m².',
        miniImages: const ['lib/assets/mini1.png', 'lib/assets/mini2.png'],
        totalText: r'$1,200 MXN',
        serviceNumber: '24571',
        proposalStatus: ProposalStatus.aceptada,
        estimatedTimeText: '50 min',
      ),
      pendingView: null,
    ),
  ];

  // Acciones simuladas (sustituye por llamadas a Supabase)

  Future<void> _rejectAt(int index) async {
    final item = _items[index];

    // Supabase → actualizar/archivar/eliminar esta solicitud
    // await supabase.from('solicitudes').update({'status': 'rechazada'}).eq('id', itemId);

    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _confirmAt(int index) async {
    final item = _items[index];

    // Solo aplica a pendientes del cliente: cambia a Enviada
    if (item.data.proposalStatus == ProposalStatus.pendiente) {
      //  Supabase → update status a 'enviada'
      // await supabase.from('solicitudes').update({'status': 'enviada'}).eq('id', itemId);

      setState(() {
        _items[index] = item.copyWith(
          data: item.data.copyWith(proposalStatus: ProposalStatus.enviada),
          pendingView: null,
        );
      });
    }
  }

  // =============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: const [
                  AppTopBar(role: AppUserRole.cliente),
                  InfoBar(title: 'Confirmación de Solicitudes'),
                ],
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.only(top: 10, bottom: 16),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 402),
                    child: Column(
                      children: [
                        for (int i = 0; i < _items.length; i++) ...[
                          _ServiceCardItem(
                            item: _items[i],
                            onReject: () => _rejectAt(i),
                            onConfirm: () => _confirmAt(i),
                          ),
                          if (i != _items.length - 1)
                            const SizedBox(height: 10),
                        ],
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

class _ServiceCardItem extends StatelessWidget {
  final _ProposalItem item;
  final VoidCallback onReject;
  final VoidCallback onConfirm;

  const _ServiceCardItem({
    required this.item,
    required this.onReject,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    // Si miniImages viene vacío, usa los assets locales mapeados por tipo de servicio
    final resolvedData = (item.data.miniImages.isEmpty)
        ? item.data.copyWith(
            miniImages: serviceMiniImages(item.data.serviceType),
          )
        : item.data;

    return ServiceRequestCard(
      variant: ServiceCardVariant.propuesta,
      data: resolvedData,
      proposalPendingView: ProposalPendingView.cliente,
      materialBySupplierOverride: false,
      onReject: onReject,
      onConfirmWithPayload:
          ({double? costOverride, String? estimatedTimeOverride}) {},
      onConfirm: onConfirm,
      autoHeight: true,
    );
  }
}

// Modelo local para la lista (incluye la sub-vista cuando está pendiente)
class _ProposalItem {
  final ServiceRequestData data;
  final ProposalPendingView? pendingView;

  _ProposalItem({required this.data, this.pendingView});

  _ProposalItem copyWith({
    ServiceRequestData? data,
    ProposalPendingView? pendingView,
  }) {
    return _ProposalItem(data: data ?? this.data, pendingView: pendingView);
  }
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
