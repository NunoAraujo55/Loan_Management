import 'package:flutter/material.dart';

class TabItemWidget extends StatelessWidget {
  final String title;

  const TabItemWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
              child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          )),
        ],
      ),
    );
  }
}
