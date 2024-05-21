import 'package:flutter/material.dart';

class ExpenseWidget extends StatefulWidget {
  const ExpenseWidget({
    super.key,
    required this.category,
    required this.totalCost,
  });
  final String category;
  final double totalCost;

  @override
  State<ExpenseWidget> createState() => _FoodExpenseWidget();
}

class _FoodExpenseWidget extends State<ExpenseWidget> {
  @override
  void initState() {
    super.initState();
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
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 4 - 50,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    "\$${(widget.totalCost).toString()}",
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
    );
  }
}
