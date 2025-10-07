import 'package:flutter/material.dart';

class ProfileHeaderCard extends StatelessWidget {
  final String name;
  final double rating; // ej. 4.9
  final int reviews; // ej. 88
  final String imageUrl;
  final VoidCallback? onBack;
  final VoidCallback? onSettings;

  const ProfileHeaderCard({
    Key? key,
    this.name = 'Juan Perez',
    this.rating = 4.9,
    this.reviews = 88,
    this.imageUrl = 'https://picsum.photos/400',
    this.onBack,
    this.onSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color topColor = Color(0xFF1F3C88);
    const Color bottomColor = Color(0xFF080F22);

    return SizedBox(
      width: 412,
      height: 319,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [topColor, bottomColor],
          ),
        ),
        child: Stack(
          children: [
            // Iconos top-left (back) y top-right (settings) usando el botón animado
            Positioned(
              left: 8,
              top: 8,
              child: SafeArea(
                child: _AnimatedIconButton(
                  icon: Icons.arrow_back,
                  size: 32,
                  color: Colors.white,
                  onPressed: onBack,
                  tooltip: 'Volver',
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: SafeArea(
                child: _AnimatedIconButton(
                  icon: Icons.settings,
                  size: 32,
                  color: Colors.white,
                  onPressed: onSettings,
                  tooltip: 'Ajustes',
                ),
              ),
            ),

            // Contenido centrado (foto, nombre, estrellas, textos)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Foto con marco blanco (130x130)
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 6),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        imageUrl,
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

                  // Nombre
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 20,
                      fontWeight: FontWeight.w400, // regular
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Estrellas (5 icons de 24, gap 10)
                  _buildStarsRow(rating),

                  const SizedBox(height: 10),

                  // "4.9 Calificación"
                  Text(
                    '${rating.toStringAsFixed(1)} Calificación',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 15,
                      fontWeight: FontWeight.w300, // light
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // "88 reseñas"
                  Text(
                    '$reviews Reseñas',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 15,
                      fontWeight: FontWeight.w300, // light
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

  // Construye la fila de estrellas con lógica full/half/outline
  Widget _buildStarsRow(double rating) {
    final int full = rating.floor();
    final bool hasHalf = (rating - full) >= 0.5;
    const double starSize = 24;
    const double gap = 10;

    List<Widget> stars = [];
    for (int i = 0; i < 5; i++) {
      Widget star;
      if (i < full) {
        star = const Icon(
          Icons.star,
          size: starSize,
          color: Color(0xFFFFC107),
        ); // amarillo
      } else if (i == full && hasHalf) {
        star = const Icon(
          Icons.star_half,
          size: starSize,
          color: Color(0xFFFFC107),
        );
      } else {
        star = const Icon(
          Icons.star_border,
          size: starSize,
          color: Color(0xFFFFC107),
        );
      }

      stars.add(star);
      if (i != 4) stars.add(const SizedBox(width: gap));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: stars,
    );
  }
}

/// Botón con animación de escala cuando se presiona.
/// - Muestra el icono en el color dado (por defecto blanco).
/// - Llama a `onPressed` si no es null.
/// - Si `onPressed` es null: no ejecuta acción, pero la animación sigue (útil para ver efecto).
class _AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final double size;
  final Color color;
  final VoidCallback? onPressed;
  final String? tooltip;

  const _AnimatedIconButton({
    Key? key,
    required this.icon,
    this.size = 24,
    this.color = Colors.white,
    this.onPressed,
    this.tooltip,
  }) : super(key: key);

  @override
  State<_AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<_AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  // Usamos AnimatedScale para animación suave
  bool _pressed = false;

  void _handleTapDown(_) {
    setState(() => _pressed = true);
  }

  void _handleTapUp(_) async {
    // breve delay para que la animación sea perceptible
    setState(() => _pressed = false);
    // ejecuta la acción (si hay)
    if (widget.onPressed != null) {
      widget.onPressed!.call();
    }
  }

  void _handleTapCancel() {
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final double scale = _pressed ? 0.88 : 1.0;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Semantics(
          button: true,
          label: widget.tooltip,
          child: Container(
            width: widget.size + 16, // área táctil un poco más grande
            height: widget.size + 16,
            alignment: Alignment.center,
            child: Icon(widget.icon, size: widget.size, color: widget.color),
          ),
        ),
      ),
    );
  }
}
