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

import 'modal_tts_trainees_wait.dart';

class ListTraineesWait extends StatelessWidget {
  SecurityModel? securityModel;
  ListTraineesWait({Key? key, this.securityModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
        widgetBody: ListTraineesWaitBody(
      securityModel: securityModel,
    ));
  }
}

class ListTraineesWaitBody extends StatefulWidget {
  SecurityModel? securityModel;
  ListTraineesWaitBody({Key? key, this.securityModel}) : super(key: key);

  @override
  State<ListTraineesWaitBody> createState() => _ListTraineesWaitBodyState();
}

class _ListTraineesWaitBodyState extends State<ListTraineesWaitBody> {
  bool _setLoading = false;
  var body = {};
  var page = 1;
  var rowPerPage = 10;
  var totalElements = 0;
  var firstRow = 1, lastRow = 0;
  var rowCount = 0;
  var currentPage = 1;

  late Order _order;
  late Future<List<Order>> futureListOrder;
  List<Order> listOrder = [];
  Future<List<Order>> getListOrder(page, {Order? oder}) async {
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

    String condition = "";
    if (oder != null && oder.id != -1) {
      condition += "id:${oder.id}";
      if (condition.isNotEmpty) {
        if (conditionByDepart.isNotEmpty) {
          response = await httpGet(
              "/api/donhang/get/page?page=$page&size=$rowPerPage&filter= $condition AND orderStatusId>1 AND stopProcessing:0 AND nominateStatus:1 AND $conditionByDepart", context);
        } else {
          response = await httpGet("/api/donhang/get/page?page=$page&size=$rowPerPage&filter=orderStatusId>1 AND stopProcessing:0 AND nominateStatus:1", context);
        }
      }
    } else {
      if (conditionByDepart.isNotEmpty) {
        response =
            await httpGet("/api/donhang/get/page?page=$page&size=$rowPerPage&filter=orderStatusId>1 AND stopProcessing:0 AND nominateStatus:1 AND $conditionByDepart", context);
      } else {
        response = await httpGet("/api/donhang/get/page?page=$page&size=$rowPerPage&filter=orderStatusId>1 AND stopProcessing:0 AND nominateStatus:1", context);
      }
    }

    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
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
    }
    return content.map((e) {
      return Order.fromJson(e);
    }).toList();
  }

  Future<List<Order>> getListOrderSearchBy(context) async {
    var response;

    response = await httpGet("/api/donhang/get/page?filter=orderStatusId:2 and stopProcessing:0 and nominateStatus:1", context);
    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      content = body['content'];
    }
    Order order = new Order(id: -1, union: null, enterprise: null, jobs: null, orderCode: "", orderName: "Tất cả", orderStatusId: -1);
    List<Order> list = content.map((e) {
      return Order.fromJson(e);
    }).toList();

    list.insert(0, order);
    return list;
  }

  @override
  void initState() {
    super.initState();
    futureListOrder = getListOrder(page - 1);
  }

  handleClickBtnSearch({Order? order}) {
    setState(() {
      _setLoading = true;
    });

    Future<List<Order>> _future = getListOrder(0, oder: order);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        futureListOrder = _future;
        _setLoading = false;
      });
    });
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
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: userRule('/danh-sach-tts-cho-thi-tuyen-pttt', context),
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
                              {'url': '/phat-trien-thi-truong', 'title': 'Dashboard'},
                              {'url': '/danh-sach-tts-cho-thi-tuyen-pttt', 'title': 'Danh sách TTS chờ thi tuyển'}
                            ],
                            content: 'Danh sách TTS chờ thi tuyển',
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
                                            height: 50,
                                            child: DropdownSearch<Order>(
                                              mode: Mode.MENU,
                                              showSearchBox: true,
                                              onFind: (String? filter) => getListOrderSearchBy(context),
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
                                                  _order = value!;
                                                  print(_order);
                                                });
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
                                              onPressed: () async {
                                                setState(() {});
                                                await handleClickBtnSearch(order: _order);
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
                                    Container(
                                      margin: marginTopBottomHorizontalLine,
                                      child: Divider(
                                        thickness: 1,
                                        color: ColorHorizontalLine,
                                      ),
                                    ),
                                    if (snapshot.hasData)
                                      !_setLoading
                                          ? Row(
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
                                                                columnSpacing: 20,
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
                                                                      'Mã đơn hàng',
                                                                      style: titleTableData,
                                                                    ),
                                                                  ),
                                                                  DataColumn(
                                                                    label: Text(
                                                                      'Tên đơn hàng',
                                                                      style: titleTableData,
                                                                    ),
                                                                  ),
                                                                  DataColumn(
                                                                    label: Text(
                                                                      'Tên nghiệp đoàn',
                                                                      style: titleTableData,
                                                                    ),
                                                                  ),
                                                                  DataColumn(
                                                                    label: Text(
                                                                      'Tên xí nghiệp',
                                                                      style: titleTableData,
                                                                    ),
                                                                  ),
                                                                  DataColumn(
                                                                    label: Text(
                                                                      'Tên công ty',
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
                                                                            child: Text("${(currentPage - 1) * rowPerPage + i + 1}"),
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
                                                                                            return ModalDanhSachTTSChoThiTuyen(
                                                                                              idOreder: listOrder[i].id,
                                                                                              order: listOrder[i],
                                                                                            );
                                                                                          });
                                                                                    }
                                                                                  : null,
                                                                              child: Container(
                                                                                width: (MediaQuery.of(context).size.width / 10) * 0.8,
                                                                                child: Text(
                                                                                  listOrder[i].orderCode,
                                                                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.blue),
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
                                                                                            return ModalDanhSachTTSChoThiTuyen(
                                                                                              idOreder: listOrder[i].id,
                                                                                              order: listOrder[i],
                                                                                            );
                                                                                          });
                                                                                    }
                                                                                  : null,
                                                                              child: Container(
                                                                                width: (MediaQuery.of(context).size.width / 10) * 0.8,
                                                                                child: Text(
                                                                                  listOrder[i].orderName,
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
                                                                                            return ModalDanhSachTTSChoThiTuyen(
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
                                                                                            return ModalDanhSachTTSChoThiTuyen(
                                                                                              idOreder: listOrder[i].id,
                                                                                              order: listOrder[i],
                                                                                            );
                                                                                          });
                                                                                    }
                                                                                  : null,
                                                                              child: Container(
                                                                                width: (MediaQuery.of(context).size.width / 10) * 0.8,
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
                                                                                            return ModalDanhSachTTSChoThiTuyen(
                                                                                              idOreder: listOrder[i].id,
                                                                                              order: listOrder[i],
                                                                                            );
                                                                                          });
                                                                                    }
                                                                                  : null,
                                                                              child: Container(
                                                                                width: (MediaQuery.of(context).size.width / 10) * 0.8,
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
                                                                    ),
                                                                ],
                                                              ))));
                                                })),
                                              ],
                                            )
                                          : Center(
                                              child: CircularProgressIndicator(),
                                            )
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
                                        currentPage,
                                        rowPerPage,
                                        pageChangeHandler: (page) {
                                          setState(() {
                                            getListOrder(
                                              page - 1,
                                            );
                                          });
                                        },
                                        rowPerPageChangeHandler: (rowPerPage) {
                                          setState(() {
                                            this.rowPerPage = rowPerPage!;
                                            //coding
                                            this.firstRow = page * currentPage;
                                            getListOrder(
                                              page - 1,
                                            );
                                          });
                                        },
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
                    ),
                  );
                });
          } else if (listRule.hasError) {
            return Text('${listRule.error}');
          }
          return Center(child: CircularProgressIndicator());
        });
  }
}
