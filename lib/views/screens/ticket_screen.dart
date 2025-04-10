import 'dart:io';

import 'package:flutter/material.dart';
import 'package:listngo/models/product.dart';
import 'package:listngo/models/receipt.dart';
import 'package:listngo/services/receipt_service.dart';
import 'package:listngo/services/service_locator.dart';
import 'package:listngo/views/widgets/custom_app_bar.dart';
import 'package:listngo/views/widgets/product_card_ticket.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  _TicketScreenState createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  final ReceiptService _receiptService = getIt<ReceiptService>();
  Receipt? _currentReceipt;

  @override
  void initState() {
    super.initState();
    _currentReceipt = _receiptService.currentReceipt.value;
    print(_currentReceipt.toString());
  }

  // Vérifier si le fichier image existe
  bool _imageExists(String? path) {
    if (path == null) return false;
    try {
      return File(path).existsSync();
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      appBar: CustomAppBar(),
      body: ValueListenableBuilder<Receipt?>(
        valueListenable: _receiptService.currentReceipt,
        builder: (context, receipt, child) {
          if (receipt == null) {
            return const Center(
              child: Text(
                'Aucun ticket sélectionné',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final hasImage = _imageExists(receipt.imagePath);

          return Column(
            children: [
              // Titre centré horizontalement (nom du ticket)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: Text(
                  receipt.name ?? 'Ticket sans nom',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lato',
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Sous-titre centré horizontalement (date du ticket)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  receipt.createdAt != null
                      ? 'Créé le ${_formatDate(receipt.createdAt!)}'
                      : 'Date inconnue',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Lato',
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Affichage du bouton pour voir la photo du ticket si disponible
              if (hasImage)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ElevatedButton.icon(
                    onPressed:
                        () => _showReceiptImageBottomSheet(
                          context,
                          receipt.imagePath!,
                        ),
                    icon: const Icon(Icons.receipt_long, color: Colors.white),
                    label: const Text(
                      'Voir le ticket',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(247, 147, 76, 1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              // Liste des produits du ticket
              Expanded(
                child: ValueListenableBuilder<List<Product>>(
                  valueListenable: receipt.products,
                  builder: (context, products, child) {
                    if (products.isEmpty) {
                      return const Center(
                        child: Text(
                          'Aucun produit dans ce ticket',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        int quantity = 1;

                        if (product.id != null) {
                          final relation =
                              receipt.productRelations[product.id!];
                          if (relation != null && relation.quantity != null) {
                            quantity = relation.quantity.toInt();
                          }
                        }

                        return ProductCardTicket(
                          product: product,
                          quantity: quantity,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: ValueListenableBuilder<Receipt?>(
        valueListenable: _receiptService.currentReceipt,
        builder: (context, receipt, child) {
          final hasImage = receipt != null && _imageExists(receipt.imagePath);

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(247, 147, 76, 1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                height: 100,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Prix Total :',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Text(
                            receipt?.price != null
                                ? '${receipt!.price!.toStringAsFixed(2)} €'
                                : '0.00 €',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 20),
                          const Text(
                            'TTC',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showReceiptImageBottomSheet(BuildContext context, String imagePath) {
    // Vérifier si le fichier existe
    final file = File(imagePath);
    if (!file.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("L'image du ticket n'est pas disponible"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Barre de drag en haut
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              // Titre
              const Text(
                'Photo du ticket',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Image du ticket
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 3.0,
                      child: Image.file(file, fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),
              // Bouton pour fermer
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0, top: 10.0),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(247, 147, 76, 1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Fermer',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
