import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import '../../../../api.dart';
import '../../../../common/format_date.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';
import '../../../forms/market_development/utils/funciton.dart';
import '../../source_information/common_ource_information/constant.dart';

class DungXuLyHSN extends StatefulWidget {
  final Function? func;
  final String titleDialog;
  final List<dynamic> listIdSelected;
  final Function setState;
  const DungXuLyHSN({Key? key, required this.titleDialog, required this.listIdSelected, required this.setState, this.func}) : super(key: key);
  @override
  State<DungXuLyHSN> createState() => _DungXuLyHSNState();
}

class _DungXuLyHSNState extends State<DungXuLyHSN> {
  TextEditingController detail = TextEditingController();
  DateTime selectedDate = DateTime.now();

  dynamic selectedValueTT = '2';
  List<dynamic> itemsTT = [
    {'name': 'Chờ tiến cử lại', 'value': '1'},
    {'name': 'Dừng xử lý tạm thời', 'value': '2'}
  ];

  dynamic selectedValueLD = '1';
  List<dynamic> itemsLD = [
    {'name': 'Do nghiệp đoàn', 'value': '0'},
    {'name': 'Do cá nhân', 'value': '1'},
    {'name': 'Khác', 'value': '2'}
  ];
  dynamic selectedMoneyBack = '0';

  String? er;
  double height = 80;
  String titleLog = 'Cập nhật dữ liệu thành công';

