import 'package:flutter/material.dart';

class SearchBarWithAdd extends StatefulWidget {
  final bool showAddButton;
  final VoidCallback? onAddButtonPressed;

  const SearchBarWithAdd({
    super.key,
    required this.showAddButton,
    this.onAddButtonPressed,
  });

  @override
  _SearchBarWithAddState createState() => _SearchBarWithAddState();
}

class _SearchBarWithAddState extends State<SearchBarWithAdd> {
  final TextEditingController _searchController = TextEditingController();

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
              onPressed: widget.onAddButtonPressed,
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
