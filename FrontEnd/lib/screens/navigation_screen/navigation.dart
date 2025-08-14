import 'package:flutter/material.dart';

class Navigation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF002E8B), // Blue background
      appBar: AppBar(
        backgroundColor: const Color(0xFF002E8B),
        elevation: 0,
        toolbarHeight: 100,
        leading: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Image.asset(
                "assets/right-arrow.png",
                height: 20,
                width: 20,
                color: Colors.white,
              ),
              onPressed: () {
                // Action for "back"
              },
            ),
            /*const Text(
              "voltar",
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
            )*/
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 50),
            decoration: BoxDecoration(
              color: const Color(0xFFD8EAF2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      'Nuno',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Example list of items
                  ListTile(
                    leading: Image.asset(
                      'assets/house.png',
                      height: 40,
                      width: 40,
                    ),
                    title: Text('Os meus Créditos'),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                    ),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Image.asset(
                      'assets/amortized.png',
                      height: 40,
                      width: 40,
                    ),
                    title: Text('Amortizações'),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                    ),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Image.asset(
                      'assets/arithmetic.png',
                      height: 40,
                      width: 40,
                    ),
                    title: Text('Simulações'),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                    ),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Image.asset(
                      'assets/settings.png',
                      height: 40,
                      width: 40,
                    ),
                    title: Text('Definições'),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),

          // circle on top (overlapping the blue and the light container)
          Align(
            alignment: Alignment.topCenter,
            child: CircleAvatar(
              radius: 42,
              backgroundColor: Colors.black,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Text(
                  'N',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
