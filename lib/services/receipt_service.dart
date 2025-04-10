import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:listngo/models/product_list.dart';
import 'package:listngo/models/receipt.dart';
import 'package:listngo/models/receipt_product_relation.dart';
import 'package:listngo/services/database_service.dart';
import 'package:listngo/services/service_locator.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ReceiptService {
  final db = getIt<DatabaseService>();

  final ValueNotifier<List<Receipt>> receipts = ValueNotifier([]);
  final ValueNotifier<Receipt?> currentReceipt = ValueNotifier(null);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> error = ValueNotifier(null);

  Future<void> loadReceipts() async {
    isLoading.value = true;
    error.value = null;

    try {
      receipts.value = await db.getAllReceipts();
    } catch (e) {
      error.value = 'Failed to load receipts: $e';
      debugPrint('Failed to load receipts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadReceiptsWithProducts() async {
    isLoading.value = true;
    error.value = null;

    try {
      final basicReceipts = await db.getAllReceipts();
      debugPrint(
        'Loaded ${basicReceipts.length} basic receipts, now loading products...',
      );

      List<Receipt> completeReceipts = [];

      for (final receipt in basicReceipts) {
        if (receipt.id != null) {
          final completeReceipt = await db.getReceiptWithProducts(receipt.id!);
          if (completeReceipt != null) {
            completeReceipts.add(completeReceipt);
            debugPrint(
              'Loaded receipt: ${completeReceipt.name} with ${completeReceipt.products.value.length} products',
            );
          } else {
            completeReceipts.add(receipt);
            debugPrint('Could not load products for receipt: ${receipt.name}');
          }
        } else {
          completeReceipts.add(receipt);
        }
      }

      receipts.value = completeReceipts;
      debugPrint('All receipts loaded with products');
    } catch (e) {
      error.value = 'Failed to load receipts with products: $e';
      debugPrint('Failed to load receipts with products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<int> createReceiptFromList(
    ProductList productList, {
    double? totalPrice,
    String? imagePath,
  }) async {
    print("Creating receipt from list: ${productList.name}");
    isLoading.value = true;
    error.value = null;

    try {
      final now = DateTime.now();
      final receipt = Receipt(
        name: productList.name,
        price: totalPrice,
        createdAt: now,
        imagePath: imagePath,
      );

      final receiptId = await db.insertReceipt(receipt);

      if (receiptId <= 0) {
        error.value = 'Failed to create receipt';
        return -1;
      }

      print("Receipt created with ID: $receiptId");

      final productsList = productList.products.value;
      for (int i = 0; i < productsList.length; i++) {
        final product = productsList[i];
        final relation = productList.productRelations[product.id!];

        if (product.id != null && relation != null) {
          final receiptProductRelation = ReceiptProductRelation(
            receiptId: receiptId,
            productId: product.id!,
            quantity: relation.quantity,
            position: i,
            createdAt: now,
          );

          await db.addProductToReceipt(receiptProductRelation);
        }
      }

      final completeReceipt = await db.getReceiptWithProducts(receiptId);
      if (completeReceipt != null) {
        final updatedReceipts =
            List<Receipt>.from(receipts.value)
              ..add(completeReceipt)
              ..sort(
                (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
                  a.createdAt ?? DateTime.now(),
                ),
              );

        receipts.value = updatedReceipts;
        currentReceipt.value = completeReceipt;
      }
      print("Receipt created with ID: $receiptId");

      return receiptId;
    } catch (e) {
      error.value = 'Error creating receipt: $e';
      debugPrint('Error creating receipt: $e');
      return -1;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveReceiptImage(int receiptId, XFile imageFile) async {
    isLoading.value = true;
    error.value = null;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final receiptDir = Directory('${appDir.path}/receipts');

      if (!await receiptDir.exists()) {
        await receiptDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(imageFile.path);
      final filename = 'receipt_${receiptId}_$timestamp$extension';
      final destFile = File('${receiptDir.path}/$filename');

      final sourceFile = File(imageFile.path);
      await sourceFile.copy(destFile.path);

      final receipt = await db.getReceiptById(receiptId);
      if (receipt != null) {
        receipt.imagePath = destFile.path;
        await db.updateReceipt(receipt);

        final index = receipts.value.indexWhere((r) => r.id == receiptId);
        if (index >= 0) {
          final updatedReceipts = List<Receipt>.from(receipts.value);
          updatedReceipts[index] = receipt;
          receipts.value = updatedReceipts;

          if (currentReceipt.value?.id == receiptId) {
            currentReceipt.value = receipt;
          }
        }

        return true;
      }

      error.value = 'Receipt not found';
      return false;
    } catch (e) {
      error.value = 'Error saving receipt image: $e';
      debugPrint('Error saving receipt image: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> takeReceiptPicture(int receiptId) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
      );

      if (image != null) {
        return await saveReceiptImage(receiptId, image);
      }

      return false;
    } catch (e) {
      error.value = 'Error taking picture: $e';
      debugPrint('Error taking picture: $e');
      return false;
    }
  }

  Receipt? findReceiptById(int id) {
    final index = receipts.value.indexWhere((receipt) => receipt.id == id);
    if (index >= 0) {
      return receipts.value[index];
    }
    return null;
  }

  Future<bool> removeReceipt(Receipt receipt) async {
    isLoading.value = true;
    error.value = null;

    try {
      final id = receipt.id;
      if (id == null) {
        error.value = 'Receipt ID is null';
        return false;
      }

      if (receipt.imagePath != null) {
        try {
          final imageFile = File(receipt.imagePath!);
          if (await imageFile.exists()) {
            await imageFile.delete();
          }
        } catch (e) {
          debugPrint('Error deleting receipt image: $e');
        }
      }

      await db.deleteReceipt(id);

      receipts.value = receipts.value.where((r) => r.id != id).toList();
      return true;
    } catch (e) {
      error.value = 'Error deleting receipt: $e';
      debugPrint('Error deleting receipt: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateReceipt(Receipt receipt) async {
    isLoading.value = true;
    error.value = null;

    try {
      final id = receipt.id;
      if (id == null) {
        error.value = 'Receipt ID is null';
        return false;
      }

      await db.updateReceipt(receipt);

      final index = receipts.value.indexWhere((r) => r.id == id);
      if (index >= 0) {
        final updatedReceipts = List<Receipt>.from(receipts.value);
        updatedReceipts[index] = receipt;
        receipts.value = updatedReceipts;

        if (currentReceipt.value?.id == id) {
          currentReceipt.value = receipt;
        }
      }

      return true;
    } catch (e) {
      error.value = 'Error updating receipt: $e';
      debugPrint('Error updating receipt: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void dispose() {
    receipts.dispose();
    currentReceipt.dispose();
    isLoading.dispose();
    error.dispose();
  }

  Future<bool> convertListToReceipt(
    ProductList productList, {
    double? totalPrice,
  }) async {
    isLoading.value = true;
    error.value = null;

    try {
      if (productList.id == null) {
        error.value = 'List ID is null';
        return false;
      }

      final receiptId = await getIt<ReceiptService>().createReceiptFromList(
        productList,
        totalPrice: totalPrice,
      );

      if (receiptId > 0) {
        return true;
      } else {
        error.value = 'Failed to create receipt';
        return false;
      }
    } catch (e) {
      error.value = 'Error converting list to receipt: $e';
      debugPrint('Error converting list to receipt: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
