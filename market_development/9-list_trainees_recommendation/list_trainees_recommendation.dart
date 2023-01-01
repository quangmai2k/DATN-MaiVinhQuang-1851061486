import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import 'package:gentelella_flutter/common/widgets_form.dart';

import 'package:provider/provider.dart';
import '../../../../../common/style.dart';
import '../../../../../model/model.dart';
import '../../../../api.dart';
import '../../../../common/dynamic_table.dart';
import '../../../../model/market_development/order.dart';
import '../../navigation.dart';
import 'modal_tts_tiencu_donhang.dart';
import "package:collection/collection.dart";

class ListTraineesRecommendation extends StatelessWidget {
  ListTraineesRecommendation({Key? key, this.securityModel}) : super(key: key);
  SecurityModel? securityModel;
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: ListTraineesRecommendationBody(securityModel: securityModel));
  }
}

class ListTraineesRecommendationBody extends StatefulWidget {
  SecurityModel? securityModel;
  ListTraineesRecommendationBody({Key? key, this.securityModel}) : super(key: key);

  @override
  State<ListTraineesRecommendationBody> createState() => _ListTraineesRecommendationBodyState();
}

class _ListTraineesRecommendationBodyState extends State<ListTraineesRecommendationBody> {
  var body = {};
  var page = 1;
  var rowPerPage = 10;
  var totalElements = 0;
  var firstRow = 1, lastRow = 0;
  var rowCount = 0;
  var currentPage = 1;
  int _order = -1;

  late Future<List<Order>> futureListOrder;
  List<Order> listOrder = [];

  String findOder = "";
  Future<List<Order>> getListOrder(page, String findOder) async {
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }
    if (page < 1) {
      page = 0;
    }

    var response;

    String conditionByDepart = "";
    try {
      if (widget.securityModel != null) {
        if (widget.securityModel!.userLoginCurren != null) {
          if (widget.securityModel!.userLoginCurren['teamId'] != null) {
            conditionByDepart += " nhanvien_xuly.teamId:${widget.securityModel!.userLoginCurren['teamId']}";
          } else {
            conditionByDepart = "";
          }
        }
      }
    } catch (e) {
      print(e);
    }

    if (findOder.isNotEmpty) {
      if (conditionByDepart.isNotEmpty) {
        // and nominateStatus:0
        response = await httpGet(
            "/api/donhang/get/page?page=$page&size=$rowPerPage&sort=nominateStatus,asc&filter=orderStatusId>1 and stopProcessing:0  and $findOder AND $conditionByDepart", context);
      } else {
        response = await httpGet("/api/donhang/get/page?page=$page&size=$rowPerPage&sort=nominateStatus,asc&filter=orderStatusId>1 and stopProcessing:0 AND $findOder", context);
      }
    } else {
      if (conditionByDepart.isNotEmpty) {
        response =
            await httpGet("/api/donhang/get/page?page=$page&size=$rowPerPage&sort=nominateStatus,asc&filter=orderStatusId>1 and stopProcessing:0  AND $conditionByDepart", context);
      } else {
        response = await httpGet("/api/donhang/get/page?page=$page&size=$rowPerPage&sort=nominateStatus,asc&filter=orderStatusId>1 and stopProcessing:0 ", context);
      }
    }

