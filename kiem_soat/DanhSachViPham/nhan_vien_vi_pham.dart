import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../api.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';
import '../../../../common/widgets_form.dart';

import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Border, Column, Row;
import 'package:universal_html/html.dart' show AnchorElement;
// ignore: deprecated_member_use
import 'package:universal_io/prefer_universal/io.dart';

import 'dart:async';

class NVViPham extends StatefulWidget {
  NVViPham({Key? key}) : super(key: key);

  @override
  State<NVViPham> createState() => _NVViPhamState();
}

class _NVViPhamState extends State<NVViPham> {
  String fileNameExport = "";
  Future<void> exportExcel(result) async {
    print("result : ${result}");
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];

    sheet.getRangeByName('A1:AO43').cellStyle.fontSize = 10;
    sheet.getRangeByName('A1:AO43').cellStyle.fontName = "Arial";

    sheet.getRangeByName('A1:AO43').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('A1:AO43').cellStyle.vAlign = VAlignType.center;
    sheet.getRangeByName('D6:D43').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('E6:E43').cellStyle.hAlign = HAlignType.center;

    sheet.getRangeByName('A2').setText('AAM');
    sheet.getRangeByName('A2').cellStyle.fontSize = 14;
    sheet.getRangeByName('A2').cellStyle.bold = true;

    sheet.getRangeByName('A3').setText('Danh sách nhân viên vi phạm');
    sheet.getRangeByName('A3').cellStyle.bold = true;
    sheet.getRangeByName('A3').cellStyle.fontSize = 14;
    sheet.getRangeByName('A3:G3').merge();

    //bảng dữ liệu
    sheet.getRangeByName('A1').columnWidth = 5.1;
    sheet.getRangeByName('B1:C1').columnWidth = 25;
    sheet.getRangeByName('D1').columnWidth = 30;
    sheet.getRangeByName('E1').columnWidth = 35;
    sheet.getRangeByName('F1').columnWidth = 40;
    sheet.getRangeByName('G1').columnWidth = 35;

    sheet.getRangeByName('A5').setText('STT');
    sheet.getRangeByName('B5').setText('Mã nhân viên');
    sheet.getRangeByName('C5').setText('Tên nhân viên');
    sheet.getRangeByName('D5').setText('Bộ phận');
    sheet.getRangeByName("E5").setText('Vị trí');
    sheet.getRangeByName('F5').setText('Nội dung vi phạm');
    sheet.getRangeByName('G5').setText('Ngày tháng');
    // sheet.getRangeByName('H5').setText('Số lượng TTS chờ thi tuyển');
    for (int i = 0; i < result.length; i++) {
      sheet.getRangeByIndex(6 + i, 1).setNumber(i + 1);
      sheet.getRangeByIndex(6 + i, 2).setText("${result[i]["nguoidung"]["userCode"]}");
      sheet.getRangeByIndex(6 + i, 3).setText("${result[i]["nguoidung"]["fullName"]}");
      sheet.getRangeByIndex(6 + i, 4).setText("${result[i]["nguoidung"]["phongban"]["departName"]}");
      sheet.getRangeByIndex(6 + i, 5).setText("${result[i]["vaitro"] != null ? result[i]["vaitro"]["name"] : "no data"}");
      sheet.getRangeByIndex(6 + i, 6).setText("${result[i]["quyetdinh"]["quydinh"]["ruleName"]}");
      sheet.getRangeByIndex(6 + i, 7).setText(
          "${result[i]["quyetdinh"]["decisionDate"] != null ? DateFormat('dd-MM-yyyy').format(DateTime.parse(result[i]["quyetdinh"]["decisionDate"])) : ""}");
      //sheet.getRangeByIndex(6 + i, 8).setText("${resultDSVP["content"][i]["quyetdinh"]["decisionDate"]}");
    }
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    if (kIsWeb) {
      AnchorElement(href: 'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
        ..setAttribute('download', 'Output.xlsx')
        ..click();
      fileNameExport = await uploadFile(bytes);
    } else {
      final String path = (await getApplicationSupportDirectory()).path;
      final String fileName = Platform.isWindows ? '$path\\Output.xlsx' : '$path/Output.xlsx';
      final File file = File(fileName);
      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open(fileName);

      // String fileNamePost = await uploadFile(file);
      // print("fileNamePost: $fileNamePost");
    }
  }

  String? time1;
  String? time2;
  String findSearch = "";
  final TextEditingController _nhanVien = TextEditingController();
  var totalElements = 0;
  var firstRow = 0;
  var rowPerPage = 10;
  var currentPage = 0;
  var resultDSVP = {};
  late Future futureListDSVP;
  Widget paging = Container();

  Future getListDSViPham(page, String findSearch) async {
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
      print(page);
    }
    if (page < 1) {
      page = 0;
    }
    var response;
    if (findSearch == "")
      response = await httpGet("/api/quyetdinh-xuphat-chitiet/get/page?page=$page&size=$rowPerPage&sort=id&filter=nguoidung.isAam:1", context);
    else
      response = await httpGet("/api/quyetdinh-xuphat-chitiet/get/page?page=$page&size=$rowPerPage&filter=nguoidung.isAam:1 $findSearch", context);

