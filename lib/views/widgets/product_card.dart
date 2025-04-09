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
      if (_quantity < 99) {
        _quantity++;
      }
    });
  }

  void _subtractQuantity() {
    setState(() {
      if (_quantity > 1) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _subtractQuantity,
                            child: Image.asset(
                              'assets/app_assets/minus_icon.png',
                              width: 42,
                              height: 42,
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
                      SizedBox(width: 15),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.delete_outline),
                          ),
                          AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color:
                                  _isChecked
                                      ? Color.fromRGBO(247, 147, 76, 1.0)
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Color.fromRGBO(247, 147, 76, 1.0),
                                width: 2,
                              ),
                              boxShadow:
                                  _isChecked
                                      ? [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ]
                                      : [],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(25),
                                onTap: () {
                                  setState(() {
                                    _isChecked = !_isChecked;
                                  });
                                },
                                child: Center(
                                  child: Icon(
                                    _isChecked ? Icons.check : Icons.add,
                                    color:
                                        _isChecked
                                            ? Colors.white
                                            : Color.fromRGBO(247, 147, 76, 1.0),
                                  ),
                                ),
                              ),
                            ),
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
