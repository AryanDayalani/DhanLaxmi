import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';

import '../db/db_helper.dart'; // Ensure paths are correct
import '../models/expense_model.dart';
import '../theme/colors.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  late Future<List<Expense>> _expenseFuture;
  int _touchedIndex = -1; // For interactive chart

  // A beautiful, consistent color palette for our chart
  final List<Color> _chartColors = [
    kMistyPink,
    kSoftGold,
    const Color(0xFF86E3CE), // Soft Mint Green
    const Color(0xFFD0E6A5), // Pale Lime
    const Color(0xFFFFDD94), // Warm Peach
    const Color(0xFFFA897B), // Muted Coral
  ];

  @override
  void initState() {
    super.initState();
    _expenseFuture = DBHelper().fetchExpenses();
  }

  // Consistent Icon Helper to match other screens
  IconData _getCategoryIcon(String categoryName) {
    const Map<String, IconData> categoryIcons = {
      'Food': Icons.lunch_dining_rounded,
      'Bills': Icons.receipt_long_rounded,
      'Health': Icons.medical_services_rounded,
      'Shopping': Icons.shopping_bag_rounded,
      'Other': Icons.more_horiz_rounded,
    };
    return categoryIcons[categoryName] ?? Icons.question_mark_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryDark,
      appBar: AppBar(
        backgroundColor: kPrimaryDark,
        elevation: 0,
        title: Text(
          "Your Spending Story",
          style: GoogleFonts.poppins(
            color: kMistyPink,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: kLightCream),
      ),
      body: FutureBuilder<List<Expense>>(
        future: _expenseFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: kMistyPink),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: GoogleFonts.poppins(color: kLightCream),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No spending data yet!",
                style: GoogleFonts.poppins(color: kLightCream, fontSize: 18),
              ),
            );
          }

          // --- Data Processing for Insights ---
          final expenses = snapshot.data!;
          final categoryTotals = _calculateCategoryTotals(expenses);
          final totalSpending = categoryTotals.values.fold(
            0.0,
            (sum, amount) => sum + amount,
          );

          // ** THE CORRECTED LOGIC FOR TOP CATEGORY **
          // Safely handles the case where there are no expenses.
          final String topCategory =
              categoryTotals.entries.isEmpty
                  ? 'None'
                  : categoryTotals.entries
                      .reduce((a, b) => a.value > b.value ? a : b)
                      .key;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Key Summary Cards
                _buildSummaryCards(totalSpending, topCategory),

                const SizedBox(height: 30),

                // The Chart and Legend section
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: Text(
                    "Spending Breakdown",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kLightCream,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: _buildChartAndLegend(categoryTotals),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(double totalSpending, String topCategory) {
    return Row(
      children: [
        Expanded(
          child: FadeInDown(
            child: _buildInsightCard(
              title: "Total Spent This Month",
              value: "₹${totalSpending.toStringAsFixed(0)}",
              icon: Icons.account_balance_wallet_rounded,
              color: kSoftGold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FadeInDown(
            delay: const Duration(milliseconds: 200),
            child: _buildInsightCard(
              title: "Highest Spent This Month",
              value: topCategory,
              icon: _getCategoryIcon(topCategory),
              color: kMistyPink,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kMistyPink.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.poppins(color: kLightCream.withOpacity(0.8)),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildChartAndLegend(Map<String, double> categoryTotals) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kMistyPink.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // The Interactive Chart
          Expanded(
            flex: 2,
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          _touchedIndex = -1;
                          return;
                        }
                        _touchedIndex =
                            pieTouchResponse
                                .touchedSection!
                                .touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 4, // Increased space
                  centerSpaceRadius: 50, // This creates the donut
                  sections: _buildPieChartSections(categoryTotals),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          // The Legend
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(categoryTotals.length, (i) {
                return _buildIndicator(
                  color: _chartColors[i % _chartColors.length],
                  text: categoryTotals.keys.toList()[i],
                  isTouched: i == _touchedIndex,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, double> data) {
    // Sort entries by value to have a consistent color-to-category mapping
    final sortedEntries =
        data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    // Calculate the total for percentage calculation
    final totalValue = data.values.fold(0.0, (s, e) => s + e);

    return List.generate(data.length, (i) {
      final isTouched = i == _touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 70.0 : 60.0;
      final color = _chartColors[i % _chartColors.length];
      final entry = sortedEntries[i];

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${(entry.value / totalValue * 100).toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: kPrimaryDark,
          shadows: [const Shadow(color: Colors.black26, blurRadius: 2)],
        ),
      );
    });
  }

  Widget _buildIndicator({
    required Color color,
    required String text,
    required bool isTouched,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: <Widget>[
          Container(
            width: isTouched ? 18 : 14,
            height: isTouched ? 18 : 14,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: isTouched ? 16 : 14,
                fontWeight: isTouched ? FontWeight.bold : FontWeight.normal,
                color: kLightCream,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, double> _calculateCategoryTotals(List<Expense> expenses) {
    final Map<String, double> totals = {};
    for (var e in expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals;
  }
}
