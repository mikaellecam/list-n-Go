import 'package:flutter/material.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({super.key});

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isChecked = false;
  int _quantity = 1;

  void _addQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _substractQuantity() {
    setState(() {
      if (_quantity > 0) {
        _quantity--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 15),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                'https://www.lahalleauxplantes.com/wp-content/uploads/2020/12/tomatoes-5962167-300x300.jpg',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  return child;
                },
              ),
            ),
            Container(
              constraints: BoxConstraints(maxWidth: 224),
              height: 100,
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
                      fontSize: 15,
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
                          Text(
                            '1.50€',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              fontFamily: 'Lato',
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: _substractQuantity,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 3),
                                  child: Image.asset(
                                    'assets/app_assets/minus_icon.png',
                                    width: 42,
                                    height: 42,
                                  ),
                                ),
                              ),
                              Text(
                                ' $_quantity ',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.black,
                                  fontFamily: 'Lato',
                                ),
                              ),
                              GestureDetector(
                                onTap: _addQuantity,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 3),
                                  child: Image.asset(
                                    'assets/app_assets/plus_orange_icon.png',
                                    width: 40,
                                    height: 40,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(width: 20),
                      Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Image.asset(
                          'assets/app_assets/bin_icon.png',
                          width: 30,
                          height: 30,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Checkbox(
                          value: _isChecked,
                          activeColor: Color.fromRGBO(247, 147, 76, 1.0),
                          checkColor: Colors.white,
                          onChanged: (bool? value) {
                            setState(() {
                              _isChecked = value ?? false;
                            });
                          },
                        ),
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
