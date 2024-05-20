import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ExpenseWidget extends StatefulWidget {
  const ExpenseWidget(
      {super.key,
      required this.docRef,
      required this.category,
      required this.totalValue});
  final String category;
  final DocumentReference<Map<String, dynamic>> docRef;
  final Function(double) totalValue;
  @override
  State<ExpenseWidget> createState() => _FoodExpenseWidget();
}

class _FoodExpenseWidget extends State<ExpenseWidget> {
  double? accumulatedExpense;
  @override
  void initState() {
    super.initState();
    getTotalAmount();
  }

  Future<void> getTotalAmount() async {
    final category = widget.category;
    final totalExpense = await widget.docRef
        .collection(category)
        .where('expense_type', isEqualTo: category)
        .aggregate(sum('amount'))
        .get()
        .then((_) => _.getSum('amount'));
    setState(() => accumulatedExpense = totalExpense);
    widget.totalValue(accumulatedExpense ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Card(
        margin: const EdgeInsets.only(left: 8, right: 8, top: 4),
        color: Theme.of(context).primaryColorDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.red.withOpacity(0.5),
          child: Ink(
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / 4 - 50,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Text(
                        "\$${(accumulatedExpense ?? 0).toString()}",
                        style: const TextStyle(
                            fontSize: 48,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const Divider(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.category.toUpperCase(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
