import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/ui/organisms/profile_header_card.dart';

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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
