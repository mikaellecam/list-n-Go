import 'package:flutter/material.dart';
import 'package:listngo/models/product_list/product_list.dart';

class ShopListItem extends StatelessWidget {
  final ProductList productList;
  final VoidCallback? onTap;

  const ShopListItem({super.key, required this.productList, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromRGBO(255, 255, 255, 1.0),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Image.asset(
          'assets/app_assets/basket_picture.png',
          width: 80,
          height: 80,
        ),
        title: Text(
          productList.name,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: "Lato",
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          "Créée le ${_formatDate(productList.createdAt)}", // TODO Change this created at value to the numbers
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: "Lato-black",
          ),
        ),
        trailing: Image.asset(
          'assets/app_assets/suivant_icon.png',
          width: 30,
          height: 30,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
