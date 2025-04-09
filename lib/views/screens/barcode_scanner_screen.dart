import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:listngo/views/widgets/custom_app_bar.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _hasScanned = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(onBackPressed: () => context.pop()),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              if (_hasScanned) return;

              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? code = barcodes.first.rawValue;
                if (code != null) {
                  setState(() {
                    _hasScanned = true;
                  });

                  _showScannedBarcode(context, code);
                }
              }
            },
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Placez le code-barres dans le cadre pour scanner',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Lato',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showScannedBarcode(BuildContext context, String barcode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Code-barres détecté'),
            content: Text('Code: $barcode'),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _hasScanned = false;
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Scanner à nouveau'),
              ),
              TextButton(
                onPressed: () {
                  // Here you would typically process the barcode
                  // For example, search for the product or add it to your list

                  // Return to previous screen with the barcode
                  context.pop(barcode);
                },
                child: const Text('Confirmer'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color.fromRGBO(247, 147, 76, 1.0),
                ),
              ),
            ],
          ),
    );
  }
}
