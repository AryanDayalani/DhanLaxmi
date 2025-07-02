import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';

import '../db/db_helper.dart';
import '../models/expense_model.dart';
import '../theme/colors.dart';
import 'add_expense_screen.dart';
import 'edit_expense_screen.dart';

enum SortOption { dateNewest, dateOldest, amountHighest, amountLowest }

class ViewExpensesScreen extends StatefulWidget {
  const ViewExpensesScreen({super.key});

  @override
  State<ViewExpensesScreen> createState() => _ViewExpensesScreenState();
}

class _ViewExpensesScreenState extends State<ViewExpensesScreen> {
  late Future<List<Expense>> _expenseFuture;
  List<Expense> _allExpenses = [];
  String _searchQuery = '';
  final _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Food',
    'Bills',
    'Health',
    'Shopping',
    'Other',
  ];
  String _selectedCategory = 'All';
  SortOption _currentSortOption = SortOption.dateNewest;

  @override
  void initState() {
    super.initState();
    _refreshExpenses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- Core Logic ---
  List<Expense> _filteredExpenses() {
    return _allExpenses.where((e) {
      final lowerSearch = _searchQuery.toLowerCase();
      final matchesSearch =
          lowerSearch.isEmpty ||
          e.note.toLowerCase().contains(lowerSearch) ||
          e.category.toLowerCase().contains(lowerSearch);
      final matchesCategory =
          _selectedCategory == 'All' || e.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  IconData _getCategoryIcon(String categoryName) {
    const categoryIcons = {
      'All': Icons.all_inclusive_rounded,
      'Food': Icons.lunch_dining_rounded,
      'Bills': Icons.receipt_long_rounded,
      'Health': Icons.medical_services_rounded,
      'Shopping': Icons.shopping_bag_rounded,
      'Other': Icons.more_horiz_rounded,
    };
    return categoryIcons[categoryName] ?? Icons.question_mark_rounded;
  }

  // ############ THIS IS THE CORRECTED FUNCTION ############
  Map<DateTime, List<Expense>> _groupExpensesByDate(List<Expense> expenses) {
    final Map<DateTime, List<Expense>> grouped = {};
    for (var expense in expenses) {
      // Changed .y to .day to fix the crash
      final dateOnly = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      grouped.putIfAbsent(dateOnly, () => []).add(expense);
    }
    return grouped;
  }

  Map<String, double> _calculateSummaries(List<Expense> expenses) {
    final now = DateTime.now();
    double today = 0, week = 0, month = 0;
    for (var e in expenses) {
      if (e.date.year == now.year &&
          e.date.month == now.month &&
          e.date.day == now.day) {
        today += e.amount;
      }
      if (e.date.isAfter(now.subtract(Duration(days: now.weekday)))) {
        week += e.amount;
      }
      if (e.date.year == now.year && e.date.month == now.month) {
        month += e.amount;
      }
    }
    return {'Today': today, 'This Week': week, 'This Month': month};
  }

  void _refreshExpenses() {
    setState(() {
      _expenseFuture = DBHelper().fetchExpenses().then((data) {
        _allExpenses = data;
        return _allExpenses;
      });
    });
  }

  void _deleteExpense(int id) {
    DBHelper().deleteExpense(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text("Expense Deleted", style: GoogleFonts.poppins()),
      ),
    );
    _refreshExpenses();
  }

  void _navigateToEditScreen(Expense expense) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EditExpenseScreen(expense: expense)),
    );
    if (result == true) {
      _refreshExpenses();
    }
  }

  String _getSortLabel(SortOption option) {
    switch (option) {
      case SortOption.dateNewest:
        return 'Date: Newest First';
      case SortOption.dateOldest:
        return 'Date: Oldest First';
      case SortOption.amountHighest:
        return 'Amount: High to Low';
      case SortOption.amountLowest:
        return 'Amount: Low to High';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryDark,
      appBar: AppBar(
        backgroundColor: kPrimaryDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: kLightCream),
        title: Text(
          "Spending History",
          style: GoogleFonts.poppins(
            color: kMistyPink,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterControls(),
          Expanded(
            child: FutureBuilder<List<Expense>>(
              future: _expenseFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(
                    child: CircularProgressIndicator(color: kMistyPink),
                  );
                if (snapshot.hasError)
                  return Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                      style: GoogleFonts.poppins(color: kLightCream),
                    ),
                  );
                if (!snapshot.hasData || snapshot.data!.isEmpty)
                  return _buildEmptyState(context);

                final filteredList = _filteredExpenses();

                if (filteredList.isEmpty)
                  return Center(
                    child: Text(
                      "No expenses match your filters.",
                      style: GoogleFonts.poppins(
                        color: kLightCream,
                        fontSize: 16,
                      ),
                    ),
                  );

                // Sort the filtered list
                filteredList.sort((a, b) {
                  switch (_currentSortOption) {
                    case SortOption.dateOldest:
                      return a.date.compareTo(b.date);
                    case SortOption.amountHighest:
                      return b.amount.compareTo(a.amount);
                    case SortOption.amountLowest:
                      return a.amount.compareTo(b.amount);
                    case SortOption.dateNewest:
                    default:
                      return b.date.compareTo(a.date);
                  }
                });

                final summaries = _calculateSummaries(snapshot.data!);

                // --- UI ENHANCEMENT: Display differently based on sort type ---
                bool isSortingByDate =
                    _currentSortOption == SortOption.dateNewest ||
                    _currentSortOption == SortOption.dateOldest;

                if (isSortingByDate) {
                  // If sorting by date, show the grouped view
                  final groupedExpenses = _groupExpensesByDate(filteredList);
                  final sortedDates = groupedExpenses.keys.toList();

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: sortedDates.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) return _buildSummaryHeader(summaries);
                      final date = sortedDates[index - 1];
                      final expensesForDate = groupedExpenses[date]!;
                      return FadeInUp(
                        from: 20,
                        delay: Duration(milliseconds: 100 * (index - 1)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDateHeader(date),
                            ...expensesForDate.map(
                              (expense) => _buildDismissibleExpense(expense),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  // If sorting by amount, show a simple, flat list
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) return _buildSummaryHeader(summaries);
                      final expense = filteredList[index - 1];
                      return FadeInUp(
                        from: 20,
                        delay: Duration(milliseconds: 50 * (index - 1)),
                        child: _buildDismissibleExpense(expense),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // (All builder widgets below are unchanged and correct)
  Widget _buildFilterControls() {
    /* ... unchanged ... */
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            style: GoogleFonts.poppins(color: kLightCream),
            decoration: InputDecoration(
              hintText: 'Search by note or category...',
              hintStyle: GoogleFonts.poppins(
                color: kLightCream.withOpacity(0.5),
              ),
              prefixIcon: const Icon(Icons.search, color: kMistyPink, size: 20),
              suffixIcon:
                  _searchQuery.isNotEmpty
                      ? IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          color: kLightCream,
                          size: 20,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                      : null,
              filled: true,
              fillColor: kMistyPink.withOpacity(0.1),
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder:
                  (context, index) => _buildCategoryChip(_categories[index]),
            ),
          ),
          Align(alignment: Alignment.centerRight, child: _buildSortDropdown()),
        ],
      ),
    );
  }

  Widget _buildSortDropdown() {
    /* ... unchanged ... */
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: kMistyPink.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SortOption>(
          value: _currentSortOption,
          dropdownColor: kPrimaryDark.withBlue(80),
          icon: const Icon(Icons.sort_rounded, color: kMistyPink, size: 20),
          style: GoogleFonts.poppins(color: kLightCream, fontSize: 13),
          onChanged:
              (newValue) => setState(() => _currentSortOption = newValue!),
          items:
              SortOption.values.map((option) {
                return DropdownMenuItem<SortOption>(
                  value: option,
                  child: Text(_getSortLabel(option)),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    /* ... unchanged ... */
    final bool isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = category),
        child: Chip(
          avatar: Icon(
            _getCategoryIcon(category),
            size: 18,
            color: isSelected ? kPrimaryDark : kLightCream,
          ),
          label: Text(
            category,
            style: GoogleFonts.poppins(
              color: isSelected ? kPrimaryDark : kLightCream,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          backgroundColor:
              isSelected
                  ? kSoftGold.withAlpha(200)
                  : kMistyPink.withOpacity(0.1),
          side:
              isSelected
                  ? BorderSide(color: kSoftGold, width: 1.5)
                  : BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryHeader(Map<String, double> summaries) {
    /* ... unchanged ... */
    return FadeInDown(
      child: Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSummaryCard("Today", summaries['Today'] ?? 0),
            Expanded(
              child: _buildSummaryCard(
                "This Week",
                summaries['This Week'] ?? 0,
              ),
            ),
            Expanded(
              child: _buildSummaryCard(
                "This Month",
                summaries['This Month'] ?? 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount) {
    /* ... unchanged ... */
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: kMistyPink.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: kLightCream.withOpacity(0.8),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "₹${amount.toStringAsFixed(0)}",
            style: GoogleFonts.poppins(
              color: kSoftGold,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDismissibleExpense(Expense expense) {
    /* ... unchanged ... */
    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_forever_rounded,
          color: Colors.white,
          size: 30,
        ),
      ),
      confirmDismiss: (_) => _showDeleteConfirmationDialog(),
      onDismissed: (_) => _deleteExpense(expense.id!),
      child: _buildExpenseListItem(expense),
    );
  }

  Future<bool?> _showDeleteConfirmationDialog() {
    /* ... unchanged ... */
    return showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
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
              "Are you sure? This action cannot be undone.",
              style: GoogleFonts.poppins(color: kLightCream),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(
                  "Cancel",
                  style: GoogleFonts.poppins(color: kLightCream),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(
                  "Delete",
                  style: GoogleFonts.poppins(color: Colors.redAccent),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildExpenseListItem(Expense expense) {
    /* ... unchanged ... */
    return InkWell(
      onTap: () => _navigateToEditScreen(expense),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: kMistyPink.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: kSoftGold.withOpacity(0.2),
              foregroundColor: kSoftGold,
              child: Icon(_getCategoryIcon(expense.category)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.note.isNotEmpty ? expense.note : expense.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: kLightCream,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (expense.note.isNotEmpty)
                    Text(
                      expense.category,
                      style: GoogleFonts.poppins(
                        color: kLightCream.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              "₹${expense.amount.toStringAsFixed(0)}",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateHeader(DateTime date) {
    /* ... unchanged ... */
    String formattedDate;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    if (date == today)
      formattedDate = 'Today';
    else if (date == yesterday)
      formattedDate = 'Yesterday';
    else
      formattedDate = DateFormat('EEEE, d MMMM').format(date);
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0, left: 8.0),
      child: Text(
        formattedDate,
        style: GoogleFonts.poppins(
          color: kSoftGold,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    /* ... unchanged ... */
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeInDown(
              child: SvgPicture.asset(
                'assets/images/empty_state.svg',
                height: 150,
              ),
            ),
            const SizedBox(height: 30),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Text(
                "It's a little empty here...",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: kLightCream,
                ),
              ),
            ),
            const SizedBox(height: 10),
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: Text(
                "Add your first expense to see the magic happen!",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: kLightCream.withOpacity(0.8),
                ),
              ),
            ),
            const SizedBox(height: 40),
            FadeInUp(
              delay: const Duration(milliseconds: 600),
              child: ElevatedButton.icon(
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddExpenseScreen(),
                      ),
                    ).then((_) => _refreshExpenses()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kMistyPink,
                  foregroundColor: kPrimaryDark,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: const Icon(Icons.add_rounded),
                label: Text(
                  "Let's add one!",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
  