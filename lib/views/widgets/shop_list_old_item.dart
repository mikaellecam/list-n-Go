import 'package:flutter/material.dart';

class ReceiptItem extends StatelessWidget {
  final String title;
  final String date;

  const ReceiptItem({super.key, required this.title, required this.date});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.receipt_long, color: Colors.orange, size: 40),
        title: DefaultTextStyle(
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: "Lato-black",
            color: Colors.black,
          ),
          child: Text(title, softWrap: true, overflow: TextOverflow.ellipsis),
        ),
        subtitle: Text(
          "Le $date",
          style: const TextStyle(fontSize: 15, fontFamily: "Lato-black"),
        ),
        trailing: Image.asset(
          'assets/app_assets/suivant_icon.png',
          width: 30,
          height: 30,
        ),
        onTap: () {
          //
        },
      ),
    );
  }
}
