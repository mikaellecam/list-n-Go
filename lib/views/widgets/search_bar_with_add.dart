import 'package:flutter/material.dart';

class SearchBarWithAdd extends StatefulWidget {
  final bool showAddButton;

  const SearchBarWithAdd({super.key, required this.showAddButton});

  @override
  _SearchBarWithAddState createState() => _SearchBarWithAddState();
}

class _SearchBarWithAddState extends State<SearchBarWithAdd> {
  final TextEditingController _searchController = TextEditingController();

  void _showAddListDialog() {
    TextEditingController _listNameController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
            content: Container(
              width: 320,
              height: 70,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  TextField(
                    controller: _listNameController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Nom de la liste',
                      hintStyle: TextStyle(
                        color: Color.fromRGBO(176, 176, 176, 1.0),
                      ),
                      filled: true,
                      fillColor: Color.fromRGBO(176, 176, 176, 0.27),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Annuler',
                      style: TextStyle(
                        color: Color.fromRGBO(176, 176, 176, 1.0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Color.fromRGBO(247, 176, 91, 1.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onPressed: () {
                      if (_listNameController.text.isNotEmpty) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      'Ajouter',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Rechercher une liste',
                hintStyle: const TextStyle(color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Color.fromRGBO(247, 176, 91, 1.0),
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Color.fromRGBO(247, 176, 91, 1.0),
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Color.fromRGBO(247, 147, 76, 1.0),
                    width: 2.5,
                  ),
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
              ),
            ),
          ),

          if (widget.showAddButton) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: Image.asset(
                'assets/app_assets/plus_light-orange_icon.png',
                width: 50,
                height: 50,
              ),
              onPressed: _showAddListDialog,
            ),
          ],
        ],
      ),
    );
  }
}
