import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../api.dart';
import '../../../common/dynamic_table.dart';
import '../../../common/format_date.dart';
import '../../../common/widgets_form.dart';
import '../../../model/market_development/order.dart';
import '../../../model/model.dart';
import '../../../common/style.dart';
import '../../../model/type.dart';
import '../../forms/market_development/utils/funciton.dart';
import '../navigation.dart';
import "package:collection/collection.dart";

import '../source_information/common_ource_information/constant.dart';
import '../trung_tam_dao_tao/danh_sach_thuc_tap_sinh/danh_sach_thuc_tap_sinh.dart';
import 'chot_danh_sach_tts_tien_cu/dung_xu_ly.dart';

var _selectedDataRow = [];
var listDungXuLy = [];
var listSelectedTable = [];

class QLHoSoTTS extends StatelessWidget {
  const QLHoSoTTS({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: QLHoSoTTSBody());
  }
}

class QLHoSoTTSBody extends StatefulWidget {
  const QLHoSoTTSBody({Key? key}) : super(key: key);

  @override
  State<QLHoSoTTSBody> createState() => _QLHoSoTTSBodyState();
}

class _QLHoSoTTSBodyState extends State<QLHoSoTTSBody> {
  String? request;
  late Future<TableListTTSDuocTienCu> futureAlbum;
  var resultDonHangDropDown = {};
  var listTrainee = [];
  late Future futureListTrainee;
  var firstRow = 0;
  int rowCount = 0;
  int currentPageDef = 1;
  int rowPerPage = 10;
  var totalElements = 0;
  var idDH;
  var idTT;
  Widget paging = Container();
  String dropdownValue = 'Tất cả';
  String dropDownValue = 'Tất cả';
  final String urlAddNewUpdateSI = "quan-ly-ho-so-tts/trainee-information";
  String trangThaiTTS = "";

  TextEditingController tenTTS = TextEditingController();
  @override
  void initState() {
    super.initState();
    callAllApi();
  }

  callAllApi() async {
    futureListTrainee = getListTrainee(1);
  }

  // List of items in our dropdown menu
  String selectedDH = "";
  String selectedTT = "";
  Map<int, String> orderName = {0: "Tất cả"};
  Map<int, String> traineeStatus = {
    0: "Tất cả",
    5: "Đã tiến cử",
    6: "Chờ thi tuyển",
    7: "Đã trúng tuyển",
    8: "Chờ đào tạo",
    9: "Đang đào tạo",
    10: "Chờ xuất cảnh",
    11: "Đã xuất cảnh",
    12: "Đã hoàn thành",
    13: "Dừng xử lý",
    14: "Chờ tiến cử lại",
    30: "Dự bị"
  };

  //Phân trang
  getListTrainee(page) async {
    await getTraineeProfile();
    String listId = '';

    if (listId == '') listId = '0';
    var response;

    if (request == null && (selectedDH == "" || selectedDH == "0")) {
      response = await httpGet(
          "/api/nguoidung/get/page?page=${page - 1}&size=$rowPerPage&sort=id&filter=isTts:1 and (ttsStatusId>4)  and (stopProcessing:0 or stopProcessing is null)",
          context);
    } else {
      if (request != null && (selectedDH == "" || selectedDH == "0")) {
        response = await httpGet(
            "/api/nguoidung/get/page?page=${page - 1}&size=$rowPerPage&sort=id&filter=(fullName~'*$request*' or userCode~'*$request*')$trangThaiTTS  and (stopProcessing:0 or stopProcessing is null)",
            context);
      } else {
        if (request == null && (selectedDH != "" && selectedDH != "0")) {
          response = await httpGet(
              "/api/nguoidung/get/page?page=${page - 1}&size=$rowPerPage&filter=orderId:$selectedDH AND isTts:1 $trangThaiTTS and (stopProcessing:0 or stopProcessing is null)",
              context);
        } else {
          if (request != null && (selectedDH != "" || selectedDH != "0")) {
            response = await httpGet(
                "/api/nguoidung/get/page?page=${page - 1}&size=$rowPerPage&filter=orderId:$selectedDH AND (fullName~'*$request*' or userCode~'*$request*') AND isTts:1 $trangThaiTTS and (stopProcessing:0 or stopProcessing is null)",
                context);
          }
        }
      }
    }

    if (response.containsKey("body")) {
      setState(() {
        // currentPage = page;
        listTrainee = jsonDecode(response["body"])['content'];
        // print(listTrainee);
        rowCount = jsonDecode(response["body"])["totalElements"];
        _selectedDataRow =
            List<bool>.generate(listTrainee.length, (int index) => false);
      });
    }
    return listTrainee;
  }

