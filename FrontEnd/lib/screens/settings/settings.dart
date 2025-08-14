import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_amortiza/auth/auth.service.dart';
import 'package:flutter_amortiza/extensions/string_casing_extension.dart';
import 'package:flutter_amortiza/models/user_model.dart';
import 'package:flutter_amortiza/screens/SignUpScreens/sign_in.dart';
import 'package:flutter_amortiza/screens/credit/create_credit_screen.dart';
import 'package:flutter_amortiza/screens/home_screen/home_screen.dart';
import 'package:get_it/get_it.dart';

class SettingsScreen extends StatefulWidget {
  final User user;
  const SettingsScreen({super.key, required this.user});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  bool isNotificationsEnabled = false;
  final Dio dio = GetIt.instance<Dio>();
  int _currentIndex = 2;
  final Color bgColor = Colors.transparent;
  final List<Widget> _navigationItem = [
    const Icon(Icons.home, color: Colors.white),
    const Icon(Icons.add, color: Colors.white),
    const Icon(Icons.settings, color: Colors.white),
  ];

  Future<void> _logout() async {
    try {
      // Get the stored access token securely
      final accessToken = await AuthService.instance.getAccessToken();

      if (accessToken == null) {
        throw Exception('No access token found');
      }

      await dio.post(
        '/auth/logout',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      await AuthService.instance.clearTokens();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    } catch (e) {
      print('Logout failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to log out')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Settings",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 34,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                widget.user.name.capitalizeFirst(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.user.email,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),

              // Dark Mode Toggle
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.dark_mode, color: Colors.black),
                title: const Text(
                  "Dark Mode",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                trailing: Switch(
                  value: isDarkMode,
                  activeColor: Color.fromARGB(255, 76, 186, 186),
                  onChanged: (value) {
                    setState(() {
                      isDarkMode = value;
                    });
                  },
                ),
              ),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.notifications, color: Colors.black),
                title: const Text(
                  "Notifications",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                trailing: Switch(
                  value: isNotificationsEnabled,
                  activeColor: Color.fromARGB(255, 76, 186, 186),
                  onChanged: (value) {
                    setState(() {
                      isNotificationsEnabled = value;
                    });
                  },
                ),
              ),

              // Contact & Support
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.support_agent, color: Colors.black),
                title: const Text(
                  "Contact & Support",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to Contact & Support page
                },
              ),

              const Spacer(),

              // Logout Button
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.logout,
                  color: Colors.red,
                ),
                title: const Text(
                  "Log Out",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  _logout();
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        //alterar a cor
        height: 60,
        color: const Color(0xFF002E8B),
        index: _currentIndex,
        items: _navigationItem,
        backgroundColor: bgColor,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          Future.delayed(const Duration(milliseconds: 600), () {
            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            } else if (index == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => CreateCreditScreen(
                          user: widget.user,
                        )),
              );
            }
          });
        },
      ),
    );
  }
}
