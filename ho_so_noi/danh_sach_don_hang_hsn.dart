import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/style.dart';
import 'package:gentelella_flutter/common/toast.dart';
import 'package:gentelella_flutter/widgets/ui/kiem_soat/setting-data/donhang.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../api.dart';
import '../../../common/widgets_form.dart';
import '../../../model/market_development/order.dart';
import '../../../model/market_development/union.dart';
import '../../../model/model.dart';
import '../navigation.dart';

final String urlDonHang = "ho-so-noi/don-hang";

BuildContext? contexts;

class DanhSachDonHangHSN extends StatelessWidget {
  const DanhSachDonHangHSN({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: DanhSachDonHangHSNBody());
  }
}

Map<int, String> orderName = {0: "Tất cả"};
Map<int, String> organizationName = {0: "Tất cả"};
String dropdownValue = 'Tất cả';
String dropDownValue = 'Tất cả';

late Future futureListDonhang;
var listDHH = {};
var listAam = {};

int rowPerPage = 10;
int rowCount = 0;
int totalElements = 0;
int currentPage = 0;
String selectedDH = "";
String selectedND = "";
Widget paging = Container();
var resultOrganizationDropDown = {};
var idND;
var idDH;

class DanhSachDonHangHSNBody extends StatefulWidget {
  DanhSachDonHangHSNBody({Key? key}) : super(key: key);

  @override
  State<DanhSachDonHangHSNBody> createState() => _DanhSachDonHangHSNBodyState();
}

class _DanhSachDonHangHSNBodyState extends State<DanhSachDonHangHSNBody> {
  Future getListDonHang(page) async {
    var response;
    if ((selectedDH == "" || selectedDH == "-1") &&
        (selectedND == "" || selectedND == '-1'))
      response = await httpGet(
          "/api/donhang/get/page?page=$page&size=$rowPerPage&sort=id&filter=orderStatusId>:2",
          context);
    else if ((selectedDH != "" || selectedDH != "-1") &&
        (selectedND == "" || selectedND == '-1')) {
      response = await httpGet(
          "/api/donhang/get/page?filter=id:$selectedDH and orderStatusId>:2",
          context);
    } else if ((selectedDH == "" || selectedDH == "-1") &&
        (selectedND != "" || selectedND != '-1')) {
      response = await httpGet(
          "/api/donhang/get/page?filter=nghiepdoan.id:$selectedND and orderStatusId>:2",
          context);
    } else {
      response = await httpGet(
          "/api/donhang/get/page?filter=id:$selectedDH AND nghiepdoan.id:$selectedND",
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

  var listBonus = {};
  dynamic orderBonus = {};
  dynamic targetBonus = {};
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
          targetBonus[listDHH1["content"][i]["id"]] =
              listBonus["content"][j]["targetBonus"];
        }
      }
    }
    print(orderBonus);
    print(targetBonus);
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