  var listTraineeProfile;
  var listProfileGroupByTrainee = {};
  var listTraineeId = [];
  dynamic listCountTraineeProfile = {};
  int count = 0;
  getTraineeProfile() async {
    var response = await httpGet(
        "/api/tts-hoso-chitiet/get/page?filter=hoso.fileGeneric:0", context);
    if (response.containsKey("body")) {
      setState(() {
        listTraineeProfile = jsonDecode(response["body"])["content"];

        listProfileGroupByTrainee =
            groupBy(listTraineeProfile, (dynamic obj) => obj['ttsId']);
        listTraineeId.clear();
        listProfileGroupByTrainee.forEach((key, value) {
          if (key != null) listTraineeId.add(key);
        });
        for (int i = 0; i < listTraineeId.length; i++) {
          count = 0;
          for (int j = 0;
              j < listProfileGroupByTrainee[listTraineeId[i]].length;
              j++) {
            if (listProfileGroupByTrainee[listTraineeId[i]][j]["hoso"]
                    ["required"] ==
                1) {
              count++;
            }
          }
          listCountTraineeProfile[listTraineeId[i]] = count;
        }
      });
    }
  }

  Future<List<Order>> getListOrder() async {
    List<Order> resultOrder = [];
    var response1 = await httpGet(
        "/api/donhang/get/page?sort=id&filter= (stopProcessing:0 or stopProcessing is null)",
        context);
    var body = jsonDecode(response1['body']);
    var content = [];
    if (response1.containsKey("body")) {
      setState(() {
        content = body['content'];
        resultOrder = content.map((e) {
          return Order.fromJson(e);
        }).toList();
        Order all = new Order(
            id: 0,
            orderName: "Tất cả",
            enterprise: null,
            jobs: null,
            orderCode: '',
            orderStatusId: 0,
            union: null);
        resultOrder.insert(0, all);
      });
    }
    return resultOrder;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: userRule('/quan-ly-ho-so-tts', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return FutureBuilder(
              future: futureListTrainee,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Consumer<NavigationModel>(
                    builder: (context, navigationModel, child) => ListView(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 1,
                          decoration: BoxDecoration(
                            color: colorWhite,
                            boxShadow: [boxShadowContainer],
                            border: Border(
                              bottom: borderTitledPage,
                            ),
                          ),
                          // padding: paddingTitledPage,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TitlePage(
                                listPreTitle: [
                                  {'url': '/ho-so-noi', 'title': 'Hồ sơ nội'},
                                ],
                                content: 'Quản lý hồ sơ TTS',
                              ),
                            ],
                          ),
                        ),
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
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Divider(
                                        thickness: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 20),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 6,
                                          child: TextFieldValidatedForm(
                                            height: 40,
                                            label: 'TTS',
                                            type: 'None',
                                            controller: tenTTS,
                                            flexLable: 2,
                                            flexTextField: 4,
                                            enter: () {
                                              request = tenTTS.text;
                                              getListTrainee(1);
                                            },
                                          ),
                                        ),
                                        Expanded(
                                          flex: 14,
                                          child: Container(),
                                        )
                                      ]),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text('Đơn hàng',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0),
                                              fontWeight: FontWeight.w700)),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Container(
                                        height: 40,
                                        child: DropdownSearch<Order>(
                                          // ignore: deprecated_member_use
                                          hint: "Tất cả",
                                          maxHeight: 350,
                                          mode: Mode.MENU,
                                          showSearchBox: true,
                                          onFind: (String? filter) =>
                                              getListOrder(),
                                          itemAsString: (Order? u) =>
                                              u!.orderName,
                                          dropdownSearchDecoration:
                                              styleDropDown,
                                          onChanged: (value) {
                                            setState(() {
                                              idDH = value!.id;
                                              selectedDH = idDH.toString();
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    Expanded(flex: 1, child: Container()),
                                    Expanded(
                                      flex: 2,
                                      child: Text('Trạng thái',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0),
                                              fontWeight: FontWeight.w700)),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          // borderRadius: BorderRadius.circular(0.0),
                                          border: Border.all(
                                            style: BorderStyle.solid,
                                          ),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                            child: ButtonTheme(
                                          alignedDropdown: true,
                                          child: DropdownButton2<String>(
                                            dropdownMaxHeight: 400,
                                            // underline: Container(
                                            //   height: 1,
                                            //   color: Colors.black,
                                            // ),
                                            hint: Text('${traineeStatus[0]}',
                                                style: sizeTextKhung),
                                            buttonPadding:
                                                const EdgeInsets.only(left: 20),
                                            items: traineeStatus.entries
                                                .map((item) =>
                                                    DropdownMenuItem<String>(
                                                      value:
                                                          item.key.toString(),
                                                      child: Text(item.value,
                                                          style: sizeTextKhung),
                                                    ))
                                                .toList(),
                                            value: selectedTT != ""
                                                ? selectedTT
                                                : null,
                                            itemPadding:
                                                const EdgeInsets.only(left: 30),
                                            onChanged: (value) {
                                              setState(() {
                                                selectedTT = value as String;
                                                idTT = int.tryParse(
                                                    selectedTT.toString());
                                                selectedTT = value;
                                              });
                                            },
                                            buttonHeight: 40,
                                          ),
                                        )),
                                      ),
                                    ),
                                    Expanded(flex: 1, child: Container()),
                                    getRule(listRule.data, Role.Sua, context)
                                        ? Expanded(
                                            flex: 2,
                                            child: ElevatedButton(
                                              // textColor: Color(0xFF6200EE),
                                              onPressed:
                                                  listSelectedTable.length != 0
                                                      ? () async {
                                                          showDialog(
                                                            context: context,
                                                            builder: (BuildContext
                                                                    context) =>
                                                                DungXuLyHSN(
                                                                    setState:
                                                                        () {
                                                                      futureListTrainee =
                                                                          getListTrainee(
                                                                              currentPageDef);
                                                                      setState(
                                                                          () {});
                                                                    },
                                                                    listIdSelected:
                                                                        listDungXuLy,
                                                                    titleDialog:
                                                                        'Dừng xử lý'),
                                                          );

                                                          // navigationModel.add(pageUrl: "/quan-ly-ho-so-tts");
                                                        }
                                                      : null,
                                              style: listSelectedTable.length !=
                                                      0
                                                  ? ElevatedButton.styleFrom(
                                                      primary: Color.fromRGBO(
                                                          245, 117, 29, 1),
                                                      onPrimary: Colors.white,
                                                      elevation: 3,
                                                      minimumSize:
                                                          Size(140, 50),
                                                    )
                                                  : ElevatedButton.styleFrom(
                                                      primary: Color.fromARGB(
                                                          255, 115, 115, 115),
                                                      onPrimary: Colors.white,
                                                      elevation: 3,
                                                      minimumSize:
                                                          Size(140, 50),
                                                    ),
                                              child: Text(
                                                'Dừng xử lý',
                                                style: TextStyle(),
                                              ),
                                            ),
                                          )
                                        : Container(),
                                    Expanded(flex: 1, child: Container()),
                                    Expanded(
                                      flex: 2,
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            primary:
                                                Color.fromRGBO(245, 117, 29, 1),
                                            onPrimary: Colors.white,
                                            // shadowColor: Colors.greenAccent,
                                            elevation: 3,
                                            // shape: RoundedRectangleBorder(
                                            //     borderRadius: BorderRadius.circular(32.0)),
                                            minimumSize:
                                                Size(140, 50), //////// HERE
                                          ),
                                          // textColor: Color(0xFF6200EE),
                                          // highlightColor: Colors.transparent,
                                          onPressed: () {
                                            request = tenTTS.text;
                                            if (idTT != null && idTT != 0)
                                              trangThaiTTS =
                                                  "and ttsStatusId:$idTT";
                                            else
                                              trangThaiTTS =
                                                  "and (ttsStatusId>4)";
                                            futureListTrainee =
                                                getListTrainee(currentPageDef);
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.search,
                                                  color: Colors.white,
                                                  size: 15),
                                              Text(' Tìm kiếm',
                                                  style: textButton),
                                            ],
                                          )),
                                    ),
                                    Expanded(flex: 1, child: Container()),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          color: backgroundPage,
                          padding: EdgeInsets.symmetric(
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
                            child: Column(
                              children: [
                                TableTTS(
                                  tableData: listTrainee,
                                  callback: (listSelectCallBack) {
                                    setState(() {
                                      listSelectedTable = listSelectCallBack;
                                    });
                                  },
                                  currentPage: currentPageDef,
                                  rowPerPage: rowPerPage,
                                ),
                                DynamicTablePagging(
                                    rowCount, currentPageDef, rowPerPage,
                                    pageChangeHandler: (currentPage) {
                                  setState(() {
                                    futureListTrainee =
                                        getListTrainee(currentPage);
                                    currentPageDef = currentPage;
                                  });
                                }, rowPerPageChangeHandler: (rowPerPageChange) {
                                  currentPageDef = 1;

                                  rowPerPage = rowPerPageChange;
                                  futureListTrainee =
                                      getListTrainee(currentPageDef);

                                  setState(() {});
                                })
                              ],
                            ),
                          ),
                        ),
                        Footer(
                            marginFooter: EdgeInsets.only(top: 25),
                            paddingFooter: EdgeInsets.all(15))
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return const Center(child: CircularProgressIndicator());
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

