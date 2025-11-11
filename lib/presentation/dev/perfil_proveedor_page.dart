import 'package:flutter/material.dart';
import '../../core/ui/ui.dart';
import '../../core/utils/service_images.dart';

/* // Top bar & utils
import 'package:flutter_fixgo_login/core/components/organisms/app_top_bar.dart';
import 'package:flutter_fixgo_login/core/utils/service_images.dart';

// Header perfil (usa tu ProfileHeaderCard con isEditing / onSave / onSettings)
import 'package:flutter_fixgo_login/features/proveedores/presentation/components/profile_header_card.dart';

// Services description (versión con isEditing y onSaveItem)
import 'package:flutter_fixgo_login/core/widgets/organisms/services_description.dart';

// Availability (renombrado de availability_row → availability_option.dart)
// La clase probablemente sigue llamándose AvailabilityRow/AvailabilityData.
import 'package:flutter_fixgo_login/features/proveedores/presentation/components/availability_option.dart';

// Reseñas
import 'package:flutter_fixgo_login/core/widgets/organisms/reviews_carousel.dart'; */

// Opcional: Supabase (para futuro guardado real)
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ProveedorPerfilPage extends StatefulWidget {
  const ProveedorPerfilPage({super.key});

  @override
  State<ProveedorPerfilPage> createState() => _ProveedorPerfilPageState();
}

class _ProveedorPerfilPageState extends State<ProveedorPerfilPage> {
  // Estado general. Con cubit cambiar el status de _pageEditing para que se cambie el icono de guardado a configuración
  bool _pageEditing = false;

  // Reseñas (cárgalas luego desde Supabase)
  final List<ReviewInfo> _reviews = const [];

  // Datos de perfil (ejemplo)
  ProviderProfileHeaderData _header = const ProviderProfileHeaderData(
    name: 'Juan Pérez',
    rating: 4.9,
    reviews: 88,
    imageUrl: 'https://picsum.photos/seed/prov1/400',
  );

  // Descripción (ejemplo)
  String _aboutText =
      'Soy Juan Pérez, me caracterizo por la responsabilidad, puntualidad y compromiso, siempre entregando resultados de calidad.';
  bool _aboutEditing = false;
  final _aboutCtrl = TextEditingController();

  // Servicios (ejemplo)
  List<ServiceInfo> _services = const [
    ServiceInfo(
      name: 'Pintura',
      title: 'Pintura de interiores',
      experienceText: '8 años de experiencia',
      costText: 'Costo: \$800 MXN',
      iconAsset: null,
    ),
    ServiceInfo(
      name: 'Jardinería',
      title: 'Poda, riego y mantenimiento',
      experienceText: '5 años de experiencia',
      costText: 'Costo: \$700 MXN',
      iconAsset: null,
    ),
    ServiceInfo(
      name: 'Jardinería',
      title: 'Poda, riego y mantenimiento',
      experienceText: '5 años de experiencia',
      costText: 'Costo: \$700 MXN',
      iconAsset: null,
    ),
  ];

  // Disponibilidad (ejemplo)
  AvailabilityData _availability = const AvailabilityData(
    daysLabel: 'Lunes a Viernes',
    timeRangeText: '9:00–18:00',
  );

  @override
  void initState() {
    super.initState();
    _aboutCtrl.text = _aboutText;
    _services = _services
        .map((s) => s.copyWith(iconAsset: _iconFromService(s.name)))
        .toList();
  }

  @override
  void dispose() {
    _aboutCtrl.dispose();
    super.dispose();
  }

  String? _iconFromService(String serviceName) {
    final imgs = serviceMiniImages(serviceName);
    if (imgs.isEmpty) return null;
    return imgs.first;
  }

  void _toggleWholePageEdit() {
    setState(() {
      _pageEditing = true;
    });
  }

