import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/colors.dart';
import 'screens/main_screen.dart';
import 'screens/greeting_screen.dart';

void main() {
  runApp(const DhanLaxmiApp());
}

class DhanLaxmiApp extends StatelessWidget {
  const DhanLaxmiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DhanLaxmi',
      debugShowCheckedModeBanner: false,
      theme: _buildThemeData(),
      home: const GreetingScreen(), // Directly starts with the tab bar
    );
  }

  ThemeData _buildThemeData() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: kPrimaryDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kMistyPink,
        primary: kMistyPink,
        secondary: kSoftGold,
        brightness: Brightness.dark,
      ),
      textTheme: TextTheme(
        titleLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: kLightCream,
          letterSpacing: 1.2,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 18,
          color: kLightCream.withOpacity(0.8),
        ),
        headlineSmall: GoogleFonts.pacifico(fontSize: 24, color: kMistyPink),
      ),
    );
  }
}
