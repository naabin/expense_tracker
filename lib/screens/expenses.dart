import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_home/app_colors.dart';
import 'package:my_home/widgets/food_expense.dart';

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}

class Expenses extends StatefulWidget {
  Expenses({super.key, required this.recordedCategories});
  final List<String> recordedCategories;
  @override
  State<Expenses> createState() => _ExpensesState();
  List<Color> get availableColors => const <Color>[
        AppColors.contentColorPurple,
        AppColors.contentColorYellow,
        AppColors.contentColorBlue,
        AppColors.contentColorOrange,
        AppColors.contentColorPink,
        AppColors.contentColorRed,
      ];

  final Color barBackgroundColor = AppColors.contentColorWhite.withOpacity(0.3);
  final Color barColor = AppColors.contentColorWhite;
  final Color touchedBarColor = AppColors.contentColorGreen;
}

class _ExpensesState extends State<Expenses> {
  List<double> totalCategoryCost = [];
  @override
  void initState() {
    super.initState();
    getTotalForCategories();
  }

  Future<double?> getTotalAmount(
      String category, DocumentReference<Map<String, dynamic>> docRef) async {
    final amount = await docRef
        .collection(category)
        .where('expense_type', isEqualTo: category)
        .aggregate(sum('amount'))
        .get()
        .then(
          (_) => _.getSum('amount'),
        );
    return amount;
  }

  Future<void> getTotalForCategories() async {
    print(widget.recordedCategories);
    if (widget.recordedCategories.isEmpty) return;
    final currentUser = FirebaseAuth.instance.currentUser?.uid;
    final expensesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser)
        .collection('expenses')
        .doc(currentUser);
    for (final cat in widget.recordedCategories) {
      final amount = await getTotalAmount(cat, expensesRef);
      setState(() => totalCategoryCost = [...totalCategoryCost, amount!]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: context.canPop()
            ? IconButton(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.arrow_back_rounded),
              )
            : null,
        title: const Center(
          child: Text('Expenses'),
        ),
        backgroundColor: Theme.of(context).primaryColorDark,
      ),
      body: (totalCategoryCost.length == widget.recordedCategories.length &&
              widget.recordedCategories.isNotEmpty)
          ? Column(
              children: [
                AspectRatio(
                  aspectRatio: 1.6,
                  child: _mainBarChart,
                ),
                const Divider(
                  height: 2,
                ),
                Expanded(
                  flex: 1,
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 300,
                            childAspectRatio: 1,
                            mainAxisSpacing: 15,
                            crossAxisSpacing: 10),
                    itemCount: widget.recordedCategories.length,
                    itemBuilder: (context, index) {
                      final category = widget.recordedCategories[index];
                      return ExpenseWidget(
                        totalCost: totalCategoryCost[index],
                        category: category,
                      );
                    },
                  ),
                ),
              ],
            )
          : const Center(
              child: Text(
                'What have you spent on today',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
    );
  }

  LinearGradient get _barsGradient => const LinearGradient(colors: [
        AppColors.contentColorBlue,
        AppColors.contentColorCyan,
      ], begin: Alignment.bottomCenter, end: Alignment.topCenter);
  FlBorderData get _borderData => FlBorderData(show: false);

  List<BarChartGroupData> get _getGroupData {
    List<BarChartGroupData> groupData = [];
    for (int i = 0; i < totalCategoryCost.length; i++) {
      groupData.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              width: (totalCategoryCost.length * 10) % 31,
              toY: totalCategoryCost[i],
              gradient: _barsGradient,
            )
          ],
          showingTooltipIndicators: [0],
        ),
      );
    }
    return groupData;
  }

  BarChart get _mainBarChart {
    return BarChart(
      BarChartData(
        barTouchData: _barcTouchData,
        titlesData: _titlesData,
        borderData: _borderData,
        barGroups: _getGroupData,
        gridData: const FlGridData(show: false),
        alignment: BarChartAlignment.spaceAround,
        maxY: (totalCategoryCost.reduce(max)) + 100,
      ),
    );
  }

  FlTitlesData get _titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getTitles,
            reservedSize: 30,
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  BarTouchData get _barcTouchData => BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => Colors.transparent,
          tooltipPadding: EdgeInsets.zero,
          tooltipMargin: 8,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              rod.toY.round().toString(),
              const TextStyle(
                  color: AppColors.contentColorCyan,
                  fontWeight: FontWeight.bold),
            );
          },
        ),
      );

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
        color: Color.fromARGB(255, 4, 70, 74),
        fontWeight: FontWeight.bold,
        fontSize: 14);
    final index = value.toInt();
    String text = widget.recordedCategories.isNotEmpty
        ? widget.recordedCategories[index][0].toTitleCase()
        : index.toString();
    Text textWidget = Text(text, style: style);
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: textWidget,
    );
  }
}
