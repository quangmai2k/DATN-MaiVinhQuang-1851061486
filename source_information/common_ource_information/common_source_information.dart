import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/api.dart';
import 'package:gentelella_flutter/model/type.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';

import '../../../../common/style.dart';
import '../../../../common/toast.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/model.dart';


//Dropdow
class DropdowSearchWidget extends StatefulWidget {
  final Map<int, String>? optionList;
  final Function function;
  final int? locationOptions; //VỊ trí được lựa chọn
  final String? hintex;
  final double? heightBox;
  const DropdowSearchWidget({Key? key, this.optionList, required this.function, this.locationOptions, required this.hintex, this.heightBox})
      : super(key: key);

  @override
  State<DropdowSearchWidget> createState() => _DropdowSearchWidgetState();
}

class _DropdowSearchWidgetState extends State<DropdowSearchWidget> {
  final TextEditingController textEditingController = TextEditingController();
  // Map<int, String> optionListDegree = {0: "Tất cả"};
  String? selectedDropdow;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Expanded(flex: 2, child: Text('Trạng thái TTS', style: titleWidgetBox)),
          Expanded(
            // flex: 5,
            child: Container(
              color: Colors.white,
              // width: MediaQuery.of(context).size.width * 0.20,
              // decoration: InputDecoration(
              //   // hintText: "Mô tả bằng cấp",
              //   border: OutlineInputBorder(
              //     borderSide: BorderSide.none,
              //   ),
              // ),
              height: (widget.heightBox == null) ? 40 : widget.heightBox,
              child: DropdownButtonHideUnderline(
                child: DropdownButton2(
                  isExpanded: true,
                  searchController: textEditingController,
                  dropdownMaxHeight: 250,
                  hint: Text(
                      '${widget.optionList![widget.locationOptions] == null ? "${widget.hintex}" : widget.optionList![widget.locationOptions]}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  items: widget.optionList!.entries
                      .map((item) => DropdownMenuItem<String>(value: item.key.toString(), child: Text(item.value)))
                      .toList(),
                  value: selectedDropdow != "" ? selectedDropdow : null,
                  onChanged: (value) {
                    setState(() {
                      selectedDropdow = value as String;
                      widget.function(int.tryParse(selectedDropdow.toString()) ?? null);
                    });
                  },
                  searchMatchFn: (item, searchValue) {
                    return (item.child.toString().contains(searchValue));
                  },
                  // searchInnerWidget: Padding(
                  //   padding: const EdgeInsets.only(
                  //       top: 20, bottom: 20, right: 20, left: 20),
                  //   child: TextFormField(
                  //     controller: textEditingController,
                  //     decoration: InputDecoration(
                  //       isDense: true,
                  //       contentPadding: const EdgeInsets.symmetric(
                  //           horizontal: 10, vertical: 8),
                  //       hintText: 'Tìm kiếm....',
                  //       hintStyle: const TextStyle(fontSize: 12),
                  //       border: OutlineInputBorder(
                  //           borderRadius: BorderRadius.circular(8)),
                  //     ),
                  //   ),
                  // ),
                  buttonHeight: 40,
                  itemHeight: 40,
                  dropdownDecoration: BoxDecoration(border: Border.all(color: const Color.fromRGBO(216, 218, 229, 1))),
                  buttonDecoration: BoxDecoration(border: Border.all(width: 0.5, style: BorderStyle.solid)),
                  buttonElevation: 0,
                  buttonPadding: const EdgeInsets.only(left: 14, right: 14),
                  itemPadding: const EdgeInsets.only(left: 14, right: 14),
                  dropdownElevation: 5,
                  focusColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --CheckBox v2--
// ignore: must_be_immutable
class CheckBoxWidget extends StatefulWidget {
  final List<Widget>? widgetTitle;
  Function? functionCheckBox;
  final bool? isChecked;
  CheckBoxWidget({
    Key? key,
    this.widgetTitle,
    this.functionCheckBox,
    this.isChecked,
  }) : super(key: key);
  @override
  State<CheckBoxWidget> createState() => _CheckBoxWidgetState();
}

class _CheckBoxWidgetState extends State<CheckBoxWidget> {
  bool isChecked = false;
  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          checkColor: Colors.white,
          fillColor: MaterialStateProperty.resolveWith(getColor),
          value: widget.isChecked,
          onChanged: (bool? value) {
            setState(() {
              widget.functionCheckBox!(value);
              // isChecked = value!;
            });
          },
        ),
        SizedBox(
          width: 3,
        ),
        Row(
          children: widget.widgetTitle!,
        )
      ],
    );
  }
}

//Xóa 1 hàng trong bảng phần form
class DeleteTableForm extends StatefulWidget {
  final String apiDelete;

  const DeleteTableForm({Key? key, required this.apiDelete}) : super(key: key);

  @override
  State<DeleteTableForm> createState() => _DeleteTableFormState();
}

class _DeleteTableFormState extends State<DeleteTableForm> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Đồng ý xóa ?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Không'),
          style: ElevatedButton.styleFrom(primary: colorOrange, onPrimary: colorWhite, minimumSize: Size(80, 40)),
        ),
        TextButton(
          onPressed: () async {
            var response = await httpDelete("${widget.apiDelete}", context);
            Map delete = jsonDecode(response['body']);
            String er;
            if (delete.containsKey("0")) {
              er = delete['0'];
              print("check vào er");
              print(er);
              showToast(context: context, msg: "$er", color: Color.fromARGB(255, 201, 27, 27), icon: Icon(Icons.supervised_user_circle));
            }
            if (delete.containsKey("1")) {
              er = delete['1'];
              showToast(context: context, msg: "$er", color: Color.fromARGB(255, 46, 193, 20), icon: Icon(Icons.supervised_user_circle));
              Navigator.pop(context);
            }
            // showToast(context: context, msg: "Xóa thành công!", color: Colors.green, icon: Icon(Icons.supervised_user_circle));
          },
          child: const Text('Có'),
          style: ElevatedButton.styleFrom(primary: colorBlueBtnDialog, onPrimary: colorWhite, minimumSize: Size(80, 40)),
        ),
      ],
    );
  }
}

