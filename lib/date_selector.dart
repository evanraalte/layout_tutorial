import 'package:flutter/material.dart';
import 'package:layout_tutorial/utils.dart';

class DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const DateSelector(
      {super.key, required this.selectedDate, required this.onDateChanged});

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      onDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              onDateChanged(selectedDate.subtract(const Duration(days: 1))),
        ),
        TextButton(
          onPressed: () => _selectDate(context),
          child: Text(formatDate(selectedDate)),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () =>
              onDateChanged(selectedDate.add(const Duration(days: 1))),
        ),
      ],
    );
  }
}