  Future<void> _saveAbout() async {
    final text = _aboutCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La descripción no puede estar vacía')),
      );
      return;
    }

    setState(() {
      _aboutText = text;
      _aboutEditing = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Descripción actualizada')));
  }

  Future<String> _uploadProfileImage(XFile file) async {
    final supabase = Supabase.instance.client;
    final bytes = await file.readAsBytes();
    final path =
        'providers/demo/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await supabase.storage
        .from('avatars')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );
    return supabase.storage.from('avatars').getPublicUrl(path);
  }

  Future<void> _saveServiceItem(
    int index,
    String newExp,
    String newCost,
  ) async {
    setState(() {
      _services[index] = _services[index].copyWith(
        experienceText: newExp,
        costText: newCost,
      );
    });
  }

  Future<void> _saveAvailability(String newTime) async {
    setState(() {
      _availability = AvailabilityData(
        daysLabel: _availability.daysLabel,
        timeRangeText: newTime,
      );
    });
  }

  void _goToReviewsHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ir al historial de calificaciones')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 412),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top bar
                  const AppTopBar(role: AppUserRole.proveedor),

                  // Header de perfil
                  ProfileHeaderCard(
                    data: _header,
                    isEditing: _pageEditing,
                    onBack: () => Navigator.of(context).maybePop(),
                    onSettings: _toggleWholePageEdit, // habilita modo edición
                    onSave: (file) async {
                      final url = await _uploadProfileImage(file);
                      setState(() {
                        _header = ProviderProfileHeaderData(
                          name: _header.name,
                          rating: _header.rating,
                          reviews: _header.reviews,
                          imageUrl: url,
                          // Con cubit cambiar el status de _pageEditing para que se cambie el icono de guardado a configuración
                        );
                      });
                      return url;
                    },
                  ),

                  const SizedBox(height: 15),

                  // Descripción del perfil
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _aboutEditing
                            ? _AboutEditor(controller: _aboutCtrl)
                            : Text(
                                _aboutText,
                                textAlign: TextAlign.justify,
                                style: const TextStyle(
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Colors.black,
                                  height: 1.35,
                                ),
                              ),

                        if (_pageEditing) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: _aboutEditing
                                ? _MiniSaveButton(onTap: _saveAbout)
                                : _MiniEditButton(
                                    onTap: () =>
                                        setState(() => _aboutEditing = true),
                                  ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Servicios
                  ServicesDescription(
                    services: _services,
                    isEditing: _pageEditing,
                    onSaveItem: (index, newExp, newCost) =>
                        _saveServiceItem(index, newExp, newCost),
                  ),

                  const SizedBox(height: 15),

                  // Disponibilidad
                  AvailabilityRow(
                    data: _availability,
                    onSave: _saveAvailability,
                  ),

                  const SizedBox(height: 15),

                  // Reseñas
                  const Text(
                    'Reseñas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ReviewsCarousel(reviews: _reviews),

                  const SizedBox(height: 15),

                  // Botón historial de calificaciones
                  SizedBox(
                    width: 250,
                    height: 26,
                    child: ElevatedButton(
                      onPressed: _goToReviewsHistory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF86117),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: EdgeInsets.zero,
                        elevation: 3,
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Ver historial de calificaciones',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniEditButton extends StatelessWidget {
  final VoidCallback onTap;
  const _MiniEditButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: EdgeInsets.zero,
          minimumSize: const Size(18, 18),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          elevation: 3,
        ),
        child: const Icon(Icons.edit, size: 12, color: Colors.white),
      ),
    );
  }
}

class _MiniSaveButton extends StatelessWidget {
  final VoidCallback onTap;
  const _MiniSaveButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          elevation: 3,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: const Size(18, 18),
        ),
        child: const Text(
          'Guardar',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            fontSize: 10,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _AboutEditor extends StatelessWidget {
  final TextEditingController controller;
  const _AboutEditor({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: null,
      minLines: 3,
      textAlign: TextAlign.justify,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.all(10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        hintText: 'Escribe tu descripción...',
      ),
      style: const TextStyle(
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
        fontSize: 12,
        color: Colors.black,
        height: 1.35,
      ),
    );
  }
}
