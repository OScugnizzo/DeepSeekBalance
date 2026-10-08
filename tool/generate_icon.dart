// Generates the DeepSeek Balance launcher icons.
//
// Run with:  dart run tool/generate_icon.dart
// Outputs:   assets/icon/icon.png            (full icon, gradient bg)
//            assets/icon/icon_foreground.png (transparent adaptive foreground)
//            assets/icon/icon_monochrome.png (transparent silhouette)
import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

const int _size = 1024;

// DeepSeek brand gradient endpoints.
const int _brandR = 0x4D, _brandG = 0x6B, _brandB = 0xFE;
const int _deepR = 0x00, _deepG = 0x52, _deepB = 0xD4;

void main() {
  final dir = Directory('assets/icon')..createSync(recursive: true);

  final icon = img.Image(width: _size, height: _size, numChannels: 4);
  _paintGradient(icon);
  _paintWhale(
    icon,
    cx: _size * 0.46,
    cy: _size * 0.58,
    r: _size * 0.30,
    body: img.ColorRgb8(0xFF, 0xFF, 0xFF),
    detail: img.ColorRgb8(0x16, 0x21, 0x3E),
    spout: img.ColorRgb8(0xBF, 0xD0, 0xFF),
  );
  _write('${dir.path}/icon.png', icon);

  final foreground = img.Image(width: _size, height: _size, numChannels: 4);
  _paintWhale(
    foreground,
    cx: _size / 2,
    cy: _size * 0.52,
    r: _size * 0.23,
    body: img.ColorRgb8(0xFF, 0xFF, 0xFF),
    detail: img.ColorRgb8(0x16, 0x21, 0x3E),
    spout: img.ColorRgb8(0xBF, 0xD0, 0xFF),
  );
  _write('${dir.path}/icon_foreground.png', foreground);

  final monochrome = img.Image(width: _size, height: _size, numChannels: 4);
  _paintWhale(
    monochrome,
    cx: _size / 2,
    cy: _size * 0.52,
    r: _size * 0.23,
    body: img.ColorRgb8(0xFF, 0xFF, 0xFF),
    detail: img.ColorRgb8(0x00, 0x00, 0x00),
    spout: img.ColorRgb8(0xFF, 0xFF, 0xFF),
    skipDetail: true,
  );
  _write('${dir.path}/icon_monochrome.png', monochrome);

  stdout.writeln('Generated icons in ${dir.path}');
}

void _write(String path, img.Image image) {
  File(path).writeAsBytesSync(img.encodePng(image));
  stdout.writeln('  -> $path');
}

/// Vertical brand gradient, lightly brightened towards the top-left.
void _paintGradient(img.Image image) {
  final h = image.height;
  final w = image.width;
  for (var y = 0; y < h; y++) {
    final t = y / (h - 1);
    final r = _lerp(_brandR, _deepR, t);
    final g = _lerp(_brandG, _deepG, t);
    final b = _lerp(_brandB, _deepB, t);
    img.fillRect(
      image,
      x1: 0,
      y1: y,
      x2: w - 1,
      y2: y,
      color: img.ColorRgb8(r, g, b),
    );
  }
}

int _lerp(int a, int b, double t) => (a + (b - a) * t).round();

void _paintWhale(
  img.Image image, {
  required double cx,
  required double cy,
  required double r,
  required img.Color body,
  required img.Color detail,
  required img.Color spout,
  bool skipDetail = false,
}) {
  // Tail fluke: sample three quadratic bezier curves into a polygon.
  final vertices = <img.Point>[];
  void bezier(
    double x0,
    double y0,
    double x1,
    double y1,
    double x2,
    double y2,
  ) {
    const steps = 26;
    for (var i = 0; i <= steps; i++) {
      final t = i / steps;
      final mt = 1 - t;
      final x = mt * mt * x0 + 2 * mt * t * x1 + t * t * x2;
      final y = mt * mt * y0 + 2 * mt * t * y1 + t * t * y2;
      vertices.add(img.Point(x, y));
    }
  }

  bezier(
    cx + r * 0.7, cy - r * 0.12,
    cx + r * 1.62, cy - r * 1.15,
    cx + r * 1.95, cy - r * 0.5,
  );
  bezier(
    cx + r * 1.95, cy - r * 0.5,
    cx + r * 1.5, cy,
    cx + r * 1.95, cy + r * 0.5,
  );
  bezier(
    cx + r * 1.95, cy + r * 0.5,
    cx + r * 1.62, cy + r * 1.15,
    cx + r * 0.7, cy + r * 0.12,
  );
  img.fillPolygon(image, vertices: vertices, color: body);

  // Body.
  img.fillCircle(
    image,
    x: cx.round(),
    y: cy.round(),
    radius: r.round(),
    color: body,
    antialias: true,
  );

  // Water spout.
  img.fillCircle(
    image,
    x: (cx - r * 0.05).round(),
    y: (cy - r * 1.5).round(),
    radius: (r * 0.14).round(),
    color: spout,
    antialias: true,
  );
  img.fillCircle(
    image,
    x: (cx - r * 0.42).round(),
    y: (cy - r * 1.72).round(),
    radius: (r * 0.1).round(),
    color: spout,
    antialias: true,
  );
  img.fillCircle(
    image,
    x: (cx + r * 0.32).round(),
    y: (cy - r * 1.72).round(),
    radius: (r * 0.1).round(),
    color: spout,
    antialias: true,
  );

  if (skipDetail) return;

  // Eye + highlight.
  img.fillCircle(
    image,
    x: (cx - r * 0.38).round(),
    y: (cy - r * 0.18).round(),
    radius: (r * 0.11).round(),
    color: detail,
    antialias: true,
  );
  img.fillCircle(
    image,
    x: (cx - r * 0.42).round(),
    y: (cy - r * 0.24).round(),
    radius: (r * 0.035).round(),
    color: img.ColorRgb8(0xFF, 0xFF, 0xFF),
    antialias: true,
  );

  // Smile.
  const startAngle = math.pi * 0.18;
  const sweep = math.pi * 0.64;
  final smileCx = cx - r * 0.18;
  final smileCy = cy + r * 0.02;
  final smileR = r * 0.42;
  const steps = 30;
  for (var i = 0; i <= steps; i++) {
    final a = startAngle + sweep * (i / steps);
    img.fillCircle(
      image,
      x: (smileCx + smileR * math.cos(a)).round(),
      y: (smileCy + smileR * math.sin(a)).round(),
      radius: (r * 0.045).round(),
      color: detail,
      antialias: true,
    );
  }
}
