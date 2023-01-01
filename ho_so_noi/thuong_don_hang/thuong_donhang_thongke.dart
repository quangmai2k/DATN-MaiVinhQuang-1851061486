import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/style.dart';
import 'package:intl/intl.dart';
import '../../../../api.dart';
import '../../../../common/format_date.dart';
import '../../../../common/toast.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/market_development/order.dart';
import '../../../../model/market_development/union.dart';

import "package:collection/collection.dart";

var selectedOrderId;
var selectedOrderName;
var selectedOrderCode;
var idDH;
var idND;
TextEditingController title = TextEditingController();
bool check = false;
var listPay = {};
void _showMaterialDialog(BuildContext context, int index, var order) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter _setState) {
          return FutureBuilder<dynamic>(
            future: userRule('/thuong-don-hang', context),
            builder: (context, listRule) {
              if (listRule.hasData) {
                return AlertDialogCount();
              } else if (listRule.hasError) {
                return Text('${listRule.error}');
              }

              // By default, show a loading spinner.
              return Center(child: CircularProgressIndicator());
            },
          );
        });
      });
}

class AlertDialogCount extends StatefulWidget {
  AlertDialogCount({Key? key}) : super(key: key);

  @override
  State<AlertDialogCount> createState() => _AlertDialogCountState();
}

class _AlertDialogCountState extends State<AlertDialogCount> {
  int totalAmount = 0;
  int rewardOfferId = 0;

  addOrderBonus() async {
    try {
      for (int i = 0; i < listCareUser1["content"].length; i++) {
        totalAmount = totalAmount +
            int.parse((listOrderBonus *
                    listCountTrainee[listCareUser1["content"][i]["id"]])
                .toString());
      }
      if (totalAmount != 0) {
        var data = {
          "title": title.text,
          "paidStatus": 0,
          "bonusType": 2,
          "totalAmount": totalAmount,
          "orderId": selectedOrderId
        };
        var response = await httpPost(
            Uri.parse('/api/thuong-chitieu-denghi/post/save'), data, context);
        setState(() {
          rewardOfferId = int.parse(jsonDecode(response["body"]).toString());
        });
        print(data);
      } else {
        showToast(
            context: context,
            msg: "Chưa đủ điều kiện thưởng",
            color: Colors.red,
            icon: Icon(Icons.warning));
      }

      print("thaida detail success");
    } catch (e) {
      print("Fail!$e");
    }
  }

  addDetailOrderBonus() async {
    try {
      for (int i = 0; i < listCareUser1["content"].length; i++) {
        var data = {
          "rewardOfferId": rewardOfferId,
          "userId": listCareUser1["content"][i]["id"],
          "ttsTotal": listCountTrainee[listCareUser1["content"][i]["id"]],
          "bonus": listCountTrainee[listCareUser1["content"][i]["id"]] *
              listOrderBonus,
        };
        print(data);
        await httpPost(
            Uri.parse('/api/thuong-donhang-denghi-chitiet/post/save'),
            data,
            context);
      }
      print("thaida detail success");
    } catch (e) {
      print("Fail!$e");
    }
  }

  updateOrderBonus() async {
    try {
      var data = {
        "orderBonus": 1,
      };
      await httpPut(
          Uri.parse('/api/donhang/put/$selectedOrderId'), data, context);
    } catch (e) {
      print("Fail!$e");
    }
  }

  callApi() async {
    await getListTraineeTookTheExam();
    await getCareUser();
  }

  @override
  void initState() {
    callApi();
    super.initState();
  }

