import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Variante de la card
enum ServiceCardVariant { solicitud, propuesta, servicio }

/// Estados para Propuesta
enum ProposalStatus { pendiente, enviada, aceptada }

/// Estados para Servicio
enum ServiceStatus { activo, finalizado, cancelado }

Color _proposalColor(ProposalStatus s) {
  switch (s) {
    case ProposalStatus.aceptada:
      return const Color(0xFF2E7D32);
    case ProposalStatus.pendiente:
    case ProposalStatus.enviada:
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
  }
}

class ServiceRequestData {
  // Encabezado
  final String customerName; 
  final String customerPhotoUrl; 
  final double rating; 

  // Detalle
  final String serviceType; // "Pintura"
  final String title; // "Pintar sala y comedor"
  final String materialSource; // "Propio" | "Proveedor"
  final String location; // "Yautepec Mor."
  final String dateText; // "26/08/2025"
  final String timeText; // "17:20 Hrs"

  final String placeImageUrl; // imagen lugar (Firebase)
  final String description; // texto largo
  final List<String> miniImages; // íconos/mini fotos

  final String totalText; // "$1,200 MXN"

  // Campos opcionales para variantes
  final String? serviceNumber; // "24569" (Propuesta/Servicio)
  final ProposalStatus? proposalStatus; // chip (Propuesta)
  final String? estimatedTimeText; // "17:30 hrs" (Propuesta)
  final ServiceStatus? serviceStatus; // chip (Servicio)

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
    // opcionales:
    this.serviceNumber,
    this.proposalStatus,
    this.estimatedTimeText,
    this.serviceStatus,
  });
}

/// Card “Solicitud/Propuesta/Servicio”
class ServiceRequestCard extends StatelessWidget {
  final ServiceCardVariant variant;
  final ServiceRequestData data;

  // Acciones comunes
  final VoidCallback? onReject;
  final VoidCallback? onConfirm;

  // Propuesta
  final VoidCallback? onModifyEstimatedTime;
  final VoidCallback? onTermsTap;

  // Servicio (activo/cancelado/finalizado)
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

  const ServiceRequestCard({
    super.key,
    required this.variant,
    required this.data,
    // acciones
    this.onReject,
    this.onConfirm,
    this.onModifyEstimatedTime,
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
  });

  double _computedBaseHeight() {
    if (variant == ServiceCardVariant.solicitud) return 470; // tu ajuste
    if (variant == ServiceCardVariant.propuesta) return 550; // tu ajuste

    // servicio
    if (data.serviceStatus == ServiceStatus.finalizado) return 450; // ✅ pedido
    if (data.serviceStatus == ServiceStatus.cancelado) return 440; // ✅ pedido
    return 609; // activo
  }