  get titleAlertDialog => null;
  updateDXL(row) async {
    var data2;
    var response1;

    if (selectedValueTT == '2') {
      row["stopProcessing"] = 1;
      print(row);
      response1 = await httpPut('/api/nguoidung/put/${row['id']}', row, context);
      data2 = {"ttsId": row['id'], "itemType": 0, "causeType": int.parse(selectedValueLD), "causeContent": detail.text, "approvalType": 0};

      await httpPost('/api/tts-donhang-dungxuly/post/save', data2, context);
    } else {
      print('Có đổi trạng thái');
      row["ttsStatusId"] = 14;
      response1 = await httpPut('/api/nguoidung/put/${row['id']}', row, context);
      print(response1);
      await httpPostDiariStatus(row['id'], row['ttsStatusId'], 14, detail.text, context);
    }
    if (jsonDecode(response1["body"])['1'] == "Cập nhật thông tin thành công!") {
      print('Cập nhật dữ liệu thành công');
    } else {
      titleLog = 'Cập nhật thất bại';
    }
    return titleLog;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  child: Image.asset('assets/images/logoAAM.png'),
                  margin: EdgeInsets.only(right: 10),
                ),
                Text(
                  widget.titleDialog,
                  style: titleAlertDialog,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close),
          ),
        ],
      ),
      content: Container(
        width: 650,
        height: 400,
        child: ListView(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Divider(
                    thickness: 1,
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                Container(
                  height: 300,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              flex: 3,
                              child: Text(
                                'Trạng thái',
                                style: titleWidgetBox,
                              )),
                          Expanded(
                              flex: 5,
                              child: Container(
                                color: Colors.white,
                                width: MediaQuery.of(context).size.width * 0.25,
                                height: 40,
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2(
                                    isExpanded: true,
                                    items: [
                                      for (int i = 0; i < itemsTT.length; i++)
                                        DropdownMenuItem<String>(
                                          value: itemsTT[i]['value'],
                                          child: Text(
                                            itemsTT[i]['name'],
                                          ),
                                        )
                                    ],
                                    value: selectedValueTT,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedValueTT = value;
                                      });
                                    },
                                    dropdownDecoration: BoxDecoration(border: Border.all(color: const Color.fromRGBO(216, 218, 229, 1))),
                                    buttonDecoration: BoxDecoration(border: Border.all(width: 0.5, style: BorderStyle.solid)),
                                    buttonElevation: 0,
                                    buttonPadding: const EdgeInsets.only(left: 14, right: 14),
                                    itemPadding: const EdgeInsets.only(left: 14, right: 14),
                                    dropdownElevation: 5,
                                    focusColor: Colors.white,
                                  ),
                                ),
                              ))
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                              flex: 3,
                              child: Text(
                                'Lý do',
                                style: titleWidgetBox,
                              )),
                          Expanded(
                              flex: 5,
                              child: Container(
                                color: Colors.white,
                                width: MediaQuery.of(context).size.width * 0.25,
                                height: 40,
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2(
                                    isExpanded: true,
                                    items: [
                                      for (int i = 0; i < itemsLD.length; i++)
                                        DropdownMenuItem<String>(
                                          value: itemsLD[i]['value'],
                                          child: Text(
                                            itemsLD[i]['name'],
                                          ),
                                        )
                                    ],
                                    value: selectedValueLD,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedValueLD = value;
                                      });
                                    },
                                    dropdownDecoration: BoxDecoration(border: Border.all(color: const Color.fromRGBO(216, 218, 229, 1))),
                                    buttonDecoration: BoxDecoration(border: Border.all(width: 0.5, style: BorderStyle.solid)),
                                    buttonElevation: 0,
                                    buttonPadding: const EdgeInsets.only(left: 14, right: 14),
                                    itemPadding: const EdgeInsets.only(left: 14, right: 14),
                                    dropdownElevation: 5,
                                    focusColor: Colors.white,
                                  ),
                                ),
                              ))
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                              flex: 3,
                              child: Text(
                                'Mô tả chi tiết',
                                style: titleWidgetBox,
                              )),
                          Expanded(
                              flex: 5,
                              child: Container(
                                height: height,
                                // width: MediaQuery.of(context).size.width * 0.15,
                                child: TextField(
                                  controller: detail,
                                  minLines: 4,
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    hintText: 'Nhập nội dung',
                                    errorText: er,
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    if (detail.text.isEmpty) {
                                      er = 'Yêu cầu không được để trống';
                                      height = 92;
                                    } else {
                                      er = null;
                                      height = 80;
                                    }
                                    setState(() {});
                                  },
                                ),
                              ))
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          // textColor: Color(0xFF6200EE),
          onPressed: () => Navigator.pop(context),
          child: Text('Hủy'),
          style: ElevatedButton.styleFrom(
            primary: colorOrange,
            onPrimary: colorWhite,
            // shadowColor: Colors.greenAccent,
            elevation: 3,
            // shape: Border.all(width: 1,color: Colors.red);
            // side: BorderSide(
            //   width: 1,
            //   color: Colors.black87,
            // ),
            minimumSize: Size(140, 50),
            // maximumSize: Size(140, 50), //////// HERE
          ),
        ),
        ElevatedButton(
          // textColor: Color(0xFF6200EE),
          onPressed: () async {
            for (var row in widget.listIdSelected) {
              await updateDXL(row);
            }
            widget.setState();
            Navigator.pop(context);
            showToast(
              context: context,
              msg: titleLog,
              color: titleLog == "Cập nhật dữ liệu thành công" ? Color.fromARGB(136, 72, 238, 67) : Colors.red,
              icon: titleLog == "Cập nhật dữ liệu thành công" ? Icon(Icons.done) : Icon(Icons.warning),
            );
            for (int i = 0; i < widget.listIdSelected.length; i++) {
              try {
                await httpPost(
                    API_THONG_BAO_PHONG_BAN_POST + "3&4&5&6&7&8&9&10",
                    {
                      "title": TIEU_DE_THONG_BAO,
                      "message":
                          "Tạm dừng xử lý TTS có mã ${widget.listIdSelected[i]["userCode"]} lúc ${getDateViewDayAndHour(FormatDate.formatDateInsertDBHHss(DateTime.now()))}",
                    },
                    context);
              } catch (e) {
                print(e);
              }
            }
            widget.func!();
          },
          child: Text(
            'Xác nhận',
            style: TextStyle(),
          ),
          style: ElevatedButton.styleFrom(
            primary: colorBlueBtnDialog,
            onPrimary: colorWhite,
            // shadowColor: Colors.greenAccent,
            elevation: 3,
            // shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(32.0)),
            minimumSize: Size(140, 50), //////// HERE
          ),
        ),
      ],
    );
  }
}