class DatePickerBoxFormV2 extends StatefulWidget {
  final Widget? label;
  final int? flexLabel;
  final List<Widget>? widgetBox;
  final Function? selectedDateFunction;
  String? updateDate;
  final dynamic marginWidget;
  final dynamic widthContainer;
  final dynamic heightWidget;
  final dynamic borderWidget;
  DatePickerBoxFormV2({
    Key? key,
    this.label,
    this.widgetBox,
    this.marginWidget,
    this.heightWidget,
    this.borderWidget,
    this.flexLabel,
    this.selectedDateFunction,
    this.updateDate,
    this.widthContainer,
  }) : super(key: key);
  @override
  State<DatePickerBoxFormV2> createState() => _DatePickerBoxFormV2State();
}

class _DatePickerBoxFormV2State extends State<DatePickerBoxFormV2> {
  //--Lấy ra ngày tháng--
  DateTime selectedDate = DateTime.now();
  //--Ngày để xét điều kiện ẩn hiện cho ô text--
  DateTime dateTimeDefault = DateTime(1000);
  bool _decideWhichDayToEnable(DateTime day) {
    if (day.isBefore(DateTime.now())) {
      return true;
    }

    return false;
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      //--cho chọn từ ngày tháng năm nào đến năm nào--
      firstDate: DateTime(1960),
      lastDate: DateTime(2080),
      initialDatePickerMode: DatePickerMode.day,
      locale: Locale("vi"),
      // fieldLabelText: 'Booking date',
      fieldHintText: 'Date/Month/Year',
      selectableDayPredicate: _decideWhichDayToEnable,
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        // print("selectedDate");
        // print(selectedDate);
        dateTimeDefault = picked;
        selectedDate = picked;
        widget.selectedDateFunction!(picked);
      });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.marginWidget,
      width: widget.widthContainer,
      // color: Colors.red,

      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                if (widget.label != null)
                  Expanded(
                    flex: widget.flexLabel ?? 5,
                    child: widget.label!,
                  ),
                Expanded(
                  flex: 5,
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.15,
                      height: widget.heightWidget,
                      decoration: BoxDecoration(
                        border: widget.borderWidget,
                        color: Colors.white,
                      ),
                      child: TextButton(
                        onPressed: () => _selectDate(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                widget.updateDate == ""
                                    ? dateTimeDefault.year == 1000
                                        ? "Chọn ngày"
                                        : DateFormat('dd-MM-yyyy').format(dateTimeDefault)
                                    : widget.updateDate!,
                                style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.bold)),
                            // Text(dateTimeDefault.year == 1000 ? "Chọn ngày" : DateFormat('dd-MM-yyyy').format(dateTimeDefault),
                            //     style: TextStyle(
                            //       fontSize: 14,
                            //       fontWeight: FontWeight.bold,
                            //       color: Colors.black87,
                            //     )),
                            SizedBox(height: 20.0),
                            Icon(
                              Icons.date_range,
                              color: Colors.blue[400],
                            ),
                            // color:,
                            // IconButton(),
                          ],
                        ),
                      )

                      //  Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [

                      //     Text(
                      //         widget.updateDate == null
                      //             ? dateTimeDefault.year == 1000
                      //                 ? "Chọn ngày"
                      //                 : DateFormat('dd-MM-yyyy')
                      //                     .format(dateTimeDefault)
                      //             : widget.updateDate!,
                      //         style: TextStyle(
                      //             fontSize: 14, fontWeight: FontWeight.bold)),
                      //     SizedBox(height: 20.0),
                      //     IconButton(
                      //         onPressed: () => _selectDate(context),
                      //         icon: Icon(Icons.date_range),
                      //         color: Colors.blue[400]),
                      //   ],
                      // ),
                      ),
                ),
              ],
            ),
          ),
          if (widget.widgetBox != null)
            Expanded(
              flex: 1,
              child: Row(
                children: widget.widgetBox!,
              ),
            ),
        ],
      ),
    );
  }
}

