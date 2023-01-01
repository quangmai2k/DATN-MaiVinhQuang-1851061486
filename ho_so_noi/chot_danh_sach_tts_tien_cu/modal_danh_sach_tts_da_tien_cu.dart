import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../../api.dart';
import "package:collection/collection.dart";
import '../../../../../../common/style.dart';
import '../../../../common/format_date.dart';
import '../../../../common/toast.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/model.dart';
import '../../../forms/market_development/utils/funciton.dart';
import 'dung_xu_ly.dart';

// ignore: must_be_immutable
class ModalDanhSachTienCu extends StatefulWidget {
  int? orderId;
  Function funcitonCallback;
  var order;
  ModalDanhSachTienCu(
      {Key? key, this.orderId, this.order, required this.funcitonCallback})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _ModalDanhSachTienCuState();
  }
}

class _ModalDanhSachTienCuState extends State<ModalDanhSachTienCu> {
  var rowPerPage = 10;
  var currentPage = 1;
  bool _setLoading = false;
  var resultListNguoiDung;
  var _selectedDataRow = [];
  late Future futureDanhSachChotTTSTienCu;
  bool check = false;
  int count = 0;
  var listPay = {};
  var listDungXuLy = [];
  var listChot = [];
  var listId = [];
  @override
  void initState() {
    super.initState();
    futureDanhSachChotTTSTienCu = getDanhSachTTS(widget.orderId, context);
    callApi();
  }

  bool checkSTT = false;
  callApi() async {
    await getListPay();
  }

  Future getDanhSachTTS(idSelectedDonHang, context) async {
    var response = await httpGet(
        "/api/donhang-tts-tiencu/get/page?filter=orderId:$idSelectedDonHang and qcApproval:1 and ptttApproval:1",
        context);
    if (response.containsKey("body")) {
      setState(() {
        resultListNguoiDung = jsonDecode(response["body"]);
        for (int i = 0; i < resultListNguoiDung["content"].length; i++) {
          listId.add(resultListNguoiDung["content"][i]["ttsId"]);
        }
        print(listId);
        _selectedDataRow = List<bool>.generate(
            resultListNguoiDung.length, (int index) => false);
      });
    }
    return resultListNguoiDung;
  }

  Future getListPay() async {
    setState(() {
      _setLoading = false;
    });
    String request = '';
    for (int i = 0; i < listId.length; i++) {
      if (listId[i] != null) {
        request += listId[i].toString();
        if (i < listId.length - 1) {
          request += ',';
        }
      }
    }
    if (listId.isEmpty) request = "0";

    var response;
    response = await httpGet(
        "/api/tts-thanhtoan/get/page?filter ttsId in ($request)", context);
    print("/api/tts-thanhtoan/get/page?filter ttsId in ($request)");
    if (response.containsKey("body")) {
      setState(() {
        listPay = jsonDecode(response["body"]);
      });
    }
    setState(() {
      _setLoading = true;
    });
  }

  int getIndex(page, rowPerPage, index) {
    return ((page * rowPerPage) + index) + 1;
  }

  getPaidBeforeExamByByTtsId(listPay, int idTTS) {
    for (int i = 0; i < listPay['content'].length; i++) {
      if (listPay['content'][i]['ttsId'].toString() == idTTS.toString()) {
        return listPay['content'][i]['paidBeforeExam'];
      }
    }
    return 0;
  }

