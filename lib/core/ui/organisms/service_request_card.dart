import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/* Este widget representa una card para mostrar solicitudes de servicio. Puede tener tres variantes:
Solicitud, Propuesta y Servicio. */

/* Versiones:

1. Versión Solicitud:
Muestra la solicitud que hace el cliente para contratar al proveedor, tienes los botones de Rechazar y Confirmar.

2. Versión Propuesta:
Tiene tres status (por lo tanto 3 versiones): Pendiente, Enviada y Aceptada.
Ahora si el status es Pendiente va a tener otras dos versiones: Cliente y Proveedor.
Cuando es la versión Propuesta Cliente y tiene el status “Pendiente” muestra solo dos botones Rechazar y Confirmar.
Cuando es la versión Propuesta Proveedor y tiene el status “Pendiente” muestra cambiar la Hora estimada e Ingresar el costo. Ingresar el costo solo aparecerá si el Material es por parte del Proveedor si es por parte del Cliente no tiene que aparecer ese input.

3. Versión Servicio:
Tiene cuatro status (Son 4 chips visibles, 3 layouts): Activo, Finalizado, Cancelado, Reportado. Y muestra lo de enviar mensajes, cancelar, reportar y concluir.
*/

/// Variante de la card
enum ServiceCardVariant { solicitud, propuesta, servicio }

/// Vista de la propuesta cuando está Pendiente
enum ProposalPendingView { cliente, proveedor }

/// Estados para Propuesta
enum ProposalStatus { pendiente, enviada, aceptada }

/// Estados para Servicio
enum ServiceStatus { activo, finalizado, cancelado, reportado }

Color _proposalColor(ProposalStatus s) {
  switch (s) {
    case ProposalStatus.aceptada:
      return const Color(0xFF2E7D32);
    case ProposalStatus.enviada:
    case ProposalStatus.pendiente:
      return const Color(0xFFF7931A);
  }
}

Color _serviceColor(ServiceStatus s) {
  switch (s) {
    case ServiceStatus.activo:
      return const Color(0xFF2E7D32);
    case ServiceStatus.finalizado:
      return const Color(0xFF1F3C88);
    case ServiceStatus.cancelado:
      return const Color(0xFFD41E1E);
    case ServiceStatus.reportado:
      return const Color(0xFFF86117);
  }
}

// -------------------- Datos --------------------

class ServiceRequestData {
  // Encabezado
  final String customerName;
  final String customerPhotoUrl;
  final double rating;

  // Detalle
  final String serviceType;
  final String title;

  /// Origen del material ("Proveedor", "Propio")
  final String materialSource;

  final String location;
  final String dateText;
  final String timeText;

  final String placeImageUrl; // imagen
  final String description;
  final List<String> miniImages; // íconos/mini fotos

  final String totalText;

  // Campos opcionales para variantes
  final String? serviceNumber;
  final ProposalStatus? proposalStatus;

  /// Texto visible de hora estimada
  final String? estimatedTimeText;

  final ServiceStatus? serviceStatus;

  const ServiceRequestData({
    required this.customerName,
    required this.customerPhotoUrl,
    required this.rating,
    required this.serviceType,
    required this.title,
    required this.materialSource,
    required this.location,
    required this.dateText,
    required this.timeText,
    required this.placeImageUrl,
    required this.description,
    required this.miniImages,
    required this.totalText,
    // opcionales
    this.serviceNumber,
    this.proposalStatus,
    this.estimatedTimeText,
    this.serviceStatus,
  });
}

// -------------------- Card --------------------

/// Card “Solicitud/Propuesta/Servicio”
class ServiceRequestCard extends StatefulWidget {
  final ServiceCardVariant variant;
  final ServiceRequestData data;

  // Acciones comunes
  final VoidCallback? onReject;
  final VoidCallback? onConfirm;

  /// Confirm que envía payload (cost/hora nueva)
  final void Function({double? costOverride, String? estimatedTimeOverride})?
  onConfirmWithPayload;

  // Propuesta
  final VoidCallback? onModifyEstimatedTimeTap; //abre input
  final VoidCallback? onTermsTap;

  // Servicio (activo/cancelado/finalizado/reportado)
  final VoidCallback? onCancel;
  final VoidCallback? onReport;
  final VoidCallback? onConclude;
  final VoidCallback? onOpenReceipt; // finalizado
  final VoidCallback? onChat;
  final VoidCallback? onCall;

  final double baseWidth;
  final double? baseHeightOverride;
  final double padding;
  final double borderRadius;

