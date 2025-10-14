import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

// Componente: 4 espacios para subir imágenes con preview y botón de eliminar.
// Pide permisos una sola vez y evita solicitudes simultáneas.
// onChanged devuelve la lista (de 4) con XFile? (nulos donde no hay imagen).
class ImageUploader4 extends StatefulWidget {
  const ImageUploader4({
    super.key,
    this.initialFiles,
    this.onChanged,
    this.width = 392,
    this.height = 120,
    this.gap = 16,
  });

  // Se puede pasar 0..4 imágenes iniciales (el resto se rellena con null).
  final List<XFile?>? initialFiles;

  final ValueChanged<List<XFile?>>? onChanged;

  /// Tamaño “objetivo” (se escala de manera fluida).
  final double width;
  final double height;

  /// Separación horizontal entre tarjetas.
  final double gap;

  @override
  State<ImageUploader4> createState() => _ImageUploader4State();
}

class _ImageUploader4State extends State<ImageUploader4> {
  final ImagePicker _picker = ImagePicker();

  /// 4 slots fijos
  late List<XFile?> _files;

  /// Para evitar lanzar solicitudes de permiso concurrentes
  bool _isRequesting = false;
  Future<Map<Permission, PermissionStatus>>? _permFuture;

  @override
  void initState() {
    super.initState();
    _files = List<XFile?>.filled(4, null);
    if (widget.initialFiles != null && widget.initialFiles!.isNotEmpty) {
      for (
        int i = 0;
        i < _files.length && i < widget.initialFiles!.length;
        i++
      ) {
        _files[i] = widget.initialFiles![i];
      }
    }
  }

  Future<bool> _ensurePermission() async {
    // En web no se requieren permisos del sistema
    if (kIsWeb) return true;

    // Si ya están concedidos, listo
    final photosGranted = await Permission.photos.isGranted;
    final storageGranted = await Permission.storage.isGranted;
    if (photosGranted || storageGranted) return true;

    // Si ya hay una solicitud en curso, espera esa misma
    if (_permFuture != null) {
      final res = await _permFuture!;
      return res.values.any((s) => s.isGranted);
    }

    // Lanza una sola solicitud combinada
    _isRequesting = true;
    _permFuture = [Permission.photos, Permission.storage].request();

    try {
      final results = await _permFuture!;
      final ok = results.values.any((s) => s.isGranted);
      return ok;
    } finally {
      _isRequesting = false;
      _permFuture = null;
    }
  }

  Future<void> _pickImage(int index) async {
    if (_isRequesting) return; // evita tocar mientras se piden permisos

    final ok = await _ensurePermission();
    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permiso de galería denegado')),
      );
      return;
    }

    final XFile? img = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (img != null && mounted) {
      setState(() => _files[index] = img);
      widget.onChanged?.call(List<XFile?>.from(_files));
    }
  }

  void _removeImage(int index) {
    setState(() => _files[index] = null);
    widget.onChanged?.call(List<XFile?>.from(_files));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double containerW = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : widget.width;

        const double horizontalPad = 10.0;
        final double innerW = containerW - (horizontalPad * 2);
        final double cardHeight = (widget.height - 20).clamp(86, 140);

        return Container(
          width: containerW,
          padding: const EdgeInsets.all(horizontalPad),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              for (int i = 0; i < 4; i++) ...[
                Expanded(
                  child: SizedBox(
                    height: cardHeight,
                    child: (_files[i] == null)
                        ? _EmptySlot(onTap: () => _pickImage(i))
                        : _ImageSlot(
                            file: _files[i]!,
                            onRemove: () => _removeImage(i),
                          ),
                  ),
                ),
                if (i != 3) SizedBox(width: widget.gap),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Tarjeta vacía con botón “+”
class _EmptySlot extends StatefulWidget {
  const _EmptySlot({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_EmptySlot> createState() => _EmptySlotState();
}

class _EmptySlotState extends State<_EmptySlot> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _down ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.25),
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (v) => setState(() => _down = v),
          borderRadius: BorderRadius.circular(8),
          splashColor: Colors.black.withValues(alpha: 0.08),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.add_box_outlined, // “Square plus”
              size: 30,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

/// Tarjeta con imagen y botón de eliminar
class _ImageSlot extends StatefulWidget {
  const _ImageSlot({required this.file, required this.onRemove});
  final XFile file;
  final VoidCallback onRemove;

  @override
  State<_ImageSlot> createState() => _ImageSlotState();
}

class _ImageSlotState extends State<_ImageSlot> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final image = kIsWeb
        ? Image.network(widget.file.path, fit: BoxFit.cover)
        : Image.file(File(widget.file.path), fit: BoxFit.cover);

    return AnimatedScale(
      scale: _down ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.25),
        child: InkWell(
          onTap: () {},
          onHighlightChanged: (v) => setState(() => _down = v),
          borderRadius: BorderRadius.circular(8),
          splashColor: Colors.black.withValues(alpha: 0.06),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                image,
                // Botón eliminar centrado
                Center(
                  child: GestureDetector(
                    onTap: widget.onRemove,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.delete_forever_rounded,
                        size: 30,
                        color: Color(0xFFD41E1E),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
