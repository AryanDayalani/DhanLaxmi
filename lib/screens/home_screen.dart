import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

import '../theme/colors.dart';
import 'add_expense_screen.dart';
import 'view_expenses_screen.dart';
import 'insights_screen.dart'; // <-- NEW: Import Insights Screen

class CuteHomeScreen extends StatefulWidget {
  const CuteHomeScreen({super.key});

  @override
  State<CuteHomeScreen> createState() => _CuteHomeScreenState();
}

class _CuteHomeScreenState extends State<CuteHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Decorative Background
          Positioned(
            top: -100,
            left: -100,
            child: CircleBlob(color: kMistyPink.withOpacity(0.1), size: 300),
          ),
          Positioned(
            bottom: -150,
            right: -120,
            child: CircleBlob(color: kSoftGold.withOpacity(0.1), size: 400),
          ),

          // Main Content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // App Title
                    FadeInDown(
                      duration: const Duration(milliseconds: 800),
                      child: Text(
                        "DhanLaxmi",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Floating Piggy Bank
                    AnimatedBuilder(
                      animation: _floatingAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatingAnimation.value),
                          child: child,
                        );
                      },
                      child: SvgPicture.asset(
                        'assets/images/piggy_bank.svg',
                        height: 150,
                        placeholderBuilder: (context) => Icon(
                          Icons.savings,
                          size: 150,
                          color: kMistyPink,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Greeting
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 200),
                      child: Text(
                        "Welcome Mom 💖",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtext
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 400),
                      child: Text(
                        "Let's make managing money\nfeel like a breeze!",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // View My Expenses
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 600),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ViewExpensesScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.list_alt_rounded),
                        label: Text(
                          "View My Expenses",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kMistyPink,
                          foregroundColor: kPrimaryDark,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // View Insights (NEW)
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 700),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const InsightsScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.pie_chart_outline),
                        label: Text(
                          "View Insights",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kSoftGold,
                          foregroundColor: kPrimaryDark,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 3),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // Floating Add Expense Button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FadeInUp(
        delay: const Duration(milliseconds: 800),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
            );
          },
          backgroundColor: kMistyPink,
          foregroundColor: kPrimaryDark,
          icon: const Icon(Icons.add, size: 28),
          label: Text(
            "Add Expense",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class CircleBlob extends StatelessWidget {
  final Color color;
  final double size;

  const CircleBlob({super.key, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
