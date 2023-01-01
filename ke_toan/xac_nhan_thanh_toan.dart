import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../api.dart';
import '../../../common/dynamic_table.dart';
import '../../../common/style.dart';
import '../../../common/toast.dart';
import '../../../common/widgets_form.dart';

import '../navigation.dart';

class XacNhanThanhToan extends StatefulWidget {
  const XacNhanThanhToan({Key? key}) : super(key: key);

  @override
  _XacNhanThanhToanState createState() => _XacNhanThanhToanState();
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _XacNhanThanhToanState extends State<XacNhanThanhToan> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: XacNhanThanhToanBody());
  }
}

enum TypePay { TinhChiTieu, ThuongNguon, TatCa }

enum Status { DaThanhToan, ChuaThanhToan, TatCa, Huy }

class XacNhanThanhToanBody extends StatefulWidget {
  const XacNhanThanhToanBody({Key? key}) : super(key: key);
  @override
  State<XacNhanThanhToanBody> createState() => _XacNhanThanhToanBodyState();
}

class _XacNhanThanhToanBodyState extends State<XacNhanThanhToanBody> {
  String? dateFrom;
  String? dateTo;
  TypePay typePay = TypePay.TatCa;
  Status status = Status.TatCa;
  late int rowCount = 0;
  int currentPageDef = 1;
  int rowPerPage = 10;
  var listData;
  String? requestPayStatus;
  late Future<dynamic> getListPaymentsFuture;
  getListPayments(currentPage) async {
    requestPayStatus = '';
    if (typePay == TypePay.TatCa) {
      if (status == Status.DaThanhToan) {
        requestPayStatus =
            "and (paidStatus:1 and bonusType:2) or (acctApprove:1 and bonusType:1)";
      } else if (status == Status.ChuaThanhToan) {
        requestPayStatus =
            "and (paidStatus:0 and bonusType:2) or (acctApprove:0 and bonusType:1)";
      } else if (status == Status.Huy) {
        requestPayStatus =
            "and (paidStatus:2 and bonusType:2) or (acctApprove:2 and bonusType:1)";
      }
    } else {
      if (typePay == TypePay.ThuongNguon) {
        if (status == Status.DaThanhToan) {
          requestPayStatus = "and paidStatus:1";
        } else if (status == Status.ChuaThanhToan) {
          requestPayStatus = "and paidStatus:0";
        } else if (status == Status.Huy) {
          requestPayStatus = "and paidStatus:2";
        }
      } else if (typePay == TypePay.TinhChiTieu) {
        if (status == Status.DaThanhToan) {
          requestPayStatus = "and acctApprove:1";
        } else if (status == Status.ChuaThanhToan) {
          requestPayStatus = "and acctApprove:0";
        } else if (status == Status.Huy) {
          requestPayStatus = "and acctApprove:2";
        }
      }
    }
    String query = '';
    if (dateFrom != null && dateTo == null) {
      query += " createdDate>:'$dateFrom'";
    } else if (dateFrom == null && dateTo != null) {
      query += " createdDate<:'$dateTo'";
    } else if (dateFrom != null && dateTo != null) {
      query += " createdDate>:'$dateFrom' and createdDate<:'$dateTo'";
    }
    var response = {};
    if (typePay == TypePay.TatCa) {
      if (requestPayStatus != '' && query != '') {
        query = "and $query";
      }
      response = await httpGet(
          "/api/thuong-chitieu-denghi/get/page?size=$rowPerPage&page=${currentPage - 1}&filter=bonusType in (1,2) $requestPayStatus $query",
          context);
    } else if (typePay == TypePay.TinhChiTieu) {
      if (query != '') query = "and $query";
      response = await httpGet(
          "/api/thuong-chitieu-denghi/get/page?size=$rowPerPage&page=${currentPage - 1}&filter=bonusType:1 $requestPayStatus $query",
          context);
    } else if (typePay == TypePay.ThuongNguon) {
      if (query != '') query = "and $query";
      response = await httpGet(
          "/api/thuong-chitieu-denghi/get/page?size=$rowPerPage&page=${currentPage - 1}&filter=bonusType:2 $requestPayStatus $query",
          context);
    }
    if (response.containsKey("body")) {
      setState(() {
        listData = jsonDecode(response["body"])['content'];
        rowCount = jsonDecode(response["body"])['totalElements'];
      });
    }
    return 0;
  }

