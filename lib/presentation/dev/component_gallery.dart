import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import '../../core/ui/ui.dart';

class ComponentGallery extends StatefulWidget {
  const ComponentGallery({Key? key}) : super(key: key);

  @override
  State<ComponentGallery> createState() => _ComponentGalleryState();
}

class _ComponentGalleryState extends State<ComponentGallery> {
  RoleSwitchValue _role = RoleSwitchValue.cliente;
  bool _acceptedTerms = false;

  void _show(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  // --- Helper para títulos de sección ---
  Widget _versionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 32.0, bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  // Base de datos de prueba con parámetros variables
  ServiceRequestData _baseData({
    String? serviceNumber,
    ProposalStatus? pStatus,
    String? estimated,
    ServiceStatus? sStatus,
    String materialSource = 'Propio',
    String totalText = r'$1,200 MXN',
    String title = 'Pintar sala y comedor',
  }) {
    return ServiceRequestData(
      customerName: 'Carlos Pinzón',
      customerPhotoUrl: 'lib/assets/duncan.jpg',
      rating: 4.0,
      serviceType: 'Pintura',
      title: title,
      materialSource: materialSource,
      location: 'Yautepec Mor.',
      dateText: '26/08/2025',
      timeText: '17:20 Hrs',
      placeImageUrl: 'lib/assets/vacia.jpg',
      description:
          'Resane y alisado de superficies, aplicación de sellador y 2 manos de pintura en muros y techo. '
          'Trabajo limpio y detallado. Área: 72 m².',
      miniImages: const ['lib/assets/mini1.png', 'lib/assets/mini2.png'],
      totalText: totalText,
      serviceNumber: serviceNumber,
      proposalStatus: pStatus,
      estimatedTimeText: estimated,
      serviceStatus: sStatus,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileData = ProviderProfileHeaderData(
      name: 'Juan Pérez',
      rating: 4.9,
      reviews: 88,
      imageUrl: 'https://picsum.photos/400',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Component Gallery (Dev)'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppTopBar(
                    role: AppUserRole.cliente,
                    onMenuSelected: (id) => _show(context, 'Hamburguesa → $id'),
                    onUserSelected: (id) => _show(context, 'Usuario → $id'),
                  ),
                  const SizedBox(height: 12),

                  // Profile header
                  ProfileHeaderCard(
                    data: profileData,
                    onBack: () => _show(context, 'Back pressed (Profile)'),
                    onSettings: () =>
                        _show(context, 'Settings pressed (Profile)'),
                  ),

                  const SizedBox(height: 48),

                  // Logo + Slogan
                  LogoSloganCard(logoAsset: 'lib/assets/LogoNaranja.png'),

                  const SizedBox(height: 24),

                  // Login Button
                  LoginButton(
                    onPressed: (_) => _show(context, 'Tap: Iniciar sesión'),
                    payload: {'source': 'gallery-login'},
                  ),

                  // Logo + Name
                  const SizedBox(height: 48),
                  LogoNameCard(logoAsset: 'lib/assets/LogoVerde.png'),

                  // Role Switch
                  const SizedBox(height: 24),
                  RoleSwitch(
                    value: _role,
                    onChanged: (v) {
                      setState(() => _role = v);
                      _show(
                        context,
                        'Switch: ${v == RoleSwitchValue.cliente ? 'Cliente' : 'Proveedor'}',
                      );
                    },
                  ),

                  // Terms Consent Row
                  const SizedBox(height: 16),
                  TermsConsentRow(
                    value: _acceptedTerms,
                    onChanged: (v) => setState(() => _acceptedTerms = v),
                    onTermsTap: () =>
                        _show(context, 'Abrir: Términos del servicio'),
                  ),

                  // SERVICE CARDS (TODAS LAS VERSIONES)
                  _versionTitle('Solicitud'),
                  ServiceRequestCard(
                    variant: ServiceCardVariant.solicitud,
                    data: _baseData(),
                    onReject: () => _show(context, 'Rechazar (Solicitud)'),
                    onConfirm: () => _show(context, 'Confirmar (Solicitud)'),
                  ),

                  _versionTitle('Propuesta — Pendiente (Cliente)'),
                  ServiceRequestCard(
                    variant: ServiceCardVariant.propuesta,
                    data: _baseData(
                      serviceNumber: '24569',
                      pStatus: ProposalStatus.pendiente,
                      estimated: '17:30 hrs',
                      materialSource: 'Proveedor',
                    ),
                    proposalPendingView: ProposalPendingView.cliente,
                    onReject: () =>
                        _show(context, 'Rechazar (Pendiente Cliente)'),
                    onConfirmWithPayload:
                        ({
                          double? costOverride,
                          String? estimatedTimeOverride,
                        }) {
                          _show(
                            context,
                            'Confirmar (Pendiente Cliente) → cost: ${costOverride ?? '-'}, hora: ${estimatedTimeOverride ?? '-'}',
                          );
                        },
                    onConfirm: () =>
                        debugPrint('Confirm base (Pendiente Cliente)'),
                    onTermsTap: () =>
                        _show(context, 'Abrir términos (Cliente)'),
                  ),

                  _versionTitle(
                    'Propuesta — Pendiente (Proveedor, material del PROVEEDOR)',
                  ),
                  ServiceRequestCard(
                    variant: ServiceCardVariant.propuesta,
                    data: _baseData(
                      serviceNumber: '24570',
                      pStatus: ProposalStatus.pendiente,
                      estimated: '17:30',
                      materialSource: 'Proveedor',
                      totalText: r'$1200 MXN',
                    ),
                    proposalPendingView: ProposalPendingView.proveedor,
                    onModifyEstimatedTimeTap: () => _show(
                      context,
                      'Abrir input: Hora estimada (Proveedor)',
                    ),
                    onReject: () => _show(
                      context,
                      'Rechazar (Pendiente Proveedor c/costo)',
                    ),
                    onConfirmWithPayload:
                        ({
                          double? costOverride,
                          String? estimatedTimeOverride,
                        }) {
                          _show(
                            context,
                            'Confirmar (Pendiente Proveedor c/costo) → costo nuevo: ${costOverride ?? 0}, hora nueva: ${estimatedTimeOverride ?? '-'}',
                          );
                        },
                    onConfirm: () => debugPrint(
                      'Confirm base (Pendiente Proveedor c/costo)',
                    ),
                    onTermsTap: () =>
                        _show(context, 'Abrir términos (Proveedor)'),
                  ),

                  _versionTitle(
                    'Propuesta — Pendiente (Proveedor, material del CLIENTE)',
                  ),
                  ServiceRequestCard(
                    variant: ServiceCardVariant.propuesta,
                    data: _baseData(
                      serviceNumber: '24571',
                      pStatus: ProposalStatus.pendiente,
                      estimated: '17:30',
                      materialSource: 'Propio',
                      totalText: r'$900 MXN',
                    ),
                    proposalPendingView: ProposalPendingView.proveedor,
                    onModifyEstimatedTimeTap: () => _show(
                      context,
                      'Abrir input: Hora estimada (Proveedor, sin costo)',
                    ),
                    onReject: () => _show(
                      context,
                      'Rechazar (Pendiente Proveedor s/costo)',
                    ),
                    onConfirmWithPayload:
                        ({
                          double? costOverride,
                          String? estimatedTimeOverride,
                        }) {
                          _show(
                            context,
                            'Confirmar (Pendiente Proveedor s/costo) → costo: ${costOverride ?? '-'}, hora nueva: ${estimatedTimeOverride ?? '-'}',
                          );
                        },
                    onConfirm: () => debugPrint(
                      'Confirm base (Pendiente Proveedor s/costo)',
                    ),
                    onTermsTap: () =>
                        _show(context, 'Abrir términos (Proveedor)'),
                  ),

                  _versionTitle('Propuesta — Enviada'),
                  ServiceRequestCard(
                    variant: ServiceCardVariant.propuesta,
                    data: _baseData(
                      serviceNumber: '24572',
                      pStatus: ProposalStatus.enviada,
                      estimated: '1 h 20 min',
                      materialSource: 'Proveedor',
                      totalText: r'$1350 MXN',
                    ),
                    onReject: () =>
                        _show(context, 'Rechazar (Propuesta Enviada)'),
                    onConfirmWithPayload:
                        ({
                          double? costOverride,
                          String? estimatedTimeOverride,
                        }) {
                          _show(
                            context,
                            'Confirmar (Propuesta Enviada) → costo: ${costOverride ?? '-'}, hora: ${estimatedTimeOverride ?? '-'}',
                          );
                        },
                    onConfirm: () =>
                        debugPrint('Confirm base (Propuesta Enviada)'),
                    onTermsTap: () =>
                        _show(context, 'Abrir términos (Enviada)'),
                  ),

                  _versionTitle('Propuesta — Aceptada'),
                  ServiceRequestCard(
                    variant: ServiceCardVariant.propuesta,
                    data: _baseData(
                      serviceNumber: '24573',
                      pStatus: ProposalStatus.aceptada,
                      estimated: '1 h',
                      materialSource: 'Proveedor',
                      totalText: r'$1000 MXN',
                    ),
                    onReject: () =>
                        _show(context, 'Rechazar (Propuesta Aceptada)'),
                    onConfirmWithPayload:
                        ({
                          double? costOverride,
                          String? estimatedTimeOverride,
                        }) {
                          _show(
                            context,
                            'Confirmar (Propuesta Aceptada) → costo: ${costOverride ?? '-'}, hora: ${estimatedTimeOverride ?? '-'}',
                          );
                        },
                    onConfirm: () =>
                        debugPrint('Confirm base (Propuesta Aceptada)'),
                    onTermsTap: () =>
                        _show(context, 'Abrir términos (Aceptada)'),
                  ),

                  _versionTitle('Servicio — Activo'),
                  ServiceRequestCard(
                    variant: ServiceCardVariant.servicio,
                    data: _baseData(
                      serviceNumber: '30001',
                      sStatus: ServiceStatus.activo,
                      materialSource: 'Proveedor',
                      totalText: r'$1500 MXN',
                      title: 'Pintar sala y comedor',
                    ),
                    onChat: () => _show(context, 'Chat'),
                    onCall: () => _show(context, 'Llamar'),
                    onCancel: () =>
                        _show(context, 'Cancelar (Servicio Activo)'),
                    onReport: () =>
                        _show(context, 'Reportar (Servicio Activo)'),
                    onConclude: () =>
                        _show(context, 'Concluir (Servicio Activo)'),
                  ),

                  _versionTitle('Servicio — Finalizado'),
                  ServiceRequestCard(
                    variant: ServiceCardVariant.servicio,
                    data: _baseData(
                      serviceNumber: '30002',
                      sStatus: ServiceStatus.finalizado,
                      totalText: r'$2050 MXN',
                      title: 'Pintar sala y comedor',
                    ),
                    onOpenReceipt: () => _show(context, 'Abrir comprobante'),
                  ),

                  _versionTitle('Servicio — Cancelado'),
                  ServiceRequestCard(
                    variant: ServiceCardVariant.servicio,
                    data: _baseData(
                      serviceNumber: '30003',
                      sStatus: ServiceStatus.cancelado,
                      totalText: r'$0 MXN',
                      title: 'Pintar sala y comedor',
                    ),
                  ),

                  _versionTitle('Servicio — Reportado'),
                  ServiceRequestCard(
                    variant: ServiceCardVariant.servicio,
                    data: _baseData(
                      serviceNumber: '30004',
                      sStatus: ServiceStatus.reportado,
                      totalText: r'$1200 MXN',
                      title: 'Pintar sala y comedor',
                    ),
                  ),

                  // ===========================
                  // Descripción de Servicios
                  const SizedBox(height: 24),
                  ServicesDescription(
                    services: const [
                      ServiceInfo(
                        name: 'Pintura',
                        title: 'Pintura de interiores',
                        experienceText: '8 años de experiencia',
                        costText: 'Costo: \$800 MXN',
                      ),
                      ServiceInfo(
                        name: 'Jardinería',
                        title: 'Poda y mantenimiento',
                        experienceText: '5 años de experiencia',
                        costText: 'Costo: \$700 MXN',
                      ),
                      ServiceInfo(
                        name: 'Plomería',
                        title: 'Reparación de tuberías',
                        experienceText: '2 años de experiencia',
                        costText: 'Costo: \$1200 MXN',
                      ),
                      ServiceInfo(
                        name: 'Electricidad',
                        title: 'Fallas e instalaciones',
                        experienceText: '6 años de experiencia',
                        costText: 'Costo: \$900 MXN',
                      ),
                      ServiceInfo(
                        name: 'Carpintería',
                        title: 'Muebles a medida',
                        experienceText: '4 años de experiencia',
                        costText: 'Costo: \$1100 MXN',
                      ),
                    ],
                  ),

                  // Reseñas en carrusel
                  const SizedBox(height: 48),
                  ReviewsCarousel(
                    reviews: const [
                      ReviewInfo(
                        name: 'Carlos Pinzón',
                        location: 'Yautepec, Morelos',
                        avatarUrl: 'https://picsum.photos/seed/carlos/200',
                        rating: 4,
                        timeAgoText: 'Hace 1 semana',
                        comment:
                            'Excelente trabajo realizado es muy puntual y perfeccionista.',
                        ageRank: 0,
                      ),
                      ReviewInfo(
                        name: 'Kike Eslava',
                        location: 'Cuautla, Morelos',
                        avatarUrl: 'https://picsum.photos/seed/kike/200',
                        rating: 4,
                        timeAgoText: 'Hace 2 semanas',
                        comment:
                            'Atento y responsable, se nota la experiencia en cada detalle.',
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
                        comment:
                            'Trabajo impecable y muy buena comunicación. ¡Recomendado!',
                        ageRank: 4,
                      ),
                    ],
                  ),

                  //  Disponibilidad
                  const SizedBox(height: 24),
                  AvailabilityRow(
                    data: const AvailabilityData(timeRangeText: '9am - 5pm'),
                    onEdit: () => _show(context, 'Editar disponibilidad'),
                  ),

                  // Calificaciones por categoría
                  const SizedBox(height: 24),
                  CategoryRatings(
                    items: const [
                      CategoryRating(label: 'Calidad del trabajo', rating: 4),
                      CategoryRating(
                        label: 'Cumplimiento en tiempo',
                        rating: 4,
                      ),
                      CategoryRating(
                        label: 'Relación precio-calidad',
                        rating: 4,
                      ),
                      CategoryRating(label: 'Trato y comunicación', rating: 3),
                      CategoryRating(label: 'Puntualidad', rating: 5),
                    ],
                  ),

                  // Barra de información
                  const SizedBox(height: 24),
                  InfoBar(
                    title: 'Servicios',
                    onBack: () => _show(context, 'Back pulsado (InfoBar)'),
                  ),

                  // Dashboard de métricas
                  const SizedBox(height: 24),
                  MetricDashboard(
                    children: const [
                      MetricCard(
                        type: MetricCardType.totalProveedores,
                        data: MetricCardData(valueText: '800'),
                      ),
                      MetricCard(
                        type: MetricCardType.totalClientes,
                        data: MetricCardData(valueText: '1,300'),
                      ),
                      MetricCard(
                        type: MetricCardType.ingresosGenerados,
                        data: MetricCardData(valueText: r'$100,830'),
                      ),
                      MetricCard(
                        type: MetricCardType.totalServicios,
                        data: MetricCardData(valueText: '1,200'),
                      ),
                    ],
                  ),

                  // Filtros
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilterPill(
                        variant: FilterVariant.servicios,
                        onChanged: (v, k, val) =>
                            _show(context, 'Filtro $k → $val'),
                      ),
                      FilterPill(
                        variant: FilterVariant.fecha,
                        onChanged: (v, k, val) =>
                            _show(context, 'Filtro $k → $val'),
                      ),
                      FilterPill(
                        variant: FilterVariant.fechaMini,
                        onChanged: (v, k, val) =>
                            _show(context, 'Mini $k → $val'),
                      ),
                      FilterPill(
                        variant: FilterVariant.ubicacion,
                        onChanged: (v, k, val) =>
                            _show(context, 'Ubicación $k → $val'),
                      ),
                    ],
                  ),

                  // Panel de búsqueda
                  const SizedBox(height: 24),
                  SearchPanel(
                    onSearchTap: (q) => _show(context, 'Buscar: $q'),
                    onFilterTap: (f) => _show(context, 'Filtro rápido: $f'),
                  ),

                  // Tarjetas de descuento de proveedor
                  const SizedBox(height: 24),
                  ProviderDiscountCard(
                    data: const ProviderDiscountData(
                      providerName: 'Juan Pérez',
                      providerPhotoUrl: 'https://picsum.photos/seed/prov/200',
                      categories: [
                        ProviderCategoryTag(label: 'Pintura'),
                        ProviderCategoryTag(label: 'Plomería'),
                      ],
                      discountText: '20 % de descuento',
                    ),
                  ),

                  // Tarjetas de descuento por categoría
                  const SizedBox(height: 24),
                  CategoryDiscountCard(
                    data: const CategoryDiscountData(
                      percentText: '20 %',
                      subtitle: 'En categoría',
                      imageAsset: 'lib/assets/JardineriaCard.png',
                    ),
                  ),

                  // Proveedores cercanos
                  const SizedBox(height: 24),
                  NearbyProvidersCard(
                    providers: const [
                      NearbyProviderData(
                        name: "Juan Pérez",
                        location: "Emiliano Zapata",
                        distanceKm: 2.5,
                        rating: 4,
                        photoUrl: "https://picsum.photos/200",
                        categories: ["pintura", "plomeria"],
                      ),
                      NearbyProviderData(
                        name: "Carlos Ruiz",
                        location: "Yautepec",
                        distanceKm: 3.2,
                        rating: 5,
                        photoUrl: "https://picsum.photos/201",
                        categories: ["jardineria", "herreria"],
                      ),
                      NearbyProviderData(
                        name: "Luis García",
                        location: "Cuautla",
                        distanceKm: 4.1,
                        rating: 3,
                        photoUrl: "https://picsum.photos/202",
                        categories: ["albanileria", "pintura"],
                      ),
                    ],
                    onSeeMore: () => debugPrint("Ver más"),
                    onOpenProvider: () => debugPrint("Abrir proveedor"),
                  ),

                  // Proveedores de interes
                  const SizedBox(height: 24),
                  InterestingProvidersSection(
                    items: const [
                      InterestedProviderData(
                        title: 'Ferretería El MARTILLO',
                        description:
                            'Soluciones rápidas y seguras para fugas y tuberías. Te garantizamos un trabajo rápido y eficiente',
                        rating: 4.0,
                        photoUrl: 'https://picsum.photos/seed/store1/200/200',
                      ),
                      InterestedProviderData(
                        title: 'Servicios de Plomería Ramírez',
                        description:
                            'Instalaciones y mantenimiento residencial.',
                        rating: 4.5,
                        photoUrl: 'https://picsum.photos/seed/store2/200/200',
                      ),
                      InterestedProviderData(
                        title: 'Herrería Gómez',
                        description:
                            'Puertas, protecciones y soldadura especializada.',
                        rating: 3.5,
                        photoUrl: 'https://picsum.photos/seed/store3/200/200',
                      ),
                      InterestedProviderData(
                        title: 'Electricidad Pro',
                        description:
                            'Diagnóstico y reparación de instalaciones.',
                        rating: 4.0,
                        photoUrl: 'https://picsum.photos/seed/store4/200/200',
                      ),
                    ],
                    initialVisible: 3,
                    onKnow: (item) => debugPrint('Conocer: ${item.title}'),
                    onHire: (item) => debugPrint('Contratar: ${item.title}'),
                  ),

                  // Publicar trabajo Card
                  const SizedBox(height: 24),
                  PublishPromptCard(
                    data: const PublishPromptData(
                      imageAsset: 'lib/assets/PublicarCard.png',
                    ),
                  ),

                  // Carrusel de imágenes
                  const SizedBox(height: 24),
                  ImageCarousel(
                    images: const [
                      'https://picsum.photos/seed/pic1/600/400',
                      'https://picsum.photos/seed/pic2/600/400',
                      'https://picsum.photos/seed/pic3/600/400',
                    ],
                    onIndexChanged: (i) => debugPrint('Carrusel índice: $i'),
                  ),

                  // Botones de contratar
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 392,
                    child: HireButton(
                      onPressed: () {
                        debugPrint('Contratar pulsado');
                      },
                    ),
                  ),

