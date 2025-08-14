import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String name;
  final bool obscureText;
  final TextCapitalization textCapitalization;
  final TextInputType inputType;
  final String? initialValue;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.name,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
    required this.inputType,
    this.initialValue
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(initialValue != null && controller.text.isEmpty){
      controller.text = initialValue!;
    }
    return Container(
        margin: const EdgeInsets.only(bottom: 15),
        child: TextField(
          enabled: true,
          controller: controller,
          textCapitalization: textCapitalization,
          maxLength: 32,
          maxLines: 1,
          obscureText: obscureText,
          keyboardType: inputType,
          textAlign: TextAlign.start,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          decoration: InputDecoration(
              labelText: name,
              counterText: "",
              filled: true,
              fillColor: Colors.white,
              labelStyle: const TextStyle(color: Colors.black),
              border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey,
                    width: 0.5),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey,
                    width: 0.5),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey,
                    width: 0.5),
                  borderRadius: BorderRadius.all(Radius.circular(10)))),
        ));
  }
}
