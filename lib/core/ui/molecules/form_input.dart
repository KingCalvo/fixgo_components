import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

/// Input para formularios (presentación pura)
/// - Título configurable (por defecto: "Titulo del trabajo").
/// - Campo de texto usando flutter_form_builder (look & feel moderno).
/// - No hace llamadas a datos: emite cambios vía onChanged.
/// - Responsivo: ocupa el ancho disponible, alto del campo ~40.
///
/// Requisitos:
///   flutter_form_builder: ^9.2.1 (o similar)
class LabeledFormInput extends StatefulWidget {
  final String title;
  final String name; // clave del campo dentro del form
  final String? hintText;
  final String? initialValue;
  final ValueChanged<String?>? onChanged;
  final TextInputType keyboardType;
  final bool enabled;
  final int? maxLength;

  const LabeledFormInput({
    Key? key,
    this.title = 'Titulo del trabajo',
    required this.name,
    this.hintText,
    this.initialValue,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.maxLength,
  }) : super(key: key);

  @override
  State<LabeledFormInput> createState() => _LabeledFormInputState();
}

class _LabeledFormInputState extends State<LabeledFormInput> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth.isFinite ? c.maxWidth : 392.0;

        return ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 72),
          child: SizedBox(
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w800, // ExtraBold
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),

                // FormBuilder con un solo campo
                FormBuilder(
                  key: _formKey,
                  child: FormBuilderTextField(
                    name: widget.name,
                    initialValue: widget.initialValue,
                    enabled: widget.enabled,
                    keyboardType: widget.keyboardType,
                    maxLength: widget.maxLength,
                    onChanged: widget.onChanged,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.hintText ?? 'Escribe aquí…',
                      hintStyle: const TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Color(0xFF424242),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10, // ~40 de alto total
                      ),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 255, 255, 255),
                      counterText: '',

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.black.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF1F3C88),
                          width: 1.5,
                        ),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.black.withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),

                      // Sombra sutil (envolvemos con Material para animación ripple)
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
