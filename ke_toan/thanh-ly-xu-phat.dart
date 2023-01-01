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

import '../../../model/model.dart';
import '../navigation.dart';

class ThanhLyXuPhat extends StatefulWidget {
  const ThanhLyXuPhat({Key? key}) : super(key: key);

  @override
  _ThanhLyXuPhatState createState() => _ThanhLyXuPhatState();
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ThanhLyXuPhatState extends State<ThanhLyXuPhat> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: ThanhLyXuPhatBody());
  }
}

class ThanhLyXuPhatBody extends StatefulWidget {
  const ThanhLyXuPhatBody({Key? key}) : super(key: key);
  @override
  State<ThanhLyXuPhatBody> createState() => _ThanhLyXuPhatBodyState();
}

class _ThanhLyXuPhatBodyState extends State<ThanhLyXuPhatBody> {
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
  late Future<dynamic> getListTtsDxlFuture;
  getListTtsDxl(currentPage) async {
    String query = '';
    if (birthDate != null) {
      query += " and nguoidung.birthDate:'$birthDate'";
    }
    var response = await httpGet(
        "/api/tts-donhang-dungxuly/get/page?sort=refunded,asc&sort=createdDate,desc&size=$rowPerPage&page=${currentPage - 1}&filter=moneyBack:true and nguoidung.fullName~'*${name.text}*' and nguoidung.address~'*${address.text}*' and itemType:0 and nguoidung.ttsStatusId:13 $query",
        context);
    if (response.containsKey("body")) {
      setState(() {
        listTtsDxl = jsonDecode(response["body"])['content'];
        // print(listTtsDxl.first['nguoidung']);
        rowCount = jsonDecode(response["body"])['totalElements'];
      });
    }
    return 0;
  }

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
      query += " decisionDate>:'$dateFrom'";
    } else if (dateFrom == null && dateTo != null) {
      query += " decisionDate<:'$dateTo'";
    } else if (dateFrom != null && dateTo != null) {
      query += " decisionDate>:'$dateFrom' and decisionDate<:'$dateTo'";
    }
    var response = await httpGet(
        "/api/quyetdinh-xuphat/get/page?sort=finesApproval,asc&sort=decisionDate,desc&size=$rowPerPageQdxp&page=${currentPage - 1}&filter=$query",
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
    getListTtsDxlFuture = getListTtsDxl(1);
    getListQdxpFuture = getListQdxp(1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: userRule('/thanh-ly-xu-phat', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return ListView(
            children: [
              TitlePage(
                listPreTitle: [
                  {'url': '/thanh-ly-xu-phat', 'title': 'Dashboard'},
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
                          thanhLy
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: TextFieldValidatedForm(
                                        type: 'None',
                                        controller: name,
                                        label: 'TTS:',
                                        flexLable: 2,
                                        flexTextField: 5, height: 40,
                                        enter: () {
                                          getListTtsDxlFuture =
                                              getListTtsDxl(1);
                                        },
                                        // widgetBox: Container(),
                                      ),
                                    ),
                                    SizedBox(width: 100),
                                    Expanded(
                                      flex: 3,
                                      child: TextFieldValidatedForm(
                                        type: 'None',
                                        controller: address,
                                        label: 'Địa chỉ:',
                                        flexLable: 2,
                                        flexTextField: 5, height: 40,
                                        enter: () {
                                          getListTtsDxlFuture =
                                              getListTtsDxl(1);
                                        },
                                        // widgetBox: Container(),
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          //tìm kiếm
                                          Container(
                                            margin: EdgeInsets.only(left: 20),
                                            child: TextButton(
                                              style: TextButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 20.0,
                                                  horizontal: 10.0,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
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
                                                if (thanhLy)
                                                  getListTtsDxlFuture =
                                                      getListTtsDxl(1);
                                                else {
                                                  getListQdxpFuture =
                                                      getListQdxp(1);
                                                }
                                              },
                                              child: Row(
                                                children: [
                                                  Transform.rotate(
                                                    angle: 270,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5,
                                                              right: 5),
                                                      child: Icon(
                                                        Icons.search,
                                                        color: Colors.white,
                                                        size: 15,
                                                      ),
                                                    ),
                                                  ),
                                                  Text('Tìm kiếm',
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
                          thanhLy
                              ? Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            margin: EdgeInsets.only(bottom: 30),
                                            child: DatePickerBoxVQ(
                                                isTime: false,
                                                label: Text(
                                                  'Ngày sinh',
                                                  style: titleWidgetBox,
                                                ),
                                                dateDisplay: birthDate,
                                                selectedDateFunction: (day) {
                                                  birthDate = day;
                                                  setState(() {});
                                                }),
                                          ),
                                        ),
                                        SizedBox(width: 100),
                                        Expanded(
                                          flex: 3,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              //tìm kiếm
                                              Container(
                                                margin: EdgeInsets.only(
                                                    left: 20, bottom: 30),
                                                child: TextButton(
                                                  style: TextButton.styleFrom(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      vertical: 20.0,
                                                      horizontal: 10.0,
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.0),
                                                    ),
                                                    backgroundColor:
                                                        Color.fromRGBO(
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
                                                    if (thanhLy)
                                                      getListTtsDxlFuture =
                                                          getListTtsDxl(1);
                                                    else {
                                                      getListQdxpFuture =
                                                          getListQdxp(1);
                                                    }
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Transform.rotate(
                                                        angle: 270,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 5,
                                                                  right: 5),
                                                          child: Icon(
                                                            Icons.search,
                                                            color: Colors.white,
                                                            size: 15,
                                                          ),
                                                        ),
                                                      ),
                                                      Text('Tìm kiếm',
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
                                    SizedBox(
                                      height: 25,
                                    ),
                                  ],
                                )
                              : Container()
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              //
              Container(
                padding: EdgeInsets.symmetric(
                    vertical: 0, horizontal: horizontalPaddingPage),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      // margin: EdgeInsets.only(left: 20),
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
                              !thanhLy ? Color(0xff009C87) : Colors.grey,
                          primary: Theme.of(context).iconTheme.color,
                          textStyle: Theme.of(context)
                              .textTheme
                              .caption
                              ?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                        ),
                        onPressed: () {
                          getListTtsDxlFuture = getListQdxp(1);
                          setState(() {
                            thanhLy = false;
                          });
                        },
                        child: Row(
                          children: [
                            Text('Xử phạt', style: textButton),
                          ],
                        ),
                      ),
                    ),
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
                              thanhLy ? Color(0xff009C87) : Colors.grey,
                          primary: Theme.of(context).iconTheme.color,
                          textStyle: Theme.of(context)
                              .textTheme
                              .caption
                              ?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                        ),
                        onPressed: () {
                          setState(() {
                            thanhLy = true;
                          });
                        },
                        child: Row(
                          children: [
                            Text('Thanh lý tài chính', style: textButton),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              thanhLy
                  ? Container(
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
                                  future: getListTtsDxlFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      var tableIndex =
                                          (currentPageDef - 1) * rowPerPage + 1;
                                      return Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Danh sách thực tập sinh dừng xử lý',
                                                style: titleBox,
                                              ),
                                            ],
                                          ),
                                          Container(
                                            margin:
                                                marginTopBottomHorizontalLine,
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
                                                          child: Text('STT',
                                                              style:
                                                                  titleTableData))),
                                                  DataColumn(
                                                      label: Container(
                                                          child: Text('Mã TTS',
                                                              style:
                                                                  titleTableData))),
                                                  DataColumn(
                                                      label: Text('Họ và tên',
                                                          style:
                                                              titleTableData)),
                                                  DataColumn(
                                                      label: Text(
                                                          'Trạng thái TTS',
                                                          style:
                                                              titleTableData)),
                                                  DataColumn(
                                                      label: Text('Lý do',
                                                          style:
                                                              titleTableData)),
                                                  DataColumn(
                                                      label: Text('Xác nhận',
                                                          style:
                                                              titleTableData)),
                                                  // DataColumn(
                                                  //     label: Text('Ngày xác nhận',
                                                  //         style: titleTableData)),
                                                ],
                                                rows: <DataRow>[
                                                  for (var row in listTtsDxl)
                                                    DataRow(cells: [
                                                      DataCell(
                                                        Text('${tableIndex++}',
                                                            style: bangDuLieu),
                                                      ),
                                                      DataCell(
                                                        Text(
                                                            row['nguoidung']
                                                                ['userCode'],
                                                            style: bangDuLieu),
                                                      ),
                                                      DataCell(
                                                        Text(
                                                            row['nguoidung']
                                                                ['fullName'],
                                                            style: bangDuLieu),
                                                      ),
                                                      DataCell(
                                                        Text(
                                                            row['nguoidung'][
                                                                        'ttsStatusId'] !=
                                                                    null
                                                                ? row['nguoidung']
                                                                        [
                                                                        'ttsTrangthai']
                                                                    [
                                                                    'statusName']
                                                                : '',
                                                            style: bangDuLieu),
                                                      ),
                                                      DataCell(InkWell(
                                                        onTap: () {
                                                          showDialog(
                                                              context: context,
                                                              builder: (BuildContext
                                                                      context) =>
                                                                  LyDoDXL(
                                                                    view: true,
                                                                    row: row,
                                                                    function:
                                                                        () {
                                                                      getListTtsDxlFuture =
                                                                          getListTtsDxl(
                                                                              currentPageDef);
                                                                      setState(
                                                                          () {});
                                                                    },
                                                                  ));
                                                        },
                                                        child: Text(
                                                          row['causeType'] == 0
                                                              ? "Do cá nhân"
                                                              : row['causeType'] ==
                                                                      1
                                                                  ? "Do nghiệp đoàn"
                                                                  : "Khác",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.blue),
                                                        ),
                                                      )),
                                                      DataCell(
                                                        row['refunded'] == 1
                                                            ? Text(
                                                                "Đã xác nhận",
                                                                style:
                                                                    bangDuLieu)
                                                            : Container(
                                                                child: Row(
                                                                  children: [
                                                                    Container(
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
                                                                              ?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          showDialog(
                                                                              context: context,
                                                                              builder: (BuildContext context) => LyDoDXL(
                                                                                    view: false,
                                                                                    row: row,
                                                                                    function: () {
                                                                                      getListTtsDxlFuture = getListTtsDxl(currentPageDef);
                                                                                      setState(() {});
                                                                                    },
                                                                                  ));
                                                                        },
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Text('Xác nhận',
                                                                                style: textButton),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
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
                                              )),
                                            ],
                                          ),
                                          DynamicTablePagging(rowCount,
                                              currentPageDef, rowPerPage,
                                              pageChangeHandler: (currentPage) {
                                            setState(() {
                                              getListTtsDxlFuture =
                                                  getListTtsDxl(currentPage);
                                              currentPageDef = currentPage;
                                            });
                                          }, rowPerPageChangeHandler:
                                                  (rowPerPageChange) {
                                            currentPageDef = 1;
                                            rowPerPage = rowPerPageChange;
                                            getListTtsDxlFuture =
                                                getListTtsDxl(currentPageDef);
                                            setState(() {});
                                          }),
                                        ],
                                      );
                                    } else if (snapshot.hasError) {
                                      return Text('${snapshot.error}');
                                    }

                                    // By default, show a loading spinner.
                                    return Center(
                                        child:
                                            const CircularProgressIndicator());
                                  },
                                )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(
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
                                          (currentPageDefQdxp - 1) *
                                                  rowPerPageQdxp +
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
                                            margin:
                                                marginTopBottomHorizontalLine,
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
                                                          style:
                                                              titleTableData)),
                                                  DataColumn(
                                                      label: Text(
                                                          'Nội dung vi phạm',
                                                          style:
                                                              titleTableData)),
                                                  DataColumn(
                                                      label: Text(
                                                          'Ngày ra quyết định',
                                                          style:
                                                              titleTableData)),
                                                  DataColumn(
                                                      label: Text('Nội dung',
                                                          style:
                                                              titleTableData)),
                                                  DataColumn(
                                                      label: Text(
                                                          'Xác nhận thu tiền',
                                                          style:
                                                              titleTableData)),
                                                ],
                                                rows: <DataRow>[
                                                  for (var row in listQdxp)
                                                    DataRow(cells: [
                                                      DataCell(
                                                        Text('${tableIndex++}',
                                                            style: bangDuLieu),
                                                      ),
                                                      DataCell(
                                                        Text(
                                                            row['quydinh'][
                                                                    'ruleName'] ??
                                                                "",
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
                                                        onTap:
                                                            getRule(
                                                                    listRule
                                                                        .data,
                                                                    Role.Sua,
                                                                    context)
                                                                ? () {
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder: (BuildContext
                                                                                context) =>
                                                                            showDialogLydo(
                                                                              titleDialog: "Xác nhận thanh lý hoặc xử phạt cho TTS",
                                                                              row: row,
                                                                              function: () {
                                                                                getListQdxp(currentPageDefQdxp);
                                                                                setState(() {});
                                                                              },
                                                                            ));
                                                                  }
                                                                : () {
                                                                    showToast(
                                                                      context:
                                                                          context,
                                                                      msg:
                                                                          "Bạn không có quyền thực hiện chức năng này",
                                                                      color: Colors
                                                                          .red,
                                                                      icon: Icon(
                                                                          Icons
                                                                              .warning),
                                                                    );
                                                                  },
                                                        child: Text(
                                                          "Chi tiết",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.blue),
                                                        ),
                                                      )),
                                                      DataCell(
                                                        Text(
                                                            row['finesApproval'] ==
                                                                    0
                                                                ? "Chưa thu"
                                                                : "Đã thu tiền phạt",
                                                            style: bangDuLieu),
                                                      ),
                                                    ])
                                                ],
                                              )),
                                            ],
                                          ),
                                          DynamicTablePagging(
                                              rowCountQdxp,
                                              currentPageDefQdxp,
                                              rowPerPageQdxp,
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
                                        child:
                                            const CircularProgressIndicator());
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

