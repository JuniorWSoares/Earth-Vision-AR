import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../widgets/ar_hud_overlay.dart';
import '../widgets/earth_3d_viewer.dart';

/// Tela de Realidade Aumentada — projeta a Terra 3D sobre fundo espacial
/// com HUD de dados em tempo real e controles interativos
class ArViewPage extends StatefulWidget {
  const ArViewPage({super.key});

  @override
  State<ArViewPage> createState() => _ArViewPageState();
}

class _ArViewPageState extends State<ArViewPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeInController;
  bool _showInfo = false;

  @override
  void initState() {
    super.initState();
    // Modo imersivo apenas em plataformas móveis (não disponível no macOS)
    if (!Platform.isMacOS) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }

    _fadeInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    if (!Platform.isMacOS) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    _fadeInController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeInController,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── 1. Fundo espacial ──────────────────────────────────────
            const _SpaceBackground(),

            // ── 2. Globe 3D interativo ─────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Earth3DViewer(),
            ),

            // ── 3. HUD overlay ─────────────────────────────────────────
            const ArHudOverlay(),

            // ── 4. AppBar transparente ────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _ArAppBar(
                onInfo: () => setState(() => _showInfo = !_showInfo),
                onClose: () => Navigator.of(context).pop(),
              ),
            ),

            // ── 5. Painel de informação (toggle) ──────────────────────
            if (_showInfo)
              Positioned(
                bottom: 90,
                left: 24,
                right: 24,
                child: _InfoPanel(),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── AppBar AR ────────────────────────────────────────────────────────
class _ArAppBar extends StatelessWidget {
  final VoidCallback onInfo;
  final VoidCallback onClose;

  const _ArAppBar({required this.onInfo, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60 + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: onClose,
          ),
          const Expanded(
            child: Text(
              'VISUALIZAÇÃO AR — TERRA',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white70),
            onPressed: onInfo,
          ),
        ],
      ),
    );
  }
}

// ─── Fundo espacial com estrelas ──────────────────────────────────────
class _SpaceBackground extends StatelessWidget {
  const _SpaceBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StarfieldPainter(),
      child: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Color(0xFF0A0A1A),
              Color(0xFF040408),
              Colors.black,
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
      ),
    );
  }
}

class _StarfieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    // Stars determinísticos com posição baseada em índice
    const count = 180;
    for (int i = 0; i < count; i++) {
      final x = (i * 137.508 % size.width);
      final y = (i * 97.3141 % size.height);
      final r = (i % 5 == 0) ? 1.2 : (i % 3 == 0) ? 0.8 : 0.5;
      final opacity = 0.3 + (i % 7) / 7.0 * 0.7;
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(_StarfieldPainter _) => false;
}

// ─── Painel de informação ─────────────────────────────────────────────
class _InfoPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PLANETA TERRA',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 12),
          _InfoRow('Tipo', 'Planeta Rochoso'),
          _InfoRow('Diâmetro', '12.742 km'),
          _InfoRow('Massa', '5,972 × 10²⁴ kg'),
          _InfoRow('Distância do Sol', '149,6 × 10⁶ km'),
          _InfoRow('Período orbital', '365,25 dias'),
          _InfoRow('Inclinação axial', '23,5°'),
          _InfoRow('Luas', '1 (Lua)'),
          const SizedBox(height: 8),
          const Text(
            '* Dados científicos da NASA / JPL',
            style: TextStyle(
              color: AppColors.white30,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppColors.white54,
              fontSize: 11,
              letterSpacing: 0.8,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