  Future<List<OrderN>> getListOrder() async {
    List<OrderN> resultOrder = [];
    var response1 = await httpGet("/api/donhang/get/page?sort=id", context);
    var body = jsonDecode(response1['body']);
    var content = [];
    if (response1.containsKey("body")) {
      setState(() {
        content = body['content'];
        resultOrder = content.map((e) {
          return OrderN.fromJson(e);
        }).toList();
        OrderN all = new OrderN(id: -1, orderName: "Tất cả", orderCode: '');
        resultOrder.insert(0, all);
      });
    }
    return resultOrder;
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

  int getIndex(page, rowPerPage, index) {
    return ((page * rowPerPage) + index) + 1;
  }

  callApi() async {
    await getListOrder1();
    await getBonus();
  }

  @override
  void initState() {
    super.initState();
    futureListDonhang = getListDonHang(currentPage);
    callApi();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: userRule('/danh-sach-don-hang-hsn', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
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
                            TitlePage(
                              listPreTitle: [
                                {'url': '/ho-so-noi', 'title': 'Hồ sơ nội'},
                              ],
                              content: 'Danh sách đơn hàng',
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
                          child: Row(
                            children: [
                              Expanded(
                                // child: Padding(
                                //   padding: EdgeInsets.fromLTRB(60, 0, 0, 0),
                                child: Row(children: [
                                  Text('Đơn hàng', style: titleWidgetBox),
                                  Expanded(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(20, 0, 50, 0),
                                      child: Container(
                                        height: 40,
                                        child: DropdownSearch<OrderN>(
                                          // ignore: deprecated_member_use
                                          hint: "Tất cả",
                                          maxHeight: 350,
                                          mode: Mode.MENU,
                                          showSearchBox: true,
                                          onFind: (String? filter) =>
                                              getListOrder(),
                                          itemAsString: (OrderN? u) =>
                                              '${u!.orderName}' +
                                              '(${u.orderCode})',
                                          dropdownSearchDecoration:
                                              styleDropDown,
                                          onChanged: (value) {
                                            setState(() {
                                              idDH = value!.id;
                                              selectedDH = idDH.toString();
                                              print(selectedDH);
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
                                          onFind: (String? filter) =>
                                              getListUnion(),
                                          itemAsString: (UnionObj? u) =>
                                              u!.orgName!,
                                          dropdownSearchDecoration:
                                              styleDropDown,
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
                                        margin:
                                            EdgeInsets.fromLTRB(50, 0, 50, 0),
                                        child: Row(children: [
                                          TextButton(
                                            style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 20.0,
                                                horizontal: 20.0,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                              ),
                                              backgroundColor: Color.fromRGBO(
                                                  245, 117, 29, 1),
                                              primary: Theme.of(context)
                                                  .iconTheme
                                                  .color,
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
                                                selectedDH = "";
                                                selectedND = "";
                                              });
                                            },
                                            child: Row(
                                              children: [
                                                Icon(Icons.search,
                                                    color: Colors.white,
                                                    size: 15),
                                                Text(' Tìm kiếm',
                                                    style: textButton),
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
                      Consumer<NavigationModel>(
                        builder: (context, navigationModel, child) => Container(
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
                                Container(
                                  width: MediaQuery.of(context).size.width * 1,
                                  child: DataTable(
                                    showCheckboxColumn: false,
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
                                          label: Text('Nghiệp đoàn',
                                              style: titleTableData)),
                                      DataColumn(
                                          label: Text('Trạng thái',
                                              style: titleTableData)),
                                      DataColumn(
                                          label: Text('Tính chỉ tiêu',
                                              style: titleTableData)),
                                      DataColumn(
                                          label: Text('Thưởng đơn hàng',
                                              style: titleTableData)),
                                      DataColumn(label: Text(' '))
                                    ],
                                    rows: <DataRow>[
                                      for (var i = 0;
                                          i < listDHH["content"].length;
                                          i++)
                                        DataRow(
                                          cells: <DataCell>[
                                            DataCell(Text(
                                              getIndex(currentPage, rowPerPage,
                                                      i)
                                                  .toString(),
                                            )),

                                            DataCell(Text(
                                              listDHH["content"][i]
                                                  ["orderCode"],
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400),
                                            )),

                                            DataCell(
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.2,
                                                child: Text(
                                                    listDHH["content"][i]
                                                        ["orderName"],
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400)),
                                              ),
                                            ),

                                            DataCell(
                                              Text(
                                                  listDHH["content"][i]
                                                              ["nghiepdoan"]
                                                          ["orgName"] ??
                                                      " nodata",
                                                  style: bangDuLieu),
                                            ),
                                            DataCell(
                                              Text(
                                                  listDHH["content"][i][
                                                              "trangthai_donhang"]
                                                          ['statusName'] ??
                                                      "",
                                                  style: bangDuLieu),
                                            ),

                                            DataCell(
                                              Text(
                                                  (targetBonus[
                                                              listDHH["content"]
                                                                  [i]["id"]] !=
                                                          null)
                                                      ? NumberFormat
                                                              .simpleCurrency(
                                                                  locale: "vi")
                                                          .format(targetBonus[
                                                              listDHH["content"]
                                                                  [i]["id"]])
                                                          .toString()
                                                      : "0",
                                                  style: bangDuLieu),
                                            ),

                                            DataCell(
                                              Text(
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
                                                      : "0",
                                                  style: bangDuLieu),
                                            ),
                                            DataCell(Row(
                                              children: [
                                                getRule(listRule.data, Role.Xem,
                                                            context) ==
                                                        true
                                                    ? Container(
                                                        child: InkWell(
                                                            onTap: () {
                                                              navigationModel.add(
                                                                  pageUrl:
                                                                      "/xem-chi-tiet-don-hang/${listDHH["content"][i]["id"]}");
                                                            },
                                                            child: Icon(Icons
                                                                .visibility)))
                                                    : Container(),
                                                getRule(listRule.data, Role.Sua,
                                                            context) ==
                                                        true
                                                    ? Container(
                                                        margin:
                                                            EdgeInsets.fromLTRB(
                                                                10, 0, 0, 0),
                                                        child: InkWell(
                                                            onTap: () {
                                                              if (listDHH["content"]
                                                                          [i][
                                                                      "orderBonus"] ==
                                                                  0) {
                                                                navigationModel.add(
                                                                    pageUrl:
                                                                        "/cau-hinh-thuong-hsn/${listDHH["content"][i]["id"]}");
                                                              } else {
                                                                showToast(
                                                                    context:
                                                                        context,
                                                                    msg:
                                                                        "Đơn hàng đã thanh toán không được sửa",
                                                                    color: Colors
                                                                        .red,
                                                                    icon: Icon(Icons
                                                                        .close));
                                                              }
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
                                  ),
                                ),
                                if (totalElements != 0)
                                  paging
                                else
                                  Center(
                                      child: Text("Không có bản ghi nào !",
                                          style: TextStyle(fontSize: 16))),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Footer(marginFooter: EdgeInsets.only(top: 25), paddingFooter: EdgeInsets.all(15))
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text('Delivery error: ${snapshot.error.toString()}');
                } else {
                  return Center(child: const CircularProgressIndicator());
                }
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
