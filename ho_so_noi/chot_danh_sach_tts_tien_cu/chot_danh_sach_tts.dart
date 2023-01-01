import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/api.dart';
import 'package:gentelella_flutter/common/toast.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../common/stopprocessing.dart';
import '../../../../common/style.dart';

import '../../../../model/model.dart';
import '../../../../model/type.dart';
import '../../navigation.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
final TextEditingController textEditingController = TextEditingController();

bool checkSelected = false;

RxString dataSelect = "Chờ tiến cử lại".obs;
RxString dataSelect1 = "Do cá nhân".obs;
final String urlAddNewUpdateSI = "quan-ly-ho-so-tts/trainee-information";
late List<TableDSTTS> listSelectedRow;
var resultListNguoiDung = {};
var resultTTSTienCu = {};
var resultListPay = {};
// ignore: unused_element
var _selectedDataRow = [];
String? selectedValueDH;
String dropdownValue = 'Tất cả';
String selectedDH = "";
String selectedStatus = "";
var resultDonHangDropDown = {};
var ipDH;
var resultColseTheListTrainee = {};
var totalElements = 0;
var contentDonHang = [];
late Future futureListDonhang;
var resultUpdateTtsStatusId = {};

var currentPage = 0;
var totalElementsDonHang = 0;
Widget paging = Container();
var firstRow = 0;
var rowPerPage = 10;
var listDHH;
var listTTS;
var resultListOrder = {};
var ipBp;
var timeNeed;
var idTTS;

class ChotDachSachTienCu extends StatefulWidget {
  ChotDachSachTienCu({Key? key}) : super(key: key);

  @override
  _ChotDachSachTienCuState createState() => _ChotDachSachTienCuState();
}

class _ChotDachSachTienCuState extends State<ChotDachSachTienCu> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: ChotDachSachTienCuBody());
  }
}

class ChotDachSachTienCuBody extends StatefulWidget {
  ChotDachSachTienCuBody({Key? key}) : super(key: key);

  @override
  State<ChotDachSachTienCuBody> createState() => _ChotDachSachTienCuBodyState();
}

class _ChotDachSachTienCuBodyState extends State<ChotDachSachTienCuBody> {
  late Future<ChotDachSachTienCuBody> futureAlbum;

