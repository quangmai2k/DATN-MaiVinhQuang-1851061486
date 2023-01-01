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
class ModalChotDanhSachTienCu extends StatefulWidget {
  int? orderId;
  Function funcitonCallback;
  var order;
  ModalChotDanhSachTienCu({Key? key, this.orderId, this.order, required this.funcitonCallback}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _ModalChotDanhSachTienCuState();
  }
}

class _ModalChotDanhSachTienCuState extends State<ModalChotDanhSachTienCu> {
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
    await getExamTimes();
    checkSTT = await checkPaidBeforeExam();
  }

  var status;
  updateTtsStatusId(listChot) async {
    for (int i = 0; i < listChot.length; i++) {
      try {
        var data = {"ttsStatusId": 6, "isTts": 1, "orderId": widget.orderId};
        var response = await httpPut(Uri.parse('/api/nguoidung/put/${listChot[i]}'), data, context);
        await httpPostDiariStatus(listChot[i], 5, 6, 'Chuyển trạng thái thực tập sinh', context);
        if (response.containKeys("body")) {
          setState(() {
            status = response['body'];
            // print(status.runtimeType());
          });
        }
        print("thaida detail success");
      } catch (_) {
        print("Fail!");
      }
    }
  }

  Future getDanhSachTTS(idSelectedDonHang, context) async {
    var response = await httpGet(
        "/api/donhang-tts-tiencu/get/page?filter=orderId:$idSelectedDonHang AND qcApproval:1 and ptttApproval:1 AND nguoidung.ttsStatusId:5 and (nguoidung.stopProcessing:0 or nguoidung.stopProcessing is null)",
        context);
    Map<int, dynamic> mapTts = new Map();
    if (response.containsKey("body")) {
      resultListNguoiDung = jsonDecode(response["body"]);
      setState(() {
        for (int i = 0; i < resultListNguoiDung["content"].length; i++) {
          if (!mapTts.containsKey(resultListNguoiDung["content"][i]["ttsId"])) {
            listId.add(resultListNguoiDung["content"][i]["ttsId"]);
            mapTts.putIfAbsent(resultListNguoiDung["content"][i]["ttsId"], () => resultListNguoiDung["content"][i]);
          } else {
            //var test = mapTts[resultListNguoiDung["content"][i]['ttsId']]['createdDate'];
            DateTime dateTimeTtsInMap = DateTime.parse(mapTts[resultListNguoiDung["content"][i]['ttsId']]['createdDate']);
            DateTime dateTimeTtsNew = DateTime.parse(mapTts[resultListNguoiDung["content"][i]['ttsId']]['createdDate']);
            if (dateTimeTtsInMap.isBefore(dateTimeTtsNew)) {
              mapTts[resultListNguoiDung["content"][i]["ttsId"]] = resultListNguoiDung["content"][i];
            }
          }
        }
        print(mapTts);

        resultListNguoiDung['content'] = [];
        resultListNguoiDung['content'].addAll(mapTts.values);

        for (int i = 0; i < resultListNguoiDung['content'].length; i++) {
          print("aa" + resultListNguoiDung['content'][i]['id'].toString());
        }
        // print(listId);
        _selectedDataRow = List<bool>.generate(resultListNguoiDung['content'].length, (int index) => false);
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
    response = await httpGet("/api/tts-thanhtoan/get/page?filter ttsId in ($request)", context);
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

  var listExamTimes;
  var listExamTimeGroupByTrainee = {};
  var listTraineeId = [];
  dynamic max = {};
  getExamTimes() async {
    String request = '';
    for (int i = 0; i < resultListNguoiDung["content"].length; i++) {
      if (resultListNguoiDung["content"][i] != null) {
        request += resultListNguoiDung["content"][i]["ttsId"].toString();
        if (i < resultListNguoiDung["content"].length - 1) {
          request += ',';
        }
      }
    }
    if (request == '') request = '0';
    var response = await httpGet("/api/tts-lichsu-thituyen/get/page?filter=ttsId in ($request) &sort=examTimes", context);

    if (response.containsKey("body")) {
      setState(() {
        listExamTimes = jsonDecode(response["body"])["content"];
        listExamTimeGroupByTrainee = groupBy(listExamTimes, (dynamic obj) => obj['ttsId']);
        listExamTimeGroupByTrainee.forEach((key, value) {
          if (key != null) listTraineeId.add(key);
        });
        for (int i = 0; i < resultListNguoiDung["content"].length; i++) {
          if (listTraineeId.isEmpty) {
            max[resultListNguoiDung["content"][i]["ttsId"]] = 0;
          }
          for (int j = 0; j < listTraineeId.length; j++) {
            if (resultListNguoiDung["content"][i]["ttsId"] != listTraineeId[j]) {
              max[resultListNguoiDung["content"][i]["ttsId"]] = 0;
            } else {
              max[listTraineeId[j]] = (listExamTimeGroupByTrainee[listTraineeId[j]].first["examTimes"]);
            }
          }
        }
        print(max);
      });
    }
  }

  addEmptyExamHistory() async {
    try {
      List<dynamic> listData = [];
      for (int i = 0; i < listChot.length; i++) {
        var data = {"ttsId": listChot[i], "orderId": widget.orderId, "examTimes": max[listChot[i]] + 1, "examResult": 0};
        listData.add(data);
      }
      await httpPost(Uri.parse('/api/tts-lichsu-thituyen/post/saveAll'), listData, context);
      print("thaida detail success");
    } catch (_) {
      print("Fail!");
    }
  }

  checkPaidBeforeExam() {
    for (int i = 0; i < resultListNguoiDung["content"].length; i++) {
      if (getPaidBeforeExamByByTtsId(listPay, resultListNguoiDung["content"][i]["ttsId"]) == 0) {
        count++;
      }
      if (count > 0) {
        check = false;
      } else
        check = true;
    }
    print(check);
    return check;
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
                        child: Text('Chốt danh sách thực tập sinh tiến cử', style: titleBox),
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
                                            width: MediaQuery.of(context).size.width * 1,
                                            child: DataTable(
                                              dataTextStyle: const TextStyle(color: Color(0xff313131), fontSize: 14, fontWeight: FontWeight.w500),
                                              showBottomBorder: true,
                                              dataRowHeight: 60,
                                              showCheckboxColumn: true,
                                              dataRowColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                                                if (states.contains(MaterialState.selected)) {
                                                  return MaterialStateColor.resolveWith((states) => const Color(0xffeef3ff));
                                                }
                                                return MaterialStateColor.resolveWith((states) => Colors.white); // Use the default value.
                                              }),
                                              columns: <DataColumn>[
                                                DataColumn(
                                                  label: Text(
                                                    'STT',
                                                    style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xff858791), fontSize: 12),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    'Mã TTS',
                                                    style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xff858791), fontSize: 12),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    'Họ tên TTS',
                                                    style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xff858791), fontSize: 12),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    'Ngày sinh',
                                                    style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xff858791), fontSize: 12),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    'Giới tính',
                                                    style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xff858791), fontSize: 12),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    'Cán bộ tuyển dụng',
                                                    style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xff858791), fontSize: 12),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    'Vị trí',
                                                    style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xff858791), fontSize: 12),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    'Thu tiền trước thi tuyển',
                                                    style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xff858791), fontSize: 12),
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
                                                if (resultListNguoiDung["content"] != null)
                                                  for (int i = 0; i < resultListNguoiDung["content"].length; i++)
                                                    DataRow(
                                                      selected: _selectedDataRow[i],
                                                      onSelectChanged: (bool? value) {
                                                        setState(() {
                                                          listDungXuLy.clear();
                                                          listChot.clear();
                                                          _selectedDataRow[i] = value!;
                                                          for (int j = 0; j < _selectedDataRow.length; j++) {
                                                            if (_selectedDataRow[j] == true) {
                                                              //Add vào list dừng xử lý
                                                              listDungXuLy.add(resultListNguoiDung["content"][j]["nguoidung"]);
                                                            }
                                                          }

                                                          for (int j = 0; j < _selectedDataRow.length; j++) {
                                                            if (getPaidBeforeExamByByTtsId(listPay, resultListNguoiDung["content"][i]["ttsId"]) != 0 &&
                                                                _selectedDataRow[j] == true) {
                                                              listChot.add(resultListNguoiDung["content"][j]['ttsId']);
                                                            }
                                                          }
                                                          // print(listChot);
                                                          print(listDungXuLy);
                                                        });
                                                      },
                                                      cells: <DataCell>[
                                                        DataCell(Text(getIndex(currentPage - 1, rowPerPage, i).toString())),
                                                        if (resultListNguoiDung["content"][i]["paidBeforeExam"] == 0)
                                                          DataCell(
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                  Icons.warning_amber,
                                                                  color: Colors.red,
                                                                ),
                                                                Text(resultListNguoiDung["content"][i]["nguoidung"]["userCode"] ?? "no data", style: bangDuLieu),
                                                              ],
                                                            ),
                                                          )
                                                        else
                                                          DataCell(
                                                            Text(resultListNguoiDung["content"][i]["nguoidung"]["userCode"] ?? "no data", style: bangDuLieu),
                                                          ),
                                                        DataCell((getPaidBeforeExamByByTtsId(listPay, resultListNguoiDung['content'][i]['ttsId']) != 0)
                                                            ? Text(resultListNguoiDung["content"][i]["nguoidung"]["fullName"] ?? "no data", style: bangDuLieu)
                                                            : Row(children: [
                                                                Icon(
                                                                  Icons.warning_amber_rounded,
                                                                  color: Colors.red,
                                                                ),
                                                                Text(resultListNguoiDung["content"][i]["nguoidung"]["fullName"] ?? "no data", style: bangDuLieu)
                                                              ])),
                                                        DataCell(
                                                          Text(
                                                              resultListNguoiDung["content"][i]["nguoidung"]["birthDate"] != null
                                                                  ? DateFormat("dd-MM-yyyy").format(DateTime.parse(resultListNguoiDung["content"][i]["nguoidung"]["birthDate"]))
                                                                  : '',
                                                              style: bangDuLieu),
                                                        ),
                                                        DataCell(
                                                          Text(resultListNguoiDung["content"][i]["nguoidung"]["gender"] == 1 ? "Nam" : "Nữ", style: bangDuLieu),
                                                        ),
                                                        DataCell(
                                                          Text(
                                                              resultListNguoiDung["content"][i]["nguoidung"]['nhanvientuyendung'] != null
                                                                  ? resultListNguoiDung["content"][i]["nguoidung"]['nhanvientuyendung']['fullName'].toString()
                                                                  : '',
                                                              style: bangDuLieu),
                                                        ),
                                                        DataCell(
                                                          Text(
                                                              resultListNguoiDung["content"][i]["nguoidung"]['nhanvientuyendung']['vaitro'] != null
                                                                  ? resultListNguoiDung["content"][i]["nguoidung"]['nhanvientuyendung']['vaitro']['name']
                                                                  : '',
                                                              style: bangDuLieu),
                                                        ),
                                                        DataCell(
                                                          Text(
                                                              (getPaidBeforeExamByByTtsId(listPay, resultListNguoiDung['content'][i]['ttsId']) == 0)
                                                                  ? "Chưa đóng tiền"
                                                                  : "Đã đóng tiền",
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
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Consumer<NavigationModel>(
                          builder: (context, navigationModel, child) => getRule(listRule.data, Role.Sua, context) == true
                              ? ElevatedButton(
                                  // textColor: Color(0xFF6200EE),
                                  onPressed: _selectedDataRow.isNotEmpty
                                      ? () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) => DungXuLyHSN(
                                              setState: () {
                                                widget.funcitonCallback();
                                                setState(() {});
                                              },
                                              listIdSelected: listDungXuLy,
                                              titleDialog: 'Dừng xử lý',
                                              func: handleSearch,
                                            ),
                                          );
                                        }
                                      : null,
                                  child: Text(
                                    'Dừng xử lý',
                                    style: TextStyle(),
                                  ),
                                  style: _selectedDataRow.isNotEmpty
                                      ? ElevatedButton.styleFrom(
                                          primary: Color.fromRGBO(245, 117, 29, 1),
                                          onPrimary: Colors.white,
                                          elevation: 3,
                                          minimumSize: Size(140, 50),
                                        )
                                      : ElevatedButton.styleFrom(
                                          primary: Color.fromARGB(255, 115, 115, 115),
                                          onPrimary: Colors.white,
                                          elevation: 3,
                                          minimumSize: Size(140, 50),
                                        ),
                                )
                              : Container(),
                        ),
                        Expanded(
                          flex: 5,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Consumer2<NavigationModel, SecurityModel>(
                                builder: (context, navigationModel, user, child) => Container(
                                  margin: EdgeInsets.fromLTRB(400, 0, 10, 0),
                                  child: getRule(listRule.data, Role.Sua, context) == true
                                      ? ElevatedButton(
                                          onPressed: (listChot.isNotEmpty && checkSTT == true)
                                              ? () async {
                                                  await updateTtsStatusId(listChot);
                                                  updateOrderStatus(int orderId) async {
                                                    try {
                                                      var data = {
                                                        "orderStatusId": 2,
                                                        "nominateStatus": 1,
                                                        "closeNominateDate": FormatDate.formatDateInsertDB(DateTime.now()),
                                                        "closeNominateUser": user.userLoginCurren["id"]
                                                      };
                                                      await httpPut('/api/donhang/put/$orderId', data, context);
                                                    } catch (_) {
                                                      print("Fail!");
                                                    }
                                                  }

                                                  addNotification() async {
                                                    try {
                                                      var data = {
                                                        "title": " Hệ thống thông báo",
                                                        "message":
                                                            'Đơn hàng có mã ${widget.order['orderCode']}-${widget.order['orderName']} đã chốt tiến cử lúc ${getDateViewDayAndHour(FormatDate.formatDateInsertDBHHss(DateTime.now()))}',
                                                      };
                                                      await httpPost('/api/push/tags/depart_id/3&5', data, context);
                                                    } catch (_) {
                                                      print("Fail!");
                                                    }
                                                  }

                                                  await updateOrderStatus(widget.orderId!);
                                                  await addEmptyExamHistory();
                                                  await addNotification();
                                                  widget.funcitonCallback();
                                                  showToast(context: context, msg: "Chốt thành công!", color: Colors.green, icon: Icon(Icons.done));
                                                  Navigator.pop(context);
                                                }
                                              : null,
                                          child: Text(
                                            'Chốt',
                                            style: TextStyle(),
                                          ),
                                          style: (listChot.isEmpty && checkSTT == false)
                                              ? ElevatedButton.styleFrom(
                                                  primary: Color.fromARGB(255, 115, 115, 115),
                                                  onPrimary: Colors.white,
                                                  elevation: 3,
                                                  minimumSize: Size(140, 50),
                                                )
                                              : ElevatedButton.styleFrom(
                                                  primary: Color.fromRGBO(245, 117, 29, 1),
                                                  onPrimary: Colors.white,
                                                  minimumSize: Size(140, 50),
                                                ),
                                        )
                                      : Container(),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Hủy',
                                      style: TextStyle(),
                                    ),
                                  ],
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Color.fromRGBO(245, 117, 29, 1),
                                  onPrimary: Colors.white,
                                  minimumSize: Size(140, 50),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
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
