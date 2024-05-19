import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_home/widgets/loading.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});
  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser?.uid;
    final expensesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser)
        .collection('expenses')
        .doc(currentUser);
    final foodExpenses = expensesRef.collection('food');
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
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: StreamBuilder(
        stream: foodExpenses.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }
          if (snapshot.connectionState == ConnectionState.done &&
              !snapshot.hasData) {
            return const Center(
              child: Text(
                  'It looks like you do not have any expenses recorded. Get started now.'),
            );
          }
          if (snapshot.connectionState == ConnectionState.none ||
              snapshot.error != null) {
            return const Center(
              child: Text('Problem occured when loading data'),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final expense = snapshot.data!.docs[index];
              return Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Flexible(
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          // height: 50,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              )),
                          child: Center(
                            child: getTotalFoodAmount(),
                          ),
                        ),

                        // flex: 1,
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              expense['expense_type'],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget getTotalFoodAmount() {
    final currentUser = FirebaseAuth.instance.currentUser?.uid;
    final expensesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser)
        .collection('expenses')
        .doc(currentUser)
        .collection('food')
        .where('expense_type', isEqualTo: 'food')
        .aggregate(sum('amount'))
        .get()
        .then((_) => _.getSum('amount'));
    return FutureBuilder(
        future: expensesRef,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }
          if (!snapshot.hasData) {
            return const Center(
              child: Text('Something Went wrong'),
            );
          }
          return Text(
            snapshot.data.toString(),
            style: const TextStyle(fontSize: 48, color: Colors.white),
          );
        });
  }
}
