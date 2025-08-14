import 'package:flutter/material.dart';

class CustomProgressBar extends StatelessWidget {
  final double progress; // Value from 0.0 to 1.0
  final String leftText;
  final String rightText;

  const CustomProgressBar({
    Key? key,
    required this.progress,
    required this.leftText,
    required this.rightText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress Bar
        LayoutBuilder(
          builder: (context, constraints) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Stack(
                children: [
                  // Background container
                  Container(
                    height: 10,
                    width: constraints.maxWidth,
                    color: Colors.grey[300],
                  ),
                  // Progress indicator
                  Container(
                    height: 10,
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        // Text Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(leftText,
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
            Text(rightText,
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ],
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Progress Bar Demo',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Custom Progress Bar'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomProgressBar(
              progress: 0.12, // 12% progress
              leftText: "12% Pago",
              rightText: "30 anos restantes",
            ),
          ),
        ),
      ),
    );
  }
}
