import 'package:flutter/material.dart';

/* Muestra la descripción de los servicios que ofrece el proveedor, detallando cada servicio, se deben mostrar mínimo 2 servicios 
y si son más de 3 servicios el desplazamiento tiene que ser como en un carrusel hacia la derecha para mostrar más servicios, 
cada servicio se muestra en forma de columna separada por una linea.  */
//  Variante normal y variante de edición.
// En edición: cada tarjeta muestra botón "Editar" y aparecen 2 inputs en experiencia y costo, cuando se editan sale el btn de "Guardar".
// Ahora también:
// - X roja (solo en edición) para ocultar la columna (visibilidad, no borrar en BD).
// - Botón + verde para agregar nuevo servicio (se debe persistir en BD vía callback).

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

class ServicesDescription extends StatefulWidget {
  final List<ServiceInfo> services;

  // Variante de edición. Cuando es true, aparece el botón "Editar" por cada servicio
  // y también la X roja para visibilidad y el botón + para agregar.
  final bool isEditing;

  // Se llama cuando el usuario pulsa "Guardar" en una tarjeta (edición experiencia/costo).
  final Future<void> Function(int index, String newExperience, String newCost)?
  onSaveItem;

  // 🔹 NUEVO: se llama cuando se oculta un servicio (visibilidad false en BD).
  // Aquí debes actualizar la BD para que ya no se muestre cuando recargues.
  final Future<void> Function(ServiceInfo info)? onHideService;

  // 🔹 NUEVO: se llama cuando se agrega un servicio nuevo. Aquí sí debes insertarlo en BD.
  final Future<void> Function(ServiceInfo newService)? onAddService;

  final double baseWidth;
  final double minHeight;
  final double columnWidth;
  final double headerBadgeMinH;

  const ServicesDescription({
    super.key,
    required this.services,
    this.isEditing = false,
    this.onSaveItem,
    this.onHideService,
    this.onAddService,
    this.baseWidth = 412,
    this.minHeight = 150,
    this.columnWidth = 126,
    this.headerBadgeMinH = 26,
  });

  @override
  State<ServicesDescription> createState() => _ServicesDescriptionState();

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

class _ServicesDescriptionState extends State<ServicesDescription> {
  late List<ServiceInfo> _visibleServices;

  // Estado para el formulario de nuevo servicio
  bool _addingService = false;
  bool _savingNewService = false;

  final TextEditingController _newNameCtrl = TextEditingController();
  final TextEditingController _newDescCtrl = TextEditingController();
  final TextEditingController _newExpCtrl = TextEditingController();
  final TextEditingController _newCostCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _visibleServices = widget.services.isNotEmpty
        ? List<ServiceInfo>.from(widget.services)
        : List<ServiceInfo>.from(ServicesDescription._fallbackServices);
  }

  @override
  void didUpdateWidget(covariant ServicesDescription oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambian los servicios desde arriba (por ejemplo tras recargar BD), actualiza lista visible.
    if (oldWidget.services != widget.services) {
      _visibleServices = widget.services.isNotEmpty
          ? List<ServiceInfo>.from(widget.services)
          : List<ServiceInfo>.from(ServicesDescription._fallbackServices);
    }
  }

  @override
  void dispose() {
    _newNameCtrl.dispose();
    _newDescCtrl.dispose();
    _newExpCtrl.dispose();
    _newCostCtrl.dispose();
    super.dispose();
  }

  List<ServiceInfo> get _items => _visibleServices.isNotEmpty
      ? _visibleServices
      : ServicesDescription._fallbackServices;

