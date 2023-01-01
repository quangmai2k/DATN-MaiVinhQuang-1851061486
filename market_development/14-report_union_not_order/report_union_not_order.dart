import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gentelella_flutter/api.dart';
import 'package:gentelella_flutter/common/style.dart';
import 'package:gentelella_flutter/common/toast.dart';
import 'package:gentelella_flutter/common/widgets_form.dart';
import 'package:gentelella_flutter/model/model.dart';
import 'package:gentelella_flutter/widgets/ui/navigation.dart';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:open_file/open_file.dart';
import 'package:universal_html/html.dart' as html;
// import '../../../api.dart';
// import '../../../common/widgets_form.dart';
// import '../../../model/model.dart';
// import '../../../common/style.dart';
// import '../../../model/type.dart';

Color borderBlack = Colors.black54;

class ReportUnionNotOrder extends StatelessWidget {
  const ReportUnionNotOrder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: ReportUnionNotOrderBody());
  }
}

class ReportUnionNotOrderBody extends StatefulWidget {
  const ReportUnionNotOrderBody({Key? key}) : super(key: key);

  @override
  State<ReportUnionNotOrderBody> createState() => _ReportUnionNotOrderBodyState();
}

class _ReportUnionNotOrderBodyState extends State<ReportUnionNotOrderBody> {
  //url trang them moi cap nhat quan lys thong tin tts
  final String urlAddNewUpdateSI = "quan-ly-thong-tin-thuc-tap-sinh/add-new-update";
//------------------------------------------------
  bool checkSelected = false;
  late Future<dynamic> futurelistOrg;

  late List listSelectedRow;
  List<dynamic> idSelectedList = [];
  Widget paging = Container();
  List<bool> _selectedDataRow = [];

  String condition = ""; //Tình trạng
  var totalElements = 0;
  var rowPerPage = 5;
  var listOrg; //Danh sách thực tập sinh
  var currentPage = 1;
  var page;
  var rowCount = 0;
  var lastRow = 0;

//seachAndPageChange
  var searchRequest = "";
  var resultList = [];
  var firstRow = 1;
  var content = [];
  var now = DateTime.now();
  var fromDate;
  var toDate;
  var from;
  var to;
  int soThang = 6; // sau bao nhieu thang khong co don hang
  Future<dynamic> pageChange(page) async {
    page = page - 1;
    if ((page) * rowPerPage > rowCount) {
      page = (1.0 * rowCount / rowPerPage).ceil();
    }
    if (page <= 0) {
      page = 0;
    }
    await getStartDate();
    var response;
    if (searchRequest.isEmpty) {
      to = DateFormat('dd-MM-yyy').format(now.subtract(new Duration(days: soThang * 30)));
      response = await httpGet("/api/nghiepdoan/get/page?sort=orgCode&filter=contractSigningTime <'$to'", context);
    } else {
      response = await httpGet("/api/nghiepdoan/get/page?sort=orgCode&filter=$searchRequest", context);
    }
    var body = jsonDecode(response['body']);
    if (response.containsKey("body")) {
      listOrg = body;
      await processData();
      setState(() {
        content = listOrg['content'];
        rowCount = listOrg["content"].length;
        totalElements = listOrg["content"].length;
        _selectedDataRow = List<bool>.generate(content.length, (int index) => false);
      });
      idSelectedList.clear();
      return body;
    } else {
      throw Exception("failse");
    }
  }

  //---------------------------------
  //-----------------------------------------
  getStartDate() {
    if (toDate == null) {
      // from = DateFormat('dd-MM-yyyy').format(DateTime(1000, 1, 1));
      to = DateFormat('dd-MM-yyy').format(now.subtract(new Duration(days: soThang * 30)));
    } else {
      to = DateFormat('dd-MM-yyyy').format(DateFormat('dd-MM-yyyy').parse(toDate).subtract(new Duration(days: soThang * 30)));
    }
    if (fromDate == null) {
      from = DateFormat('dd-MM-yyyy').format(DateTime(1000, 1, 1));
    } else {
      from = DateFormat('dd-MM-yyyy').format(DateFormat('dd-MM-yyyy').parse(fromDate).subtract(new Duration(days: soThang * 30)));
    }
  }