  /// Vista solo para Propuesta Pendiente
  final ProposalPendingView? proposalPendingView;

  /// Para definir si el material es por parte del proveedor
  final bool? materialBySupplierOverride;

  const ServiceRequestCard({
    super.key,
    required this.variant,
    required this.data,
    // acciones
    this.onReject,
    this.onConfirm,
    this.onConfirmWithPayload,
    this.onModifyEstimatedTimeTap,
    this.onTermsTap,
    this.onCancel,
    this.onReport,
    this.onConclude,
    this.onOpenReceipt,
    this.onChat,
    this.onCall,
    // estilo
    this.baseWidth = 402,
    this.baseHeightOverride,
    this.padding = 10,
    this.borderRadius = 8,
    // propuesta
    this.proposalPendingView,
    this.materialBySupplierOverride,
  });

  @override
  State<ServiceRequestCard> createState() => _ServiceRequestCardState();
}

class _ServiceRequestCardState extends State<ServiceRequestCard> {
  // Inputs internos de costo y hora estimada
  final TextEditingController _costCtrl = TextEditingController();
  final TextEditingController _estimatedTimeCtrl = TextEditingController();

  bool _editingEstimatedTime = false;

  @override
  void initState() {
    super.initState();
    if (widget.data.estimatedTimeText != null) {
      _estimatedTimeCtrl.text = widget.data.estimatedTimeText!;
    }
  }

  @override
  void dispose() {
    _costCtrl.dispose();
    _estimatedTimeCtrl.dispose();
    super.dispose();
  }

  bool get _isProposalPending =>
      widget.variant == ServiceCardVariant.propuesta &&
      widget.data.proposalStatus == ProposalStatus.pendiente;

  bool get _isProposalPendingCliente =>
      _isProposalPending &&
      widget.proposalPendingView == ProposalPendingView.cliente;

  bool get _isProposalPendingProveedor =>
      _isProposalPending &&
      (widget.proposalPendingView == ProposalPendingView.proveedor ||
          widget.proposalPendingView == null);

  bool get _materialBySupplier {
    if (widget.materialBySupplierOverride != null) {
      return widget.materialBySupplierOverride!;
    }
    final src = widget.data.materialSource.toLowerCase().trim();
    return src.contains('proveedor') ||
        src == 'propio' ||
        src == 'del proveedor';
  }

  double _parseTotalNumber(String totalText) {
    // Extrae número del texto tipo "450 MXN" o "$450.00"
    final digits = RegExp(r'([\d]+([.,]\d+)?)').firstMatch(totalText);
    if (digits == null) return 0;
    final n = digits.group(1)!.replaceAll(',', '.');
    return double.tryParse(n) ?? 0;
  }

  String _formatMoneyMXN(double value, {String suffix = ' MXN'}) {
    final fixed = value.toStringAsFixed(
      value.truncateToDouble() == value ? 0 : 2,
    );
    return '\$$fixed$suffix';
  }

  /// Total mostrado: si hay costo nuevo, se suma al total original solo visualmente.
  String get _computedTotalText {
    final base = _parseTotalNumber(widget.data.totalText);
    final extra = double.tryParse(_costCtrl.text.replaceAll(',', '.')) ?? 0;
    final total = (extra > 0) ? (base + extra) : base;
    return _formatMoneyMXN(total);
  }

  // Alturas base ajustables
  static const double _hSolicitud = 480;
  static const double _hPropuestaBase = 480;
  static const double _hPropuestaProveedorConCosto = 610;
  static const double _hPropuestaProveedorModificar = 550;
  static const double _hPropuestaEnviada = 480;
  static const double _hPropuestaAceptada = 480;
  static const double _hServicioFinalizado = 460;
  static const double _hServicioCanceladoReportado = 446;
  static const double _hServicioActivo = 609;

