import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soignemoiapplication/src/api/api.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'home_screen.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  static const route = '/signin';

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> login() async {
    setState(() {
      _isLoading = true;
    });

    var data = {
      'username': emailController.text,
      'password': passwordController.text,
    };

    try {
      var res = await Api().login(data);
      var body = json.decode(res.body);

      if (body['code'] == 401) {
        _showError('Identifiants invalides');
      } else if (body['token'] != null) {
        // Decode the token to check for the role
        Map<String, dynamic> decodedToken = JwtDecoder.decode(body['token']);
        List<dynamic> roles = decodedToken['roles'];
        if (roles.contains('ROLE_DOCTOR')) {
          SharedPreferences localStorage = await SharedPreferences.getInstance();
          localStorage.setString('token', body['token']);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          _showError('Accès refusé. Seuls les médecins peuvent se connecter.');
        }
      } else {
        _showError('Erreur inattendue. Veuillez réessayer.');
      }
    } catch (e) {
      _showError('Une erreur s\'est produite : $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 60),
                Center(
                  child: Image.asset(
                    'lib/assets/images/logo.png',
                    height: 60, // Taille du logo
                  ),
                ),
                const SizedBox(height: 60),
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Bienvenue !',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          hintText: 'E-mail',
                          labelText: 'E-mail',
                          prefixIcon: const Icon(Icons.email),
                          labelStyle: const TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          hintText: 'Mot de passe',
                          labelText: 'Mot de passe',
                          prefixIcon: const Icon(Icons.lock),
                          labelStyle: const TextStyle(fontSize: 18),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.center,
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                          onPressed: login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 36),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Color(0xFFE01D5B),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Se connecter',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
