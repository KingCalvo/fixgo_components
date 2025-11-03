import 'package:flutter/material.dart';

import '../../core/ui/ui.dart';
import '../../core/utils/service_images.dart';
/* import '../../../core/utils/service_images.dart'; */

class ConfirmacionProveedorPage extends StatefulWidget {
  const ConfirmacionProveedorPage({super.key});

  @override
  State<ConfirmacionProveedorPage> createState() =>
      _ConfirmacionProveedorPageState();
}

class _ConfirmacionProveedorPageState extends State<ConfirmacionProveedorPage> {
  // Simulación de resultados (cámbialo por tu fetch de Supabase)
  final List<_ProposalItem> _items = [
    _ProposalItem(
      data: ServiceRequestData(
        customerName: 'Juan Pérez',
        customerPhotoUrl: 'https://picsum.photos/seed/jp/200',
        rating: 4.2,
        serviceType: 'Pintura',
        title: 'Pintar sala y comedor',
        materialSource: 'Proveedor',
        location: 'Yautepec, Mor.',
        dateText: '26/08/2025',
        timeText: '17:20 Hrs',
        placeImageUrl: 'https://picsum.photos/seed/room/300/200',
        description:
            'Resane y alisado; sellador + 2 manos. Trabajo limpio. Área: 72 m².',
        miniImages:
            const [], // vacío: se resolverá con serviceMiniImages() que esta en core/utils/service_images.dart
        totalText: r'$1,200 MXN',
        serviceNumber: '24569',
        proposalStatus: ProposalStatus.pendiente,
        estimatedTimeText: '1 h 20 min',
      ),
      // En status PENDIENTE, para proveedor debe ver "modificar hora / costo"
      pendingView: ProposalPendingView.proveedor,
    ),
    _ProposalItem(
      data: ServiceRequestData(
        customerName: 'María López',
        customerPhotoUrl: 'https://picsum.photos/seed/jp2/200',
        rating: 4.7,
        serviceType: 'Herrería',
        title: 'Soldar barandal',
        materialSource: 'Propio',
        location: 'Cuautla, Mor.',
        dateText: '28/08/2025',
        timeText: '12:00 Hrs',
        placeImageUrl: 'https://picsum.photos/seed/room2/300/200',
        description: 'Soldadura de refuerzo y pintura antioxidante.',
        miniImages: const [],
        totalText: r'$900 MXN',
        serviceNumber: '24570',
        proposalStatus: ProposalStatus.enviada,
        estimatedTimeText: '1 h',
      ),
    ),
    _ProposalItem(
      data: ServiceRequestData(
        customerName: 'Carlos Ruiz',
        customerPhotoUrl: 'https://picsum.photos/seed/jp3/200',
        rating: 4.5,
        serviceType: 'Jardinería',
        title: 'Poda ligera y limpieza',
        materialSource: 'Propio',
        location: 'Yautepec, Mor.',
        dateText: '29/08/2025',
        timeText: '09:30 Hrs',
        placeImageUrl: 'https://picsum.photos/seed/room3/300/200',
        description: 'Poda de setos frontales y recolección.',
        miniImages: const [],
        totalText: r'$700 MXN',
        serviceNumber: '24571',
        proposalStatus: ProposalStatus.aceptada,
        estimatedTimeText: '50 min',
      ),
    ),
  ];

  // Acciones simuladas (sustituye)

  Future<void> _rejectAt(int index) async {
    //  update status, etc.
    setState(() => _items.removeAt(index));
  }

  Future<void> _confirmAt(int index) async {
    final item = _items[index];
    if (item.data.proposalStatus == ProposalStatus.pendiente) {
      //  update status a 'enviada'
      setState(() {
        _items[index] = item.copyWith(
          data: item.data.copyWith(proposalStatus: ProposalStatus.enviada),
          pendingView: null,
        );
      });
    }
  }

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
                  AppTopBar(role: AppUserRole.proveedor),
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
    // Si la lista viene vacía, resolvemos miniImages con assets locales por tipo
    final resolvedData = (item.data.miniImages.isEmpty)
        ? item.data.copyWith(
            miniImages: serviceMiniImages(item.data.serviceType),
          )
        : item.data;

    // Para proveedor:
    // Si está PENDIENTE y el material es del proveedor: verá inputs de hora/costo (la card detecta esto con materialSource = 'Proveedor').
    // Si está ENVIADA o ACEPTADA: versiones correspondientes.
    return ServiceRequestCard(
      variant: ServiceCardVariant.propuesta,
      data: resolvedData,
      proposalPendingView: item.pendingView,
      onReject: onReject,
      onConfirmWithPayload:
          ({double? costOverride, String? estimatedTimeOverride}) {},
      onConfirm: onConfirm,
      autoHeight: true,
    );
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
