import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:listngo/services/product_service.dart';
import 'package:listngo/views/widgets/custom_app_bar.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

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

  // Image handling variables
  final ImagePicker _picker = ImagePicker();
  String? _imagePath;
  File? _imageFile;
  bool _hasChangedImage = false;

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

      if (product.imagePath != null) {
        setState(() {
          _imagePath = product.imagePath;
          // Check if the image is a local file (not from API)
          if (!product.isApi && product.imagePath != null) {
            _imageFile = File(product.imagePath!);
          }
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Save the image to the application directory
        final String savedPath = await _saveImageToAppDirectory(pickedFile);

        setState(() {
          _imagePath = savedPath;
          _imageFile = File(savedPath);
          _hasChangedImage = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection de l\'image: $e')),
      );
    }
  }

  Future<String> _saveImageToAppDirectory(XFile file) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String appDirPath = appDir.path;

    final String uniqueFileName =
        '${const Uuid().v4()}${path.extension(file.path)}';
    final String savedImagePath = path.join(appDirPath, uniqueFileName);

    await File(file.path).copy(savedImagePath);

    return savedImagePath;
  }

  Future<void> _deleteTemporaryImage() async {
    if (_hasChangedImage && _imagePath != null) {
      try {
        final file = File(_imagePath!);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        print('Erreur lors de la suppression de l\'image: $e');
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sélectionner une source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Galerie de photos'),
                  ),
                  onTap: () {
                    context.pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Appareil photo'),
                  ),
                  onTap: () {
                    context.pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    if (_hasChangedImage ||
        _nameController.text.isNotEmpty ||
        _quantityController.text.isNotEmpty ||
        _keywordsController.text.isNotEmpty) {
      final shouldPop = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Êtes-vous sûr ?'),
            content: const Text(
              'Les modifications que vous avez apportées ne seront pas enregistrées.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Quitter'),
              ),
            ],
          );
        },
      );

      if (shouldPop == true) {
        await _deleteTemporaryImage();
      }

      return shouldPop ?? false;
    }

    return true;
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
        imagePath: _imagePath,
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
        imagePath: _imagePath,
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

  // Widget pour créer un placeholder sans appel réseau ni asset
  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 50, color: Colors.grey[500]),
            SizedBox(height: 10),
            Text(
              'Aucune image',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontFamily: 'Lato',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _displayImage() {
    if (_imageFile != null) {
      return Image.file(
        _imageFile!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    } else if (_imagePath != null &&
        _isEditing &&
        productService.currentProduct.value?.isApi == true) {
      return Image.network(
        _imagePath!,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              color: const Color.fromRGBO(247, 147, 76, 1.0),
              value:
                  loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    } else {
      // Show placeholder
      return _buildPlaceholder();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarTitle =
        widget.customTitle ??
        (_isEditing ? 'Modifier le produit' : 'Créer un produit');
    final buttonText = _isEditing ? 'Mettre à jour' : 'Créer';

    return WillPopScope(
      // TODO: fix the deprecation
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 243, 243, 243),
        appBar: CustomAppBar(
          onBackPressed: () async {
            if (await _onWillPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: constraints.maxHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: screenHeight * 0.25,
                            width: double.infinity,
                            child: _displayImage(),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: _showImageSourceDialog,
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
                                  Icons.add_a_photo,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(
                            top: 25,
                            bottom: 60,
                            left: 30,
                            right: 15,
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
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                child: Container(
                                  padding: EdgeInsets.only(right: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                borderRadius:
                                                    BorderRadius.circular(10),
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

                                      // Rest of the form fields as before...
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
                                                borderRadius:
                                                    BorderRadius.circular(10),
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
                                                borderRadius:
                                                    BorderRadius.circular(10),
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
                                        margin: EdgeInsets.symmetric(
                                          vertical: 10,
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
                        ),
                      ),
                    ],
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
      ),
    );
  }
}
