import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Singleton for caching PDF assets (fonts/images)
class CertificatePdfAssets {
  static final CertificatePdfAssets _instance =
      CertificatePdfAssets._internal();
  factory CertificatePdfAssets() => _instance;
  CertificatePdfAssets._internal();

  pw.Font? regularFont;
  pw.Font? boldFont;
  pw.Font? scriptFont;
  pw.MemoryImage? borderImage;
  pw.MemoryImage? coatOfArms;
  pw.MemoryImage? signatureImage;
  bool _loaded = false;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    regularFont = pw.Font.ttf(
      await rootBundle.load("assets/fonts/Roboto-Regular.ttf"),
    );
    boldFont = pw.Font.ttf(
      await rootBundle.load("assets/fonts/Roboto-Bold.ttf"),
    );
    scriptFont = pw.Font.ttf(
      await rootBundle.load("assets/fonts/PinyonScript-Regular.ttf"),
    );
    borderImage = pw.MemoryImage(
      (await rootBundle.load('images/logo22.png')).buffer.asUint8List(),
    );
    coatOfArms = pw.MemoryImage(
      (await rootBundle.load('images/logo.png')).buffer.asUint8List(),
    );
    signatureImage = pw.MemoryImage(
      (await rootBundle.load('images/signature.png')).buffer.asUint8List(),
    );
    _loaded = true;
  }
}
