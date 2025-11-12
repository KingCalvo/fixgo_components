import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

// ====== TUS COMPONENTES (ajusta rutas reales) ======
/* import '../../core/ui/ui.dart'; // para AppUserRole si lo necesitas
// import 'package:flutter_fixgo_login/core/components/organisms/app_top_bar.dart';
import '../../core/components/organisms/app_top_bar.dart';
// import 'package:flutter_fixgo_login/core/components/molecules/info_bar.dart';
import '../../core/components/molecules/info_bar.dart';
// import 'package:flutter_fixgo_login/core/components/molecules/filter_months.dart';
import '../../core/components/molecules/filter_months.dart'
    show FilterMonthsPill;
// import 'package:flutter_fixgo_login/core/components/molecules/metric_card.dart';
import '../../core/components/molecules/metric_card.dart'; */
// =======================================
import '../../core/ui/ui.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  // RepaintBoundary solo para lo que debe ir al PDF
  final GlobalKey _pdfSectionKey = GlobalKey();

  // Estado simulado
  num _ingresosGenerados = 100830;
  int _totalServicios = 1200;
  int _totalProveedores = 800;
  int _totalClientes = 1300;

  // Series por mes (1..12)
  final Map<int, int> _serviciosPorMes = {
    7: 90,
    8: 80,
    9: 78,
    10: 85,
    11: 92,
    12: 88,
  };

  final Map<int, int> _ingresosPorMes = {
    7: 2234,
    8: 5600,
    9: 3890,
    10: 4200,
    11: 5100,
    12: 4975,
  };

  // Selección de meses por card
  late List<int> _selMesesServicios;
  late List<int> _selMesesIngresos;

  @override
  void initState() {
    super.initState();
    _selMesesServicios = _defaultLast3(_serviciosPorMes);
    _selMesesIngresos = _defaultLast3(_ingresosPorMes);
  }

  List<int> _defaultLast3(Map<int, int> series) {
    final months = series.keys.toList()..sort();
    if (months.length <= 3) return months;
    return months.sublist(months.length - 3);
  }

  // Exportar a PDF: solo lo que está dentro de _pdfSectionKey
  Future<void> _exportToPdf() async {
    try {
      final boundary =
          _pdfSectionKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => pw.Center(
            child: pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.contain),
          ),
        ),
      );
      final out = await pdf.save();
      await Printing.sharePdf(bytes: out, filename: 'metricas_admin.pdf');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al generar PDF: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    const maxBodyWidth = 412.0;
    final currency = NumberFormat.currency(locale: 'es_MX', symbol: r'$');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // NO entran al PDF:
            const SliverToBoxAdapter(child: AppTopBar(role: AppUserRole.admin)),
            const SliverToBoxAdapter(child: InfoBar(title: 'Métricas')),
            const SliverToBoxAdapter(child: SizedBox(height: 15)),

            // Botón Generar Reporte (NO entra al PDF)
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: maxBodyWidth),
                  child: _GenerateReportButton(onTap: _exportToPdf),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 15)),

            // Sección que SÍ va al PDF
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: maxBodyWidth),
                  child: RepaintBoundary(
                    key: _pdfSectionKey,
                    child: Column(
                      children: [
                        // MetricDashboard
                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              SizedBox(
                                width: 200,
                                child: MetricCard(
                                  type: MetricCardType.ingresosGenerados,
                                  data: MetricCardData(
                                    valueText: currency.format(
                                      _ingresosGenerados,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 180,
                                child: MetricCard(
                                  type: MetricCardType.totalServicios,
                                  data: MetricCardData(
                                    valueText: '$_totalServicios',
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 200,
                                child: MetricCard(
                                  type: MetricCardType.totalProveedores,
                                  data: const MetricCardData(valueText: '800'),
                                ),
                              ),
                              SizedBox(
                                width: 180,
                                child: MetricCard(
                                  type: MetricCardType.totalClientes,
                                  data: const MetricCardData(
                                    valueText: '1,300',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 15),

                        // Card Servicios (Grafica de barra)
                        _ServicesCard(
                          selectedMonths: _selMesesServicios,
                          onMonthsChanged: (m) =>
                              setState(() => _selMesesServicios = m..sort()),
                          monthlyServices: _serviciosPorMes,
                        ),

                        const SizedBox(height: 15),

                        // Card Ingresos (Grafica de línea)
                        _IncomeCardAdmin(
                          selectedMonths: _selMesesIngresos,
                          onMonthsChanged: (m) =>
                              setState(() => _selMesesIngresos = m..sort()),
                          monthlyIncome: _ingresosPorMes,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 15)),
          ],
        ),
      ),
    );
  }
}

// Botón PDF
class _GenerateReportButton extends StatefulWidget {
  final VoidCallback onTap;
  const _GenerateReportButton({required this.onTap});

  @override
  State<_GenerateReportButton> createState() => _GenerateReportButtonState();
}

class _GenerateReportButtonState extends State<_GenerateReportButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      child: Material(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(4),
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.25),
        child: InkWell(
          onHighlightChanged: (v) => setState(() => _pressed = v),
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(4),
          splashColor: Colors.white.withValues(alpha: 0.15),
          child: const SizedBox(
            width: 156,
            height: 26,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Generar Reporte',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.receipt_long, size: 22, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Card: Servicios
class _ServicesCard extends StatelessWidget {
  final List<int> selectedMonths;
  final void Function(List<int>) onMonthsChanged;
  final Map<int, int> monthlyServices;

  const _ServicesCard({
    required this.selectedMonths,
    required this.onMonthsChanged,
    required this.monthlyServices,
  });

  String _abbr(int m) {
    const a = [
      '',
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return (m >= 1 && m <= 12) ? a[m] : m.toString();
  }

  bool _nearInt(double v) => (v - v.round()).abs() < 0.001;

  @override
  Widget build(BuildContext context) {
    final sel = [...selectedMonths]..sort();
    final maxY =
        (sel.isEmpty
                ? 0
                : sel
                      .map((m) => monthlyServices[m] ?? 0)
                      .reduce((a, b) => a > b ? a : b))
            .toDouble();
    final topY = (maxY <= 0 ? 100 : (maxY * 1.2)).ceilToDouble();
    final double minX = -0.2;
    final double maxX = sel.isEmpty ? 2.2 : (sel.length - 1 + 0.2);

    return Container(
      width: 370,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'Servicios',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 120),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FilterMonthsPill(
                    initialSelectedMonths: sel,
                    width: 130,
                    height: 26,
                    onChanged: (nums, _) => onMonthsChanged(nums),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          const Center(
            child: Text(
              'Servicios en 3 meses',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),

          const SizedBox(height: 8),

          SizedBox(
            height: 240,
            width: double.infinity,
            child: BarChart(
              BarChartData(
                minY: 0,
                maxY: topY,
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: (topY / 5),
                ),
                borderData: FlBorderData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (v, _) => Text(
                        v.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      ),
                      interval: (topY / 5),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (v, _) {
                        if (!_nearInt(v)) return const SizedBox.shrink();
                        final i = v.round();
                        if (i < 0 || i >= sel.length)
                          return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _abbr(sel[i]),
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                      interval: 1,
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                barGroups: List.generate(sel.length, (i) {
                  final m = sel[i];
                  final y = (monthlyServices[m] ?? 0).toDouble();
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: y,
                        width: 16,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Card: Ingresos
class _IncomeCardAdmin extends StatelessWidget {
  final List<int> selectedMonths;
  final void Function(List<int>) onMonthsChanged;
  final Map<int, int> monthlyIncome;

  const _IncomeCardAdmin({
    required this.selectedMonths,
    required this.onMonthsChanged,
    required this.monthlyIncome,
  });

  String _abbr(int m) {
    const a = [
      '',
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return (m >= 1 && m <= 12) ? a[m] : m.toString();
  }

  bool _nearInt(double v) => (v - v.round()).abs() < 0.001;

  @override
  Widget build(BuildContext context) {
    final sel = [...selectedMonths]..sort();

    final maxY =
        (sel.isEmpty
                ? 0
                : sel
                      .map((m) => monthlyIncome[m] ?? 0)
                      .reduce((a, b) => a > b ? a : b))
            .toDouble();
    final topY = (maxY <= 0 ? 1000 : (maxY * 1.2)).ceilToDouble();
    final double minX = -0.2;
    final double maxX = sel.isEmpty ? 2.2 : (sel.length - 1 + 0.2);

    return Container(
      width: 370,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'Ingresos',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 120),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FilterMonthsPill(
                    initialSelectedMonths: sel,
                    width: 130,
                    height: 26,
                    onChanged: (nums, _) => onMonthsChanged(nums),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          const Center(
            child: Text(
              'Ingresos en 3 meses',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),

          const SizedBox(height: 8),

          SizedBox(
            height: 240,
            width: double.infinity,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: topY,
                minX: minX,
                maxX: maxX,
                clipData: const FlClipData(
                  left: false,
                  right: false,
                  top: false,
                  bottom: false,
                ),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: (topY / 5),
                ),
                borderData: FlBorderData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (v, _) => Text(
                        v.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      ),
                      interval: (topY / 5),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (v, _) {
                        if (!_nearInt(v)) return const SizedBox.shrink();
                        final idx = v.round();
                        if (idx < 0 || idx >= sel.length)
                          return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _abbr(sel[idx]),
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                      interval: 1,
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: true),
                    spots: List.generate(sel.length, (i) {
                      final m = sel[i];
                      final y = (monthlyIncome[m] ?? 0).toDouble();
                      return FlSpot(i.toDouble(), y);
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
