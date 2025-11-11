import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// Datos base del proveedor
class ProviderProfileHeaderData {
  final String name;
  final double rating;
  final int reviews;
  final String imageUrl;

  const ProviderProfileHeaderData({
    required this.name,
    required this.rating,
    required this.reviews,
    required this.imageUrl,
  });
}

/// Header de perfil (normal / edición).
class ProfileHeaderCard extends StatefulWidget {
  final ProviderProfileHeaderData data;

  /// Flecha atrás (si es null, NO se muestra)
  final VoidCallback? onBack;

  /// Ícono Config (si es null, NO se muestra). En edición se reemplaza por Guardar.
  final VoidCallback? onSettings;

  /// Si true, muestra botón "+" en la imagen y el botón "Guardar"
  final bool isEditing;

  /// Sube imagen a storage y retorna URL pública
  final Future<String> Function(XFile file)? onSave;

  final Color topColor;
  final Color bottomColor;
  final double height;

  const ProfileHeaderCard({
    Key? key,
    required this.data,
    this.onBack,
    this.onSettings,
    this.isEditing = false,
    this.onSave,
    this.topColor = const Color(0xFF1F3C88),
    this.bottomColor = const Color(0xFF080F22),
    this.height = 319,
  }) : super(key: key);

  @override
  State<ProfileHeaderCard> createState() => _ProfileHeaderCardState();
}

class _ProfileHeaderCardState extends State<ProfileHeaderCard> {
  final ImagePicker _picker = ImagePicker();

  XFile? _picked;
  String? _finalImageOverride;
  bool _saving = false;

  Future<bool> _ensurePermission() async {
    if (kIsWeb) return true;
    final photosGranted = await Permission.photos.request().isGranted;
    final storageGranted = await Permission.storage.request().isGranted;
    return photosGranted || storageGranted;
  }

  Future<void> _pickImage() async {
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
    if (img != null && mounted) setState(() => _picked = img);
  }

  Future<void> _handleSave() async {
    if (_picked == null || widget.onSave == null) return;
    setState(() => _saving = true);
    try {
      final url = await widget.onSave!(_picked!);
      if (!mounted) return;
      setState(() {
        _finalImageOverride = url;
        _picked = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto de perfil actualizada')),
      );
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
      width: double.infinity,
      height: widget.height,
      child: _ProfileHeaderContent(
        data: widget.data,
        onBack: widget.onBack,
        onSettings: widget.onSettings,
        isEditing: widget.isEditing,
        onPickImage: _pickImage,
        onSave: (_picked != null && !_saving && widget.onSave != null)
            ? _handleSave
            : null,
        saving: _saving,
        topColor: widget.topColor,
        bottomColor: widget.bottomColor,
        picked: _picked,
        finalImageOverride: _finalImageOverride,
      ),
    );
  }
}

class _ProfileHeaderContent extends StatelessWidget {
  final ProviderProfileHeaderData data;
  final VoidCallback? onBack;
  final VoidCallback? onSettings;

  final bool isEditing;
  final VoidCallback? onPickImage;
  final VoidCallback? onSave;
  final bool saving;

  final XFile? picked;
  final String? finalImageOverride;

  final Color topColor;
  final Color bottomColor;

  const _ProfileHeaderContent({
    required this.data,
    required this.onBack,
    required this.onSettings,
    required this.isEditing,
    required this.onPickImage,
    required this.onSave,
    required this.saving,
    required this.topColor,
    required this.bottomColor,
    required this.picked,
    required this.finalImageOverride,
  });

  ImageProvider _resolveImageProvider() {
    if (picked != null) {
      return kIsWeb
          ? NetworkImage(picked!.path)
          : FileImage(File(picked!.path));
    }
    if (finalImageOverride != null && finalImageOverride!.isNotEmpty) {
      return NetworkImage(finalImageOverride!);
    }
    return NetworkImage(data.imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = _resolveImageProvider();

    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [topColor, bottomColor],
          ),
        ),
        child: Stack(
          children: [
            // Flecha (solo si hay callback)
            if (onBack != null)
              Positioned(
                left: 8,
                top: 8,
                child: SafeArea(
                  child: _ActionIcon(
                    icon: Icons.arrow_back,
                    tooltip: 'Volver',
                    onTap: onBack,
                  ),
                ),
              ),

            // Derecha: Guardar (si isEditing) o Config (si onSettings != null)
            Positioned(
              right: 8,
              top: 8,
              child: SafeArea(
                child: isEditing
                    ? _SaveButton(
                        enabled: onSave != null,
                        saving: saving,
                        onTap: onSave,
                      )
                    : (onSettings != null
                          ? _ActionIcon(
                              icon: Icons.settings,
                              tooltip: 'Ajustes',
                              onTap: onSettings,
                            )
                          : const SizedBox.shrink()),
              ),
            ),

            // Contenido central
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Foto + botón "+"
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 6),
                        ),
                        child: ClipOval(
                          child: Image(
                            image: imageProvider,
                            fit: BoxFit.cover,
                            errorBuilder: (context, _, __) => Container(
                              color: Colors.grey.shade300,
                              child: const Icon(
                                Icons.person,
                                size: 56,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (isEditing)
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: GestureDetector(
                            onTap: onPickImage,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4392F9),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.add,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    data.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  _StarsRow(rating: data.rating),
                  const SizedBox(height: 10),

                  Text(
                    '${data.rating.toStringAsFixed(1)} Calificación',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${data.reviews} Reseñas',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionIcon extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _ActionIcon({required this.icon, required this.tooltip, this.onTap});

  @override
  State<_ActionIcon> createState() => _ActionIconState();
}

class _ActionIconState extends State<_ActionIcon> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final double scale = _pressed ? 0.9 : 1.0;

    return Semantics(
      button: true,
      label: widget.tooltip,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: widget.onTap,
            onHighlightChanged: (v) => setState(() => _pressed = v),
            splashColor: Colors.white.withValues(alpha: 0.25),
            highlightColor: Colors.white.withValues(alpha: 0.10),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Center(
                // el Icon se pinta desde el padre
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant _ActionIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
  }
}

// Botón Guardar
class _SaveButton extends StatelessWidget {
  final bool enabled;
  final bool saving;
  final VoidCallback? onTap;
  const _SaveButton({required this.enabled, required this.saving, this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color bg = enabled
        ? const Color(0xFF2E7D32)
        : Colors.white.withValues(alpha: 0.20);
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        splashColor: Colors.white.withValues(alpha: 0.18),
        highlightColor: Colors.white.withValues(alpha: 0.10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (saving)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                const Icon(Icons.check, size: 18, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                saving ? 'Guardando...' : 'Guardar',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Fila de 5 estrellas
class _StarsRow extends StatelessWidget {
  final double rating;
  const _StarsRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    const double starSize = 24;
    const double gap = 10;
    final int full = rating.floor();
    final bool hasHalf = (rating - full) >= 0.5;

    final List<Widget> stars = [];
    for (int i = 0; i < 5; i++) {
      IconData icon;
      if (i < full) {
        icon = Icons.star;
      } else if (i == full && hasHalf) {
        icon = Icons.star_half;
      } else {
        icon = Icons.star_border;
      }
      stars.add(Icon(icon, size: starSize, color: const Color(0xFFFFC107)));
      if (i != 4) stars.add(const SizedBox(width: gap));
    }
    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }
}
