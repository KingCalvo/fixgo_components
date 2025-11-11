import 'package:flutter/material.dart';

// Sirve para ver y modificar la disponibilidad de tiempo del proveedor.
class AvailabilityData {
  final String daysLabel;
  final String timeRangeText;
  const AvailabilityData({
    this.daysLabel = 'Lunes a Viernes',
    required this.timeRangeText,
  });
}

// Row de disponibilidad
class AvailabilityRow extends StatefulWidget {
  final AvailabilityData data;

  // Se dispara cuando el usuario guarda una nueva hora.
  // Si lo dejas null, solo actualizará el UI local.
  final Future<void> Function(String newTime)? onSave;

  final double baseWidth;
  final EdgeInsets padding;

  const AvailabilityRow({
    super.key,
    required this.data,
    this.onSave,
    this.baseWidth = 412,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  State<AvailabilityRow> createState() => _AvailabilityRowState();
}

class _AvailabilityRowState extends State<AvailabilityRow> {
  bool _isEditing = false;
  bool _isSaving = false;
  late String _currentTime; // lo que se muestra cuando no está editando
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentTime = widget.data.timeRangeText;
    _controller.text = _currentTime;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleEditOrSave() async {
    if (_isEditing) {
      // Guardar
      final newTime = _controller.text.trim();
      if (newTime.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La hora no puede estar vacía')),
        );
        return;
      }

      setState(() => _isSaving = true);

      try {
        if (widget.onSave != null) {
          await widget.onSave!(newTime);
        }
        setState(() {
          _currentTime = newTime;
          _isEditing = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    } else {
      // Entrar a edición
      setState(() {
        _controller.text = _currentTime;
        _isEditing = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: widget.baseWidth),
      child: Container(
        color: Colors.white,
        padding: widget.padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Columna izquierda
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Disponible:',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Si está editando, muestra TextField; si no, texto plano
                  if (_isEditing) ...[
                    Text(
                      widget.data.daysLabel,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 40,
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: 'Ej: 9:00–18:00',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          isDense: true,
                        ),
                        onSubmitted: (_) => _handleEditOrSave(),
                      ),
                    ),
                  ] else ...[
                    Text(
                      '${widget.data.daysLabel}: $_currentTime',
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Botón Editar/Guardar
            _ActionButton(
              label: _isEditing ? 'Guardar' : 'Editar',
              icon: _isEditing ? Icons.check : Icons.edit,
              isBusy: _isSaving,
              onTap: _isSaving ? null : _handleEditOrSave,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isBusy;
  const _ActionButton({
    required this.label,
    required this.icon,
    this.onTap,
    this.isBusy = false,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      child: Material(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(4),
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.35),
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (v) => setState(() => _pressed = v),
          borderRadius: BorderRadius.circular(4),
          splashColor: Colors.white.withValues(alpha: 0.18),
          highlightColor: Colors.white.withValues(alpha: 0.10),
          child: SizedBox(
            width: 110,
            height: 28,
            child: Center(
              child: widget.isBusy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.label,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(widget.icon, size: 18, color: Colors.white),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
