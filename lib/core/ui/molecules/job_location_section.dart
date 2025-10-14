import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class JobLocationData {
  final String title;
  final String addressText;
  final LatLng point;

  const JobLocationData({
    this.title = 'Ubicación del trabajo',
    required this.addressText,
    required this.point,
  });

  JobLocationData copyWith({
    String? title,
    String? addressText,
    LatLng? point,
  }) => JobLocationData(
    title: title ?? this.title,
    addressText: addressText ?? this.addressText,
    point: point ?? this.point,
  );
}

class JobLocationSection extends StatefulWidget {
  final JobLocationData data;

  /// Te avisa cada vez que el usuario escribe (para autocompletar, etc.)
  final ValueChanged<String>? onAddressChanged;

  /// Te avisa cuando el usuario “confirma” (Enter o tap en el ícono).
  /// Aquí conectas tu geocodificador y luego puedes llamar a [onUpdateFromOutside].
  final ValueChanged<String>? onAddressSubmitted;

  /// Te avisa si el usuario toca el mapa (para mover el pin).
  final ValueChanged<LatLng>? onMapTap;

  /// Si quieres un botón de “mi ubicación” (opcional).
  final VoidCallback? onMyLocation;

  /// Permite que capas superiores actualicen el widget (texto/marker)
  /// tras una geocodificación externa.
  final void Function(JobLocationData data)? onUpdateFromOutside;

  const JobLocationSection({
    super.key,
    required this.data,
    this.onAddressChanged,
    this.onAddressSubmitted,
    this.onMapTap,
    this.onMyLocation,
    this.onUpdateFromOutside,
  });

  @override
  State<JobLocationSection> createState() => _JobLocationSectionState();
}

class _JobLocationSectionState extends State<JobLocationSection> {
  late final TextEditingController _ctrl;
  late JobLocationData _state;

  @override
  void initState() {
    super.initState();
    _state = widget.data;
    _ctrl = TextEditingController(text: widget.data.addressText);
  }

  @override
  void didUpdateWidget(covariant JobLocationSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si desde fuera te envían un nuevo estado, reflejarlo
    if (oldWidget.data.addressText != widget.data.addressText ||
        oldWidget.data.point != widget.data.point) {
      _state = widget.data;
      _ctrl.value = TextEditingValue(
        text: widget.data.addressText,
        selection: TextSelection.collapsed(
          offset: widget.data.addressText.length,
        ),
      );
      setState(() {});
    }
  }

  void _submit() {
    final text = _ctrl.text.trim();
    widget.onAddressSubmitted?.call(text);
    // No movemos el mapa aquí: déjalo al resultado de tu geocodificación
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              _state.title,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),

            // Input (editable) + botón de acción
            SizedBox(
              height: 40,
              child: TextField(
                controller: _ctrl,
                onChanged: widget.onAddressChanged,
                onSubmitted: (_) => _submit(),
                textInputAction: TextInputAction.search,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Ubicación actual',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF3F3F3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
                  ),
                  suffixIcon: _AnimatedIconBtn(
                    icon: Icons.search_rounded,
                    onTap: _submit,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Mapa
            SizedBox(
              width: double.infinity,
              height: 170,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: _state.point,
                    initialZoom: 15,
                    onTap: (tapPos, latLng) {
                      widget.onMapTap?.call(latLng);
                      setState(() {
                        _state = _state.copyWith(point: latLng);
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.fixgo.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _state.point,
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
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedIconBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _AnimatedIconBtn({required this.icon, this.onTap});

  @override
  State<_AnimatedIconBtn> createState() => _AnimatedIconBtnState();
}

class _AnimatedIconBtnState extends State<_AnimatedIconBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 90),
  );
  late final Animation<double> _scale = Tween(
    begin: 1.0,
    end: 0.92,
  ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _c.forward(),
      onTapUp: (_) {
        _c.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _c.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.06),
          ),
          child: Icon(widget.icon, color: Colors.black87),
        ),
      ),
    );
  }
}