  var listTraineeGroupByCareUser = {};
  var listTraineeGroupBy;
  var countTTS = 0;
  var listTrainee = {};
  var listTraineePass = [];
  var listTraineeFail = [];
  var listCareUser = [];
  dynamic listCountTrainee = {};
  getListTraineeTookTheExam() async {
    var response = await httpGet(
        "/api/tts-lichsu-thituyen/get/page?filter=orderId:$selectedOrderId and(thuctapsinh.stopProcessing is null or thuctapsinh.stopProcessing:0) and examResult in (1,2)",
        context);
    if (response.containsKey("body")) {
      setState(() {
        listTrainee = jsonDecode(response["body"]);
      });
    }
    listTraineePass.clear();
    listTraineeFail.clear();
    for (var element in listTrainee['content']) {
      if (element['examResult'] == 1) {
        listTraineePass.add(element);
      } else
        listTraineeFail.add(element);
    }
    for (var element in listTraineePass) {
      if (element['thuctapsinh']['ttsStatusId'] >= 7) {
        countTTS = listTraineePass.length + listTraineeFail.length;
        break;
      } else
        countTTS = 0;
    }

    if (countTTS != 0) {
      listTraineeGroupByCareUser = groupBy(listTrainee['content'],
          (dynamic obj) => obj['thuctapsinh']['careUser']);
      listCareUser.clear();
      listTraineeGroupByCareUser.forEach((key, value) {
        if (key != null) {
          listCareUser.add(key);
        }
        listCountTrainee[key] = value.length;
      });
    }
  }

