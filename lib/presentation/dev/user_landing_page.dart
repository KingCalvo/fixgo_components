import 'package:flutter/material.dart';
import '../../core/ui/ui.dart';

class UserLandingPage extends StatelessWidget {
  const UserLandingPage({super.key});

  static const double _contentMaxWidth = 412;
  static const double _gap6 = 6;
  static const double _gap15 = 15;

  @override
  Widget build(BuildContext context) {
    // ====== Datos demo (cámbialos por tus resultados de Supabase) ======
    const interested = <InterestedProviderData>[
      InterestedProviderData(
        title: 'Ferretería EL MARTILLO',
        description: 'Soluciones rápidas y seguras para fugas y tuberías.',
        rating: 4.8,
        photoUrl: 'https://picsum.photos/seed/p1/200',
      ),
      InterestedProviderData(
        title: 'Pinturas Gómez',
        description: 'Pintura residencial y comercial. Garantía por escrito.',
        rating: 4.6,
        photoUrl: 'https://picsum.photos/seed/p2/200',
      ),
      InterestedProviderData(
        title: 'Limpieza Pro Max',
        description: 'Limpieza de exteriores e interiores.',
        rating: 4.9,
        photoUrl: 'https://picsum.photos/seed/p3/200',
      ),
      InterestedProviderData(
        title: 'Jardinería VerdeVivo',
        description: 'Poda, mantenimiento y diseño.',
        rating: 4.4,
        photoUrl: 'https://picsum.photos/seed/p4/200',
      ),
      InterestedProviderData(
        title: 'Herrería Hernández',
        description: 'Portones y barandales a medida.',
        rating: 4.7,
        photoUrl: 'https://picsum.photos/seed/p5/200',
      ),
      InterestedProviderData(
        title: 'Electricistas Luna',
        description: 'Instalaciones y emergencias 24/7.',
        rating: 4.5,
        photoUrl: 'https://picsum.photos/seed/p6/200',
      ),
      InterestedProviderData(
        title: 'Plomería Express',
        description: 'Detección de fugas y reparación inmediata.',
        rating: 4.3,
        photoUrl: 'https://picsum.photos/seed/p7/200',
      ),
      InterestedProviderData(
        title: 'Carpintería Roble',
        description: 'Muebles a medida y reparación.',
        rating: 4.2,
        photoUrl: 'https://picsum.photos/seed/p8/200',
      ),
    ];

    // Top 7 por calificación (desc)
    final topCotizados = [...interested]
      ..sort((a, b) => b.rating.compareTo(a.rating));
    final top7 = topCotizados.take(7).toList();

    final nearbyProviders = <NearbyProviderData>[
      const NearbyProviderData(
        name: "Juan Pérez",
        location: "Emiliano Zapata",
        distanceKm: 2.5,
        rating: 4,
        photoUrl: "https://picsum.photos/200",
        categories: ["pintura", "plomería"],
      ),
      const NearbyProviderData(
        name: "Carlos Ruiz",
        location: "Yautepec",
        distanceKm: 3.2,
        rating: 5,
        photoUrl: "https://picsum.photos/201",
        categories: ["jardinería", "herrería"],
      ),
      const NearbyProviderData(
        name: "Luis García",
        location: "Cuautla",
        distanceKm: 4.1,
        rating: 3,
        photoUrl: "https://picsum.photos/202",
        categories: ["albañilería", "pintura"],
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                // Top bar (ancho completo)
                const SliverToBoxAdapter(
                  child: AppTopBar(role: AppUserRole.cliente),
                ),

                // Contenido centrado
                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: _contentMaxWidth,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: _gap6),

                          // Buscador
                          const SearchPanel(),

                          const SizedBox(height: _gap15),

                          // Carrusel: ProviderDiscount + CategoryDiscount
                          const _DiscountsCarousel(),

                          const SizedBox(height: _gap15),

                          // Proveedores cercanos
                          NearbyProvidersCard(
                            providers: nearbyProviders,
                            onSeeMore: () {
                              // TODO: navegación a lista completa
                            },
                            onOpenProvider: () {
                              // TODO: abrir perfil proveedor
                            },
                          ),

                          const SizedBox(height: _gap15),

                          // También te podría interesar
                          InterestingProvidersSection(
                            // si tu componente ya admite "title", úsalo:
                            title: 'También te podría interesar',
                            items: interested,
                            initialVisible: 3,
                            onKnow: (it) {},
                            onHire: (it) {},
                          ),

                          const SizedBox(height: _gap15),

                          // Publica tu trabajo (ancho completo)
                          PublishPromptCard(
                            onPublish: () {
                              // TODO: flujo publicar
                            },
                          ),

                          const SizedBox(height: _gap15),

                          // Los más cotizados (ya pre-filtrado y ordenado aquí)
                          InterestingProvidersSection(
                            title: 'Los más cotizados',
                            items: top7,
                            initialVisible: 3,
                            onKnow: (it) {},
                            onHire: (it) {},
                          ),

                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Bot siempre abajo a la derecha (flotante)
            Positioned(
              right: 16,
              bottom: 16,
              child: BotFab(
                data: BotFabData(
                  imageAsset: 'lib/assets/bot.png',
                  onTap: () {
                    // TODO: abrir chat del bot
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------- Carrusel de descuentos -------------------
class _DiscountsCarousel extends StatelessWidget {
  const _DiscountsCarousel();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200, // ajusta si tus cards son más altas
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            const SizedBox(width: 8),
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
            const SizedBox(width: 12),
            CategoryDiscountCard(
              data: const CategoryDiscountData(
                percentText: '20 %',
                subtitle: 'En categoría',
                imageAsset: 'lib/assets/JardineriaCard.png',
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