  double _computedBaseHeight() {
    // --- PROPUESTA ---
    if (widget.variant == ServiceCardVariant.propuesta) {
      final status = widget.data.proposalStatus;

      // Pendiente
      if (status == ProposalStatus.pendiente) {
        // Si es proveedor y el material lo pone él (hay input de costo)
        if (_isProposalPendingProveedor && _materialBySupplier) {
          return _hPropuestaProveedorConCosto;
        }

        // Si es proveedor pero NO hay costo (solo modificar hora)
        if (_isProposalPendingProveedor && !_materialBySupplier) {
          return _hPropuestaProveedorModificar;
        }

        // Cliente u otros casos pendientes
        return _hPropuestaBase;
      }

      // Enviada
      if (status == ProposalStatus.enviada) {
        return _hPropuestaEnviada;
      }

      // Aceptada
      if (status == ProposalStatus.aceptada) {
        return _hPropuestaAceptada;
      }

      // Cualquier otro caso de propuesta (fallback)
      return _hPropuestaBase;
    }

    // --- SOLICITUD ---
    if (widget.variant == ServiceCardVariant.solicitud) {
      return _hSolicitud;
    }

    // --- SERVICIO ---
    if (widget.data.serviceStatus == ServiceStatus.finalizado) {
      return _hServicioFinalizado;
    }

    if (widget.data.serviceStatus == ServiceStatus.cancelado ||
        widget.data.serviceStatus == ServiceStatus.reportado) {
      return _hServicioCanceladoReportado;
    }

    // Activo
    return _hServicioActivo;
  }

