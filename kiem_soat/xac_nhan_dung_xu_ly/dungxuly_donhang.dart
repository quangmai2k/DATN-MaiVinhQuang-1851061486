import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/widgets_form.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../api.dart';
import '../../../../common/format_date.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';
import '../../../../model/model.dart';

// ignore: camel_case_types
class DXL_DH extends StatefulWidget {
  const DXL_DH({Key? key}) : super(key: key);

  @override
  State<DXL_DH> createState() => _DXL_DHState();
}

// ignore: camel_case_types
class _DXL_DHState extends State<DXL_DH> {
  String getDateViewDayAndHour(String? date) {
    try {
      if (date == null) {
        return "Không có dữ liệu";
      }
      var inputFormat = DateFormat('yyyy-MM-ddThh:mm:ss');
      var inputDate = inputFormat.parse(date); // <-- dd/MM 24H format
      var outputFormat = DateFormat('HH:mm dd/MM/yyyy');
      var outputDate = outputFormat.format(inputDate);
      return outputDate;
    } catch (e) {}
    return "Không có dữ liệu";
  }

  final TextEditingController _donHang = TextEditingController();
  final TextEditingController _lyDo = TextEditingController();
  bool flag = true;
  var listDH1;
  String? fileName;
  putDungXuLyDonHang() async {
    String request = '';
    for (int i = 0; i < idList.length; i++) {
      if (idList[i] != null) {
        request += idList[i].toString();
        if (i < idList.length - 1) {
          request += ',';
        }
      }
    }
    if (idList.isEmpty) request = "0";
    var response = await httpGet("/api/tts-donhang-dungxuly/get/page?filter=id in ($request)", context);
    if (response.containsKey("body")) {
      setState(() {
        listDH1 = jsonDecode(response["body"])['content'];
      });
    }
    // try {
    print("listDH1.length:${listDH1.length}");

    dynamic data = {"orderStatusId": 5};
    dynamic data1 = {"approvalType": 1, "relateFile": fileName};
    for (int i = 0; i < listDH1.length; i++) {
      await httpPut('/api/donhang/put/${listDH1[i]['orderId']}', data, context); //Tra ve id
      await httpPut('/api/tts-donhang-dungxuly/put/${listDH1[i]['id']}', data1, context);

      addNotification() async {
        try {
          var data = {
            "title": "Hệ thống thông báo",
            "message": 'Đơn hàng có mã' +
                ' ${listDH1[i]['donhang']['orderCode']}' +
                ' đã dừng xử lý lúc lúc ${getDateViewDayAndHour(listDH1[i]['createdDate'])}.',
          };
          await httpPost('/api/push/tags/depart_id/1&2&3&4&5&6&7&8&9&10', data, context);
        } catch (_) {
          print("Fail!");
        }
      }

      await addNotification();
    }
    // } catch (_) {
    //   // print(listDH1['content']['orderId']);
    //   print("Fail!");
    // }
  }

  putDonHangTienCuLai() async {
    String request = '';
    for (int i = 0; i < idList.length; i++) {
      if (idList[i] != null) {
        request += idList[i].toString();
        if (i < idList.length - 1) {
          request += ',';
        }
      }
    }
    if (idList.isEmpty) request = "0";
    var response = await httpGet("/api/tts-donhang-dungxuly/get/page?filter=id in ($request)", context);
    if (response.containsKey("body")) {
      setState(() {
        listDH1 = jsonDecode(response["body"])['content'];
      });
    }
    // try {
    print("listDH1.length:${listDH1.length}");

    dynamic data = {"stopProcessing": 0, "isTts": 1};
    for (int i = 0; i < listDH1.length; i++) {
      await httpPut('/api/donhang/put/${listDH1[i]['orderId']}', data, context); //Tra ve id
    }
    // dynamic data1={}
  }

