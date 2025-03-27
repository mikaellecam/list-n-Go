import 'package:flutter/material.dart';

class CreateProductListDialog extends StatefulWidget {
  const CreateProductListDialog({super.key});

  @override
  State<CreateProductListDialog> createState() =>
      _CreateProductListDialogState();
}

class _CreateProductListDialogState extends State<CreateProductListDialog> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey.shade300,
      title: const Text("Create Product List"),
      content: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Nom de la nouvelle liste:",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ],
          ),
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                errorMaxLines: 3,
              ),
              cursorColor: Colors.white,
              autofocus: true,
              validator: (userInput) {
                if (userInput == null || userInput.trim() == "") {
                  return "Le nom ne peut pas être vide";
                }
                if (!RegExp("^[a-zA-Z0-9]{1,30}\$").hasMatch(userInput)) {
                  return "Le nom n'est pas valide, il doit seulement contenir des lettres ou des nombres (longueur max est de 30)";
                }
                return null;
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _controller.text);
            }
          },
          child: const Text(
            'Submit',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
