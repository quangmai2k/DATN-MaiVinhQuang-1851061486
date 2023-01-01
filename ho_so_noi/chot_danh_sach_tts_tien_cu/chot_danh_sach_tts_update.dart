import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/api.dart';
import 'package:provider/provider.dart';

import '../../../../common/dynamic_table.dart';
import '../../../../common/format_date.dart';
import '../../../../common/style.dart';

import '../../../../common/widgets_form.dart';
import '../../../../model/market_development/order.dart';
import '../../../../model/model.dart';
import '../../navigation.dart';
import 'modal_chot_danh_sach_tts_tien_cu.dart';
import 'modal_danh_sach_tts_da_tien_cu.dart';

class ChotDachSachTienCu1 extends StatefulWidget {
  ChotDachSachTienCu1({Key? key}) : super(key: key);

  @override
  _ChotDachSachTienCu1State createState() => _ChotDachSachTienCu1State();
}

class _ChotDachSachTienCu1State extends State<ChotDachSachTienCu1> {
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
  final TextEditingController textEditingController = TextEditingController();
  var listDHH;
// ignore: unused_element
  String selectedDH = "";
  String selectedStatus = "";
  var resultDonHangDropDown = {};
  var idDH;
  bool _setLoading = false;
  late Future futureListDonhang;
  var rowPerPage = 10;
  var rowCount = 0;
  int currentPageDef = 1;
  var currentPage = 1;
  var idTT;

  @override
  void initState() {
    super.initState();
    callApi();
  }

  callApi() async {
    setState(() {
      _setLoading = false;
    });
    await (futureListDonhang = getListDonHang(currentPage));
    setState(() {
      _setLoading = true;
    });
  }

  getListDonHang(page) async {
    var response;
    if (selectedDH == "" || selectedDH == "0") {
      response = await httpGet(
          "/api/donhang/get/page?page=${page - 1}&size=$rowPerPage&sort=closeNominateDate,desc&filter=orderStatusId>1 and stopProcessing:0 $nominateStatus ",
          context);
    } else {
      response = await httpGet(
          "/api/donhang/get/page?page=${page - 1}&size=$rowPerPage&sort=closeNominateDate,desc&filter=id:$selectedDH and orderStatusId>1 and stopProcessing:0 $nominateStatus",
          context);
    }
    if (response.containsKey("body")) {
      setState(() {
        currentPage = page;
        listDHH = jsonDecode(response["body"]);
        rowCount = listDHH["totalElements"];
      });
    }
    return listDHH;
  }