// ignore: must_be_immutable
class LyDoDXL extends StatefulWidget {
  dynamic row;
  Function? function;
  bool view;
  LyDoDXL({Key? key, this.row, this.function, required this.view})
      : super(key: key);

  @override
  State<LyDoDXL> createState() => _LyDoDXLState();
}

class _LyDoDXLState extends State<LyDoDXL> {
  TextEditingController content = TextEditingController();
  String titleLog = 'Xác nhận thanh toán thành công';
  updateDXL() async {
    // print("$selectedValueLTT" + 'Date');

    if (widget.row != null) {
      // String dateName = "$selectedValueLTT" + 'Date';
      // var realTime =
      //     DateFormat("yyyy-MM-ddTHH:mm:ss").format(DateTime.now().toLocal());
      widget.row['refunded'] = 1;
      widget.row['refundApprover'] =
          Provider.of<SecurityModel>(context, listen: false)
              .userLoginCurren['id'];
      var response = await httpPut(
          '/api/tts-donhang-dungxuly/put/${widget.row['id']}',
          widget.row,
          context);
      if (response['body'] == 'true') {
        if (widget.row['nguoidung']['nhanvientuyendung'] != null)
          await httpPost(
              "/api/push/tags/user_code/${widget.row['nguoidung']['nhanvientuyendung']['userCode']}",
              {
                "title": "Hệ thống thông báo",
                "message":
                    "Yêu cầu thanh lý tài chính cho TTS ${widget.row['nguoidung']['userCode']}-${widget.row['nguoidung']['fullName']} đã được thực hiện."
              },
              context);
        await httpPost(
            "/api/push/tags/depart_id/4&9",
            {
              "title": "Hệ thống thông báo",
              "message":
                  "Yêu cầu thanh lý tài chính cho TTS ${widget.row['nguoidung']['userCode']}-${widget.row['nguoidung']['fullName']} đã được thực hiện."
            },
            context);
        print('Xác nhận thanh toán thành công');
      } else {
        titleLog = 'Xác nhận thanh toán thất bại';
      }
    } else {
      titleLog = "Xác nhận thanh toán thất bại";
    }
  }

