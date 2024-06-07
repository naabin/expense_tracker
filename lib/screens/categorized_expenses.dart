import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:my_home/widgets/loading.dart';

class CategorizedExpenes extends StatefulWidget {
  const CategorizedExpenes({super.key, required this.category});
  final String category;
  @override
  State<CategorizedExpenes> createState() => _CategorizedExpensesState();
}

class _CategorizedExpensesState extends State<CategorizedExpenes> {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser?.uid;
    final expensesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser)
        .collection('expenses')
        .doc(currentUser);
    var expnesesSnapshots = expensesRef.collection(widget.category).snapshots();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Center(child: Text(widget.category.toUpperCase())),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: StreamBuilder(
        stream: expnesesSnapshots,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var expense = snapshot.data!.docs[index];
              var formatter = DateFormat(DateFormat.ABBR_MONTH_WEEKDAY_DAY);
              var date = (expense['created_on'] as Timestamp).toDate();
              var formatted = formatter.format(date);
              return ListTile(
                title: Text(formatted),
                leading: const Icon(Icons.repeat_on_sharp),
                trailing: Text(expense['amount'].toString()),
              );
            },
          );
        },
      ),
    );
  }
}
