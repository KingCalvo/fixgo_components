import 'package:flutter/material.dart';

/* import 'package:flutter_fixgo_login/core/components/organisms/app_top_bar.dart';
import 'package:flutter_fixgo_login/core/components/molecules/info_bar.dart';
import 'package:flutter_fixgo_login/core/widgets/organisms/service_card.dart';
import 'package:flutter_fixgo_login/core/utils/service_images.dart'; */
import '../../core/ui/ui.dart';
import '../../core/utils/service_images.dart';

/// Muestra lista de ServiceRequestCard (variante servicio) para estados:
/// Activo, Finalizado, Cancelado, Reportado.
class ServiciosActivosProveedor extends StatefulWidget {
  const ServiciosActivosProveedor({Key? key}) : super(key: key);

  @override
  State<ServiciosActivosProveedor> createState() =>
      _ServiciosActivosProveedorState();
}

class _ServiciosActivosProveedorState extends State<ServiciosActivosProveedor> {
  // Simulación de datos
  final List<_ServiceItem> _items = [
    _ServiceItem(
      data: ServiceRequestData(
        customerName: 'María López',
        customerPhotoUrl: 'https://picsum.photos/seed/c1/200',
        rating: 4.6,
        serviceType: 'Pintura',
        title: 'Pintar recámara principal',
        materialSource: 'Proveedor',
        location: 'Cuernavaca, Mor.',
        dateText: '03/11/2025',
        timeText: '11:00 Hrs',
        placeImageUrl: 'https://picsum.photos/seed/px1/400/280',
        description: 'Sellador y 2 manos de pintura en muros y techo.',
        miniImages: const [], // se autocompleta con service_images.dart
        totalText: r'$1,800 MXN',
        serviceNumber: '40001',
        serviceStatus: ServiceStatus.activo,
      ),
    ),
    _ServiceItem(
      data: ServiceRequestData(
        customerName: 'Carlos Ruiz',
        customerPhotoUrl: 'https://picsum.photos/seed/c2/200',
        rating: 4.9,
        serviceType: 'Plomería',
        title: 'Cambio de mezcladora',
        materialSource: 'Propio',
        location: 'Jiutepec, Mor.',
        dateText: '28/10/2025',
        timeText: '17:00 Hrs',
        placeImageUrl: 'https://picsum.photos/seed/px2/400/280',
        description: 'Retiro de pieza vieja y colocación con prueba de fugas.',
        miniImages: const ['lib/assets/mini1.png', 'lib/assets/mini2.png'],
        totalText: r'$950 MXN',
        serviceNumber: '40002',
        serviceStatus: ServiceStatus.finalizado,
      ),
    ),
    _ServiceItem(
      data: ServiceRequestData(
        customerName: 'Laura Méndez',
        customerPhotoUrl: 'https://picsum.photos/seed/c3/200',
        rating: 3.9,
        serviceType: 'Jardinería',
        title: 'Poda de setos laterales',
        materialSource: 'Proveedor',
        location: 'Temixco, Mor.',
        dateText: '27/10/2025',
        timeText: '09:30 Hrs',
        placeImageUrl: 'https://picsum.photos/seed/px3/400/280',
        description: 'Poda y retiro de residuo vegetal.',
        miniImages: const [],
        totalText: r'$600 MXN',
        serviceNumber: '40003',
        serviceStatus: ServiceStatus.cancelado,
      ),
    ),
    _ServiceItem(
      data: ServiceRequestData(
        customerName: 'Ana Torres',
        customerPhotoUrl: 'https://picsum.photos/seed/c4/200',
        rating: 4.3,
        serviceType: 'Electricidad',
        title: 'Revisión de apagadores',
        materialSource: 'Propio',
        location: 'Cuautla, Mor.',
        dateText: '26/10/2025',
        timeText: '15:00 Hrs',
        placeImageUrl: 'https://picsum.photos/seed/px4/400/280',
        description: 'Diagnóstico y sustitución de apagador dañado.',
        miniImages: const [],
        totalText: r'$500 MXN',
        serviceNumber: '40004',
        serviceStatus: ServiceStatus.reportado,
      ),
    ),
  ];