  Future<void> _showMaterialDialog(idSelectedDonHang, context) async {
    var response = await httpGet(
        "/api/donhang-tts-tiencu/get/page?filter=orderId:$idSelectedDonHang AND qcApproval:1 and ptttApproval:1",
        context);

    if (response.containsKey("body")) {
      setState(() {
        resultTTSTienCu = jsonDecode(response["body"]);
      });
      var response1 = await httpGet(
          "/api/tts-thanhtoan/get/page?filter=orderId:$idSelectedDonHang and nguoidung.ttsStatusId:5",
          context);

      if (response1.containsKey("body")) {
        setState(() {
          resultListNguoiDung = jsonDecode(response1["body"]);
          _selectedDataRow = List<bool>.generate(
              resultListNguoiDung.length, (int index) => false);
        });
        // print("thang9999");
        for (int i = 0; i < resultListNguoiDung["content"].length; i++)
          if (resultListNguoiDung["content"][i]["nguoidung"]["gender"] == 0)
            resultListNguoiDung["content"][i]["nguoidung"]["gender"] = 'Nam';
          else if (resultListNguoiDung["content"][i]["nguoidung"]["gender"] ==
              1)
            resultListNguoiDung["content"][i]["nguoidung"]["gender"] = 'Nữ';
          else
            resultListNguoiDung["content"][i]["nguoidung"]["gender"] = 'Khác';
        //}
      }
    }

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          updateTtsStatusId() async {
            for (int i = 0; i < resultListNguoiDung["content"].length; i++) {
              try {
                var data = {"ttsStatusId": 6};
                await httpPut(
                    Uri.parse(
                        '/api/nguoidung/put/${resultListNguoiDung["content"][i]["ttsId"]}'),
                    data,
                    context); //Tra ve id

                print("thaida detail success");
              } catch (_) {
                print("Fail!");
              }
            }
          }

          updateOrderStatus() async {
            for (int i = 0; i < resultListNguoiDung["content"].length; i++) {
              try {
                var data = {
                  "nominateStatus": 1,
                  "closeNominateDate": DateTime.now()
                };
                await httpPut(Uri.parse('/api/donhang/put/$idSelectedDonHang'),
                    data, context);
                print("thaida detail success");
              } catch (_) {
                print("Fail!");
              }
            }
          }

          return Consumer<ButtonDungXuLy>(
              builder: (context, btnDungXuLy, child) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        child: Image.asset('images/logoAAM.png'),
                        margin: EdgeInsets.only(right: 10),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Chốt danh sách thực tập sinh tiến cử',
                              style: titleBox),
                          for (int i = 0;
                              i < resultListNguoiDung["content"].length;
                              i++)
                            Text(
                              resultListNguoiDung["content"][i]["donhang"]
                                      ["orderName"]
                                  .toString(),
                            )
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      btnDungXuLy.button = false;
                    },
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              //Bảng chot ds
              content: Container(
                width: 900,
                height: 400,
                child: TableTTS(),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (int i = 0;
                        i < resultListNguoiDung["content"].length;
                        i++)
                      //Điều kiện button Dừng xử lý
                      if (btnDungXuLy.button == true &&
                          resultListNguoiDung["content"][i]["paidBeforeExam"] ==
                              0)
                        TextButton(
                          // textColor: Color(0xFF6200EE),
                          onPressed: () {
                            showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: ((BuildContext context) =>
                                    Stopprocessing(
                                      titleDialog: 'Dừng xử lý',
                                      ttsId: idTTS,
                                      donhangId: null,
                                      doituong: 0,
                                    )));
                          },
                          child: Text(
                            'Dừng xử lý',
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
                      else if (btnDungXuLy.button == true &&
                          resultListNguoiDung["content"][i]["paidBeforeExam"] ==
                              1)
                        TextButton(
                          //textColor: Color(0xFF6200EE),
                          onPressed: () {},
                          child: Text(
                            'Dừng xử lý',
                            style: TextStyle(),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Color.fromARGB(255, 115, 115, 115),
                            onPrimary: Colors.white,
                            // shadowColor: Colors.greenAccent,
                            elevation: 3,
                            // shape: RoundedRectangleBorder(
                            //     borderRadius: BorderRadius.circular(32.0)),
                            minimumSize: Size(140, 50), //////// HERE
                          ),
                        )
                      else if (btnDungXuLy.button == false)
                        TextButton(
                          //textColor: Color(0xFF6200EE),
                          onPressed: () {},
                          child: Text(
                            'Dừng xử lý',
                            style: TextStyle(),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Color.fromARGB(255, 115, 115, 115),
                            onPrimary: Colors.white,
                            // shadowColor: Colors.greenAccent,
                            elevation: 3,
                            // shape: RoundedRectangleBorder(
                            //     borderRadius: BorderRadius.circular(32.0)),
                            minimumSize: Size(140, 50), //////// HERE
                          ),
                        ),

                    //Điều kiện button Chốt
                    for (int i = 0;
                        i < resultListNguoiDung["content"].length;
                        i++)
                      if (btnDungXuLy.button == true &&
                          resultListNguoiDung["content"][i]["paidBeforeExam"] ==
                              1)
                        Container(
                          margin: EdgeInsets.fromLTRB(400, 0, 10, 0),
                          child: ElevatedButton(
                            onPressed: () {
                              btnDungXuLy.button = false;
                              updateTtsStatusId();
                              updateOrderStatus();
                              Navigator.pop(context);
                              showToast(
                                  context: context,
                                  msg: "Chốt thành công!",
                                  color: Colors.green,
                                  icon: Icon(Icons.supervised_user_circle));
                            },
                            child: Text(
                              'Chốt',
                              style: TextStyle(),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Color.fromRGBO(245, 117, 29, 1),
                              onPrimary: Colors.white,
                              elevation: 3,
                              minimumSize: Size(140, 50),
                            ),
                          ),
                        )
                      else if (btnDungXuLy.button == true &&
                          resultListNguoiDung["content"][0]["paidBeforeExam"] ==
                              0)
                        Container(
                          margin: EdgeInsets.fromLTRB(400, 0, 10, 0),
                          child: ElevatedButton(
                            onPressed: () {},
                            child: Text(
                              'Chốt',
                              style: TextStyle(),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Color.fromARGB(255, 115, 115, 115),
                              onPrimary: Colors.white,
                              elevation: 3,
                              minimumSize: Size(140, 50),
                            ),
                          ),
                        )
                      else if (btnDungXuLy.button == false)
                        Container(
                          margin: EdgeInsets.fromLTRB(400, 0, 10, 0),
                          child: ElevatedButton(
                            onPressed: () {},
                            child: Text(
                              'Chốt',
                              style: TextStyle(),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Color.fromARGB(255, 115, 115, 115),
                              onPrimary: Colors.white,
                              elevation: 3,
                              minimumSize: Size(140, 50),
                            ),
                          ),
                        ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        btnDungXuLy.button = false;
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
                        primary: Colors.white,
                        onPrimary: Color.fromRGBO(245, 117, 29, 1),
                        minimumSize: Size(140, 50), //////// HERE
                      ),
                    ),
                  ],
                )
              ],
            );
          });
        });
  }

  @override
  void initState() {
    super.initState();
    futureListDonhang = getListDonHang(currentPage);
    getDonHangDropDown();
  }

  Map<int, String> status = {0: "Tất cả", 1: "Đã chốt", 2: "Chưa chốt"};
  Map<int, String> orderName = {0: "Tất cả"};

  getDonHangDropDown() async {
    var response = await httpGet("/api/donhang/get/page?sort=id,asc", context);

    if (response.containsKey("body")) {
      setState(() {
        resultDonHangDropDown = jsonDecode(response["body"]);

        for (int i = 0; i < resultDonHangDropDown["content"].length; i++) {
          orderName[resultDonHangDropDown["content"][i]["id"]] =
              resultDonHangDropDown["content"][i]["orderName"] +
                  '(${resultDonHangDropDown["content"][i]["orderCode"]})';
        }
      });
    }
  }

  Future getListDonHang(page) async {
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }

    if (page < 1) {
      page = 0;
    }

    var response;
    if (selectedDH == "" || selectedDH == "0")
      response = await httpGet(
          "/api/donhang/get/page?page=$page&size=$rowPerPage&sort=id&filter=orderStatusId:2",
          context);
    else {
      response = await httpGet(
          "/api/donhang/get/page?page=$page&size=$rowPerPage&sort=id&filter=id:$selectedDH and orderStatusId:2",
          context);
    }
    if (response.containsKey("body")) {
      setState(() {
        currentPage = page;
        listDHH = jsonDecode(response["body"]);
        totalElements = listDHH["totalElements"];
      });
    }
    return listDHH;
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
                            print(currentPage - 1);
                          }
                        : null,
                    icon: const Icon(Icons.chevron_left)),
                IconButton(
                    onPressed: lastRow < listDHH["totalElements"]
                        ? () {
                            getListDonHang(currentPage + 1);
                            print(currentPage + 1);
                          }
                        : null,
                    icon: const Icon(Icons.chevron_right)),
              ],
            );
          }
          return Scaffold(
              key: _scaffoldKey,
              body: Consumer<NavigationModel>(
                builder: (context, navigationModel, child) =>
                    ListView(children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 1,
                    decoration: BoxDecoration(
                      color: colorWhite,
                      boxShadow: [boxShadowContainer],
                      border: Border(
                        bottom: borderTitledPage,
                      ),
                    ),
                    padding: paddingTitledPage,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Home',
                              style: TextStyle(color: Color(0xff009C87)),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 5, right: 5),
                              child: Text(
                                '/',
                                style: TextStyle(
                                  color: Color(0xffC8C9CA),
                                ),
                              ),
                            ),
                            Text('Hồ sơ nội',
                                style: TextStyle(color: Color(0xff009C87))),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text('Chốt danh sách TTS tiến cử', style: titlePage),
                      ],
                    ),
                  ),
                  Container(
                    color: backgroundPage,
                    padding: EdgeInsets.symmetric(
                        vertical: verticalPaddingPage,
                        horizontal: horizontalPaddingPage),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 1,
                            decoration: BoxDecoration(
                              color: colorWhite,
                              borderRadius: borderRadiusContainer,
                              boxShadow: [boxShadowContainer],
                              border: borderAllContainerBox,
                            ),
                            padding: paddingBoxContainer,
                            child: Row(children: [
                              Expanded(
                                flex: 2,
                                child: Text('Đơn hàng',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                        fontWeight: FontWeight.w700)),
                              ),
                              Expanded(
                                flex: 4,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(0.0),
                                    border: Border.all(
                                        color: Colors.black,
                                        style: BorderStyle.solid,
                                        width: 0.80),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton2(
                                      isExpanded: true,
                                      searchController: textEditingController,
                                      // buttonDecoration: BoxDecoration(border: Border.all(width: 0.5, style: BorderStyle.solid)),
                                      hint: Text('${orderName[0]}',
                                          style: sizeTextKhung),
                                      buttonPadding:
                                          const EdgeInsets.only(left: 20),

                                      items: orderName.entries
                                          .map((item) =>
                                              DropdownMenuItem<String>(
                                                value: item.key.toString(),
                                                child: Text(item.value,
                                                    style: sizeTextKhung),
                                              ))
                                          .toList(),
                                      value:
                                          selectedDH != "" ? selectedDH : null,
                                      itemPadding:
                                          const EdgeInsets.only(left: 30),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedDH = value as String;

                                          ipDH = int.tryParse(
                                              selectedDH.toString());
                                          selectedDH = value;
                                        });
                                        print(selectedDH);
                                      },
                                      searchMatchFn: (item, searchValue) {
                                        return (item.child
                                            .toString()
                                            .contains(searchValue));
                                      },
                                      searchInnerWidget: Padding(
                                        padding: const EdgeInsets.only(
                                          top: 20,
                                          bottom: 20,
                                          right: 20,
                                          left: 20,
                                        ),
                                        child: TextFormField(
                                          controller: textEditingController,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 8,
                                            ),
                                            hintText: 'Search for an item...',
                                            hintStyle:
                                                const TextStyle(fontSize: 12),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                      buttonHeight: 40,
                                      itemHeight: 30,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(flex: 3, child: Container()),
                              Expanded(
                                flex: 2,
                                child: Text('Trạng thái',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                        fontWeight: FontWeight.w700)),
                              ),
                              Expanded(
                                flex: 4,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(0.0),
                                    border: Border.all(
                                        color: Colors.black,
                                        style: BorderStyle.solid,
                                        width: 0.80),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton2(
                                      isExpanded: true,
                                      searchController: textEditingController,
                                      // buttonDecoration: BoxDecoration(border: Border.all(width: 0.5, style: BorderStyle.solid)),
                                      hint: Text('${status[0]}',
                                          style: sizeTextKhung),
                                      buttonPadding:
                                          const EdgeInsets.only(left: 20),

                                      items: status.entries
                                          .map((item) =>
                                              DropdownMenuItem<String>(
                                                value: item.key.toString(),
                                                child: Text(item.value,
                                                    style: sizeTextKhung),
                                              ))
                                          .toList(),
                                      itemPadding:
                                          const EdgeInsets.only(left: 30),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedStatus = value as String;
                                          selectedStatus = value;
                                        });
                                      },
                                      buttonHeight: 40,
                                      itemHeight: 30,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(flex: 3, child: Container()),
                              Expanded(
                                flex: 2,
                                child: Container(
                                    child: Row(children: [
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 20.0,
                                        horizontal: 10.0,
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
                                        Text('Tìm kiếm', style: textButton),
                                        const Icon(Icons.near_me,
                                            color: Colors.white),
                                      ],
                                    ),
                                  ),
                                ])),
                              )
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(25, 0, 25, 0),
                        width: MediaQuery.of(context).size.width * 1,
                        decoration: BoxDecoration(
                          color: colorWhite,
                          borderRadius: borderRadiusContainer,
                          boxShadow: [boxShadowContainer],
                          border: borderAllContainerBox,
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: horizontalPaddingPage),
                        child: DataTable(
                          showCheckboxColumn: true,
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
                                label:
                                    Text('Người chốt', style: titleTableData)),
                            DataColumn(
                                label: Text('Ngày chốt', style: titleTableData))
                          ],
                          rows: <DataRow>[
                            //if (listDHH != null)

                            for (int j = 0; j < listDHH["content"].length; j++)
                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text(
                                    listDHH["content"][j]["id"].toString(),
                                  )),
                                  DataCell(
                                    TextButton(
                                      onPressed: () {
                                        _showMaterialDialog(
                                            listDHH["content"][j]["id"],
                                            context);
                                      },
                                      child: Text(
                                        listDHH["content"][j]["orderCode"] ??
                                            "no data",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    TextButton(
                                      onPressed: () {
                                        _showMaterialDialog(
                                            listDHH["content"][j]["id"],
                                            context);
                                      },
                                      child: Text(
                                        listDHH["content"][j]["orderName"] ??
                                            "no data",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      listDHH["content"][j]["orderName"] ??
                                          "no data",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      listDHH["content"][j]["orderName"] ??
                                          "no data",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(),
                  paging
                ]),
              ));
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class TableTTS extends StatefulWidget {
  TableTTS({Key? key}) : super(key: key);

  @override
  State<TableTTS> createState() => _TableListChotDanhSachTTSState();
}

class _TableListChotDanhSachTTSState extends State<TableTTS> {
  List<bool> _selected = [];
  var listTTS = {};
  var listPay = {};
  var totalElements = 0;
  var firstRow = 0;
  var rowPerPage = 5;
  var selectedDataTable = {};

  late Future futureListPay;
  late Future futureListTTS;

  var currentPage = 0;

  @override
  void initState() {
    super.initState();
    futureListTTS = getListTTS(currentPage);
    futureListPay = getListPay(currentPage);
  }

  Future getListPay(page) async {
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
      print(page);
    }

    if (page < 1) {
      page = 0;
    }

    var response;

    response = await httpGet("/api/tts-thanhtoan/get/page", context);
    if (response.containsKey("body")) {
      setState(() {
        listPay = jsonDecode(response["body"]);

        totalElements = listPay["totalElements"];
      });
    }
  }

  Future getListTTS(page) async {
    var response =
        await httpGet("/api/nguoidung/get/page?filter=isTts:1", context);
    if (response.containsKey("body")) {
      setState(() {
        listTTS = jsonDecode(response["body"]);
        _selected = List<bool>.generate(listTTS.length, (int index) => false);
        totalElements = listTTS["totalElements"];
      });
    }
    return 0;
  }

  var idSelectedDonhang = {};
  //----------------Bảng chốt ds-----
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futureListTTS,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return StatefulBuilder(
                builder: (BuildContext context, _setState) => Column(
                      children: [
                        Container(
                          height: 350,
                          child: ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              DataTable(
                                  showCheckboxColumn: true,
                                  columnSpacing: 20,
                                  columns: [
                                    DataColumn(
                                        label:
                                            Text('STT', style: titleTableData)),
                                    DataColumn(
                                        label: Text('Mã TTS',
                                            style: titleTableData)),
                                    DataColumn(
                                        label: Text('Họ tên TTS',
                                            style: titleTableData)),
                                    DataColumn(
                                        label: Text('Giới tính',
                                            style: titleTableData)),
                                    DataColumn(
                                        label: Text('Thu tiền trước thi tuyển',
                                            style: titleTableData)),
                                    DataColumn(
                                      label: Text(' '),
                                    ),
                                  ],
                                  rows: <DataRow>[
                                    if (resultListNguoiDung["content"] != null)
                                      for (int i = 0;
                                          i <
                                              resultListNguoiDung["content"]
                                                  .length;
                                          i++)
                                        DataRow(
                                          selected: _selected[i],
                                          onSelectChanged: (bool? selected) {
                                            setState(
                                              () {
                                                selectedDataTable["id"] =
                                                    resultListNguoiDung[
                                                            "content"][i]
                                                        ["nguoidung"]["id"];
                                                selectedDataTable[
                                                    "isSelected"] = selected!;

                                                if (selectedDataTable[
                                                        "isSelected"] ==
                                                    true) {
                                                  checkSelected = true;
                                                  print(selected);
                                                } else {
                                                  checkSelected = false;
                                                  if (resultListNguoiDung[
                                                              "content"][i]
                                                          ["paidBeforeExam"] ==
                                                      1) {
                                                    checkSelected = false;
                                                  }
                                                }
                                                idTTS = resultListNguoiDung[
                                                        "content"][i]
                                                    ["nguoidung"]["id"];

                                                context
                                                    .read<ButtonDungXuLy>()
                                                    .btnDungXuLy(checkSelected);
                                              },
                                            );
                                          },
                                          cells: <DataCell>[
                                            DataCell(Text("${i + 1}")),
                                            if (resultListNguoiDung["content"]
                                                    [i]["paidBeforeExam"] ==
                                                0)
                                              DataCell(
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.warning,
                                                      color: Colors.red,
                                                    ),
                                                    Text(
                                                        resultListNguoiDung[
                                                                        "content"][i]
                                                                    [
                                                                    "nguoidung"]
                                                                ["userCode"] ??
                                                            "no data",
                                                        style: bangDuLieu),
                                                  ],
                                                ),
                                              )
                                            else
                                              DataCell(
                                                Text(
                                                    resultListNguoiDung[
                                                                    "content"]
                                                                [i]["nguoidung"]
                                                            ["userCode"] ??
                                                        "no data",
                                                    style: bangDuLieu),
                                              ),
                                            DataCell(
                                              Text(
                                                  resultListNguoiDung["content"]
                                                              [i]["nguoidung"]
                                                          ["userName"] ??
                                                      "no data",
                                                  style: bangDuLieu),
                                            ),
                                            DataCell(
                                              Text(
                                                  resultListNguoiDung["content"]
                                                              [i]["nguoidung"]
                                                          ["gender"]
                                                      .toString(),
                                                  style: bangDuLieu),
                                            ),
                                            DataCell(
                                              Text(
                                                  resultListNguoiDung["content"]
                                                          [i]["paidBeforeExam"]
                                                      .toString(),
                                                  style: bangDuLieu),
                                            ),

                                            DataCell(Row(
                                              children: [
                                                Container(
                                                    child: InkWell(
                                                        onTap: () {},
                                                        child: Icon(
                                                            Icons.visibility))),
                                                Container(
                                                    margin: EdgeInsets.fromLTRB(
                                                        10, 0, 0, 0),
                                                    child: InkWell(
                                                        onTap: () {},
                                                        child: Icon(
                                                          Icons.edit_calendar,
                                                          color:
                                                              Color(0xff009C87),
                                                        ))),
                                              ],
                                            )),
                                            //
                                          ],
// =======
//                               DataTable(
//                                   showCheckboxColumn: true,
//                                   columnSpacing: 20,
//                                   columns: [
//                                     DataColumn(
//                                         label:
//                                             Text('STT', style: titleTableData)),
//                                     DataColumn(
//                                         label: Text('Mã TTS',
//                                             style: titleTableData)),
//                                     DataColumn(
//                                         label: Text('Họ tên TTS',
//                                             style: titleTableData)),
//                                     DataColumn(
//                                         label: Text('Giới tính',
//                                             style: titleTableData)),
//                                     DataColumn(
//                                         label: Text('Thu tiền trước thi tuyển',
//                                             style: titleTableData)),
//                                     DataColumn(
//                                       label: Text(' '),
// >>>>>>> ba68cd0dfd11aeeac093ed21700e7553b20c72ae
//                                     ),
//                                   ],
//                                   rows: <DataRow>[
//                                     if (resultListNguoiDung["content"] != null)
//                                       for (int i = 0;
//                                           i <
//                                               resultListNguoiDung["content"]
//                                                   .length;
//                                           i++)
//                                         DataRow(
//                                           selected: selectedDataTable["id"] ==
//                                                   resultListNguoiDung["content"]
//                                                       [i]["nguoidung"]["id"]
//                                               ? selectedDataTable["isSelected"]
//                                               : false,
//                                           onSelectChanged: (bool? selected) {
//                                             _setState(
//                                               () {
//                                                 selectedDataTable["id"] =
//                                                     resultListNguoiDung[
//                                                             "content"][i]
//                                                         ["nguoidung"]["id"];
//                                                 selectedDataTable[
//                                                     "isSelected"] = selected!;

//                                                 if (selectedDataTable[
//                                                         "isSelected"] ==
//                                                     true) {
//                                                   checkSelected = true;
//                                                   print(selected);
//                                                 } else {
//                                                   checkSelected = false;
//                                                   if (resultListNguoiDung[
//                                                               "content"][i]
//                                                           ["paidBeforeExam"] ==
//                                                       1) {
//                                                     checkSelected = false;
//                                                   }
//                                                 }
//                                                 idTTS = resultListNguoiDung[
//                                                         "content"][i]
//                                                     ["nguoidung"]["id"];

//                                                 context
//                                                     .read<ButtonDungXuLy>()
//                                                     .btnDungXuLy(checkSelected);
//                                               },
//                                             );
//                                           },
//                                           cells: <DataCell>[
//                                             DataCell(Text("${i + 1}")),
//                                             if (resultListNguoiDung["content"]
//                                                     [i]["paidBeforeExam"] ==
//                                                 0)
//                                               DataCell(
//                                                 Row(
//                                                   children: [
//                                                     Icon(
//                                                       Icons.warning,
//                                                       color: Colors.red,
//                                                     ),
//                                                     Text(
//                                                         resultListNguoiDung[
//                                                                         "content"][i]
//                                                                     [
//                                                                     "nguoidung"]
//                                                                 ["userCode"] ??
//                                                             "no data",
//                                                         style: bangDuLieu),
//                                                   ],
//                                                 ),
//                                               )
//                                             else
//                                               DataCell(
//                                                 Text(
//                                                     resultListNguoiDung[
//                                                                     "content"]
//                                                                 [i]["nguoidung"]
//                                                             ["userCode"] ??
//                                                         "no data",
//                                                     style: bangDuLieu),
//                                               ),
//                                             DataCell(
//                                               Text(
//                                                   resultListNguoiDung["content"]
//                                                               [i]["nguoidung"]
//                                                           ["userName"] ??
//                                                       "no data",
//                                                   style: bangDuLieu),
//                                             ),
//                                             DataCell(
//                                               Text(
//                                                   resultListNguoiDung["content"]
//                                                               [i]["nguoidung"]
//                                                           ["gender"]
//                                                       .toString(),
//                                                   style: bangDuLieu),
//                                             ),
//                                             DataCell(
//                                               Text(
//                                                   resultListNguoiDung["content"]
//                                                           [0]["paidBeforeExam"]
//                                                       .toString(),
//                                                   style: bangDuLieu),
//                                             ),
//                                             DataCell(Row(
//                                               children: [
//                                                 Container(
//                                                     child: InkWell(
//                                                         onTap: () {},
//                                                         child: Icon(
//                                                             Icons.visibility))),
//                                                 Container(
//                                                     margin: EdgeInsets.fromLTRB(
//                                                         10, 0, 0, 0),
//                                                     child: InkWell(
//                                                         onTap: () {},
//                                                         child: Icon(
//                                                           Icons.edit_calendar,
//                                                           color:
//                                                               Color(0xff009C87),
//                                                         ))),
//                                               ],
//                                             )),
//                                             //
//                                           ],
                                        ),
                                  ]),
                            ],
                          ),
                        ),
                        Container()
                      ],
                    ));
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return const Center(child: CircularProgressIndicator());
        });
  }
}
