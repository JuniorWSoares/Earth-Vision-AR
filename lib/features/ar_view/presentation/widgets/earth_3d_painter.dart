import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Renderiza a Terra em 3D usando CustomPainter com:
/// - Esfera com projeção de Mercator mapeada em círculo
/// - Iluminação direcional simulada (shading por pixel)
/// - Rotação contínua (longitude offset) e inclinação axial
/// - Continentes desenhados proceduralmente com patches de Bezier
class EarthPainter extends CustomPainter {
  final double rotationAngle; // longitude em radianos
  final double tiltAngle; // inclinação axial em radianos
  final double scale;

  EarthPainter({
    required this.rotationAngle,
    required this.tiltAngle,
    this.scale = 1.0,
  });

  // ─── Paleta de cores ────────────────────────────────────────────────
  static const Color _deepOcean = Color(0xFF0D3B6E);
  static const Color _ocean = Color(0xFF1565C0);
  static const Color _shallowSea = Color(0xFF1976D2);
  static const Color _land = Color(0xFF2E7D32);
  static const Color _desert = Color(0xFFD4A017);
  static const Color _snow = Color(0xFFF5F5F5);
  static const Color _cloud1 = Color(0xCCFFFFFF);
  static const Color _cloud2 = Color(0x88FFFFFF);
  static const Color _atmosphere = Color(0x3300C8FF);
  static const Color _atmosphereEdge = Color(0x6600A8FF);
  static const Color _terminator = Color(0x99000022);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * scale;

    // ── 1. Camada de atmosfera (halo externo) ─────────────────────────
    _drawAtmosphere(canvas, center, radius);

    // ── 2. Corpo do planeta (oceano base) ─────────────────────────────
    _drawOceanBase(canvas, center, radius);

    // ── 3. Terreno (continentes) ───────────────────────────────────────
    _drawTerrain(canvas, center, radius);

    // ── 4. Calotas polares ─────────────────────────────────────────────
    _drawPolarCaps(canvas, center, radius);

    // ── 5. Nuvens ─────────────────────────────────────────────────────
    _drawClouds(canvas, center, radius);

    // ── 6. Iluminação direcional (sombra de noite) ────────────────────
    _drawNightSide(canvas, center, radius);

    // ── 7. Especular (brilho do oceano) ───────────────────────────────
    _drawSpecular(canvas, center, radius);

