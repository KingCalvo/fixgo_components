import 'package:flutter/material.dart';

class ServiceInfo {
  final String name; // "Pintura", "Carpintería", etc.
  final String title; // "Pintura de interiores"
  final String experienceText; // "8 años de experiencia"
  final String costText; // "Costo: $800 MXN"
  final String? iconAsset; // 'assets/pintura.png' (opcional)

  const ServiceInfo({
    required this.name,
    required this.title,
    required this.experienceText,
    required this.costText,
    this.iconAsset,
  });
}

/// Sección “Descripción de servicios”
/// - baseWidth 412 (se centra) y minHeight 150 (crece si hace falta).
/// - Si hay >3 servicios, scroll horizontal tipo carrusel.
/// - Cada servicio es una columna separada por una línea vertical.
class ServicesDescription extends StatelessWidget {
  final List<ServiceInfo> services;

  final double baseWidth;
  final double minHeight;
  final double columnWidth; // ancho aprox. de cada columna
  final double headerBadgeMinH; // alto mínimo del badge

  const ServicesDescription({
    super.key,
    required this.services,
    this.baseWidth = 412,
    this.minHeight = 150,
    this.columnWidth = 126,
    this.headerBadgeMinH = 26,
  });

  @override
  Widget build(BuildContext context) {
    final items = services.isNotEmpty ? services : _fallbackServices;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: baseWidth, minHeight: minHeight),
        child: SizedBox(
          width: baseWidth, // 412 px como pediste
          // sin height fija: deja que crezca si el texto lo necesita
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                const SizedBox(height: 4),
                const Text(
                  'Servicios',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400, // regular
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                // Carrusel horizontal
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(width: 8),
                        ..._buildColumns(items),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildColumns(List<ServiceInfo> items) {
    final List<Widget> cols = [];
    for (int i = 0; i < items.length; i++) {
      cols.add(
        _ServiceColumn(
          info: items[i],
          width: columnWidth,
          badgeMinHeight: headerBadgeMinH,
        ),
      );
      if (i != items.length - 1) {
        cols.add(_VerticalDivider()); // altura la da IntrinsicHeight
      }
    }
    return cols;
  }

  // Datos de ejemplo si aún no llegan desde Supabase
  static const _fallbackServices = <ServiceInfo>[
    ServiceInfo(
      name: 'Pintura',
      title: 'Pintura de interiores',
      experienceText: '8 años de experiencia',
      costText: 'Costo: \$800 MXN',
      iconAsset: 'assets/mini1.png',
    ),
    ServiceInfo(
      name: 'Jardinería',
      title: 'Poda, riego y mantenimiento',
      experienceText: '5 años de experiencia',
      costText: 'Costo: \$700 MXN',
      iconAsset: 'assets/mini2.png',
    ),
    ServiceInfo(
      name: 'Plomería',
      title: 'Instalación y reparación de tuberías',
      experienceText: '2 años de experiencia',
      costText: 'Costo: \$1,200 MXN',
      iconAsset: 'assets/mini1.png',
    ),
  ];
}

class _ServiceColumn extends StatelessWidget {
  final ServiceInfo info;
  final double width;
  final double badgeMinHeight;
  const _ServiceColumn({
    required this.info,
    required this.width,
    required this.badgeMinHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width, // ~126 px por columna
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // <— CENTRA TODO
        children: [
          Container(
            constraints: BoxConstraints(minHeight: badgeMinHeight),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFC3C0C0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, // <— icono + texto centrados
              mainAxisSize: MainAxisSize.min,
              children: [
                _MiniIcon(asset: info.iconAsset),
                const SizedBox(width: 6),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      info.name,
                      softWrap: false,
                      maxLines: 1,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w300,
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Text(
            info.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w300,
              fontSize: 10,
              color: Colors.black,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            info.experienceText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w300,
              fontSize: 10,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            info.costText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w300,
              fontSize: 10,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: const Color(0xFFC4C4C4),
    );
  }
}

class _MiniIcon extends StatelessWidget {
  final String? asset;
  const _MiniIcon({this.asset});

  @override
  Widget build(BuildContext context) {
    if (asset == null) {
      return const Icon(Icons.construction, size: 20, color: Colors.black54);
    }
    return Image.asset(
      asset!,
      width: 20,
      height: 20,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.construction, size: 20, color: Colors.black54),
    );
  }
}
