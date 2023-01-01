import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../api.dart';
import '../../../../common/dynamic_table.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/model.dart';
import '../../../common/style.dart';
import '../../navigation.dart';
// ignore: unused_import

class ThuPhatDaoTao extends StatefulWidget {
  const ThuPhatDaoTao({Key? key}) : super(key: key);

  @override
  _ThuPhatDaoTaoState createState() => _ThuPhatDaoTaoState();
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ThuPhatDaoTaoState extends State<ThuPhatDaoTao> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: ThuPhatDaoTaoBody());
  }
}

class ThuPhatDaoTaoBody extends StatefulWidget {
  const ThuPhatDaoTaoBody({Key? key}) : super(key: key);
  @override
  State<ThuPhatDaoTaoBody> createState() => _ThuPhatDaoTaoBodyState();
}

class _ThuPhatDaoTaoBodyState extends State<ThuPhatDaoTaoBody> {
  String? selectedValueTT = 'Tất cả';
  List<String> trangThai = [
    'Đã tiến cử',
    'Đã trúng tuyển',
    'Chờ xuất cảnh',
    'Đã xuất cảnh'
  ];
  // ignore: non_constant_identifier_names
  String? selectedValueDH = 'Tất cả';
  List<String> donHang = [
    'Cà chua Shizouka (DH281)',
    'Cà chua1 Shizouka (DH281)',
    'Cà chua2 Shizouka (DH281)',
  ];
  String? birthDate;
  bool thanhLy = false;
  // ignore: non_constant_identifier_names
  TextEditingController name = TextEditingController();
  TextEditingController address = TextEditingController();
  var listTtsDxl = [];
  late int rowCount = 0;
  int currentPageDef = 1;
  int rowPerPage = 10;
  String? dateFrom;
  String? dateTo;
  late Future<dynamic> getListQdxpFuture;

  late int rowCountQdxp = 0;
  int currentPageDefQdxp = 1;
  int rowPerPageQdxp = 10;
  var listQdxp;
  getListQdxp(currentPage) async {
    String query = '';
    if (dateFrom != null && dateTo == null) {
      query += " and decisionDate>:'$dateFrom' ";
    } else if (dateFrom == null && dateTo != null) {
      query += " and decisionDate<:'$dateTo' ";
    } else if (dateFrom != null && dateTo != null) {
      query += " and decisionDate>:'$dateFrom' and decisionDate<:'$dateTo' ";
    }
    var response = await httpGet(
        "/api/daotao-xuphat/get/page?sort=finesApproval,asc&sort=decisionDate&sort=modifiedDate,desc&size=$rowPerPageQdxp&page=${currentPage - 1}&filter=treatment:1 $query",
        context);
    if (response.containsKey("body")) {
      setState(() {
        listQdxp = jsonDecode(response["body"])['content'];
        // print(listTtsDxl.first['nguoidung']);
        rowCountQdxp = jsonDecode(response["body"])['totalElements'];
      });
    }
    return 0;
  }

