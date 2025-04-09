import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:listngo/models/product_list.dart';
import 'package:listngo/services/product_list_service.dart';
import 'package:listngo/services/service_locator.dart';

class ListCard extends StatefulWidget {
  final ProductList productList;
  final VoidCallback? onTap;

  const ListCard({super.key, required this.productList, this.onTap});

  @override
  State<ListCard> createState() => _ListCardState();
}

class _ListCardState extends State<ListCard> {
  late final TextEditingController _controller;
  late final ProductListService _productListService;
  bool _isRenaming = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.productList.name);
    _productListService = getIt<ProductListService>();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void startRenaming() {
    setState(() {
      _isRenaming = true;
    });
  }

  void finishRenaming() async {
    setState(() {
      _isRenaming = false;
    });
    String newName = _controller.text;
    if (newName.isEmpty) {
      return;
    }
    widget.productList.name = newName;
    _productListService.updateList(widget.productList);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromRGBO(255, 255, 255, 1.0),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () {
            final actualList = getIt<ProductListService>().findListById(
              widget.productList.id!,
            );
            print(actualList.hashCode);
            getIt<ProductListService>().currentList.value = actualList;
            context.push('/list');
          },
          splashColor: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Image.asset(
                      'assets/app_assets/basket_picture.png',
                      width: 55,
                      height: 55,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      // Add this Expanded widget
                      child:
                          _isRenaming
                              ? TextField(
                                controller: _controller,
                                autofocus: true,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "Lato",
                                  color: Colors.black,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              )
                              : Text(
                                widget.productList.name,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "Lato",
                                  color: Colors.black,
                                ),
                              ),
                    ),
                  ],
                ),
              ),
              if (_isRenaming)
                IconButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    finishRenaming();
                  },
                  icon: const Icon(
                    Icons.check,
                    color: Colors.orange,
                  ), // Changed to orange to match menu color
                ),
              PopupMenuButton(
                iconColor: Colors.orange,
                color: Colors.white,
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        onTap: startRenaming,
                        child: const Text(
                          'Rename',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      PopupMenuItem(
                        child: const Text(
                          'Remove',
                          style: TextStyle(color: Colors.black),
                        ),
                        onTap: () async {
                          bool? confirm = await showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Confirmation'),
                                  content: const Text(
                                    'Êtes-vous sûr de vouloir supprimer cet élément ?',
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => context.pop(false),
                                      child: const Text('Annuler'),
                                    ),
                                    TextButton(
                                      onPressed: () => context.pop(true),
                                      child: const Text('Supprimer'),
                                    ),
                                  ],
                                ),
                          );
                          if (confirm != null && confirm) {
                            await getIt<ProductListService>().removeList(
                              widget.productList,
                            );
                            if (context.mounted) {
                              context.pop();
                            }
                          }
                        },
                      ),
                    ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
