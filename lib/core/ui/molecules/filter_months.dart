import 'package:flutter/material.dart';

// Filtro de meses
// Al abrir, permite seleccionar hasta 3 meses (no deja seleccionar el 4).
// Botones: Cancelar / Aplicar (Aplicar solo habilitado con 3 meses).
class FilterMonthsPill extends StatefulWidget {
  final void Function(
    List<int> selectedMonthNumbers,
    List<String> selectedMonthNames,
  )?
  onChanged;

  /// Meses preseleccionados. Si pasas más de 3, se tomarán los 3 primeros.
  final List<int> initialSelectedMonths;

  // Muestra meses abreviados
  final bool showAbbrevInLabel;

  final double width;
  final double height;

  const FilterMonthsPill({
    super.key,
    this.onChanged,
    this.initialSelectedMonths = const [],
    this.showAbbrevInLabel = true,
    this.width = 150,
    this.height = 26,
  });

  @override
  State<FilterMonthsPill> createState() => _FilterMonthsPillState();
}

class _FilterMonthsPillState extends State<FilterMonthsPill> {
  final MenuController _controller = MenuController();

  late List<int> _selected;

  static const List<String> _months = <String>[
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  static const List<String> _monthsAbbrev = <String>[
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun',
    'Jul',
    'Ago',
    'Sep',
    'Oct',
    'Nov',
    'Dic',
  ];

  @override
  void initState() {
    super.initState();
    final initial = widget.initialSelectedMonths
        .where((m) => m >= 1 && m <= 12)
        .toList();
    _selected = initial.take(3).toList(growable: true);
  }

  String get _label {
    if (_selected.isEmpty) return 'Meses';
    final names = _selected
        .map(
          (m) =>
              widget.showAbbrevInLabel ? _monthsAbbrev[m - 1] : _months[m - 1],
        )
        .toList();
    return names.join(', ');
  }

  bool get _hasSelection => _selected.isNotEmpty;

  void _toggle(int monthNumber) {
    setState(() {
      if (_selected.contains(monthNumber)) {
        _selected.remove(monthNumber);
      } else {
        if (_selected.length < 3) {
          _selected.add(monthNumber);
        }
      }
    });
  }

  void _apply() {
    if (_selected.length != 3) return;
    final names = _selected.map((m) => _months[m - 1]).toList();
    widget.onChanged?.call(List<int>.from(_selected), names);
    _controller.close();
  }

  void _cancel() {
    _controller.close();
  }

  @override
  Widget build(BuildContext context) {
    final Color baseBorder = _hasSelection
        ? const Color(0xFF1F3C88)
        : Colors.black;
    final Color baseText = _hasSelection
        ? const Color(0xFF1F3C88)
        : Colors.black;
    final Color baseIcon = _hasSelection
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
      menuChildren: [
        // Contenido del menú
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: SizedBox(
            width: 260,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Elige 3 meses',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Grid de meses
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(12, (i) {
                    final monthNumber = i + 1; // 1..12
                    final selected = _selected.contains(monthNumber);
                    final disabled = !selected && _selected.length >= 3;
                    return _MonthChip(
                      label: _monthsAbbrev[i],
                      selected: selected,
                      disabled: disabled,
                      onTap: () => _toggle(monthNumber),
                    );
                  }),
                ),

                const SizedBox(height: 12),

                // Botones
                Row(
                  children: [
                    TextButton(
                      onPressed: _cancel,
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 13,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _selected.length == 3 ? _apply : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F3C88),
                        disabledBackgroundColor: const Color(
                          0xFF1F3C88,
                        ).withValues(alpha: 0.30),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(88, 34),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                        shadowColor: Colors.black.withValues(alpha: 0.25),
                      ),
                      child: const Text(
                        'Aplicar',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
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
                  Icon(Icons.filter_list, size: 24, color: baseIcon),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MonthChip extends StatefulWidget {
  final String label;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  const _MonthChip({
    required this.label,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  @override
  State<_MonthChip> createState() => _MonthChipState();
}

class _MonthChipState extends State<_MonthChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bool sel = widget.selected;
    final bool dis = widget.disabled;

    final Color bg = sel
        ? const Color(0xFF1F3C88)
        : (dis ? const Color(0xFFEAEAEA) : const Color(0xFFF5F5F5));

    final Color text = sel
        ? Colors.white
        : (dis ? Colors.black.withValues(alpha: 0.45) : Colors.black);

    return AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      child: Material(
        color: bg,
        elevation: sel ? 2 : 0,
        shadowColor: Colors.black.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onHighlightChanged: (v) => setState(() => _pressed = v),
          onTap: dis ? null : widget.onTap,
          borderRadius: BorderRadius.circular(6),
          splashColor: Colors.white.withValues(alpha: sel ? 0.20 : 0.10),
          highlightColor: Colors.white.withValues(alpha: sel ? 0.10 : 0.06),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              widget.label,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
