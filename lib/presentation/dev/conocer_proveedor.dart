import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../core/ui/ui.dart';

/* import 'package:flutter_fixgo_login/core/components/organisms/app_top_bar.dart';
import 'package:flutter_fixgo_login/core/components/molecules/info_bar.dart';
import 'package:flutter_fixgo_login/core/components/molecules/image_carousel.dart';
import 'package:flutter_fixgo_login/core/components/molecules/services_description.dart';
import 'package:flutter_fixgo_login/core/components/atoms/hire_button.dart';
import 'package:flutter_fixgo_login/core/components/molecules/reviews_carousel.dart'; */

class ConocerProveedorPage extends StatefulWidget {
  const ConocerProveedorPage({super.key});

  @override
  State<ConocerProveedorPage> createState() => _ConocerProveedorPageState();
}

class _ConocerProveedorPageState extends State<ConocerProveedorPage> {
  late ProviderProfileVM vm;

  @override
  void initState() {
    super.initState();
    // Reemplazar este mock con datos traídos de Supabase.
    vm = ProviderProfileVM(
      name: 'Juan Pérez',
      galleryUrls: const [
        // Supabase Storage: URLs de imágenes de trabajos
        'https://picsum.photos/seed/work1/800/600',
        'https://picsum.photos/seed/work2/800/600',
        'https://picsum.photos/seed/work3/800/600',
      ],
      rating: 4,
      aboutText:
          'Soy Juan Pérez, me caracterizo por la responsabilidad, puntualidad y compromiso, siempre entregando resultados de calidad.',
      services: const [
        ServiceInfo(
          name: 'Pintura',
          title: 'Pintura de interiores',
          experienceText: '8 años de experiencia',
          costText: 'Trabajos hasta por \$800 MXN',
        ),
        ServiceInfo(
          name: 'Plomería',
          title: 'Reparación de tuberías',
          experienceText: '8 años de experiencia',
          costText: 'Trabajos hasta por \$800 MXN',
        ),
        ServiceInfo(
          name: 'Carpintería',
          title: 'Muebles a medida',
          experienceText: '8 años de experiencia',
          costText: 'Trabajos hasta por \$800 MXN',
        ),
      ],
      serviceZoneText: 'Zona de servicio: Cuernavaca y alrededores',
      location: const LatLng(18.9218, -99.2216),
      reviews: const [
        ReviewInfo(
          name: 'Carlos Pinzón',
          location: 'Yautepec, Morelos',
          avatarUrl: 'https://picsum.photos/seed/carlos/200',
          rating: 4,
          timeAgoText: 'Hace 1 semana',
          comment: 'Excelente trabajo realizado, muy puntual y perfeccionista.',
          ageRank: 0,
        ),
        ReviewInfo(
          name: 'Kike Eslava',
          location: 'Cuautla, Morelos',
          avatarUrl: 'https://picsum.photos/seed/kike/200',
          rating: 4,
          timeAgoText: 'Hace 2 semanas',
          comment: 'Atento y responsable, se nota la experiencia.',
          ageRank: 1,
        ),
        ReviewInfo(
          name: 'María López',
          location: 'Cuernavaca, Morelos',
          avatarUrl: 'https://picsum.photos/seed/maria/200',
          rating: 5,
          timeAgoText: 'Hace 2 meses',
          comment: 'Trabajo impecable y muy buena comunicación.',
          ageRank: 4,
        ),
      ],
    );
  }

  void _goToConfirmacionUsuario() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ConfirmacionSolicitudesEjemplo()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 412),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top bar
                      AppTopBar(
                        role: AppUserRole.cliente,
                        onMenuSelected: (_) {},
                        onUserSelected: (_) {},
                      ),

                      // InfoBar con el nombre del proveedor
                      InfoBar(title: vm.name),

                      const SizedBox(height: 15),

                      // Carrusel de imágenes
                      ImageCarousel(
                        images: vm.galleryUrls,
                        onIndexChanged: (_) {},
                        controlsInset: 12,
                      ),

                      const SizedBox(height: 15),

                      // Estrellas
                      _BigStarsRow(value: vm.rating, size: 24, gap: 10),

                      const SizedBox(height: 15),

                      // Presentación
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          vm.aboutText,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w300,
                            fontSize: 15,
                            color: Colors.black,
                            height: 1.35,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Línea divisora
                      Container(
                        height: 1,
                        width: double.infinity,
                        color: const Color(0xFFD9D9D9),
                      ),

                      const SizedBox(height: 15),

                      // Servicios que realiza
                      ServicesDescription(services: vm.services),

                      const SizedBox(height: 30),

                      // Botón Contratar
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 392,
                          child: HireButton(
                            onPressed: _goToConfirmacionUsuario,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Zona de servicio
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          vm.serviceZoneText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w300,
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Mapa
                      _ProviderLocationMap(point: vm.location),

                      const SizedBox(height: 30),

                      // Título "Reseñas"
                      const Text(
                        'Reseñas',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Carrusel de reseñas
                      ReviewsCarousel(reviews: vm.reviews),

                      const SizedBox(height: 24),
                    ],
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

class ProviderProfileVM {
  final String name;
  final List<String> galleryUrls;
  final int rating; // 0..5
  final String aboutText;
  final List<ServiceInfo> services;
  final String serviceZoneText;
  final LatLng location;
  final List<ReviewInfo> reviews;

  ProviderProfileVM({
    required this.name,
    required this.galleryUrls,
    required this.rating,
    required this.aboutText,
    required this.services,
    required this.serviceZoneText,
    required this.location,
    required this.reviews,
  });
}

class _BigStarsRow extends StatelessWidget {
  final int value; // 0..5
  final double size;
  final double gap;

  const _BigStarsRow({required this.value, this.size = 24, this.gap = 10});

  @override
  Widget build(BuildContext context) {
    final List<Widget> stars = [];
    for (int i = 0; i < 5; i++) {
      final filled = i < value;
      stars.add(_StarIcon(filled: filled, size: size));
      if (i != 4) stars.add(SizedBox(width: gap));
    }
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: stars);
  }
}

class _StarIcon extends StatelessWidget {
  final bool filled;
  final double size;
  const _StarIcon({required this.filled, this.size = 24});

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return Icon(Icons.star, size: size, color: const Color(0xFFFFC107));
    }
    // estrella “vacía” que es blanca con borde negro
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.star, size: size, color: Colors.white),
          Icon(Icons.star_border, size: size, color: Colors.black),
        ],
      ),
    );
  }
}

class _ProviderLocationMap extends StatelessWidget {
  final LatLng point;
  const _ProviderLocationMap({required this.point});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: point,
            initialZoom: 15,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.fixgo.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: point,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_pin,
                    size: 36,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// NAVEGACIÓN DE EJEMPLO
class ConfirmacionSolicitudesEjemplo extends StatelessWidget {
  const ConfirmacionSolicitudesEjemplo({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Confirmación de Solicitudes (Usuario)')),
    );
  }
}