  @override
  Widget build(BuildContext context) {
    final baseHeight = baseHeightOverride ?? _computedBaseHeight();

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth.isFinite ? c.maxWidth : baseWidth;
        final h = c.maxHeight.isFinite ? c.maxHeight : baseHeight;
        final scale = (w / baseWidth < h / baseHeight)
            ? w / baseWidth
            : h / baseHeight;

        return Center(
          child: SizedBox(
            width: baseWidth * scale,
            height: baseHeight * scale,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(borderRadius),
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
                padding: EdgeInsets.all(padding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(),
                    const SizedBox(height: 6),
                    const _Divider382(),
                    const SizedBox(height: 6),
                    _topDetailBlock(), // imagen + textos + chip según variante
                    const SizedBox(height: 12),
                    _descriptionBlock(),
                    const SizedBox(height: 8),
                    const _Divider382(),
                    const SizedBox(height: 6),
                    _totalRowAndExtras(), // total + (extras según variante)
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
        _Avatar(url: data.customerPhotoUrl, size: 43),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            data.customerName,
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
        _StarsRow(rating: data.rating, gap: 6, size: 18),
      ],
    );
  }

  Widget _topDetailBlock() {
    final bool showProposalChip =
        variant == ServiceCardVariant.propuesta && data.proposalStatus != null;
    final bool showServiceChip =
        variant == ServiceCardVariant.servicio && data.serviceStatus != null;

    return SizedBox(
      height: 170,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 141,
            child: _RoundedImage(url: data.placeImageUrl, height: 150),
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
                        text: data.serviceNumber == null
                            ? 'Servicio: '
                            : 'Servicio ${data.serviceNumber!}: ',
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: data.serviceType,
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
                  data.title,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
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
                      data.materialSource,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w300,
                        fontSize: 14.25,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      data.materialSource.toLowerCase() == 'propio'
                          ? Icons.house_rounded
                          : Icons.directions_car_rounded,
                      size: 18,
                      color: Colors.black.withValues(alpha: 0.8),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                Text(
                  data.location,
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
                      data.dateText,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w300,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 45),
                    Text(
                      data.timeText,
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
                    text: switch (data.proposalStatus!) {
                      ProposalStatus.pendiente => 'Pendiente',
                      ProposalStatus.enviada => 'Enviada',
                      ProposalStatus.aceptada => 'Aceptada',
                    },
                    color: _proposalColor(data.proposalStatus!),
                  ),
                ],

                if (showServiceChip) ...[
                  const SizedBox(height: 8),
                  _statusChip(
                    text: switch (data.serviceStatus!) {
                      ServiceStatus.activo => 'Activo',
                      ServiceStatus.finalizado => 'Finalizado',
                      ServiceStatus.cancelado => 'Cancelado',
                    },
                    color: _serviceColor(data.serviceStatus!),
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
        height: 17,
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
          data.description,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w300,
            fontSize: 12,
            color: Color(0xFF484747),
            height: 1.25,
          ),
        ),
        const SizedBox(height: 8),
        if (data.miniImages.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: data.miniImages
                .map((p) => _MiniImage(pathOrUrl: p))
                .toList(),
          ),
      ],
    );
  }

  Widget _totalRowAndExtras() {
    final totalRow = Row(
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
          data.totalText,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ],
    );

    // Extras según variante
    if (variant == ServiceCardVariant.propuesta &&
        data.estimatedTimeText != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          totalRow,
          const SizedBox(height: 6),
          const _Divider382(),
          const SizedBox(height: 8),
          Row(
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Hora estimada: ',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: data.estimatedTimeText!,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              _SmallActionButton(
                label: 'Modificar',
                color: const Color(0xFFF86117),
                onTap: onModifyEstimatedTime,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const _Divider382(),
          const SizedBox(height: 6),
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
                    recognizer: (onTermsTap == null)
                        ? null
                        : (TapGestureRecognizer()..onTap = onTermsTap),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (variant == ServiceCardVariant.servicio) {
      if (data.serviceStatus == ServiceStatus.finalizado) {
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
              data.totalText,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            _ReceiptButton(onTap: onOpenReceipt),
          ],
        );
      }

      if (data.serviceStatus == ServiceStatus.cancelado) {
        return totalRow;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [totalRow, const SizedBox(height: 6), const _Divider382()],
      );
    }
    return totalRow;
  }

  List<Widget> _footerActions(BuildContext context) {
    // --- Variante SOLICITUD ---
    if (variant == ServiceCardVariant.solicitud) {
      return [
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ActionButton(
              label: 'Rechazar',
              color: const Color(0xFFD41E1E),
              onTap: onReject,
            ),
            const SizedBox(width: 12),
            _ActionButton(
              label: 'Confirmar',
              color: const Color(0xFF2E7D32),
              onTap: onConfirm,
            ),
          ],
        ),
      ];
    }

    // --- Variante PROPUESTA ---
    if (variant == ServiceCardVariant.propuesta) {
      return [
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ActionButton(
              label: 'Rechazar',
              color: const Color(0xFFD41E1E),
              onTap: onReject,
            ),
            const SizedBox(width: 12),
            _ActionButton(
              label: 'Confirmar',
              color: const Color(0xFF2E7D32),
              onTap: onConfirm,
            ),
          ],
        ),
      ];
    }

    // --- Variante SERVICIO ---
    if (data.serviceStatus == ServiceStatus.activo) {
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
              onTap: onChat,
            ),
            const SizedBox(width: 11),
            _SquareIconButton(icon: Icons.phone_rounded, onTap: onCall),
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
              onTap: onCancel,
            ),
            const SizedBox(width: 12),
            _ActionButton(
              label: 'Reportar',
              color: const Color(0xFFF86117),
              width: 160,
              onTap: onReport,
            ),
            const SizedBox(width: 12),
          ],
        ),
        const SizedBox(height: 8),
        _FullWidthActionButton(
          label: 'Concluir',
          color: const Color(0xFF2E7D32),
          onTap: onConclude,
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
  final String url;
  final double size;
  const _Avatar({required this.url, this.size = 43});

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
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.person, color: Color(0xFF9E9E9E)),
      ),
    );
  }
}

class _RoundedImage extends StatelessWidget {
  final String url;
  final double height;
  const _RoundedImage({required this.url, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFECEFF1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.image, color: Color(0xFF9E9E9E)),
      ),
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

  Widget _tryNetworkOrAsset(String p) {
    final isNet = p.startsWith('http://') || p.startsWith('https://');
    if (isNet) {
      return Image.network(
        p,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.image_not_supported, color: Color(0xFF9E9E9E)),
      );
    }
    return Image.asset(
      p,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.broken_image, color: Color(0xFF9E9E9E)),
    );
  }
}

class _StarsRow extends StatelessWidget {
  final double rating; // 0..5
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
        color = Colors.black87;
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
