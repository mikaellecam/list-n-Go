import 'package:flutter/material.dart';
import 'package:listngo/views/widgets/prices_list_card.dart';

import '../widgets/product_card.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [
          Container(
            child: Column(
              children: [
                ProductCard(),
                ProductCard(),
                ProductCard(),
                ProductCard(),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: PricesListCard(),
          ),
        ],
    );
  }
}
