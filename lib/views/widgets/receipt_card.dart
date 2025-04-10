import 'dart:io';

import 'package:flutter/material.dart';
import 'package:listngo/models/receipt.dart';

class ReceiptCard extends StatelessWidget {
  final Receipt receipt;
  final VoidCallback onTap;

  const ReceiptCard({super.key, required this.receipt, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        receipt.createdAt != null
            ? 'Le ${receipt.createdAt!.day}/${receipt.createdAt!.month}/${receipt.createdAt!.year}'
            : 'Date inconnue';

    final productCount = receipt.products.value.length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Receipt image or placeholder
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      receipt.imagePath != null
                          ? Image.file(
                            File(receipt.imagePath!),
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Icon(
                                  Icons.receipt,
                                  size: 40,
                                  color: Colors.grey[400],
                                ),
                          )
                          : Icon(
                            Icons.receipt,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                ),
              ),
              const SizedBox(width: 16),

              // Receipt details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receipt.name ?? 'Ticket sans nom',
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.shopping_basket,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$productCount produit${productCount > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        if (receipt.price != null)
                          Text(
                            '${receipt.price!.toStringAsFixed(2)} €',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(247, 147, 76, 1.0),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Chevron icon
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
