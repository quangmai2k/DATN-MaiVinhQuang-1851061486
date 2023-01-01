import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/format_date.dart';
import 'package:gentelella_flutter/model/market_development/order.dart';
import 'package:gentelella_flutter/widgets/ui/navigation.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:universal_io/prefer_universal/io.dart';
import '../../../../api.dart';
import '../../../../common/dynamic_table.dart';

import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Border, Column, Row;
import 'package:universal_html/html.dart' show AnchorElement;
import "package:collection/collection.dart";
import '../../../../common/style.dart';
import '../../../../model/model.dart';
import 'dart:async';

import '../../../common/widgets_form.dart';
import '../../utils/market_development.dart';

class BaoCaoTienDoThiTuyen extends StatefulWidget {
  const BaoCaoTienDoThiTuyen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BaoCaoTienDoThiTuyenState();
  }
}

class _BaoCaoTienDoThiTuyenState extends State<BaoCaoTienDoThiTuyen> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: BaoCaoTienDoThiTuyenBody());
  }
}

class BaoCaoTienDoThiTuyenBody extends StatefulWidget {
  const BaoCaoTienDoThiTuyenBody({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BaoCaoTienDoThiTuyenBodyState();
  }
}

class _BaoCaoTienDoThiTuyenBodyState extends State<BaoCaoTienDoThiTuyenBody> {
  var body = {};
  var page = 1;
  var rowPerPage = 10;
  var totalElements = 0;
  var firstRow = 1, lastRow = 0;
  var rowCount = 0;
  var currentPage = 1;
  bool _setLoading = false;
  late Future<List<Order>> _futureOrders;
  List<Order> listOrder = [];

  TextEditingController unionController = TextEditingController();
  String? dateFrom;
  String? dateTo;
  DateTime? estimatedInterviewDate;

// Xuất file excel
  String fileNameExport = "";
  Future<void> exportExcel(List<Order> order) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];

    sheet.getRangeByName('A1:AO999').cellStyle.fontSize = 10;
    sheet.getRangeByName('A1:AO999').cellStyle.fontName = "Arial";

    sheet.getRangeByName('A1:AO999').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('A1:AO999').cellStyle.vAlign = VAlignType.center;
    sheet.getRangeByName('C6:C999').cellStyle.hAlign = HAlignType.left;
    sheet.getRangeByName('D6:D999').cellStyle.hAlign = HAlignType.left;
    sheet.getRangeByName('E6:E999').cellStyle.hAlign = HAlignType.left;

    sheet.getRangeByName('A2').setText('AAM');
    sheet.getRangeByName('A2').cellStyle.fontSize = 14;
    sheet.getRangeByName('A2').cellStyle.bold = true;

    sheet.getRangeByName('A3').setText('BÁO CÁO TIẾN ĐỘ THI TUYỂN');
    sheet.getRangeByName('A3').cellStyle.bold = true;
    sheet.getRangeByName('A3').cellStyle.fontSize = 14;
    sheet.getRangeByName('A3:G3').merge();

    //bảng dữ liệu
    sheet.getRangeByName('A1').columnWidth = 5.1;
    sheet.getRangeByName('B1:C1').columnWidth = 25;
    sheet.getRangeByName('D1').columnWidth = 50;
    sheet.getRangeByName('E1').columnWidth = 70;
    sheet.getRangeByName('F1:H1').columnWidth = 25;

