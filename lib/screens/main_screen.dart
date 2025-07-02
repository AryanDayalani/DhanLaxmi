import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/view_expenses_screen.dart';
import '../screens/add_expense_screen.dart';
import '../screens/insights_screen.dart'; // <-- Make sure this exists
import '../theme/colors.dart';

class MainScreen extends StatefulWidget {
  final int startIndex;

  const MainScreen({super.key, this.startIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  final List<Widget> _screens = [
    ViewExpensesScreen(),
    AddExpenseScreen(),
    InsightsScreen(), // Replaces Profile
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.startIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryDark,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: kPrimaryDark,
        selectedItemColor: kMistyPink,
        unselectedItemColor: kLightCream.withOpacity(0.6),
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.poppins(),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_rounded),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline_rounded),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_graph_rounded),
            label: 'Insights',
          ),
        ],
      ),
    );
  }
}
