import 'package:flutter/material.dart';

// Variantes de filtro
enum FilterVariant { servicios, fecha, fechaMini, ubicacion }

// Widget único que dibuja el “pill” y abre un menú contextual con opciones.
// No hace consultas. Sólo muestra/guarda la selección y emite onChanged.
class FilterPill extends StatefulWidget {
  final FilterVariant variant;

  // Callback para informar selección (clave/valor).
  // servicios:    key='servicio',    value=p.ej. 'Pintura'
  // fecha/mini:   key='periodo',     value='Hoy'|'Esta semana'|'Este mes'
  // ubicación:    key='estado' o 'municipio', value=nombre
  final void Function(FilterVariant variant, String key, String value)?
  onChanged;

  /// Listas opcionales
  final List<String>? serviceOptions;
  final List<String>? dateOptions;
  final List<String>? states;
  final List<String>? municipalities;

  /// Si true, el label muestra lo elegido (ej. "Servicios: Pintura")
  final bool showSelectionInLabel;

  const FilterPill({
    super.key,
    required this.variant,
    this.onChanged,
    this.serviceOptions,
    this.dateOptions,
    this.states,
    this.municipalities,
    this.showSelectionInLabel = true,
  });

  @override
  State<FilterPill> createState() => _FilterPillState();
}

class _FilterPillState extends State<FilterPill> {
  final MenuController _controller = MenuController();

  String? _selectedService;
  String? _selectedPeriod;
  String? _selectedState;
  String? _selectedMunicipio;

  // tamaños base por variante
  double get _w => switch (widget.variant) {
    FilterVariant.servicios => 110,
    FilterVariant.fecha => 130,
    FilterVariant.fechaMini => 120,
    FilterVariant.ubicacion => 160,
  };
  double get _h => switch (widget.variant) {
    FilterVariant.servicios => 26,
    FilterVariant.fecha => 26,
    FilterVariant.fechaMini => 22,
    FilterVariant.ubicacion => 26,
  };
  double get _iconSize => switch (widget.variant) {
    FilterVariant.fechaMini => 20,
    _ => 24,
  };
  double get _fontSize => 16;

  List<String> get _services =>
      widget.serviceOptions ??
      const ['Pintura', 'Herrería', 'Jardinería', 'Albañilería'];

  List<String> get _periods =>
      widget.dateOptions ?? const ['Hoy', 'Esta semana', 'Este mes'];

  List<String> get _states =>
      widget.states ?? const ['Morelos', 'CDMX', 'Edomex'];
  List<String> get _municipios =>
      widget.municipalities ?? const ['Yautepec', 'Cuautla', 'Cuernavaca'];

  String get _baseLabel => switch (widget.variant) {
    FilterVariant.servicios => 'Servicios',
    FilterVariant.fecha => 'Fecha',
    FilterVariant.fechaMini => 'Fecha',
    FilterVariant.ubicacion => 'Ubicación',
  };

  String get _label {
    switch (widget.variant) {
      case FilterVariant.servicios:
        return _selectedService ?? _baseLabel;
      case FilterVariant.fecha || FilterVariant.fechaMini:
        return _selectedPeriod ?? _baseLabel;
      case FilterVariant.ubicacion:
        if (_selectedState != null && _selectedMunicipio != null) {
          return '$_selectedState / $_selectedMunicipio';
        }
        return _selectedState ?? _selectedMunicipio ?? _baseLabel;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Detectar si hay algo seleccionado
    final bool hasSelection = switch (widget.variant) {
      FilterVariant.servicios => _selectedService != null,
      FilterVariant.fecha || FilterVariant.fechaMini => _selectedPeriod != null,
      FilterVariant.ubicacion =>
        _selectedState != null || _selectedMunicipio != null,
    };

    // Colores base
    final Color baseBorder = hasSelection
        ? const Color(0xFF1F3C88)
        : Colors.black;
    final Color baseText = hasSelection
        ? const Color(0xFF1F3C88)
        : Colors.black;
    final Color baseIcon = hasSelection
        ? const Color(0xFF1F3C88)
        : Colors.black;

    return MenuAnchor(
      controller: _controller,
      style: const MenuStyle(
        backgroundColor: WidgetStatePropertyAll(Colors.white),
        elevation: WidgetStatePropertyAll(8),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
      menuChildren: _buildMenuChildren(),
      builder: (context, controller, child) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () =>
                controller.isOpen ? controller.close() : controller.open(),
            borderRadius: BorderRadius.circular(6),
            splashColor: const Color(0xFF1F3C88).withValues(alpha: 0.12),
            highlightColor: const Color(0xFF1F3C88).withValues(alpha: 0.08),
            child: Container(
              width: _w,
              height: _h,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: baseBorder, width: 1.2),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _label,
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          fontSize: _fontSize,
                          color: baseText,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.filter_list, size: _iconSize, color: baseIcon),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildMenuChildren() {
    switch (widget.variant) {
      case FilterVariant.servicios:
        return _services
            .map(
              (s) => MenuItemButton(
                onPressed: () {
                  setState(() => _selectedService = s);
                  widget.onChanged?.call(
                    FilterVariant.servicios,
                    'servicio',
                    s,
                  );
                  _controller.close();
                },
                child: Text(
                  s,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
            )
            .toList();

      case FilterVariant.fecha || FilterVariant.fechaMini:
        return _periods
            .map(
              (p) => MenuItemButton(
                onPressed: () {
                  setState(() => _selectedPeriod = p);
                  widget.onChanged?.call(widget.variant, 'periodo', p);
                  _controller.close();
                },
                child: Text(
                  p,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
            )
            .toList();

      case FilterVariant.ubicacion:
        // Submenús: Estado / Municipio (abre a la derecha automáticamente)
        return [
          SubmenuButton(
            leadingIcon: const Icon(Icons.location_city, color: Colors.black),
            child: const Text(
              'Estado',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            menuChildren: _states
                .map(
                  (e) => MenuItemButton(
                    onPressed: () {
                      setState(() => _selectedState = e);
                      widget.onChanged?.call(
                        FilterVariant.ubicacion,
                        'estado',
                        e,
                      );
                      // No cierro el menú padre para que el usuario pueda elegir municipio también.
                    },
                    child: Text(
                      e,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          SubmenuButton(
            leadingIcon: const Icon(Icons.map_outlined, color: Colors.black),
            child: const Text(
              'Municipio',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            menuChildren: _municipios
                .map(
                  (m) => MenuItemButton(
                    onPressed: () {
                      setState(() => _selectedMunicipio = m);
                      widget.onChanged?.call(
                        FilterVariant.ubicacion,
                        'municipio',
                        m,
                      );
                      _controller.close();
                    },
                    child: Text(
                      m,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ];
    }
  }
}
