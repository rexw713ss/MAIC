import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

/// Result of extracting medication fields from a scanned image.
class OcrMedicationScanResult {
  OcrMedicationScanResult({
    required this.rawText,
    this.name,
    this.dosageAmount,
    this.dosageUnit,
  });

  final String rawText;
  final String? name;
  final double? dosageAmount;

  /// Maps to this app's dosageUnit values: 'mg', 'ml', 'tabs', 'drops'.
  final String? dosageUnit;
}

class OcrService {
  /// Runs OCR and applies simple heuristic parsing rules.
  Future<OcrMedicationScanResult> recognizeMedicationFields(XFile image) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final inputImage = InputImage.fromFilePath(image.path);
      final recognizedText = await textRecognizer.processImage(inputImage);
      final raw = recognizedText.text;
      return _parseMedication(raw);
    } finally {
      textRecognizer.close();
    }
  }

  OcrMedicationScanResult _parseMedication(String rawText) {
    final normalized = rawText.replaceAll('\r', '\n').trim();

    final lines = normalized
        .split(RegExp(r'\n+'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final name = _extractName(lines, normalized);
    final (dosageAmount, dosageUnit) = _extractDosage(normalized);

    return OcrMedicationScanResult(
      rawText: normalized,
      name: name,
      dosageAmount: dosageAmount,
      dosageUnit: dosageUnit,
    );
  }

  String? _extractName(List<String> lines, String fullText) {
    final nonEmpty = lines.where((l) => l.isNotEmpty).toList();
    if (nonEmpty.isEmpty) return null;

    final String firstLine = nonEmpty.firstWhere(
      (l) => RegExp(r'[A-Za-z]').hasMatch(l),
      orElse: () => nonEmpty.first,
    );

    String? longest = nonEmpty
        .where((l) => RegExp(r'[A-Za-z]').hasMatch(l))
        .fold<String?>(null, (prev, cur) {
      if (prev == null) return cur;
      return cur.length > prev.length ? cur : prev;
    });

    final String candidate = longest ?? firstLine;

    // Strip common OCR artifacts and excess whitespace.
    final cleaned = candidate.replaceAll(RegExp(r'\s+'), ' ').replaceAll(
          RegExp(r'^[^A-Za-z]+'),
          '',
        ).trim();

    if (cleaned.isEmpty) return null;
    if (cleaned.length < 2) return null;

    return cleaned;
  }

  (double?, String?) _extractDosage(String text) {
    // Rule: Strings containing numbers + 'mg'/'ml'/'capsule' => dosage.
    // Examples: '500mg', '5 mg', '2 capsules', '1.5ml'
    final unitRegex = RegExp(
      r'(\d+(?:[.,]\d+)?)\s*(mg|ml|capsule[s]?)\b',
      caseSensitive: false,
    );

    final matches = unitRegex.allMatches(text).toList();
    if (matches.isNotEmpty) {
      final match = matches.first;
      final amountRaw = match.group(1);
      final unitRaw = match.group(2)?.toLowerCase();

      final amount = amountRaw == null
          ? null
          : double.tryParse(amountRaw.replaceAll(',', '.'));
      if (amount == null) return (null, null);

      final unit = switch (unitRaw) {
        'mg' => 'mg',
        'ml' => 'ml',
        // Map "capsule(s)" to this app's 'tabs' unit.
        _ => 'tabs',
      };

      return (amount, unit);
    }

    // Fallback: numbers + mg/ml even if OCR separated tokens.
    final mgMlRegex = RegExp(
      r'(\d+(?:[.,]\d+)?)\s*(mg|ml)\b',
      caseSensitive: false,
    );
    final mgMlMatch = mgMlRegex.firstMatch(text);
    if (mgMlMatch != null) {
      final amountRaw = mgMlMatch.group(1);
      final unitRaw = mgMlMatch.group(2)?.toLowerCase();
      final amount = amountRaw == null
          ? null
          : double.tryParse(amountRaw.replaceAll(',', '.'));
      if (amount == null || unitRaw == null) return (null, null);
      return (amount, unitRaw);
    }

    return (null, null);
  }
}

