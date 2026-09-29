import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:clinician_app/core/constant/constant_import.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A rendered pin plus the anchor that puts its tip on the coordinate.
class MapMarkerBitmap {
  const MapMarkerBitmap({required this.descriptor, required this.anchor});

  final BitmapDescriptor descriptor;
  final Offset anchor;
}

/// Renders the Figma map pin — the green teardrop from
/// `assets/svg/map_marker_icon.svg` with a white number inside and a blue
/// name chip hanging underneath — into a [BitmapDescriptor].
///
/// Drawn with Canvas rather than loaded from the SVG because Google Maps
/// needs raster bytes, and the number / name differ per marker.
class MapMarkerFactory {
  const MapMarkerFactory._();

  // Geometry of the SVG (24 × 30 view box): a 12 px circle with a tail that
  // leaves the circle at y ≈ 23.37 and meets at the tip (12, 30).
  static const double _pinWidth = 24;
  static const double _pinHeight = 30;
  static const double _pinRadius = 12;
  static const double _tailStartY = 23.373;
  static const double _tailHalfWidth = 3.826;

  static const double _scale = 1.4; // pin renders ~34 × 42 logical px
  static const double _numberFontSize = 13;
  static const double _labelFontSize = 10;
  static const double _labelPaddingH = 8;
  static const double _labelPaddingV = 2;
  static const double _labelRadius = 8;
  static const double _labelGap = -3; // chip overlaps the tail like Figma
  static const double _maxLabelWidth = 200;

  /// [number] is left blank for the clinician's own position.
  static Future<MapMarkerBitmap> build({
    required String label,
    String? number,
    required double devicePixelRatio,
  }) async {
    final double pinW = _pinWidth * _scale;
    final double pinH = _pinHeight * _scale;

    final ui.ParagraphBuilder labelBuilder =
        ui.ParagraphBuilder(
            ui.ParagraphStyle(
              textAlign: TextAlign.center,
              fontFamily: AppTextStyle.fontFamily,
              fontSize: _labelFontSize * _scale,
              fontWeight: FontWeight.w600,
            ),
          )
          ..pushStyle(ui.TextStyle(color: Colors.white))
          ..addText(label);
    // Measure at a finite width first (an infinite constraint reports a
    // meaningless longestLine), then re-layout to that exact width so the
    // text is centred inside the chip.
    final ui.Paragraph labelParagraph =
        labelBuilder.build()
          ..layout(ui.ParagraphConstraints(width: _maxLabelWidth * _scale));
    final double labelW = labelParagraph.longestLine.ceilToDouble();
    labelParagraph.layout(ui.ParagraphConstraints(width: labelW));
    final double chipW = labelW + _labelPaddingH * 2 * _scale;
    final double chipH = labelParagraph.height + _labelPaddingV * 2 * _scale;

    final double width = chipW > pinW ? chipW : pinW;
    final double height = pinH + _labelGap * _scale + chipH;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder)..scale(devicePixelRatio);

    final double pinLeft = (width - pinW) / 2;
    _drawPin(canvas, Offset(pinLeft, 0));

    if (number != null && number.isNotEmpty) {
      final ui.ParagraphBuilder numberBuilder =
          ui.ParagraphBuilder(
              ui.ParagraphStyle(
                textAlign: TextAlign.center,
                fontFamily: AppTextStyle.fontFamily,
                fontSize: _numberFontSize * _scale,
                fontWeight: FontWeight.w700,
              ),
            )
            ..pushStyle(ui.TextStyle(color: Colors.white))
            ..addText(number);
      final ui.Paragraph numberParagraph =
          numberBuilder.build()..layout(ui.ParagraphConstraints(width: pinW));
      canvas.drawParagraph(
        numberParagraph,
        Offset(pinLeft, _pinRadius * _scale - numberParagraph.height / 2),
      );
    }

    final double chipTop = pinH + _labelGap * _scale;
    final RRect chip = RRect.fromRectAndRadius(
      Rect.fromLTWH((width - chipW) / 2, chipTop, chipW, chipH),
      Radius.circular(_labelRadius * _scale),
    );
    canvas.drawRRect(chip, Paint()..color = AppColors.mapMarkerLabel);
    canvas.drawParagraph(
      labelParagraph,
      Offset((width - labelW) / 2, chipTop + _labelPaddingV * _scale),
    );

    final ui.Image image = await recorder.endRecording().toImage(
      (width * devicePixelRatio).ceil(),
      (height * devicePixelRatio).ceil(),
    );
    final ByteData? bytes = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return MapMarkerBitmap(
      descriptor: BitmapDescriptor.bytes(
        bytes!.buffer.asUint8List(),
        width: width,
        height: height,
      ),
      anchor: Offset(0.5, pinH / height),
    );
  }

  static void _drawPin(Canvas canvas, Offset origin) {
    final double s = _scale;
    final Path path =
        Path()
          ..addOval(
            Rect.fromCircle(
              center: origin + Offset(_pinRadius * s, _pinRadius * s),
              radius: _pinRadius * s,
            ),
          )
          ..moveTo(
            origin.dx + (_pinRadius - _tailHalfWidth) * s,
            origin.dy + _tailStartY * s,
          )
          ..lineTo(origin.dx + _pinRadius * s, origin.dy + _pinHeight * s)
          ..lineTo(
            origin.dx + (_pinRadius + _tailHalfWidth) * s,
            origin.dy + _tailStartY * s,
          )
          ..close();
    canvas.drawPath(path, Paint()..color = AppColors.mapMarkerGreen);
  }
}
