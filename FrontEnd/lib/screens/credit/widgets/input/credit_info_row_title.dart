import 'package:flutter/material.dart';

class CustomInfoRowtitle extends StatelessWidget {
  final String begin;
  final String end;

  const CustomInfoRowtitle({super.key, required this.begin, required this.end});

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
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              end,
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }
}
