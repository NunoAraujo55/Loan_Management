import 'package:flutter/material.dart';


class ProfileScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8EAF2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD8EAF2),
        elevation: 0,
        toolbarHeight: 100,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            // Action for "back"
          },
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF002E8B),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 40, left: 16, right: 16, bottom: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [   
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text(
                            'Nuno',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ListTile(
                          leading:
                              Icon(Icons.account_circle, color: Colors.white),
                          title: Text('Nuno Araújo',
                              style: TextStyle(color: Colors.white)),
                        ),
                        ListTile(
                          leading: Icon(Icons.password, color: Colors.white),
                          title: Text('Password',
                              style: TextStyle(color: Colors.white)),
                        ),
                        ListTile(
                          leading: Icon(Icons.email, color: Colors.white),
                          title: Text('Email',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                    ListTile(
                      leading: Icon(Icons.exit_to_app, color: Colors.white),
                      title:
                          Text('Sair', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
