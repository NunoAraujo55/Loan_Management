import 'package:flutter/material.dart';

class DisplayInputField extends StatelessWidget {
  final String info;
  final String label;
  const DisplayInputField({
    Key? key,
    required this.info,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 20),
      width: 280,
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          prefixText: "\$ ",
          prefixStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          hintText: info,
          filled: true,
          fillColor: Color(0xFFF7F9FA),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFE6EBF0)),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
