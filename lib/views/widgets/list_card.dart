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
                          'Renommer',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      PopupMenuItem(
                        child: const Text(
                          'Supprimer',
                          style: TextStyle(color: Colors.black),
                        ),
                        onTap: () async {
                          bool? confirm = await showModalBottomSheet<bool>(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (context) {
                              return Container(
                                color : const Color.fromARGB(255, 243, 243, 243),
                                padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom,
                                  left: 16,
                                  right: 16,
                                  top: 16,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Confirmation',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: const Color.fromRGBO(
                                              247,
                                              147,
                                              76,
                                              1.0,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.close),
                                          onPressed: () => context.pop(false),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Êtes-vous sûr de vouloir supprimer cet élément ?',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () => context.pop(false),
                                          child: Text(
                                            'Annuler',
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () => context.pop(true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromRGBO(
                                                  247,
                                                  147,
                                                  76,
                                                  1.0,
                                                ),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                          ),
                                          child: Text('Supprimer'),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              );
                            },
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