  Future<List<int>> _readImageData(String name) async {
    final ByteData data = await rootBundle.load('assets/images/$name');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  processData() async {
    Set orgKhongTM = new Set();
    var rp = await httpGet("/api/donhang/get/page?sort=id&filter=createdDate <'$from' or createdDate >'$to'", context);
    print("/api/donhang/get/page?sort=id&filter=createdDate>'$from' and createdDate <'$to'");
    var result = jsonDecode(rp["body"]);

    for (int i = 0; i < result["totalElements"]; ++i) {
      orgKhongTM.add(result['content'][i]['nghiepdoan']['id']);
    }
    print(orgKhongTM);
    for (int i = 0; i < listOrg["content"].length; ++i) {
      for (var item in orgKhongTM) {
        if (item == listOrg["content"][i]["id"]) {
          listOrg["content"].removeAt(i);
          i--;
          break;
        }
      }
    }
    for (int i = 0; i < listOrg["content"].length; ++i) {
      print(listOrg["content"][i]["id"]);
    }
  }

  Future<void> exportFile() async {
    final xlsio.Workbook workbook = new xlsio.Workbook();
//Accessing worksheet via index.
    final xlsio.Worksheet sheet = workbook.worksheets[0];
    // Style

    final xlsio.Style style = workbook.styles.add('Style1');
    style.fontSize = 16;
    style.bold = true;
    style.hAlign = xlsio.HAlignType.center;
    final xlsio.Style header = workbook.styles.add('Style2');
    header.fontSize = 12;
    header.bold = true;
    header.hAlign = xlsio.HAlignType.center;
    final xlsio.Style stt = workbook.styles.add("style3");
    stt.hAlign = xlsio.HAlignType.center;
//Add Data
    sheet.getRangeByName('A1:AO43').cellStyle.hAlign = xlsio.HAlignType.center;
    sheet.getRangeByName('A1:AO43').cellStyle.vAlign = xlsio.VAlignType.center;
    sheet.getRangeByName('B6:E6').columnWidth = 40;
    sheet.getRangeByName('A5:E5').merge();
    sheet.getRangeByName('A6:E6').cellStyle = header;
    sheet.getRangeByName('A5').setText('Báo cáo nghiệp đoàn không có đơn hàng');
    sheet.getRangeByName('A5').cellStyle = style;
    sheet.getRangeByName('A6:A${(listOrg["content"].length + 4)}').cellStyle = stt;
    sheet.getRangeByName('A6').setText('STT');
    sheet.getRangeByName('B6').setText('Mã Nghiệp Đoàn');
    sheet.getRangeByName('C6').setText('Tên Nghiệp Đoàn');
    sheet.getRangeByName('D6').setText('Mã Người Phụ Trách');
    sheet.getRangeByName('E6').setText('Tên Người Phụ Trách');

    sheet.getRangeByName("A6").cellStyle.borders.all.lineStyle = xlsio.LineStyle.medium;
    sheet.getRangeByName("B6").cellStyle.borders.all.lineStyle = xlsio.LineStyle.medium;
    sheet.getRangeByName("C6").cellStyle.borders.all.lineStyle = xlsio.LineStyle.medium;
    sheet.getRangeByName("D6").cellStyle.borders.all.lineStyle = xlsio.LineStyle.medium;
    sheet.getRangeByName("E6").cellStyle.borders.all.lineStyle = xlsio.LineStyle.medium;
    for (int i = 0; i < listOrg["content"].length; ++i) {
      sheet.getRangeByIndex(i + 7, 1).setNumber(i + 1);
      sheet.getRangeByIndex(i + 7, 2).setText(listOrg['content'][i]['orgCode']);
      sheet.getRangeByIndex(i + 7, 3).setText(listOrg['content'][i]['orgName']);
      sheet.getRangeByIndex(i + 7, 4).setText(listOrg["content"][i]["nguoixuly"]["userCode"]);
      sheet.getRangeByIndex(i + 7, 5).setText(listOrg["content"][i]["nguoixuly"]["fullName"]);

      sheet.getRangeByIndex(i + 7, 1).cellStyle.borders.all.lineStyle = xlsio.LineStyle.medium;
      sheet.getRangeByIndex(7 + i, 2).cellStyle.borders.all.lineStyle = xlsio.LineStyle.medium;
      sheet.getRangeByIndex(7 + i, 3).cellStyle.borders.all.lineStyle = xlsio.LineStyle.medium;
      sheet.getRangeByIndex(7 + i, 4).cellStyle.borders.all.lineStyle = xlsio.LineStyle.medium;
      sheet.getRangeByIndex(7 + i, 5).cellStyle.borders.all.lineStyle = xlsio.LineStyle.medium;
    }

    final String image = base64.encode(await _readImageData('logoAAM.png'));
    sheet.pictures.addBase64(1, 1, image);
// Save the document.
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();
    if (kIsWeb) {
      html.AnchorElement(href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}")
        ..setAttribute('download', 'bao-cao-nghiep-doan-khong-co-don-hang.xlsx')
        ..click();
    } else {
      final String path = (await getApplicationSupportDirectory()).path;
      final String fileName = Platform.isWindows ? '$path\\bao-cao-nghiep-doan-khong-co-don-hang.xlsx' : '$path/bao-cao-nghiep-doan-khong-co-don-hang.xlsx';
      final File file = File(fileName);
      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open(fileName);
    }
  }

  //----------------------------------------
  @override
  void initState() {
    futurelistOrg = pageChange(0);
    super.initState();
  }

  //-------------url Breadcrumbs-----------------
  final String dashboard = '/thong-tin-nguon';
  //---Hết phần url
  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationModel>(
      builder: (context, navigationModel, child) => ListView(
        children: [
          //---------- Breadcrumbs----------------
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
                {'url': '/bao-cao-cac-nghiep-doan-khong-co-don-hang', 'title': 'Báo cáo nghiệp đoàn không có đơn hàng'}
              ],
              content: 'Báo cáo nghiệp đoàn không có đơn hàng',
            ),
          ),
          //----------end Breadcrumbs----------------
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
                              flex: 3,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      margin: EdgeInsets.only(bottom: 30),
                                      child: DatePickerBoxVQ(
                                          isTime: false,
                                          label: Text(
                                            'Từ ngày',
                                            style: titleWidgetBox,
                                          ),
                                          dateDisplay: fromDate,
                                          selectedDateFunction: (day) {
                                            setState(() {
                                              fromDate = day;
                                            });
                                          }),
                                    ),
                                  ),
                                ],
                              )),
                          SizedBox(width: 100),
                          Expanded(
                            flex: 3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 30),
                                    child: DatePickerBoxVQ(
                                        isTime: false,
                                        label: Text(
                                          'Đến ngày',
                                          style: titleWidgetBox,
                                        ),
                                        dateDisplay: toDate,
                                        selectedDateFunction: (day) {
                                          setState(() {
                                            toDate = day;
                                          });
                                        }),
                                  ),
                                ),
                              ],
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
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  backgroundColor: Color.fromRGBO(245, 117, 29, 1),
                                  primary: Theme.of(context).iconTheme.color,
                                  textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                ),
                                onPressed: () async {
                                  onLoading(context);
                                  getStartDate();
                                  await Future.delayed(Duration(milliseconds: 500));
                                  Navigator.of(context).pop(true);
                                  if (!DateFormat('dd-MM-yyyy').parse(from).isBefore(DateFormat('dd-MM-yyyy').parse(to))) {
                                    showToast(context: context, msg: "Từ ngày phải nhỏ hơn Đến ngày !", color: Colors.redAccent, icon: Icon(Icons.error));
                                    return;
                                  }
                                  // print(from + " " + to);
                                  searchRequest = "contractSigningTime < '$to'";
                                  setState(() {
                                    currentPage = 1;
                                    futurelistOrg = pageChange(currentPage);
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
                            Container(
                              margin: marginLeftBtn,
                              child: TextButton.icon(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: borderRadiusBtn,
                                  ),
                                  backgroundColor: backgroundColorBtn,
                                  primary: Theme.of(context).iconTheme.color,
                                  textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                ),
                                onPressed: () async {
                                  print("Xuất file");
                                  await exportFile();
                                  onLoading(context);
                                  await Future.delayed(Duration(milliseconds: 500));
                                  Navigator.of(context).pop(true);
                                  // navigationModel.add(pageUrl: urlAddNewUpdateSI);
                                },
                                icon: Transform.rotate(
                                  angle: 270,
                                  child: Icon(
                                    Icons.file_open_sharp,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),
                                label: Row(
                                  children: [
                                    Text('Xuất file ', style: textButton),
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
                //--------------------Bảng thông tin thực tập sinh-------------------
                FutureBuilder(
                  future: futurelistOrg,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (listOrg["content"].length == 0) {
                        paging = Text("Không có kết quả phù hợp");
                      } else if (listOrg["content"].length > 0) {
                        var firstRow = (currentPage - 1) * rowPerPage + 1;
                        var lastRow = (currentPage) * rowPerPage;
                        if (lastRow > listOrg["content"].length) {
                          lastRow = listOrg["content"].length;
                        }
                        paging = Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            children: [
                              Expanded(flex: 1, child: Container()),
                              const Text("Số dòng trên trang: "),
                              DropdownButton<int>(
                                value: rowPerPage,
                                icon: const Icon(Icons.keyboard_arrow_down),
                                elevation: 16,
                                style: const TextStyle(color: Colors.deepPurple),
                                underline: Container(
                                  height: 2,
                                  color: Colors.deepPurpleAccent,
                                ),
                                onChanged: (int? newValue) {
                                  setState(() {
                                    rowPerPage = newValue!;
                                    futurelistOrg = pageChange(1);
                                  });
                                },
                                items: <int>[5, 10, 25, 50, 100].map<DropdownMenuItem<int>>((int value) {
                                  return DropdownMenuItem<int>(
                                    value: value,
                                    child: Text("$value"),
                                  );
                                }).toList(),
                              ),
                              Text("Dòng $firstRow - $lastRow của ${listOrg["content"].length}"),
                              IconButton(
                                  onPressed: currentPage != 1
                                      ? () {
                                          setState(() {
                                            currentPage--;
                                            futurelistOrg = pageChange(currentPage);
                                          });
                                        }
                                      : null,
                                  icon: const Icon(Icons.chevron_left)),
                              IconButton(
                                  onPressed: lastRow < listOrg["content"].length
                                      ? () {
                                          setState(() {
                                            currentPage++;
                                            futurelistOrg = pageChange(currentPage);
                                          });
                                        }
                                      : null,
                                  icon: const Icon(Icons.chevron_right)),
                            ],
                          ),
                        );
                      }
                      return Container(
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
                                  'Danh sách nghiệp đoàn',
                                  style: titleBox,
                                ),
                                Text(
                                  'Kết quả tìm kiếm: $rowCount',
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
                            Container(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: DataTable(
                                          showCheckboxColumn: false,
                                          columnSpacing: 20,
                                          horizontalMargin: 10,
                                          dataRowHeight: 60,
                                          columns: [
                                            DataColumn(label: Text('STT', style: titleTableData)),
                                            DataColumn(label: Text('Mã nghiệp đoàn', style: titleTableData)),
                                            DataColumn(label: Text('Tên nghiệp đoàn', style: titleTableData)),
                                            DataColumn(label: Text('Người phụ trách', style: titleTableData)),
                                          ],
                                          rows: <DataRow>[
                                            for (int i = rowPerPage * (currentPage - 1); i < listOrg["content"].length && i < rowPerPage * (currentPage); i++)
                                              DataRow(
                                                cells: <DataCell>[
                                                  DataCell(Text("${i + 1}")),
                                                  DataCell(
                                                    Text(listOrg["content"][i]["orgCode"] ?? "no data", style: bangDuLieu),
                                                  ),
                                                  DataCell(
                                                    Row(
                                                      children: [
                                                        Text(listOrg["content"][i]["orgName"].toString(), style: bangDuLieu),
                                                      ],
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Row(
                                                      children: [
                                                        Text(
                                                            listOrg["content"][i]["nguoixuly"]["fullName"].toString() + " (" + listOrg["content"][i]["nguoixuly"]["userCode"] + ")",
                                                            style: bangDuLieu),

                                                        // Text(listOrg["content"][i]["fullName"].toString(), style: bangDuLieu),
                                                      ],
                                                    ),
                                                  ),

                                                  //
                                                ],
                                                //-----------------------
                                                selected: _selectedDataRow[i],
                                                onSelectChanged: (bool? selected) {},
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  paging,
                                ],
                              ),
                            ),
                            Footer()
                          ],
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
                Footer(paddingFooter: paddingBoxContainer, marginFooter: EdgeInsets.only(top: 30)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
