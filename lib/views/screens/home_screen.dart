import 'package:flutter/material.dart';
import '../widgets/shop_list.dart';
import '../widgets/search_bar_with_add.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      appBar: AppBar(
        title: Image.asset('assets/app_assets/list-n-go_logo.png', height: 50),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTabButton(0, Icons.shopping_cart, "Listes de courses"),
              const SizedBox(width: 8),
              _buildTabButton(1, Icons.receipt, "Tickets de caisse"),
            ],
          ),

          // Affichage conditionnel de la barre de recherche
          const SizedBox(height: 10),
          SearchBarWithAdd(showAddButton: _selectedTab == 0),
          const SizedBox(height: 10),

          Expanded(
            child: _selectedTab == 0 ? _buildListView() : _buildFavoritesView(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, IconData icon, String label) {
    bool isSelected = _selectedTab == index;

    return ElevatedButton.icon(
      onPressed: () {
        setState(() {
          _selectedTab = index;
        });
      },
      icon: Icon(
        icon,
        color:
            isSelected ? Colors.white : const Color.fromRGBO(247, 147, 76, 1.0),
      ),
      label: Text(
        label,
        style: TextStyle(
          color:
              isSelected
                  ? Colors.white
                  : const Color.fromRGBO(247, 147, 76, 1.0),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? const Color.fromRGBO(247, 147, 76, 1.0) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: Color.fromRGBO(247, 147, 76, 1.0)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: 15,
      itemBuilder: (context, index) {
        return ShopListItem();
      },
    );
  }

  Widget _buildFavoritesView() {
    return Center(
      child: Text(
        "<Afficher l'historique>",
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }
}
