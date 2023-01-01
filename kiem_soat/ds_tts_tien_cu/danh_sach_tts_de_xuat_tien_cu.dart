import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import 'package:gentelella_flutter/common/widgets_form.dart';

import 'package:provider/provider.dart';
import '../../../../../../common/style.dart';
import '../../../../../../model/model.dart';
import '../../../../../api.dart';
import '../../../../../common/dynamic_table.dart';
import '../../../../../model/market_development/order.dart';
// import '../../navigation.dart';
// import '../../market_development/9-list_trainees_recommendation/modal_tts_tiencu_donhang.dart';
import '../../navigation.dart';
import 'model_tts_tien_cu.dart';
import "package:collection/collection.dart";

// import 'modal_tts_tiencu_donhang.dart';

class DanhSachTTSDeXuatTienCu extends StatelessWidget {
  DanhSachTTSDeXuatTienCu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: DanhSachTTSDeXuatTienCuBody());
  }
}

class DanhSachTTSDeXuatTienCuBody extends StatefulWidget {
  const DanhSachTTSDeXuatTienCuBody({Key? key}) : super(key: key);

  @override
  State<DanhSachTTSDeXuatTienCuBody> createState() =>
      _DanhSachTTSDeXuatTienCuBodyState();
}

class _DanhSachTTSDeXuatTienCuBodyState
    extends State<DanhSachTTSDeXuatTienCuBody> {
  var body = {};

  int _order = -1;

  late Future<List<Order>> futureListOrder;
  List<Order> listOrder = [];

  String findOder = "";
  Future<List<Order>> getListOrder(String findOder) async {
    var response;
    await getCountTrainee();

    if (findOder == "") {
      response = await httpGet(
          "/api/donhang/get/page?filter=orderStatusId>1 and orderStatusId<5 and stopProcessing:0 and nominateStatus:0",
          context);
    } else
      response = await httpGet(
          "/api/donhang/get/page?filter=orderStatusId:2 and stopProcessing:0 and nominateStatus:0 and $findOder",
          context);

    var content = [];
    if (response.containsKey("body")) {
      var body = jsonDecode(response['body']);
      content = body['content'];
      rowCount = body["totalElements"];
      setState(() {
        listOrder = content.map((e) {
          return Order.fromJson(e);
        }).toList();
      });
      return listOrder;
    }
    return listOrder;
  }

  Future<List<Order>> getListOrderSearchBy({conditon}) async {
    List<Order> listSearchBy = [];
    String dieuKien = "";
    if (conditon != null) {
      dieuKien += " AND orderName ~'*$conditon*'";
    }
    var response = await httpGet(
        "/api/donhang/get/page?filter=orderStatusId>1 and orderStatusId<5 and stopProcessing:0 and nominateStatus:0" +
            dieuKien,
        context);
    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      content = body['content'];
      listSearchBy = content.map((e) {
        return Order.fromJson(e);
      }).toList();
      Order order = new Order(
          id: -1,
          union: null,
          enterprise: null,
          jobs: null,
          orderCode: "",
          orderName: "Tất cả",
          orderStatusId: -1);

      listSearchBy.insert(0, order);
      // print(object);
      return listSearchBy;
    }

    return listSearchBy;
  }

  dynamic listCountTrainee = {};
  getCountTrainee() async {
    var resultListOrder = [];
    var listTraineeGroupByOrder = {};
    var listOrderId = [];
    var response = await httpGet(
        "/api/donhang-tts-tiencu/get/page?filter=donhang.orderStatusId>1 and donhang.orderStatusId<5 and donhang.stopProcessing:0 and donhang.nominateStatus:0 and nguoidung.stopProcessing:0 and qcApproval:0",
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
      });
      for (int i = 0; i < listOrderId.length; i++) {
        listCountTrainee[listOrderId[i]] =
            listTraineeGroupByOrder[listOrderId[i]].length;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    futureListOrder = getListOrder(findOder);
  }

  int rowCount = 0;
  int currentPage = 1;
  int rowPerPage = 10;
  var firstRow;
  var lastRow;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: userRule('/danh-sach-tts-de-xuat-tien-cu', context),
        builder: (context, listRule) {
          if (listRule.hasData) {
            return FutureBuilder<List<Order>>(
                future: futureListOrder,
                builder: (context, snapshot) {
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
                                    {'url': '/kiem-soat', 'title': 'Dashboard'},
                                    // {'url': '/danh-sach-tts-de-xuat-tien-cu', 'title': 'Danh sách TTS đề xuất tiến cử'}
                                  ],
                                  content: 'Danh sách TTS đề xuất tiến cử',
                                ),
                              ),
                              Container(
                                color: backgroundPage,
                                padding: EdgeInsets.symmetric(
                                    vertical: verticalPaddingPage,
                                    horizontal: horizontalPaddingPage),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width:
                                          MediaQuery.of(context).size.width * 1,
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
                                          //Đường line
                                          Container(
                                            margin:
                                                marginTopBottomHorizontalLine,
                                            child: Divider(
                                              thickness: 1,
                                              color: ColorHorizontalLine,
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Text('Đơn hàng',
                                                    style: titleWidgetBox),
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
                                                    onFind: (String? filter) =>
                                                        getListOrderSearchBy(
                                                            conditon: filter),
                                                    filterFn: (order, filter) =>
                                                        order!
                                                            .userFilterByCreationDate(
                                                                filter!),
                                                    itemAsString: (Order? u) =>
                                                        u!.orderName +
                                                        "(${u.orderCode})",
                                                    dropdownSearchDecoration:
                                                        styleDropDown,
                                                    emptyBuilder: (context,
                                                        String? value) {
                                                      return const Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 10),
                                                        child: Align(
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(
                                                                "Không có dữ liệu !")),
                                                      );
                                                    },
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _order = value!.id;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                  flex: 2, child: Container()),
                                            ],
                                          ),

                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                30, 30, 0, 0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                //tìm kiếm
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(left: 20),
                                                  child: TextButton.icon(
                                                    style: TextButton.styleFrom(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        vertical: 20.0,
                                                        horizontal: 10.0,
                                                      ),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.0),
                                                      ),
                                                      backgroundColor:
                                                          Color.fromRGBO(
                                                              245, 117, 29, 1),
                                                      primary: Theme.of(context)
                                                          .iconTheme
                                                          .color,
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .caption
                                                              ?.copyWith(
                                                                  fontSize:
                                                                      10.0,
                                                                  letterSpacing:
                                                                      2.0),
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        if (_order == -1)
                                                          findOder = "";
                                                        else
                                                          findOder =
                                                              "id:$_order";
                                                        currentPage = 1;
                                                        getListOrder(findOder);
                                                      });
                                                    },
                                                    // child: Row(
                                                    //   children: [
                                                    //     Text('Tìm kiếm', style: textButton),
                                                    //     const Icon(Icons.near_me, color: Colors.white),
                                                    //   ],
                                                    // ),
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
                                                        Text('Tìm kiếm ',
                                                            style: textButton),
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
                                      width:
                                          MediaQuery.of(context).size.width * 1,
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
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
                                            margin:
                                                marginTopBottomHorizontalLine,
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
                                                Expanded(child: LayoutBuilder(
                                                    builder:
                                                        (BuildContext context,
                                                            BoxConstraints
                                                                constraints) {
                                                  rowCount = listOrder.length;
                                                  firstRow = (currentPage - 1) *
                                                      rowPerPage;
                                                  lastRow =
                                                      currentPage * rowPerPage -
                                                          1;
                                                  if (lastRow > rowCount - 1) {
                                                    lastRow = rowCount - 1;
                                                  }
                                                  var sortList = [];
                                                  for (var row in listOrder) {
                                                    sortList.add({
                                                      'order': row,
                                                      "count": listCountTrainee[
                                                                  row.id] !=
                                                              null
                                                          ? listCountTrainee[
                                                              row.id]
                                                          : 0
                                                    });
                                                  }
                                                  sortList.sort((a, b) {
                                                    return b['count']
                                                        .compareTo(a['count']);
                                                    //softing on alphabetical order (Ascending order by Name String)
                                                  });
                                                  return Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: DataTable(
                                                              dataTextStyle: const TextStyle(
                                                                  color: Color(
                                                                      0xff313131),
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                              showBottomBorder:
                                                                  true,
                                                              dataRowHeight: 60,
                                                              showCheckboxColumn:
                                                                  true,
                                                              dataRowColor: MaterialStateProperty
                                                                  .resolveWith<
                                                                      Color?>((Set<
                                                                          MaterialState>
                                                                      states) {
                                                                if (states.contains(
                                                                    MaterialState
                                                                        .selected)) {
                                                                  return MaterialStateColor.resolveWith(
                                                                      (states) =>
                                                                          const Color(
                                                                              0xffeef3ff));
                                                                }
                                                                return MaterialStateColor
                                                                    .resolveWith(
                                                                        (states) =>
                                                                            Colors.white); // Use the default value.
                                                              }),
                                                              columns: <
                                                                  DataColumn>[
                                                                DataColumn(
                                                                  label: Text(
                                                                      'STT',
                                                                      style:
                                                                          titleTableData),
                                                                ),
                                                                DataColumn(
                                                                  label: Text(
                                                                    'Mã đơn hàng',
                                                                    style:
                                                                        titleTableData,
                                                                  ),
                                                                ),
                                                                DataColumn(
                                                                  label: Text(
                                                                    'Tên đơn hàng',
                                                                    style:
                                                                        titleTableData,
                                                                  ),
                                                                ),
                                                                DataColumn(
                                                                  label: Text(
                                                                    'Số lượng TTS chờ duyệt',
                                                                    style:
                                                                        titleTableData,
                                                                  ),
                                                                ),
                                                                DataColumn(
                                                                  label: Text(
                                                                    'Hành động',
                                                                    style:
                                                                        titleTableData,
                                                                  ),
                                                                ),
                                                              ],
                                                              rows: <DataRow>[
                                                                for (int i =
                                                                        firstRow;
                                                                    i <=
                                                                        lastRow;
                                                                    i++)
                                                                  DataRow(
                                                                    cells: <
                                                                        DataCell>[
                                                                      DataCell(
                                                                        Container(
                                                                          child: Text(
                                                                              "${i + 1}",
                                                                              textAlign: TextAlign.center),
                                                                        ),
                                                                      ),
                                                                      DataCell(
                                                                        Tooltip(
                                                                          message: !getRule(listRule.data, Role.Sua, context)
                                                                              ? "Bạn không có quyển"
                                                                              : "",
                                                                          child:
                                                                              TextButton(
                                                                            onPressed: getRule(listRule.data, Role.Sua, context)
                                                                                ? () {
                                                                                    showDialog(
                                                                                        context: context,
                                                                                        builder: (BuildContext context) {
                                                                                          return ModalDanhSachTTSTienCu(
                                                                                            idOreder: sortList[i]['order'].id,
                                                                                            order: sortList[i]['order'],
                                                                                          );
                                                                                        });
                                                                                  }
                                                                                : null,
                                                                            child:
                                                                                Container(
                                                                              width: (MediaQuery.of(context).size.width / 10) * 1,
                                                                              child: Text(
                                                                                sortList[i]['order'].orderCode,
                                                                                style: textButtonTable,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      DataCell(
                                                                        Tooltip(
                                                                          message: !getRule(listRule.data, Role.Sua, context)
                                                                              ? "Bạn không có quyển"
                                                                              : "",
                                                                          child:
                                                                              TextButton(
                                                                            onPressed: getRule(listRule.data, Role.Sua, context)
                                                                                ? () async {
                                                                                    await showDialog(
                                                                                        context: context,
                                                                                        builder: (BuildContext context) {
                                                                                          return ModalDanhSachTTSTienCu(
                                                                                            idOreder: sortList[i]['order'].id,
                                                                                            order: sortList[i]['order'],
                                                                                          );
                                                                                        });
                                                                                    futureListOrder = getListOrder(findOder);
                                                                                  }
                                                                                : null,
                                                                            child:
                                                                                Container(
                                                                              width: (MediaQuery.of(context).size.width / 10) * 3,
                                                                              child: Text(
                                                                                sortList[i]['order'].orderName,
                                                                                style: textButtonTable,
                                                                                maxLines: 3,
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),

                                                                      ),
                                                                      DataCell(
                                                                        Container(
                                                                          child:
                                                                              Text(
                                                                            listCountTrainee[sortList[i]['order'].id] != null
                                                                                ? listCountTrainee[sortList[i]['order'].id].toString()
                                                                                : "0",
                                                                            maxLines:
                                                                                3,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      DataCell(
                                                                          Row(
                                                                        children: [
                                                                          getRule(listRule.data, Role.Xem, context)
                                                                              ? Container(
                                                                                  margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                                  child: InkWell(
                                                                                    onTap: () {
                                                                                      navigationModel.add(pageUrl: "/xem-chi-tiet-don-hang/${sortList[i]['order'].id}");
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
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      DynamicTablePagging(
                                                          rowCount,
                                                          currentPage,
                                                          rowPerPage,
                                                          pageChangeHandler:
                                                              (currentPageCallBack) {
                                                        setState(() {
                                                          currentPage =
                                                              currentPageCallBack;
                                                        });
                                                      }, rowPerPageChangeHandler:
                                                              (rowPerPageChange) {
                                                        currentPage = 1;
                                                        rowPerPage =
                                                            rowPerPageChange;
                                                        print(rowPerPage);
                                                        setState(() {});
                                                      }),
                                                    ],
                                                  );
                                                })),
                                              ],
                                            )
                                          else if (snapshot.hasError)
                                            Text("Vui lòng tải lại trang")
                                          else if (!snapshot.hasData)
                                            Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          // End Datatable
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Footer()
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
