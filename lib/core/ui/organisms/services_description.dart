import 'package:flutter/material.dart';

/* Muestra la descripción de los servicios que ofrece el proveedor, detallando cada servicio, se deben mostrar mínimo 2 servicios 
y si son más de 3 servicios el desplazamiento tiene que ser como en un carrusel hacia la derecha para mostrar más servicios, 
cada servicio se muestra en forma de columna separada por una linea.  */
//  Variante normal y variante de edición.
// En edición: cada tarjeta muestra botón "Editar" y aparecen 2 inputs en experiencia y costo, cuando se editan sale el btn de "Guardar".

class ServiceInfo {
  final String name;
  final String title;
  final String experienceText;
  final String costText;
  final String? iconAsset;

  const ServiceInfo({
    required this.name,
    required this.title,
    required this.experienceText,
    required this.costText,
    this.iconAsset,
  });

  ServiceInfo copyWith({
    String? name,
    String? title,
    String? experienceText,
    String? costText,
    String? iconAsset,
  }) {
    return ServiceInfo(
      name: name ?? this.name,
      title: title ?? this.title,
      experienceText: experienceText ?? this.experienceText,
      costText: costText ?? this.costText,
      iconAsset: iconAsset ?? this.iconAsset,
    );
  }
}

class ServicesDescription extends StatelessWidget {
  final List<ServiceInfo> services;

  // Variante de edición. Cuando es true, aparece el botón "Editar" por cada servicio.
  final bool isEditing;

  // Se llama cuando el usuario pulsa "Guardar" en una tarjeta.
  final Future<void> Function(int index, String newExperience, String newCost)?
  onSaveItem;

  final double baseWidth;
  final double minHeight;
  final double columnWidth;
  final double headerBadgeMinH;

  const ServicesDescription({
    super.key,
    required this.services,
    this.isEditing = false,
    this.onSaveItem,
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
          width: baseWidth,
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
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
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
          index: i,
          info: items[i],
          width: columnWidth,
          badgeMinHeight: headerBadgeMinH,
          isEditing: isEditing,
          onSave: onSaveItem,
        ),
      );
      if (i != items.length - 1) {
        cols.add(const _VerticalDivider());
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

class _ServiceColumn extends StatefulWidget {
  final int index;
  final ServiceInfo info;
  final double width;
  final double badgeMinHeight;
  final bool isEditing;
  final Future<void> Function(int index, String newExperience, String newCost)?
  onSave;

  const _ServiceColumn({
    required this.index,
    required this.info,
    required this.width,
    required this.badgeMinHeight,
    required this.isEditing,
    required this.onSave,
  });

  @override
  State<_ServiceColumn> createState() => _ServiceColumnState();
}

class _ServiceColumnState extends State<_ServiceColumn> {
  bool _editingThis = false; // estado de edición por tarjeta
  bool _saving = false;

  late final TextEditingController _expCtrl;
  late final TextEditingController _costCtrl;

  @override
  void initState() {
    super.initState();
    _expCtrl = TextEditingController(text: widget.info.experienceText);
    _costCtrl = TextEditingController(text: widget.info.costText);
  }

  @override
  void didUpdateWidget(covariant _ServiceColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    // si cambian los datos desde afuera, sincroniza
    if (oldWidget.info.experienceText != widget.info.experienceText) {
      _expCtrl.text = widget.info.experienceText;
    }
    if (oldWidget.info.costText != widget.info.costText) {
      _costCtrl.text = widget.info.costText;
    }
    // si sales del modo edición global, resetea local
    if (!widget.isEditing && _editingThis) {
      setState(() => _editingThis = false);
    }
  }

  @override
  void dispose() {
    _expCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggleEditOrSave() async {
    if (!_editingThis) {
      // Entrar en edición solo si la variante global lo permite
      if (widget.isEditing) setState(() => _editingThis = true);
      return;
    }
    // Guardar
    final newExp = _expCtrl.text.trim();
    final newCost = _costCtrl.text.trim();
    if (newExp.isEmpty || newCost.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa experiencia y costo')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      if (widget.onSave != null) {
        await widget.onSave!(widget.index, newExp, newCost);
      }
      if (!mounted) return;
      setState(() => _editingThis = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Servicio actualizado')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Encabezado con icono + nombre
          Container(
            constraints: BoxConstraints(minHeight: widget.badgeMinHeight),
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
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _MiniIcon(asset: widget.info.iconAsset),
                const SizedBox(width: 6),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.info.name,
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

          // Título
          Text(
            widget.info.title,
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

          // Experiencia
          _editingThis
              ? _TinyInput(controller: _expCtrl)
              : Text(
                  widget.info.experienceText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w300,
                    fontSize: 10,
                    color: Colors.black,
                  ),
                ),

          const SizedBox(height: 8),

          // Costo
          _editingThis
              ? _TinyInput(controller: _costCtrl)
              : Text(
                  widget.info.costText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w300,
                    fontSize: 10,
                    color: Colors.black,
                  ),
                ),

          const SizedBox(height: 8),

          // Botón Editar / Guardar (solo visible en variante de edición)
          if (widget.isEditing)
            _EditSaveButton(
              saving: _saving,
              isEditingThis: _editingThis,
              onTap: _toggleEditOrSave,
            ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: const Color(0xFFC4C4C4),
    );
  }
}

/// Ícono mini
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

/// Input diminuto para experiencia y costo: cuando es editar
class _TinyInput extends StatelessWidget {
  final TextEditingController controller;
  const _TinyInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      height: 10,
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 10, height: 1.0),
        textAlign: TextAlign.center,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 0,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
        ),
        onSubmitted: (_) {},
      ),
    );
  }
}

/// Botón Editar / Guardar
class _EditSaveButton extends StatelessWidget {
  final bool isEditingThis;
  final bool saving;
  final VoidCallback onTap;

  const _EditSaveButton({
    required this.isEditingThis,
    required this.saving,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = saving
        ? 'Guardando...'
        : (isEditingThis ? 'Guardar' : 'Editar');

    return SizedBox(
      width: 80,
      height: 13,
      child: ElevatedButton(
        onPressed: saving ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: const Size(80, 13),
          elevation: 3,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w300,
              fontSize: 10,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
