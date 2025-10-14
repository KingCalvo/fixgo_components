import 'package:flutter/material.dart';

enum MetricCardType {
  ingresosGenerados,
  totalServicios,
  totalProveedores,
  totalClientes,
}

class MetricCardData {
  final String valueText;
  final String? overrideTitle;

  const MetricCardData({required this.valueText, this.overrideTitle});
}

/// DASHBOARD de métricas (2×2)
class MetricDashboard extends StatelessWidget {
  final List<MetricCard> children;

  const MetricDashboard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool twoCols = constraints.maxWidth >= 320;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: twoCols ? 2 : 1,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 2.3,
          ),
          itemCount: children.length,
          itemBuilder: (_, i) => children[i],
        );
      },
    );
  }
}

/// CARD individual
class MetricCard extends StatelessWidget {
  final MetricCardType type;
  final MetricCardData data;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.type,
    required this.data,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final _Style s = _styleOf(type);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        splashColor: Colors.white.withValues(alpha: 0.12),
        highlightColor: Colors.white.withValues(alpha: 0.08),
        child: Container(
          constraints: const BoxConstraints(minWidth: 148, minHeight: 66),
          decoration: BoxDecoration(
            color: s.bg,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        data.overrideTitle ?? s.title,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        data.valueText,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: s.chipBg,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.trending_up,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _Style _styleOf(MetricCardType t) {
    switch (t) {
      case MetricCardType.ingresosGenerados:
        return const _Style(
          title: 'Ingresos generados',
          bg: Color(0xFF1F3C88),
          chipBg: Color(0xFF1B3373),
        );
      case MetricCardType.totalServicios:
        return const _Style(
          title: 'Total de servicios',
          bg: Color(0xFFF86117),
          chipBg: Color(0xFFCD5419),
        );
      case MetricCardType.totalProveedores:
        return const _Style(
          title: 'Total de Proveedores',
          bg: Color(0xFF2E7D32),
          chipBg: Color(0xFF266729),
        );
      case MetricCardType.totalClientes:
        return const _Style(
          title: 'Total de clientes',
          bg: Color(0xFFFEBC2F),
          chipBg: Color(0xFFDBA227),
        );
    }
  }
}

class _Style {
  final String title;
  final Color bg;
  final Color chipBg;
  const _Style({required this.title, required this.bg, required this.chipBg});
}
