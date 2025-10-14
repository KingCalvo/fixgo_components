import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class ProposedDatePicker extends StatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime>? onDateChanged;
  final DateTime firstDate;
  final DateTime lastDate;

  /// Dimensiones base (responsivo)
  final double baseWidth;
  final EdgeInsetsGeometry padding;

  ProposedDatePicker({
    Key? key,
    this.initialDate,
    this.onDateChanged,
    DateTime? firstDate,
    DateTime? lastDate,
    this.baseWidth = 392,
    this.padding = const EdgeInsets.all(10),
  }) : firstDate = firstDate ?? DateTime(2020, 1, 1),
       lastDate = lastDate ?? DateTime(2100, 12, 31),
       super(key: key);

  @override
  State<ProposedDatePicker> createState() => _ProposedDatePickerState();
}

class _ProposedDatePickerState extends State<ProposedDatePicker> {
  DateTime? _selected;
  bool _intlReady = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDate;
    // Cargamos datos de localización sin tocar main.dart
    initializeDateFormatting('es_MX', null).then((_) {
      Intl.defaultLocale = 'es_MX';
      if (mounted) setState(() => _intlReady = true);
    });
  }

  String _formatDate(DateTime d) {
    final locale = Intl.defaultLocale ?? 'es_MX';
    return DateFormat.yMMMMEEEEd(locale).format(d);
  }

  Future<void> _openCalendarSheet() async {
    if (!_intlReady) return;
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .35),
      builder: (ctx) {
        return _CalendarSheet(
          initial: _selected ?? DateTime.now(),
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
        );
      },
    );

    if (picked != null) {
      setState(() => _selected = picked);
      widget.onDateChanged?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth.isFinite ? c.maxWidth : widget.baseWidth;

        return Container(
          width: width,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              const Text(
                'Fecha (propuesta)',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w800, // ExtraBold
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),

              // “Input” con ícono de calendar que abre el modal
              Material(
                color: const Color(0xFFEDE8F0),
                borderRadius: BorderRadius.circular(12),
                elevation: 2,
                shadowColor: Colors.black.withValues(alpha: .18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _openCalendarSheet,
                  splashColor: Colors.black.withValues(alpha: .06),
                  highlightColor: Colors.black.withValues(alpha: .04),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 20,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _selected == null
                                ? 'Selecciona una fecha'
                                : _formatDate(_selected!),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.expand_more_rounded,
                          size: 22,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Bottom sheet con el calendario
class _CalendarSheet extends StatefulWidget {
  final DateTime initial;
  final DateTime firstDate;
  final DateTime lastDate;

  const _CalendarSheet({
    required this.initial,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_CalendarSheet> createState() => _CalendarSheetState();
}

class _CalendarSheetState extends State<_CalendarSheet> {
  late DateTime _focused;
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    _focused = widget.initial;
    _selected = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final sheetHeight = media.size.height * 0.60; // 60% de alto

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Container(
        height: sheetHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .24),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 46,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(height: 10),

            // Header: mes y año actual
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    DateFormat.yMMMM(
                      Intl.defaultLocale ?? 'es_MX',
                    ).format(_focused),
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  _CircleIconButton(
                    icon: Icons.close_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Calendario
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  elevation: 2,
                  shadowColor: Colors.black.withValues(alpha: .18),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TableCalendar(
                      locale: 'es_MX',
                      firstDay: widget.firstDate,
                      lastDay: widget.lastDate,
                      focusedDay: _focused,
                      availableGestures: AvailableGestures.horizontalSwipe,
                      headerVisible: false, // usamos header propio
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekendStyle: TextStyle(
                          color: Color(0xFF1F3C88),
                          fontWeight: FontWeight.w600,
                        ),
                        weekdayStyle: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      calendarStyle: CalendarStyle(
                        isTodayHighlighted: false,
                        // Texto de celdas
                        defaultTextStyle: const TextStyle(
                          color: Colors.black87,
                        ),
                        weekendTextStyle: const TextStyle(
                          color: Color(0xFF1F3C88),
                        ),
                        todayTextStyle: const TextStyle(color: Colors.black87),

                        // Seleccionado (círculo sólido azul y texto blanco)
                        selectedDecoration: BoxDecoration(
                          color: const Color(0xFF1F3C88),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .22),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        selectedTextStyle: const TextStyle(color: Colors.white),
                      ),
                      selectedDayPredicate: (day) =>
                          _selected != null && isSameDay(_selected, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selected = selectedDay;
                          _focused = focusedDay;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        _focused = focusedDay;
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Botón Confirmar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: _PrimaryButton(
                label: 'Confirmar fecha',
                onTap: () {
                  if (_selected != null) {
                    Navigator.pop<DateTime>(context, _selected);
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  const _PrimaryButton({required this.label, this.onTap});

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      child: Material(
        color: const Color(0xFF1F3C88),
        borderRadius: BorderRadius.circular(10),
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: .25),
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (v) => setState(() => _pressed = v),
          borderRadius: BorderRadius.circular(10),
          splashColor: Colors.white.withValues(alpha: .18),
          highlightColor: Colors.white.withValues(alpha: .10),
          child: const SizedBox(
            height: 44,
            width: double.infinity,
            child: Center(
              child: Text(
                'Confirmar fecha',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón circular para iconos del header del sheet (e.g. cerrar)
class _CircleIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CircleIconButton({required this.icon, this.onTap});

  @override
  State<_CircleIconButton> createState() => _CircleIconButtonState();
}

class _CircleIconButtonState extends State<_CircleIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      child: Material(
        color: const Color(0xFFEDE8F0),
        shape: const CircleBorder(),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: .18),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: widget.onTap,
          onHighlightChanged: (v) => setState(() => _pressed = v),
          splashColor: Colors.black.withValues(alpha: .06),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(widget.icon, color: Colors.black, size: 20),
          ),
        ),
      ),
    );
  }
}