    sheet.getRangeByName('A5:H5').cellStyle.bold = true;
    sheet.getRangeByName('A5').setText('STT');
    sheet.getRangeByName('B5').setText('Mã đơn hàng');
    sheet.getRangeByName('C5').setText('Tên đơn hàng');
    sheet.getRangeByName('D5').setText('Nghiệp đoàn');
    sheet.getRangeByName("E5").setText('Xí nghiệp');
    sheet.getRangeByName('F5').setText('Ngày dự kiến thi tuyển');
    sheet.getRangeByName('G5').setText('Số lượng TTS thi tuyển');
    sheet.getRangeByName('H5').setText('Số lượng TTS đã tiến cử');
    sheet.getRangeByName('I5').setText('Số lượng TTS chờ thi tuyển');
    for (int i = 0; i < order.length; i++) {
      sheet.getRangeByIndex(6 + i, 1).setNumber(i + 1);
      sheet.getRangeByIndex(6 + i, 2).setText("${order[i].orderCode}");
      sheet.getRangeByIndex(6 + i, 3).setText("${order[i].orderName}");
      sheet.getRangeByIndex(6 + i, 4).setText("${order[i].union}");
      sheet.getRangeByIndex(6 + i, 5).setText("${order[i].enterprise}");
      (order[i].estimatedInterviewDate == null)
          ? sheet.getRangeByIndex(6 + i, 6).setText(" ")
          : sheet.getRangeByIndex(6 + i, 6).setText("${order[i].estimatedInterviewDate}");
      sheet.getRangeByIndex(6 + i, 8).setText("${(listCountTraine1[listOrder[i].id] != null) ? listCountTraine1[listOrder[i].id] : ""}");
      sheet.getRangeByIndex(6 + i, 7).setText("${order[i].ttsRequired}");
      sheet.getRangeByIndex(6 + i, 9).setText("${(listCountTraine[listOrder[i].id] != null) ? listCountTraine[listOrder[i].id] : ""}");
    }
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    if (kIsWeb) {
      AnchorElement(href: 'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
        ..setAttribute('download', 'Báo cáo tiến độ thi tuyển.xlsx')
        ..click();
      fileNameExport = await uploadFile(bytes);
    } else {
      final String path = (await getApplicationSupportDirectory()).path;
      final String fileName = Platform.isWindows ? '$path\\Output.xlsx' : '$path/Output.xlsx';
      final File file = File(fileName);
      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open(fileName);

      String fileNamePost = await uploadFile(file);
      print("fileNamePost: $fileNamePost");
    }
  }

  Future<List<Order>> getListOrder(page, {dateTo, dateFrom}) async {
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }
    if (page < 1) {
      page = 0;
    }
    var response;
    String condition = "";

    if (dateFrom != null && dateFrom != "") {
      condition += "estimatedInterviewDate >:'${dateFrom!}'";
    }
    if (dateTo != null && dateTo != "") {
      condition += " AND estimatedInterviewDate <:'${dateTo!}'";
    }

    response = await httpGet("/api/donhang/get/page?page=$page&size=$rowPerPage&filter=$condition", context);
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

