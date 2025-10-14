import 'package:flutter/material.dart';

class NearbyProviderData {
  final String name;
  final String location;
  final double distanceKm;
  final double rating;
  final String photoUrl;
  final List<String> categories;

  const NearbyProviderData({
    required this.name,
    required this.location,
    required this.distanceKm,
    required this.rating,
    required this.photoUrl,
    required this.categories,
  });
}

class NearbyProvidersCard extends StatelessWidget {
  final List<NearbyProviderData> providers;
  final VoidCallback? onSeeMore;
  final VoidCallback? onOpenProvider;

  const NearbyProvidersCard({
    super.key,
    required this.providers,
    this.onSeeMore,
    this.onOpenProvider,
  });

  @override
  Widget build(BuildContext context) {
    final visibleProviders = providers.length > 3
        ? providers.sublist(0, 3)
        : providers;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: Column(
        children: [
          const Text(
            "Proveedores cercanos a ti",
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          // Contenedor con scroll si hay más de 3
          if (providers.length > 3)
            SizedBox(
              height: 230,
              child: ListView.separated(
                itemCount: providers.length,
                separatorBuilder: (_, __) => const Divider(height: 10),
                itemBuilder: (context, i) =>
                    _ProviderRow(provider: providers[i], onTap: onOpenProvider),
              ),
            )
          else
            Column(
              children: [
                for (final p in visibleProviders) ...[
                  _ProviderRow(provider: p, onTap: onOpenProvider),
                  const Divider(height: 10),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _ProviderRow extends StatelessWidget {
  final NearbyProviderData provider;
  final VoidCallback? onTap;

  const _ProviderRow({required this.provider, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Imagen circular
            ClipOval(
              child: Image.network(
                provider.photoUrl,
                width: 30,
                height: 30,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.person, size: 30, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 8),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.name,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        provider.location,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          color: Colors.black,
                        ),
                      ),
                      const Text(
                        " → ",
                        style: TextStyle(fontSize: 13, color: Colors.black),
                      ),
                      Text(
                        "${provider.distanceKm.toStringAsFixed(1)} km",
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  _StarsRow(rating: provider.rating),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Categorías (iconos)
            Row(
              children: [
                for (int i = 0; i < provider.categories.length; i++) ...[
                  Container(
                    width: 38,
                    height: 27,
                    margin: EdgeInsets.only(
                      right: i != provider.categories.length - 1 ? 11 : 0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFC3C0C0)),
                    ),
                    child: Image.asset(
                      'assets/${provider.categories[i]}.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image, color: Colors.grey, size: 20),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(width: 10),

            // Flecha “>”
            IconButton(
              onPressed: onTap,
              icon: const Icon(
                Icons.chevron_right,
                color: Color(0xFFD4D4D4),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Estrellas de calificación
class _StarsRow extends StatelessWidget {
  final double rating;
  const _StarsRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    final int full = rating.floor();
    final bool half = (rating - full) >= 0.5;
    return Row(
      children: List.generate(5, (i) {
        if (i < full) {
          return const Padding(
            padding: EdgeInsets.only(right: 5),
            child: Icon(Icons.star, size: 12, color: Colors.amber),
          );
        } else if (i == full && half) {
          return const Padding(
            padding: EdgeInsets.only(right: 5),
            child: Icon(Icons.star_half, size: 12, color: Colors.amber),
          );
        } else {
          return const Padding(
            padding: EdgeInsets.only(right: 5),
            child: Icon(Icons.star_border, size: 12, color: Colors.black),
          );
        }
      }),
    );
  }
}
