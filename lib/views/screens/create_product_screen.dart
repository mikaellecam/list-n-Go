import 'package:flutter/material.dart';
import 'package:listngo/services/product_service.dart';
import 'package:listngo/views/widgets/custom_app_bar.dart';

import '../../services/database_service.dart';
import '../../services/service_locator.dart';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({super.key, this.customTitle});

  final String? customTitle;

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final ProductService productService = getIt<ProductService>();
  bool _isLoading = false;
  String valeurNutriscore = '';
  bool _isChecked = false;
  bool _isEditing = false;
  int? _productId;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _keywordsController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Écouter les changements dans l'état de chargement du service
    productService.isLoading.addListener(_updateLoadingState);
    // Écouter les erreurs du service
    productService.error.addListener(_showError);

    // Vérifier si un produit est déjà sélectionné pour modification
    _loadCurrentProduct();
  }

  void _loadCurrentProduct() {
    if (productService.currentProduct.value != null) {
      final product = productService.currentProduct.value!;
      _isEditing = true;
      _productId = product.id;

      // Remplir les champs avec les valeurs du produit
      _nameController.text = product.name;

      if (product.quantity != null) {
        _quantityController.text = product.quantity!;
      }

      if (product.keywords != null && product.keywords!.isNotEmpty) {
        _keywordsController.text = product.keywords!.join(', ');
      }

      if (product.nutriScore != null) {
        setState(() {
          valeurNutriscore = product.nutriScore!;
        });
      }
    }
  }

  void _updateLoadingState() {
    if (mounted) {
      setState(() {
        _isLoading = productService.isLoading.value;
      });
    }
  }

  void _showError() {
    final errorMessage = productService.error.value;
    if (errorMessage != null && errorMessage.isNotEmpty && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _keywordsController.dispose();
    _scrollController.dispose();
    productService.isLoading.removeListener(_updateLoadingState);
    productService.error.removeListener(_showError);

    // Ne pas réinitialiser le produit courant si on est en mode édition
    // pour permettre l'utilisation dans d'autres écrans
    if (!_isEditing) {
      productService.resetCurrentProduct();
    }

    super.dispose();
  }

  Future<void> _saveProduct() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le nom du produit est requis')),
      );
      return;
    }

    final quantity = _quantityController.text.trim();
    final keywordsText = _keywordsController.text.trim();
    final List<String> keywordsList =
        keywordsText.isEmpty
            ? []
            : keywordsText.split(',').map((k) => k.trim()).toList();

    int resultId;

    if (_isEditing && _productId != null) {
      resultId = await productService.updateProduct(
        id: _productId!,
        name: name,
        quantity: quantity.isEmpty ? null : quantity,
        keywords: keywordsList.isEmpty ? null : keywordsList,
        nutriScore: valeurNutriscore.isEmpty ? null : valeurNutriscore,
      );

      if (resultId > 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produit mis à jour avec succès')),
        );
        Navigator.of(context).pop(true);
      }
    } else {
      // Créer un nouveau produit
      resultId = await productService.createProduct(
        name: name,
        quantity: quantity.isEmpty ? null : quantity,
        keywords: keywordsList.isEmpty ? null : keywordsList,
        nutriScore: valeurNutriscore.isEmpty ? null : valeurNutriscore,
      );

      if (resultId > 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produit créé avec succès')),
        );

        // Si l'utilisateur a coché "Ajouter directement dans la liste"
        if (_isChecked) {
          // Logique pour ajouter dans la liste active
          // Cette partie devra être complétée selon vos besoins
        }

        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarTitle =
        widget.customTitle ??
        (_isEditing ? 'Modifier le produit' : 'Créer un produit');
    final buttonText = _isEditing ? 'Mettre à jour' : 'Créer';

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
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 82),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final dbService = DatabaseService.instance;
                          final result =
                              await dbService.getAllProductsAsString();
                          print(result); // Affiche dans la console

                          // Afficher dans une boîte de dialogue avec texte noir
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: Text(
                                    'Contenu de la base de données',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  content: SingleChildScrollView(
                                    child: Text(
                                      result,
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Fermer'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                          );
                        },
                        child: Text('Afficher les produits'),
                      ),
                      Stack(
                        children: [
                          Container(
                            height: screenHeight * 0.25,
                            width: double.infinity,
                            child:
                                _isEditing &&
                                        productService
                                                .currentProduct
                                                .value
                                                ?.imagePath !=
                                            null
                                    ? Image.network(
                                      productService
                                          .currentProduct
                                          .value!
                                          .imagePath!,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (
                                            context,
                                            error,
                                            stackTrace,
                                          ) => Image.network(
                                            'https://www.annuaire-bijoux.com/wp-content/themes/first-mag/img/noprew-related.jpg',
                                            fit: BoxFit.contain,
                                          ),
                                    )
                                    : Image.network(
                                      'https://www.annuaire-bijoux.com/wp-content/themes/first-mag/img/noprew-related.jpg',
                                      fit: BoxFit.contain,
                                    ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: () {
                                print('Bouton pressé');
                                // Logique pour sélectionner une image
                              },
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(247, 147, 76, 1.0),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 30,
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
                          bottom: 120,
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
                            controller: _scrollController,
                            thumbVisibility: true,
                            thickness: 3,
                            child: Container(
                              padding: EdgeInsets.only(right: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // Nom
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
                                            controller: _nameController,
                                            decoration: InputDecoration(
                                              hintText:
                                                  'Entrez le nom du produit',
                                              hintStyle: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Lato',
                                                color: Colors.black,
                                              ),
                                              border: InputBorder.none,
                                            ),
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontFamily: 'Lato',
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Unité
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Unité (poids/volume/nombre) :',
                                          style: TextStyle(
                                            fontSize: 20,
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
                                            controller: _quantityController,
                                            decoration: InputDecoration(
                                              hintText: 'Entrez l\'unité',
                                              hintStyle: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Lato',
                                                color: Colors.black,
                                              ),
                                              border: InputBorder.none,
                                            ),
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontFamily: 'Lato',
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Mots-clés
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Mots-clés de recherche :',
                                          style: TextStyle(
                                            fontSize: 20,
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
                                            controller: _keywordsController,
                                            decoration: InputDecoration(
                                              hintText:
                                                  'Exemple : tomate, viande',
                                              hintStyle: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Lato',
                                                color: Colors.black,
                                              ),
                                              border: InputBorder.none,
                                            ),
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontFamily: 'Lato',
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Nutri-score
                                  Text(
                                    'Nutri-score :',
                                    style: TextStyle(
                                      fontSize: 20,
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
                                        fontSize: 18,
                                        fontFamily: 'Lato',
                                      ),
                                      items:
                                          <String>[
                                            'Non concerné',
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
                                  // Afficher seulement si en mode création, pas en édition
                                  if (!_isEditing)
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
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontFamily: 'Lato',
                                          ),
                                        ),
                                      ],
                                    ),
                                  SizedBox(height: 30),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bouton fixe en bas de l'écran
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
                        onPressed: _isLoading ? null : _saveProduct,
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
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : Text(
                                  buttonText,
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
