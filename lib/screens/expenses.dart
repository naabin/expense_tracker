import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_home/app_colors.dart';
import 'package:my_home/screens/add_expense.dart';
import 'package:my_home/widgets/food_expense.dart';

class Expenses extends StatefulWidget {
  Expenses({super.key});
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
  final Duration animDuration = const Duration(microseconds: 250);
  int touchedIndex = -1;
  bool isPlaying = false;
  List<String> recordedCategories = [];
  List<double> recordedToal = [];
  @override
  void initState() {
    super.initState();
    getCategories();
  }

  void getExpenseTotal(double amt) {
    setState(() => recordedToal = [...recordedToal, amt]);
  }

  Future<void> getCategories() async {
    final currentUser = FirebaseAuth.instance.currentUser?.uid;
    final expensesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser)
        .collection('expenses')
        .doc(currentUser);
    for (final categotry in ExpenseCategory.values) {
      final snap = await expensesRef.collection(categotry.name).get();
      if (snap.docs.isNotEmpty) {
        setState(
            () => recordedCategories = [...recordedCategories, categotry.name]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser?.uid;
    final expensesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser)
        .collection('expenses')
        .doc(currentUser);
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
      body: recordedCategories.isNotEmpty
          ? SafeArea(
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Cost',
                                  style: TextStyle(
                                      color: AppColors.contentColorGreen,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                const Text(
                                  'Gibberish',
                                  style: TextStyle(
                                      color: AppColors.contentColorGreen,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: BarChart(
                                      isPlaying ? mainBarData() : mainBarData(),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
                      itemCount: recordedCategories.length,
                      itemBuilder: (context, index) {
                        final category = recordedCategories[index];
                        return ExpenseWidget(
                            docRef: expensesRef,
                            category: category,
                            totalValue: getExpenseTotal);
                      },
                    ),
                  ),
                ],
              ),
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

  List<BarChartGroupData> getGroupData(
      {double width = 22, List<int> showToolTips = const []}) {
    List<BarChartGroupData> l = [];
    Color barColor = widget.barColor;
    for (int i = 0; i < recordedToal.length; i++) {
      bool isTouched = touchedIndex == i;
      l.add(
        BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: isTouched ? recordedToal[i] + 1 : recordedToal[i],
                color: isTouched ? widget.touchedBarColor : barColor,
                width: width,
                borderSide: isTouched
                    ? BorderSide(color: widget.touchedBarColor)
                    : const BorderSide(color: Colors.white, width: 0),
                backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: recordedToal[i],
                    color: widget.barBackgroundColor),
              )
            ],
            showingTooltipIndicators: showToolTips),
      );
    }
    return l;
  }

  BarChartData mainBarData() {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => Colors.blueGrey,
          tooltipHorizontalAlignment: FLHorizontalAlignment.right,
          tooltipMargin: -10,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            String xTitle = recordedCategories[groupIndex];
            return BarTooltipItem(
              '$xTitle\n',
              const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
              children: <TextSpan>[
                TextSpan(
                  text: (rod.toY - 1).toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
        touchCallback: (FlTouchEvent event, bartouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                bartouchResponse == null ||
                bartouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = bartouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getTitles,
            reservedSize: 38,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: false),
      barGroups: getGroupData(),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14);
    Text text = Text(recordedCategories[value.toInt()][0], style: style);
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: text,
    );
  }

  Future<dynamic> refreshState() async {
    setState(() {});
    await Future<dynamic>.delayed(
      animDuration + const Duration(microseconds: 50),
    );
    if (isPlaying) {
      await refreshState();
    }
  }
}
