import 'package:flutter/material.dart';

enum AppUserRole { cliente, proveedor, admin }

class AppTopBar extends StatelessWidget {
  final AppUserRole role;
  final String logoAsset;
  final void Function(String id)? onMenuSelected;
  final void Function(String id)? onUserSelected;

  const AppTopBar({
    super.key,
    required this.role,
    this.logoAsset = 'assets/LogoNaranja.png',
    this.onMenuSelected,
    this.onUserSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF2E2E2E),
      elevation: 4,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 65.5,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _AnchorMenuIcon(
                  tooltip: 'Menú',
                  icon: Icons.menu,
                  size: 44,
                  items: _menuItemsForRole(role),
                  onSelected: onMenuSelected,
                ),
                const SizedBox(width: 10),
                const _CompactLogo(width: 175, height: 45.5),
                const Spacer(),
                _AnchorMenuIcon(
                  tooltip: 'Cuenta',
                  icon: Icons.account_circle_outlined,
                  size: 45.5,
                  items: _userItemsForRole(role),
                  onSelected: onUserSelected,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Menú hamburguesa por rol
  List<_MenuEntry> _menuItemsForRole(AppUserRole r) {
    switch (r) {
      case AppUserRole.cliente:
        return const [
          _MenuEntry('home', Icons.home, 'Inicio'),
          _MenuEntry('confirmar', Icons.verified, 'Confirmar servicios'),
          _MenuEntry('servicios', Icons.receipt_long, 'Servicios'),
        ];
      case AppUserRole.proveedor:
        return const [
          _MenuEntry('home', Icons.home, 'Inicio'),
          _MenuEntry(
            'confirmacion',
            Icons.verified,
            'Confirmación de servicios',
          ),
          _MenuEntry('servicios', Icons.receipt_long, 'Servicios'),
        ];
      case AppUserRole.admin:
        return const [
          _MenuEntry('metricas', Icons.settings, 'Métricas'),
          _MenuEntry('proveedores', Icons.logout, 'Proveedores'),
        ];
    }
  }

  // Menú usuario por rol
  List<_MenuEntry> _userItemsForRole(AppUserRole r) {
    switch (r) {
      case AppUserRole.cliente:
        return const [
          _MenuEntry('perfil', Icons.settings, 'Perfil'),
          _MenuEntry('salir', Icons.logout, 'Salir'),
        ];
      case AppUserRole.proveedor:
        return const [
          _MenuEntry('perfil', Icons.settings, 'Perfil'),
          _MenuEntry('historial', Icons.bar_chart, 'Historial'),
          _MenuEntry('salir', Icons.logout, 'Salir'),
        ];
      case AppUserRole.admin:
        return const [
          _MenuEntry('ajustes', Icons.settings, 'Ajustes'),
          _MenuEntry('salir', Icons.logout, 'Salir'),
        ];
    }
  }
}

/// Icono que abre un menú usando MenuAnchor (abre/cierra 100% seguro)
class _AnchorMenuIcon extends StatefulWidget {
  final IconData icon;
  final double size;
  final String? tooltip;
  final List<_MenuEntry> items;
  final void Function(String id)? onSelected;

  const _AnchorMenuIcon({
    required this.icon,
    required this.size,
    required this.items,
    this.tooltip,
    this.onSelected,
  });

  @override
  State<_AnchorMenuIcon> createState() => _AnchorMenuIconState();
}

class _AnchorMenuIconState extends State<_AnchorMenuIcon> {
  final MenuController _controller = MenuController();

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: _controller,
      style: const MenuStyle(
        surfaceTintColor: WidgetStatePropertyAll(Colors.white),
        backgroundColor: WidgetStatePropertyAll(Colors.white),
        elevation: WidgetStatePropertyAll(8),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
      menuChildren: widget.items
          .map(
            (e) => MenuItemButton(
              leadingIcon: Icon(e.icon, size: 24, color: Colors.black),
              onPressed: () {
                widget.onSelected?.call(e.id);
                _controller.close();
              },
              child: const SizedBox(
                width: 160, // ancho cómodo para el texto
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '', // el texto lo ponemos en el label abajo
                  ),
                ),
              ),
              style: ButtonStyle(
                alignment: Alignment.centerLeft,
                textStyle: WidgetStatePropertyAll(
                  const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
                foregroundColor: WidgetStatePropertyAll(Colors.black),
              ),
            ),
          )
          .toList()
          .asMap()
          .entries
          .map((entry) {
            final i = entry.key;
            final btn = entry.value;
            final label = widget.items[i].label;
            return Stack(
              children: [
                btn,
                Positioned.fill(
                  left: 44, // deja espacio del icono
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            );
          })
          .toList(),
      builder: (context, controller, child) {
        return IconButton(
          tooltip: widget.tooltip,
          iconSize: widget.size * 0.82,
          splashRadius: widget.size * 0.62,
          color: Colors.white,
          onPressed: () {
            controller.isOpen ? controller.close() : controller.open();
          },
          icon: Icon(widget.icon, color: Colors.white),
        );
      },
    );
  }
}

class _CompactLogo extends StatelessWidget {
  final double width;
  final double height;
  const _CompactLogo({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Row(
        children: [
          Container(
            width: height,
            height: height,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/LogoNaranja.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.build, color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'FixGo',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w800,
              fontSize: 32,
              color: Colors.white,
              height: 1.0,
              letterSpacing: .5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuEntry {
  final String id;
  final IconData icon;
  final String label;
  const _MenuEntry(this.id, this.icon, this.label);
}
