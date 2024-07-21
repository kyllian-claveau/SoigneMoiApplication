import 'package:flutter/material.dart';
import 'package:soignemoiapplication/src/view/home_screen.dart';
import 'package:soignemoiapplication/src/view/sign_in.dart';

class AppFooter extends StatelessWidget {
  final bool isHomeScreen;

  const AppFooter({Key? key, required this.isHomeScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.teal,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              // Navigate to sign-in screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SignIn()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              // Navigate to home screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: isHomeScreen
                ? null
                : () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
