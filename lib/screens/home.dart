import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_home/screens/add_expense.dart';
import 'package:my_home/screens/expenses.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.user});
  final User user;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPageIndex = 0;
  List<Widget> pageList = [Expenses(), const AddExpense()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentPageIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on_outlined),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_alert_outlined),
            label: 'Add expense',
          )
        ],
        selectedIconTheme: Theme.of(context).iconTheme,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              context.go('/add-expense');
              break;
          }
        },
      ),
      body: pageList.elementAt(currentPageIndex),
    );
  }
}
