import 'package:flutter/material.dart';
import 'package:listngo/models/receipt.dart';
import 'package:listngo/services/receipt_service.dart';
import 'package:listngo/services/service_locator.dart';

import '../widgets/shop_list_old_item.dart';

class PurchaseHistoryListScreen extends StatefulWidget {
  const PurchaseHistoryListScreen({super.key});

  @override
  _PurchaseHistoryListScreenState createState() =>
      _PurchaseHistoryListScreenState();
}

class _PurchaseHistoryListScreenState extends State<PurchaseHistoryListScreen> {
  final ReceiptService _receiptService = getIt<ReceiptService>();

  @override
  void initState() {
    super.initState();
    _loadReceipts();
  }

  Future<void> _loadReceipts() async {
    await _receiptService.loadReceiptsWithProducts();
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'Date inconnue';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Receipt>>(
      valueListenable: _receiptService.receipts,
      builder: (context, receipts, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: _receiptService.isLoading,
          builder: (context, isLoading, child) {
            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (receipts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.receipt_long,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Aucun ticket disponible",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Les tickets apparaîtront ici après validation d'une liste de courses",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _loadReceipts,
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 10),
                itemCount: receipts.length,
                itemBuilder: (context, index) {
                  final receipt = receipts[index];
                  return ReceiptItem(
                    title: receipt.name ?? 'Ticket sans nom',
                    date: _formatDate(receipt.createdAt),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
