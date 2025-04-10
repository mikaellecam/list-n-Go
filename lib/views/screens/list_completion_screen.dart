import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:listngo/models/product_list.dart';
import 'package:listngo/services/product_list_service.dart';
import 'package:listngo/services/receipt_service.dart';
import 'package:listngo/services/service_locator.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../services/receipt_text_recognizer.dart';

class ListCompletionScreen extends StatefulWidget {
  const ListCompletionScreen({super.key});

  @override
  _ListCompletionScreenState createState() => _ListCompletionScreenState();
}

class _ListCompletionScreenState extends State<ListCompletionScreen> {
  final receiptService = getIt<ReceiptService>();
  final productListService = getIt<ProductListService>();
  final priceController = TextEditingController();
  bool isCreatingReceipt = false;
  bool isScanning = false;
  String? receiptImagePath;
  late final ProductList productList;

  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isCameraMode = false;

  @override
  void initState() {
    super.initState();
    productList = productListService.currentList.value!;
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await _requestCameraPermission();

    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    // Use the back camera
    final rearCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    // Initialize controller
    _cameraController = CameraController(
      rearCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    priceController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status != PermissionStatus.granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'La permission caméra est nécessaire pour scanner le ticket',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleCameraMode() async {
    if (!_isCameraInitialized) {
      await _initializeCamera();
    }

    setState(() {
      _isCameraMode = !_isCameraMode;
    });
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_isCameraInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La caméra n\'est pas disponible'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() {
        isScanning = true;
      });

      final XFile photo = await _cameraController!.takePicture();

      // Copy to a more permanent location
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imagePath = path.join(directory.path, 'receipt_$timestamp.jpg');

      await File(photo.path).copy(imagePath);

      setState(() {
        receiptImagePath = imagePath;
        _isCameraMode = false;
      });

      // Process the image to extract the total
      try {
        final price = await ReceiptTextRecognizer.extractReceiptTotal(
          imagePath,
        );

        if (price != null && mounted) {
          setState(() {
            priceController.text = price.toStringAsFixed(2);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Prix détecté: ${price.toStringAsFixed(2)} €'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Aucun prix n\'a été détecté. Veuillez entrer le montant manuellement.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de l\'analyse du ticket: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la prise de photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isScanning = false;
        });
      }
    }
  }

  void _viewReceiptImage() {
    if (receiptImagePath == null) return;

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  title: const Text('Aperçu du ticket'),
                  backgroundColor: const Color.fromRGBO(247, 147, 76, 1.0),
                  foregroundColor: Colors.white,
                  leading: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Flexible(
                  child: InteractiveViewer(
                    child: Image.file(
                      File(receiptImagePath!),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _toggleCameraMode();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reprendre'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[600],
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Confirmer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(
                            247,
                            147,
                            76,
                            1.0,
                          ),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _createReceiptAndNavigate() async {
    if (isCreatingReceipt) return;

    setState(() {
      isCreatingReceipt = true;
    });

    double? totalPrice;
    if (priceController.text.isNotEmpty) {
      try {
        totalPrice = double.parse(priceController.text.replaceAll(',', '.'));
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez entrer un prix valide'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          isCreatingReceipt = false;
        });
        return;
      }
    }

    try {
      // Create a local copy of the product list
      final currentProductList = productList;

      // Create the receipt
      final receiptId = await receiptService.createReceiptFromList(
        currentProductList,
        totalPrice: totalPrice,
        imagePath: receiptImagePath,
      );

      if (receiptId > 0) {
        if (mounted) {
          context.pushReplacement('/home');
          productListService.currentList.value = null;
        }
      } else if (receiptService.error.value != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(receiptService.error.value!),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isCreatingReceipt = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCameraMode) {
      return _buildCameraView();
    }

    return _buildNormalView();
  }

  Widget _buildCameraView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner le ticket'),
        backgroundColor: const Color.fromRGBO(247, 147, 76, 1.0),
        foregroundColor: Colors.white,
      ),
      body:
          _isCameraInitialized
              ? Stack(
                children: [
                  // Camera preview
                  CameraPreview(_cameraController!),

                  // Capture button at the bottom
                  Positioned(
                    bottom: 30,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: FloatingActionButton(
                        onPressed: isScanning ? null : _takePicture,
                        backgroundColor: const Color.fromRGBO(
                          247,
                          147,
                          76,
                          1.0,
                        ),
                        child:
                            isScanning
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Icon(Icons.camera_alt, size: 36),
                      ),
                    ),
                  ),

                  // Loading indicator
                  if (isScanning)
                    Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 16),
                            Text(
                              'Analyse du ticket en cours...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              )
              : const Center(child: CircularProgressIndicator()),
      floatingActionButton:
          _isCameraInitialized && !isScanning
              ? FloatingActionButton.small(
                onPressed: _toggleCameraMode,
                backgroundColor: Colors.white,
                child: const Icon(Icons.close, color: Colors.black),
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
    );
  }

  Widget _buildNormalView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finaliser la liste'),
        backgroundColor: const Color.fromRGBO(247, 147, 76, 1.0),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Liste: ${productList.name}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${productList.products.value.length} produits',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Receipt image guidance
              const Text(
                'Prenez une photo de votre ticket de caisse',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Receipt image preview or placeholder
              GestureDetector(
                onTap:
                    receiptImagePath != null
                        ? _viewReceiptImage
                        : _toggleCameraMode,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          receiptImagePath != null
                              ? const Color.fromRGBO(247, 147, 76, 1.0)
                              : Colors.grey[300]!,
                      width: receiptImagePath != null ? 2 : 1,
                    ),
                  ),
                  child:
                      receiptImagePath != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(
                                  File(receiptImagePath!),
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.white,
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.black54,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        receiptImagePath = null;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                          : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Prendre une photo du ticket',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Le montant total sera automatiquement détecté',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                ),
              ),
              const SizedBox(height: 16),

              // Camera button
              if (receiptImagePath == null)
                ElevatedButton.icon(
                  onPressed: isScanning ? null : _toggleCameraMode,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Prendre une photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(247, 147, 76, 1.0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),

              const SizedBox(height: 24),
              const Text(
                'Montant total',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText:
                      isScanning
                          ? 'Analyse du ticket en cours...'
                          : 'Entrez le montant total',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.euro),
                  suffixText: '€',
                ),
                enabled: !isScanning,
              ),
              if (isScanning)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.grey[300],
                    color: const Color.fromRGBO(247, 147, 76, 1.0),
                  ),
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed:
                    (isCreatingReceipt || isScanning)
                        ? null
                        : _createReceiptAndNavigate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(247, 147, 76, 1.0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    isCreatingReceipt
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'Créer un ticket de caisse',
                          style: TextStyle(fontSize: 16),
                        ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed:
                    (isCreatingReceipt || isScanning)
                        ? null
                        : () => context.pop(),
                child: const Text('Annuler'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