class DatePickerBoxTableForm extends StatefulWidget {
  final Widget? label;
  final int? flexLabel;
  final int? flexDatePiker;
  String? dateDisplay;
  String? timeDisplay;
  Function? selectedDateFunction;
  Function? selectedTimeFunction;
  bool? isTime = false;
  String? requestDayAfter;
  String? requestDayBefore;
  Function? getFullTime;
  DatePickerBoxTableForm(
      {Key? key,
      this.label,
      this.flexLabel,
      this.flexDatePiker,
      this.selectedDateFunction,
      this.selectedTimeFunction,
      this.dateDisplay,
      this.timeDisplay,
      this.requestDayAfter,
      this.requestDayBefore,
      this.getFullTime,
      this.isTime})
      : super(key: key);
  @override
  State<DatePickerBoxTableForm> createState() => _DatePickerBoxTableFormState();
}

class _DatePickerBoxTableFormState extends State<DatePickerBoxTableForm> {
  DateTime selectedDate = DateTime.now();
  String? dateDisplay;
  String? timeDisplay;
  bool _decideWhichDayToEnable(DateTime day) {
    if (widget.requestDayAfter == null && widget.requestDayBefore == null) {
      return true;
    } else if (widget.requestDayAfter != null && widget.requestDayBefore != null) {
      DateFormat dateFormat = DateFormat("dd-MM-yyyy");
      DateTime requestAfter = dateFormat.parse(widget.requestDayAfter!);
      DateTime requestBefore = dateFormat.parse(widget.requestDayBefore!);
      if (day.isAfter(requestAfter) && day.isBefore(requestBefore)) {
        return true;
      }
    } else if (widget.requestDayAfter != null) {
      DateFormat dateFormat = DateFormat("dd-MM-yyyy");
      DateTime request = dateFormat.parse(widget.requestDayAfter!);
      if (day.isAfter(request)) {
        return true;
      }
    } else if (widget.requestDayBefore != null) {
      DateFormat dateFormat = DateFormat("dd-MM-yyyy");
      DateTime request = dateFormat.parse(widget.requestDayBefore!);
      if (day.isBefore(request)) {
        return true;
      }
    }

    return false;
  }

