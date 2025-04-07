import 'package:flutter/material.dart';

import '../widgets/product_card.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 243, 243, 243),
        appBar: AppBar(
          title: Image.asset('assets/app_assets/list-n-go_logo.png', height: 50),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 243, 243, 243),
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 120),
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child:Row(
                      children: [
                        Spacer(),
                        Container(
                          constraints: BoxConstraints(maxWidth: 250),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Nom de la liste',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontFamily: "Lato",
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                                softWrap: true,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Image.asset(
                                  'assets/app_assets/pencil_icon.png',
                                  width: 60,
                                  height: 60,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Image.asset(
                          'assets/app_assets/plus_light-orange_icon.png',
                          width: 35,
                          height: 35,
                        ),
                      ],
                    )
                  ),
                  Container(
                    alignment: Alignment.topRight,
                    padding : EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Text(
                          'Tout sélectionner',
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: "Lato",
                            color: Colors.black,
                          ),
                        ),
                      ],
                      )
                  ),
                  ...List.generate(10, (index) => ProductCard()),
                ],
              ),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
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
                    'Courses terminées',
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: "Lato",
                      color: Colors.white,
                    ),
                  )
                 ),
                ),
              ),
          ],
      ),
    );
  }
}
