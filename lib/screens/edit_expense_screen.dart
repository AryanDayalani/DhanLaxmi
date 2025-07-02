import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';

import '../models/expense_model.dart';
import '../db/db_helper.dart';
import '../theme/colors.dart';

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;

  const EditExpenseScreen({super.key, required this.expense});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late String _selectedCategory;
  late DateTime _selectedDate;

  // --- UI ENHANCEMENT: Use the same icon-based category map as AddExpenseScreen ---
  final Map<String, IconData> _categories = {
    'Food': Icons.lunch_dining_rounded,
    'Bills': Icons.receipt_long_rounded,
    'Health': Icons.medical_services_rounded,
    'Shopping': Icons.shopping_bag_rounded,
    'Other': Icons.more_horiz_rounded,
  };

  @override
  void initState() {
    super.initState();
    // Initialize state with the expense data passed to the screen
    _amountController = TextEditingController(
      text: widget.expense.amount.toStringAsFixed(0),
    );
    _noteController = TextEditingController(text: widget.expense.note);
    _selectedCategory = widget.expense.category;
    _selectedDate = widget.expense.date;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // --- Date Picker with our custom theme ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: kPrimaryDark,
              onPrimary: kMistyPink,
              onSurface: kPrimaryDark,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: kPrimaryDark),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: kLightCream),
        title: Text(
          "Edit Expense",
          style: GoogleFonts.poppins(
            color: kMistyPink,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        // --- UI ENHANCEMENT: Add a Delete Action in the AppBar ---
        actions: [
          IconButton(
            onPressed: _showDeleteConfirmationDialog,
            icon: const Icon(Icons.delete_forever_rounded),
            tooltip: "Delete Expense",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          // --- UI ENHANCEMENT: Mirroring the 'Add Expense' layout for consistency ---
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Main Amount Input (just like Add Screen)
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
                      border: InputBorder.none,
                      hintText: "₹0",
                      hintStyle: GoogleFonts.poppins(
                        color: kSoftGold.withOpacity(0.4),
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    validator:
                        (v) =>
                            v == null || v.isEmpty ? "Enter an amount" : null,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Visual Category Selector (just like Add Screen)
              FadeInUp(
                child: Text(
                  "Category",
                  style: GoogleFonts.poppins(color: kLightCream, fontSize: 18),
                ),
              ),
              const SizedBox(height: 15),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: _buildCategorySelector(),
              ),
              const SizedBox(height: 30),

              // Grouped Date and Note fields (just like Add Screen)
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kMistyPink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildDateSelector(),
                      const Divider(color: kMistyPink, height: 20),
                      _buildNoteField(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 50),

              // Prominent Save Button (just like Add Screen)
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: _saveChanges,
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
                      "Save Changes",
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

  // --- These builder methods are copied from AddExpenseScreen for UI consistency ---

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children:
            _categories.entries.map((entry) {
              final isSelected = _selectedCategory == entry.key;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = entry.key),
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
            DateFormat('EEEE, MMMM d').format(_selectedDate),
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

  // --- Core Logic Methods for Saving and Deleting ---

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final updatedExpense = Expense(
        id: widget.expense.id,
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        note: _noteController.text,
        date: _selectedDate,
      );
      await DBHelper().updateExpense(updatedExpense);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: kSoftGold,
          content: Text(
            "Changes Saved! ✨",
            style: GoogleFonts.poppins(color: kPrimaryDark),
          ),
        ),
      );
      Navigator.of(context).pop(true); // Return 'true' to signal a refresh
    }
  }

  void _deleteExpense() async {
    await DBHelper().deleteExpense(widget.expense.id!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text("Expense Deleted", style: GoogleFonts.poppins()),
      ),
    );
    Navigator.of(context).pop(true); // Return 'true' to signal a refresh
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: kPrimaryDark.withBlue(60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Delete Expense?",
            style: GoogleFonts.poppins(
              color: kMistyPink,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "This action cannot be undone. Are you sure you want to delete this expense?",
            style: GoogleFonts.poppins(color: kLightCream),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(color: kLightCream),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
                _deleteExpense(); // Perform the delete action
              },
              child: Text(
                "Delete",
                style: GoogleFonts.poppins(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }
}