  Future<void> _setStatusAt(int index, ServiceStatus status) async {
    final item = _items[index];

    // update status

    setState(() {
      _items[index] = item.copyWith(
        data: item.data.copyWith(serviceStatus: status),
      );
    });
  }

  Future<void> _onCancelAt(int index) =>
      _setStatusAt(index, ServiceStatus.cancelado);
  Future<void> _onReportAt(int index) =>
      _setStatusAt(index, ServiceStatus.reportado);
  Future<void> _onConcludeAt(int index) =>
      _setStatusAt(index, ServiceStatus.finalizado);

  void _onChat(int index) {
    debugPrint(
      'Chat con cliente de servicio: ${_items[index].data.serviceNumber}',
    );
  }

  void _onCall(int index) {
    debugPrint('Llamar al cliente: ${_items[index].data.serviceNumber}');
  }

  void _onOpenReceipt(int index) {
    debugPrint('Abrir comprobante: ${_items[index].data.serviceNumber}');
  }

  @override
  Widget build(BuildContext context) {
    final list = _items.where((it) {
      final s = it.data.serviceStatus;
      return s == ServiceStatus.activo ||
          s == ServiceStatus.finalizado ||
          s == ServiceStatus.cancelado ||
          s == ServiceStatus.reportado;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: Column(
                children: [
                  AppTopBar(role: AppUserRole.proveedor),
                  InfoBar(title: 'Servicios'),
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
                        for (int i = 0; i < list.length; i++) ...[
                          _ServiceCardItem(
                            item: list[i],
                            index: i,
                            onChat: () => _onChat(i),
                            onCall: () => _onCall(i),
                            onCancel: () => _onCancelAt(i),
                            onReport: () => _onReportAt(i),
                            onConclude: () => _onConcludeAt(i),
                            onOpenReceipt: () => _onOpenReceipt(i),
                          ),
                          if (i != list.length - 1) const SizedBox(height: 10),
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

class _ServiceItem {
  final ServiceRequestData data;
  _ServiceItem({required this.data});
  _ServiceItem copyWith({ServiceRequestData? data}) =>
      _ServiceItem(data: data ?? this.data);
}

class _ServiceCardItem extends StatelessWidget {
  const _ServiceCardItem({
    Key? key,
    required this.item,
    required this.index,
    required this.onChat,
    required this.onCall,
    required this.onCancel,
    required this.onReport,
    required this.onConclude,
    required this.onOpenReceipt,
  }) : super(key: key);

  final _ServiceItem item;
  final int index;

  final VoidCallback onChat;
  final VoidCallback onCall;
  final VoidCallback onCancel;
  final VoidCallback onReport;
  final VoidCallback onConclude;
  final VoidCallback onOpenReceipt;

  @override
  Widget build(BuildContext context) {
    final status = item.data.serviceStatus;

    // Completar si mini imágenes vienen vacías
    final resolvedData = (item.data.miniImages.isEmpty)
        ? item.data.copyWith(
            miniImages: serviceMiniImages(item.data.serviceType),
          )
        : item.data;

    return ServiceRequestCard(
      variant: ServiceCardVariant.servicio,
      data: resolvedData,

      // Acciones según estado
      onChat: status == ServiceStatus.activo ? onChat : null,
      onCall: status == ServiceStatus.activo ? onCall : null,
      onCancel: status == ServiceStatus.activo ? onCancel : null,
      onReport: status == ServiceStatus.activo ? onReport : null,
      onConclude: status == ServiceStatus.activo ? onConclude : null,

      onOpenReceipt: status == ServiceStatus.finalizado ? onOpenReceipt : null,
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

// Opcional: mapeo si guardas texto
String _mapStatusToDb(ServiceStatus s) => switch (s) {
  ServiceStatus.activo => 'activo',
  ServiceStatus.finalizado => 'finalizado',
  ServiceStatus.cancelado => 'cancelado',
  ServiceStatus.reportado => 'reportado',
};
