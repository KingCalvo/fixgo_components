import 'package:flutter/material.dart';

/// Datos expuestos a Presentación
class ServiceCategorySelector extends StatefulWidget {
  final List<String> options;

  final List<String> initialSelected;

  /// Callback cuando cambia la selección
  final ValueChanged<List<String>>? onChanged;

  /// Resolve del asset por nombre de categoría.
  /// Por defecto: "<Categoria>Img.png" dentro de assets/
  final String Function(String category)? assetResolver;

  final double baseWidth;

  final double baseHeight;

  const ServiceCategorySelector({
    super.key,
    this.options = const [
      'Pintura',
      'Herrería',
      'Jardinería',
      'Limpieza de exteriores',
      'Plomería',
      'Reparación de electrodomésticos',
      'Albañilería',
    ],
    this.initialSelected = const [],
    this.onChanged,
    this.assetResolver,
    this.baseWidth = 392,
    this.baseHeight = 104,
  });

  @override
  State<ServiceCategorySelector> createState() =>
      _ServiceCategorySelectorState();
}

class _ServiceCategorySelectorState extends State<ServiceCategorySelector> {
  late List<String> _selected;
  String? _pendingAdd;

  String _defaultAssetFor(String category) {
    // Nombre de archivo: "<Categoria>Img.png" sin tildes ni mayúsculas exactas
    // pero como lo defines tú, aquí respetamos tal cual:
    // p.ej. "Pintura" -> assets/PinturaImg.png
    final safe = category.replaceAll(' ', '');
    return 'assets/${safe}Img.png';
  }

  @override
  void initState() {
    super.initState();
    _selected = [...widget.initialSelected];
  }

  void _addSelected() {
    if (_pendingAdd == null) return;
    if (_selected.contains(_pendingAdd)) return;
    setState(() {
      _selected.add(_pendingAdd!);
      _pendingAdd = null;
    });
    widget.onChanged?.call(List.unmodifiable(_selected));
  }

  void _remove(String category) {
    setState(() => _selected.remove(category));
    widget.onChanged?.call(List.unmodifiable(_selected));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final maxW = c.maxWidth.isFinite ? c.maxWidth : widget.baseWidth;

        return ConstrainedBox(
          constraints: BoxConstraints(minWidth: maxW),
          child: Container(
            width: maxW,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selecciona la o las categorías',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w800, // ExtraBold
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _pendingAdd,
                  icon: const Icon(Icons.arrow_drop_down_rounded),
                  decoration: InputDecoration(
                    hintText: 'Pintura',
                    hintStyle: const TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: Color(0xFF9E9E9E),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 255, 255, 255),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.withValues(alpha: .6),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.withValues(alpha: .6),
                      ),
                    ),
                  ),
                  items: widget.options
                      .map(
                        (opt) => DropdownMenuItem<String>(
                          value: opt,
                          child: Text(
                            opt,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    setState(() => _pendingAdd = val);
                    _addSelected(); // añade al momento de elegir
                  },
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _selected
                      .map(
                        (cat) => _MiniCategoryCard(
                          label: cat,
                          assetPath: (widget.assetResolver ?? _defaultAssetFor)
                              .call(cat),
                          onRemove: () => _remove(cat),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MiniCategoryCard extends StatelessWidget {
  final String label;
  final String assetPath;
  final VoidCallback onRemove;

  const _MiniCategoryCard({
    required this.label,
    required this.assetPath,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onRemove, // tap para eliminar (también hay X)
        child: Container(
          constraints: const BoxConstraints(minWidth: 110, minHeight: 40),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFC3C0C0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono/imagen 25x25
              SizedBox(
                width: 25,
                height: 25,
                child: _AssetOrPlaceholder(path: assetPath),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFF424242),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: Colors.black.withValues(alpha: .60),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssetOrPlaceholder extends StatelessWidget {
  final String path;
  const _AssetOrPlaceholder({required this.path});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Icon(
        Icons.image_outlined,
        size: 20,
        color: Colors.black.withValues(alpha: .45),
      ),
    );
  }
}