  @override
  void initState() {
    // TODO: implement initState
    getListQdxpFuture = getListQdxp(1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: userRule('/thu-phat-dao-tao', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return ListView(
            children: [
              TitlePage(
                listPreTitle: [
                  {'url': '/bang-thong-ke-nhanh', 'title': 'Dashboard'},
                ],
                content: 'Thanh lý xử phạt',
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    vertical: verticalPaddingPage,
                    horizontal: horizontalPaddingPage),
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
                                flex: 3,
                                child: DatePickerBoxVQ(
                                    requestDayBefore: dateTo,
                                    isTime: false,
                                    label: Text(
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
                                    label: Text(
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
                                          getListQdxpFuture = getListQdxp(1);
                                        },
                                        child: Row(
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
              //
              Container(
                color: backgroundPage,
                padding: EdgeInsets.symmetric(
                    vertical: 10, horizontal: horizontalPaddingPage),
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
                              child: FutureBuilder<dynamic>(
                            future: getListQdxpFuture,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                var tableIndex =
                                    (currentPageDefQdxp - 1) * rowPerPageQdxp +
                                        1;
                                return Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Danh sách quyết định xử phạt',
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
                                          showCheckboxColumn: false,
                                          columns: [
                                            DataColumn(
                                                label: Text('STT',
                                                    style: titleTableData)),
                                            DataColumn(
                                                label: Text('Nội dung vi phạm',
                                                    style: titleTableData)),
                                            DataColumn(
                                                label: Text(
                                                    'Ngày ra quyết định',
                                                    style: titleTableData)),
                                            DataColumn(
                                                label: Text('Nội dung',
                                                    style: titleTableData)),
                                            DataColumn(
                                                label: Text('Xác nhận thu tiền',
                                                    style: titleTableData)),
                                          ],
                                          rows: <DataRow>[
                                            for (var row in listQdxp)
                                              DataRow(cells: [
                                                DataCell(
                                                  Text('${tableIndex++}',
                                                      style: bangDuLieu),
                                                ),
                                                DataCell(
                                                  Text(row['title'] ?? "",
                                                      style: bangDuLieu),
                                                ),
                                                DataCell(
                                                  Text(
                                                      row['decisionDate'] !=
                                                              null
                                                          ? dateReverse(
                                                              displayDateTimeStamp(
                                                                  row['decisionDate']))
                                                          : "",
                                                      style: bangDuLieu),
                                                ),
                                                DataCell(InkWell(
                                                  onTap: getRule(listRule.data,
                                                          Role.Sua, context)
                                                      ? () {
                                                          showDialog(
                                                              context: context,
                                                              builder: (BuildContext
                                                                      context) =>
                                                                  showDialogLydo(
                                                                    titleDialog:
                                                                        "Xác nhận xử phạt cho TTS",
                                                                    row: row,
                                                                    function:
                                                                        () {
                                                                      getListQdxp(
                                                                          currentPageDefQdxp);
                                                                      setState(
                                                                          () {});
                                                                    },
                                                                  ));
                                                        }
                                                      : () {
                                                          showToast(
                                                            context: context,
                                                            msg:
                                                                "Bạn không có quyền thực hiện chức năng này",
                                                            color: Colors.red,
                                                            icon: Icon(
                                                                Icons.warning),
                                                          );
                                                        },
                                                  child: Text(
                                                    "Chi tiết",
                                                    style: TextStyle(
                                                        color: Colors.blue),
                                                  ),
                                                )),
                                                DataCell(
                                                  Text(
                                                      row['finesApproval'] == 0
                                                          ? "Chưa thu"
                                                          : "Đã thu tiền phạt",
                                                      style: bangDuLieu),
                                                ),
                                              ])
                                          ],
                                        )),
                                      ],
                                    ),
                                    DynamicTablePagging(rowCountQdxp,
                                        currentPageDefQdxp, rowPerPageQdxp,
                                        pageChangeHandler: (currentPage) {
                                      setState(() {
                                        getListQdxpFuture =
                                            getListQdxp(currentPage);
                                        currentPageDefQdxp = currentPage;
                                      });
                                    }, rowPerPageChangeHandler:
                                            (rowPerPageChange) {
                                      rowPerPageQdxp = rowPerPageChange;
                                      getListQdxpFuture =
                                          getListQdxp(currentPageDefQdxp);
                                      setState(() {});
                                    }),
                                  ],
                                );
                              } else if (snapshot.hasError) {
                                return Text('${snapshot.error}');
                              }

                              // By default, show a loading spinner.
                              return Center(
                                  child: const CircularProgressIndicator());
                            },
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Footer()
            ],
          );
        } else if (listRule.hasError) {
          return Text('${listRule.error}');
        }
        // By default, show a loading spinner.
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

// ignore: non_constant_identifier_names, camel_case_types
class showDialogLydo extends StatefulWidget {
  final String titleDialog;
  final dynamic row;
  final Function function;
  const showDialogLydo(
      {Key? key,
      required this.titleDialog,
      required this.row,
      required this.function})
      : super(key: key);

  @override
  State<showDialogLydo> createState() => _showDialogLydoState();
}

// ignore: camel_case_types
class _showDialogLydoState extends State<showDialogLydo> {
  String? loaiThanhToan = 'Tạm thu trước thi tuyển';
  // ignore: non_constant_identifier_names
  late Future<dynamic> getListNvpFuture;
  var listNvp = [];
  getListNvp() async {
    var response = await httpGet(
        "/api/daotao-xuphat-chitiet/get/page?filter=eduDecisionId:${widget.row['id']}",
        context);
    if (response.containsKey("body")) {
      setState(() {
        listNvp = jsonDecode(response["body"])['content'];
      });
    }
    return 0;
  }

  String titleLog = 'Xác nhận thu tiền thành công';
  updateQdxp() async {
    widget.row['finesApproval'] = 1;
    widget.row['finesApprover'] =
        Provider.of<SecurityModel>(context, listen: false)
            .userLoginCurren['id'];
    var response = await httpPut(
        '/api/daotao-xuphat/put/${widget.row['id']}', widget.row, context);

    if (response['body'] == 'true') {
      await httpPost(
          "/api/push/tags/depart_id/7",
          {
            "title": "Hệ thống thông báo",
            "message":
                "Quyết định xử phạt ${widget.row['title']} ngày ${widget.row['decisionDate'] != null ? DateFormat("dd-MM-yyyy").format(DateTime.tryParse(widget.row['decisionDate'])!) : "không xác định"} đã được thực hiện."
          },
          context);
    } else {
      titleLog = 'Xác nhận thu tiền thất bại';
    }
  }

