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

/// Firma para tu geocodificador externo
typedef AddressResolver = Future<LatLng?> Function(String address);

class JobLocationSection extends StatefulWidget {
  final JobLocationData data;

  /// Resolver de direcciones: coordenadas que provees desde otra capa.
  /// Si es null, el widget no intentará geocodificar.
  final AddressResolver? resolveAddress;

  final ValueChanged<String>? onAddressChanged;
  final ValueChanged<String>? onAddressSubmitted;
  final ValueChanged<LatLng>? onMapTap;

  const JobLocationSection({
    super.key,
    required this.data,
    this.resolveAddress,
    this.onAddressChanged,
    this.onAddressSubmitted,
    this.onMapTap,
  });

  @override
  State<JobLocationSection> createState() => _JobLocationSectionState();
}

class _JobLocationSectionState extends State<JobLocationSection> {
  late JobLocationData _state;
  late final TextEditingController _ctrl;
  final MapController _mapController = MapController();
  bool _resolving = false;

  @override
  void initState() {
    super.initState();
    _state = widget.data;
    _ctrl = TextEditingController(text: widget.data.addressText);
  }

  @override
  void didUpdateWidget(covariant JobLocationSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si desde arriba cambian el estado, reflejarlo
    if (oldWidget.data.addressText != widget.data.addressText ||
        oldWidget.data.point != widget.data.point) {
      _state = widget.data;
      _ctrl.value = TextEditingValue(
        text: widget.data.addressText,
        selection: TextSelection.collapsed(
          offset: widget.data.addressText.length,
        ),
      );
      // mueve el mapa al nuevo punto
      _mapController.move(_state.point, 15);
      setState(() {});
    }
  }

  Future<void> _submit() async {
    final address = _ctrl.text.trim();
    widget.onAddressSubmitted?.call(address);
    if (widget.resolveAddress == null || address.isEmpty) return;

    setState(() => _resolving = true);
    try {
      final LatLng? result = await widget.resolveAddress!(address);
      if (result != null) {
        setState(() {
          _state = _state.copyWith(addressText: address, point: result);
        });
        _mapController.move(result, 15);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('No se encontró esa ubicación')),
            );
        }
      }
    } finally {
      if (mounted) setState(() => _resolving = false);
    }
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

            // Input de dirección + botón buscar
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
                  suffixIcon: _SearchIcon(loading: _resolving, onTap: _submit),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Mapa con pin
            SizedBox(
              width: double.infinity,
              height: 170,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FlutterMap(
                  mapController: _mapController,
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

class _SearchIcon extends StatefulWidget {
  final bool loading;
  final VoidCallback? onTap;
  const _SearchIcon({required this.loading, this.onTap});

  @override
  State<_SearchIcon> createState() => _SearchIconState();
}

class _SearchIconState extends State<_SearchIcon>
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
    final bg = Colors.black.withValues(alpha: 0.06);
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
          decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
          child: widget.loading
              ? const Padding(
                  padding: EdgeInsets.all(10),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : const Icon(Icons.search_rounded, color: Colors.black87),
        ),
      ),
    );
  }
}
