import 'package:flutter/material.dart';

class ProductCardTicket extends StatefulWidget {
  const ProductCardTicket({super.key});

  @override
  _ProductCardTicketState createState() => _ProductCardTicketState();
}

class _ProductCardTicketState extends State<ProductCardTicket> {
  bool _isChecked = false;
  int _quantity = 1;

  void _addQuantity() {
    setState(() {
      if (_quantity < 99) {
        _quantity++;
      }
    });
  }

  void _substractQuantity() {
    setState(() {
      if (_quantity > 1) {
        _quantity--;
      }
    });
  }

  @override
Widget build(BuildContext context) {
  return Container(
    padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              'https://www.lahalleauxplantes.com/wp-content/uploads/2020/12/tomatoes-5962167-300x300.jpg',
              width: 75,
              height: 75,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                return child;
              },
            ),
          ),
          Container(
            constraints: BoxConstraints(maxWidth: 224),
            height: 75,
            padding: EdgeInsets.only(left: 20, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Nom du produit',
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 1),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              'Quantité : ',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontFamily: 'Lato',
                              ),
                            ),
                            Text(
                              ' $_quantity ',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontFamily: 'Lato',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}
