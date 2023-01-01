import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../api.dart';
import '../../../common/dynamic_table.dart';
import '../../../common/style.dart';
// ignore: unused_import
import '../../../common/toast.dart';
import '../../../common/widgets_form.dart';

// import '../../../model/type.dart';
import '../../../model/model.dart';
import '../navigation.dart';

class XacNhanTinhThuongCtv extends StatefulWidget {
  const XacNhanTinhThuongCtv({Key? key}) : super(key: key);

  @override
  _XacNhanTinhThuongCtvState createState() => _XacNhanTinhThuongCtvState();
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _XacNhanTinhThuongCtvState extends State<XacNhanTinhThuongCtv> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: XacNhanTinhThuongCtvBody());
  }
}

class XacNhanTinhThuongCtvBody extends StatefulWidget {
  const XacNhanTinhThuongCtvBody({Key? key}) : super(key: key);
  @override
  State<XacNhanTinhThuongCtvBody> createState() =>
      _XacNhanTinhThuongCtvBodyState();
}

class _XacNhanTinhThuongCtvBodyState extends State<XacNhanTinhThuongCtvBody> {
  var listDntt;
  late Future<dynamic> getListDnttFuture;
  late int rowCount = 0;
  int currentPageDef = 1;
  int rowPerPage = 10;
  getListDntt(curentPage) async {
    var response = await httpGet(
        "/api/ctv-denghi-thanhtoan/get/page?sort=createdDate,desc&size=$rowPerPage&page=${curentPage - 1}",
        context);
    if (response.containsKey("body")) {
      setState(() {
        listDntt = jsonDecode(response["body"])['content'];
        rowCount = jsonDecode(response["body"])['totalElements'];
      });
      return listDntt;
    } else
      throw Exception('False to load data');
  }

  @override
  // ignore: must_call_super
  void initState() {
    getListDnttFuture = getListDntt(1);
  }