// ignore: must_be_immutable
class TableTTS extends StatefulWidget {
  final Function? callback;
  int currentPage;
  int rowPerPage;
  dynamic tableData;
  TableTTS(
      {Key? key,
      required this.callback,
      this.tableData,
      required this.currentPage,
      required this.rowPerPage})
      : super(key: key);

  @override
  State<TableTTS> createState() => _TableListManagementTraineeProfileState();
}

class _TableListManagementTraineeProfileState extends State<TableTTS> {
  var countRequiredProfile;
  getCountRequiredProfile() async {
    var response = await httpGet(
        "/api/tts-hoso/get/count?filter=required:1 and fileGeneric:0", context);
    if (response.containsKey("body")) {
      setState(
        () {
          countRequiredProfile = response["body"];
        },
      );
    }
  }

  var listTraineeProfile = [];
  var listProfileGroupByTrainee = {};
  var listTraineeId = [];
  dynamic listCountTraineeProfile = {};
  int count = 0;
  getTraineeProfile() async {
    var response = await httpGet(
        "/api/tts-hoso-chitiet/get/page?filter=hoso.fileGeneric:0", context);
    if (response.containsKey("body")) {
      setState(() {
        listTraineeProfile = jsonDecode(response["body"])["content"];
        listProfileGroupByTrainee =
            groupBy(listTraineeProfile, (dynamic obj) => obj['ttsId']);
        listTraineeId.clear();
        listProfileGroupByTrainee.forEach((key, value) {
          if (key != null) listTraineeId.add(key);
        });
        for (var row in listTraineeId) {
          count = 0;
          for (int j = 0; j < listProfileGroupByTrainee[row].length; j++) {
            if (listProfileGroupByTrainee[row][j]["hoso"]["required"] == 1) {
              count++;
            }
          }
          listCountTraineeProfile[row] = count;
        }
      });
    }
    return 0;
  }

