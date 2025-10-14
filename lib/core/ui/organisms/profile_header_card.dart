import 'package:flutter/material.dart';

/// DTO para hidratar el widget desde la capa de Presentación.
/// (Rellénalo desde tu ViewModel/Controller con datos de Supabase/Firebase)
class ProviderProfileHeaderData {
  final String name; // p.ej. "Juan Pérez"  (Supabase)
  final double rating; // p.ej. 4.9           (Supabase)
  final int reviews; // p.ej. 88            (Supabase)
  final String imageUrl; // p.ej. URL Firebase Storage

  const ProviderProfileHeaderData({
    required this.name,
    required this.rating,
    required this.reviews,
    required this.imageUrl,
  });
}

/// Card de cabecera de perfil (412×319 base) con gradiente y acciones.
class ProfileHeaderCard extends StatelessWidget {
  /// Datos que vienen de tu capa de Presentación.
  final ProviderProfileHeaderData data;

  /// Callbacks (navegación/acciones) — implementación desde Presentación.
  final VoidCallback? onBack;
  final VoidCallback? onSettings;

  /// Colores configurables (defaults según especificación).
  final Color topColor;
  final Color bottomColor;

  /// Si quieres forzar ancho/alto; si no, el widget escala responsivamente
  /// dentro de su contenedor usando 412×319 como referencia.
  final double baseWidth;
  final double baseHeight;

  const ProfileHeaderCard({
    Key? key,
    required this.data,
    this.onBack,
    this.onSettings,
    this.topColor = const Color(0xFF1F3C88),
    this.bottomColor = const Color(0xFF080F22),
    this.baseWidth = 412,
    this.baseHeight = 319,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcula factor de escala para mantener proporción base 412×319.
        final double w = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : baseWidth;
        final double h = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : baseHeight;

        // Si el padre no fija alto, usamos el alto base.
        final bool heightUnbounded = !constraints.hasBoundedHeight;
        final double width = w == 0 ? baseWidth : w;
        final double height = heightUnbounded
            ? baseHeight
            : (h == 0 ? baseHeight : h);

        // Escala respecto a dimensiones base
        final double scaleX = width / baseWidth;
        final double scaleY = height / baseHeight;
        final double scale = scaleX < scaleY ? scaleX : scaleY;

        return Center(
          child: SizedBox(
            width: baseWidth * scale,
            height: baseHeight * scale,
            child: _ProfileHeaderContent(
              data: data,
              onBack: onBack,
              onSettings: onSettings,
              topColor: topColor,
              bottomColor: bottomColor,
            ),
          ),
        );
      },
    );
  }
}

class _ProfileHeaderContent extends StatelessWidget {
  final ProviderProfileHeaderData data;
  final VoidCallback? onBack;
  final VoidCallback? onSettings;
  final Color topColor;
  final Color bottomColor;

  const _ProfileHeaderContent({
    required this.data,
    required this.onBack,
    required this.onSettings,
    required this.topColor,
    required this.bottomColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      // permite ripple en overlay
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [topColor, bottomColor],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Acciones superiores
            Positioned(
              left: 8,
              top: 8,
              child: SafeArea(
                child: _ActionIcon(
                  icon: Icons.arrow_back,
                  tooltip: 'Volver',
                  onTap: onBack,
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: SafeArea(
                child: _ActionIcon(
                  icon: Icons.settings,
                  tooltip: 'Ajustes',
                  onTap: onSettings,
                ),
              ),
            ),

            // Contenido central
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar 130×130 con borde blanco 6
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 6),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.network(
                        data.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade300,
                          child: const Icon(
                            Icons.person,
                            size: 56,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Nombre (Roboto regular 20)
                  Text(
                    data.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Estrellas 24 con gap 10
                  _StarsRow(rating: data.rating),

                  const SizedBox(height: 10),

                  // "4.9 Calificación" (Roboto light 15)
                  Text(
                    '${data.rating.toStringAsFixed(1)} Calificación',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // "88 Reseñas" (Roboto light 15)
                  Text(
                    '${data.reviews} Reseñas',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón circular con ripple, animación de escala y ligera elevación.
class _ActionIcon extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _ActionIcon({required this.icon, required this.tooltip, this.onTap});

  @override
  State<_ActionIcon> createState() => _ActionIconState();
}

class _ActionIconState extends State<_ActionIcon> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final double scale = _pressed ? 0.9 : 1.0;

    return Semantics(
      button: true,
      label: widget.tooltip,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: widget.onTap,
          onHighlightChanged: (v) => setState(() => _pressed = v),
          splashColor: Colors.white.withValues(alpha: 0.25),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              widget.icon,
              size: 28,
              color: Colors.white,
              shadows: const [
                Shadow(
                  color: Colors.black54,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension on _ActionIconState {
  // Reemplazamos el icono con overlay para dibujar blanco con “sombra suave”.
  // (Helper para mantener el Material circular anterior)
  Widget get _iconStack =>
      Stack(alignment: Alignment.center, children: const []);
}

/// Fila de 5 estrellas con soporte full/half/outline (24px, gap 10)
class _StarsRow extends StatelessWidget {
  final double rating;
  const _StarsRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    const double starSize = 24;
    const double gap = 10;
    final int full = rating.floor();
    final bool hasHalf = (rating - full) >= 0.5;

    List<Widget> stars = [];
    for (int i = 0; i < 5; i++) {
      IconData icon;
      if (i < full) {
        icon = Icons.star;
      } else if (i == full && hasHalf) {
        icon = Icons.star_half;
      } else {
        icon = Icons.star_border;
      }
      stars.add(Icon(icon, size: starSize, color: const Color(0xFFFFC107)));
      if (i != 4) stars.add(const SizedBox(width: gap));
    }

    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }
}