  @override
  Widget build(BuildContext context) {
    final baseHeight = widget.baseHeightOverride ?? _computedBaseHeight();

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth.isFinite ? c.maxWidth : widget.baseWidth;
        final h = c.maxHeight.isFinite ? c.maxHeight : baseHeight;
        final scale = (w / widget.baseWidth < h / baseHeight)
            ? w / widget.baseWidth
            : h / baseHeight;

        return Center(
          child: SizedBox(
            width: widget.baseWidth * scale,
            height: baseHeight * scale,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(color: Colors.black.withValues(alpha: 0.7)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: EdgeInsets.all(widget.padding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(),
                    const SizedBox(height: 6),
                    const _Divider382(),
                    const SizedBox(height: 6),
                    _topDetailBlock(),
                    const SizedBox(height: 12),
                    _descriptionBlock(),
                    const SizedBox(height: 8),
                    const _Divider382(),
                    const SizedBox(height: 6),
                    _proposalOrServiceExtrasAndTotal(), // total va aquí
                    ..._footerActions(context),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------- Secciones ----------------

  Widget _header() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _Avatar(pathOrUrl: widget.data.customerPhotoUrl, size: 43),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            widget.data.customerName,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 10),
        _StarsRow(rating: widget.data.rating, gap: 6, size: 18),
      ],
    );
  }

  Widget _topDetailBlock() {
    final bool showProposalChip =
        widget.variant == ServiceCardVariant.propuesta &&
        widget.data.proposalStatus != null;

    final bool showServiceChip =
        widget.variant == ServiceCardVariant.servicio &&
        widget.data.serviceStatus != null;

    return SizedBox(
      height: 170,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 141,
            child: _RoundedImage(
              pathOrUrl: widget.data.placeImageUrl,
              height: 150,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: widget.data.serviceNumber == null
                            ? 'Servicio: '
                            : 'Servicio ${widget.data.serviceNumber!}: ',
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: widget.data.serviceType,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),

                Text(
                  widget.data.title,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontSize: 17,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                Row(
                  children: [
                    const Text(
                      'Material: ',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w300,
                        fontSize: 14.25,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      widget.data.materialSource,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w300,
                        fontSize: 14.25,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      widget.data.materialSource.toLowerCase() == 'propio'
                          ? Icons.house_rounded
                          : Icons.directions_car_rounded,
                      size: 18,
                      color: Colors.black.withValues(alpha: 0.8),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                Text(
                  widget.data.location,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w300,
                    fontSize: 13,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),

                Row(
                  children: [
                    Text(
                      widget.data.dateText,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w300,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 45),
                    Text(
                      widget.data.timeText,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w300,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),

                if (showProposalChip) ...[
                  const SizedBox(height: 8),
                  _statusChip(
                    text: switch (widget.data.proposalStatus!) {
                      ProposalStatus.pendiente => 'Pendiente',
                      ProposalStatus.enviada => 'Enviada',
                      ProposalStatus.aceptada => 'Aceptada',
                    },
                    color: _proposalColor(widget.data.proposalStatus!),
                  ),
                ],

                if (showServiceChip) ...[
                  const SizedBox(height: 8),
                  _statusChip(
                    text: switch (widget.data.serviceStatus!) {
                      ServiceStatus.activo => 'Activo',
                      ServiceStatus.finalizado => 'Finalizado',
                      ServiceStatus.cancelado => 'Cancelado',
                      ServiceStatus.reportado => 'Reportado',
                    },
                    color: _serviceColor(widget.data.serviceStatus!),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip({required String text, required Color color}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 201,
        height: 20,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _descriptionBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descripción',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          widget.data.description,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w300,
            fontSize: 12,
            color: Color(0xFF484747),
            height: 1.25,
          ),
        ),
        const SizedBox(height: 8),
        if (widget.data.miniImages.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.data.miniImages
                .map((p) => _MiniImage(pathOrUrl: p))
                .toList(),
          ),
      ],
    );
  }

  Widget _proposalOrServiceExtrasAndTotal() {
    // PROPUESTA Pendiente del Cliente: Sin hora ni costo, solo botones (footer)
    if (_isProposalPendingCliente) {
      return _totalRow(
        _formatMoneyMXN(_parseTotalNumber(widget.data.totalText)),
      );
    }

    // PROPUESTA Pendiente del Proveedor: Hora estimada, Costo (proveedor)
    if (_isProposalPendingProveedor) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hora estimada
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Hora estimada: ',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 6),
              if (_editingEstimatedTime)
                SizedBox(
                  width: 160,
                  height: 28,
                  child: TextField(
                    controller: _estimatedTimeCtrl,
                    decoration: _inputDecoration(hint: 'Ej. 1h 30m'),
                    style: const TextStyle(fontSize: 14),
                    onChanged: (_) => setState(() {}),
                  ),
                )
              else
                Text(
                  _estimatedTimeCtrl.text.isEmpty
                      ? (widget.data.estimatedTimeText ?? '')
                      : _estimatedTimeCtrl.text,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              const Spacer(),
              if (!_editingEstimatedTime)
                _SmallActionButton(
                  label: 'Modificar',
                  color: const Color(0xFFF86117),
                  onTap: () {
                    setState(() {
                      _editingEstimatedTime = true;
                    });
                    widget.onModifyEstimatedTimeTap?.call();
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          const _Divider382(),
          const SizedBox(height: 8),

          // Ingresa costo (solo si material por parte del proveedor)
          if (_materialBySupplier) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Ingresa el costo del material',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 140,
                  height: 28,
                  child: TextField(
                    controller: _costCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: false,
                    ),
                    decoration: _inputDecoration(hint: '0.00'),
                    style: const TextStyle(fontSize: 14),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          _totalRow(_computedTotalText),

          const SizedBox(height: 6),
          const _Divider382(),
          const SizedBox(height: 6),

          // Términos
          Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w300,
                  fontSize: 12,
                  color: Colors.black,
                  height: 1.2,
                ),
                children: [
                  const TextSpan(text: 'Al seleccionar el botón, acepto los '),
                  TextSpan(
                    text: 'términos del servicio',
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: (widget.onTermsTap == null)
                        ? null
                        : (TapGestureRecognizer()..onTap = widget.onTermsTap),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // PROPUESTA (enviada/aceptada)
    if (widget.variant == ServiceCardVariant.propuesta) {
      return _totalRow(
        _formatMoneyMXN(_parseTotalNumber(widget.data.totalText)),
      );
    }

    // SERVICIO
    if (widget.variant == ServiceCardVariant.servicio) {
      final s = widget.data.serviceStatus;
      if (s == ServiceStatus.finalizado) {
        return Row(
          children: [
            const Text(
              'Total',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.data.totalText,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            _ReceiptButton(onTap: widget.onOpenReceipt),
          ],
        );
      }

      if (s == ServiceStatus.cancelado || s == ServiceStatus.reportado) {
        return _totalRow(
          _formatMoneyMXN(_parseTotalNumber(widget.data.totalText)),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _totalRow(_formatMoneyMXN(_parseTotalNumber(widget.data.totalText))),
          const SizedBox(height: 6),
          const _Divider382(),
        ],
      );
    }

    // SOLICITUD
    return _totalRow(_formatMoneyMXN(_parseTotalNumber(widget.data.totalText)));
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      isDense: true,
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFF9E9E9E)),
      ),
    );
  }

  Widget _totalRow(String totalText) {
    return Row(
      children: [
        const Text(
          'Total',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        const Spacer(),
        Text(
          totalText,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  List<Widget> _footerActions(BuildContext context) {
    // SOLICITUD Rechazar / Confirmar
    if (widget.variant == ServiceCardVariant.solicitud) {
      return [
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ActionButton(
              label: 'Rechazar',
              color: const Color(0xFFD41E1E),
              onTap: widget.onReject,
            ),
            const SizedBox(width: 12),
            _ActionButton(
              label: 'Confirmar',
              color: const Color(0xFF2E7D32),
              onTap: widget.onConfirm,
            ),
          ],
        ),
      ];
    }

    // PROPUESTA Pendiente del Cliente: solo Rechazar / Confirmar
    if (_isProposalPendingCliente) {
      return [
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ActionButton(
              label: 'Rechazar',
              color: const Color(0xFFD41E1E),
              onTap: widget.onReject,
            ),
            const SizedBox(width: 12),
            _ActionButton(
              label: 'Confirmar',
              color: const Color(0xFF2E7D32),
              onTap: () {
                widget.onConfirmWithPayload?.call(
                  costOverride: null,
                  estimatedTimeOverride: null,
                );
                widget.onConfirm?.call();
              },
            ),
          ],
        ),
      ];
    }

    // PROPUESTA (Pendiente Proveedor con input de hora/costo)
    if (widget.variant == ServiceCardVariant.propuesta) {
      return [
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ActionButton(
              label: 'Rechazar',
              color: const Color(0xFFD41E1E),
              onTap: widget.onReject,
            ),
            const SizedBox(width: 12),
            _ActionButton(
              label: 'Confirmar',
              color: const Color(0xFF2E7D32),
              onTap: () {
                double? cost;
                if (_isProposalPendingProveedor && _materialBySupplier) {
                  final parsed = double.tryParse(
                    _costCtrl.text.replaceAll(',', '.'),
                  );
                  if (parsed != null && parsed >= 0) cost = parsed;
                }
                String? hour;
                if (_isProposalPendingProveedor) {
                  final text = _estimatedTimeCtrl.text.trim();
                  if (text.isNotEmpty) hour = text;
                }

                widget.onConfirmWithPayload?.call(
                  costOverride: cost,
                  estimatedTimeOverride: hour,
                );
                widget.onConfirm?.call();
              },
            ),
          ],
        ),
      ];
    }

    // SERVICI: Acciones por status
    if (widget.data.serviceStatus == ServiceStatus.activo) {
      return [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 37.57,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.53),
                  border: Border.all(color: const Color(0xFFE6E6E6)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Envía un mensaje',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w300,
                    fontSize: 14,
                    color: Color(0xFF484747),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 11),
            _SquareIconButton(
              icon: Icons.chat_bubble_outline_rounded,
              onTap: widget.onChat,
            ),
            const SizedBox(width: 11),
            _SquareIconButton(icon: Icons.phone_rounded, onTap: widget.onCall),
          ],
        ),
        const SizedBox(height: 8),
        const _Divider382(),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ActionButton(
              label: 'Cancelar',
              color: const Color(0xFFD41E1E),
              width: 160,
              onTap: widget.onCancel,
            ),
            const SizedBox(width: 12),
            _ActionButton(
              label: 'Reportar',
              color: const Color(0xFFF86117),
              width: 160,
              onTap: widget.onReport,
            ),
            const SizedBox(width: 12),
          ],
        ),
        const SizedBox(height: 8),
        _FullWidthActionButton(
          label: 'Concluir',
          color: const Color(0xFF2E7D32),
          onTap: widget.onConclude,
        ),
        const SizedBox(height: 4),
        Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w300,
                fontSize: 12,
                color: Colors.black,
              ),
              children: [
                TextSpan(text: 'Al seleccionar el botón, Concluir los '),
                TextSpan(
                  text: 'términos del servicio',
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    // Finalizado/Cancelado/Reportado
    return const [SizedBox.shrink()];
  }
}

class _Divider382 extends StatelessWidget {
  const _Divider382();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      width: double.infinity,
      color: const Color(0xFFC4C4C4),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String pathOrUrl;
  final double size;
  const _Avatar({required this.pathOrUrl, this.size = 43});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: _tryNetworkOrAsset(pathOrUrl, fit: BoxFit.cover),
    );
  }
}

class _RoundedImage extends StatelessWidget {
  final String pathOrUrl;
  final double height;
  const _RoundedImage({required this.pathOrUrl, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFECEFF1),
      ),
      clipBehavior: Clip.antiAlias,
      child: _tryNetworkOrAsset(pathOrUrl, fit: BoxFit.cover),
    );
  }
}

class _MiniImage extends StatelessWidget {
  final String pathOrUrl;
  const _MiniImage({required this.pathOrUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46.7,
      height: 33.39,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFF5F5F5),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: _tryNetworkOrAsset(pathOrUrl),
    );
  }
}

