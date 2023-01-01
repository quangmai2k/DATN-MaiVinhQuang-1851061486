import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/forms/market_development/utils/funciton.dart';

import 'package:provider/provider.dart';

import '../../../../../api.dart';
import '../../../../../common/dynamic_table.dart';
import '../../../../../common/style.dart';
import '../../../../../model/market_development/lichsuthanhtoan.dart';
import '../../../../../model/market_development/union.dart';
import '../../../../../model/model.dart';

class PaymentHistoryDetail extends StatefulWidget {
  final UnionObj? union;
  PaymentHistoryDetail({Key? key, this.union}) : super(key: key);

  @override
  State<PaymentHistoryDetail> createState() => _PaymentHistoryDetailState();
}

class _PaymentHistoryDetailState extends State<PaymentHistoryDetail> {
  DateTime selectedDate = DateTime.now();
  List<PaymentHistory> listPaymentHistory = [];
  late Future<List<PaymentHistory>> futurePaymentHistorys;
  bool get wantKeepAlive => true; //chuyển sang false thì khi tab sẽ load lại trang
  var body = {};
  var page = 1;
  var rowPerPage = 5;
  var totalElements = 0;
  var firstRow = 1, lastRow = 0;
  var rowCount = 0;
  var currentPage = 1;
  Map<int, String> _mapStatusofUnion = {
    0: ' Chưa thanh toán',
    1: ' Đã thanh toán',
    2: ' Thanh toán 1 phần',
  };
  Future<List<PaymentHistory>> getListPaymentHistory(int id, page) async {
    // if (page * rowPerPage > totalElements) {
    //   page = (1.0 * totalElements / rowPerPage - 1).ceil();
    // }
    // if (page < 1) {
    //   page = 0;
    // }
    var response;
    Map<String, String> requestParam = Map();

    String condition = "";
    page = page - 1;
    if (requestParam.isNotEmpty) {
      for (var entry in requestParam.entries) {
        if (entry.key == "orgName") {
          condition += " ( ${entry.key}~'*${entry.value}*'";
        }
        if (entry.key == "orgCode") {
          condition += " OR ${entry.key}~'*${entry.value}*' ) ";
        }

        if (entry.key == "contractStatus") {
          if (entry.value != "-1") {
            condition += " AND ${entry.key}:${entry.value}";
          } else {
            //condition +=
            //" AND ( contractStatus:0 OR contractStatus:1 OR contractStatus:2 OR contractStatus:3 )";
          }
        }
      }

      response = await httpGet("/api/nghiepdoan-thanhtoan/get/page?page=$page&size=$rowPerPage&filter=$condition", context);
    } else {
      response = await httpGet("/api/nghiepdoan-thanhtoan/get/page?page=$page&size=$rowPerPage&sort=id&filter=orgId:${widget.union!.id}", context);
    }
    var body = jsonDecode(response['body']);
    var content = [];
    // listUnionObjectResult = content.map((e) {
    //   return UnionObj.fromJson(e);
    // }).toList();

    print("DM ${body['content']}");
    if (response.containsKey("body")) {
      setState(() {
        currentPage = page;
        content = body['content'];
        rowCount = body["totalElements"];
        totalElements = body["totalElements"];
        lastRow = totalElements;
        listPaymentHistory = content.map((e) {
          return PaymentHistory.fromJson(e);
        }).toList();

        if (listPaymentHistory.length > 0) {
          firstRow = (currentPage + 1) * rowPerPage + 1;
          lastRow = (currentPage + 1) * rowPerPage;
          if (lastRow > totalElements) {
            lastRow = totalElements;
          }
        }
      });
    }

    return content.map((e) {
      return PaymentHistory.fromJson(e);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    futurePaymentHistorys = getListPaymentHistory(widget.union!.id!, page);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationModel>(
        builder: (context, navigationModel, child) => FutureBuilder<Object>(
            future: futurePaymentHistorys,
            builder: (context, snapshot) {
              return ListView(
                children: [
                  //==============Danh sách=====
                  Container(
                    width: MediaQuery.of(context).size.width * 1,
                    padding: paddingBoxContainer,
                    margin: marginBoxFormTab,
                    decoration: BoxDecoration(
                      color: colorWhite,
                      borderRadius: borderRadiusContainer,
                      boxShadow: [boxShadowContainer],
                      border: borderAllContainerBox,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Lịch sử thanh toán',
                              style: titleBox,
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
                        if (snapshot.hasData)
                          //Start Datatable
                          Container(
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
                                      style: titleTableData,
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Ngày',
                                      style: titleTableData,
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Trạng thái',
                                      style: titleTableData,
                                    ),
                                  ),
                                ],
                                rows: <DataRow>[
                                  for (int i = 0; i < listPaymentHistory.length; i++)
                                    DataRow(
                                      cells: <DataCell>[
                                        DataCell(Text("${(page - 1) * rowPerPage + i + 1}")),
                                        DataCell(Text(listPaymentHistory[i].paidDate != null ? getDateView(listPaymentHistory[i].paidDate) : "Chưa có dữ liệu")),
                                        DataCell(Text(listPaymentHistory[i].status != null ? _mapStatusofUnion[listPaymentHistory[i].status].toString() : "Chưa có dữ liệu")),
                                      ],
                                    ),
                                ],
                              ))
                        else if (snapshot.hasError)
                          Text("Fail! ${snapshot.error}")
                        else if (!snapshot.hasData)
                          Center(
                            child: CircularProgressIndicator(),
                          ),
                        //End Datatable
                        Container(
                          margin: const EdgeInsets.only(right: 50),
                          child: DynamicTablePagging(
                            rowCount,
                            currentPage + 1,
                            rowPerPage,
                            pageChangeHandler: (page) {
                              setState(() {
                                print("page $page");

                                currentPage = page;
                              });
                            },
                            rowPerPageChangeHandler: (rowPerPage) {
                              setState(() {
                                this.rowPerPage = rowPerPage!;

                                this.firstRow = page * currentPage;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }));
  }
}
