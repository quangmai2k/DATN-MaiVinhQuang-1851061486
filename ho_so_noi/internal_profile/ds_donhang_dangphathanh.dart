import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/api.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../../common/dynamic_table.dart';
import '../../../../common/style.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/market_development/order.dart';
import '../../../../model/model.dart';
import '../../../../model/type.dart';
import '../../navigation.dart';

class ReleaseOrder extends StatefulWidget {
  ReleaseOrder({Key? key}) : super(key: key);

  @override
  _ReleaseOrderState createState() => _ReleaseOrderState();
}

class _ReleaseOrderState extends State<ReleaseOrder> {
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

  bool checkSelected = false;
  var listDHH;
  RxString dataSelect = "Chờ tiến cử lại".obs;
  RxString dataSelect1 = "Do cá nhân".obs;
  final String urlAddNewUpdateSI = "quan-ly-ho-so-tts/trainee-information";
  late List<TableDSTTS> listSelectedRow;
  var resultListNguoiDung = {};
  var resultTTSTienCu = {};
  var resultListPay = {};
// ignore: unused_element
  String? selectedValueDH;
  String dropdownValue = 'Tất cả';
  String selectedDH = "";
  String selectedStatus = "";
  var resultDonHangDropDown = {};
  var ipDH;
  var resultColseTheListTrainee = {};

  var contentDonHang = [];
  late Future futureListDonhang;
  var resultUpdateTtsStatusId = {};
  var body = {};
  var page = 0;
  var rowPerPage = 10;
  var totalElements = 0;
  var firstRow = 1, lastRow = 0;
  var rowCount = 0;
  int currentPageDef = 1;
  var currentPage = 1;
  var idDH;

  @override
  void initState() {
    super.initState();
    callApi();
  }

  callApi() async {
    await (futureListDonhang = getListDonHang(currentPage));
  }

  getListDonHang(page) async {
    var response;
    if (selectedDH == "" || selectedDH == "0")
      response = await httpGet("/api/donhang/get/page?page=${page - 1}&size=$rowPerPage&createdDate:max(date)&filter=orderStatusId:2", context);
    else {
      response = await httpGet(
          "/api/donhang/get/page?page=${page - 1}&size=$rowPerPage&createdDate:max(date)&filter=id:$selectedDH and orderStatusId:2", context);
    }
    if (response.containsKey("body")) {
      setState(() {
        currentPage = page + 1;
        listDHH = jsonDecode(response["body"]);
        rowCount = listDHH["totalElements"];
      });
    }
    return listDHH;
  }

  Future<List<Order>> getListOrder() async {
    List<Order> resultOrder = [];
    var response1 = await httpGet("/api/donhang/get/page?sort=id&filter=orderStatusId:2 and (stopProcessing:0 or stopProcessing is null)", context);
    var body = jsonDecode(response1['body']);
    var content = [];
    if (response1.containsKey("body")) {
      setState(() {
        content = body['content'];
        resultOrder = content.map((e) {
          return Order.fromJson(e);
        }).toList();
        Order all = new Order(id: 0, orderName: "Tất cả", enterprise: null, jobs: null, orderCode: '', orderStatusId: 0, union: null);
        resultOrder.insert(0, all);
      });
    }
    return resultOrder;
  }

  Map<int, String> status = {0: "Tất cả", 1: "Đã chốt", 2: "Chưa chốt"};
  Map<int, String> orderName = {0: "Tất cả"};

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: userRule('/don-hang-dang-phat-hanh', context),
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
                              Text('Hồ sơ nội', style: TextStyle(color: Color(0xff009C87))),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Danh sách đơn hàng đang phát hành', style: titlePage),
                        ],
                      ),
                    ),
                    Container(
                      color: backgroundPage,
                      padding: EdgeInsets.symmetric(vertical: verticalPaddingPage, horizontal: horizontalPaddingPage),
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
                                      style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.w700)),
                                ),
                                Expanded(
                                  flex: 6,
                                  child: Container(
                                    height: 40,
                                    child: DropdownSearch<Order>(
                                      // ignore: deprecated_member_use
                                      hint: "Tất cả",
                                      maxHeight: 350,
                                      mode: Mode.MENU,
                                      showSearchBox: true,
                                      onFind: (String? filter) => getListOrder(),
                                      itemAsString: (Order? u) => u!.orderName,
                                      dropdownSearchDecoration: styleDropDown,
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
                                Expanded(flex: 7, child: Container()),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                      child: Row(children: [
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16.0,
                                          horizontal: 16.0,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5.0),
                                        ),
                                        backgroundColor: Color.fromRGBO(245, 117, 29, 1),
                                        primary: Theme.of(context).iconTheme.color,
                                        textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          futureListDonhang = getListDonHang(0);
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          const Icon(Icons.search, color: Colors.white),
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
                          padding: EdgeInsets.symmetric(horizontal: horizontalPaddingPage),
                          child: Column(
                            children: [
                              Consumer<NavigationModel>(
                                builder: (context, navigationModel, child) => Container(
                                  width: MediaQuery.of(context).size.width * 1,
                                  child: DataTable(
                                    columnSpacing: 100,
                                    showCheckboxColumn: true,
                                    columns: [
                                      DataColumn(label: Text('STT', style: titleTableData)),
                                      DataColumn(label: Text('Mã đơn hàng', style: titleTableData)),
                                      DataColumn(label: Text('Tên đơn hàng', style: titleTableData)),
                                      DataColumn(label: Text('', style: titleTableData)),
                                    ],
                                    rows: <DataRow>[
                                      if (listDHH["content"] != null)
                                        for (int j = 0; j < listDHH["content"].length; j++)
                                          DataRow(
                                            cells: <DataCell>[
                                              DataCell(Text(
                                                "${j + 1}",
                                              )),
                                              DataCell(
                                                Text(
                                                  listDHH["content"][j]["orderCode"] ?? "no data",
                                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  listDHH["content"][j]["orderName"] ?? "no data",
                                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                                                ),
                                              ),
                                              DataCell(
                                                getRule(listRule.data, Role.Xem, context) == true
                                                    ? Container(
                                                        child: InkWell(
                                                            onTap: () {
                                                              navigationModel.add(pageUrl: "/xem-chi-tiet-don-hang/${listDHH["content"][j]["id"]}");
                                                            },
                                                            child: Icon(Icons.visibility)))
                                                    : Container(),
                                              )
                                            ],
                                          ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                  child: DynamicTablePagging(rowCount, currentPageDef, rowPerPage, pageChangeHandler: (currentPage) {
                                setState(() {
                                  futureListDonhang = getListDonHang(currentPage);
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
                      Footer(marginFooter: EdgeInsets.only(top: 25), paddingFooter: EdgeInsets.all(15))
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