  putDonHangTienCuLai1(String approvalContent, int userID) async {
    String request = '';
    for (int i = 0; i < idList.length; i++) {
      if (idList[i] != null) {
        request += idList[i].toString();
        if (i < idList.length - 1) {
          request += ',';
        }
      }
    }
    if (idList.isEmpty) request = "0";
    var response = await httpGet("/api/tts-donhang-dungxuly/get/page?filter=id in ($request)", context);
    if (response.containsKey("body")) {
      setState(() {
        listDH1 = jsonDecode(response["body"])['content'];
      });
    }

    for (int i = 0; i < listDH1.length; i++) {
      listDH1[i]['approvalContent'] = approvalContent;
      listDH1[i]['approvalType'] = 2;
      listDH1[i]['approvalUser'] = userID;
      listDH1[i]['approvalDate'] = FormatDate.formatDateInsertDB(DateTime.now());
      await httpPut('/api/tts-donhang-dungxuly/put/${listDH1[i]['id']}', listDH1[i], context);

      addNotification() async {
        try {
          var data = {
            "title": "Kiểm soát thông báo",
            "message": 'Đơn hàng có mã' +
                '${listDH1[i]['donhang']['userCode']}' +
                ' đã dừng xử lý lúc lúc ${getDateViewDayAndHour(listDH1[i]['createdDate'])}.',
          };
          await httpPost('/api/push/tags/depart_id/5', data, context);
        } catch (_) {
          print("Fail!");
        }
      }

      await addNotification();
    }
  }

