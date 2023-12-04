import 'package:flutter/material.dart';
import 'package:layout_tutorial/db.dart';
import 'package:layout_tutorial/utils.dart';

Future<void> showAddItemDialog(BuildContext context, DateTime selectedDate,
    Function refreshSuccessList) async {
  String title = '';
  String subtitle = '';
  DateTime? selectedDateForItem = selectedDate;
  final formKey = GlobalKey<FormState>();

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text('Add New Item'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: ListBody(
                  children: <Widget>[
                    TextFormField(
                      onChanged: (value) {
                        title = value;
                      },
                      decoration:
                          const InputDecoration(hintText: "Enter title"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      onChanged: (value) {
                        subtitle = value;
                      },
                      decoration:
                          const InputDecoration(hintText: "Enter subtitle"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a subtitle';
                        }
                        return null;
                      },
                    ),
                    ListTile(
                      title: Text(selectedDateForItem == null
                          ? 'No date selected'
                          : 'Selected date: ${formatDate(selectedDateForItem!, Localizations.localeOf(context).toString())}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDateForItem ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2025),
                        );
                        if (picked != null && picked != selectedDateForItem) {
                          setState(() {
                            selectedDateForItem = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Add'),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    if (title.isNotEmpty && subtitle.isNotEmpty) {
                      Success newSuccess = Success(
                          title: title,
                          subtitle: subtitle,
                          date: selectedDateForItem); // Use the selected date
                      await SuccessDatabaseService().insertSuccess(newSuccess);
                      refreshSuccessList();
                      Navigator.of(context).pop();
                    }
                  }
                },
              ),
            ],
          );
        },
      );
    },
  );
}
