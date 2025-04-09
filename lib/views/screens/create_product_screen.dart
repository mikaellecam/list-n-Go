import 'package:flutter/material.dart';
import 'package:listngo/views/widgets/custom_app_bar.dart';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({super.key});

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  String valeurNutriscore = '';
  bool _isChecked = false;

  // Ajout d'un ScrollController pour le Scrollbar
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    // Libérer les ressources du ScrollController à la destruction du widget
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      appBar: CustomAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            height: constraints.maxHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                SingleChildScrollView(
                  // Ajout du controller à SingleChildScrollView
                  controller: _scrollController,
                  padding: const EdgeInsets.only(
                    bottom: 82,
                  ), // Espace pour le bouton
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            height:
                                screenHeight *
                                0.25, // Même hauteur que dans ProductScreen
                            width: double.infinity,
                            child: Image.network(
                              'https://www.annuaire-bijoux.com/wp-content/themes/first-mag/img/noprew-related.jpg',
                              fit:
                                  BoxFit
                                      .contain, // Même fit que dans ProductScreen
                            ),
                          ),
                          // Pour placer le bouton en bas à droite de l'image
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                print('Bouton pressé');
                              },
                              child: Padding(
                                padding: EdgeInsets.only(top: 3),
                                child: Image.asset(
                                  'assets/app_assets/plus_orange_icon.png',
                                  width: 75,
                                  height: 75,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(
                          top: 25,
                          bottom: 120, // Augmenté comme dans ProductScreen
                          left: 30,
                          right: 15,
                        ),
                        constraints: BoxConstraints(
                          minHeight:
                              constraints.maxHeight - screenHeight * 0.25 + 100,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.white,
                        ),
                        child: Container(
                          width: double.infinity,
                          child: Scrollbar(
                            // Utilisation du ScrollController dans le Scrollbar
                            controller: _scrollController,
                            thumbVisibility: true,
                            thickness: 3,
                            child: Container(
                              padding: EdgeInsets.only(right: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // Nom - Même style que dans ProductScreen
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Nom : ',
                                          style: TextStyle(
                                            fontSize: 20,
                                            // Augmenté comme dans ProductScreen
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontFamily: 'Lato',
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            color: Color.fromRGBO(
                                              245,
                                              245,
                                              245,
                                              1.0,
                                            ),
                                          ),
                                          child: TextField(
                                            decoration: InputDecoration(
                                              hintText:
                                                  'Entrez le nom du produit',
                                              hintStyle: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Lato',
                                              ),
                                              border: InputBorder.none,
                                            ),
                                            style: TextStyle(
                                              fontSize: 18, // Harmonisé
                                              fontFamily: 'Lato',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Unité - Même style que dans ProductScreen
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Unité (poids/volume/nombre) :',
                                          style: TextStyle(
                                            fontSize: 20, // Harmonisé
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontFamily: 'Lato',
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            color: Color.fromRGBO(
                                              245,
                                              245,
                                              245,
                                              1.0,
                                            ),
                                          ),
                                          child: TextField(
                                            decoration: InputDecoration(
                                              hintText: 'Entrez l\'unité',
                                              hintStyle: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Lato',
                                              ),
                                              border: InputBorder.none,
                                            ),
                                            style: TextStyle(
                                              fontSize: 18, // Harmonisé
                                              fontFamily: 'Lato',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Mots-clés - Même style
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Mots-clés de recherche :',
                                          style: TextStyle(
                                            fontSize: 20, // Harmonisé
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontFamily: 'Lato',
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            color: Color.fromRGBO(
                                              245,
                                              245,
                                              245,
                                              1.0,
                                            ),
                                          ),
                                          child: TextField(
                                            decoration: InputDecoration(
                                              hintText:
                                                  'Exemple : tomate, viande',
                                              hintStyle: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Lato',
                                              ),
                                              border: InputBorder.none,
                                            ),
                                            style: TextStyle(
                                              fontSize: 18, // Harmonisé
                                              fontFamily: 'Lato',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Nutri-score - Harmonisé
                                  Text(
                                    'Nutri-score :',
                                    style: TextStyle(
                                      fontSize: 20, // Harmonisé
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontFamily: 'Lato',
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    margin: EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Color.fromRGBO(245, 245, 245, 1.0),
                                    ),
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      // Pour que le dropdown prenne toute la largeur
                                      hint: Text(
                                        'Choisir une option',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Lato',
                                        ),
                                      ),
                                      value:
                                          valeurNutriscore == ''
                                              ? null
                                              : valeurNutriscore,
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            valeurNutriscore = newValue;
                                          });
                                        }
                                      },
                                      dropdownColor: Color.fromRGBO(
                                        245,
                                        245,
                                        245,
                                        1.0,
                                      ),
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18, // Harmonisé
                                        fontFamily: 'Lato',
                                      ),
                                      items:
                                          <String>[
                                            '0',
                                            'A',
                                            'B',
                                            'C',
                                            'D',
                                            'E',
                                          ].map<DropdownMenuItem<String>>((
                                            String value,
                                          ) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _isChecked,
                                        activeColor: Color.fromRGBO(
                                          247,
                                          147,
                                          76,
                                          1.0,
                                        ),
                                        checkColor: Colors.white,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            _isChecked = value ?? false;
                                          });
                                        },
                                      ),
                                      Text(
                                        'Ajouter directement dans la liste',
                                        style: TextStyle(
                                          fontSize: 16, // Harmonisé
                                          color: Colors.black,
                                          fontFamily: 'Lato',
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ), // Espace supplémentaire en bas
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bouton fixe en bas de l'écran (comme dans ProductScreen)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
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
                          print('Bouton pressé');
                          // Action pour créer le produit
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
                          'Créer',
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