  @override
  Widget build(BuildContext context) {
    var curentUser =
        Provider.of<SecurityModel>(context, listen: false).userLoginCurren;
    return FutureBuilder<dynamic>(
      future: userRule('/xac-nhan-thuong-ctv', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return FutureBuilder<dynamic>(
            future: getListDnttFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var tableIndex = (currentPageDef - 1) * rowPerPage + 1;

                // ignore: unused_local_variable
                final double width = MediaQuery.of(context).size.width;

                // var tableIndex = (currentPageDef - 1) * rowPerPage + 1;
                return ListView(
                  children: [
                    TitlePage(
                      listPreTitle: [
                        {'url': '/ke-toan', 'title': 'Dashboard'},
                      ],
                      content: 'Xác nhận tính thưởng cộng tác viên',
                    ),

                    Container(
                      color: backgroundPage,
                      padding: EdgeInsets.symmetric(
                          vertical: verticalPaddingPage,
                          horizontal: horizontalPaddingPage),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 1,
                        // margin: marginTopBoxContainer,
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
                              children: [
                                Expanded(
                                    child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SelectableText(
                                          'Danh sách đề nghị tính thưởng cộng tác viên',
                                          style: titleBox,
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
                                      children: [
                                        Expanded(
                                          child: DataTable(
                                            columnSpacing:
                                                MediaQuery.of(context)
                                                            .size
                                                            .width <
                                                        1600
                                                    ? 10
                                                    : 20,
                                            showCheckboxColumn: false,
                                            columns: [
                                              DataColumn(
                                                  label: SelectableText('STT',
                                                      style: titleTableData)),
                                              DataColumn(
                                                  label: SelectableText(
                                                      'Mã đề nghị',
                                                      style: titleTableData)),
                                              DataColumn(
                                                  label: SelectableText(
                                                      'Tiêu đề',
                                                      style: titleTableData)),
                                              DataColumn(
                                                  label: SelectableText(
                                                      'Trạng thái thanh toán',
                                                      style: titleTableData)),
                                              DataColumn(
                                                  label: SelectableText(
                                                      'Ngày thanh toán',
                                                      style: titleTableData)),
                                              if (curentUser['departId'] == 1 ||
                                                  curentUser['departId'] == 2)
                                                DataColumn(
                                                    label: SelectableText(
                                                        'Phê duyệt',
                                                        style: titleTableData))
                                            ],
                                            rows: <DataRow>[
                                              for (var row in listDntt)
                                                DataRow(
                                                  // selected:
                                                  //     _listDataTableXacNhanThanhToan[i]
                                                  //         .selected,
                                                  // onSelectChanged: (value) {
                                                  //   setState(() {
                                                  //     _listDataTableXacNhanThanhToan[i]
                                                  //         .selected = value!;
                                                  //   });
                                                  // },
                                                  cells: <DataCell>[
                                                    DataCell(SelectableText(
                                                        "${tableIndex++}")),
                                                    DataCell(TextButton(
                                                        onPressed: () {
                                                          showDialog(
                                                              context: context,
                                                              builder: (BuildContext
                                                                      context) =>
                                                                  ThanhToan(
                                                                      row: row,
                                                                      function:
                                                                          () {
                                                                        getListDnttFuture =
                                                                            getListDntt(currentPageDef);
                                                                      }));
                                                        },
                                                        child: Row(
                                                          children: [
                                                            row['approve'] == 0
                                                                ? Tooltip(
                                                                    message:
                                                                        "Đề nghị đang chờ duyệt",
                                                                    child: Icon(
                                                                      Icons
                                                                          .report,
                                                                      color: Colors
                                                                          .amber,
                                                                    ),
                                                                  )
                                                                : row['approve'] ==
                                                                        1
                                                                    ? Container()
                                                                    : Tooltip(
                                                                        message:
                                                                            "Đề nghị đã bị từ chối",
                                                                        child: Icon(
                                                                            Icons
                                                                                .warning,
                                                                            color:
                                                                                Colors.red),
                                                                      ),
                                                            Text(row['code']),
                                                          ],
                                                        ))),
                                                    DataCell(
                                                      SelectableText(
                                                          row['title'],
                                                          style: bangDuLieu),
                                                    ),
                                                    DataCell(
                                                      SelectableText(
                                                          row['paidStatus'] == 0
                                                              ? "Chưa thanh toán"
                                                              : "Đã thanh toán",
                                                          style: bangDuLieu),
                                                    ),
                                                    DataCell(
                                                      SelectableText(
                                                          row['paidDate'] ==
                                                                  null
                                                              ? ''
                                                              : dateReverse(
                                                                  displayDateTimeStamp(
                                                                      row['paidDate'])),
                                                          style: bangDuLieu),
                                                    ),
                                                    if (curentUser[
                                                                'departId'] ==
                                                            1 ||
                                                        curentUser[
                                                                'departId'] ==
                                                            2)
                                                      DataCell(Container(
                                                        child: Row(
                                                          children: [
                                                            row['approve'] == 0
                                                                ? Container(
                                                                    child:
                                                                        TextButton(
                                                                      style: TextButton
                                                                          .styleFrom(
                                                                        padding:
                                                                            const EdgeInsets.symmetric(
                                                                          vertical:
                                                                              20.0,
                                                                          horizontal:
                                                                              10.0,
                                                                        ),
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(5.0),
                                                                        ),
                                                                        backgroundColor: Color.fromRGBO(
                                                                            245,
                                                                            117,
                                                                            29,
                                                                            1),
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
                                                                      onPressed:
                                                                          () {
                                                                        showDialog(
                                                                            context:
                                                                                context,
                                                                            builder: (BuildContext context) => ThanhToan(
                                                                                pheDuyet: true,
                                                                                row: row,
                                                                                function: () {
                                                                                  getListDnttFuture = getListDntt(currentPageDef);
                                                                                }));
                                                                      },
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Text(
                                                                              'Phê duyệt',
                                                                              style: textButton),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  )
                                                                : row['approve'] ==
                                                                        1
                                                                    ? Text(
                                                                        'Đã phê duyệt')
                                                                    : Text(
                                                                        "Đã từ chối"),
                                                          ],
                                                        ),
                                                      )),
                                                    //
                                                  ],
                                                )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    DynamicTablePagging(
                                        rowCount, currentPageDef, rowPerPage,
                                        pageChangeHandler: (currentPage) {
                                      getListDnttFuture =
                                          getListDntt(currentPage);
                                      currentPageDef = currentPage;
                                      setState(() {});
                                    }, rowPerPageChangeHandler:
                                            (rowPerPageChange) {
                                      rowPerPage = rowPerPageChange;
                                      getListDnttFuture =
                                          getListDntt(currentPageDef);
                                      setState(() {});
                                    }),
                                  ],
                                )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Footer()
                    //
                  ],
                );
              } else if (snapshot.hasError) {
                return SelectableText('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return const Center(child: CircularProgressIndicator());
            },
          );
        } else if (listRule.hasError) {
          return SelectableText('${listRule.error}');
        }

        // By default, show a loading spinner.
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

// Pop-up xác nhận thu tiên
class ThanhToan extends StatefulWidget {
  final bool? pheDuyet;
  final dynamic row;
  final Function function;
  const ThanhToan(
      {Key? key, required this.row, required this.function, this.pheDuyet})
      : super(key: key);

  @override
  State<ThanhToan> createState() => _ThanhToanState();
}

class _ThanhToanState extends State<ThanhToan> {
  var listCtv;
  late int rowCount = 0;
  int currentPageDef = 1;
  int rowPerPage = 5;
  late Future<dynamic> getHistoryPayFuture;
  var listTtsGt;
  getHistoryPay(curentPage) async {
    var response = await httpGet(
        "/api/ctv-lichsu-thanhtoan/get/page?size=$rowPerPage&page=${curentPage - 1}&filter=denghiId:${widget.row['id']}",
        context);
    var getListTts = await httpGet(
        "/api/ctv-lichsu-gioithieu/get/page?filter=denghiId:${widget.row['id']}",
        context);
    if (getListTts.containsKey("body")) {
      setState(() {
        listTtsGt = jsonDecode(getListTts["body"])['content'];
      });
    }
    if (response.containsKey("body")) {
      setState(() {
        listCtv = jsonDecode(response["body"])['content'];
        rowCount = jsonDecode(response["body"])['totalElements'];
      });
      return listCtv;
    } else
      throw Exception('False to load data');
  }

  pheDuyet(approve) async {
    data['approve'] = approve;
    data['approver'] = Provider.of<SecurityModel>(context, listen: false)
        .userLoginCurren['id'];
    var response = await httpPut(
        '/api/ctv-denghi-thanhtoan/put/${data['id']}', data, context);
    if (response['body'] == 'true') {
      showToast(
        context: context,
        msg: approve == 1
            ? 'Phê duyệt thành công'
            : "Từ chối đề nghị thành công, vui lòng thử lại",
        color: Color.fromARGB(136, 72, 238, 67),
        icon: Icon(Icons.done),
      );
    } else {
      showToast(
        context: context,
        msg: approve == 1
            ? 'Phê duyệt thất bại'
            : "Từ chối đề nghị thất bại, vui lòng thử lại",
        color: Colors.red,
        icon: Icon(Icons.warning),
      );
    }
  }

  xacNhanThanhToan() async {
    data['paidStatus'] = 1;
    data['paidDate'] = DateFormat("yyyy-MM-ddThh:mm:ss").format(DateTime.now());
    var response = await httpPut(
        '/api/ctv-denghi-thanhtoan/put/${data['id']}', data, context);
    if (response['body'] == 'true') {
      for (var row in listTtsGt) {
        row['rewarded'] = 1;
        await httpPut(
            "/api/ctv-lichsu-gioithieu/put/${row['id']}", row, context);
      }
      showToast(
        context: context,
        msg: 'Xác nhận thưởng thành công',
        color: Color.fromARGB(136, 72, 238, 67),
        icon: Icon(Icons.done),
      );
    } else {
      showToast(
        context: context,
        msg: 'Xác nhận thưởng thất bại',
        color: Colors.red,
        icon: Icon(Icons.warning),
      );
    }
  }

  var data;
  @override
  void initState() {
    data = widget.row;
    getHistoryPayFuture = getHistoryPay(1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var tableIndex = (currentPageDef - 1) * rowPerPage + 1;

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  child: Image.asset('images/logoAAM.png'),
                  margin: EdgeInsets.only(right: 10),
                ),
                SelectableText(
                  "Xác nhận thanh toán thưởng cộng tác viên",
                  style: titleAlertDialog,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close),
          ),
        ],
      ),
      content: Container(
        width: 1000,
        height: 500,
        child: ListView(
          children: [
            Container(
              margin: marginTopBottomHorizontalLine,
              child: Divider(
                thickness: 1,
                color: ColorHorizontalLine,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SelectableText(
                  'Danh sách cộng tác viên được tính thưởng',
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
                Expanded(
                    child: FutureBuilder<dynamic>(
                  future: getHistoryPayFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return DataTable(
                        showCheckboxColumn: false,
                        columnSpacing: 20,
                        horizontalMargin: 10,
                        dataRowHeight: 40,
                        columns: [
                          DataColumn(
                              label:
                                  SelectableText('STT', style: titleTableData)),
                          DataColumn(
                              label: SelectableText('Mã CTV',
                                  style: titleTableData)),
                          DataColumn(
                              label: SelectableText('Họ tên',
                                  style: titleTableData)),
                          DataColumn(
                              label: SelectableText('Ngày thanh toán',
                                  style: titleTableData)),
                          DataColumn(
                              label: SelectableText('Tổng số thực tập sinh',
                                  style: titleTableData)),
                          DataColumn(
                              label: SelectableText('Thưởng KM',
                                  style: titleTableData)),
                          DataColumn(
                              label: SelectableText('Tổng tiền',
                                  style: titleTableData)),
                        ],
                        rows: <DataRow>[
                          for (var row in listCtv)
                            DataRow(cells: <DataCell>[
                              DataCell(SelectableText("${tableIndex++}")),
                              DataCell(SelectableText(
                                  row['congtacvien']['userCode'])),
                              DataCell(SelectableText(
                                  row['congtacvien']['fullName'])),
                              DataCell(SelectableText(dateReverse(
                                  displayDateTimeStamp(row['payDate'])))),
                              DataCell(SelectableText(
                                  row['ttsFlightTotal'].toString())),
                              DataCell(SelectableText(
                                  row['promotTotal'].toString())),
                              DataCell(SelectableText(
                                  "${moneyFormatter(row['totalAmount'])} ")),
                            ])
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return SelectableText('${snapshot.error}');
                    }

                    // By default, show a loading spinner.
                    return Center(child: const CircularProgressIndicator());
                  },
                )),
              ],
            ),
            DynamicTablePagging(rowCount, currentPageDef, rowPerPage,
                pageChangeHandler: (currentPage) {
              getHistoryPayFuture = getHistoryPay(currentPage);
              currentPageDef = currentPage;
              setState(() {});
            }, rowPerPageChangeHandler: (rowPerPageChange) {
              rowPerPage = rowPerPageChange;
              getHistoryPayFuture = getHistoryPay(currentPageDef);
              setState(() {});
            }),
            Container(
              margin: marginTopBottomHorizontalLine,
              child: Divider(
                thickness: 1,
                color: ColorHorizontalLine,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      SelectableText(
                        "Ngày thanh toán: ",
                        style: titleWidgetBox,
                      ),
                      SelectableText(
                          '${widget.row['paidDate'] == null ? '' : dateReverse(displayDateTimeStamp(widget.row['paidDate']))}')
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SelectableText(
                        "Tổng tiền: ",
                        style: titleWidgetBox,
                      ),
                      SelectableText(
                          '${moneyFormatter(widget.row['totalAmount'])} ')
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              margin: EdgeInsets.only(left: 20),
              child: ElevatedButton(
                // textColor: Color(0xFF6200EE),
                onPressed: () => Navigator.pop(context),
                child: Text(
                    widget.row['paidStatus'] == 0 && widget.row['approve'] == 1
                        ? 'Hủy'
                        : 'Đóng'),
                style: ElevatedButton.styleFrom(
                  primary: colorOrange,
                  onPrimary: colorWhite,
                  // shadowColor: Colors.greenAccent,
                  elevation: 3,
                  // shape: Border.all(width: 1,color: Colors.red);
                  // side: BorderSide(
                  //   width: 1,
                  //   color: Colors.black87,
                  // ),
                  minimumSize: Size(140, 50),
                  // maximumSize: Size(140, 50), //////// HERE
                ),
              ),
            ),
            widget.pheDuyet == true
                ? Container(
                    margin: EdgeInsets.only(left: 20),
                    child: ElevatedButton(
                      // textColor: Color(0xFF6200EE),
                      onPressed: () async {
                        await pheDuyet(2);
                        widget.function();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Từ chối',
                        style: TextStyle(),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: colorOrange,
                        onPrimary: colorWhite,
                        // shadowColor: Colors.greenAccent,
                        elevation: 3,
                        // shape: Border.all(width: 1,color: Colors.red);
                        // side: BorderSide(
                        //   width: 1,
                        //   color: Colors.black87,
                        // ),
                        minimumSize: Size(140, 50),
                        // maximumSize: Size(140, 50), //////// HERE
                      ),
                    ),
                  )
                : Container(),
            widget.pheDuyet == true
                ? Container(
                    margin: EdgeInsets.only(left: 20),
                    child: ElevatedButton(
                      // textColor: Color(0xFF6200EE),
                      onPressed: () async {
                        await pheDuyet(1);
                        widget.function();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Phê duyệt',
                        style: TextStyle(),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: colorBlueBtnDialog,
                        onPrimary: colorWhite,
                        // shadowColor: Colors.greenAccent,
                        elevation: 3,
                        // shape: RoundedRectangleBorder(
                        //     borderRadius: BorderRadius.circular(32.0)),
                        minimumSize: Size(140, 50), //////// HERE
                      ),
                    ),
                  )
                : Container(),
            widget.row['paidStatus'] == 0 &&
                    widget.row['approve'] == 1 &&
                    widget.pheDuyet != true
                ? Container(
                    margin: EdgeInsets.only(left: 20),
                    child: ElevatedButton(
                      // textColor: Color(0xFF6200EE),
                      onPressed: () async {
                        await xacNhanThanhToan();
                        widget.function();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Xác nhận',
                        style: TextStyle(),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: colorBlueBtnDialog,
                        onPrimary: colorWhite,
                        // shadowColor: Colors.greenAccent,
                        elevation: 3,
                        // shape: RoundedRectangleBorder(
                        //     borderRadius: BorderRadius.circular(32.0)),
                        minimumSize: Size(140, 50), //////// HERE
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ],
    );
  }
}