  late Future futureData;
  @override
  void initState() {
    callApi();
    futureData = getTraineeProfile();
    super.initState();
  }

  callApi() async {
    await getCountRequiredProfile();
    // await getTraineeProfile();
  }

  @override
  Widget build(BuildContext context) {
    int getIndex(page, rowPerPage, index) {
      return (((page - 1) * rowPerPage) + index) + 1;
    }

    return FutureBuilder<dynamic>(
      future: userRule('/quan-ly-ho-so-tts', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return FutureBuilder(
              future: futureData,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Consumer<NavigationModel>(
                      builder: (context, navigationModel, child) =>
                          StatefulBuilder(
                            builder: (BuildContext context, setState) =>
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width * 1,
                                    child: DataTable(
                                      showCheckboxColumn: true,
                                      dataRowHeight: 60,
                                      columnSpacing: 10,
                                      columns: [
                                        DataColumn(
                                            label: Text('STT',
                                                style: titleTableData)),
                                        DataColumn(
                                            label: Text('Mã đơn hàng',
                                                style: titleTableData)),
                                        DataColumn(
                                            label: Text('Tên đơn hàng',
                                                style: titleTableData)),
                                        DataColumn(
                                            label: Text('Mã TTS',
                                                style: titleTableData)),
                                        DataColumn(
                                            label: Text('Họ tên',
                                                style: titleTableData)),
                                        DataColumn(
                                            label: Text('Giới tính',
                                                style: titleTableData)),
                                        DataColumn(
                                            label: Text('SĐT',
                                                style: titleTableData)),
                                        DataColumn(
                                            label: Text('Trạng thái',
                                                style: titleTableData)),
                                        DataColumn(
                                          label: Text(' '),
                                        ),
                                      ],
                                      rows: <DataRow>[
                                        for (var i = 0;
                                            i < widget.tableData.length;
                                            i++)
                                          DataRow(
                                            selected: _selectedDataRow[i],
                                            onSelectChanged: (bool? value) {
                                              setState(() {
                                                listDungXuLy.clear();
                                                _selectedDataRow[i] = value!;
                                                for (int j = 0;
                                                    j < _selectedDataRow.length;
                                                    j++) {
                                                  if (_selectedDataRow[j] ==
                                                      true) {
                                                    //Add vào list dừng xử lý
                                                    listDungXuLy.add(
                                                        widget.tableData[j]);
                                                  }
                                                }
                                                widget.callback!(listDungXuLy);
                                              });
                                            },
                                            cells: <DataCell>[
                                              DataCell(Text(
                                                getIndex(widget.currentPage,
                                                        widget.rowPerPage, i)
                                                    .toString(),
                                              )),
                                              DataCell(
                                                Text(
                                                    (widget.tableData[i]
                                                                ["donhang"] !=
                                                            null)
                                                        ? widget.tableData[i]
                                                                ["donhang"]
                                                            ["orderCode"]
                                                        : "",
                                                    style: bangDuLieu),
                                              ),
                                              DataCell(
                                                Container(
                                                  child: Text(
                                                      (widget.tableData[i]
                                                                  ["donhang"] !=
                                                              null)
                                                          ? widget.tableData[i]
                                                                  ["donhang"]
                                                              ["orderName"]
                                                          : "",
                                                      style: bangDuLieu),
                                                ),
                                              ),
                                              DataCell(
                                                !widget.tableData[i][
                                                        "profileDocumentsCompleted"]
                                                    ? Row(
                                                        // mainAxisAlignment:
                                                        //     MainAxisAlignment
                                                        //         .center,
                                                        children: [
                                                          Tooltip(
                                                            message:
                                                                "TTS thiếu hồ sơ",
                                                            child: Icon(
                                                              Icons
                                                                  .warning_amber_rounded,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      244,
                                                                      67,
                                                                      54),
                                                            ),
                                                          ),
                                                          Text(
                                                              widget.tableData[
                                                                          i][
                                                                      "userCode"] ??
                                                                  "",
                                                              style:
                                                                  bangDuLieu),
                                                        ],
                                                      )
                                                    : Text(
                                                        widget.tableData[i]
                                                                ["userCode"] ??
                                                            "",
                                                        style: bangDuLieu),
                                              ),
                                              DataCell(
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                        child: Text(
                                                            widget.tableData[i][
                                                                    "fullName"] ??
                                                                "",
                                                            style: bangDuLieu)),
                                                    Text(
                                                        widget.tableData[i][
                                                                    "birthDate"] !=
                                                                null
                                                            ? DateFormat(
                                                                    "dd-MM-yyyy")
                                                                .format(DateTime
                                                                    .parse(widget
                                                                            .tableData[i]
                                                                        [
                                                                        "birthDate"]))
                                                            : "",
                                                        style: bangDuLieu)
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                    (widget.tableData[i]
                                                                ["gender"] ==
                                                            0)
                                                        ? "Nam"
                                                        : "Nữ",
                                                    style: bangDuLieu),
                                              ),
                                              DataCell(
                                                Text(
                                                    widget.tableData[i]
                                                        ["phone"],
                                                    style: bangDuLieu),
                                              ),
                                              DataCell(
                                                Text(
                                                    (widget.tableData[i][
                                                                "ttsTrangthai"] !=
                                                            null)
                                                        ? widget.tableData[i]
                                                                ["ttsTrangthai"]
                                                            ["statusName"]
                                                        : "",
                                                    style: TextStyle(
                                                        color: widget.tableData[
                                                                        i][
                                                                    "ttsStatusId"] ==
                                                                13
                                                            ? Colors.red
                                                            : widget.tableData[i]
                                                                        ["stopProcessing"] ==
                                                                    1
                                                                ? Colors.amber
                                                                : Colors.black)),
                                              ),
                                              DataCell(Row(
                                                children: [
                                                  getRule(listRule.data,
                                                          Role.Xem, context)
                                                      ? Container(
                                                          child: InkWell(
                                                              onTap: () {
                                                                navigationModel
                                                                    .add(
                                                                  pageUrl:
                                                                      ("/view-thong-tin-thuc-tap-sinh" +
                                                                          "/${widget.tableData[i]["id"]}"),
                                                                );
                                                              },
                                                              child: Icon(Icons
                                                                  .visibility)))
                                                      : Container(),
                                                  getRule(listRule.data,
                                                          Role.Sua, context)
                                                      ? Container(
                                                          margin: EdgeInsets
                                                              .fromLTRB(
                                                                  10, 0, 0, 0),
                                                          child: InkWell(
                                                              onTap: () {
                                                                navigationModel.add(
                                                                    pageUrl:
                                                                        "/ho-so-ca-nhan/${widget.tableData[i]["id"]}");
                                                              },
                                                              child: Icon(
                                                                Icons
                                                                    .edit_calendar,
                                                                color: Color(
                                                                    0xff009C87),
                                                              )))
                                                      : Container(),
                                                ],
                                              )),
                                              //
                                            ],
                                          )
                                      ],
                                    )),
                          ));
                }
                return const Center(child: CircularProgressIndicator());
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