  _selectDate(BuildContext context) async {
    if (widget.requestDayAfter != null) {
      DateFormat dateFormat = DateFormat("dd-MM-yyyy");
      DateTime request = dateFormat.parse(widget.requestDayAfter!);
      selectedDate = request.add(Duration(days: 1));
      dateDisplay = DateFormat("dd-MM-yyyy").format(selectedDate.toLocal());
      widget.selectedDateFunction!(dateDisplay);
    }
    if (widget.requestDayBefore != null) {
      DateFormat dateFormat = DateFormat("dd-MM-yyyy");
      DateTime request = dateFormat.parse(widget.requestDayBefore!);
      selectedDate = request.subtract(Duration(days: 1));
      dateDisplay = DateFormat("dd-MM-yyyy").format(selectedDate.toLocal());
      widget.selectedDateFunction!(dateDisplay);
    }
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1960),
        lastDate: DateTime(2025),
        selectableDayPredicate: _decideWhichDayToEnable);
    if (picked != null)
      setState(() {
        selectedDate = picked;
        dateDisplay = DateFormat("dd-MM-yyyy").format(selectedDate.toLocal());
        widget.selectedDateFunction!(dateDisplay);
      });
  }

  TimeOfDay _time = TimeOfDay(hour: 7, minute: 15);
  void _selectTime() async {
    final TimeOfDay? newTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, childWidget) {
          return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                  // Using 24-Hour format
                  alwaysUse24HourFormat: true),
              // If you want 12-Hour format, just change alwaysUse24HourFormat to false or remove all the builder argument
              child: childWidget!);
        });
    if (newTime != null) {
      setState(() {
        _time = newTime;
        timeDisplay = _time.format(context).toString();
        widget.selectedTimeFunction!(timeDisplay);
        convertTimeStamp(dateDisplay!, timeDisplay!);
        widget.getFullTime!(convertTimeStamp(dateDisplay!, timeDisplay!));
      });
    }
  }

  @override
  void initState() {
    if (widget.dateDisplay != null) {
      dateDisplay = widget.dateDisplay;
      timeDisplay = widget.timeDisplay;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (widget.label != null)
          Expanded(
            flex: widget.flexLabel ?? 2,
            child: widget.label!,
          ),
        Expanded(
          flex: widget.flexDatePiker ?? 5,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  // width: MediaQuery.of(context).size.width * 0.15,
                  // height: 40,
                  padding: EdgeInsets.only(left: 10),
                  // decoration: BoxDecoration(
                  //   border: Border.all(width: 0.5, style: BorderStyle.solid),
                  //   color: Colors.white,
                  // ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(dateDisplay ?? 'Chọn ngày', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      SizedBox(height: 20.0),
                      dateDisplay == null
                          ? IconButton(onPressed: () => _selectDate(context), icon: Icon(Icons.date_range), color: Colors.blue[400])
                          : IconButton(
                              onPressed: () {
                                dateDisplay = null;
                                widget.selectedDateFunction!(dateDisplay);

                                setState(() {});
                              },
                              icon: Icon(Icons.close)),
                    ],
                  ),
                ),
              ),
              widget.isTime != false
                  ? Expanded(
                      flex: 2,
                      child: Container(
                        // width: MediaQuery.of(context).size.width * 0.15,
                        height: 40,
                        padding: EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                          border: Border.all(width: 0.5, style: BorderStyle.solid),
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(timeDisplay ?? 'Chọn giờ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            SizedBox(height: 20.0),
                            timeDisplay == null
                                ? IconButton(onPressed: () => _selectTime(), icon: Icon(Icons.schedule), color: Colors.blue[400])
                                : IconButton(
                                    onPressed: () {
                                      timeDisplay = null;
                                      widget.selectedTimeFunction!(timeDisplay);
                                      setState(() {});
                                    },
                                    icon: Icon(Icons.close)),
                          ],
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ],
    );
  }
}