  var listCareUser1 = {};
  getCareUser() async {
    String request = '';
    for (int i = 0; i < listCareUser.length; i++) {
      if (listCareUser[i] != null) {
        request += listCareUser[i].toString();
        if (i < listCareUser.length - 1) {
          request += ',';
        }
      }
    }
    if (listCareUser.isEmpty) request = "0";
    var response = await httpGet(
        "/api/nguoidung/get/page?filter=id in ($request)", context);
    if (response.containsKey("body")) {
      setState(() {
        listCareUser1 = jsonDecode(response["body"]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    child: Image.asset('assets/images/logoAAM.png'),
                    margin: EdgeInsets.only(right: 10),
                  ),
                  Text(
                    'Danh sách nhân viên tuyển dụng',
                    style: TextStyle(
                        fontSize: 20,
                        color: Color(0xff333333),
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close),
              ),
            ],
          ),
          Text(
            'Đơn hàng : $selectedOrderName',
            style: TextStyle(
                fontSize: 20,
                color: Color(0xff333333),
                fontWeight: FontWeight.w400),
          ),
          Container(
            margin: marginTopBottomHorizontalLine,
            child: Divider(
              thickness: 1,
              color: ColorHorizontalLine,
            ),
          ),
          Container(
              child: Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text('Thưởng đơn hàng: ',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xff333333),
                                  fontWeight: FontWeight.w700)),
                          Text(
                              ' ${NumberFormat.simpleCurrency(locale: "vi").format(listOrderBonus)}  VND/TTS ',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xff333333),
                                  fontWeight: FontWeight.w400)),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                              margin: EdgeInsets.only(top: 20),
                              child: Text("")),
                        ],
                      )
                    ],
                  )),
              Expanded(
                flex: 1,
                child: Container(),
              ),
              Expanded(
                flex: 3,
                child: Column(children: [
                  Container(
                    child: Row(
                      children: [
                        Text('Trạng thái thanh toán: ',
                            style: TextStyle(
                                fontSize: 18,
                                color: Color(0xff333333),
                                fontWeight: FontWeight.w700)),
                        if (check == true)
                          (listPay["content"][0]["paidDate"] != null)
                              ? Text(" Đã thanh toán",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xff333333),
                                  ))
                              : Text(" Đã gửi thanh toán",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xff333333),
                                  ))
                        else
                          Text(" Chưa thanh toán",
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xff333333),
                              )),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    child: Row(
                      children: [
                        Text("Ngày thanh toán: ",
                            style: TextStyle(
                                fontSize: 18,
                                color: Color(0xff333333),
                                fontWeight: FontWeight.w700)),
                        (listPay["content"].isEmpty)
                            ? Text("")
                            : (listPay["content"][0]["paidDate"] != null)
                                ? Text(
                                    "${FormatDate.formatDateView(DateTime.parse(listPay["content"][0]["paidDate"]))}")
                                : Text(""),
                      ],
                    ),
                  )
                ]),
              ),
              Expanded(
                flex: 1,
                child: Container(),
              )
            ],
          )),
          Container(
            // margin: marginTopBottomHorizontalLine,
            margin: EdgeInsets.only(top: 10),
            child: Divider(
              thickness: 1,
              color: ColorHorizontalLine,
            ),
          ),
        ],
      ),
      //Bảng chot ds
      content: Container(
          width: 600,
          height: 300,
          child: Container(
            child: Column(
              // padding: const EdgeInsets.all(16),
              children: [
                DataTable(
                  showCheckboxColumn: false,
                  columns: [
                    DataColumn(label: Text('STT', style: titleTableData)),
                    DataColumn(
                        label: Text('Mã nhân viên', style: titleTableData)),
                    DataColumn(
                        label: Text('Tên nhân viên', style: titleTableData)),
                    DataColumn(
                        label: Text('Số lượng TTS', style: titleTableData)),
                    DataColumn(label: Text('Tổng tiền', style: titleTableData)),
                  ],
                  rows: <DataRow>[
                    if (listCareUser1["content"] != null)
                      for (int i = 0; i < listCareUser1["content"].length; i++)
                        DataRow(
                          cells: <DataCell>[
                            DataCell(Text("${i + 1}")),
                            DataCell(Text(
                              listCareUser1["content"][i]["userCode"],
                              style: bangDuLieu,
                            )),

                            DataCell(Text(
                              listCareUser1["content"][i]["fullName"],
                              style: bangDuLieu,
                            )),

                            DataCell(
                              TextButton(
                                child: Text(
                                  listCountTrainee[listCareUser1["content"][i]
                                          ["id"]]
                                      .toString(),
                                ),
                                onPressed: () async {
                                  // var listTrainee = {};
                                  // var careUserId = listCareUser1["content"][i]["id"];
                                  // var response = await httpGet(
                                  //     "/api/nguoidung/get/page?filter=orderId:$selectedOrderId and careUser: $careUserId and isTts:1 and (ttsStatusId > 6)",
                                  //     context);
                                  // if (response.containsKey("body")) {
                                  //   listTrainee = jsonDecode(response["body"]);
                                  // }
                                  if (countTTS != 0) {
                                    int index = 1;
                                    final AlertDialog dialog1 = AlertDialog(
                                      title: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.55,
                                        child: SizedBox(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    height: 50,
                                                    width: 50,
                                                    child: Image.asset(
                                                        'assets/images/logoAAM.png'),
                                                    margin: EdgeInsets.only(
                                                        right: 10),
                                                  ),
                                                  Text(
                                                    'Danhh sách TTS',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        color:
                                                            Color(0xff333333),
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                                ],
                                              ),
                                              IconButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                icon: Icon(Icons.close),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      content: DataTable(
                                        showCheckboxColumn: false,
                                        columns: [
                                          DataColumn(
                                              label: Text('STT',
                                                  style: titleTableData)),
                                          DataColumn(
                                              label: Text('Mã TTS',
                                                  style: titleTableData)),
                                          DataColumn(
                                              label: Text('Tên TTS',
                                                  style: titleTableData)),
                                          DataColumn(
                                              label: Text('Ngày sinh',
                                                  style: titleTableData)),
                                          DataColumn(
                                              label: Text('Trạng thái',
                                                  style: titleTableData)),
                                        ],
                                        rows: <DataRow>[
                                          for (var row
                                              in listTraineeGroupByCareUser[
                                                  listCareUser1["content"][i]
                                                      ["id"]])
                                            DataRow(
                                              cells: <DataCell>[
                                                DataCell(Text("${index++}")),
                                                DataCell(Text(
                                                  (row != null)
                                                      ? row['thuctapsinh']
                                                              ["userCode"]
                                                          .toString()
                                                      : "",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                )),
                                                DataCell(
                                                  Text(
                                                      (row != null)
                                                          ? row['thuctapsinh']
                                                                  ["fullName"]
                                                              .toString()
                                                          : "",
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400)),
                                                ),
                                                DataCell(Text(
                                                    row['thuctapsinh']
                                                                ["birthDate"] !=
                                                            null
                                                        ? DateFormat(
                                                                "dd-MM-yyyy")
                                                            .format(DateTime.parse(
                                                                row['thuctapsinh']
                                                                    [
                                                                    "birthDate"]))
                                                        : "",
                                                    style: bangDuLieu)),
                                                DataCell(
                                                  Text(
                                                      row['thuctapsinh'][
                                                                  "ttsTrangthai"]
                                                              ["statusName"] ??
                                                          "nodata",
                                                      style: bangDuLieu),
                                                ),
                                              ],
                                            )
                                        ],
                                      ),
                                      actions: [],
                                    );
                                    showDialog<void>(
                                        context: context,
                                        builder: (context) => dialog1);
                                  }
                                },
                              ),
                            ),
                            DataCell(
                              Text(
                                NumberFormat.simpleCurrency(locale: "vi")
                                    .format((listOrderBonus *
                                        listCountTrainee[
                                            listCareUser1["content"][i]["id"]]))
                                    .toString(),
                                style: bangDuLieu,
                              ),
                            ),

                            //
                          ],
                        )
                  ],
                ),
              ],
            ),
          )),
      actions: <Widget>[
        if (countTTS != 0)
          ElevatedButton(
            // textColor: Color(0xFF6200EE),
            onPressed: () async {
              showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.25,
                              height: 80,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          child: Image.asset(
                                              'assets/images/logoAAM.png'),
                                          margin: EdgeInsets.only(right: 10),
                                        ),
                                        Text(
                                          'Tiêu đề',
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Color(0xff333333),
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: Icon(Icons.close),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        content: Container(
                          width: 50,
                          height: 150,
                          // color: Colors.black,
                          padding: EdgeInsets.only(top: 25),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 1,
                                color: Color(0xffD7D7D7),
                              ),
                              top: BorderSide(
                                width: 1,
                                color: Color(0xffD7D7D7),
                              ),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  TextFieldValidated(
                                    type: 'Text',
                                    height: 40,
                                    controller: title,
                                    label: 'Nhập tiêu đề',
                                    flexLable: 2,
                                    flexTextField: 4,
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
                              primary: Color(0xffFF7F10),
                              onPrimary: Color.fromARGB(221, 255, 255, 255),
                              // shadowColor: Colors.greenAccent,
                              elevation: 3,
                              // shape: RoundedRectangleBorder(
                              //     borderRadius: BorderRadius.circular(32.0)),
                              minimumSize: Size(140, 50), //////// HERE
                            ),
                          ),
                          ElevatedButton(
                            // textColor: Color(0xFF6200EE),
                            onPressed: () async {
                              await addOrderBonus();
                              if (rewardOfferId != 0) {
                                await addDetailOrderBonus();
                                await updateOrderBonus();
                                showToast(
                                    context: context,
                                    msg: "Gửi thanh toán thành công",
                                    color: Color(0xFF4CAF50),
                                    icon: Icon(Icons.supervised_user_circle));
                              }
                              addNotification() async {
                                try {
                                  var data = {
                                    "title": " Hệ thống thông báo",
                                    "message":
                                        'Có đề nghị mới thưởng đơn hàng $selectedOrderCode-$selectedOrderName',
                                  };
                                  await httpPost(
                                      '/api/push/tags/depart_id/2&6&9',
                                      data,
                                      context);
                                } catch (_) {
                                  print("Fail!");
                                }
                              }

                              await addNotification();
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Xác nhận',
                              style: TextStyle(),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Color.fromARGB(255, 255, 255, 255),
                              onPrimary: Color(0xffFF7F10),
                              // shadowColor: Colors.greenAccent,
                              elevation: 3,
                              // shape: RoundedRectangleBorder(
                              //     borderRadius: BorderRadius.circular(32.0)),
                              minimumSize: Size(140, 50), //////// HERE
                            ),
                          )
                        ],
                      ));
            },
            child: Text(
              'Gửi',
              style: TextStyle(),
            ),
            style: ElevatedButton.styleFrom(
              primary: Color.fromRGBO(245, 117, 29, 1),
              onPrimary: Colors.white,
              // shadowColor: Colors.greenAccent,
              elevation: 3,
              // shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(32.0)),
              minimumSize: Size(140, 50), //////// HERE
            ),
          )
        else
          ElevatedButton(
            onPressed: () {},
            child: Text(
              'Gửi',
              style: TextStyle(),
            ),
            style: ElevatedButton.styleFrom(
              primary: Color.fromARGB(255, 111, 111, 111),
              onPrimary: Colors.white,
              // shadowColor: Colors.greenAccent,
              elevation: 3,
              // shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(32.0)),
              minimumSize: Size(140, 50), //////// HERE
            ),
          )
      ],
    );
  }
}

