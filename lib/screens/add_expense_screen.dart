import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart'; // Add this for date formatting. Run 'flutter pub add intl'
import '../models/expense_model.dart'; // Import your Expense model
import '../db/db_helper.dart';
import '../theme/colors.dart';
import 'view_expenses_screen.dart';
import 'main_screen.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  // --- UI/UX ENHANCEMENT: Category Data with Icons ---
  // A map is better here to associate an icon with each category string.
  final Map<String, IconData> _categories = {
    'Food': Icons.lunch_dining_rounded,
    'Bills': Icons.receipt_long_rounded,
    'Health': Icons.medical_services_rounded,
    'Shopping': Icons.shopping_bag_rounded, // Added more for variety
    'Other': Icons.more_horiz_rounded,
  };

  // Keep track of the selected category and date
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // --- UI/UX ENHANCEMENT: Date Picker Function ---
  // A dedicated function to show the date picker.
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      // Theming the date picker to match our app
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: kPrimaryDark, // header background color
              onPrimary: kMistyPink, // header text color
              onSurface: kPrimaryDark, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: kPrimaryDark, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'New Expense',
          style: GoogleFonts.poppins(
            color: kMistyPink,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: kLightCream),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // --- UI/UX ENHANCEMENT: Main Amount Input ---
              // This is now the hero element. Big, bold, and clear.
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: Center(
                  child: TextFormField(
                    controller: _amountController,
                    textAlign: TextAlign.center,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: GoogleFonts.poppins(
                      color: kSoftGold,
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      // We use 'collapsed' to have a clean, borderless input
                      border: InputBorder.none,
                      hintText: "₹0",
                      hintStyle: GoogleFonts.poppins(
                        color: kSoftGold.withOpacity(0.4),
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter an amount";
                      }
                      if (double.tryParse(value) == null) {
                        return "Please enter a valid number";
                      }
                      return null;
                    },
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // --- UI/UX ENHANCEMENT: Visual Category Selector ---
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 200),
                child: Text(
                  "Category",
                  style: GoogleFonts.poppins(color: kLightCream, fontSize: 18),
                ),
              ),
              const SizedBox(height: 15),
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 300),
                child: _buildCategorySelector(),
              ),

              const SizedBox(height: 30),

              // --- UI/UX ENHANCEMENT: Grouped Date and Note fields ---
              // Grouping related items in a decorated container makes the form cleaner.
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 400),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kMistyPink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      // Date Field
                      _buildDateSelector(),
                      const Divider(color: kMistyPink, height: 20),
                      // Note Field
                      _buildNoteField(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // --- UI/UX ENHANCEMENT: Animated, more prominent Save button ---
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 500),
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: _saveExpense,
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
                      elevation: 8,
                      shadowColor: kMistyPink.withOpacity(0.5),
                    ),
                    icon: const Icon(Icons.check_circle_outline, size: 24),
                    label: Text(
                      "Save Expense",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 60, // A fixed height for the horizontal list
      child: ListView(
        scrollDirection: Axis.horizontal,
        children:
            _categories.entries.map((entry) {
              final isSelected = _selectedCategory == entry.key;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = entry.key;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? kSoftGold : kMistyPink.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30),
                    border:
                        isSelected
                            ? Border.all(color: kLightCream, width: 2)
                            : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        entry.value,
                        color: isSelected ? kPrimaryDark : kLightCream,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry.key,
                        style: GoogleFonts.poppins(
                          color: isSelected ? kPrimaryDark : kLightCream,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today_rounded,
            color: kLightCream,
            size: 24,
          ),
          const SizedBox(width: 16),
          Text(
            DateFormat(
              'EEEE, MMMM d',
            ).format(_selectedDate), // Example: "Tuesday, July 23"
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
          ),
          const Spacer(),
          const Icon(Icons.arrow_drop_down, color: kLightCream),
        ],
      ),
    );
  }

  Widget _buildNoteField() {
    return TextFormField(
      controller: _noteController,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        icon: const Icon(Icons.notes_rounded, color: kLightCream),
        border: InputBorder.none,
        hintText: "Add a note (optional)",
        hintStyle: GoogleFonts.poppins(color: kLightCream.withOpacity(0.5)),
      ),
    );
  }

  void _saveExpense() {
    // Validate that a category has been selected
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            "Please select a category!",
            style: GoogleFonts.poppins(),
          ),
        ),
      );
      return;
    }

    // Validate the amount field
    if (_formKey.currentState!.validate()) {
      // --- THIS IS THE FIX ---
      // We create the Expense object by passing the _selectedDate variable DIRECTLY.
      // We DO NOT call .toIso8601String() here anymore.
      final newExpense = Expense(
        amount: double.parse(_amountController.text),
        category: _selectedCategory!,
        note: _noteController.text,
        date:
            _selectedDate, // <-- The Corrected Line! Pass the DateTime object.
      );

      // Now, you pass this object to your database helper.
      // The `toMap()` method inside the Expense model will be called by your DB helper,
      // and it will automatically convert the DateTime to a string for storage.
      DBHelper().insertExpense(
        newExpense,
      ); // Make sure you have an insert method like this.

      // --- GOOD UX: Confirmation Feedback ---
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: kSoftGold,
          content: Text(
            "Expense Added! ✨",
            style: GoogleFonts.poppins(color: kPrimaryDark),
          ),
        ),
      );
      // Go back to the previous screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen(startIndex: 0)),
        (route) => false,
      );
    }
  }
}
