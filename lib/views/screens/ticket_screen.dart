import 'package:flutter/material.dart';
import 'package:listngo/views/widgets/custom_app_bar.dart';
import 'package:listngo/views/widgets/product_card_ticket.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  _TicketScreenState createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      appBar: CustomAppBar(),
      body: Column(
        children: [
          // Titre centré horizontalement
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: const Text(
              'Mon Titre',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Lato',
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Sous-titre centré horizontalement
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 16.0),
            child: const Text(
              'Mon Sous-titre',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontFamily: 'Lato',
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          const ProductCardTicket(),
          const ProductCardTicket(),
          const ProductCardTicket(),
        ],
      ),
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(247, 147, 76, 1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            height: 100,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Prix Total :',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: const [
                      Text(
                        '23.99 €',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 20),
                      Text(
                        'TTC',
                        style: TextStyle(color: Colors.black87, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Rond gris au-dessus à droite
          Positioned(
            top: -70,
            right: 20,
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(247, 176, 91, 1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons
                      .picture_in_picture, // Change selon ce que tu veux mettre
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