late Future futureListDonhang;
var listDHH = {};
int rowPerPage = 10;
int rowCount = 0;
int totalElements = 0;
int currentPage = 0;
String selectedDH = "";
String selectedND = "";
Widget paging = Container();
var resultListOrderBonus = {};
var listOrderBonus;

class ThuongDonHangThongKe extends StatefulWidget {
  ThuongDonHangThongKe({Key? key}) : super(key: key);

  @override
  State<ThuongDonHangThongKe> createState() => _ThuongDonHangThongKeState();
}

class _ThuongDonHangThongKeState extends State<ThuongDonHangThongKe> {
  Future getListDonHang(page) async {
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }

    if (page < 1) {
      page = 0;
    }

    var response;
    if ((selectedDH == "" || selectedDH == "-1") &&
        (selectedND == "" || selectedND == '-1'))
      response = await httpGet(
          "/api/donhang/get/page?page=$page&size=$rowPerPage&filter=orderStatusId>1 and orderBonus:0 and stopProcessing:0",
          context); //thiếu (stopProcessing:0 or stopProcessing is null)
    else if ((selectedDH != "" || selectedDH != "-1") &&
        (selectedND == "" || selectedND == '-1')) {
      response = await httpGet(
          "/api/donhang/get/page?page=$page&size=$rowPerPage&filter=id:$selectedDH and orderBonus:0 and stopProcessing:0",
          context);
    } else if ((selectedDH == "" || selectedDH == "-1") &&
        (selectedND != "" || selectedND != '-1')) {
      response = await httpGet(
          "/api/donhang/get/page?page=$page&size=$rowPerPage&filter=nghiepdoan.id:$selectedND and orderBonus:0 and stopProcessing:0",
          context);
    } else {
      response = await httpGet(
          "/api/donhang/get/page?page=$page&size=$rowPerPage&filter=id:$selectedDH AND nghiepdoan.id:$selectedND and orderBonus:0 and stopProcessing:0",
          context);
    }
    if (response.containsKey("body")) {
      setState(() {
        currentPage = page;
        listDHH = jsonDecode(response["body"]);
        totalElements = listDHH["totalElements"];
      });
    }
    return 0;
  }

  Future<List<Order>> getListOrder() async {
    List<Order> resultOrder = [];
    var response1 = await httpGet("/api/donhang/get/page?sort=id", context);
    var body = jsonDecode(response1['body']);
    var content = [];
    if (response1.containsKey("body")) {
      setState(() {
        content = body['content'];
        resultOrder = content.map((e) {
          return Order.fromJson(e);
        }).toList();
        Order all = new Order(
            id: -1,
            orderName: "Tất cả",
            enterprise: null,
            jobs: null,
            orderCode: 'Tất cả',
            orderStatusId: 0,
            union: null);
        resultOrder.insert(0, all);
      });
    }
    return resultOrder;
  }

  Future getOrderBonus() async {
    var response = await httpGet(
        "/api/thuong-chitieu-donhang/get/page?filter=orderId:$selectedOrderId and approve:1",
        context);
    if (response.containsKey("body")) {
      setState(() {
        resultListOrderBonus = jsonDecode(response["body"]);
      });
    }
    for (var element in resultListOrderBonus["content"]) {
      listOrderBonus = element["orderBonus"];
    }
  }

  var resultListOrderBonus1 = {};
  Future getOrderBonus1() async {
    var response = await httpGet(
        "/api/thuong-chitieu-donhang/get/page?filter= approve:1", context);
    if (response.containsKey("body")) {
      setState(() {
        resultListOrderBonus1 = jsonDecode(response["body"]);
      });
    }
    // for (var element in resultListOrderBonus["content"]) {
    //   listOrderBonus = element["orderBonus"];
    // }
  }

  var order = {};
  Future getOrder() async {
    var response = await httpGet(
        "/api/donhang/get/page?filter=id:$selectedOrderId", context);
    if (response.containsKey("body")) {
      setState(() {
        order = jsonDecode(response["body"]);
      });
    }
    if (order["content"][0]["orderBonus"] != 0)
      check = true;
    else
      check = false;
  }

  Future getPaidDate() async {
    var response = await httpGet(
        "/api/thuong-chitieu-denghi/get/page?filter=orderId:$selectedOrderId",
        context);
    if (response.containsKey("body")) {
      listPay = jsonDecode(response["body"]);
    }
  }

  Future<List<UnionObj>> getListUnion() async {
    List<UnionObj> resultUnion = [];
    var response = await httpGet("/api/nghiepdoan/get/page?sort=id", context);
    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        content = body['content'];
        resultUnion = content.map((e) {
          return UnionObj.fromJson(e);
        }).toList();
        UnionObj all = new UnionObj(id: -1, orgName: "Tất cả");
        resultUnion.insert(0, all);
      });
    }
    return resultUnion;
  }

  var listDHH1 = {};
  getListOrder1() async {
    var response = await httpGet("/api/donhang/get/page", context);
    if (response.containsKey("body")) {
      setState(() {
        listDHH1 = jsonDecode(response["body"]);
      });
    }
  }

  var listBonus = {};
  dynamic orderBonus = {};
  getBonus() async {
    var response = await httpGet(
        "/api/thuong-chitieu-donhang/get/page?filter=approve:1", context);
    if (response.containsKey("body")) {
      setState(() {
        listBonus = jsonDecode(response["body"]);
      });
    }
    for (int i = 0; i < listDHH1["content"].length; i++) {
      for (int j = 0; j < listBonus["content"].length; j++) {
        if (listDHH1["content"][i]["id"] ==
            listBonus["content"][j]["orderId"]) {
          orderBonus[listDHH1["content"][i]["id"]] =
              listBonus["content"][j]["orderBonus"];
        }
      }
    }
  }

  int getIndex(page, rowPerPage, index) {
    return ((page * rowPerPage) + index) + 1;
  }

  @override
  void initState() {
    super.initState();
    futureListDonhang = getListDonHang(currentPage);
    getListOrder();
    getListUnion();
    getOrderBonus1();
    callApi();
  }

  callApi() async {
    await getListOrder1();
    await getBonus();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futureListDonhang,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (listDHH["content"].length > 0) {
              var firstRow = (currentPage) * rowPerPage + 1;
              var lastRow = (currentPage + 1) * rowPerPage;

              if (lastRow > listDHH["totalElements"]) {
                lastRow = listDHH["totalElements"];
              }
              paging = Row(
                children: [
                  Expanded(flex: 1, child: Container()),
                  const Text("Số dòng trên trang: "),
                  DropdownButton<int>(
                    value: rowPerPage,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    elevation: 16,
                    style: const TextStyle(color: Colors.deepPurple),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (int? newValue) {
                      setState(() {
                        rowPerPage = newValue!;
                        getListDonHang(currentPage);
                      });
                    },
                    items: <int>[2, 5, 10, 25, 50, 100]
                        .map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text("$value"),
                      );
                    }).toList(),
                  ),
                  Text(
                      "Dòng $firstRow - $lastRow của ${listDHH["totalElements"]}"),
                  IconButton(
                      onPressed: firstRow != 1
                          ? () {
                              getListDonHang(currentPage - 1);
                            }
                          : null,
                      icon: const Icon(Icons.chevron_left)),
                  IconButton(
                      onPressed: lastRow < listDHH["totalElements"]
                          ? () {
                              getListDonHang(currentPage + 1);
                            }
                          : null,
                      icon: const Icon(Icons.chevron_right)),
                ],
              );
            }
          }

          return Scaffold(
            body: ListView(children: [
              Container(
                color: backgroundPage,
                padding: EdgeInsets.symmetric(
                    vertical: verticalPaddingPage,
                    horizontal: horizontalPaddingPage),
                child: Container(
                  width: MediaQuery.of(context).size.width * 1,
                  decoration: BoxDecoration(
                    color: colorWhite,
                    borderRadius: borderRadiusContainer,
                    boxShadow: [boxShadowContainer],
                    border: borderAllContainerBox,
                  ),
                  padding: paddingBoxContainer,
                  child: Row(
                    children: [
                      Expanded(
                        // child: Padding(
                        //   padding: EdgeInsets.fromLTRB(60, 0, 0, 0),
                        child: Row(children: [
                          Text('Đơn hàng', style: titleWidgetBox),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(20, 0, 50, 0),
                              child: Container(
                                height: 40,
                                child: DropdownSearch<Order>(
                                  // ignore: deprecated_member_use
                                  hint: "Tất cả",
                                  maxHeight: 350,
                                  mode: Mode.MENU,
                                  showSearchBox: true,
                                  onFind: (String? filter) => getListOrder(),
                                  itemAsString: (Order? u) =>
                                      '${u!.orderName}' + '(${u.orderCode})',
                                  dropdownSearchDecoration: styleDropDown,
                                  onChanged: (value) {
                                    setState(() {
                                      idDH = value!.id;
                                      selectedDH = idDH.toString();
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          Text('Nghiệp đoàn', style: titleWidgetBox),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                              child: Container(
                                height: 40,
                                child: DropdownSearch<UnionObj>(
                                  // ignore: deprecated_member_use
                                  hint: "Tất cả",
                                  maxHeight: 350,
                                  mode: Mode.MENU,
                                  showSearchBox: true,
                                  onFind: (String? filter) => getListUnion(),
                                  itemAsString: (UnionObj? u) => u!.orgName!,
                                  dropdownSearchDecoration: styleDropDown,
                                  onChanged: (value) {
                                    setState(() {
                                      idND = value!.id;
                                      selectedND = idND.toString();
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                                margin: EdgeInsets.fromLTRB(50, 0, 50, 0),
                                child: Row(children: [
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 20.0,
                                        horizontal: 20.0,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      backgroundColor:
                                          Color.fromRGBO(245, 117, 29, 1),
                                      primary:
                                          Theme.of(context).iconTheme.color,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .caption
                                          ?.copyWith(
                                              fontSize: 10.0,
                                              letterSpacing: 2.0),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        futureListDonhang =
                                            getListDonHang(currentPage);
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Icon(Icons.search,
                                            color: Colors.white, size: 15),
                                        Text(' Tìm kiếm', style: textButton),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 150,
                                  ),
                                ])),
                          )
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                color: backgroundPage,
                padding:
                    EdgeInsets.symmetric(horizontal: horizontalPaddingPage),
                child: Container(
                  width: MediaQuery.of(context).size.width * 1,
                  decoration: BoxDecoration(
                    color: colorWhite,
                    borderRadius: borderRadiusContainer,
                    boxShadow: [boxShadowContainer],
                    border: borderAllContainerBox,
                  ),
                  padding: paddingBoxContainer,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 1,
                        child: DataTable(
                          showCheckboxColumn: false,
                          columns: [
                            DataColumn(
                                label: Text('STT', style: titleTableData)),
                            DataColumn(
                                label:
                                    Text('Mã đơn hàng', style: titleTableData)),
                            DataColumn(
                                label: Text('Tên đơn hàng',
                                    style: titleTableData)),
                            DataColumn(
                                label: Text('Cấu hình thưởng',
                                    style: titleTableData)),
                            DataColumn(
                                label:
                                    Text('Nghiệp đoàn', style: titleTableData)),
                          ],
                          rows: <DataRow>[
                            if (listDHH["content"] != null)
                              for (var i = 0;
                                  i < listDHH["content"].length;
                                  i++)
                                if (listDHH["content"][i]["orderBonus"] != 0 ||
                                    listDHH["content"][i]["orderBonus"] != null)
                                  DataRow(
                                    cells: <DataCell>[
                                      DataCell(Text(
                                        getIndex(currentPage, rowPerPage, i)
                                            .toString(),
                                      )),
                                      DataCell(TextButton(
                                        onPressed: () async {
                                          selectedOrderId =
                                              listDHH["content"][i]["id"];
                                          selectedOrderName = listDHH["content"]
                                              [i]["orderName"];
                                          selectedOrderCode = listDHH["content"]
                                              [i]["orderCode"];
                                          await getOrderBonus();
                                          await getOrder();
                                          await getPaidDate();
                                          (resultListOrderBonus["content"]
                                                  .isNotEmpty)
                                              ? _showMaterialDialog(
                                                  context, i, order)
                                              : showToast(
                                                  context: context,
                                                  msg:
                                                      "Đơn hàng chưa có cấu hình thưởng",
                                                  color: Colors.red,
                                                  icon: Icon(Icons.reddit));
                                        },
                                        child: Text(
                                          listDHH["content"][i]["orderCode"] ??
                                              "nodata",
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      )),
                                      DataCell(TextButton(
                                        onPressed: () async {
                                          selectedOrderId =
                                              listDHH["content"][i]["id"];
                                          selectedOrderName = listDHH["content"]
                                              [i]["orderName"];
                                          selectedOrderCode = listDHH["content"]
                                              [i]["orderCode"];
                                          await getOrderBonus();
                                          await getOrder();
                                          await getPaidDate();
                                          (resultListOrderBonus["content"]
                                                  .isNotEmpty)
                                              ? _showMaterialDialog(
                                                  context, i, order)
                                              : showToast(
                                                  context: context,
                                                  msg:
                                                      "Đơn hàng chưa có cấu hình thưởng",
                                                  color: Colors.red,
                                                  icon: Icon(Icons
                                                      .notification_important_rounded));
                                        },
                                        child: Text(
                                          listDHH["content"][i]["orderName"] ??
                                              "nodata",
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      )),
                                      DataCell(
                                        Container(
                                            child: Text(
                                                (orderBonus[listDHH["content"]
                                                            [i]["id"]] !=
                                                        null)
                                                    ? NumberFormat
                                                            .simpleCurrency(
                                                                locale: "vi")
                                                        .format(orderBonus[
                                                            listDHH["content"]
                                                                [i]["id"]])
                                                        .toString()
                                                    : "",
                                                style: bangDuLieu)),
                                      ),
                                      DataCell(
                                        Container(
                                            width: 200,
                                            child: Text(
                                                listDHH["content"][i]
                                                            ["nghiepdoan"]
                                                        ["orgName"] ??
                                                    "nodata",
                                                style: bangDuLieu)),
                                      ),
                                    ],
                                  )
                          ],
                        ),
                      ),
                      paging
                    ],
                  ),
                ),
              ),
              Footer(
                  marginFooter: EdgeInsets.only(top: 25),
                  paddingFooter: EdgeInsets.all(15))
            ]),
          );
        });
  }
}