//chọn năm
// ignore: must_be_immutable
class YearPickerWidget extends StatefulWidget {
  final Function? callBack;
  DateTime? afterLimit;
  DateTime? pickTime;
  YearPickerWidget({
    Key? key,
    this.callBack,
    this.afterLimit,
    this.pickTime,
  }) : super(key: key);
  @override
  YearPickerWidgetState createState() => YearPickerWidgetState();
}

class YearPickerWidgetState extends State<YearPickerWidget> {
  DateTime selectedDate = DateTime.now();
  @override
  void initState() {
    super.initState();
    if (widget.pickTime != null) selectedDate = widget.pickTime!;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10),
          child: (widget.pickTime != null)
              ? Text(
                  "${widget.pickTime!.year}",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                )
              : Text(
                  "Chọn năm",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
        ),
        SizedBox(
          height: 20.0,
        ),
        // (widget.pickTime == null)
        // ?
        IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Chọn năm"),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                          icon: Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  content: Container(
                    // Need to use container to add size constraint.
                    width: 300,
                    height: 300,
                    child: YearPicker(
                      firstDate: DateTime(DateTime.now().year - 100, 1),
                      lastDate: DateTime(DateTime.now().year, 1),
                      initialDate: DateTime.now(),

                      // save the selected date to _selectedDate DateTime variable.
                      // It's used to set the previous selected date when
                      // re-showing the dialog.
                      selectedDate: selectedDate,
                      onChanged: (DateTime dateTime) {
                        if (dateTime != null) {
                          setState(() {
                            print("năm$dateTime");
                            widget.pickTime = dateTime;
                            widget.callBack!(dateTime);
                            selectedDate = dateTime;
                          });
                        }
                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
              },
            );
            // AlertDialog(
            //   title: Text("Chọn năm"),
            //   content: Container(
            //     // Need to use container to add size constraint.
            //     width: 300,
            //     height: 300,
            //     child: YearPicker(
            //       firstDate: DateTime(DateTime.now().year - 100, 1),
            //       lastDate: DateTime(DateTime.now().year + 100, 1),
            //       initialDate: DateTime.now(),
            //       // save the selected date to _selectedDate DateTime variable.
            //       // It's used to set the previous selected date when
            //       // re-showing the dialog.
            //       selectedDate: selectedDate,
            //       onChanged: (DateTime? dateTime) {
            //         if (dateTime != null) {
            //           setState(() {
            //             widget.pickTime = dateTime;
            //             widget.callBack!(dateTime.year);
            //           });
            //         }
            //         // close the dialog when year is selected.
            //         // print(dateTime.year);
            //         Navigator.pop(context);

            //         // Do something with the dateTime selected.
            //         // Remember that you need to use dateTime.year to get the year
            //       },
            //     ),
            //   ),
            // );
          },
          icon: Icon(Icons.date_range),
          color: Colors.blue[400],
        )
        // : IconButton(
        //     onPressed: () {
        //       setState(() {
        //         widget.pickTime = null;
        //         widget.callBack!("");
        //       });
        //     },
        //     icon: Icon(Icons.close),
        //   ),
      ],
    );
  }
}
// class YearPickerWidget extends StatefulWidget {
//   const YearPickerWidget({Key? key}) : super(key: key);

//   @override
//   State<YearPickerWidget> createState() => _YearPickerWidgetState();
// }

// class _YearPickerWidgetState extends State<YearPickerWidget> {
//   DateTime selectedDate =DateTime.now();
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text("Select Year"),
//       content: Container(
//         // Need to use container to add size constraint.
//         width: 300,
//         height: 300,
//         child: YearPicker(
//           firstDate: DateTime(DateTime.now().year - 100, 1),
//           lastDate: DateTime(DateTime.now().year + 100, 1),
//           initialDate: DateTime.now(),
//           // save the selected date to _selectedDate DateTime variable.
//           // It's used to set the previous selected date when
//           // re-showing the dialog.
//           selectedDate: selectedDate,
//           onChanged: (DateTime dateTime) {
//             // close the dialog when year is selected.
//             print(dateTime.year);
//             Navigator.pop(context);