  Future<void> _handleHideService(int index) async {
    final items = _items;
    if (index < 0 || index >= items.length) return;
    final info = items[index];

    // Quitar de la lista visible en UI
    setState(() {
      _visibleServices.remove(info);
    });

    // Avisar al padre para que marque visibilidad = false en BD
    if (widget.onHideService != null) {
      try {
        await widget.onHideService!(info);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar visibilidad: $e')),
        );
      }
    }
  }

  void _toggleAddForm() {
    setState(() {
      _addingService = !_addingService;
    });
  }

  Future<void> _saveNewService() async {
    final name = _newNameCtrl.text.trim();
    final desc = _newDescCtrl.text.trim();
    final exp = _newExpCtrl.text.trim();
    final cost = _newCostCtrl.text.trim();

    if (name.isEmpty || desc.isEmpty || exp.isEmpty || cost.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los campos del nuevo servicio'),
        ),
      );
      return;
    }

    final newService = ServiceInfo(
      name: name,
      title: desc,
      experienceText: exp,
      costText: cost,
      iconAsset: null,
    );

    setState(() {
      _savingNewService = true;
    });

    try {
      // Agregar al carrusel local
      setState(() {
        _visibleServices.add(newService);
      });

      // Avisar al padre para que inserte en BD
      if (widget.onAddService != null) {
        await widget.onAddService!(newService);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Servicio agregado')));

      // Limpiar campos y cerrar formulario
      _newNameCtrl.clear();
      _newDescCtrl.clear();
      _newExpCtrl.clear();
      _newCostCtrl.clear();
      setState(() {
        _addingService = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al agregar servicio: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _savingNewService = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: widget.baseWidth,
          minHeight: widget.minHeight,
        ),
        child: SizedBox(
          width: widget.baseWidth,
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                const SizedBox(height: 4),
                // Título + botón agregar servicio
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 140),
                  child: Row(
                    children: [
                      const Spacer(),
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
                      const Spacer(),
                      if (widget.isEditing)
                        IconButton(
                          onPressed: _savingNewService ? null : _toggleAddForm,
                          icon: const Icon(Icons.add_circle),
                          color: const Color(0xFF2E7D32), // verde
                          tooltip: 'Agregar servicio',
                        ),
                    ],
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

                // Formulario para nuevo servicio
                if (widget.isEditing && _addingService) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _NewServiceForm(
                      nameCtrl: _newNameCtrl,
                      descCtrl: _newDescCtrl,
                      expCtrl: _newExpCtrl,
                      costCtrl: _newCostCtrl,
                      onCancel: _savingNewService ? null : _toggleAddForm,
                      onSave: _savingNewService ? null : _saveNewService,
                      saving: _savingNewService,
                    ),
                  ),
                ],

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
          width: widget.columnWidth,
          badgeMinHeight: widget.headerBadgeMinH,
          isEditing: widget.isEditing,
          onSave: widget.onSaveItem,
          // X roja de visibilidad (solo en modo edición)
          onHide: widget.isEditing ? () => _handleHideService(i) : null,
        ),
      );
      if (i != items.length - 1) {
        cols.add(const _VerticalDivider());
      }
    }
    return cols;
  }
}

class _ServiceColumn extends StatefulWidget {
  final int index;
  final ServiceInfo info;
  final double width;
  final double badgeMinHeight;
  final bool isEditing;
  final Future<void> Function(int index, String newExperience, String newCost)?
  onSave;

  // 🔹 NUEVO: callback para ocultar la columna (visibilidad)
  final VoidCallback? onHide;

  const _ServiceColumn({
    required this.index,
    required this.info,
    required this.width,
    required this.badgeMinHeight,
    required this.isEditing,
    required this.onSave,
    this.onHide,
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
          // Encabezado con icono + nombre + X de visibilidad (en edición)
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
                if (widget.isEditing && widget.onHide != null) ...[
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: widget.onHide,
                    borderRadius: BorderRadius.circular(20),
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: Color(0xFFD41E1E), // rojo
                    ),
                  ),
                ],
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

/// Formulario para agregar un nuevo servicio
class _NewServiceForm extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController descCtrl;
  final TextEditingController expCtrl;
  final TextEditingController costCtrl;
  final VoidCallback? onCancel;
  final VoidCallback? onSave;
  final bool saving;

  const _NewServiceForm({
    required this.nameCtrl,
    required this.descCtrl,
    required this.expCtrl,
    required this.costCtrl,
    required this.onCancel,
    required this.onSave,
    required this.saving,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC3C0C0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Agregar nuevo servicio',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          _textField(controller: nameCtrl, label: 'Nombre del servicio'),
          const SizedBox(height: 6),
          _textField(controller: descCtrl, label: 'Descripción', maxLines: 2),
          const SizedBox(height: 6),
          _textField(controller: expCtrl, label: 'Años de experiencia'),
          const SizedBox(height: 6),
          _textField(controller: costCtrl, label: 'Costo'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: saving ? null : onCancel,
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.black87),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: saving ? null : onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  elevation: 2,
                ),
                child: Text(
                  saving ? 'Guardando...' : 'Guardar',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }
}
