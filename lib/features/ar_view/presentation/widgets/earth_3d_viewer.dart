import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'earth_3d_painter.dart';

/// Widget interativo da Terra 3D com:
/// - Rotação automática
/// - Drag horizontal para girar manualmente
/// - Pinch-to-zoom
/// - Inclinação axial animada
class Earth3DViewer extends StatefulWidget {
  const Earth3DViewer({super.key});

  @override
  State<Earth3DViewer> createState() => _Earth3DViewerState();
}

class _Earth3DViewerState extends State<Earth3DViewer>
    with TickerProviderStateMixin {
  // Rotação automática
  late final AnimationController _autoRotateController;

  // Rotação manual por drag
  double _manualRotation = 0.0;
  double _velocityX = 0.0;
  DateTime? _lastDragTime;

  // Zoom (scale)
  double _scale = 1.0;
  double _baseScale = 1.0;
  static const double _minScale = 0.6;
  static const double _maxScale = 2.2;

  // Inclinação axial (23,5°)
  static const double _tiltAngle = 23.5 * math.pi / 180;

  // Flag para pausar auto-rotação durante interação
  bool _isDragging = false;
  late final AnimationController _decayController;

  @override
  void initState() {
    super.initState();

    _autoRotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _decayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _autoRotateController.addListener(() => setState(() {}));
    _decayController.addListener(_applyDecay);
  }

  void _applyDecay() {
    if (_isDragging) return;
    setState(() {
      _manualRotation += _velocityX * (1 - _decayController.value) * 0.015;
    });
  }

  @override
  void dispose() {
    _autoRotateController.dispose();
    _decayController.dispose();
    super.dispose();
  }

  double get _currentRotation {
    final auto = _autoRotateController.value * 2 * math.pi;
    return auto + _manualRotation;
  }

  // ─── Handlers de gesto ──────────────────────────────────────────────
  void _onScaleStart(ScaleStartDetails details) {
    _baseScale = _scale;
    _isDragging = true;
    _decayController.reset();
    _lastDragTime = DateTime.now();
    _velocityX = 0;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final now = DateTime.now();
    final dt = _lastDragTime != null
        ? now.difference(_lastDragTime!).inMilliseconds / 1000.0
        : 0.0;

    setState(() {
      // Zoom (dois dedos)
      _scale = (_baseScale * details.scale).clamp(_minScale, _maxScale);

      // Rotação pelo giro de pinch (dois dedos)
      if (details.pointerCount >= 2) {
        _manualRotation += details.rotation * 0.5;
      }

      // Pan com um dedo — usa focalPointDelta
      if (details.pointerCount == 1) {
        if (dt > 0) {
          _velocityX = details.focalPointDelta.dx / dt;
        }
        _manualRotation += details.focalPointDelta.dx * 0.008;
      }
    });

    _lastDragTime = now;
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _isDragging = false;
    _decayController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onScaleEnd: _onScaleEnd,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: EarthPainter(
            rotationAngle: _currentRotation,
            tiltAngle: _tiltAngle,
            scale: _scale,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