  handleSearch() {
    setState(() {
      try {
        futureDanhSachChotTTSTienCu = getDanhSachTTS(widget.orderId, context);
      } catch (e) {
        print("Lỗi tại đây" + e.toString());
      }
    });

    // Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: userRule('/chot-ds-tts-tien-cu', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return FutureBuilder<dynamic>(
              future: futureDanhSachChotTTSTienCu,
              builder: (context, snapshot) {
                return AlertDialog(
                  title: Row(
                    children: [
                      Image.asset(
                        "assets/images/logoAAM.png",
                        width: 50,
                        height: 50,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: Text('Chốt danh sách thực tập sinh tiến cử',
                            style: titleBox),
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
                    height: 400,
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Column(
                      children: [
                        Text('Đơn hàng: ${widget.order['orderName']}'),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child: Divider(
                            thickness: 1,
                            color: Colors.grey,
                          ),
                        ),
                        Container(
                          height: 300,
                          child: ListView(
                            children: [
                              Column(
                                children: [
                                  if (snapshot.hasData)
                                    //Start Datatable
                                    _setLoading
                                        ? Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                1,
                                            child: DataTable(
                                              dataTextStyle: const TextStyle(
                                                  color: Color(0xff313131),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500),
                                              showBottomBorder: true,
                                              dataRowHeight: 60,
                                              showCheckboxColumn: true,
                                              dataRowColor:
                                                  MaterialStateProperty
                                                      .resolveWith<Color?>((Set<
                                                              MaterialState>
                                                          states) {
                                                if (states.contains(
                                                    MaterialState.selected)) {
                                                  return MaterialStateColor
                                                      .resolveWith((states) =>
                                                          const Color(
                                                              0xffeef3ff));
                                                }
                                                return MaterialStateColor
                                                    .resolveWith((states) => Colors
                                                        .white); // Use the default value.
                                              }),
                                              columns: <DataColumn>[
                                                DataColumn(
                                                  label: Text(
                                                    'STT',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color:
                                                            Color(0xff858791),
                                                        fontSize: 12),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    'Mã TTS',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color:
                                                            Color(0xff858791),
                                                        fontSize: 12),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    'Họ tên TTS',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color:
                                                            Color(0xff858791),
                                                        fontSize: 12),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    'Ngày sinh',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color:
                                                            Color(0xff858791),
                                                        fontSize: 12),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    'Giới tính',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color:
                                                            Color(0xff858791),
                                                        fontSize: 12),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    'Cán bộ tuyển dụng',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color:
                                                            Color(0xff858791),
                                                        fontSize: 12),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    'Vị trí',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color:
                                                            Color(0xff858791),
                                                        fontSize: 12),
                                                  ),
                                                ),
                                                // DataColumn(
                                                //   label: Text(
                                                //     'Thao tác',
                                                //     style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xff858791), fontSize: 12),
                                                //   ),
                                                // ),
                                              ],
                                              rows: <DataRow>[
                                                if (resultListNguoiDung[
                                                        "content"] !=
                                                    null)
                                                  for (int i = 0;
                                                      i <
                                                          resultListNguoiDung[
                                                                  "content"]
                                                              .length;
                                                      i++)
                                                    DataRow(
                                                      cells: <DataCell>[
                                                        DataCell(Text(getIndex(
                                                                currentPage - 1,
                                                                rowPerPage,
                                                                i)
                                                            .toString())),

                                                        DataCell(
                                                          Text(
                                                              resultListNguoiDung["content"]
                                                                              [
                                                                              i]
                                                                          [
                                                                          "nguoidung"]
                                                                      [
                                                                      "userCode"] ??
                                                                  "no data",
                                                              style:
                                                                  bangDuLieu),
                                                        ),
                                                        DataCell(Row(children: [
                                                          Text(
                                                              resultListNguoiDung["content"]
                                                                              [
                                                                              i]
                                                                          [
                                                                          "nguoidung"]
                                                                      [
                                                                      "fullName"] ??
                                                                  "no data",
                                                              style: bangDuLieu)
                                                        ])),
                                                        DataCell(
                                                          Text(
                                                              resultListNguoiDung["content"][i]
                                                                              [
                                                                              "nguoidung"]
                                                                          [
                                                                          "birthDate"] !=
                                                                      null
                                                                  ? DateFormat(
                                                                          "dd-MM-yyyy")
                                                                      .format(DateTime.parse(resultListNguoiDung["content"]
                                                                              [i]["nguoidung"]
                                                                          [
                                                                          "birthDate"]))
                                                                  : '',
                                                              style:
                                                                  bangDuLieu),
                                                        ),
                                                        DataCell(
                                                          Text(
                                                              resultListNguoiDung["content"][i]
                                                                              [
                                                                              "nguoidung"]
                                                                          [
                                                                          "gender"] ==
                                                                      1
                                                                  ? "Nam"
                                                                  : "Nữ",
                                                              style:
                                                                  bangDuLieu),
                                                        ),
                                                        DataCell(
                                                          Text(
                                                              resultListNguoiDung["content"][i]
                                                                              [
                                                                              "nguoidung"]
                                                                          [
                                                                          'nhanvientuyendung'] !=
                                                                      null
                                                                  ? resultListNguoiDung["content"]
                                                                              [
                                                                              i]["nguoidung"]['nhanvientuyendung']
                                                                          [
                                                                          'fullName']
                                                                      .toString()
                                                                  : '',
                                                              style:
                                                                  bangDuLieu),
                                                        ),
                                                        DataCell(
                                                          Text(
                                                              resultListNguoiDung["content"][i]["nguoidung"]
                                                                              [
                                                                              'nhanvientuyendung']
                                                                          [
                                                                          'vaitro'] !=
                                                                      null
                                                                  ? resultListNguoiDung["content"]
                                                                              [
                                                                              i]
                                                                          [
                                                                          "nguoidung"]['nhanvientuyendung']
                                                                      [
                                                                      'vaitro']['name']
                                                                  : '',
                                                              style: bangDuLieu),
                                                        ),

                                                        // DataCell(Row(
                                                        //   children: [
                                                        //     Container(child: InkWell(onTap: () {}, child: Icon(Icons.visibility))),
                                                        //     Container(
                                                        //         margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                        //         child: InkWell(
                                                        //             onTap: () {},
                                                        //             child: Icon(
                                                        //               Icons.edit_calendar,
                                                        //               color: Color(0xff009C87),
                                                        //             ))),
                                                        //   ],
                                                        // )),
                                                        //
                                                      ],
                                                    ),
                                              ],
                                            ))
                                        : Center(
                                            child: CircularProgressIndicator(),
                                          )
                                  else if (snapshot.hasError)
                                    Text("Fail! ${snapshot.error}")
                                  else if (!snapshot.hasData)
                                    Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                        //   child: Divider(
                        //     thickness: 1,
                        //     color: Colors.grey,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  actions: [],
                );
              });
        } else if (listRule.hasError) {
          return Text('${listRule.error}');
        }

        // By default, show a loading spinner.
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