  var resultListTrainee = [];
  var listTraineeGroupByOrder = {};
  var listOrderId = [];
  dynamic listCountTraine = {};
  getCountTrainee() async {
    var response = await httpGet("/api/nguoidung/get/page?filter=ttsStatusId:6", context);
    if (response.containsKey("body")) {
      setState(() {
        resultListTrainee = jsonDecode(response["body"])["content"];
        listTraineeGroupByOrder = groupBy(resultListTrainee, (dynamic obj) {
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
        listCountTraine[listOrderId[i]] = listTraineeGroupByOrder[listOrderId[i]].length;
      }
    }
  }

  var resultListTrainee1 = [];
  var listTraineeGroupByOrder1 = {};
  var listOrderId1 = [];
  dynamic listCountTraine1 = {};
  getCountTrainee1() async {
    var response = await httpGet("/api/nguoidung/get/page?filter=ttsStatusId:5", context);
    if (response.containsKey("body")) {
      setState(() {
        resultListTrainee1 = jsonDecode(response["body"])["content"];
        listTraineeGroupByOrder1 = groupBy(resultListTrainee1, (dynamic obj) {
          return obj['orderId'];
        });

        listTraineeGroupByOrder1.forEach((key, value) {
          if (key != null) {
            listOrderId1.add(key);
          }
        });
      });
      for (int i = 0; i < listOrderId1.length; i++) {
        listCountTraine1[listOrderId1[i]] = listTraineeGroupByOrder1[listOrderId1[i]].length;
      }
    }
    print(resultListTrainee1);
  }

  callApi() async {
    await getCountTrainee();
    await getCountTrainee1();
  }

  @override
  void initState() {
    super.initState();
    _futureOrders = getListOrder(page - 1, dateFrom: "", dateTo: "");
    callApi();
  }

  handleClickBtnSearch({dateFrom, dateTo}) {
    print("clicked");
    setState(() {
      _setLoading = true;
    });

    Future<List<Order>> _futureOrders1 = getListOrder(0, dateFrom: dateFrom, dateTo: dateTo);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _futureOrders = _futureOrders1;
        _setLoading = false;
      });
    });
  }

  int getIndex(page, rowPerPage, index) {
    return ((page * rowPerPage) + index) + 1;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: userRule('/bao-cao-tien-do-thi-tuyen', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return Consumer<NavigationModel>(
              builder: (context, navigationModel, child) => FutureBuilder<List<Order>>(
                  future: _futureOrders,
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
                          // padding: paddingTitledPage,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TitlePage(
                                listPreTitle: [
                                  {'url': '/ho-so-noi', 'title': 'Hồ sơ nội'},
                                ],
                                content: 'Báo cáo tiến độ thi tuyển',
                              ),
                            ],
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
                                    child: Column(children: [
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

                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: DatePickerBoxCustomForMarkert(
                                                  isTime: false,
                                                  title: "Từ ngày",
                                                  isBlocDate: false,
                                                  isNotFeatureDate: true,
                                                  label: Text(
                                                    'Từ ngày',
                                                    style: titleWidgetBox,
                                                  ),
                                                  dateDisplay: dateFrom,
                                                  selectedDateFunction: (day) {
                                                    setState(() {
                                                      dateFrom = day;
                                                    });
                                                  }),
                                            ),
                                            SizedBox(width: 100),
                                            Expanded(
                                              flex: 3,
                                              child: DatePickerBoxCustomForMarkert(
                                                  isTime: false,
                                                  title: "Đến ngày",
                                                  isBlocDate: false,
                                                  isNotFeatureDate: true,
                                                  label: Text(
                                                    'Đến ngày',
                                                    style: titleWidgetBox,
                                                  ),
                                                  dateDisplay: dateTo,
                                                  selectedDateFunction: (day) {
                                                    setState(() {
                                                      dateTo = day;
                                                    });
                                                  }),
                                            ),
                                            Expanded(flex: 2, child: Container()),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.fromLTRB(50, 50, 20, 0),
                                          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                            Container(
                                              margin: EdgeInsets.only(left: 20),
                                              child: TextButton(
                                                style: TextButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(
                                                    vertical: 20.0,
                                                    horizontal: 20.0,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(5.0),
                                                  ),
                                                  backgroundColor: Color.fromRGBO(245, 117, 29, 1),
                                                  primary: Theme.of(context).iconTheme.color,
                                                  textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                                ),
                                                onPressed: () {
                                                  handleClickBtnSearch(dateFrom: dateFrom, dateTo: dateTo);
                                                },
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.search, color: Colors.white, size: 15),
                                                    Text(' Tìm kiếm', style: textButton),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Container(
                                                margin: EdgeInsets.only(left: 20),
                                                child: (getRule(listRule.data, Role.Xem, context) == true)
                                                    ? TextButton(
                                                        style: TextButton.styleFrom(
                                                          padding: const EdgeInsets.symmetric(
                                                            vertical: 20.0,
                                                            horizontal: 20.0,
                                                          ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(5.0),
                                                          ),
                                                          backgroundColor: Color.fromRGBO(245, 117, 29, 1),
                                                          primary: Theme.of(context).iconTheme.color,
                                                          textStyle:
                                                              Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                                        ),
                                                        onPressed: () async {
                                                          Future<List<Order>> getListOrder1(page, {dateTo, dateFrom}) async {
                                                            var response;
                                                            String condition = "";
                                                            if (dateFrom != null && dateFrom != "") {
                                                              condition += "estimatedInterviewDate >:'${dateFrom!}'";
                                                            }
                                                            if (dateTo != null && dateTo != "") {
                                                              condition += " AND estimatedInterviewDate <:'${dateTo!}'";
                                                            }
                                                            print("/api/donhang/get/page?filter=$condition");
                                                            response = await httpGet("/api/donhang/get/page?filter=$condition", context);
                                                            var body = jsonDecode(response['body']);
                                                            var content = [];
                                                            if (response.containsKey("body")) {
                                                              setState(() {
                                                                content = body['content'];
                                                                listOrder = content.map((e) {
                                                                  return Order.fromJson(e);
                                                                }).toList();
                                                              });
                                                            }
                                                            return listOrder;
                                                          }

                                                          // await getListOrder1(page - 1, dateFrom: "", dateTo: "");
                                                          await getListOrder1(0, dateFrom: dateFrom, dateTo: dateTo);
                                                          await exportExcel(listOrder);
                                                          _futureOrders = getListOrder(page - 1, dateFrom: dateFrom, dateTo: dateTo);
                                                        },
                                                        child: Row(children: [
                                                          Icon(Icons.upload_file, color: Colors.white, size: 15),
                                                          Text('Xuất file', style: textButton),
                                                        ]))
                                                    : Container()),
                                          ])),
                                    ])),
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
                                      if (snapshot.hasData)
                                        //Start Datatable
                                        !_setLoading
                                            ? Container(
                                                width: MediaQuery.of(context).size.width * 1,
                                                child: DataTable(
                                                  dataTextStyle: const TextStyle(color: Color(0xff313131), fontSize: 14, fontWeight: FontWeight.w500),
                                                  showBottomBorder: true,
                                                  dataRowHeight: 60,
                                                  columnSpacing: 5,
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
                                                        "Ngày dự kiến"
                                                        "\nthi tuyển",
                                                        style: titleTableData,
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        'Số lượng TTS'
                                                        '\nthi tuyển',
                                                        style: titleTableData,
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        'Số lượng TTS'
                                                        '\nđã tiến cử',
                                                        style: titleTableData,
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        'Số lượng TTS'
                                                        '\nchờ thi tuyển',
                                                        style: titleTableData,
                                                      ),
                                                    ),
                                                  ],
                                                  rows: <DataRow>[
                                                    for (int i = 0; i < listOrder.length; i++)
                                                      DataRow(
                                                        cells: <DataCell>[
                                                          DataCell(Text(
                                                            getIndex(currentPage - 1, rowPerPage, i).toString(),
                                                          )),
                                                          DataCell(Text(listOrder[i].orderCode)),
                                                          DataCell(Container(
                                                              width: MediaQuery.of(context).size.width * 0.125, child: Text(listOrder[i].orderName))),
                                                          DataCell(Container(
                                                              width: MediaQuery.of(context).size.width * 0.1,
                                                              child: Text(listOrder[i].union.toString()))),
                                                          DataCell(Container(
                                                              width: MediaQuery.of(context).size.width * 0.1,
                                                              child: Text(listOrder[i].enterprise.toString()))),
                                                          DataCell((listOrder[i].estimatedInterviewDate != null)
                                                              ? Container(
                                                                  width: MediaQuery.of(context).size.width * 0.075,
                                                                  child: Text(FormatDate.formatDateView(
                                                                      DateTime.parse(listOrder[i].estimatedInterviewDate.toString()))),
                                                                )
                                                              : Text("")),
                                                          DataCell(Container(
                                                              margin: EdgeInsets.only(left: 25),
                                                              width: MediaQuery.of(context).size.width * 0.025,
                                                              child: Text(listOrder[i].ttsRequired.toString()))),
                                                          DataCell(Container(
                                                              margin: EdgeInsets.only(left: 25),
                                                              width: MediaQuery.of(context).size.width * 0.025,
                                                              child: (listCountTraine1[listOrder[i].id] != null)
                                                                  ? Text(listCountTraine1[listOrder[i].id].toString())
                                                                  : Text(" "))),
                                                          DataCell(Container(
                                                              margin: EdgeInsets.only(left: 25),
                                                              width: MediaQuery.of(context).size.width * 0.025,
                                                              child: (listCountTraine[listOrder[i].id] != null)
                                                                  ? Text(listCountTraine[listOrder[i].id].toString())
                                                                  : Text(" "))),
                                                        ],
                                                      ),
                                                  ],
                                                ))
                                            : Center(
                                                child: CircularProgressIndicator(),
                                              )
                                      else if (snapshot.hasError)
                                        Text("Fail! ${snapshot.error}")
                                      else if (!snapshot.hasData)
                                        Center(
                                          child: Center(child: CircularProgressIndicator()),
                                        ),
                                      Container(
                                        // margin: const EdgeInsets.only(right: 50),
                                        child: DynamicTablePagging(
                                          rowCount,
                                          currentPage,
                                          rowPerPage,
                                          pageChangeHandler: (page) {
                                            setState(() {
                                              getListOrder(page - 1, dateFrom: dateFrom, dateTo: dateTo);
                                              currentPage = page - 1;
                                            });
                                          },
                                          rowPerPageChangeHandler: (rowPerPage) {
                                            setState(() {
                                              this.rowPerPage = rowPerPage!;

                                              getListOrder(page - 1, dateFrom: dateFrom, dateTo: dateTo);
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )),
                        Footer(marginFooter: EdgeInsets.only(top: 25), paddingFooter: EdgeInsets.all(15))
                      ],
                    );
                  }));
        } else if (listRule.hasError) {
          return Text('${listRule.error}');
        }

        // By default, show a loading spinner.
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
