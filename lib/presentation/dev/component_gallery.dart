import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
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

  ServiceRequestData _baseData({
    String? serviceNumber,
    ProposalStatus? pStatus,
    String? estimated,
    ServiceStatus? sStatus,
  }) {
    return ServiceRequestData(
      customerName: 'Carlos Pinzón',
      customerPhotoUrl: 'https://picsum.photos/seed/user/200',
      rating: 4.0,
      serviceType: 'Pintura',
      title: 'Pintar sala y comedor',
      materialSource: 'Propio',
      location: 'Yautepec Mor.',
      dateText: '26/08/2025',
      timeText: '17:20 Hrs',
      placeImageUrl: 'https://picsum.photos/seed/room/600/400',
      description:
          'Resane y alisado de superficies, aplicación de sellador y 2 manos de pintura en muros y techo. '
          'Trabajo limpio y detallado. Área: 72 m².',
      miniImages: const ['assets/mini1.png', 'assets/mini2.png'],
      totalText: '\$1,200 MXN',
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
        // 🔽 Ahora el body está envuelto en un Stack para superponer el FAB del bot
        child: Stack(
          children: [
            // Contenido original tal cual lo tenías
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppTopBar(
                    role:
                        AppUserRole.cliente, // prueba también proveedor / admin
                    onMenuSelected: (id) => _show(context, 'Hamburguesa → $id'),
                    onUserSelected: (id) => _show(context, 'Usuario → $id'),
                  ),
                  const SizedBox(height: 12),

                  // 1) Profile header
                  ProfileHeaderCard(
                    data: profileData,
                    onBack: () => _show(context, 'Back pressed (Profile)'),
                    onSettings: () =>
                        _show(context, 'Settings pressed (Profile)'),
                  ),

                  const SizedBox(height: 48),

                  // 2) Logo + Slogan
                  LogoSloganCard(logoAsset: 'assets/LogoNaranja.png'),

                  const SizedBox(height: 24),

                  // 3) Login Button (base 378×28; responsivo)
                  LoginButton(
                    onPressed: (_) => _show(context, 'Tap: Iniciar sesión'),
                    payload: {'source': 'gallery-login'},
                  ),

                  // 4: Logo + Name
                  const SizedBox(height: 48),
                  LogoNameCard(logoAsset: 'assets/LogoVerde.png'),

                  // 5: Role Switch
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
                  // 6: Terms Consent Row
                  const SizedBox(height: 16),
                  TermsConsentRow(
                    value: _acceptedTerms,
                    onChanged: (v) => setState(() => _acceptedTerms = v),
                    onTermsTap: () =>
                        _show(context, 'Abrir: Términos del servicio'),
                  ),

                  // 7: Service Request Card
                  // 1) Solicitud
                  const SizedBox(height: 48),
                  ServiceRequestCard(
                    variant: ServiceCardVariant.solicitud,
                    data: _baseData(),
                    onReject: () => _show(context, 'Rechazar (Solicitud)'),
                    onConfirm: () => _show(context, 'Confirmar (Solicitud)'),
                  ),

                  // 2) Propuesta
                  const SizedBox(height: 48),
                  ServiceRequestCard(
                    variant: ServiceCardVariant.propuesta,
                    data: _baseData(
                      serviceNumber: '24569',
                      pStatus: ProposalStatus.pendiente,
                      estimated: '17:30 hrs',
                    ),
                    onReject: () => _show(context, 'Rechazar (Propuesta)'),
                    onConfirm: () => _show(context, 'Confirmar (Propuesta)'),
                    onModifyEstimatedTime: () =>
                        _show(context, 'Modificar hora'),
                    onTermsTap: () => _show(context, 'Abrir términos'),
                  ),

                  // 3) Servicio (estado: Activo)
                  const SizedBox(height: 48),
                  ServiceRequestCard(
                    variant: ServiceCardVariant.servicio,
                    data: _baseData(
                      serviceNumber: '24569',
                      sStatus: ServiceStatus.activo,
                    ),
                    onChat: () => _show(context, 'Chat'),
                    onCall: () => _show(context, 'Llamar'),
                    onCancel: () => _show(context, 'Cancelar'),
                    onReport: () => _show(context, 'Reportar'),
                    onConclude: () => _show(context, 'Concluir'),
                  ),
                  // 3.b) Servicio (estado: Finalizado)
                  const SizedBox(height: 48),
                  ServiceRequestCard(
                    variant: ServiceCardVariant.servicio,
                    data: _baseData(
                      serviceNumber: '24569',
                      sStatus: ServiceStatus.finalizado,
                    ),
                    onOpenReceipt: () => _show(context, 'Abrir comprobante'),
                  ),

                  // 3.c) Servicio (estado: Cancelado)
                  const SizedBox(height: 48),
                  ServiceRequestCard(
                    variant: ServiceCardVariant.servicio,
                    data: _baseData(
                      serviceNumber: '24569',
                      sStatus: ServiceStatus.cancelado,
                    ),
                  ),

                  // 8: Services Description
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
                        costText: 'Costo: \$1,200 MXN',
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
                        costText: 'Costo: \$1,100 MXN',
                      ),
                    ],
                  ),

                  // Reseñas (Reviews) Carousel
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

                  // Disponibilidad
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

                  // Info Bar
                  const SizedBox(height: 24),
                  InfoBar(
                    title: 'Servicios',
                    onBack: () => _show(context, 'Back pulsado (InfoBar)'),
                  ),

                  // Métricas
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

                  // Tarjeta de descuento del proveedor
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

                  // Tarjeta de descuento por categoría
                  const SizedBox(height: 24),
                  CategoryDiscountCard(
                    data: const CategoryDiscountData(
                      percentText: '20 %',
                      subtitle: 'En categoría',
                      imageUrl: 'https://picsum.photos/seed/garden/116',
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

                  // Sección de proveedores de interés
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

                  // Tarjeta de Publicar Servicio
                  const SizedBox(height: 24),
                  PublishPromptCard(
                    data: const PublishPromptData(
                      imageUrl: 'https://picsum.photos/seed/tool/120',
                    ),
                    // onPublish: () => _show(context, 'Ir a publicar'),
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

                  // Botón Contratar
                  const SizedBox(height: 16),
                  SizedBox(
                    // opcional: para forzar el ancho completo del viewport
                    width: 392, // o MediaQuery.of(context).size.width - 20
                    child: HireButton(
                      onPressed: () {
                        // TODO: navegación a la pantalla de contratación
                        // Navigator.pushNamed(context, '/contratar');
                        debugPrint('Contratar pulsado');
                      },
                    ),
                  ),

                  // Botón Publicar trabajo
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 392, // o MediaQuery.of(context).size.width - 20
                    child: PublishButton(
                      onPressed: () {
                        // TODO: navegar a la pantalla de publicación
                        // Navigator.pushNamed(context, '/publicar');
                        debugPrint('Publicar trabajo pulsado');
                      },
                    ),
                  ),

                  // Cargador de imágenes (4 slots)
                  const SizedBox(height: 24),
                  ImageUploader4(
                    onChanged: (files) {
                      // files.length == 4; cada posición puede ser null o XFile
                      debugPrint(
                        'Subidas: ${files.where((f) => f != null).length}',
                      );
                    },
                  ),

                  // Selector de categorías (ServiceCategorySelector)
                  const SizedBox(height: 24),
                  ServiceCategorySelector(
                    // initialSelected: const ['Pintura'], // opcional
                    onChanged: (list) =>
                        _show(context, 'Categorías: ${list.join(", ")}'),
                  ),

                  // Calendario de fechas (DateCalendar)
                  const SizedBox(height: 24),
                  ProposedDatePicker(
                    initialDate: DateTime.now().add(const Duration(days: 2)),
                    onDateChanged: (date) =>
                        debugPrint('Fecha propuesta: $date'),
                  ),

                  // Input de formulario (FormInput)
                  const SizedBox(height: 24),
                  LabeledFormInput(
                    name: 'job_title',
                    title: 'Titulo del trabajo',
                    hintText: 'Ej. Pintar sala y comedor',
                    onChanged: (val) => debugPrint('Título: $val'),
                  ),

                  // Campo de ubicación del trabajo (JobLocationField)
                  const SizedBox(height: 24),
                  JobLocationSection(
                    data: JobLocationData(
                      addressText: 'Ubicación actual / Yautepec Morelos',
                      point: LatLng(18.8836, -99.0667),
                    ),
                    onAddressSubmitted: (txt) async {
                      // Aquí harías geocoding; por ahora simulo coordenadas:
                      final mock = txt.toLowerCase().contains('centro')
                          ? const LatLng(18.9200, -99.2340)
                          : const LatLng(18.8845, -99.0635);

                      // Actualizar el widget: reconstruye con nuevos datos (desde tu estado padre)
                      // En la gallery puedes simplemente mostrar un snackbar:
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(
                              'Buscar: $txt → (${mock.latitude.toStringAsFixed(4)}, ${mock.longitude.toStringAsFixed(4)})',
                            ),
                          ),
                        );
                    },
                    onMapTap: (p) {
                      // Si el usuario toca el mapa, recibe LatLng aquí (guárdalo para enviar a Supabase)
                      debugPrint('Nuevo punto: ${p.latitude}, ${p.longitude}');
                    },
                  ),
                ],
              ),
            ),

            // 🔝 Botón flotante del bot superpuesto (abajo-derecha)
            Positioned(
              right: 16,
              bottom: 16,
              child: BotFab(
                data: BotFabData(
                  // imageAsset: 'assets/bot.png',
                  imageUrl: 'https://picsum.photos/seed/bot/120',
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