Widget _tryNetworkOrAsset(String p, {BoxFit fit = BoxFit.cover}) {
  final isNet = p.startsWith('http://') || p.startsWith('https://');
  if (isNet) {
    return Image.network(
      p,
      fit: fit,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.image_not_supported, color: Color(0xFF9E9E9E)),
    );
  }
  return Image.asset(
    p,
    fit: fit,
    errorBuilder: (_, __, ___) =>
        const Icon(Icons.broken_image, color: Color(0xFF9E9E9E)),
  );
}

class _StarsRow extends StatelessWidget {
  final double rating;
  final double size;
  final double gap;
  const _StarsRow({required this.rating, this.size = 18, this.gap = 6});

  @override
  Widget build(BuildContext context) {
    final int full = rating.floor();
    final bool half = (rating - full) >= 0.5;
    final List<Widget> stars = [];
    for (int i = 0; i < 5; i++) {
      IconData icon;
      Color color;
      if (i < full) {
        icon = Icons.star;
        color = const Color(0xFFFFC107);
      } else if (i == full && half) {
        icon = Icons.star_half;
        color = const Color(0xFFFFC107);
      } else {
        icon = Icons.star_border;
        color = Colors.black87; // contorno visible
      }
      stars.add(Icon(icon, size: size, color: color));
      if (i != 4) stars.add(SizedBox(width: gap));
    }
    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }
}

