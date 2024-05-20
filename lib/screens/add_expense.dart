import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum ExpenseCategory {
  food,
  health,
  transport,
  mortgage,
  phone,
  study,
  miscellaneous,
  creditcard,
  debt,
  travel,
  holiday,
  other,
}

enum ExpenseFrequency { daily, weekly, fortnightly, mothly, yearly }

class AddExpense extends StatefulWidget {
  const AddExpense({super.key});
  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  var submitting = false;
  ExpenseCategory? category;
  ExpenseFrequency? expenseFrequency;
  var recurring = false;
  bool isValid = false;
  void _save() async {
    final valid = _formKey.currentState?.validate();
    if (!valid!) return;
    setState(() => isValid = true);
    setState(() => submitting = true);
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('expenses')
            .doc(userId)
            .collection(category.toString().split('.').last)
            .add({
          'expense_type': category.toString().split('.').last,
          'amount': int.parse(_amountController.text),
          'recurring': recurring,
          'recur_freq': expenseFrequency.toString().split('.').last,
          'creator': userId,
          'created_on': FieldValue.serverTimestamp()
        });
      } on FirebaseException catch (e) {
        if (mounted) {
          setState(() => submitting = false);
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                child: Text(e.message ?? 'An error occured'),
              ),
            ),
          );
        }
      } finally {
        setState(() => submitting = false);
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expense added.'),
            ),
          );
        }
        //This may change in the future
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        title: const Center(
          child: Text('Add Expense'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _save,
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        int.parse(value) < 0) {
                      return 'Positive amount is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<ExpenseCategory>(
                        onChanged: (value) {
                          category = value;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: getCategoryDropdowns(),
                        validator: (value) {
                          if (value == null) {
                            return 'Choose in which category it fall into';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                SwitchListTile(
                  title: const Text('Recurring cost'),
                  subtitle: const Text('Is it going to repeat?'),
                  value: recurring,
                  activeColor: Colors.red,
                  onChanged: (bool val) {
                    setState(() => recurring = val);
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                recurring
                    ? Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<ExpenseFrequency>(
                              value: ExpenseFrequency.weekly,
                              onChanged: (value) {
                                expenseFrequency = value;
                              },
                              decoration: const InputDecoration(
                                labelText: 'How Often',
                                border: OutlineInputBorder(),
                              ),
                              items: getReccuringDropDowns(),
                              validator: (value) {
                                if (value == null) {
                                  return 'choose how often do you make this expenditure';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      )
                    : const SizedBox(
                        height: 10,
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<ExpenseCategory>> getCategoryDropdowns() {
    List<DropdownMenuItem<ExpenseCategory>> dropDowns =
        <DropdownMenuItem<ExpenseCategory>>[];
    for (final expense in ExpenseCategory.values) {
      final wi = DropdownMenuItem<ExpenseCategory>(
          value: expense, child: Text(expense.name.toUpperCase()));
      dropDowns.add(wi);
    }
    return dropDowns;
  }

  List<DropdownMenuItem<ExpenseFrequency>> getReccuringDropDowns() {
    List<DropdownMenuItem<ExpenseFrequency>> dropDowns =
        <DropdownMenuItem<ExpenseFrequency>>[];
    for (final freq in ExpenseFrequency.values) {
      final wi = DropdownMenuItem<ExpenseFrequency>(
          value: freq, child: Text(freq.name.toUpperCase()));
      dropDowns.add(wi);
    }
    return dropDowns;
  }
}