    // ── 8. Borda iluminada ────────────────────────────────────────────
    _drawLimb(canvas, center, radius);
  }

  // ─── Atmosfera ───────────────────────────────────────────────────────
  void _drawAtmosphere(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.transparent, _atmosphereEdge, _atmosphere],
        stops: const [0.82, 0.92, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.12));
    canvas.drawCircle(center, radius * 1.12, paint);
  }

  // ─── Base oceânica ───────────────────────────────────────────────────
  void _drawOceanBase(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [_shallowSea, _ocean, _deepOcean],
        stops: const [0.0, 0.5, 1.0],
        center: const Alignment(-0.3, -0.3),
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  // ─── Terreno: converte lon/lat → posição 2D na esfera projetada ───────
  Offset? _projectToSphere(
      Offset center, double radius, double lon, double lat) {
    // Aplica rotação e inclinação
    final rotatedLon = lon + rotationAngle;
    final x = math.cos(lat) * math.sin(rotatedLon);
    final y = math.sin(lat) * math.cos(tiltAngle) -
        math.cos(lat) * math.cos(rotatedLon) * math.sin(tiltAngle);
    final z = math.sin(lat) * math.sin(tiltAngle) +
        math.cos(lat) * math.cos(rotatedLon) * math.cos(tiltAngle);

    if (z < 0) return null; // face oculta

    return Offset(
      center.dx + x * radius,
      center.dy - y * radius,
    );
  }

  // ─── Polígono de continente a partir de lista de lon/lat ─────────────
  void _drawContinent(Canvas canvas, Offset center, double radius,
      List<List<double>> coords, Color color) {
    final points = <Offset>[];
    for (final c in coords) {
      final p = _projectToSphere(
          center, radius, c[0] * math.pi / 180, c[1] * math.pi / 180);
      if (p != null) points.add(p);
    }
    if (points.length < 3) return;

    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();

    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawTerrain(Canvas canvas, Offset center, double radius) {
    // América do Norte
    _drawContinent(canvas, center, radius, [
      [-167, 68], [-140, 72], [-110, 73], [-85, 71], [-65, 60],
      [-55, 47], [-65, 44], [-70, 42], [-75, 35], [-80, 25],
      [-87, 15], [-92, 15], [-105, 20], [-118, 25], [-122, 38],
      [-124, 48], [-135, 58], [-150, 62], [-167, 68],
    ], _land);

    // América do Sul
    _drawContinent(canvas, center, radius, [
      [-80, 12], [-65, 12], [-50, 5], [-35, -5], [-35, -20],
      [-40, -33], [-50, -40], [-65, -55], [-75, -50],
      [-80, -40], [-82, -25], [-80, 12],
    ], _land);

    // Europa
    _drawContinent(canvas, center, radius, [
      [-10, 35], [0, 43], [20, 48], [30, 60], [28, 70],
      [15, 72], [5, 62], [-3, 55], [-10, 50], [-10, 35],
    ], _land);

    // África
    _drawContinent(canvas, center, radius, [
      [-18, 15], [-15, 5], [-10, 0], [10, -10], [30, -28],
      [35, -34], [28, -34], [18, -28], [12, -5], [10, 5],
      [15, 15], [25, 22], [20, 37], [10, 38], [0, 30],
      [-5, 20], [-18, 15],
    ], _land);

    // Ásia
    _drawContinent(canvas, center, radius, [
      [26, 70], [40, 72], [60, 73], [100, 72], [140, 70],
      [168, 65], [160, 55], [140, 45], [130, 35], [120, 25],
      [100, 10], [90, 8], [78, 10], [65, 22], [55, 22],
      [45, 12], [38, 15], [35, 28], [28, 38], [26, 48],
      [22, 58], [26, 70],
    ], _land);

    // Austrália
    _drawContinent(canvas, center, radius, [
      [114, -22], [122, -18], [130, -12], [136, -12], [140, -18],
      [150, -24], [153, -30], [150, -38], [140, -38], [130, -32],
      [116, -34], [114, -28], [114, -22],
    ], _land);

    // Gronelândia
    _drawContinent(canvas, center, radius, [
      [-45, 83], [-20, 83], [-18, 76], [-23, 70], [-40, 65],
      [-54, 68], [-58, 75], [-45, 83],
    ], _snow.withOpacity(0.9));

    // Deserto do Saara
    _drawContinent(canvas, center, radius, [
      [-5, 15], [10, 18], [25, 22], [30, 22], [28, 28],
      [15, 28], [0, 25], [-5, 20], [-5, 15],
    ], _desert);

    // Deserto da Arábia
    _drawContinent(canvas, center, radius, [
      [37, 15], [48, 12], [58, 22], [57, 28], [45, 30],
      [38, 28], [37, 15],
    ], _desert);

    // Antártida (anel no polo sul)
    final aPath = Path();
    final aCenter = _projectToSphere(
        center, radius, 0, -75 * math.pi / 180);
    if (aCenter != null) {
      aPath.addOval(Rect.fromCenter(
        center: aCenter,
        width: radius * 0.5,
        height: radius * 0.2,
      ));
      canvas.drawPath(aPath, Paint()..color = _snow);
    }
  }

  // ─── Calotas polares ─────────────────────────────────────────────────
  void _drawPolarCaps(Canvas canvas, Offset center, double radius) {
    // Ártico
    final arcticPaint = Paint()
      ..color = _snow.withOpacity(0.85)
      ..style = PaintingStyle.fill;
    final arcticPath = Path();
    bool arcticStarted = false;
    for (int i = 0; i <= 360; i += 10) {
      final p = _projectToSphere(
          center, radius, i * math.pi / 180, 80 * math.pi / 180);
      if (p != null) {
        if (!arcticStarted) {
          arcticPath.moveTo(p.dx, p.dy);
          arcticStarted = true;
        } else {
          arcticPath.lineTo(p.dx, p.dy);
        }
      }
    }
    if (arcticStarted) {
      arcticPath.close();
      canvas.drawPath(arcticPath, arcticPaint);
    }
  }

  // ─── Nuvens ───────────────────────────────────────────────────────────
  void _drawClouds(Canvas canvas, Offset center, double radius) {
    final cloudConfigs = [
      // [lon, lat, size] (graus)
      [-30.0, 50.0, 0.18], [20.0, 55.0, 0.14], [60.0, 45.0, 0.12],
      [-60.0, 5.0, 0.22], [-20.0, -20.0, 0.16], [80.0, 20.0, 0.13],
      [140.0, 35.0, 0.15], [-100.0, 30.0, 0.17], [0.0, -45.0, 0.20],
      [170.0, -30.0, 0.14],
    ];

    for (final cfg in cloudConfigs) {
      final p = _projectToSphere(
          center, radius,
          (cfg[0] + rotationAngle * 55) * math.pi / 180,
          cfg[1] * math.pi / 180);
      if (p == null) continue;
      final sz = radius * cfg[2];
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [_cloud1, _cloud2, Colors.transparent],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(Rect.fromCenter(center: p, width: sz * 2, height: sz));
      canvas.drawOval(
          Rect.fromCenter(center: p, width: sz * 2, height: sz), paint);
    }
  }

  // ─── Lado noturno (sombra) ────────────────────────────────────────────
  void _drawNightSide(Canvas canvas, Offset center, double radius) {
    // A fonte de luz vem da direita (+x world space)
    final lightDir = Offset(0.6, -0.3);

    final nightPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(lightDir.dx, lightDir.dy),
        colors: [
          Colors.transparent,
          Colors.transparent,
          _terminator,
          const Color(0xDD000015),
        ],
        stops: const [0.0, 0.35, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.save();
    canvas.clipPath(Path()..addOval(
        Rect.fromCircle(center: center, radius: radius)));
    canvas.drawCircle(center, radius, nightPaint);
    canvas.restore();
  }

  // ─── Especular oceânico ───────────────────────────────────────────────
  void _drawSpecular(Canvas canvas, Offset center, double radius) {
    final specCenter =
        Offset(center.dx + radius * 0.25, center.dy - radius * 0.25);
    final specPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.35),
          Colors.white.withOpacity(0.0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(
          Rect.fromCircle(center: specCenter, radius: radius * 0.4));
    canvas.save();
    canvas.clipPath(Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius)));
    canvas.drawCircle(specCenter, radius * 0.4, specPaint);
    canvas.restore();
  }

  // ─── Limbo iluminado ──────────────────────────────────────────────────
  void _drawLimb(Canvas canvas, Offset center, double radius) {
    final limbPaint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..shader = SweepGradient(
        colors: [
          const Color(0x0000C8FF),
          const Color(0x6600E5FF),
          const Color(0x2200C8FF),
          const Color(0x0000C8FF),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, limbPaint);
  }

  @override
  bool shouldRepaint(EarthPainter oldDelegate) =>
      oldDelegate.rotationAngle != rotationAngle ||
      oldDelegate.tiltAngle != tiltAngle ||
      oldDelegate.scale != scale;
}
