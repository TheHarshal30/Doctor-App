// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medigine/screens/navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  Future<void> _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // If authentication is successful
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      // Navigate to the main page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NavPage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          _errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          _errorMessage = 'Wrong password provided.';
        } else {
          _errorMessage = 'An error occurred. Please try again.';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var headings1 = MediaQuery.of(context).size.height / 40;
    var headings2 = MediaQuery.of(context).size.height / 50;
    var headings3 = MediaQuery.of(context).size.height / 60;
    var headings4 = MediaQuery.of(context).size.height / 80;
    var headings5 = MediaQuery.of(context).size.height / 90;

    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Container(
                width: MediaQuery.of(context).size.width / 6,
                child: Column(
                  children: [
                    Image(
                      image: AssetImage("assets/image.png"),
                      height: MediaQuery.of(context).size.height / 15,
                      width: MediaQuery.of(context).size.width / 30,
                    ),
                    Text.rich(
                      TextSpan(
                        text: 'Welcome to\n',
                        style: GoogleFonts.exo2(
                            fontSize: headings2, fontWeight: FontWeight.bold),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'MEDIGENE CARE',
                            style: GoogleFonts.exo2(
                              fontSize: headings1,
                              fontWeight: FontWeight.w900,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 20,
                    ),
                    TextField(
                      controller: _emailController,
                      style: GoogleFonts.exo2(
                          fontSize: headings3, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(labelText: 'Email'),
                    ),
                    TextField(
                      style: GoogleFonts.exo2(
                          fontSize: headings3, fontWeight: FontWeight.w600),
                      controller: _passwordController,
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    if (_errorMessage.isNotEmpty) ...[
                      SizedBox(height: MediaQuery.of(context).size.height / 40),
                      Text(
                        _errorMessage,
                        style:
                            TextStyle(color: Colors.red, fontSize: headings4),
                      ),
                    ],
                    SizedBox(height: MediaQuery.of(context).size.height / 15),
                    ElevatedButton(
                      onPressed: _login,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Login',
                          style: GoogleFonts.exo2(fontSize: headings3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