// ignore: must_be_immutable
class TextFieldValidated extends StatefulWidget {
  String type;
  TextEditingController?
      controller; //Cần truyền controller vào để lấy giá trị ra TextEditingController
  int? minLines = 1;
  int? maxLines = 1;
  int? flexLable;
  int? flexTextField;
  Function? enter;
  String? hint;
  String label;
  final double height;
  TextFieldValidated({
    Key? key,
    required this.type,
    this.controller,
    this.minLines,
    this.maxLines,
    this.hint,
    required this.label,
    this.flexLable,
    this.flexTextField,
    required this.height,
    this.enter,
  }) : super(key: key);

  @override
  State<TextFieldValidated> createState() => _TextFieldValidatedState();
}

class _TextFieldValidatedState extends State<TextFieldValidated> {
  String? er;

  late double height = widget.height;
  bool isEmail(String string) {
    // Null or empty string is invalid
    if (string.isEmpty) {
      return false;
    }

    const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    final regExp = RegExp(pattern);

    if (!regExp.hasMatch(string)) {
      return false;
    }
    return true;
  }

  bool _isPhoneNumber(String value) {
    String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      return false;
    } else if (!regExp.hasMatch(value)) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            height: height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                    flex: widget.flexLable ?? 2,
                    child: Text(
                      widget.label,
                      style: titleWidgetBox,
                    )),
                Expanded(
                  flex: widget.flexTextField ?? 6,
                  child: TextField(
                    minLines: widget.minLines,
                    maxLines: widget.maxLines,
                    controller: widget.controller ?? null,
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      errorText: er,
                      contentPadding: const EdgeInsets.fromLTRB(10, 7, 5, 0),
                      filled: true,
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    onSubmitted: (value) {
                      widget.enter!();
                    },
                    onChanged: (value) {
                      if (widget.type == 'Text') {
                        if (value.isEmpty) {
                          setState(() {
                            er = "Trường này không được bỏ trống";
                            height = 63;
                          });
                        } else {
                          setState(() {
                            er = null;
                            height = 40;
                          });
                        }
                      } else if (widget.type == 'Email') {
                        if (isEmail(widget.controller!.text)) {
                          setState(() {
                            er = null;
                            height = 40;
                          });
                        } else {
                          setState(() {
                            er = "Đây phải là một Email";
                            height = 63;
                          });
                        }
                      } else if (widget.type == 'Phone') {
                        if (_isPhoneNumber(widget.controller!.text)) {
                          setState(() {
                            er = null;
                            height = 40;
                          });
                        } else {
                          setState(() {
                            er = "Đây phải là một số điện thoại";
                            height = 63;
                          });
                        }
                      } else if (widget.type == 'None') {}
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
