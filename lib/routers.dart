import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_home/screens/add_expense.dart';
import 'package:my_home/screens/expenses.dart';
import 'package:my_home/screens/home.dart';
import 'package:my_home/widgets/loading.dart';

final GoRouter goRouterConfig = GoRouter(
  routes: [
    GoRoute(
        path: '/',
        builder: (context, _) {
          return StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: ((context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingWidget();
              }
              final user = snapshot.data as User;
              return HomeScreen(user: user);
            }),
          );
        }),
    GoRoute(path: '/add-expense', builder: (context, _) => const AddExpense()),
    GoRoute(path: '/expenses', builder: (context, _) => Expenses()),
  ],
);
