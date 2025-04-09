import 'package:flutter/material.dart';

import '../widgets/inputs_product.dart';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({super.key});

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  String valeurNutriscore = '';
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 243, 243, 243),
        appBar: AppBar(title: const Text(
          "Créer un produit",
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontFamily: 'Lato',
            ),
        ),
          centerTitle: true,
          backgroundColor: Colors.white,

        ),
        body: Column(
          children : [
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  child: Image.network(
                    'https://www.annuaire-bijoux.com/wp-content/themes/first-mag/img/noprew-related.jpg',
                    fit: BoxFit.fill,
                  ),
                ),
                //Pour placer le bouton en bas à droite de l'image
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
            Expanded(
              child : Container(
                  width: double.infinity,
                  padding : EdgeInsets.only(top : 25, bottom : 20, left : 30, right: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white,
                  ),
                  child :
                    Container(
                      width: 100,
                      height: 50,
                      child: Scrollbar(
                        thumbVisibility : true,
                        thickness: 3,
                          child: SingleChildScrollView(
                          child : Container(
                            padding : EdgeInsets.only(right: 20),
                            child : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children : [
                                  InputsProduct(
                                    title: 'Nom : ',
                                    hint_text: 'Entrez le nom du produit',
                                  ),
                                  InputsProduct(
                                    title: 'Unité ( poids / volume / nombre ) :',
                                    hint_text: 'Entrez l\'unité',
                                  ),
                                  InputsProduct(
                                    title: 'Mots-clés de recherche :',
                                    hint_text: 'Exemple : tomate, viande',
                                  ),
                                  Text(
                                    'Nutri-score :',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                      fontFamily: 'Lato',
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    margin: EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Color.fromRGBO(245, 245, 245, 1.0),
                                    ),
                                    child : DropdownButton<String>(
                                      hint: Text(
                                        'Choisir une option',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontFamily: 'Lato'
                                        ),
                                      ),
                                      value: valeurNutriscore == '' ? null : valeurNutriscore,
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            valeurNutriscore = newValue;
                                          });
                                        }
                                      },
                                      dropdownColor: Color.fromRGBO(245, 245, 245, 1.0),
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontFamily: 'Lato',
                                      ),
                                      items: <String>['0', 'A', 'B', 'C', 'D', 'E']
                                          .map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _isChecked,
                                        activeColor: Color.fromRGBO(247, 147, 76, 1.0),
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
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontFamily: 'Lato',
                                        ),
                                      )
                                    ],
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),
                                        color: const Color.fromRGBO(247, 147, 76, 1.0),),
                                      padding: EdgeInsets.symmetric(vertical : 3),
                                      margin : EdgeInsets.all(25),
                                      child: TextButton(
                                          onPressed: () {
                                            print('Bouton pressé');
                                            // liste terminée
                                          },
                                          child: Text(
                                            'Créer',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontFamily: "Lato",
                                              color: Colors.white,
                                            ),
                                          )
                                      ),
                                    ),
                                  ),
                                ]
                            ),
                          )
                        )
                      )
                    )
              )
            )
          ]
        )
    );
  }
}



