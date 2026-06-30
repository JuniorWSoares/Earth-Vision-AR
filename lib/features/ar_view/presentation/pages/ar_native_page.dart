import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../../core/theme/app_colors.dart';

/// Tela AR — usa ARKit nativo via PlatformView.
/// A lógica de AR, carregamento do modelo e gestos está em EarthARView.swift.
class ArNativePage extends StatefulWidget {
  const ArNativePage({super.key});

  @override
  State<ArNativePage> createState() => _ArNativePageState();
}

class _ArNativePageState extends State<ArNativePage>
    with WidgetsBindingObserver {
  MethodChannel? _channel;
  bool _planeDetected = false;
  bool _earthPlaced = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Observa ciclo de vida do app para pausar/retomar AR
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Pausa a sessão AR ao sair da tela (economiza bateria)
    _channel?.invokeMethod('pause');
    super.dispose();
  }

  /// Pausa/retoma AR conforme o app vai para background/foreground
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _channel?.invokeMethod('pause');
        break;
      case AppLifecycleState.resumed:
        _channel?.invokeMethod('resume');
        break;
      default:
        break;
    }
  }

  void _onPlatformViewCreated(int viewId) {
    _channel = MethodChannel('earth_ar_view_$viewId');
    _channel!.setMethodCallHandler((call) async {
      if (!mounted) return;
      switch (call.method) {
        case 'onLoading':
          setState(() { _isLoading = true; _earthPlaced = false; });
          break;
        case 'onPlaneDetected':
          setState(() => _planeDetected = true);
          break;
        case 'onEarthPlaced':
          setState(() { _earthPlaced = true; _isLoading = false; });
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── View ARKit nativa ─────────────────────────────────────
          UiKitView(
            viewType: 'earth_ar_view',
            onPlatformViewCreated: _onPlatformViewCreated,
            creationParamsCodec: const StandardMessageCodec(),
          ),

          // ── AppBar ────────────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: _buildAppBar(context),
          ),

          // ── Instrução para o usuário ──────────────────────────────
          if (!_earthPlaced)
            Positioned(
              bottom: 100, left: 24, right: 24,
              child: _buildInstruction(),
            ),

          // ── Status após posicionar ────────────────────────────────
          if (_earthPlaced)
            Positioned(
              bottom: 50, left: 0, right: 0,
              child: _buildStatus(),
            ),

          // ── Loading ───────────────────────────────────────────────
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                    SizedBox(height: 16),
                    Text(
                      'CARREGANDO MODELO DA TERRA...',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.75),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Expanded(
            child: Text(
              'TERRA — REALIDADE AUMENTADA',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.8,
              ),
            ),
          ),
          // Indicador de plano detectado
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 10, height: 10,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _planeDetected ? AppColors.primary : Colors.white24,
              boxShadow: _planeDetected
                  ? [BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.7),
                      blurRadius: 8, spreadRadius: 2,
                    )]
                  : [],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstruction() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _planeDetected ? Icons.touch_app : Icons.screen_rotation,
            color: AppColors.primary,
            size: 30,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _planeDetected
                      ? 'SUPERFÍCIE DETECTADA'
                      : 'PROCURANDO SUPERFÍCIE...',
                  style: TextStyle(
                    color: _planeDetected
                        ? AppColors.primary
                        : Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _planeDetected
                      ? 'Toque na superfície para posicionar a Terra.'
                      : 'Mova o celular devagar sobre uma mesa ou chão.',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatus() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.5),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.public, color: AppColors.primary, size: 18),
            SizedBox(width: 8),
            Text(
              'ARRASTE PARA GIRAR  •  TOQUE PARA MOVER',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