//             // Do something with the dateTime selected.
//             // Remember that you need to use dateTime.year to get the year
//           },
//         ),
//       ),
//     );
//   }
// }

// ignore: must_be_immutable
class CancelWidget extends StatefulWidget {
  String? url;
  String? label;

  CancelWidget({Key? key, this.url, this.label}) : super(key: key);

  @override
  State<CancelWidget> createState() => _CancelWidgetState();
}

class _CancelWidgetState extends State<CancelWidget> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Image.asset(
            "assets/images/logoAAM.png",
            width: 30,
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: Text('Xác nhận'),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close)),
            ),
          )
        ],
      ),
      content: Container(
        height: 90,
        width: 500,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 30),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      widget.label != null ? widget.label! : "Bạn có chắc chắn muốn hủy chức năng này?",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Divider(
            thickness: 1,
            color: Colors.grey,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 120,
              height: 40,
              child: OutlinedButton(
                  style: ElevatedButton.styleFrom(
                    onPrimary: Color(0xffF77919), // Background color
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Từ chối')),
            ),
            Container(
              width: 120,
              height: 40,
              padding: EdgeInsets.only(left: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Color(0xffF77919),
                  onPrimary: Colors.white, // Background color
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  if (widget.url != null) {
                    Provider.of<NavigationModel>(context, listen: false).add(pageUrl: widget.url);
                  }
                },
                child: Text('Xác nhận'),
              ),
            )
          ],
        ),
      ],
    );
  }
}

class YesNoRadioBoxWidget extends StatefulWidget {
  final Widget? label;
  final List<Widget>? widgetBox;
  String? updateDate;
  final dynamic marginWidget;
  final dynamic widthContainer;
  final dynamic heightWidget;
  final dynamic borderWidget;
  List<Widget> listWidget;
  YesNoRadioBoxWidget({
    Key? key,
    this.label,
    this.widgetBox,
    this.marginWidget,
    this.heightWidget,
    this.borderWidget,
    this.updateDate,
    this.widthContainer,
    required this.listWidget,
  }) : super(key: key);
  @override
  State<YesNoRadioBoxWidget> createState() => _YesNoRadioBoxWidgetState();
}

class _YesNoRadioBoxWidgetState extends State<YesNoRadioBoxWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 30),
      child: Row(
        children: [
          if (widget.label != null)
            Expanded(
              flex: 3,
              child: widget.label!,
            ),
          Expanded(
            flex: 5,
            child: Container(
              height: 40,
              child: Row(
                children: widget.listWidget,
              ),
            ),
          ),
          // if (widget.widgetBox != null)
          //   Expanded(
          //     flex: 1,
          //     child: Row(
          //       children: widget.widgetBox!,
          //     ),
          //   ),
        ],
      ),
    );
  }
}

class TextFieldWidget extends StatefulWidget {
  final Widget? label;
  final List<Widget>? widgetBox;
  String? updateDate;
  final dynamic marginWidget;
  final dynamic widthContainer;
  final dynamic heightWidget;
  final dynamic borderWidget;
  Widget listWidget;
  TextFieldWidget({
    Key? key,
    this.label,
    this.widgetBox,
    this.marginWidget,
    this.heightWidget,
    this.borderWidget,
    this.updateDate,
    this.widthContainer,
    required this.listWidget,
  }) : super(key: key);
  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 30),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                if (widget.label != null)
                  Expanded(
                    flex: 3,
                    child: widget.label!,
                  ),
                Expanded(
                  flex: 5,
                  child: Container(height: 100, width: 200, child: widget.listWidget),
                ),
              ],
            ),
          ),
          if (widget.widgetBox != null)
            Expanded(
              flex: 1,
              child: Row(
                children: widget.widgetBox!,
              ),
            ),
        ],
      ),
    );
  }
}

bool isNumeric(String str) {
    bool status = false;
    try {
      int.parse(str);
      status = true;
      return status;
    } catch (e) {
      status = false;
      return status;
    }
  }