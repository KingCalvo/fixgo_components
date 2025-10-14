import 'package:flutter/material.dart';

class QuickFilter {
  final String label;
  final double? width;

  /// Asset opcional 25x25 para el ícono/imagen del filtro
  final String? iconAsset;

  const QuickFilter({required this.label, this.width, this.iconAsset});
}

/// Panel de búsqueda (base 412×102) con:
/// - Input “Busca lo que necesitas” (402×42, #E0D8E0, borde 8)
/// - Carrusel horizontal de filtros rápidos clicables
class SearchPanel extends StatefulWidget {
  final void Function(String query)? onSearchTap;

  final void Function(String filterLabel)? onFilterTap;

  final List<QuickFilter>? filters;

  final double baseWidth;
  final double baseHeight;

  const SearchPanel({
    super.key,
    this.onSearchTap,
    this.onFilterTap,
    this.filters,
    this.baseWidth = 412,
    this.baseHeight = 102,
  });

  @override
  State<SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends State<SearchPanel> {
  final _controller = TextEditingController();

  List<QuickFilter> get _filters =>
      widget.filters ??
      const [
        QuickFilter(label: 'Pintura'),
        QuickFilter(label: 'Limpieza de Exteriores'),
        QuickFilter(label: 'Plomería'),
        QuickFilter(label: 'Jardinería'),
        QuickFilter(label: 'Reparación de Electrodomésticos'),
      ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth.isFinite ? c.maxWidth : widget.baseWidth;
        final h = c.maxHeight.isFinite ? c.maxHeight : widget.baseHeight;
        final scaleW = w / widget.baseWidth;
        final scaleH = h / widget.baseHeight;
        final scale = scaleW < scaleH ? scaleW : scaleH;

        return SizedBox(
          width: widget.baseWidth * scale,
          height: widget.baseHeight * scale,
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.topLeft,
            child: _content(),
          ),
        );
      },
    );
  }

  Widget _content() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // INPUT
        _SearchInput(
          controller: _controller,
          onTapIcon: () => widget.onSearchTap?.call(_controller.text.trim()),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 5),
            itemCount: _filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final f = _filters[i];
              return _QuickFilterChip(
                label: f.label,
                width: f.width, // null => auto width
                iconAsset: f.iconAsset, // opcional
                onTap: () => widget.onFilterTap?.call(f.label),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SearchInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onTapIcon;
  const _SearchInput({required this.controller, this.onTapIcon});

  @override
  State<_SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<_SearchInput> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.99 : 1.0,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 402,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFE0D8E0),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          child: Row(
            children: [
              Expanded(
                child: Focus(
                  onFocusChange: (focus) =>
                      setState(() => _pressed = focus), // animación al enfocar
                  child: TextField(
                    controller: widget.controller,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Color(0xFF424242),
                    ),
                    decoration: const InputDecoration(
                      isCollapsed: true,
                      hintText: 'Busca lo que necesitas',
                      hintStyle: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Color(0xFF424242),
                      ),
                      border: InputBorder.none,
                    ),
                    onEditingComplete: () {
                      setState(() => _pressed = false);
                      widget.onTapIcon?.call();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Icono lupa (acción de buscar)
              InkResponse(
                radius: 20,
                onTap: widget.onTapIcon,
                splashColor: Colors.black.withValues(alpha: 0.12),
                highlightColor: Colors.black.withValues(alpha: 0.08),
                child: const SizedBox(
                  width: 32,
                  height: 32,
                  child: Icon(Icons.search, size: 18, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickFilterChip extends StatefulWidget {
  final String label;
  final double? width; // null => auto width
  final String? iconAsset;
  final VoidCallback? onTap;

  const _QuickFilterChip({
    required this.label,
    this.width,
    this.iconAsset,
    this.onTap,
  });

  @override
  State<_QuickFilterChip> createState() => _QuickFilterChipState();
}

class _QuickFilterChipState extends State<_QuickFilterChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final chipCore = Container(
      constraints: const BoxConstraints(minHeight: 40, minWidth: 80),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC3C0C0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 25,
            height: 25,
            child: widget.iconAsset == null
                ? const Icon(Icons.image, size: 22, color: Color(0xFF616161))
                : Image.asset(
                    widget.iconAsset!,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.broken_image,
                      size: 22,
                      color: Color(0xFF616161),
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          Text(
            widget.label,
            maxLines: 1,
            softWrap: false,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Color(0xFF424242),
            ),
          ),
        ],
      ),
    );

    final sized = widget.width == null
        ? IntrinsicWidth(child: chipCore) // ancho auto según el texto
        : SizedBox(width: widget.width, child: chipCore);

    return AnimatedScale(
      scale: _pressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (v) => setState(() => _pressed = v),
          borderRadius: BorderRadius.circular(8),
          splashColor: Colors.black.withValues(alpha: 0.06),
          highlightColor: Colors.black.withValues(alpha: 0.04),
          child: sized,
        ),
      ),
    );
  }
}