  @override
  // ignore: must_call_super
  void initState() {}

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
            Text(
              'Thanh lý tài chính',
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
      content: Container(
        width: 400,
        height: 200,
        child: ListView(children: [
          Column(children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Divider(
                thickness: 1,
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    "Lý do: ",
                    style: titleWidgetBox,
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Text(widget.row['causeType'] == 0
                      ? "Do cá nhân"
                      : "Do nghiệp đoàn"),
                )
              ],
            ),
            SizedBox(
              height: 25,
            ),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    "Mô tả: ",
                    style: titleWidgetBox,
                  ),
                ),
                Expanded(flex: 5, child: Text(widget.row['causeContent']))
              ],
            ),
            SizedBox(
              height: 25,
            ),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    "Trạng thái: ",
                    style: titleWidgetBox,
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Text(widget.row['refunded'] == 1
                      ? "Đã thanh toán"
                      : "Chưa thanh toán"),
                )
              ],
            ),
            SizedBox(
              height: 25,
            ),
            // Row(
            //   children: [
            //     Expanded(
            //         flex: 3,
            //         child: Text(
            //           'Nội dung duyệt',
            //           style: titleWidgetBox,
            //         )),
            //     Expanded(
            //         flex: 5,
            //         child: Container(
            //           // height: height,
            //           // width: MediaQuery.of(context).size.width * 0.15,
            //           child: TextField(
            //             controller: content,
            //             minLines: 2,
            //             maxLines: 2,
            //             decoration: InputDecoration(
            //               hintText: 'Nhập nội dung',
            //               // errorText: er,
            //               border: OutlineInputBorder(),
            //             ),
            //             onChanged: (value) {
            //               // if (detail.text.isEmpty) {
            //               //   er = 'Yêu cầu không được để trống';
            //               //   height = 92;
            //               // } else {
            //               //   er = null;
            //               //   height = 80;
            //               // }
            //               // setState(() {});
            //             },
            //           ),
            //         ))
            //   ],
            // )
          ]),
        ]),
      ),
      actions: [
        ElevatedButton(
          // textColor: Color(0xFF6200EE),
          onPressed: () => Navigator.pop(context),
          child: Text(widget.view ? 'Đóng' : 'Hủy'),
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
        widget.view
            ? Container()
            : ElevatedButton(
                // textColor: Color(0xFF6200EE),
                onPressed: () async {
                  await showDialog(
                      context: context,
                      builder: (BuildContext context) => XacNhan(
                          title: "Xác nhận thanh lý tài chính",
                          function: () async {
                            await updateDXL();
                            widget.function!();
                            showToast(
                              context: context,
                              msg: titleLog,
                              color:
                                  titleLog == "Xác nhận thanh toán thành công"
                                      ? Color.fromARGB(136, 72, 238, 67)
                                      : Colors.red,
                              icon: titleLog == "Xác nhận thanh toán thành công"
                                  ? Icon(Icons.done)
                                  : Icon(Icons.warning),
                            );
                            Navigator.pop(context);
                          },
                          content:
                              "Bạn có chắc chắn muốn xác nhận thanh lý tiền học cho TTS không?"));
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
      ],
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
  var listNvp;
  bool exitsta = false, exitstb = false, exitstc = false;
  getListNvp() async {
    // String query = '';
    // if (birthDate != null) {
    //   query += " and nguoidung.birthDate:'$birthDate'";
    // }
    var response = await httpGet(
        "/api/quyetdinh-xuphat-chitiet/get/page?filter=decisionId:${widget.row['id']}",
        context);
    if (response.containsKey("body")) {
      setState(() {
        listNvp = jsonDecode(response["body"])['content'];
        // print(listNvp);
      });
    }

    for (var row in listNvp) {
      if (row['dutyId'] == null) exitsta = true;
      if (row['dutyId'] != null) {
        if (row['vaitro']['level'] == 0) exitstb = true;
        if (row['vaitro']['level'] == 1) exitstc = true;
      }
    }
    return 0;
  }

  String titleLog = 'Xác nhận thu tiền thành công';
  updateQdxp() async {
    // String dateName = "$selectedValueLTT" + 'Date';
    // var realTime =
    //     DateFormat("yyyy-MM-ddTHH:mm:ss").format(DateTime.now().toLocal());

    widget.row['finesApproval'] = 1;
    widget.row['finesApprover'] =
        Provider.of<SecurityModel>(context, listen: false)
            .userLoginCurren['id'];

    var response = await httpPut(
        '/api/quyetdinh-xuphat/put/${widget.row['id']}', widget.row, context);

    if (response['body'] == 'true') {
      print('Xác nhận thu tiền thành công');
      await httpPost(
          "/api/push/tags/depart_id/4&9",
          {
            "title": "Hệ thống thông báo",
            "message":
                "Quyết định xử phạt ${widget.row['quydinh']['ruleName']} ngày ${widget.row['decisionDate'] != null ? DateFormat("dd-MM-yyyy").format(DateTime.tryParse(widget.row['decisionDate'])!) : "không xác định"} đã được thực hiện."
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
              'Xác nhận thanh lý hoặc xử phạt cho TTS',
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
              height: listNvp.isEmpty ? 200 : 450,
              child: ListView(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          exitsta
                              ? Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                                          style:
                                                              titleTableData))),
                                              DataColumn(
                                                  label: Container(
                                                      // width: 50,
                                                      child: Text('Họ và tên',
                                                          style:
                                                              titleTableData))),
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
                                                  label: Text('Tổng phạt',
                                                      style: titleTableData)),
                                            ],
                                            rows: <DataRow>[
                                              for (var row in listNvp)
                                                if (row['dutyId'] == null)
                                                  DataRow(cells: [
                                                    DataCell(
                                                      Text('${++a}',
                                                          style: bangDuLieu),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                          row['nguoidung']
                                                              ['fullName'],
                                                          style: bangDuLieu),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                          row['nguoidung'][
                                                                  'birthDate'] ??
                                                              '',
                                                          style: bangDuLieu),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                          row['nguoidung'][
                                                                      'donhang'] !=
                                                                  null
                                                              ? row['nguoidung']
                                                                      [
                                                                      'donhang']
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
                                                      Text(row['reason'] ?? "",
                                                          style: bangDuLieu),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                          moneyFormatter(row[
                                                              'finesTotal']),
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
                                    Center(
                                        child: a == 0
                                            ? Container(
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 15),
                                                child: Text(
                                                    "Không có bản ghi nào"))
                                            : Container())
                                  ],
                                )
                              : Container(),
                          exitstb
                              ? Column(
                                  children: [
                                    SizedBox(
                                      height: 25,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Danh sách cán bộ vi phạm',
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
                                                          style:
                                                              titleTableData))),
                                              DataColumn(
                                                  label: Container(
                                                      // width: 50,
                                                      child: Text(
                                                          'Họ và tên cán bộ',
                                                          style:
                                                              titleTableData))),
                                              DataColumn(
                                                  label: Text('Nội dung phạt',
                                                      style: titleTableData)),
                                              DataColumn(
                                                  label: Text('Tổng phạt',
                                                      style: titleTableData)),
                                            ],
                                            rows: <DataRow>[
                                              for (var row in listNvp)
                                                if (row['dutyId'] != null)
                                                  if (row['vaitro']['level'] ==
                                                      0)
                                                    DataRow(cells: [
                                                      DataCell(
                                                        Text('${++b}',
                                                            style: bangDuLieu),
                                                      ),
                                                      DataCell(
                                                        Text(
                                                            row['nguoidung']
                                                                ['fullName'],
                                                            style: bangDuLieu),
                                                      ),
                                                      DataCell(
                                                        Text(
                                                            row['reason'] ?? '',
                                                            style: bangDuLieu),
                                                      ),
                                                      DataCell(
                                                        Text(
                                                            moneyFormatter(row[
                                                                'finesTotal']),
                                                            style: bangDuLieu),
                                                      ),
                                                    ])
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Center(
                                        child: b == 0
                                            ? Container(
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 15),
                                                child: Text(
                                                    "Không có bản ghi nào"))
                                            : Container())
                                  ],
                                )
                              : Container(),
                          exitstc
                              ? Column(
                                  children: [
                                    SizedBox(
                                      height: 25,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Danh sách trưởng phòng vi phạm',
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
                                                          style:
                                                              titleTableData))),
                                              DataColumn(
                                                  label: Container(
                                                      // width: 50,
                                                      child: Text(
                                                          'Họ và tên cán bộ',
                                                          style:
                                                              titleTableData))),
                                              DataColumn(
                                                  label: Text('Nội dung phạt',
                                                      style: titleTableData)),
                                              DataColumn(
                                                  label: Text('Tổng phạt',
                                                      style: titleTableData)),
                                            ],
                                            rows: <DataRow>[
                                              for (var row in listNvp)
                                                if (row['dutyId'] != null)
                                                  if (row['vaitro']['level'] ==
                                                      1)
                                                    DataRow(cells: [
                                                      DataCell(
                                                        Text('${++c}',
                                                            style: bangDuLieu),
                                                      ),
                                                      DataCell(
                                                        Text(
                                                            row['nguoidung']
                                                                ['fullName'],
                                                            style: bangDuLieu),
                                                      ),
                                                      DataCell(
                                                        Text(
                                                            row['reason'] ?? "",
                                                            style: bangDuLieu),
                                                      ),
                                                      DataCell(
                                                        Text(
                                                            moneyFormatter(row[
                                                                'finesTotal']),
                                                            style: bangDuLieu),
                                                      ),
                                                    ])
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Center(
                                        child: c == 0
                                            ? Container(
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 15),
                                                child: Text(
                                                    "Không có bản ghi nào"))
                                            : Container())
                                  ],
                                )
                              : Container(),
                          listNvp.isEmpty
                              ? Center(
                                  child: Text(
                                  "Không có thông tin",
                                  style: TextStyle(fontSize: 20),
                                ))
                              : Container()
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
