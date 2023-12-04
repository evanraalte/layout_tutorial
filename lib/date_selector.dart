import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  String _formatDate(DateTime date, String locale) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(const Duration(days: 1));
    DateTime tomorrow = today.add(const Duration(days: 1));

    if (date == today) {
      return 'Today'; // or use a localized string
    } else if (date == yesterday) {
      return 'Yesterday'; // or use a localized string
    } else if (date == tomorrow) {
      return 'Tomorrow'; // or use a localized string
    } else {
      return DateFormat('dd-MM-yyyy', locale).format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    String locale = Localizations.localeOf(context).toString();
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
          child: Text(_formatDate(selectedDate, locale)),
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
