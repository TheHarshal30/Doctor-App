// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medigine/screens/login.dart';
import 'package:medigine/screens/navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash() async {
    // Wait for the splash screen duration (5 seconds in this case)
    await Future.delayed(Duration(seconds: 4));

    // Now check the login status
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      // User is logged in, navigate to the main page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NavPage()),
      );
    } else {
      // User is not logged in, navigate to the login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return EasySplashScreen(
      logoWidth: 50,
      logo: Image(
        image: AssetImage("assets/image.png"),
      ),
      title: Text.rich(
        TextSpan(
          text: 'Welcome to\n',
          style: GoogleFonts.exo2(fontSize: 18, fontWeight: FontWeight.bold),
          children: <TextSpan>[
            TextSpan(
              text: 'MEDIGENE CARE',
              style: GoogleFonts.exo2(
                fontSize: 25,
                fontWeight: FontWeight.w900,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.grey.shade400,
      showLoader: true,
      loadingText: Text(
        "Loading...",
        style: GoogleFonts.exo2(),
      ),
      durationInSeconds: 4, // Splash screen will last 5 seconds
    );
  }
}