  @override
  // ignore: must_call_super
  void initState() {
    getListPaymentsFuture = getListPayments(1);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        TitlePage(
          listPreTitle: [
            {'url': '/ke-toan', 'title': 'Dashboard'},
          ],
          content: 'Xác nhận thanh toán tài chính tuyển dụng',
        ),
        Container(
          padding: EdgeInsets.symmetric(
              vertical: verticalPaddingPage, horizontal: horizontalPaddingPage),
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
                        SelectableText(
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
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.start,
                    //   children: [
                    //     Expanded(
                    //       flex: 3,
                    //       child: Container(
                    //         margin: EdgeInsets.only(bottom: 30),
                    //         child: DropDownButtonWidget(
                    //           labelDropDown: SelectableText('Kiểu trả lương:',
                    //               style: titleWidgetBox),
                    //           listOption: title,
                    //           functionDropDown: (value) {},
                    //           selectedValues: 'Chọn một kiểu',
                    //         ),
                    //       ),
                    //     ),
                    //     SizedBox(width: 100),
                    //     Expanded(
                    //       flex: 3,
                    //       child: Container(
                    //         margin: EdgeInsets.only(bottom: 30),
                    //         child: DropDownButtonWidget(
                    //           labelDropDown: SelectableText('Trạng thái thanh toán:',
                    //               style: titleWidgetBox),
                    //           listOption: trangThai,
                    //           functionDropDown: (value) {},
                    //           selectedValues: 'Chọn một trạng thái',
                    //         ),
                    //       ),
                    //     ),
                    //     Expanded(flex: 2, child: Container()),
                    //   ],
                    // ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: DatePickerBoxVQ(
                              requestDayBefore: dateTo,
                              isTime: false,
                              label: SelectableText(
                                'Từ ngày',
                                style: titleWidgetBox,
                              ),
                              dateDisplay: dateFrom,
                              selectedDateFunction: (day) {
                                dateFrom = day;
                                setState(() {});
                              }),
                        ),
                        SizedBox(width: 100),
                        Expanded(
                          flex: 3,
                          child: DatePickerBoxVQ(
                              requestDayAfter: dateFrom,
                              isTime: false,
                              label: SelectableText(
                                'Đến ngày',
                                style: titleWidgetBox,
                              ),
                              dateDisplay: dateFrom,
                              selectedDateFunction: (day) {
                                dateTo = day;
                                setState(() {});
                              }),
                        ),
                        Expanded(
                          flex: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              //tìm kiếm
                              Container(
                                margin: EdgeInsets.only(left: 20),
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20.0,
                                      horizontal: 10.0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    backgroundColor:
                                        Color.fromRGBO(245, 117, 29, 1),
                                    primary: Theme.of(context).iconTheme.color,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .caption
                                        ?.copyWith(
                                            fontSize: 10.0, letterSpacing: 2.0),
                                  ),
                                  onPressed: () {
                                    getListPaymentsFuture = getListPayments(1);
                                  },
                                  child: Row(
                                    children: [
                                      Row(
                                        children: [
                                          Transform.rotate(
                                            angle: 270,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 5, right: 5),
                                              child: Icon(
                                                Icons.search,
                                                color: Colors.white,
                                                size: 15,
                                              ),
                                            ),
                                          ),
                                          Text('Tìm kiếm', style: textButton),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                color: backgroundPage,
                // padding: EdgeInsets.symmetric(
                //     vertical: verticalPaddingPage,
                //     horizontal: horizontalPaddingPage),
                padding: EdgeInsets.fromLTRB(25, 25, 0, 25),
                child: Container(
                  // margin: marginTopBoxContainer,
                  width: MediaQuery.of(context).size.width * 1,
                  decoration: BoxDecoration(
                    color: colorWhite,
                    borderRadius: borderRadiusContainer,
                    boxShadow: [boxShadowContainer],
                    border: borderAllContainerBox,
                  ),
                  padding: paddingBoxContainer,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 25),
                              child: SelectableText(
                                'Loại đề nghị',
                                textAlign: TextAlign.center,
                                style: titleTableData,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            RadioListTile<TypePay>(
                              title: const SelectableText('Tất cả'),
                              value: TypePay.TatCa,
                              groupValue: typePay,
                              onChanged: (TypePay? value) {
                                setState(() {
                                  typePay = value!;
                                });
                                getListPaymentsFuture = getListPayments(1);

                                // futureListTrainee = pageChange(0);
                              },
                            ),
                            RadioListTile<TypePay>(
                              title:
                                  const SelectableText('Chỉ tiêu tuyển dụng'),
                              value: TypePay.TinhChiTieu,
                              groupValue: typePay,
                              onChanged: (TypePay? value) {
                                setState(() {
                                  typePay = value!;
                                });
                                // futureListTrainee = pageChange(0);
                                getListPaymentsFuture = getListPayments(1);
                              },
                            ),
                            RadioListTile<TypePay>(
                              title: const SelectableText('Thưởng nóng'),
                              value: TypePay.ThuongNguon,
                              groupValue: typePay,
                              onChanged: (TypePay? value) {
                                setState(() {
                                  typePay = value!;
                                });
                                // futureListTrainee = pageChange(0);
                                getListPaymentsFuture = getListPayments(1);
                              },
                            ),

                            SizedBox(
                              height: 25,
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 25),
                              child: SelectableText(
                                'Trạng thái',
                                textAlign: TextAlign.center,
                                style: titleTableData,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            // RadioListTile<TypePay(
                            //   title: const SelectableText('Tất cả'),
                            //   value: TypePay.TinhChiTieu,
                            //   groupValue: typePay,
                            //   onChanged: (TypePay? value) {
                            //     setState(() {
                            //       typePay = value!;
                            //     });
                            //     // futureListTrainee = pageChange(0);
                            //   },
                            // ),
                            RadioListTile<Status>(
                              title: const SelectableText('Tất cả'),
                              value: Status.TatCa,
                              groupValue: status,
                              onChanged: (Status? value) {
                                setState(() {
                                  status = value!;
                                });
                                getListPaymentsFuture = getListPayments(1);
                              },
                            ),
                            RadioListTile<Status>(
                              title: const SelectableText('Đã duyệt'),
                              value: Status.DaThanhToan,
                              groupValue: status,
                              onChanged: (Status? value) {
                                setState(() {
                                  status = value!;
                                });
                                getListPaymentsFuture = getListPayments(1);

                                // futureListTrainee = pageChange(0);
                              },
                            ),
                            RadioListTile<Status>(
                              title: const SelectableText('Chưa duyệt'),
                              value: Status.ChuaThanhToan,
                              groupValue: status,
                              onChanged: (Status? value) {
                                setState(() {
                                  status = value!;
                                });
                                getListPaymentsFuture = getListPayments(1);

                                // futureListTrainee = pageChange(0);
                              },
                            ),
                            RadioListTile<Status>(
                              title: const SelectableText('Đã từ chối'),
                              value: Status.Huy,
                              groupValue: status,
                              onChanged: (Status? value) {
                                setState(() {
                                  status = value!;
                                });
                                getListPaymentsFuture = getListPayments(1);

                                // futureListTrainee = pageChange(0);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 8,
              child: Container(
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
                        // flex: 8,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SelectableText(
                                  'Thông tin thanh toán',
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
                            FutureBuilder<dynamic>(
                              future: getListPaymentsFuture,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  var tableIndex =
                                      (currentPageDef - 1) * rowPerPage + 1;
                                  return Column(
                                    children: [
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
                                                        'Mã danh sách',
                                                        style: titleTableData)),
                                                DataColumn(
                                                    label: SelectableText(
                                                        'Loại đề nghị',
                                                        style: titleTableData)),
                                                DataColumn(
                                                    label: SelectableText(
                                                        'Đơn hàng',
                                                        style: titleTableData)),
                                                DataColumn(
                                                    label: SelectableText(
                                                        'Trạng thái',
                                                        style: titleTableData)),
                                                DataColumn(
                                                    label: SelectableText(
                                                        'Ngày xác nhận',
                                                        style: titleTableData)),
                                              ],
                                              rows: <DataRow>[
                                                for (var row in listData)
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
                                                      DataCell(Row(
                                                        children: [
                                                          row['bonusType'] ==
                                                                      2 &&
                                                                  row['donhang']
                                                                          [
                                                                          'stopProcessing'] ==
                                                                      1
                                                              ? Tooltip(
                                                                  message:
                                                                      'Đơn hàng đang trong trạng thái dừng xử lý',
                                                                  child: Icon(
                                                                    Icons
                                                                        .warning,
                                                                    color: Colors
                                                                        .red,
                                                                  ),
                                                                )
                                                              : Container(),
                                                          TextButton(
                                                              onPressed: row['bonusType'] ==
                                                                          2 &&
                                                                      row['donhang']
                                                                              [
                                                                              'stopProcessing'] ==
                                                                          1
                                                                  ? () {
                                                                      showToast(
                                                                          context:
                                                                              context,
                                                                          msg:
                                                                              'Đơn hàng đang trong trạng thái dừng xử lý',
                                                                          color: Colors
                                                                              .red,
                                                                          icon:
                                                                              const Icon(Icons.warning));
                                                                    }
                                                                  : () {
                                                                      showDialog(
                                                                        context:
                                                                            context,
                                                                        builder: (BuildContext context) => ShowDialogThuong(
                                                                            row: row,
                                                                            function: () {
                                                                              getListPayments(currentPageDef);
                                                                            },
                                                                            titleDialog: 'Danh sách TTS'),
                                                                      );
                                                                    },
                                                              child: Text(
                                                                row['code'],
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                              )),
                                                        ],
                                                      )),

                                                      DataCell(
                                                        SelectableText(
                                                            row['bonusType'] ==
                                                                    1
                                                                ? 'Chỉ tiêu tuyển dụng'
                                                                : 'Thưởng nóng',
                                                            style: bangDuLieu),
                                                      ),
                                                      DataCell(
                                                        SelectableText(
                                                            row['bonusType'] ==
                                                                    2
                                                                ? row['donhang'] !=
                                                                        null
                                                                    ? row['donhang']
                                                                        [
                                                                        'orderName']
                                                                    : ''
                                                                : '',
                                                            style: bangDuLieu),
                                                      ),
                                                      DataCell(
                                                        row['bonusType'] == 2
                                                            ? SelectableText(
                                                                row['paidStatus'] ==
                                                                        0
                                                                    ? 'Chưa thanh toán'
                                                                    : row['paidStatus'] ==
                                                                            1
                                                                        ? 'Đã thanh toán'
                                                                        : 'Hủy',
                                                                style:
                                                                    bangDuLieu)
                                                            : Text(row['acctApprove'] ==
                                                                    0
                                                                ? "Chờ duyệt"
                                                                : row['acctApprove'] ==
                                                                        1
                                                                    ? "Đã duyệt"
                                                                    : "Đã từ chối"),
                                                      ),
                                                      DataCell(
                                                        SelectableText(
                                                            row['bonusType'] ==
                                                                    1
                                                                ? row['dateApprove'] ==
                                                                        null
                                                                    ? ''
                                                                    : dateReverse(
                                                                        displayDateTimeStamp(row[
                                                                            'dateApprove']))
                                                                : row['paidDate'] ==
                                                                        null
                                                                    ? ''
                                                                    : dateReverse(
                                                                        displayDateTimeStamp(
                                                                            row['paidDate'])),
                                                            style: bangDuLieu),
                                                      ),
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
                                        setState(() {
                                          getListPaymentsFuture =
                                              getListPayments(currentPage);
                                          currentPageDef = currentPage;
                                        });
                                      }, rowPerPageChangeHandler:
                                              (rowPerPageChange) {
                                        currentPageDef = 1;

                                        rowPerPage = rowPerPageChange;
                                        getListPaymentsFuture =
                                            getListPayments(currentPageDef);
                                        setState(() {});
                                      }),
                                    ],
                                  );
                                } else if (snapshot.hasError) {
                                  return SelectableText('${snapshot.error}');
                                }

                                // By default, show a loading spinner.
                                return Center(
                                    child: const CircularProgressIndicator());
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Footer()
        //
      ],
    );
  }
}

class ShowDialogThuong extends StatefulWidget {
  final String titleDialog;
  final dynamic row;
  final Function function;
  const ShowDialogThuong(
      {Key? key,
      required this.titleDialog,
      required this.row,
      required this.function})
      : super(key: key);

  @override
  State<ShowDialogThuong> createState() => _ShowDialogThuongState();
}

// ignore: camel_case_types
class _ShowDialogThuongState extends State<ShowDialogThuong> {
  var listData;
  late int rowCount = 0;
  int currentPageDef = 1;
  int rowPerPage = 10;
  late Future<dynamic> getListDataFuture;
  getListData(currentPage) async {
    String query;
    if (widget.row['bonusType'] == 2)
      query =
          "/api/thuong-donhang-denghi-chitiet/get/page?size=$rowPerPage&page=${currentPage - 1}&filter=rewardOfferId:${widget.row['id']}";
    else
      query =
          "/api/thuong-chitieu-chitiet/get/page?size=$rowPerPage&page=${currentPage - 1}&filter=rewardOfferId:${widget.row['id']}";

    var response = await httpGet(query, context);
    if (response.containsKey("body")) {
      setState(() {
        listData = jsonDecode(response["body"])['content'];
        // print(listTtsDxl.first['nguoidung']);
        rowCount = jsonDecode(response["body"])['totalElements'];
        print(rowCount);
      });
    }
    return 0;
  }

  String titleLog = "Xác nhận thưởng thành công";
  updateTctDn(paidStatus) async {
    // String dateName = "$selectedValueLTT" + 'Date';
    var realTime =
        DateFormat("yyyy-MM-ddTHH:mm:ss").format(DateTime.now().toLocal());
    if (widget.row['bonusType'] == 1) {
      widget.row["acctApprove"] = paidStatus;
      widget.row["dateApprove"] = realTime.toString();
    } else {
      widget.row["paidStatus"] = paidStatus;
      widget.row["paidDate"] = realTime.toString();
    }
    if (paidStatus == 2) {
      widget.row['orderId'] = null;
    }

    var response = await httpPut(
        '/api/thuong-chitieu-denghi/put/${widget.row['id']}',
        widget.row,
        context);
    if (response['body'] == 'true') {
      if (paidStatus == 2) {
        titleLog = 'Xác nhận hủy thành công';
      } else {}
    } else {
      titleLog = 'Xác nhận thưởng thất bại';
    }
  }

  var listTts;
  // var listId = [];
  getListTts() async {
    var response = await httpGet(
        "/api/tts-lichsu-thituyen/get/page?filter=rewardOfferId:${widget.row['id']}",
        context);
    if (response.containsKey("body")) {
      setState(() {
        listTts = jsonDecode(response["body"])['content'];
      });
    }
    return 0;
  }

  updateLstt(row) async {
    // String dateName = "$selectedValueLTT" + 'Date';
    // var data = {"rewardOfferId": null};
    row['rewardOfferId'] = null;
    var response = await httpPut(
        '/api/tts-lichsu-thituyen/put/${row['id']}', row, context);
    if (response['body'] == 'true') {
      print('Xác nhận thưởng thành công');
    } else {
      print('Xác nhận thưởng thất bại');
    }
  }

  updateOrder() async {
    // String dateName = "$selectedValueLTT" + 'Date';
    var data = {"orderBonus": 0};
    await httpPut('/api/donhang/put/${widget.row['orderId']}', data, context);
    // if (response['body'] == 'true') {
    //   print('Xác nhận thưởng thành công');
    // } else {
    //   titleLog = 'Xác nhận thưởng thất bại';
    // }
  }

  @override
  // ignore: must_call_super
  void initState() {
    getListDataFuture = getListData(1);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
              widget.row['bonusType'] == 2
                  ? 'Danh sách thưởng nóng'
                  : 'Danh sách thưởng chỉ tiêu',
              style: titleAlertDialog,
            ),
          ],
        )),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.close,
          ),
        ),
      ]),

      //content
      content: Container(
        width: 900,
        height: 450,
        child: ListView(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //đường line
                Container(
                  margin: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Divider(
                    thickness: 1,
                    color: ColorHorizontalLine,
                  ),
                ),
                widget.row['bonusType'] == 2
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Container(),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(),
                          ),
                        ],
                      )
                    : Container(),

                //table
                Container(
                  height: 400,
                  child: Row(
                    children: [
                      Expanded(
                        child: FutureBuilder<dynamic>(
                          future: getListDataFuture,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              var tableIndex =
                                  (currentPageDef - 1) * rowPerPage + 1;

                              return Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      widget.row['bonusType'] == 1
                                          ? Row(
                                              children: [
                                                Expanded(
                                                  child: DataTable(
                                                    showCheckboxColumn: false,
                                                    columns: [
                                                      DataColumn(
                                                          label: SelectableText(
                                                              'STT',
                                                              style:
                                                                  titleTableData)),
                                                      DataColumn(
                                                          label: SelectableText(
                                                              'Mã nhân viên',
                                                              style:
                                                                  titleTableData)),
                                                      DataColumn(
                                                          label: SelectableText(
                                                              'Tên nhân viên',
                                                              style:
                                                                  titleTableData)),
                                                      DataColumn(
                                                          label: SelectableText(
                                                              'Tổng số TTS',
                                                              style:
                                                                  titleTableData)),
                                                      DataColumn(
                                                          label: SelectableText(
                                                              'Tổng số lần thi tuyển',
                                                              style:
                                                                  titleTableData)),
                                                      DataColumn(
                                                          label: SelectableText(
                                                              'Tổng tiền',
                                                              style:
                                                                  titleTableData)),
                                                    ],
                                                    rows: <DataRow>[
                                                      for (var row in listData)
                                                        DataRow(
                                                          cells: <DataCell>[
                                                            DataCell(Center(
                                                                child: SelectableText(
                                                                    "${tableIndex++}"))),
                                                            DataCell(
                                                              Center(
                                                                  child: SelectableText(
                                                                      row['nhanvien']
                                                                          [
                                                                          'userCode'],
                                                                      style:
                                                                          bangDuLieu)),
                                                            ),
                                                            DataCell(
                                                              SelectableText(
                                                                  row['nhanvien']
                                                                      [
                                                                      'fullName'],
                                                                  style:
                                                                      bangDuLieu),
                                                            ),
                                                            DataCell(
                                                              Text(
                                                                  row['ttsTotal']
                                                                      .toString(),
                                                                  style:
                                                                      bangDuLieu),
                                                            ),
                                                            DataCell(
                                                              TextButton(
                                                                onPressed: () {
                                                                  showDialog(
                                                                    context:
                                                                        context,
                                                                    builder: (BuildContext
                                                                            context) =>
                                                                        DanhSachTtsThiTuyen(
                                                                            user:
                                                                                row,
                                                                            titleDialog:
                                                                                'Lịch sử thi tuyển'),
                                                                  );
                                                                },
                                                                child: Text(row[
                                                                        'examTotal']
                                                                    .toString()),
                                                              ),
                                                            ),
                                                            DataCell(
                                                              SelectableText(
                                                                  moneyFormatter(row[
                                                                      'amountTotal']),
                                                                  style:
                                                                      bangDuLieu),
                                                            ),
                                                            //
                                                          ],
                                                        )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Row(
                                              children: [
                                                Expanded(
                                                  child: DataTable(
                                                    showCheckboxColumn: false,
                                                    columns: [
                                                      DataColumn(
                                                          label: SelectableText(
                                                              'STT',
                                                              style:
                                                                  titleTableData)),
                                                      DataColumn(
                                                          label: SelectableText(
                                                              'Mã nhân viên',
                                                              style:
                                                                  titleTableData)),
                                                      DataColumn(
                                                          label: SelectableText(
                                                              'Tên nhân viên',
                                                              style:
                                                                  titleTableData)),
                                                      DataColumn(
                                                          label: SelectableText(
                                                              'Số lượng TTS',
                                                              style:
                                                                  titleTableData)),
                                                      DataColumn(
                                                          label: SelectableText(
                                                              'Tổng tiền',
                                                              style:
                                                                  titleTableData)),
                                                    ],
                                                    rows: <DataRow>[
                                                      for (var row in listData)
                                                        DataRow(
                                                          cells: <DataCell>[
                                                            DataCell(Center(
                                                                child: SelectableText(
                                                                    "${tableIndex++}"))),
                                                            DataCell(
                                                              Center(
                                                                  child: SelectableText(
                                                                      row['nhanvien']
                                                                          [
                                                                          'userCode'],
                                                                      style:
                                                                          bangDuLieu)),
                                                            ),
                                                            DataCell(
                                                              SelectableText(
                                                                  row['nhanvien']
                                                                      [
                                                                      'fullName'],
                                                                  style:
                                                                      bangDuLieu),
                                                            ),
                                                            DataCell(TextButton(
                                                              child: Text(row[
                                                                      'ttsTotal']
                                                                  .toString()),
                                                              onPressed: () {
                                                                showDialog(
                                                                    context:
                                                                        context,
                                                                    builder: (BuildContext
                                                                            context) =>
                                                                        DanhSachDaThiTuyen(
                                                                          row:
                                                                              row,
                                                                          orderId:
                                                                              widget.row['orderId'],
                                                                        ));
                                                              },
                                                            )),
                                                            DataCell(
                                                              SelectableText(
                                                                  moneyFormatter(row[
                                                                      'bonus']),
                                                                  style:
                                                                      bangDuLieu),
                                                            ),
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
                                        setState(() {
                                          getListDataFuture =
                                              getListData(currentPage);
                                          currentPageDef = currentPage;
                                        });
                                      }, rowPerPageChangeHandler:
                                              (rowPerPageChange) {
                                        currentPageDef = 1;

                                        rowPerPage = rowPerPageChange;
                                        getListDataFuture =
                                            getListData(currentPageDef);
                                        setState(() {});
                                      }),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          SelectableText('Tổng tiền:',
                                              style: titleWidgetBox),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          SelectableText(
                                              '${moneyFormatter(widget.row['totalAmount'])} ',
                                              style: titleWidgetBox),
                                          SizedBox(width: 15)
                                        ],
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: 16, right: 16, bottom: 16),
                                        child: Divider(
                                          thickness: 1,
                                          color: ColorHorizontalLine,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            } else if (snapshot.hasError) {
                              return SelectableText('${snapshot.error}');
                            }

                            // By default, show a loading spinner.
                            return Center(
                                child: const CircularProgressIndicator());
                          },
                        ),
                      ),
                    ],
                  ),
                )

                // Row(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: [
                //     Container(
                //       // margin: EdgeInsets.only(left: 20),
                //       child: TextButton(
                //         style: TextButton.styleFrom(
                //           padding: const EdgeInsets.symmetric(
                //             vertical: 20.0,
                //             horizontal: 10.0,
                //           ),
                //           shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(5.0),
                //           ),
                //           backgroundColor: Color.fromRGBO(245, 117, 29, 1),
                //           primary: Theme.of(context).iconTheme.color,
                //           textStyle: Theme.of(context)
                //               .textTheme
                //               .caption
                //               ?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                //         ),
                //         onPressed: () {
                //           Navigator.pop(context);
                //         },
                //         child: Row(
                //           children: [
                //             SelectableText('Xác nhận', style: textButton),
                //           ],
                //         ),
                //       ),
                //     ),
                //   ],
                // )
              ],
            ),
          ],
        ),
      ),
      actions: [
        (widget.row['paidStatus'] == 0 && widget.row['bonusType'] == 2) ||
                (widget.row['acctApprove'] == 0 && widget.row['bonusType'] == 1)
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    // textColor: Color(0xFF6200EE),
                    onPressed: () async {
                      await showDialog(
                          context: context,
                          builder: (BuildContext context) => XacNhan(
                              title: "Xác nhận hủy thanh toán",
                              function: () async {
                                await updateTctDn(2);
                                if (widget.row['bonusType'] == 2) {
                                  await updateOrder();
                                } else {
                                  await getListTts();
                                  for (var row in listTts) {
                                    await updateLstt(row);
                                  }
                                }
                                widget.function();
                                showToast(
                                  context: context,
                                  msg: titleLog,
                                  color: titleLog == 'Xác nhận hủy thành công'
                                      ? Color.fromARGB(136, 72, 238, 67)
                                      : Colors.red,
                                  icon: titleLog == 'Xác nhận hủy thành công'
                                      ? Icon(Icons.done)
                                      : Icon(Icons.warning),
                                );
                              },
                              content:
                                  "Bạn có chắc chắn muốn xác nhận hủy thanh toán thưởng không?"));
                      Navigator.pop(context);
                    },
                    child: Text('Từ chối duyệt'),
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
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          // textColor: Color(0xFF6200EE),
                          onPressed: () => Navigator.pop(context),
                          child: Text('Hủy'),
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
                        Container(
                          margin: EdgeInsets.only(left: 20),
                          child: ElevatedButton(
                            // textColor: Color(0xFF6200EE),
                            onPressed: () async {
                              await showDialog(
                                  context: context,
                                  builder: (BuildContext context) => XacNhan(
                                      title: "Xác nhận thưởng",
                                      function: () async {
                                        await updateTctDn(1);
                                        widget.function();
                                        showToast(
                                          context: context,
                                          msg: titleLog,
                                          color: titleLog ==
                                                  "Xác nhận thưởng thành công"
                                              ? Color.fromARGB(136, 72, 238, 67)
                                              : Colors.red,
                                          icon: titleLog ==
                                                  "Xác nhận thưởng thành công"
                                              ? Icon(Icons.done)
                                              : Icon(Icons.warning),
                                        );
                                        if (widget.row['bonusType'] == 2) {
                                          print('Thưởng ok');
                                          await httpPost(
                                              "/api/push/tags/depart_id/6&9",
                                              {
                                                "title": "Hệ thống thông báo",
                                                "message":
                                                    "Đề nghị thưởng đơn hàng ${widget.row['code']} đã được thực hiện."
                                              },
                                              context);
                                        } else {
                                          await httpPost(
                                              "/api/push/tags/depart_id/6&9",
                                              {
                                                "title": "Hệ thống thông báo",
                                                "message":
                                                    "Đề nghị thưởng chỉ tiêu tuyển dụng ${widget.row['code']} đã được thực hiện."
                                              },
                                              context);
                                        }
                                      },
                                      content:
                                          "Bạn có chắc chắn muốn xác nhận thưởng không?"));
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
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : ElevatedButton(
                // textColor: Color(0xFF6200EE),
                onPressed: () => Navigator.pop(context),
                child: Text('Đóng'),
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
      ],
    );
  }
}

class XacNhan extends StatefulWidget {
  String title;
  String content;
  Function function;
  XacNhan(
      {Key? key,
      required this.title,
      required this.function,
      required this.content})
      : super(key: key);
  @override
  State<XacNhan> createState() => _XacNhanState();
}

class _XacNhanState extends State<XacNhan> {
  @override
  Widget build(BuildContext context) {
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
                  widget.title,
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
        height: 100,
        width: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(0),
              child: Divider(
                thickness: 1,
              ),
            ),
            SelectableText(
              widget.content,
            ),
            Padding(
              padding: const EdgeInsets.all(0),
              child: Divider(
                thickness: 1,
              ),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          // textColor: Color(0xFF6200EE),
          onPressed: () => Navigator.pop(context),
          child: Text('Hủy'),
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
        ElevatedButton(
          // textColor: Color(0xFF6200EE),
          onPressed: () async {
            await widget.function();
            Navigator.pop(context);
          },
          child: Text(
            'Đồng ý',
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
      ],
    );
  }
}

class DanhSachTtsThiTuyen extends StatefulWidget {
  final String titleDialog;
  // final Function setState;
  final dynamic user;
  const DanhSachTtsThiTuyen(
      {Key? key,
      required this.titleDialog,
      // required this.setState,
      required this.user})
      : super(key: key);

  @override
  State<DanhSachTtsThiTuyen> createState() => _DanhSachTtsThiTuyenState();
}

class _DanhSachTtsThiTuyenState extends State<DanhSachTtsThiTuyen> {
  late Future<dynamic> getListHistoryExamFuture;
  late int rowCount = 0;
  int currentPageDef = 1;
  int rowPerPage = 10;
  var listHistory;
  var resultListTargetBonus;

  getListHistoryExam(curentPage) async {
    var targetBonus = await httpGet(
        "/api/thuong-chitieu-donhang/get/page?filter=approve:1", context);
    if (targetBonus.containsKey("body")) {
      setState(() {
        resultListTargetBonus = jsonDecode(targetBonus["body"])['content'];
      });
    }
    var response = await httpGet(
        "/api/tts-lichsu-thituyen/get/page?size=$rowPerPage&page=${curentPage - 1}&sort=ttsId&filter=thuctapsinh.careUser:${widget.user['userId']} and rewardOfferId:${widget.user['rewardOfferId']} and examResult in (1,2,3)",
        context);
    if (response.containsKey("body")) {
      listHistory = jsonDecode(response["body"])['content'];
      rowCount = jsonDecode(response["body"])['totalElements'];
      setState(() {});
      return listHistory;
    }
  }

  @override
  void initState() {
    getListHistoryExamFuture = getListHistoryExam(1);
    super.initState();
  }

  DateTime selectedDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: getListHistoryExamFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          String targetBonus(orderId) {
            for (var row in resultListTargetBonus) {
              if (row['orderId'] == orderId) {
                return NumberFormat.simpleCurrency(locale: "vi")
                    .format(row['targetBonus'])
                    .toString();
              }
            }
            return '';
          }

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
                        child: Image.asset('assets/images/logoAAM.png'),
                        margin: EdgeInsets.only(right: 10),
                      ),
                      Text(
                        widget.titleDialog,
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
              width: 1300,
              height: 600,
              child: ListView(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Divider(
                          thickness: 1,
                        ),
                      ),
                      Container(
                        child: Container(
                          child: Column(
                            children: [
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: DataTable(
                                          columnSpacing: 5,
                                          showCheckboxColumn: true,
                                          columns: [
                                            DataColumn(
                                                label: Expanded(
                                                    child: Text(
                                              'STT',
                                              style: titleTableData,
                                              textAlign: TextAlign.center,
                                            ))),
                                            DataColumn(
                                                label: Expanded(
                                                    child: Text(
                                              'Tên TTS',
                                              style: titleTableData,
                                              textAlign: TextAlign.center,
                                            ))),
                                            DataColumn(
                                                label: Expanded(
                                                    child: Text(
                                              'Ngày thi',
                                              style: titleTableData,
                                              textAlign: TextAlign.center,
                                            ))),
                                            DataColumn(
                                                label: Expanded(
                                                    child: Text(
                                              'Đơn hàng',
                                              style: titleTableData,
                                              textAlign: TextAlign.center,
                                            ))),
                                            DataColumn(
                                                label: Expanded(
                                                    child: Text(
                                              'Thưởng chỉ tiêu',
                                              style: titleTableData,
                                              textAlign: TextAlign.center,
                                            ))),
                                          ],
                                          rows: <DataRow>[
                                            for (var row in listHistory)
                                              DataRow(cells: [
                                                DataCell(Center(
                                                    child: Text(
                                                        "${tableIndex++}"))),
                                                DataCell(Text(
                                                    "${row['thuctapsinh']['fullName']} (${row['thuctapsinh']['userCode']})")),
                                                DataCell(Text(
                                                    row['examDate'] != null
                                                        ? DateFormat(
                                                                "dd-MM-yyyy")
                                                            .format(DateTime
                                                                    .parse(row[
                                                                        'examDate'])
                                                                .toLocal())
                                                        : '',
                                                    style: bangDuLieu)),
                                                DataCell(Text(
                                                    row['donhang'] != null
                                                        ? row['donhang']
                                                            ['orderName']
                                                        : '',
                                                    style: bangDuLieu)),
                                                DataCell(Text(
                                                    targetBonus(
                                                        row['donhang']['id']),
                                                    style: bangDuLieu)),
                                                //
                                              ])
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  DynamicTablePagging(
                                      rowCount, currentPageDef, rowPerPage,
                                      pageChangeHandler: (currentPage) {
                                    setState(() {
                                      getListHistoryExamFuture =
                                          getListHistoryExam(currentPage);

                                      currentPageDef = currentPage;
                                    });
                                  }, rowPerPageChangeHandler:
                                          (rowPerPageChange) {
                                    currentPageDef = 1;

                                    rowPerPage = rowPerPageChange;
                                    getListHistoryExamFuture =
                                        getListHistoryExam(currentPageDef);
                                    setState(() {});
                                  }),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.only(left: 20, bottom: 20),
                child: TextButton(
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
                    textStyle: Theme.of(context)
                        .textTheme
                        .caption
                        ?.copyWith(fontSize: 20.0, letterSpacing: 2.0),
                  ),
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                  child: Text('Đóng', style: textButton),
                ),
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        // By default, show a loading spinner.
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class DanhSachDaThiTuyen extends StatefulWidget {
  dynamic row;
  dynamic orderId;
  DanhSachDaThiTuyen({Key? key, this.row, this.orderId}) : super(key: key);

  @override
  State<DanhSachDaThiTuyen> createState() => _DanhSachDaThiTuyenState();
}

class _DanhSachDaThiTuyenState extends State<DanhSachDaThiTuyen> {
  var listTts = [];
  getListTraineeTookTheExam() async {
    var response = await httpGet(
        "/api/tts-lichsu-thituyen/get/page?filter=orderId:${widget.orderId} and (thuctapsinh.stopProcessing is null or thuctapsinh.stopProcessing:0) and thuctapsinh.ttsStatusId!13 and thuctapsinh.careUser:${widget.row['nhanvien']['id']} and examResult in (1,2)",
        context);
    print(response);

    if (response.containsKey("body")) {
      setState(() {
        listTts = jsonDecode(response["body"])['content'];
      });
    }
    return 0;
  }

  late Future<dynamic> getListTts;
  @override
  void initState() {
    getListTts = getListTraineeTookTheExam();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int index = 1;
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
                  child: Image.asset('assets/images/logoAAM.png'),
                  margin: EdgeInsets.only(right: 10),
                ),
                Text(
                  "Danh sách thực tập sinh",
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
      content: FutureBuilder<dynamic>(
        future: getListTts,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              child: Container(
                width: 1000,
                height: 600,
                child: ListView(
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Divider(
                            thickness: 1,
                          ),
                        ),
                        Container(
                          child: Container(
                            child: Column(
                              children: [
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: DataTable(
                                            showCheckboxColumn: false,
                                            columns: [
                                              DataColumn(
                                                  label: Text('STT',
                                                      style: titleTableData)),
                                              DataColumn(
                                                  label: Text('Mã TTS',
                                                      style: titleTableData)),
                                              DataColumn(
                                                  label: Text('Tên TTS',
                                                      style: titleTableData)),
                                              DataColumn(
                                                  label: Text('Trạng thái',
                                                      style: titleTableData)),
                                            ],
                                            rows: <DataRow>[
                                              for (var row in listTts)
                                                DataRow(
                                                  cells: <DataCell>[
                                                    DataCell(
                                                        Text("${index++}")),
                                                    DataCell(Text(
                                                      (row != null)
                                                          ? row['thuctapsinh']
                                                                  ["userCode"]
                                                              .toString()
                                                          : "nodata",
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    )),
                                                    DataCell(
                                                      Text(
                                                          (row != null)
                                                              ? row['thuctapsinh']
                                                                      [
                                                                      "fullName"]
                                                                  .toString()
                                                              : "nodata",
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400)),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                          row['thuctapsinh'][
                                                                      "ttsTrangthai"]
                                                                  [
                                                                  "statusName"] ??
                                                              "nodata",
                                                          style: bangDuLieu),
                                                    ),
                                                  ],
                                                )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }

          // By default, show a loading spinner.
          return const CircularProgressIndicator();
        },
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(left: 20, bottom: 20),
          child: TextButton(
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
              textStyle: Theme.of(context)
                  .textTheme
                  .caption
                  ?.copyWith(fontSize: 20.0, letterSpacing: 2.0),
            ),
            onPressed: () {
              setState(() {
                Navigator.pop(context);
              });
            },
            child: Text('Đóng', style: textButton),
          ),
        ),
      ],
    );
  }
}