                  // Boton de publicar trabajo
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 392,
                    child: PublishButton(
                      onPressed: () {
                        debugPrint('Publicar trabajo pulsado');
                      },
                    ),
                  ),

                  // Subidor de imágenes
                  const SizedBox(height: 24),
                  ImageUploader4(
                    onChanged: (files) {
                      debugPrint(
                        'Subidas: ${files.where((f) => f != null).length}',
                      );
                    },
                  ),

                  // Selector de categoría de servicio
                  const SizedBox(height: 24),
                  ServiceCategorySelector(
                    onChanged: (list) =>
                        _show(context, 'Categorías: ${list.join(", ")}'),
                  ),

                  // Selector de fecha propuesta
                  const SizedBox(height: 24),
                  ProposedDatePicker(
                    initialDate: DateTime.now().add(const Duration(days: 2)),
                    onDateChanged: (date) =>
                        debugPrint('Fecha propuesta: $date'),
                  ),

                  // Input de formulario
                  const SizedBox(height: 24),
                  LabeledFormInput(
                    name: 'job_title',
                    title: 'Titulo del trabajo',
                    hintText: 'Ej. Pintar sala y comedor',
                    onChanged: (val) => debugPrint('Título: $val'),
                  ),

                  // Sección de ubicación de trabajo
                  const SizedBox(height: 24),
                  JobLocationSection(
                    data: const JobLocationData(
                      addressText: 'Ubicación actual / Yautepec Morelos',
                      point: LatLng(18.8836, -99.0667),
                    ),
                    resolveAddress: (address) async {
                      try {
                        final list = await locationFromAddress(address);
                        if (list.isNotEmpty) {
                          final loc = list.first;
                          return LatLng(loc.latitude, loc.longitude);
                        }
                        return null;
                      } catch (e) {
                        return null;
                      }
                    },
                    onAddressSubmitted: (txt) => debugPrint('Buscar: $txt'),
                    onMapTap: (p) => debugPrint(
                      'Nuevo punto: ${p.latitude}, ${p.longitude}',
                    ),
                  ),
                ],
              ),
            ),

            // Botón flotante
            Positioned(
              right: 16,
              bottom: 16,
              child: BotFab(
                data: BotFabData(
                  imageAsset: 'lib/assets/bot.png',
                  onTap: () => _show(context, 'Abrir chat del bot'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
