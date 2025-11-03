import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'presentation/dev/component_gallery.dart';
import 'presentation/dev/Hire_Service_Form_fx.dart';
import 'presentation/dev/confirmacion_solicitudes_fx.dart';
import 'presentation/dev/confirmacion_solicitudes_proveedor.dart';
import 'presentation/dev/user_landing_page.dart';
import 'presentation/dev/conocer_proveedor.dart';
import 'presentation/dev/servicios_activos_usuario_page.dart';
import 'presentation/dev/servicios_activos_proveedor.dart';
import 'presentation/dev/solicitudes_cercanas.dart';
import 'presentation/dev/nuevas_solicitudes.dart';

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
        home: NuevasSolicitudesProveedor(),
      );
    }

    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: Center(child: Text('Hello World!'))),
    );
  }
}
