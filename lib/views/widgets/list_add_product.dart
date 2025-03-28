import 'package:flutter/material.dart';

class ListAddProduct extends StatefulWidget {
  const ListAddProduct({super.key});

   @override
  _ListAddProductState createState() => _ListAddProductState();
}

class _ListAddProductState extends State<ListAddProduct> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(16),
            ),
            width: double.infinity,
            height: 120,
          ),
          Padding(
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
                // Utiliser Expanded pour que cette colonne prenne la même largeur que l'autre colonne
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(left: 20, right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nom du produit test testzjzzebezbeezie',
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
                            // Première colonne (prix et unité)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '1.50€',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black,
                                    fontFamily: 'Lato',
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Text(
                                    'Unité :',
                                    softWrap: true,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black,
                                      fontFamily: 'Lato',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Deuxième colonne (les boutons - et +)
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(top: 3),
                                      child: Image.asset(
                                        'assets/app_assets/minus_icon.png',
                                        width: 38,
                                        height: 38,
                                      ),
                                    ),
                                    Text(
                                      ' 1 ',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.black,
                                        fontFamily: 'Lato',
                                      ),
                                    ),
                                    Image.asset(
                                      'assets/app_assets/plus_orange_icon.png',
                                      width: 38,
                                      height: 38,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}