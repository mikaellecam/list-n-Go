import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:listngo/models/product_list/product_list.dart';
import 'package:listngo/services/product_list_service.dart';
import 'package:listngo/services/service_locator.dart';

class ListCard extends StatelessWidget {
  final ProductList productList;
  final VoidCallback? onTap;

  const ListCard({super.key, required this.productList, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromRGBO(255, 255, 255, 1.0),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            IconButton(
              onPressed: () async {
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
                  await getIt<ProductListService>().removeList(productList);
                  if (context.mounted) {
                    context.pop();
                  }
                }
              },
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
            ),
            Expanded(
              child: InkWell(
                onTap: () => context.push('/list'),
                splashColor: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/app_assets/basket_picture.png',
                          width: 55,
                          height: 55,
                        ),
                        SizedBox(width: 20),
                        Text(
                          productList.name,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            fontFamily: "Lato",
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 24,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
