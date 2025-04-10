import 'package:flutter/foundation.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class ReceiptTextRecognizer {
  static Future<double?> extractReceiptTotal(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final textRecognizer = GoogleMlKit.vision.textRecognizer();

      try {
        final RecognizedText recognizedText = await textRecognizer.processImage(
          inputImage,
        );

        if (kDebugMode) {
          print('Recognized text:');
          print(recognizedText.text);
        }

        return _parseReceiptTotal(recognizedText.text);
      } finally {
        textRecognizer.close();
      }
    } catch (e) {
      debugPrint('Error in text recognition: $e');
      return null;
    }
  }

  static double? _parseReceiptTotal(String text) {
    final lines = text.split('\n');

    final totalPriceMap = <double, int>{};

    final totalKeywords = [
      'total',
      'montant',
      'somme',
      'net',
      'ttc',
      'à payer',
      'payer',
    ];

    final priceRegex = RegExp(r'(\d+[,\.]\d{2})');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].toLowerCase();

      bool containsTotalKeyword = totalKeywords.any(
        (keyword) => line.contains(keyword),
      );

      if (containsTotalKeyword) {
        String lineToCheck = line;
        if (i < lines.length - 1 && !priceRegex.hasMatch(line)) {
          lineToCheck += " " + lines[i + 1];
        }

        final priceMatches = priceRegex.allMatches(lineToCheck);
        for (final match in priceMatches) {
          final priceStr = match.group(1)!.replaceAll(',', '.');
          final price = double.tryParse(priceStr);
          if (price != null && price > 0) {
            totalPriceMap[price] = (totalPriceMap[price] ?? 0) + 2;
          }
        }
      }
    }

    for (final line in lines) {
      final priceMatches = priceRegex.allMatches(line);
      for (final match in priceMatches) {
        final priceStr = match.group(1)!.replaceAll(',', '.');
        final price = double.tryParse(priceStr);
        if (price != null && price > 0) {
          totalPriceMap[price] = (totalPriceMap[price] ?? 0) + 1;
        }
      }
    }

    double? lastPrice;
    for (int i = lines.length - 1; i >= 0; i--) {
      final priceMatches = priceRegex.allMatches(lines[i]);
      if (priceMatches.isNotEmpty) {
        final priceStr = priceMatches.last.group(1)!.replaceAll(',', '.');
        lastPrice = double.tryParse(priceStr);
        if (lastPrice != null && lastPrice > 0) {
          // Give extra weight to the last price
          totalPriceMap[lastPrice] = (totalPriceMap[lastPrice] ?? 0) + 3;
          break;
        }
      }
    }

    if (totalPriceMap.isNotEmpty) {
      final entries = totalPriceMap.entries.toList();
      entries.sort((a, b) {
        final weightComparison = b.value.compareTo(a.value);
        if (weightComparison != 0) return weightComparison;

        return b.key.compareTo(a.key);
      });

      if (kDebugMode) {
        print('Potential total prices with weights:');
        for (var entry in entries) {
          print('${entry.key.toStringAsFixed(2)}€: ${entry.value}');
        }
      }

      return entries.first.key;
    }

    return null;
  }
}
