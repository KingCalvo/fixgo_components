import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../core/ui/ui.dart'; // reexport de tus componentes

class HireServiceForm extends StatefulWidget {
  const HireServiceForm({Key? key}) : super(key: key);

  @override
  State<HireServiceForm> createState() => _HireServiceFormState();
}

class _HireServiceFormState extends State<HireServiceForm> {
  String _title = '';
  String _desc = '';
  String _hour = '3:00 pm (tolerancia de 30 min)';
  List<String> _selectedCategories = [];
  RoleSwitchValue _material = RoleSwitchValue.proveedor;
  DateTime? _proposedDate;

  LatLng? _jobPoint = const LatLng(18.8836, -99.0667);
  String _jobAddress = 'Ubicación actual / Yautepec Morelos';

  final List<dynamic> _images = [null, null, null, null];
  double _approximatePrice = 450;

  Widget _gap(double h) => SizedBox(height: h);

  Text _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w800,
      fontSize: 20,
      color: Colors.black,
    ),
  );

  Future<void> _onSubmit() async {
    final payload = {
      'titulo_trabajo': _title.trim(),
      'descripcion': _desc.trim(),
      'categorias': _selectedCategories,
      'material': _material == RoleSwitchValue.proveedor
          ? 'Proveedor'
          : 'Cliente',
      'fecha_propuesta': _proposedDate?.toIso8601String(),
      'hora_propuesta': _hour.trim(),
      'ubicacion_texto': _jobAddress,
      'ubicacion_lat': _jobPoint?.latitude,
      'ubicacion_lng': _jobPoint?.longitude,
      'imagenes': _images,
      'pago_aproximado': _approximatePrice,
      'created_at': DateTime.now().toIso8601String(),
    };

    // Insertar en Supabase
    // final supabase = Supabase.instance.client;

    if (!mounted) return;
    Navigator.pushNamed(
      context,
      '/confirmacion-solicitudes',
      arguments: payload,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              role: AppUserRole.cliente,
              onMenuSelected: (_) {},
              onUserSelected: (_) {},
            ),

            InfoBar(
              title: 'Contratar Proveedor',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 402),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Input Título del trabajo
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: LabeledFormInput(
                            name: 'job_title',
                            title: 'Título del trabajo',
                            hintText: 'Ejemplo: “Pintar sala”',
                            onChanged: (v) => _title = v ?? '',
                          ),
                        ),

                        _gap(10),

                        // Input Descripción detallada
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Descripción detallada del trabajo',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 6),
                              _TextArea(
                                height: 132,
                                hint:
                                    'Ejemplo: Se hará la aplicación de pintura en muros interiores',
                                onChanged: (v) => _desc = v,
                              ),
                            ],
                          ),
                        ),

                        _gap(10),

                        // Selector de categorías
                        ServiceCategorySelector(
                          onChanged: (list) =>
                              setState(() => _selectedCategories = list),
                        ),

                        _gap(10),

                        // Seleccionar Material con componente Rol Switch
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _sectionTitle('Material'),
                          ),
                        ),
                        _gap(6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: RoleSwitch(
                            value: _material,
                            onChanged: (v) => setState(() => _material = v),
                          ),
                        ),

                        _gap(10),

                        // Fecha propuesta con DatePicker (DateCalendar)
                        ProposedDatePicker(
                          initialDate: DateTime.now().add(
                            const Duration(days: 2),
                          ),
                          onDateChanged: (d) =>
                              setState(() => _proposedDate = d),
                        ),

                        _gap(10),

                        // Inout de Hora (propuesta)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: LabeledFormInput(
                            name: 'proposed_hour',
                            title: 'Hora (propuesta)',
                            hintText: '3:00 pm (tolerancia de 30 min)',
                            keyboardType: TextInputType.text,
                            onChanged: (v) => _hour = v ?? '',
                          ),
                        ),

                        _gap(10),

                        // Ubicación del trabajo
                        JobLocationSection(
                          data: JobLocationData(
                            addressText: _jobAddress,
                            point: _jobPoint ?? const LatLng(18.8836, -99.0667),
                          ),
                          resolveAddress: (address) async => null,
                          onAddressSubmitted: (txt) =>
                              setState(() => _jobAddress = txt),
                          onMapTap: (p) => setState(() => _jobPoint = p),
                        ),

                        _gap(10),

                        // Fotos de referencia
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionTitle('Fotos de referencia (Opcional)'),
                              const SizedBox(height: 6),
                              ImageUploader4(
                                onChanged: (files) {
                                  setState(() {
                                    for (
                                      int i = 0;
                                      i < _images.length && i < files.length;
                                      i++
                                    ) {
                                      _images[i] = files[i];
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),

                        _gap(10),

                        // Pago aproximado
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionTitle('Pago aproximado'),
                              const SizedBox(height: 4),
                              Container(
                                width: double.infinity,
                                height: 1,
                                color: const Color(0xFFD9D9D9),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '\$ ${_approximatePrice.toStringAsFixed(0)} MXN',
                                  style: const TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        _gap(10),

                        // Btn de Enviar contrato
                        SizedBox(
                          width: 392,
                          height: 40,
                          child: _SendButton(
                            label: 'Enviar contrato',
                            onTap: _onSubmit,
                          ),
                        ),

                        _gap(16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// TextArea local
class _TextArea extends StatelessWidget {
  final double height;
  final String hint;
  final ValueChanged<String>? onChanged;

  const _TextArea({required this.height, required this.hint, this.onChanged});

  @override
  Widget build(BuildContext context) {
    const lineHeight = 22.0;
    final lines = (height / lineHeight).floor().clamp(3, 12);

    return SizedBox(
      height: height,
      child: TextField(
        minLines: lines,
        maxLines: lines,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Color(0xFF9E9E9E)),
          ),
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}

// Botón enviado
class _SendButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _SendButton({required this.label, required this.onTap});

  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.985 : 1.0,
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
          child: Center(
            child: Text(
              widget.label,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