    if (response.containsKey("body")) {
      setState(() {
        currentPage = page;
        resultDSVP = jsonDecode(response["body"]);
        totalElements = resultDSVP["totalElements"];
      });
    }
    return resultDSVP;
  }

  @override
  void initState() {
    super.initState();
    futureListDSVP = getListDSViPham(currentPage, findSearch);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureListDSVP,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var tableIndex = (currentPage) * rowPerPage + 1;
          if (resultDSVP["content"].length > 0) {
            var firstRow = (currentPage) * rowPerPage + 1;
            var lastRow = (currentPage + 1) * rowPerPage;
            if (lastRow > resultDSVP["totalElements"]) {
              lastRow = resultDSVP["totalElements"];
            }

            paging = Row(
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
                      getListDSViPham(currentPage, findSearch);
                    });
                  },
                  items: <int>[2, 5, 10, 25, 50, 100].map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text("$value"),
                    );
                  }).toList(),
                ),
                Text("Dòng $firstRow - $lastRow của ${resultDSVP["totalElements"]}"),
                InkWell(
                    onTap: firstRow != 1
                        ? () {
                            getListDSViPham(currentPage - 1, findSearch);
                            //print(currentPage - 1);
                          }
                        : null,
                    child: (firstRow != 1)
                        ? Icon(Icons.chevron_left)
                        : Icon(
                            Icons.chevron_left,
                            color: Colors.grey,
                          )),
                InkWell(
                    onTap: lastRow < resultDSVP["totalElements"]
                        ? () {
                            getListDSViPham(currentPage + 1, findSearch);
                            //print(currentPage + 1);
                          }
                        : null,
                    child: (lastRow < resultDSVP["totalElements"])
                        ? Icon(Icons.chevron_right)
                        : Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                          )),
              ],
            );
          }

          return ListView(
            controller: ScrollController(),
            // mainAxisAlignment: MainAxisAlignment.start,
            children: [
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
                          padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Container(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text('Nhân viên', style: titleWidgetBox),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Container(
                                          // width: MediaQuery.of(context).size.width * 0.15,
                                          height: 40,
                                          child: TextField(
                                            controller: _nhanVien,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  width: 3,
                                                  color: Colors.black,
                                                ),
                                                borderRadius: BorderRadius.circular(0.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 100),
                              Expanded(
                                flex: 3,
                                child: Container(),
                              ),
                              Expanded(flex: 2, child: Container()),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20, left: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RichText(
                                text: TextSpan(
                                  text: 'Ngày vi phạm',
                                  style: titleBox,
                                  children: const <TextSpan>[
                                    TextSpan(
                                      text: '',
                                      style: TextStyle(color: Colors.red),
                                    )
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.more_horiz,
                                color: Color(0xff9aa5ce),
                                size: 14,
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(30, 20, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 30),
                                  child: DatePickerBox1(
                                      requestDayBefore: time2,
                                      isTime: false,
                                      label: Text(
                                        'Từ ngày:',
                                        style: titleWidgetBox,
                                      ),
                                      dateDisplay: time1,
                                      selectedDateFunction: (day) {
                                        time1 = day;
                                        setState(() {});
                                      }),
                                ),
                              ),
                              SizedBox(width: 100),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 30),
                                  child: DatePickerBox1(
                                      requestDayAfter: time1,
                                      isTime: false,
                                      label: Text(
                                        'Đến ngày:',
                                        style: titleWidgetBox,
                                      ),
                                      dateDisplay: time1,
                                      selectedDateFunction: (day) {
                                        time2 = day;
                                        print(day);
                                        setState(() {});
                                      }),
                                ),
                              ),
                              Expanded(flex: 2, child: Container()),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(50, 30, 20, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: 40,
                                margin: EdgeInsets.only(left: 20),
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15.0,
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
                                    findSearch = "";
                                    var nhanVien;
                                    var tuNgay;
                                    var denNgay;
                                    if (_nhanVien.text != "")
                                      nhanVien = "and nguoidung.fullName~'*${_nhanVien.text}*' ";
                                    else
                                      nhanVien = "";
                                    if (time1 != null)
                                      tuNgay = "and quyetdinh.decisionDate>'" +
                                          time1.toString().substring(8, 10) +
                                          "-" +
                                          time1.toString().substring(5, 7) +
                                          "-" +
                                          time1.toString().substring(0, 4) +
                                          "' ";
                                    else
                                      tuNgay = "";
                                    if (time2 != null)
                                      denNgay = "and quyetdinh.decisionDate<'" +
                                          time2.toString().substring(8, 10) +
                                          "-" +
                                          time2.toString().substring(5, 7) +
                                          "-" +
                                          time2.toString().substring(0, 4) +
                                          "' ";
                                    else
                                      denNgay = "";

                                    findSearch = nhanVien + tuNgay + denNgay;

                                    getListDSViPham(0, findSearch);
                                  },
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(right: 10),
                                        child: Icon(
                                          Icons.search,
                                          color: Colors.white,
                                          size: 15,
                                        ),
                                      ),
                                      Center(child: Text('Tìm kiếm', style: textButton)),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 20),
                                // width: 100,
                                height: 40,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15.0,
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
                                    var resultDSVP1;
                                    Future getListDSViPham1(fromDate, toDate) async {
                                      var response;
                                      String condition = "";
                                      if (time1 != null && time2 != "") {
                                        condition += " and estimatedInterviewDate >:'$time1'";
                                      }
                                      if (time1 != null && time2 != "") {
                                        condition += " AND estimatedInterviewDate <:'$time2'";
                                      }

                                      response = await httpGet("/api/quyetdinh-xuphat-chitiet/get/page?filter=nguoidung.isAam:1$condition", context);

                                      if (response.containsKey("body")) {
                                        setState(() {
                                          resultDSVP1 = jsonDecode(response["body"])['content'];
                                          print("quang:$resultDSVP1");
                                          //totalElements = resultDSVP1["totalElements"];
                                        });
                                      }
                                      return resultDSVP1;
                                    }

                                    await getListDSViPham1(time1, time2);
                                    await exportExcel(resultDSVP1);
                                  },
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: 10),
                                        child: Icon(Icons.file_open_sharp, color: Colors.white, size: 15),
                                      ),
                                      Center(child: Text('Xuất file', style: textButton)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
              Container(
                color: backgroundPage,
                padding: EdgeInsets.symmetric(vertical: verticalPaddingPage, horizontal: horizontalPaddingPage),
                child: Container(
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
                            'Bảng thông tin',
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
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                //flex: 20,
                                child: DataTable(
                                  //columnSpacing:160,
                                  columns: <DataColumn>[
                                    DataColumn(label: Text("STT", style: titleTableData)),
                                    DataColumn(label: Text("Mã nhân viên", style: titleTableData)),
                                    DataColumn(label: Text("Tên nhân viên", style: titleTableData)),
                                    DataColumn(label: Text("Bộ phận", style: titleTableData)),
                                    DataColumn(label: Text("Vị trí ", style: titleTableData)),
                                    DataColumn(label: Text("Nội dung \nvi phạm", style: titleTableData)),
                                    DataColumn(label: Text("Ngày tháng", style: titleTableData)),
                                  ],
                                  rows: <DataRow>[
                                    for (int i = 0; i < resultDSVP["content"].length; i++)
                                      DataRow(cells: [
                                        DataCell(Container(
                                            width: (MediaQuery.of(context).size.width / 10) * 0.15, child: Text("${tableIndex + i}", style: bangDuLieu))),
                                        DataCell(Container(
                                            width: (MediaQuery.of(context).size.width / 10) * 0.65,
                                            child: Text(resultDSVP["content"][i]["nguoidung"]["userCode"] ?? "", style: bangDuLieu))),
                                        DataCell(Container(
                                            width: (MediaQuery.of(context).size.width / 10) * 0.65,
                                            child: Text(resultDSVP["content"][i]["nguoidung"]["fullName"] ?? "", style: bangDuLieu))),
                                        DataCell(Container(
                                            width: (MediaQuery.of(context).size.width / 10) * 0.65,
                                            child: Text(resultDSVP["content"][i]["nguoidung"]["phongban"]["departName"] ?? "", style: bangDuLieu))),
                                        DataCell(Container(
                                            width: (MediaQuery.of(context).size.width / 10) * 0.45,
                                            child: Text(
                                              (resultDSVP["content"][i]["vaitro"] != null)?resultDSVP["content"][i]["vaitro"]["name"] ?? "": "", style: bangDuLieu))),
                                        DataCell(Container(
                                            width: (MediaQuery.of(context).size.width / 10) * 0.65,
                                            child: Text(resultDSVP["content"][i]["quyetdinh"]["quydinh"]["ruleName"] ?? "", style: bangDuLieu))),
                                        DataCell(Text(
                                            (resultDSVP["content"][i]["quyetdinh"] != null && resultDSVP["content"][i]["quyetdinh"]["decisionDate"] != null)
                                                ? DateFormat('dd/MM/yyyy').format(DateTime.parse(resultDSVP["content"][i]["quyetdinh"]["decisionDate"]))
                                                : "",
                                            style: bangDuLieu)),

                                        //
                                      ])
                                  ],
                                ),
                              ),
                              //Expanded(child: Container(), flex: 1)
                            ],
                          ),
                        ],
                      ),
                      if (totalElements != 0)
                        paging
                      else
                        Center(
                            child: Text("Không có kết quả phù hợp",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ))),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 30, left: 30, right: 30),
                width: MediaQuery.of(context).size.width * 1,
                decoration: BoxDecoration(
                  color: colorWhite,
                  boxShadow: [boxShadowContainer],
                  border: Border(
                    bottom: borderTitledPage,
                  ),
                ),
                padding: paddingTitledPage,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('no copyright'),
                  ],
                ),
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
