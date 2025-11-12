import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

// ====== TUS COMPONENTES (ajusta las rutas reales) ======
// import 'package:flutter_fixgo_login/core/components/organisms/app_top_bar.dart';
// import 'package:flutter_fixgo_login/core/components/molecules/info_bar.dart';
// import 'package:flutter_fixgo_login/core/components/molecules/filter_months.dart' show FilterMonthsPill;
// import 'package:flutter_fixgo_login/core/widgets/molecules/metric_card.dart';
import '../../core/ui/ui.dart';
/* import '../../core/components/organisms/app_top_bar.dart';
import '../../core/components/molecules/info_bar.dart';
import '../../core/components/molecules/filter_months.dart'
    show FilterMonthsPill;
import '../../core/widgets/molecules/metric_card.dart'; */

// =======================================

class ProviderPerformancePage extends StatefulWidget {
  const ProviderPerformancePage({super.key});

  @override
  State<ProviderPerformancePage> createState() =>
      _ProviderPerformancePageState();
}

class _ProviderPerformancePageState extends State<ProviderPerformancePage> {
  final GlobalKey _pdfSectionKey = GlobalKey();

  // Estado simulado
  num _ingresosGenerados = 9200;
  int _totalServicios = 22;

  double _calificacionPromedio = 4.7;
  int _comisionActualPct = 10;
  int _serviciosParaProxEval = 3;

  /// Ingresos / servicios / comisión por mes (1..12)
  final Map<int, int> _ingresosPorMes = {
    7: 1350,
    8: 900,
    9: 2250,
    10: 1500,
    11: 2100,
    12: 2850,
  };
  final Map<int, int> _serviciosPorMes = {
    7: 4,
    8: 3,
    9: 5,
    10: 4,
    11: 6,
    12: 7,
  };
  final Map<int, int> _comisionAplicadaPorMes = {
    7: 7,
    8: 7,
    9: 7,
    10: 8,
    11: 7,
    12: 7,
  };

  late List<int> _selectedMonths;

  @override
  void initState() {
    super.initState();
    _selectedMonths = _defaultLast3();
  }

  List<int> _defaultLast3() {
    final months = _ingresosPorMes.keys.toList()..sort();
    if (months.length <= 3) return months;
    return months.sublist(months.length - 3);
  }

  int get _kpiServiciosCompletados =>
      _selectedMonths.fold<int>(0, (s, m) => s + (_serviciosPorMes[m] ?? 0));

  int get _kpiComisionAplicadaPromedio {
    final vals = _selectedMonths
        .map((m) => _comisionAplicadaPorMes[m] ?? 0)
        .toList();
    if (vals.isEmpty) return 0;
    return (vals.reduce((a, b) => a + b) / vals.length).round();
  }

  int get _kpiTotalIngresos =>
      _selectedMonths.fold<int>(0, (s, m) => s + (_ingresosPorMes[m] ?? 0));

  // PDF: captura solo la sección con key _pdfSectionKey
  Future<void> _exportToPdf() async {
    try {
      final boundary =
          _pdfSectionKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => pw.Center(
            child: pw.Image(pw.MemoryImage(pngBytes), fit: pw.BoxFit.contain),
          ),
        ),
      );
      final bytes = await pdf.save();
      await Printing.sharePdf(bytes: bytes, filename: 'mi_desempeno.pdf');
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

    // Métricas derivadas (para la card de ingresos)
    final serviciosCompletados = _kpiServiciosCompletados;
    final comisionProm = _kpiComisionAplicadaPromedio;
    final totalIngresos = _kpiTotalIngresos;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // (NO entran al PDF)
            const SliverToBoxAdapter(
              child: AppTopBar(role: AppUserRole.proveedor),
            ),
            const SliverToBoxAdapter(child: InfoBar(title: 'Mi desempeño')),
            const SliverToBoxAdapter(child: SizedBox(height: 15)),