    var content = [];
    if (response.containsKey("body")) {
      var body = jsonDecode(response['body']);
      setState(() {
        currentPage = page + 1;
        content = body['content'];
        rowCount = body["totalElements"];
        totalElements = body["totalElements"];
        lastRow = totalElements;
        listOrder = content.map((e) {
          return Order.fromJson(e);
        }).toList();
      });
      return listOrder;
    }
    return listOrder;
  }

  dynamic listCountTrainee = {};
  getCountTrainee() async {
    var resultListOrder = [];
    var listTraineeGroupByOrder = {};
    var listOrderId = [];
    var response = await httpGet(
        "/api/donhang-tts-tiencu/get/page?filter=nguoidung.ttsStatusId:4 and (nguoidung.stopProcessing:0 or nguoidung.stopProcessing is null ) and qcApproval:1 and nguoidung.isTts:1 and ptttApproval!2",
        context);
    if (response.containsKey("body")) {
      setState(() {
        resultListOrder = jsonDecode(response["body"])["content"];
        listTraineeGroupByOrder = groupBy(resultListOrder, (dynamic obj) {
          return obj['orderId'];
        });

        listTraineeGroupByOrder.forEach((key, value) {
          if (key != null) {
            listOrderId.add(key);
          }
        });
        print(listOrderId);
      });
      for (int i = 0; i < listOrderId.length; i++) {
        listCountTrainee[listOrderId[i]] = listTraineeGroupByOrder[listOrderId[i]].length;
      }
    }
  }

  Future<List<Order>> getListOrderSearchBy({conditon}) async {
    List<Order> listSearchBy = [];
    String dieuKien = "";
    if (conditon != null) {
      dieuKien += " AND orderName ~'*$conditon*'";
    }
    var response = await httpGet("/api/donhang/get/page?filter=orderStatusId:2 and stopProcessing:0 and nominateStatus:0" + dieuKien, context);
    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      content = body['content'];
      listSearchBy = content.map((e) {
        return Order.fromJson(e);
      }).toList();
      Order order = new Order(id: -1, union: null, enterprise: null, jobs: null, orderCode: "", orderName: "Tất cả", orderStatusId: -1);

      listSearchBy.insert(0, order);
      print("trung $listSearchBy");
      // print(object);
      return listSearchBy;
    }

    return listSearchBy;
  }

  getValue(Order? data) {
    try {
      if (data != null) {
        if (data.union != null) {
          if (data.union!.phongban != null) {
            return data.union!.phongban!.departName;
          }
        }
      }
    } catch (e) {
      print(e);
    }
    return "Chưa có công ty";
  }

  @override
  void initState() {
    super.initState();
    futureListOrder = getListOrder(page - 1, findOder);
    getCountTrainee();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: userRule('/danh-sach-tts-de-xuat-tien-cu-pttt', context),
        builder: (context, listRule) {
          if (listRule.hasData) {
            return FutureBuilder<List<Order>>(
                future: futureListOrder,
                builder: (context, snapshot) {
                  var index = (currentPage - 1) * (rowPerPage);
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
                                child: TitlePage(
                                  listPreTitle: [
                                    {'url': '/phat-trien-thi-truong', 'title': 'Dashboard'},
                                    {'url': '/danh-sach-tts-de-xuat-tien-cu-pttt', 'title': 'Danh sách TTS đề xuất tiến cử'}
                                  ],
                                  content: 'Danh sách TTS đề xuất tiến cử',
                                ),
                              ),
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
                                      child: Column(
                                        children: [
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
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Text('Đơn hàng', style: titleWidgetBox),
                                              ),
                                              Expanded(
                                                flex: 10,
                                                child: Container(
                                                  color: Colors.white,
                                                  // width: MediaQuery.of(context).size.width * 0.15,
                                                  height: 50,
                                                  child: DropdownSearch<Order>(
                                                    mode: Mode.MENU,
                                                    showSearchBox: true,
                                                    onFind: (String? filter) => getListOrderSearchBy(conditon: filter),
                                                    filterFn: (order, filter) => order!.userFilterByCreationDate(filter!),
                                                    itemAsString: (Order? u) => u!.orderName + "(${u.orderCode})",
                                                    dropdownSearchDecoration: styleDropDown,
                                                    emptyBuilder: (context, String? value) {
                                                      return const Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 10),
                                                        child: Align(alignment: Alignment.center, child: Text("Không có dữ liệu !")),
                                                      );
                                                    },
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _order = value!.id;
                                                      });
                                                      print(value);
                                                    },
                                                  ),
                                                ),
                                              ),
                                              Expanded(flex: 2, child: Container()),
                                            ],
                                          ),

                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(30, 30, 0, 0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                //tìm kiếm
                                                Container(
                                                  margin: EdgeInsets.only(left: 20),
                                                  child: TextButton.icon(
                                                    style: TextButton.styleFrom(
                                                      padding: const EdgeInsets.symmetric(
                                                        vertical: 20.0,
                                                        horizontal: 10.0,
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
                                                        print(_order);
                                                        if (_order == -1)
                                                          findOder = "";
                                                        else
                                                          findOder = "id:$_order";
                                                        print(findOder);
                                                        getListOrder(page - 1, findOder);
                                                      });
                                                    },
                                                    icon: Transform.rotate(
                                                      angle: 270,
                                                      child: Icon(
                                                        Icons.search,
                                                        color: Colors.white,
                                                        size: 15,
                                                      ),
                                                    ),
                                                    label: Row(
                                                      children: [
                                                        Text('Tìm kiếm ', style: textButton),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width * 1,
                                      margin: marginTopBoxContainer,
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
                                                'Thông tin thực tập sinh',
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
                                          // Start Datatable
                                          if (snapshot.hasData)
                                            // Start Datatable
                                            Row(
                                              children: [
                                                Expanded(child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                                                  return Center(
                                                      child: SingleChildScrollView(
                                                          scrollDirection: Axis.horizontal,
                                                          child: ConstrainedBox(
                                                              constraints: BoxConstraints(minWidth: constraints.maxWidth),
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
                                                                    label: Text('STT', style: titleTableData),
                                                                  ),
                                                                  DataColumn(
                                                                    label: Text(
                                                                      'Đơn hàng',
                                                                      style: titleTableData,
                                                                    ),
                                                                  ),
                                                                  DataColumn(
                                                                    label: Text(
                                                                      'Nghiệp đoàn',
                                                                      style: titleTableData,
                                                                    ),
                                                                  ),
                                                                  DataColumn(
                                                                    label: Text(
                                                                      'Xí nghiệp',
                                                                      style: titleTableData,
                                                                    ),
                                                                  ),
                                                                  DataColumn(
                                                                    label: Text(
                                                                      'Công ty',
                                                                      style: titleTableData,
                                                                    ),
                                                                  ),
                                                                  DataColumn(
                                                                    label: Text(
                                                                      'Số lượng \nTTS chờ duyệt',
                                                                      style: titleTableData,
                                                                    ),
                                                                  ),
                                                                  DataColumn(
                                                                    label: Text(
                                                                      'Hành động',
                                                                      style: titleTableData,
                                                                    ),
                                                                  ),
                                                                ],
                                                                rows: <DataRow>[
                                                                  for (int i = 0; i < listOrder.length; i++)
                                                                    DataRow(
                                                                      cells: <DataCell>[
                                                                        DataCell(
                                                                          Container(
                                                                            child: Text("${i + index + 1}"),
                                                                          ),
                                                                        ),
                                                                        DataCell(
                                                                          Tooltip(
                                                                            message: listOrder[i].nominateStatus == 1 ? "Đơn hàng đã chốt tiến cử" : "",
                                                                            child: InkWell(
                                                                              onTap: getRule(listRule.data, Role.Sua, context)
                                                                                  ? () {
                                                                                      showDialog(
                                                                                          context: context,
                                                                                          builder: (BuildContext context) {
                                                                                            print(listOrder[i].id);

                                                                                            return ModalDanhSachTTSTienCuDonHang(
                                                                                              idOreder: listOrder[i].id,
                                                                                              order: listOrder[i],
                                                                                            );
                                                                                          });
                                                                                      print(listOrder[i].orderCode);
                                                                                    }
                                                                                  : null,
                                                                              child: Container(
                                                                                width: (MediaQuery.of(context).size.width / 10) * 0.8,
                                                                                child: Text(
                                                                                  listOrder[i].orderName + "\n ( " + listOrder[i].orderCode + " )",
                                                                                  style: TextStyle(
                                                                                      fontSize: 14,
                                                                                      fontWeight: FontWeight.w400,
                                                                                      color: listOrder[i].nominateStatus == 1 ? Colors.red : Colors.blue),
                                                                                  textAlign: TextAlign.start,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        DataCell(
                                                                          Tooltip(
                                                                            message: !getRule(listRule.data, Role.Sua, context) ? "Bạn không có quyển" : "",
                                                                            child: InkWell(
                                                                              onTap: getRule(listRule.data, Role.Sua, context)
                                                                                  ? () {
                                                                                      showDialog(
                                                                                          context: context,
                                                                                          builder: (BuildContext context) {
                                                                                            print(listOrder[i].id);

                                                                                            return ModalDanhSachTTSTienCuDonHang(
                                                                                              idOreder: listOrder[i].id,
                                                                                              order: listOrder[i],
                                                                                            );
                                                                                          });
                                                                                    }
                                                                                  : null,
                                                                              child: Container(
                                                                                width: (MediaQuery.of(context).size.width / 10) * 0.9,
                                                                                child: Text(
                                                                                  listOrder[i].union!.orgName.toString(),
                                                                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.blue),
                                                                                  maxLines: 3,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        DataCell(
                                                                          Tooltip(
                                                                            message: !getRule(listRule.data, Role.Sua, context) ? "Bạn không có quyển" : "",
                                                                            child: InkWell(
                                                                              onTap: getRule(listRule.data, Role.Sua, context)
                                                                                  ? () {
                                                                                      showDialog(
                                                                                          context: context,
                                                                                          builder: (BuildContext context) {
                                                                                            print(listOrder[i].id);

                                                                                            return ModalDanhSachTTSTienCuDonHang(
                                                                                              idOreder: listOrder[i].id,
                                                                                              order: listOrder[i],
                                                                                            );
                                                                                          });
                                                                                    }
                                                                                  : null,
                                                                              child: Container(
                                                                                width: (MediaQuery.of(context).size.width / 10) * 0.6,
                                                                                child: Text(
                                                                                  listOrder[i].enterprise!.companyName.toString(),
                                                                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.blue),
                                                                                  maxLines: 3,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        DataCell(
                                                                          Tooltip(
                                                                            message: !getRule(listRule.data, Role.Sua, context) ? "Bạn không có quyển" : "",
                                                                            child: InkWell(
                                                                              onTap: getRule(listRule.data, Role.Sua, context)
                                                                                  ? () {
                                                                                      showDialog(
                                                                                          context: context,
                                                                                          builder: (BuildContext context) {
                                                                                            print(listOrder[i].id);

                                                                                            return ModalDanhSachTTSTienCuDonHang(
                                                                                              idOreder: listOrder[i].id,
                                                                                              order: listOrder[i],
                                                                                            );
                                                                                          });
                                                                                    }
                                                                                  : null,
                                                                              child: Container(
                                                                                width: (MediaQuery.of(context).size.width / 10) * 0.5,
                                                                                child: Text(
                                                                                  getValue(listOrder[i]),
                                                                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.blue),
                                                                                  maxLines: 3,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        DataCell(
                                                                          Tooltip(
                                                                            message: !getRule(listRule.data, Role.Sua, context) ? "Bạn không có quyển" : "",
                                                                            child: InkWell(
                                                                              onTap: getRule(listRule.data, Role.Sua, context)
                                                                                  ? () {
                                                                                      showDialog(
                                                                                          context: context,
                                                                                          builder: (BuildContext context) {
                                                                                            return ModalDanhSachTTSTienCuDonHang(
                                                                                              idOreder: listOrder[i].id,
                                                                                              order: listOrder[i],
                                                                                            );
                                                                                          });
                                                                                    }
                                                                                  : null,
                                                                              child: Container(
                                                                                width: (MediaQuery.of(context).size.width / 10) * 0.5,
                                                                                child: Text(
                                                                                  listCountTrainee[listOrder[i].id] != null ? listCountTrainee[listOrder[i].id].toString() : "0",
                                                                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.blue),
                                                                                  maxLines: 3,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        DataCell(Row(
                                                                          children: [
                                                                            getRule(listRule.data, Role.Xem, context)
                                                                                ? Container(
                                                                                    margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                                    child: InkWell(
                                                                                      onTap: () {
                                                                                        navigationModel.add(pageUrl: "/xem-chi-tiet-don-hang/${snapshot.data![i].id}");
                                                                                      },
                                                                                      child: Icon(Icons.visibility),
                                                                                    ),
                                                                                  )
                                                                                : Container(),
                                                                          ],
                                                                        )),
                                                                      ],
                                                                      // selected: _selected[i],
                                                                      // onSelectChanged: (bool? value) {
                                                                      //   setState(() {});
                                                                      // },
                                                                    ),
                                                                ],
                                                              ))));
                                                })),
                                              ],
                                            )
                                          else if (snapshot.hasError)
                                            Text("Fail! ${snapshot.error}")
                                          else if (!snapshot.hasData)
                                            Center(
                                              child: CircularProgressIndicator(),
                                            ),
                                          // End Datatable
                                          Container(
                                            margin: const EdgeInsets.only(right: 50),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                DynamicTablePagging(
                                                  rowCount,
                                                  currentPage,
                                                  rowPerPage,
                                                  pageChangeHandler: (page) async {
                                                    setState(() {
                                                      getListOrder(page - 1, findOder);
                                                    });
                                                  },
                                                  rowPerPageChangeHandler: (rowPerPage) {
                                                    setState(() {
                                                      this.rowPerPage = rowPerPage!;
                                                      //coding
                                                      this.firstRow = page * currentPage;
                                                      getListOrder(page - 1, findOder);
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Footer()
                                  ],
                                ),
                              ),
                            ],
                          ));
                });
          } else if (listRule.hasError) {
            return Text('${listRule.error}');
          }
          return Center(child: CircularProgressIndicator());
        });
  }
}
