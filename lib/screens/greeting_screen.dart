import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'view_expenses_screen.dart';
import '../theme/colors.dart';
import 'main_screen.dart';

class GreetingScreen extends StatelessWidget {
  const GreetingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryDark,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome Mom! 💖",
                style: GoogleFonts.pacifico(fontSize: 34, color: kMistyPink),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                "Hope you’re having a lovely day.\nLet’s check your finances!",
                style: GoogleFonts.poppins(fontSize: 18, color: kLightCream),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const MainScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kMistyPink,
                  foregroundColor: kPrimaryDark,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "Take me there →",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