  String? trangThai = 'Chưa thanh toán';
  // ignore: non_constant_identifier_names
  List<String> TrangThai = ['Chưa thanh toán', 'Đã thanh toán'];
  int a = 0, b = 0, c = 0;
  @override
  void initState() {
    getListNvpFuture = getListNvp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int i = 1;
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
            Text(
              'Xác nhận xử phạt cho TTS',
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
      content: FutureBuilder<dynamic>(
        future: getListNvpFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              width: 1200,
              height: listNvp.isEmpty ? 200 : 300,
              child: ListView(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Danh sách TTS vi phạm',
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
                                      showCheckboxColumn: false,
                                      columns: [
                                        DataColumn(
                                            label: Container(
                                                // width: 25,
                                                child: Text('STT',
                                                    style: titleTableData))),
                                        DataColumn(
                                            label: Container(
                                                // width: 50,
                                                child: Text('Họ và tên',
                                                    style: titleTableData))),
                                        DataColumn(
                                            label: Text('Ngày sinh',
                                                style: titleTableData)),
                                        DataColumn(
                                            label: Text('Tên đơn hàng',
                                                style: titleTableData)),
                                        // DataColumn(
                                        //     label: Text('Lý do', style: titleTableData)),
                                        // DataColumn(
                                        //     label: Text('Ngày nhập học trúng tuyển',
                                        //         style: titleTableData)),
                                        DataColumn(
                                            label: Text('Nội dung phạt',
                                                style: titleTableData)),
                                        DataColumn(
                                            label: Text('Ghi chú',
                                                style: titleTableData)),
                                        DataColumn(
                                            label: Text('Tổng phạt',
                                                style: titleTableData)),
                                      ],
                                      rows: <DataRow>[
                                        for (var row in listNvp)
                                          DataRow(cells: [
                                            DataCell(
                                              Text('${i++}', style: bangDuLieu),
                                            ),
                                            DataCell(
                                              Text(
                                                  row['thuctapsinh']
                                                      ['fullName'],
                                                  style: bangDuLieu),
                                            ),
                                            DataCell(
                                              Text(
                                                  row['thuctapsinh']
                                                          ['birthDate'] ??
                                                      '',
                                                  style: bangDuLieu),
                                            ),
                                            DataCell(
                                              Text(
                                                  row['thuctapsinh']
                                                              ['donhang'] !=
                                                          null
                                                      ? row['thuctapsinh']
                                                              ['donhang']
                                                          ['orderName']
                                                      : "",
                                                  style: bangDuLieu),
                                            ),
                                            // DataCell(
                                            //   Text(
                                            //       row['nguoidung']['ttsTrangthai']
                                            //           ['statusName'],
                                            //       style: bangDuLieu),
                                            // ),
                                            DataCell(
                                              Text(
                                                  row['quydinh'] != null
                                                      ? row['quydinh']
                                                                  ['quydinh']
                                                              ['name'] ??
                                                          ""
                                                      : '',
                                                  style: bangDuLieu),
                                            ),
                                            DataCell(
                                              Text(row['note'] ?? '',
                                                  style: bangDuLieu),
                                            ),
                                            DataCell(
                                              Text(moneyFormatter(row['fines']),
                                                  style: bangDuLieu),
                                            ),
                                            // DataCell(
                                            //   Text(
                                            //       row['approvalType'] == 0
                                            //           ? ''
                                            //           : row['approvalDate'],
                                            //       style: bangDuLieu),
                                            // ),
                                          ])
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }

          // By default, show a loading spinner.
          return Center(child: const CircularProgressIndicator());
        },
      ),
      actions: [
        ElevatedButton(
          // textColor: Color(0xFF6200EE),
          onPressed: () => Navigator.pop(context),
          child: Text(widget.row['finesApproval'] == 0 ? 'Hủy' : 'Đóng'),
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
        widget.row['finesApproval'] == 0
            ? ElevatedButton(
                // textColor: Color(0xFF6200EE),
                onPressed: () async {
                  await showDialog(
                      context: context,
                      builder: (BuildContext context) => XacNhan(
                          title: "Xác nhận thu tiền nộp phạt",
                          function: () async {
                            await updateQdxp();
                            widget.function();
                            showToast(
                              context: context,
                              msg: titleLog,
                              color: titleLog == "Xác nhận thu tiền thành công"
                                  ? Color.fromARGB(136, 72, 238, 67)
                                  : Colors.red,
                              icon: titleLog == "Xác nhận thu tiền thành công"
                                  ? Icon(Icons.done)
                                  : Icon(Icons.warning),
                            );
                            Navigator.pop(context);
                          },
                          content:
                              "Bạn có chắc chắn muốn xác nhận thu toàn bộ tiền nộp phạt không?"));
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
              )
            : Container(),
      ],
    );
  }
}

// ignore: must_be_immutable
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
                Text(
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
            Text(
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
            widget.function();
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
