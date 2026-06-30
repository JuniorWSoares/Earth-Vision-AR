import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';

/// HUD (Heads-Up Display) sobreposto à visualização AR da Terra
/// Exibe dados simulados em tempo real com animação de pulso
class ArHudOverlay extends StatefulWidget {
  const ArHudOverlay({super.key});

  @override
  State<ArHudOverlay> createState() => _ArHudOverlayState();
}

class _ArHudOverlayState extends State<ArHudOverlay>
    with TickerProviderStateMixin {
  late Timer _dataTimer;
  late final AnimationController _pulseController;
  late final AnimationController _scanController;

  final _rng = Random();

  // Dados simulados de satélite
  double _temperature = 14.2;
  double _co2Level = 421.3;
  int _activeSensors = 14293;
  String _lastSync = '00:00';
  int _orbitAlt = 408;
  double _cloudCover = 67.4;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Atualiza dados a cada 3 segundos
    _dataTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        final now = DateTime.now();
        setState(() {
          _temperature = 14.0 + _rng.nextDouble() * 0.8 - 0.4;
          _co2Level = 421.0 + _rng.nextDouble() * 1.5 - 0.5;
          _activeSensors = 14200 + _rng.nextInt(200);
          _lastSync = '${now.second.toString().padLeft(2, '0')}s';
          _orbitAlt = 405 + _rng.nextInt(8);
          _cloudCover = 65.0 + _rng.nextDouble() * 5;
        });
      }
    });
  }

  @override
  void dispose() {
    _dataTimer.cancel();
    _pulseController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Linha de scan animada
        _ScanLine(controller: _scanController),

        // Canto superior esquerdo — Status de sinal
        Positioned(
          top: 16,
          left: 16,
          child: _SignalStatus(pulseController: _pulseController),
        ),

        // Canto superior direito — Coordenadas de órbita
        Positioned(
          top: 16,
          right: 16,
          child: _OrbitInfo(altitude: _orbitAlt),
        ),

        // Painel esquerdo — Dados atmosféricos
        Positioned(
          left: 16,
          bottom: 130,
          child: _DataPanel(
            title: 'ATMOSFERA',
            items: [
              _DataItem('TEMP MÉD.', '${_temperature.toStringAsFixed(1)}°C'),
              _DataItem('CO₂', '${_co2Level.toStringAsFixed(1)} ppm'),
              _DataItem('NUVENS', '${_cloudCover.toStringAsFixed(1)}%'),
            ],
          ),
        ),

        // Painel direito — Status da rede
        Positioned(
          right: 16,
          bottom: 130,
          child: _DataPanel(
            title: 'REDE SENSOR',
            alignment: CrossAxisAlignment.end,
            items: [
              _DataItem('SENSORES', _activeSensors.toString()),
              _DataItem('ÓRBITA', '${_orbitAlt} km'),
              _DataItem('SINC', _lastSync),
            ],
          ),
        ),

        // Retículo central
        const Center(child: _Reticle()),

        // Instrução inferior
        Positioned(
          bottom: 90,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.white10),
              ),
              child: const Text(
                'ARRASTE PARA GIRAR  •  PINÇA PARA ZOOM',
                style: TextStyle(
                  color: AppColors.white30,
                  fontSize: 10,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Linha de varredura ───────────────────────────────────────────────
class _ScanLine extends StatelessWidget {
  final AnimationController controller;
  const _ScanLine({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final height = MediaQuery.of(context).size.height;
        final y = controller.value * height;
        return Positioned(
          top: y,
          left: 0,
          right: 0,
          child: Container(
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.primary.withOpacity(0.3),
                  AppColors.primary.withOpacity(0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Status de sinal com pulso ────────────────────────────────────────
class _SignalStatus extends StatelessWidget {
  final AnimationController pulseController;
  const _SignalStatus({required this.pulseController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseController,
      builder: (_, __) {
        final opacity = 0.5 + pulseController.value * 0.5;
        return Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(opacity),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(opacity * 0.6),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'FEED AO VIVO',
              style: TextStyle(
                color: AppColors.primary.withOpacity(opacity),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.4,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Info de órbita ───────────────────────────────────────────────────
class _OrbitInfo extends StatelessWidget {
  final int altitude;
  const _OrbitInfo({required this.altitude});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'ALT. ÓRBITA',
          style: TextStyle(
              color: AppColors.white30,
              fontSize: 9,
              letterSpacing: 1.2),
        ),
        Text(
          '$altitude KM',
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'ISS / LEO',
          style: TextStyle(
              color: AppColors.white30,
              fontSize: 9,
              letterSpacing: 1.2),
        ),
      ],
    );
  }
}

// ─── Painel de dados ──────────────────────────────────────────────────
class _DataPanel extends StatelessWidget {
  final String title;
  final List<_DataItem> items;
  final CrossAxisAlignment alignment;

  const _DataPanel({
    required this.title,
    required this.items,
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.white10),
      ),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Column(
                  crossAxisAlignment: alignment,
                  children: [
                    Text(
                      item.label,
                      style: const TextStyle(
                        color: AppColors.white30,
                        fontSize: 9,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      item.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _DataItem {
  final String label;
  final String value;
  const _DataItem(this.label, this.value);
}

// ─── Retículo central ─────────────────────────────────────────────────
class _Reticle extends StatelessWidget {
  const _Reticle();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: CustomPaint(painter: _ReticlePainter()),
    );
  }
}

class _ReticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.7)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;
    const gap = 8.0;
    const len = 12.0;

    // 4 cantos do retículo
    for (final dx in [-1.0, 1.0]) {
      for (final dy in [-1.0, 1.0]) {
        final ox = cx + dx * gap;
        final oy = cy + dy * gap;
        canvas.drawLine(Offset(ox, oy), Offset(ox + dx * len, oy), paint);
        canvas.drawLine(Offset(ox, oy), Offset(ox, oy + dy * len), paint);
      }
    }

    // Ponto central
    canvas.drawCircle(
      Offset(cx, cy),
      2,
      Paint()..color = AppColors.primary.withOpacity(0.8),
    );
  }

  @override
  bool shouldRepaint(_ReticlePainter _) => false;
}
