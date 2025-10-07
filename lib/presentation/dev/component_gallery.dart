import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/ui/organisms/profile_header_card.dart';
import '../../core/ui/organisms/service_options_card.dart';

class ComponentGallery extends StatelessWidget {
  const ComponentGallery({Key? key}) : super(key: key);

  void _showMessage(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(milliseconds: 900)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Component Gallery (Dev)'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
          child: Center(
            child: Column(
              children: [
                const Text(
                  'Previews',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 18),

                // ProfileHeaderCard preview
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const Text(
                          'ProfileHeaderCard',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        // No usar const para pasar callbacks
                        ProfileHeaderCard(
                          name: 'Juan Pérez',
                          rating: 4.9,
                          reviews: 88,
                          imageUrl: 'https://picsum.photos/400',
                          onBack: () =>
                              _showMessage(context, 'Back pressed (Profile)'),
                          onSettings: () => _showMessage(
                            context,
                            'Settings pressed (Profile)',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ServiceOptionsCard preview
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const Text(
                          'ServiceOptionsCard',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        ServiceOptionsCard(
                          onSendMessage: () =>
                              _showMessage(context, 'Enviar mensaje (demo)'),
                          onCall: () => _showMessage(context, 'Llamar (demo)'),
                          onCancel: () =>
                              _showMessage(context, 'Cancelar servicio (demo)'),
                          onReport: () =>
                              _showMessage(context, 'Reportar servicio (demo)'),
                          onConclude: () =>
                              _showMessage(context, 'Concluir servicio (demo)'),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Nota: los botones muestran SnackBar de prueba. '
                          'Activa el checkbox antes de "Concluir" para probar la acción.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                if (kDebugMode)
                  const Text(
                    'Modo DEBUG — ComponentGallery activa. Usa hot reload para ver cambios.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
