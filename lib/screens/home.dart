import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_home/screens/add_expense.dart';
import 'package:my_home/screens/expenses.dart';
import 'package:my_home/widgets/loading.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.user});
  final User user;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    getCategories();
  }

  Future<List<String>> getCategories() async {
    List<String> data = [];
    final currentUser = FirebaseAuth.instance.currentUser?.uid;
    final expensesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser)
        .collection('expenses')
        .doc(currentUser);
    for (final categotry in ExpenseCategory.values) {
      final snap = await expensesRef.collection(categotry.name).get();
      if (snap.docs.isNotEmpty) {
        data.add(categotry.name);
      }
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    List<String> recordedCategories = [];
    List<Widget> pageList = [
      Expenses(
        recordedCategories: recordedCategories,
      ),
      const AddExpense()
    ];
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
                context.go('/expenses', extra: recordedCategories);
                break;
              case 1:
                context.go('/add-expense');
                break;
            }
          },
        ),
        body: FutureBuilder(
          future: getCategories(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingWidget();
            }
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              recordedCategories = snapshot.data!;
              return Expenses(recordedCategories: recordedCategories);
            }
            return const Center(
              child: Text('Nothing here'),
            );
          },
        ));
  }
}
