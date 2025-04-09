import 'package:flutter/material.dart';

class InputsProduct extends StatelessWidget {
  final String title;
  final String hint_text;

  const InputsProduct({
    super.key,
    required this.title,
    required this.hint_text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          '$title',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            fontFamily: 'Lato',
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10, bottom: 20),
          child: TextField(
            style: TextStyle(color: Colors.black, fontSize: 15, fontFamily: 'Lato'),
            decoration: InputDecoration(
              hintText: '$hint_text',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Color.fromRGBO(245, 245, 245, 1.0),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }
}
