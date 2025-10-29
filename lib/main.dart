import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'presentation/dev/component_gallery.dart';
import 'presentation/dev/Hire_Service_Form_fx.dart';
import 'presentation/dev/confirmacion_solicitudes_fx.dart';
import 'presentation/dev/confirmacion_solicitudes_proveedor.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      return const MaterialApp(
        debugShowCheckedModeBanner: true,
        home: ConfirmacionSolicitudesPage(),
      );
    }

    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: Center(child: Text('Hello World!'))),
    );
  }
}
