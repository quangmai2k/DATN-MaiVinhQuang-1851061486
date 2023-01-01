import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerInTable1 extends StatefulWidget {
  String? dateDisplay;
  Function function;
  DatePickerInTable1({Key? key, this.dateDisplay, required this.function}) : super(key: key);

  @override
  State<DatePickerInTable1> createState() => _DatePickerTableInState1();
}

class _DatePickerTableInState1 extends State<DatePickerInTable1> {
  String? dateDisplay;
  DateTime selectedDate = DateTime.now();
  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2040),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        dateDisplay = DateFormat("dd-MM-yyyy").format(selectedDate.toLocal());
        widget.function(dateDisplay!);
      });
  }

  @override
  // ignore: must_call_super
  void initState() {
    if (widget.dateDisplay != null) dateDisplay = widget.dateDisplay!;
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.dateDisplay != null) dateDisplay = widget.dateDisplay!;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SelectableText(dateDisplay ?? 'Chọn ngày', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        SizedBox(height: 20.0),
        IconButton(onPressed: () => _selectDate(context), icon: Icon(Icons.date_range), color: Colors.blue[400]),
      ],
    );
  }
}