class _ActionButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final double width;
  final double height;

  const _ActionButton({
    required this.label,
    required this.color,
    this.onTap,
    this.width = 165,
    this.height = 24,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      child: Material(
        color: widget.color,
        borderRadius: BorderRadius.circular(4),
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.35),
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (v) => setState(() => _pressed = v),
          borderRadius: BorderRadius.circular(4),
          splashColor: Colors.white.withValues(alpha: 0.18),
          highlightColor: Colors.white.withValues(alpha: 0.10),
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: Center(
              child: Text(
                widget.label,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FullWidthActionButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _FullWidthActionButton({
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  State<_FullWidthActionButton> createState() => _FullWidthActionButtonState();
}

class _FullWidthActionButtonState extends State<_FullWidthActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      child: Material(
        color: widget.color,
        borderRadius: BorderRadius.circular(4),
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.35),
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (v) => setState(() => _pressed = v),
          borderRadius: BorderRadius.circular(4),
          splashColor: Colors.white.withValues(alpha: 0.18),
          highlightColor: Colors.white.withValues(alpha: 0.10),
          child: SizedBox(
            width: 382,
            height: 24,
            child: Center(
              child: Text(
                widget.label,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SmallActionButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _SmallActionButton({
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  State<_SmallActionButton> createState() => _SmallActionButtonState();
}

class _SmallActionButtonState extends State<_SmallActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      child: Material(
        color: widget.color,
        borderRadius: BorderRadius.circular(4),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (v) => setState(() => _pressed = v),
          borderRadius: BorderRadius.circular(4),
          splashColor: Colors.white.withValues(alpha: 0.18),
          highlightColor: Colors.white.withValues(alpha: 0.10),
          child: SizedBox(
            width: 130,
            height: 20,
            child: Center(
              child: Text(
                widget.label,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SquareIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _SquareIconButton({required this.icon, this.onTap});

  @override
  State<_SquareIconButton> createState() => _SquareIconButtonState();
}

class _SquareIconButtonState extends State<_SquareIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      child: Material(
        color: const Color(0xFFE6E6E6),
        borderRadius: BorderRadius.circular(6.53),
        elevation: 1.5,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (v) => setState(() => _pressed = v),
          borderRadius: BorderRadius.circular(6.53),
          splashColor: Colors.black.withValues(alpha: 0.06),
          child: SizedBox(
            width: 37.57,
            height: 37.57,
            child: Center(
              child: Icon(
                widget.icon,
                size: 20,
                color: Colors.black.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReceiptButton extends StatefulWidget {
  final VoidCallback? onTap;
  const _ReceiptButton({this.onTap});

  @override
  State<_ReceiptButton> createState() => _ReceiptButtonState();
}

class _ReceiptButtonState extends State<_ReceiptButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      child: Material(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(4),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (v) => setState(() => _pressed = v),
          borderRadius: BorderRadius.circular(4),
          splashColor: Colors.white.withValues(alpha: 0.18),
          highlightColor: Colors.white.withValues(alpha: 0.10),
          child: SizedBox(
            width: 169,
            height: 18,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Comprobante de pago',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w300,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
