import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Filtro exclusivo para Ubicación (Estado / Municipio).
/// Carga datos desde Supabase
/// Emite onChanged con key = 'estado' | 'municipio'.
class FiltroUbicacionPill extends StatefulWidget {
  final void Function(String key, String value)? onChanged;

  final double width;
  final double height;
  final String baseLabel;

  // Carga con Supabase
  final SupabaseClient? supabase;
  final String statesTable;
  final String statesNameColumn;
  final String municipalitiesTable;
  final String municipalitiesNameColumn;
  final String municipalitiesStateFkColumn;

  // Carga con funciones (opcional)
  final Future<List<String>> Function()? loadStates;
  final Future<List<String>> Function(String state)? loadMunicipalities;

  const FiltroUbicacionPill({
    super.key,
    this.onChanged,
    this.width = 160,
    this.height = 26,
    this.baseLabel = 'Ubicación',
    // Supabase
    this.supabase,
    this.statesTable = 'estados',
    this.statesNameColumn = 'nombre',
    this.municipalitiesTable = 'municipios',
    this.municipalitiesNameColumn = 'nombre',
    this.municipalitiesStateFkColumn = 'estado',
    // Loaders
    this.loadStates,
    this.loadMunicipalities,
  });

  @override
  State<FiltroUbicacionPill> createState() => _FiltroUbicacionPillState();
}

class _FiltroUbicacionPillState extends State<FiltroUbicacionPill> {
  final MenuController _controller = MenuController();

  String? _selectedState;
  String? _selectedMunicipio;

  bool _loadingStates = false;
  bool _loadingMunicipios = false;

  List<String> _states = const <String>[];
  List<String> _municipios = const <String>[];

  String get _label {
    if (_selectedState != null && _selectedMunicipio != null) {
      return '$_selectedState / $_selectedMunicipio';
    }
    return _selectedState ?? _selectedMunicipio ?? widget.baseLabel;
  }

  @override
  void initState() {
    super.initState();
    _fetchStates();
  }

  Future<void> _fetchStates() async {
    setState(() => _loadingStates = true);
    try {
      List<String> list;
      if (widget.loadStates != null) {
        list = await widget.loadStates!();
      } else if (widget.supabase != null) {
        final res = await widget.supabase!
            .from(widget.statesTable)
            .select(widget.statesNameColumn)
            .order(widget.statesNameColumn);
        list = (res as List<dynamic>)
            .map(
              (row) =>
                  (row as Map<String, dynamic>)[widget.statesNameColumn]
                      as String,
            )
            .map((s) => s.trim())
            .toList();
      } else {
        list = const <String>['Morelos', 'CDMX', 'Edomex'];
      }
      setState(() => _states = list);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingStates = false);
    }
  }

  Future<void> _fetchMunicipios(String state) async {
    setState(() => _loadingMunicipios = true);
    try {
      List<String> list;
      if (widget.loadMunicipalities != null) {
        list = await widget.loadMunicipalities!(state);
      } else if (widget.supabase != null) {
        final res = await widget.supabase!
            .from(widget.municipalitiesTable)
            .select(widget.municipalitiesNameColumn)
            .eq(widget.municipalitiesStateFkColumn, state)
            .order(widget.municipalitiesNameColumn);
        list = (res as List<dynamic>)
            .map(
              (row) =>
                  (row as Map<String, dynamic>)[widget.municipalitiesNameColumn]
                      as String,
            )
            .map((s) => s.trim())
            .toList();
      } else {
        list = const <String>['Yautepec', 'Cuautla', 'Cuernavaca'];
      }
      setState(() => _municipios = list);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingMunicipios = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSelection =
        _selectedState != null || _selectedMunicipio != null;
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
              width: widget.width,
              height: widget.height,
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
                          fontSize: 16,
                          color: baseText,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.location_on_outlined, size: 24, color: baseIcon),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildMenuChildren() {
    final List<String> states = _loadingStates ? const <String>[] : _states;
    final List<String> municipios = _loadingMunicipios
        ? const <String>[]
        : _municipios;

    return <Widget>[
      // ESTADO
      SubmenuButton(
        leadingIcon: const Icon(Icons.location_city, color: Colors.black),
        menuChildren: states
            .map(
              (String e) => MenuItemButton(
                onPressed: () async {
                  setState(() {
                    _selectedState = e; // e es String
                    _selectedMunicipio = null;
                    _municipios = const <String>[];
                  });
                  widget.onChanged?.call('estado', e);
                  await _fetchMunicipios(e);
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
        child: Row(
          children: [
            const Text(
              'Estado',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            if (_loadingStates) ...[
              const SizedBox(width: 8),
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ],
        ),
      ),

      // MUNICIPIO
      SubmenuButton(
        leadingIcon: const Icon(Icons.map_outlined, color: Colors.black),
        menuChildren: municipios
            .map(
              (String m) => MenuItemButton(
                onPressed: () {
                  setState(() => _selectedMunicipio = m); // m es String
                  widget.onChanged?.call('municipio', m);
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
        child: Row(
          children: [
            const Text(
              'Municipio',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            if (_loadingMunicipios) ...[
              const SizedBox(width: 8),
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ],
        ),
      ),
    ];
  }
}
