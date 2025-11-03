import 'package:flutter/material.dart';

/* import 'package:flutter_fixgo_login/core/components/organisms/app_top_bar.dart';
import 'package:flutter_fixgo_login/core/components/molecules/info_bar.dart';
import 'package:flutter_fixgo_login/core/widgets/organisms/service_card.dart';
import 'package:flutter_fixgo_login/core/utils/service_images.dart'; */
import '../../core/ui/ui.dart';
import '../../core/utils/service_images.dart';

class ServiciosActivosUsuario extends StatefulWidget {
  const ServiciosActivosUsuario({Key? key}) : super(key: key);

  @override
  State<ServiciosActivosUsuario> createState() =>
      _ServiciosActivosUsuarioState();
}

class _ServiciosActivosUsuarioState extends State<ServiciosActivosUsuario> {
  // Simulación de datos:
  final List<_ServiceItem> _items = [
    _ServiceItem(
      data: ServiceRequestData(
        customerName: 'Juan Pérez',
        customerPhotoUrl: 'https://picsum.photos/seed/jp1/200',
        rating: 4.0,
        serviceType: 'Pintura',
        title: 'Pintar sala y comedor',
        materialSource: 'Proveedor',
        location: 'Cuernavaca, Mor.',
        dateText: '02/11/2025',
        timeText: '10:30 Hrs',
        placeImageUrl: 'https://picsum.photos/seed/house1/400/280',
        description:
            'Preparación de superficies, sellador y 2 manos de pintura. Área: 70 m².',
        miniImages: const [], // se autocompleta con service_images.dart
        totalText: r'$1,500 MXN',
        serviceNumber: '30001',
        serviceStatus: ServiceStatus.activo,
      ),
    ),
    _ServiceItem(
      data: ServiceRequestData(
        customerName: 'Juan Pérez',
        customerPhotoUrl: 'https://picsum.photos/seed/jp2/200',
        rating: 4.5,
        serviceType: 'Plomería',
        title: 'Reparación de fuga en baño',
        materialSource: 'Propio',
        location: 'Jiutepec, Mor.',
        dateText: '29/10/2025',
        timeText: '12:00 Hrs',
        placeImageUrl: 'https://picsum.photos/seed/house2/400/280',
        description: 'Cambio de cople, ajuste de sellos y pruebas de presión.',
        miniImages: const ['lib/assets/mini1.png', 'lib/assets/mini2.png'],
        totalText: r'$900 MXN',
        serviceNumber: '30002',
        serviceStatus: ServiceStatus.finalizado,
      ),
    ),
    _ServiceItem(
      data: ServiceRequestData(
        customerName: 'Juan Pérez',
        customerPhotoUrl: 'https://picsum.photos/seed/jp3/200',
        rating: 3.8,
        serviceType: 'Jardinería',
        title: 'Poda de jardín frontal',
        materialSource: 'Proveedor',
        location: 'Cuautla, Mor.',
        dateText: '25/10/2025',
        timeText: '09:00 Hrs',
        placeImageUrl: 'https://picsum.photos/seed/house3/400/280',
        description: 'Poda de setos y retiro de residuos.',
        miniImages: const [],
        totalText: r'$700 MXN',
        serviceNumber: '30003',
        serviceStatus: ServiceStatus.cancelado,
      ),
    ),
    _ServiceItem(
      data: ServiceRequestData(
        customerName: 'Juan Pérez',
        customerPhotoUrl: 'https://picsum.photos/seed/jp4/200',
        rating: 4.2,
        serviceType: 'Electricidad',
        title: 'Revisión de corto circuito',
        materialSource: 'Propio',
        location: 'Temixco, Mor.',
        dateText: '27/10/2025',
        timeText: '16:00 Hrs',
        placeImageUrl: 'https://picsum.photos/seed/house4/400/280',
        description: 'Diagnóstico de centro de carga y cambio de pastilla.',
        miniImages: const [],
        totalText: r'$1,100 MXN',
        serviceNumber: '30004',
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
    debugPrint('Chat con servicio: ${_items[index].data.serviceNumber}');
  }

  void _onCall(int index) {
    debugPrint(
      'Llamar a proveedor de servicio: ${_items[index].data.serviceNumber}',
    );
  }

  void _onOpenReceipt(int index) {
    debugPrint('Abrir comprobante: ${_items[index].data.serviceNumber}');
  }

  // ================================================================================================

  @override
  Widget build(BuildContext context) {
    // Si quieres filtrar aquí por estados admitidos
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
            // Top bar + título
            const SliverToBoxAdapter(
              child: Column(
                children: [
                  AppTopBar(role: AppUserRole.cliente),
                  InfoBar(title: 'Servicios'),
                ],
              ),
            ),

            // Lista de services cards
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

    // Si miniImages viene vacío, completa por tipo de servicio
    final resolvedData = (item.data.miniImages.isEmpty)
        ? item.data.copyWith(
            miniImages: serviceMiniImages(item.data.serviceType),
          )
        : item.data;

    // Acciones por estado:
    // Activo: chat, call, cancelar, reportar, concluir
    // Finalizado: abrir comprobante
    // Cancelado/Reportado: sin acciones (solo info)
    return ServiceRequestCard(
      variant: ServiceCardVariant.servicio,
      data: resolvedData,

      // Accionessegún estado
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