  Future<List<Order>> getListOrder() async {
    List<Order> resultOrder = [];
    var response1 = await httpGet(
        "/api/donhang/get/page?sort=id&filter=orderStatusId:2 and (stopProcessing:0 or stopProcessing is null)",
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
          orderCode: '',
          enterprise: null,
          jobs: null,
          orderStatusId: 0,
          union: null,
        );
        resultOrder.insert(0, all);
      });
    }
    return resultOrder;
  }

  int getIndex(page, rowPerPage, index) {
    return ((page * rowPerPage) + index) + 1;
  }

  Map<int, String> status = {0: "Tất cả", 1: "Đã chốt", 2: "Chưa chốt"};
  Map<int, String> orderName = {0: "Tất cả"};
  String nominateStatus = "";

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: userRule('/chot-ds-tts-tien-cu', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return FutureBuilder<dynamic>(
              future: futureListDonhang,
              builder: (context, snapshot) {
                return ListView(
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
                          // Row(
                          //   children: [
                          //     Text(
                          //       'Home',
                          //       style: TextStyle(color: Color(0xff009C87)),
                          //     ),
                          //     Padding(
                          //       padding: EdgeInsets.only(left: 5, right: 5),
                          //       child: Text(
                          //         '/',
                          //         style: TextStyle(
                          //           color: Color(0xffC8C9CA),
                          //         ),
                          //       ),
                          //     ),
                          //     Text('Hồ sơ nội', style: TextStyle(color: Color(0xff009C87))),
                          //   ],
                          // ),
                          TitlePage(
                            listPreTitle: [
                              {'url': '/ho-so-noi', 'title': 'Hồ sơ nội'},
                            ],
                            content: 'Chốt danh sách TTS tiến cử',
                          ),
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
                                    // decoration: BoxDecoration(
                                    //   borderRadius: BorderRadius.circular(0.0),
                                    //   border: Border.all(color: Colors.black, style: BorderStyle.solid, width: 0.80),
                                    // ),
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
                                          '${u!.orderName}' +
                                          '${u.orderCode != '' ? '(' : ''}${u.orderCode}${u.orderCode != '' ? ')' : ''}',
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
                                Expanded(flex: 2, child: Container()),
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
                                            idTT = int.tryParse(
                                                selectedStatus.toString());
                                          });
                                        },
                                        value: selectedStatus != ""
                                            ? selectedStatus
                                            : null,
                                        buttonHeight: 40,
                                        itemHeight: 30,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(flex: 2, child: Container()),
                                Expanded(
                                  flex: 2,
                                  child: Container(
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
                                        if (idTT == 1) {
                                          nominateStatus =
                                              "and nominateStatus:1";
                                        } else {
                                          if (idTT == 2)
                                            nominateStatus =
                                                "and (nominateStatus:0 or nominateStatus is null)";
                                          else
                                            nominateStatus = "";
                                        }
                                        setState(() {
                                          futureListDonhang =
                                              getListDonHang(currentPage);
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          Icon(Icons.search,
                                              color: Colors.white, size: 15),
                                          Text('Tìm kiếm', style: textButton),
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
                    if (snapshot.hasData)
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
                          child: Column(
                            children: [
                              Consumer2<NavigationModel, SecurityModel>(
                                builder: (context, navigationModel, user,
                                        child) =>
                                    _setLoading
                                        ? SingleChildScrollView(
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  1,
                                              child: DataTable(
                                                columnSpacing: 100,
                                                showCheckboxColumn: true,
                                                columns: [
                                                  DataColumn(
                                                      label: Text('STT',
                                                          style:
                                                              titleTableData)),
                                                  DataColumn(
                                                      label: Text('Mã đơn hàng',
                                                          style:
                                                              titleTableData)),
                                                  DataColumn(
                                                      label: Text(
                                                          'Tên đơn hàng',
                                                          style:
                                                              titleTableData)),
                                                  DataColumn(
                                                      label: Text('Người chốt',
                                                          style:
                                                              titleTableData)),
                                                  DataColumn(
                                                      label: Text('Ngày chốt',
                                                          style:
                                                              titleTableData))
                                                ],
                                                rows: <DataRow>[
                                                  if (listDHH["content"] !=
                                                      null)
                                                    for (int j = 0;
                                                        j <
                                                            listDHH["content"]
                                                                .length;
                                                        j++)
                                                      DataRow(
                                                        cells: <DataCell>[
                                                          DataCell(Text(
                                                            getIndex(
                                                                    currentPage -
                                                                        1,
                                                                    rowPerPage,
                                                                    j)
                                                                .toString(),
                                                          )),
                                                          DataCell(
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.2,
                                                              child: TextButton(
                                                                style: ButtonStyle(
                                                                    alignment:
                                                                        Alignment
                                                                            .centerLeft),
                                                                onPressed: () {
                                                                  (listDHH["content"][j]
                                                                              [
                                                                              "closeNominateUser"] ==
                                                                          null)
                                                                      ? showDialog(
                                                                          context:
                                                                              context,
                                                                          builder: (BuildContext context) => ModalChotDanhSachTienCu(
                                                                              orderId: listDHH["content"][j]["id"],
                                                                              order: listDHH["content"][j],
                                                                              funcitonCallback: () {
                                                                                futureListDonhang = getListDonHang(currentPage);
                                                                              }),
                                                                        )
                                                                      : showDialog(
                                                                          context:
                                                                              context,
                                                                          builder: (BuildContext context) => ModalDanhSachTienCu(
                                                                              orderId: listDHH["content"][j]["id"],
                                                                              order: listDHH["content"][j],
                                                                              funcitonCallback: () {
                                                                                futureListDonhang = getListDonHang(currentPage);
                                                                              }),
                                                                        );
                                                                  // _showMaterialDialog(
                                                                  //     listDHH["content"][j]["id"], context);
                                                                },
                                                                child: Row(
                                                                  children: [
                                                                    Flexible(
                                                                      child:
                                                                          Text(
                                                                        listDHH["content"][j]["orderCode"] ??
                                                                            "no data",
                                                                        textAlign:
                                                                            TextAlign.left,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.w400,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          DataCell(
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.2,
                                                              child: TextButton(
                                                                style: ButtonStyle(
                                                                    alignment:
                                                                        Alignment
                                                                            .centerLeft),
                                                                onPressed: () {
                                                                  (listDHH["content"][j]
                                                                              [
                                                                              "closeNominateUser"] ==
                                                                          null)
                                                                      ? showDialog(
                                                                          context:
                                                                              context,
                                                                          builder: (BuildContext context) => ModalChotDanhSachTienCu(
                                                                              orderId: listDHH["content"][j]["id"],
                                                                              order: listDHH["content"][j],
                                                                              funcitonCallback: () {
                                                                                futureListDonhang = getListDonHang(currentPage);
                                                                              }),
                                                                        )
                                                                      : showDialog(
                                                                          context:
                                                                              context,
                                                                          builder: (BuildContext context) => ModalDanhSachTienCu(
                                                                              orderId: listDHH["content"][j]["id"],
                                                                              order: listDHH["content"][j],
                                                                              funcitonCallback: () {
                                                                                futureListDonhang = getListDonHang(currentPage);
                                                                              }),
                                                                        );
                                                                  // _showMaterialDialog(
                                                                  //     listDHH["content"][j]["id"], context);
                                                                },
                                                                child: Row(
                                                                  children: [
                                                                    Flexible(
                                                                      child:
                                                                          Text(
                                                                        listDHH["content"][j]["orderName"] ??
                                                                            "no data",
                                                                        textAlign:
                                                                            TextAlign.left,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.w400,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          DataCell(
                                                            Container(
                                                              width: 100,
                                                              child: Text(
                                                                (listDHH["content"][j]
                                                                            [
                                                                            "closeNominateUser"] !=
                                                                        null)
                                                                    ? listDHH["content"][j]["nguoichot_tiencu"]
                                                                            [
                                                                            "fullName"]
                                                                        .toString()
                                                                    : " ",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                              ),
                                                            ),
                                                          ),
                                                          DataCell(
                                                            Text(
                                                              (listDHH["content"]
                                                                              [
                                                                              j]
                                                                          [
                                                                          "closeNominateDate"] !=
                                                                      null)
                                                                  ? FormatDate.formatDateView(DateTime.parse(listDHH["content"]
                                                                              [
                                                                              j]
                                                                          [
                                                                          "closeNominateDate"]
                                                                      .toString()))
                                                                  : " ",
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : Center(
                                            child: CircularProgressIndicator()),
                              ),
                              Container(
                                  child: DynamicTablePagging(
                                      rowCount, currentPageDef, rowPerPage,
                                      pageChangeHandler: (currentPage) {
                                setState(() {
                                  futureListDonhang =
                                      getListDonHang(currentPage);
                                  currentPageDef = currentPage;
                                });
                              }, rowPerPageChangeHandler: (rowPerPageChange) {
                                rowPerPage = rowPerPageChange;
                                futureListDonhang = getListDonHang(currentPage);

                                setState(() {});
                              }))
                            ],
                          ))
                    else if (snapshot.hasError)
                      Text("Fail! ${snapshot.error}")
                    else
                      Center(child: CircularProgressIndicator()),
                    Footer(
                        marginFooter: EdgeInsets.only(top: 25),
                        paddingFooter: EdgeInsets.all(15))
                    //Dynamictable
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
