import 'package:flutter/material.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int _quantity = 1;
  String _text = "500G";
  String? _selectedPrice;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text("TEST")),
      // Occuper tout l'espace vertical disponible
      body: LayoutBuilder(
        builder: (context, constraints) {
          // LayoutBuilder donne la hauteur maximale disponible
          return Container(
            // Forcer le container à prendre toute la hauteur disponible
            height: constraints.maxHeight,
            child: Stack(
              // Permettre au Stack de remplir le Container
              fit: StackFit.expand,
              children: [
                // Partie supérieure avec défilement
                SingleChildScrollView(
                  // Padding en bas pour éviter que le contenu ne soit masqué par le bouton
                  padding: const EdgeInsets.only(
                    bottom: 82,
                  ), // Hauteur du bouton + padding
                  child: Column(
                    children: [
                      // Image en haut
                      SizedBox(
                        width: double.infinity,
                        height: screenHeight * 0.25,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                          ),
                          child: Image.network(
                            'https://images.openfoodfacts.org/images/products/000/008/017/7173/front_en.174.200.jpg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      // Container avec les infos du produit
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Colonne pour le titre et les boutons de modification/suppression
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  alignment: WrapAlignment.start,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    const Text(
                                      "Tomates avec un titre un",
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontFamily: 'Lato',
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: Color.fromRGBO(
                                          247,
                                          147,
                                          76,
                                          1.0,
                                        ),
                                      ),
                                      onPressed: () {
                                        // Action d'édition
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        // Action de suppression
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Row pour les boutons de quantité, alignée à droite
                            const SizedBox(height: 30),

                            // Unité (poids/volume/litre)
                            SizedBox(
                              width: double.infinity,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  const Text(
                                    'Unité ',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontFamily: 'Lato',
                                    ),
                                  ),
                                  const Text(
                                    '(poids/volume/litre) ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontFamily: 'Lato',
                                    ),
                                  ),
                                  const Text(
                                    ':',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontFamily: 'Lato',
                                    ),
                                  ),
                                  // Utilisation d'Expanded pour occuper l'espace restant
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        0,
                                        0,
                                        75,
                                        0,
                                      ),
                                      child: Text(
                                        _text,
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontFamily: 'Lato',
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 30),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Nutri-Score :',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontFamily: 'Lato',
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                  ),
                                  child: SizedBox(
                                    width: 170,
                                    child: Image.network(
                                      "https://upload.wikimedia.org/wikipedia/commons/thumb/7/7d/Nutri-score-A.svg/1024px-Nutri-score-A.svg.png",
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 30),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Prix :',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontFamily: 'Lato',
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    0,
                                    0,
                                    10,
                                    0,
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 100,
                                        child: TextField(
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          decoration: InputDecoration(
                                            labelText: 'Prix',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    50.0,
                                                  ), // Bordures arrondies
                                            ),
                                            errorText:
                                                (_selectedPrice != null &&
                                                        _selectedPrice!
                                                            .isNotEmpty &&
                                                        double.tryParse(
                                                              _selectedPrice!,
                                                            ) ==
                                                            null)
                                                    ? 'Veuillez entrer un nombre valide'
                                                    : null,
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedPrice = value;
                                            });
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      //_isPriceDifferent ?
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Color.fromRGBO(
                                            247,
                                            147,
                                            76,
                                            1.0,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(),
                                          icon: Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                          onPressed: () {},
                                        ),
                                      ),
                                      //: SizedBox.shrink(),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 40),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                  ),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(),
                                      icon: const Icon(
                                        Icons.remove,
                                        color: Colors.grey,
                                        size: 30,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          if (_quantity > 0) {
                                            _quantity--;
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                Text(
                                  '$_quantity',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 24,
                                    fontFamily: 'Lato',
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0,
                                  ),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(247, 147, 76, 1.0),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(),
                                      icon: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _quantity++;
                                        });
                                      },
                                    ),
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

                // Bouton fixe en bas de l'écran
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      // Ajout d'une ombre subtile pour séparer visuellement le bouton du contenu
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0, -2),
                          blurRadius: 4.0,
                        ),
                      ],
                    ),
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // Action pour ajouter à la liste
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(
                            247,
                            147,
                            76,
                            1.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        ),
                        child: const Text(
                          'Ajouter à la liste',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Lato',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
