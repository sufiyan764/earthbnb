import 'package:flutter/material.dart';

class FormattedDateWidget extends StatelessWidget {
  final DateTime? date;
  final TextStyle? style;

  const FormattedDateWidget({
    Key? key,
    required this.date,
    this.style,
  }) : super(key: key);

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return "${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatDate(date),
      style: style ?? DefaultTextStyle.of(context).style,
    );
  }
}