            // Botón Generar Reporte (NO entra en el PDF)
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: maxBodyWidth),
                  child: _GenerateReportButton(onTap: _exportToPdf),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 15)),

            // PDF SECTION (desde aquí hacia abajo)
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: maxBodyWidth),
                  child: RepaintBoundary(
                    key: _pdfSectionKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // MÉTRICAS
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: MetricDashboard(
                            children: [
                              MetricCard(
                                type: MetricCardType.ingresosGenerados,
                                data: MetricCardData(
                                  valueText: currency.format(
                                    _ingresosGenerados,
                                  ),
                                ),
                              ),
                              MetricCard(
                                type: MetricCardType.totalServicios,
                                data: MetricCardData(
                                  valueText: '$_totalServicios',
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 15),

                        // Tarjeta "Desempeño"
                        _PerformanceCard(
                          avgRating: _calificacionPromedio,
                          commissionPct: _comisionActualPct,
                          nextEvalServices: _serviciosParaProxEval,
                          onHistoryTap: () {
                            // TODO: navegar a historial de servicios
                          },
                        ),

                        const SizedBox(height: 15),

                        // Ingresos con filtro y gráfica (3 meses)
                        _IncomeCard(
                          selectedMonths: _selectedMonths,
                          onMonthsChanged: (months) => setState(() {
                            _selectedMonths = months..sort();
                          }),
                          serviciosCompletados: serviciosCompletados,
                          comisionAplicadaPromedio: comisionProm,
                          totalIngresos: totalIngresos,
                          monthlyIncome: _ingresosPorMes,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 15)),

            // Botón inferior (NO entra al PDF)
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: maxBodyWidth),
                  child: SizedBox(
                    width: 250,
                    height: 26,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Navegar
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF86117),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        elevation: 3,
                      ),
                      child: const Text(
                        'Ver historial de reseñas',
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
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

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

class _PerformanceCard extends StatelessWidget {
  final double avgRating;
  final int commissionPct;
  final int nextEvalServices;
  final VoidCallback onHistoryTap;

  const _PerformanceCard({
    required this.avgRating,
    required this.commissionPct,
    required this.nextEvalServices,
    required this.onHistoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 370,
      height: 190,
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
        children: [
          const Text(
            'Desempeño',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 7),
          Container(height: 1, width: 352, color: const Color(0xFFC4C4C4)),
          const SizedBox(height: 7),

          _rowText('Calificación promedio:', avgRating.toStringAsFixed(1)),
          const SizedBox(height: 4),
          _rowText('Comisión actual:', '$commissionPct %'),
          const SizedBox(height: 4),
          _rowText('Próxima evaluación:', 'En $nextEvalServices servicios más'),

          const Spacer(),

          Material(
            color: const Color(0xFF2E7D32),
            borderRadius: BorderRadius.circular(4),
            elevation: 3,
            shadowColor: Colors.black.withValues(alpha: 0.25),
            child: InkWell(
              onTap: onHistoryTap,
              borderRadius: BorderRadius.circular(4),
              splashColor: Colors.white.withValues(alpha: 0.12),
              child: const SizedBox(
                width: 172,
                height: 30,
                child: Center(
                  child: Text(
                    'Historial de servicios',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowText(String left, String right) {
    return Row(
      children: [
        Text(
          left,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          right,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class _IncomeCard extends StatelessWidget {
  final List<int> selectedMonths;
  final void Function(List<int>) onMonthsChanged;

  final int serviciosCompletados;
  final int comisionAplicadaPromedio;
  final int totalIngresos;
  final Map<int, int> monthlyIncome;

  const _IncomeCard({
    required this.selectedMonths,
    required this.onMonthsChanged,
    required this.serviciosCompletados,
    required this.comisionAplicadaPromedio,
    required this.totalIngresos,
    required this.monthlyIncome,
  });

  String _monthAbbrev(int m) {
    const abbr = [
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
    return (m >= 1 && m <= 12) ? abbr[m] : m.toString();
  }

  bool _isNearInt(double v) => (v - v.round()).abs() < 0.001;

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
          // Header: título + filtro meses
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
                    onChanged: (selectedMonthNumbers, _names) {
                      onMonthsChanged(selectedMonthNumbers);
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _kpiLine('Servicios completados:', '$serviciosCompletados'),
          const SizedBox(height: 4),
          _kpiLine('Comisión aplicada:', '$comisionAplicadaPromedio %'),
          const SizedBox(height: 4),
          _kpiLine(
            'Total de ingresos:',
            NumberFormat.currency(
              locale: 'es_MX',
              symbol: r'$',
            ).format(totalIngresos),
          ),

          const SizedBox(height: 30),

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
                  top: false,
                  bottom: false,
                  left: false,
                  right: false,
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (v, _) => Text(
                        v.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      ),
                      interval: topY <= 0 ? 1000 : (topY / 4),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (v, _) {
                        if (!_isNearInt(v)) return const SizedBox.shrink();
                        final idx = v.round();
                        if (idx < 0 || idx >= sel.length) {
                          return const SizedBox.shrink();
                        }
                        final month = sel[idx];
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _monthAbbrev(month),
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
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: (topY / 4),
                ),
                borderData: FlBorderData(show: true),
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

  Widget _kpiLine(String left, String right) {
    return Row(
      children: [
        Text(
          left,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          right,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
