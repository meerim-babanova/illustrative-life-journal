import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/illustration_scene.dart';

/// Paints the illustration described by an [IllustrationScene].
///
/// This is the renderer half of Phase 2: flat, storybook shapes in the
/// app's own muted palette — light, horizon, place and weather — drawn from
/// the structured scene the interpreter produced. It runs offline and is
/// fully deterministic for a given seed, which is what makes "regenerate"
/// meaningful and "restore an earlier take" possible.
class SceneArt extends StatelessWidget {
  const SceneArt({super.key, required this.scene, this.borderRadius = 24});

  final IllustrationScene scene;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CustomPaint(
        painter: _SceneArtPainter(scene),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _SceneArtPainter extends CustomPainter {
  _SceneArtPainter(this.scene);

  final IllustrationScene scene;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p = scene.palette;
    final rng = Random(scene.seed);
    final full = Rect.fromLTWH(0, 0, w, h);

    canvas.drawRect(
      full,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [p.skyTop, p.skyBottom],
        ).createShader(full),
    );

    final horizon = scene.place == ScenePlace.indoor ? h * 0.74 : h * 0.7;

    // Sun / moon and its haze.
    final lightX = w * (0.18 + rng.nextDouble() * 0.62);
    final lightY = h * (0.2 + rng.nextDouble() * 0.16);
    final lightR = w * 0.055;
    canvas.drawCircle(
      Offset(lightX, lightY),
      lightR * 3.4,
      Paint()
        ..shader = RadialGradient(
          colors: [p.glow.withOpacity(0.55), p.glow.withOpacity(0)],
        ).createShader(
          Rect.fromCircle(center: Offset(lightX, lightY), radius: lightR * 3.4),
        ),
    );
    canvas.drawCircle(
      Offset(lightX, lightY),
      lightR,
      Paint()..color = p.glow.withOpacity(scene.time == SceneTime.night ? 0.9 : 0.75),
    );

    if (scene.place == ScenePlace.indoor) {
      _paintIndoor(canvas, w, h, horizon, p, rng);
    } else {
      if (scene.place == ScenePlace.city) {
        _paintSkyline(canvas, w, horizon, p, rng);
      } else {
        _paintHills(canvas, w, h, horizon, p, rng);
      }
      canvas.drawRect(
        Rect.fromLTWH(0, horizon, w, h - horizon),
        Paint()..color = p.land,
      );
      if (scene.place == ScenePlace.water) {
        _paintWater(canvas, w, h, horizon, p, lightX);
      }
      if (scene.place == ScenePlace.nature) {
        _paintTrees(canvas, w, horizon, p, rng);
      }
    }

    if (scene.weather == SceneWeather.cloudy || scene.weather == SceneWeather.rain) {
      _paintClouds(canvas, w, h, p, rng);
    }
    if (scene.weather == SceneWeather.rain) {
      _paintRain(canvas, w, h, horizon, rng);
    }
    if (scene.weather == SceneWeather.snow) {
      _paintSnow(canvas, w, h, rng);
    }

    // Companions: soft silhouettes standing with the character.
    for (var i = 0; i < scene.companions; i++) {
      final side = i.isEven ? -1 : 1;
      final cx = w * 0.5 + side * w * (0.16 + i * 0.05);
      final figureH = h * (0.2 + rng.nextDouble() * 0.04);
      final bodyTop = horizon - figureH;
      final body = RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - w * 0.028, bodyTop + figureH * 0.32, w * 0.056, figureH * 0.68),
        Radius.circular(w * 0.02),
      );
      final paint = Paint()..color = p.landDeep.withOpacity(0.55);
      canvas.drawRRect(body, paint);
      canvas.drawCircle(Offset(cx, bodyTop + figureH * 0.18), w * 0.022, paint);
    }

    // Warm paper vignette so the art reads as printed, not screen-lit.
    canvas.drawRect(
      full,
      Paint()
        ..shader = RadialGradient(
          radius: 0.95,
          colors: [
            const Color(0x00000000),
            const Color(0x142E2A26),
          ],
        ).createShader(full),
    );
  }

  void _paintIndoor(Canvas canvas, double w, double h, double floor,
      ScenePalette p, Random rng) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, floor),
      Paint()..color = p.skyTop.withOpacity(0.9),
    );
    final windowRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.14, h * 0.16, w * 0.3, h * 0.34),
      Radius.circular(w * 0.02),
    );
    canvas.drawRRect(windowRect, Paint()..color = p.glow.withOpacity(0.8));
    canvas.drawRRect(
      windowRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.008
        ..color = p.landDeep.withOpacity(0.35),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, floor, w, h - floor),
      Paint()..color = p.landDeep.withOpacity(0.45),
    );
    // A table edge, because indoor memories usually happen at one.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.56, floor - h * 0.1, w * 0.36, h * 0.05),
        Radius.circular(w * 0.012),
      ),
      Paint()..color = p.land.withOpacity(0.85),
    );
  }

  void _paintHills(Canvas canvas, double w, double h, double horizon,
      ScenePalette p, Random rng) {
    for (var i = 0; i < 3; i++) {
      final lift = h * (0.06 + rng.nextDouble() * 0.12) * (3 - i) / 2;
      final path = Path()
        ..moveTo(-w * 0.1, horizon)
        ..quadraticBezierTo(
          w * (0.2 + i * 0.3),
          horizon - lift,
          w * 1.1,
          horizon,
        )
        ..lineTo(w * 1.1, horizon + 2)
        ..lineTo(-w * 0.1, horizon + 2)
        ..close();
      canvas.drawPath(
        path,
        Paint()..color = Color.lerp(p.land, p.landDeep, 0.25 + i * 0.22)!
            .withOpacity(0.75),
      );
    }
  }

  void _paintSkyline(Canvas canvas, double w, double horizon, ScenePalette p,
      Random rng) {
    var x = -w * 0.05;
    while (x < w * 1.05) {
      final bw = w * (0.06 + rng.nextDouble() * 0.09);
      final bh = horizon * (0.16 + rng.nextDouble() * 0.34);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, horizon - bh, bw, bh),
          Radius.circular(w * 0.006),
        ),
        Paint()..color = Color.lerp(p.land, p.landDeep, 0.55)!.withOpacity(0.85),
      );
      x += bw + w * 0.012;
    }
  }

  void _paintTrees(Canvas canvas, double w, double horizon, ScenePalette p,
      Random rng) {
    for (var i = 0; i < 4; i++) {
      final cx = w * (0.06 + rng.nextDouble() * 0.88);
      final r = w * (0.035 + rng.nextDouble() * 0.03);
      canvas.drawCircle(
        Offset(cx, horizon - r * 1.3),
        r,
        Paint()..color = p.landDeep.withOpacity(0.5),
      );
      canvas.drawRect(
        Rect.fromLTWH(cx - w * 0.006, horizon - r * 1.3, w * 0.012, r * 1.4),
        Paint()..color = p.landDeep.withOpacity(0.6),
      );
    }
  }

  void _paintWater(Canvas canvas, double w, double h, double horizon,
      ScenePalette p, double lightX) {
    canvas.drawRect(
      Rect.fromLTWH(0, horizon, w, h - horizon),
      Paint()..color = Color.lerp(p.skyBottom, p.landDeep, 0.35)!,
    );
    for (var i = 0; i < 6; i++) {
      final y = horizon + (h - horizon) * (0.12 + i * 0.14);
      final width = w * (0.1 + (i.isEven ? 0.16 : 0.08));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(lightX - width / 2, y, width, h * 0.012),
          Radius.circular(h * 0.01),
        ),
        Paint()..color = p.glow.withOpacity(0.45 - i * 0.05),
      );
    }
  }

  void _paintClouds(Canvas canvas, double w, double h, ScenePalette p,
      Random rng) {
    for (var i = 0; i < 3; i++) {
      final cx = w * rng.nextDouble();
      final cy = h * (0.12 + rng.nextDouble() * 0.2);
      final r = w * (0.05 + rng.nextDouble() * 0.04);
      final paint = Paint()..color = Colors.white.withOpacity(0.35);
      canvas.drawCircle(Offset(cx, cy), r, paint);
      canvas.drawCircle(Offset(cx + r * 0.8, cy + r * 0.15), r * 0.75, paint);
      canvas.drawCircle(Offset(cx - r * 0.8, cy + r * 0.2), r * 0.6, paint);
    }
  }

  void _paintRain(Canvas canvas, double w, double h, double horizon,
      Random rng) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = w * 0.0035
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 46; i++) {
      final x = w * rng.nextDouble();
      final y = h * rng.nextDouble() * 0.95;
      canvas.drawLine(Offset(x, y), Offset(x - w * 0.012, y + h * 0.05), paint);
    }
  }

  void _paintSnow(Canvas canvas, double w, double h, Random rng) {
    final paint = Paint()..color = Colors.white.withOpacity(0.7);
    for (var i = 0; i < 40; i++) {
      canvas.drawCircle(
        Offset(w * rng.nextDouble(), h * rng.nextDouble()),
        w * (0.003 + rng.nextDouble() * 0.004),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SceneArtPainter oldDelegate) =>
      oldDelegate.scene != scene;
}
