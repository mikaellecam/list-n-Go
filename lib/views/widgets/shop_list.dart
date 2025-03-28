import 'package:flutter/material.dart';

class ShopListItem extends StatelessWidget {
  const ShopListItem({super.key});

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
          "Nom",
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
          "nb articles",
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
}