  var listRelateFile = {};
  getFile() async {
    String request = '';
    for (int i = 0; i < idList.length; i++) {
      if (idList[i] != null) {
        request += idList[i].toString();
        if (i < idList.length - 1) {
          request += ',';
        }
      }
    }
    if (idList.isEmpty) request = "0";
    var response = await httpGet("/api/tts-donhang-dungxuly/get/page?filter=id in ($request)", context);
    if (response.containsKey("body")) {
      setState(() {
        listRelateFile = jsonDecode(response["body"]);
      });
    }
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return Consumer2<NavigationModel, SecurityModel>(
            builder: (context, navigationModel, user, child) => StatefulBuilder(
                builder: (BuildContext context, StateSetter _setState) => AlertDialog(
                      title: Column(
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                "assets/images/logoAAM.png",
                                width: 30,
                                height: 30,
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: Text('Phê duyệt', style: titleAlertDialog),
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          Navigator.pop(context);
                                        });
                                      },
                                      child: Icon(Icons.close)),
                                ),
                              )
                            ],
                          ),
                          Divider(
                            thickness: 1,
                            color: Colors.black,
                          ),
                        ],
                      ),
                      content: Container(
                        width: 450,
                        height: 100,
                        child: Column(
                          children: <Widget>[
                            flag == true
                                ? Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Thông tin liên quan:',
                                            style: titleTableData,
                                          ),
                                        ],
                                      ),
                                      for (int i = 0; i < listRelateFile["content"].length; i++)
                                        Row(
                                          children: [
                                            Text("${listRelateFile['content'][i]["donhang"]['orderCode']} : "),
                                            TextButton(
                                              child: (listRelateFile["content"][i]["realateFile"] == null ||
                                                      listRelateFile["content"][i]["realateFile"] == "")
                                                  ? Icon(
                                                      Icons.upload_file,
                                                      color: Colors.blue[400],
                                                    )
                                                  : Text("${listRelateFile["content"][i]["realateFile"]}"),
                                              onPressed: () async {
                                                var file = await FilePicker.platform.pickFiles(
                                                  type: FileType.custom,
                                                  allowedExtensions: ['pdf', 'docx', 'jpeg', 'png', 'jpg'],
                                                  withReadStream: true, //
                                                );
                                                if (file != null) {
                                                  fileName = await uploadFile(file, context: context);
                                                  _setState(() {
                                                    listRelateFile["content"][i]["realateFile"] = fileName;
                                                    // print("fileName1:${listRelateFile["content"][i]["realateFile"]}");
                                                  });
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      Container(
                                          child: Row(
                                        children: [
                                          Expanded(child: Text("Lý do từ chối")),
                                        ],
                                      )),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 20),
                                        child: Container(
                                          // width: MediaQuery.of(context).size.width * 0.15,
                                          height: 60,
                                          child: TextField(
                                            controller: _lyDo,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  width: 3,
                                                  color: Colors.black,
                                                ),
                                                borderRadius: BorderRadius.circular(0.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: Divider(
                            thickness: 1,
                            color: Colors.grey,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            flag == false
                                ? Container(
                                    width: 120,
                                    height: 40,
                                    child: OutlinedButton(
                                        style: ElevatedButton.styleFrom(
                                          onPrimary: Color(0xffF77919), // Background color
                                        ),
                                        onPressed: () async {
                                          // Navigator.pop(context);

                                          _setState(() {
                                            flag = true;
                                          });
                                        },
                                        child: Text('Hủy')),
                                  )
                                : Container(
                                    width: 120,
                                    height: 40,
                                    child: OutlinedButton(
                                        style: ElevatedButton.styleFrom(
                                          onPrimary: Color(0xffF77919), // Background color
                                        ),
                                        onPressed: () async {
                                          // Navigator.pop(context);

                                          _setState(() {
                                            flag = false;
                                          });
                                        },
                                        child: Text('Từ chối')),
                                  ),
                            flag == false
                                ? Container(
                                    width: 120,
                                    height: 40,
                                    padding: EdgeInsets.only(left: 20),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: Color(0xffF77919),
                                        onPrimary: Colors.white, // Background color
                                      ),
                                      onPressed: () async {
                                        //
                                        // await putDungXuLyDonHang();
                                        await putDonHangTienCuLai();
                                        await putDonHangTienCuLai1(_lyDo.text, user.userLoginCurren["id"]);
                                        await getDonHangDungXuLy(currentPage, findSearch);

                                        setState(() {
                                          // navigationModel.add(pageUrl: "/xac-nhan-dung-xu-ly");
                                        });
                                        // updateqcApproval();
                                        Navigator.pop(context);
                                      },
                                      child: Text('Xác nhận'),
                                    ),
                                  )
                                : Container(
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

                                        await putDungXuLyDonHang();
                                        await getDonHangDungXuLy(currentPage, findSearch);

                                        setState(() {
                                          // navigationModel.add(pageUrl: "/xac-nhan-dung-xu-ly");
                                        });
                                        // updateqcApproval();
                                      },
                                      child: Text('Duyệt'),
                                    ),
                                  )
                          ],
                        ),
                      ],
                    )));
      },
    );
  }

  dynamic idSelectedDonHang;
  bool checkSelected = false;
  // List<bool> _selected = [];
  List listOrderDungXuLy = [];
  var totalElements = 0;
  var firstRow = 0;
  var rowPerPage = 10;
  var currentPage = 0;
  Widget paging = Container();
  late Future futureListDHDXL;
  String findSearch = "";

  var listHD = {};
  var idList = [];
  List<bool> _selectedData = [];
  Future getDonHangDungXuLy(page, String findSearch) async {
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
      print(page);
    }
    if (page < 1) {
      page = 0;
    }
    // print('quan');
    var response;
    if (findSearch == "") {
      response = await httpGet("/api/tts-donhang-dungxuly/get/page?page=$page&size=$rowPerPage&filter=itemType:1 &sort=approvalType", context);
    } else {
      response =
          await httpGet("/api/tts-donhang-dungxuly/get/page?page=$page&size=$rowPerPage&filter=itemType:1 $findSearch &sort=approvalType", context);
    }
    // var response = await httpGet("api/donhang/get/page?page=$page&size=$rowPerPage&filter=itemType:1", context);

    // print('quan');
    // print("api/tts-donhang-dungxuly/get/page?page=$page&size=$rowPerPage&filter=itemType:1");
    if (response.containsKey("body")) {
      setState(() {
        currentPage = page;
        listHD = jsonDecode(response["body"]);
        totalElements = listHD["totalElements"];
        _selectedData = List<bool>.generate(listHD.length, (int index) => false);
      });
    }
    return listHD;
  }

  void initState() {
    super.initState();
    futureListDHDXL = getDonHangDungXuLy(currentPage, findSearch);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationModel>(
        builder: (context, navigationModel, child) => FutureBuilder(
              future: futureListDHDXL,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var tableIndex = (currentPage) * rowPerPage + 1;
                  if (listHD["content"].length > 0) {
                    var firstRow = (currentPage) * rowPerPage + 1;
                    var lastRow = (currentPage + 1) * rowPerPage;
                    if (lastRow > listHD["totalElements"]) {
                      lastRow = listHD["totalElements"];
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
                              getDonHangDungXuLy(currentPage, findSearch);
                            });
                          },
                          items: <int>[2, 5, 10, 25, 50, 100].map<DropdownMenuItem<int>>((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text("$value"),
                            );
                          }).toList(),
                        ),
                        Text("Dòng $firstRow - $lastRow của ${listHD["totalElements"]}"),
                        InkWell(
                            onTap: firstRow != 1
                                ? () {
                                    getDonHangDungXuLy(currentPage - 1, findSearch);
                                    //print(currentPage - 1);
                                  }
                                : null,
                            child: (firstRow != 1)
                                ? Icon(Icons.chevron_left)
                                : Icon(
                                    Icons.chevron_left,
                                    color: Colors.grey,
                                  )),
                        InkWell(
                            onTap: lastRow < listHD["totalElements"]
                                ? () {
                                    getDonHangDungXuLy(currentPage + 1, findSearch);
                                    //print(currentPage + 1);
                                  }
                                : null,
                            child: (lastRow < listHD["totalElements"])
                                ? Icon(Icons.chevron_right)
                                : Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey,
                                  )),
                      ],
                    );
                  }

                  return ListView(
                    controller: ScrollController(),
                    // mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        color: backgroundPage,
                        padding: EdgeInsets.symmetric(vertical: verticalPaddingPage, horizontal: horizontalPaddingPage),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 1,
                              decoration: BoxDecoration(
                                color: colorWhite,
                                borderRadius: borderRadiusContainer,
                                boxShadow: [boxShadowContainer],
                                border: borderAllContainerBox,
                              ),
                              padding: paddingBoxContainer,
                              child: Column(children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Nhập thông tin',
                                      style: titleBox,
                                    ),
                                    Icon(
                                      Icons.more_horiz,
                                      color: Color(0xff9aa5ce),
                                      size: 14,
                                    ),
                                  ],
                                ),
                                //Đường line
                                Container(
                                  margin: marginTopBottomHorizontalLine,
                                  child: Divider(
                                    thickness: 1,
                                    color: ColorHorizontalLine,
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Text('Đơn hàng', style: titleWidgetBox),
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: Container(
                                                  // width: MediaQuery.of(context).size.width * 0.15,
                                                  height: 40,
                                                  child: TextField(
                                                    controller: _donHang,
                                                    decoration: InputDecoration(
                                                      border: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          width: 3,
                                                          color: Colors.black,
                                                        ),
                                                        borderRadius: BorderRadius.circular(0.0),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 200),
                                      Expanded(
                                        flex: 5,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Container(
                                                height: 40,
                                                width: 95,
                                                margin: EdgeInsets.only(left: 20),
                                                child: TextButton(
                                                  style: TextButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(
                                                      vertical: 15.0,
                                                      horizontal: 10.0,
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(5.0),
                                                    ),
                                                    backgroundColor: (checkSelected == true) ? Color.fromRGBO(245, 117, 29, 1) : Colors.grey,
                                                    primary: Theme.of(context).iconTheme.color,
                                                    textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                                  ),
                                                  onPressed: (checkSelected == true)
                                                      ? () {
                                                          setState(() async {
                                                            await getFile();
                                                            _showMyDialog();
                                                          });
                                                        }
                                                      : null,
                                                  child: Text('Dừng xử lý', style: textButton),
                                                ),
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(left: 20),
                                                width: 105,
                                                height: 40,
                                                child: TextButton(
                                                  style: TextButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(
                                                      vertical: 15.0,
                                                      horizontal: 10.0,
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(5.0),
                                                    ),
                                                    backgroundColor: Color.fromRGBO(245, 117, 29, 1),
                                                    primary: Theme.of(context).iconTheme.color,
                                                    textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                                  ),
                                                  onPressed: () async {
                                                    findSearch = "";
                                                    var donHang;
                                                    if (_donHang.text != "") {
                                                      donHang = "and donhang.orderName~'*${_donHang.text}*' ";
                                                    } else {
                                                      donHang = "";
                                                    }
                                                    findSearch = donHang;
                                                    getDonHangDungXuLy(0, findSearch);
                                                    checkSelected = false;
                                                    idList.clear();
                                                    setState(() {
                                                      print(idList);
                                                    });
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.only(right: 10),
                                                        child: Icon(Icons.search, color: Colors.white, size: 15),
                                                      ),
                                                      Center(child: Text('Tìm kiếm', style: textButton)),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(flex: 0, child: Container()),
                                    ],
                                  ),
                                ),
                              ]),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: backgroundPage,
                        padding: EdgeInsets.symmetric(vertical: verticalPaddingPage, horizontal: horizontalPaddingPage),
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
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Bảng thông tin',
                                    style: titleBox,
                                  ),
                                  Icon(
                                    Icons.more_horiz,
                                    color: colorIconTitleBox,
                                    size: 14,
                                  ),
                                ],
                              ),
                              //Đường line
                              Container(
                                margin: marginTopBottomHorizontalLine,
                                child: Divider(
                                  thickness: 1,
                                  color: ColorHorizontalLine,
                                ),
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        //flex: 20,
                                        child: DataTable(
                                          //columnSpacing:160,
                                          showCheckboxColumn: true,
                                          columnSpacing: 0,
                                          columns: <DataColumn>[
                                            DataColumn(label: Text("STT", style: titleTableData)),
                                            DataColumn(label: Text("Mã đơn hàng", style: titleTableData)),
                                            DataColumn(label: Text("Tên đơn hàng", style: titleTableData)),
                                            DataColumn(label: Text("Nội dung", style: titleTableData)),
                                            DataColumn(label: Text("File", style: titleTableData)),
                                            DataColumn(label: Text("Trạng thái", style: titleTableData)),
                                          ],
                                          rows: <DataRow>[
                                            for (int i = 0; i < listHD["content"].length; i++)
                                              DataRow(
                                                cells: [
                                                  DataCell(Text("${tableIndex + i}", style: bangDuLieu)),
                                                  DataCell(Text(listHD["content"][i]['donhang']["orderCode"] ?? "no data",
                                                      // "",
                                                      style: bangDuLieu)),
                                                  DataCell((listHD["content"][i]["approvalType"] != 2)
                                                      ? Container(
                                                          width: 200,
                                                          child: Text(listHD["content"][i]['donhang']["orderName"] ?? "no data",
                                                              // "",
                                                              style: bangDuLieu),
                                                        )
                                                      : Container(
                                                          width: 200,
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons.warning_amber_rounded,
                                                                color: Colors.red,
                                                              ),
                                                              Text(listHD["content"][i]['donhang']["orderName"] ?? "no data",
                                                                  // "",
                                                                  style: bangDuLieu),
                                                            ],
                                                          ),
                                                        )),
                                                  DataCell(Container(
                                                    width: 200,
                                                    child: Text(listHD["content"][i]["causeContent"] ?? "no data",
                                                        // 'Dừng xử lý đơn hàng cần phê duyệt',
                                                        style: bangDuLieu),
                                                  )),
                                                  DataCell((listHD["content"][i]["relateFile"]) != null
                                                      ? TextButton(
                                                          child: Text(
                                                            listHD["content"][i]["relateFile"],
                                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                                                          ),
                                                          onPressed: () {
                                                            downloadFile(listHD["content"][i]["relateFile"]);
                                                          },
                                                        )
                                                      : Container()),
                                                  DataCell((listHD["content"][i]["donhang"]["orderStatusId"] != 5)
                                                      ? Text("Tạm dừng xử lý",
                                                          // "",
                                                          style: bangDuLieu)
                                                      : (listHD["content"][i]["donhang"]["trangthai_donhang"]["statusName"] != null)
                                                          ? Text(listHD["content"][i]["donhang"]["trangthai_donhang"]["statusName"], style: bangDuLieu)
                                                          : Container()),

                                                  //
                                                ],
                                                selected: _selectedData[i],
                                                onSelectChanged: (bool? selected) {
                                                  setState(() {
                                                    _selectedData[i] = selected!;
                                                    if (listHD['content'][i]['approvalType'] == 2) {
                                                      _selectedData[i] = false;
                                                      showToast(
                                                          context: context,
                                                          msg: "Yêu cầu đã bị từ chối",
                                                          color: Colors.red,
                                                          icon: Icon(Icons.warning));
                                                    }else if (listHD["content"][i]["donhang"]["orderStatusId"] == 5) {
                                                      _selectedData[i] = false;
                                                      showToast(
                                                          context: context,
                                                          msg: "Đơn hàng đã dừng xử lý",
                                                          color: Colors.red,
                                                          icon: Icon(Icons.warning));
                                                    }
                                                    idSelectedDonHang = listHD['content'][i]['id'];

                                                    if (_selectedData[i])
                                                      idList.add(idSelectedDonHang);
                                                    else
                                                      idList.remove(idSelectedDonHang);
                                                    if (idList.length > 0) {
                                                      checkSelected = true;
                                                    } else {
                                                      checkSelected = false;
                                                    }
                                                  });
                                                },
                                              )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (totalElements != 0)
                                paging
                              else
                                Center(
                                    child: Text("Không có kết quả phù hợp",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ))),
                            ],
                          ),
                        ),
                      ),
                      Footer()
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return const Center(child: CircularProgressIndicator());
              },
            ));
  }
}
