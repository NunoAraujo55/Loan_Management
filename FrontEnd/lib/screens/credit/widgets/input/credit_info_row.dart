import 'package:flutter/material.dart';

class CustomInfoRow extends StatelessWidget {
  final String begin;
  final String end;

  const CustomInfoRow({super.key, required this.begin, required this.end});

  @override
  Widget build(context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              begin,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),
            Text(
              end,
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        const Divider(
          color: Colors.grey,
        ),
      ],
    );
  }
}
