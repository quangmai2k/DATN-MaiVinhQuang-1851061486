// ignore_for_file: unused_local_variable, unnecessary_brace_in_string_interps, deprecated_member_use, unrelated_type_equality_checks, unused_field
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../../../api.dart';
import '../../../common/style.dart';
import '../../../common/widgets_form.dart';
import '../../forms/nhan_su/setting-data/depart.dart';
import '../../forms/nhan_su/setting-data/userAAM.dart';
import '../navigation.dart';
import 'package:universal_html/html.dart' show AnchorElement;
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;
import 'package:universal_io/io.dart';
import "package:collection/collection.dart";

class ChiTieuTuyenDung extends StatefulWidget {
  const ChiTieuTuyenDung({Key? key}) : super(key: key);

  @override
  _ChiTieuTuyenDungState createState() => _ChiTieuTuyenDungState();
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ChiTieuTuyenDungState extends State<ChiTieuTuyenDung> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: ChiTieuTuyenDungBody());
  }
}

class ChiTieuTuyenDungBody extends StatefulWidget {
  const ChiTieuTuyenDungBody({Key? key}) : super(key: key);
  @override
  State<ChiTieuTuyenDungBody> createState() => _ChiTieuTuyenDungBodyState();
}

class _ChiTieuTuyenDungBodyState extends State<ChiTieuTuyenDungBody> {
  String findCTTD = "";
  var listInterViews = {};
  //listInterViews['nhân viên tuyển dụng']=['title' 0,'phong ban' 1,'vi tri' 2, SL cần 3, Số lượng đã tuyển 4, Số cuộc PV 5]
  getLPV(String findCTTD) async {
    listInterViews = {};
    print(findCTTD);
    var listInterViewsFirst = {};
    var response5;
    if (findCTTD == "")
      response5 = await httpGet("/api/tuyendung-phongvan/get/page?sort=interviewTime&filter=status:1", context);
    else
      response5 = await httpGet("/api/tuyendung-phongvan/get/page?sort=interviewTime&filter=status:1 and $findCTTD", context);
    var content = [];

    if (response5.containsKey("body")) {
      setState(() {
        var resultLPV = jsonDecode(response5["body"]);
        content = resultLPV['content'];
        if (content.length > 0) {
          listInterViewsFirst = groupBy(content, (dynamic obj) {
            return obj['recruitmentUser'];
          });
          var listInterViewsSort = {};
          for (var element in listInterViewsFirst.keys) {
            listInterViews[element] = [];
            listInterViewsSort = groupBy(listInterViewsFirst[element], (dynamic obj) {
              return obj['tuyendung']['title'];
            });
            for (var element1 in listInterViewsSort.keys) {
              String title = element1;
              String phongBan = listInterViewsSort[element1].first['tuyendungChitiet']['phongban']['departName'];
              String viTRi = listInterViewsSort[element1].first['tuyendungChitiet']['vaitro']['name'];
              int slCan = listInterViewsSort[element1].first['qty'];
              int slTrung = 0;
              int slPv = listInterViewsSort[element1].length;
              for (var item in listInterViewsSort[element1]) {
                if (item['qtyRecruited'] != null) slTrung += item['qtyRecruited'] as int;
              }
              listInterViews[element].add([title, phongBan, viTRi, slCan, slTrung, slPv]);
            }
          }
        }
      });
    }
  }

  List<Depart>? resultPhongBan;
  int? selectedBP;
  Future<List<Depart>> getPhongBan() async {
    var response1 = await httpGet("/api/phongban/get/page?sort=id,asc&filter=parentId:0 and id>2 and deleted:false", context);
    var body = jsonDecode(response1['body']);
    var content = [];
    if (response1.containsKey("body")) {
      setState(() {
        content = body['content'];
        resultPhongBan = content.map((e) {
          return Depart.fromJson(e);
        }).toList();
      });
    }
    Depart all = new Depart(id: -1, departName: "Tất cả");
    resultPhongBan?.insert(0, all);
    return content.map((e) {
      return Depart.fromJson(e);
    }).toList();
  }

  Future<UserAAM> getUser(int id) async {
    UserAAM user = UserAAM();
    var response1 = await httpGet("/api/nguoidung/get/profile?filter=id:$id", context);
    if (response1.containsKey("body")) {
      var body = jsonDecode(response1['body']);
      setState(() {
        user = UserAAM(
          id: body['id'],
          userCode: (body['userCode']) ?? "",
          fullName: (body['fullName']) ?? "",
        );
      });
    }
    return user;
  }

//xuất file excel
  Future<void> createExcel(var listInterViews, var listUser) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    sheet.getRangeByName('A1:AO43').cellStyle.fontSize = 10;
    sheet.getRangeByName('A1:AO43').cellStyle.fontName = "Arial";
    sheet.getRangeByName('A1:AO43').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('A1:AO43').cellStyle.vAlign = VAlignType.center;
    sheet.getRangeByName('A2').setText('AAM');
    sheet.getRangeByName('A2').cellStyle.fontSize = 14;
    sheet.getRangeByName('A2').cellStyle.bold = true;
    sheet.getRangeByName('B1').columnWidth = 35;
    sheet.getRangeByName('C1').columnWidth = 35;
    sheet.getRangeByName('D1').columnWidth = 30;
    sheet.getRangeByName('E1').columnWidth = 25;
    sheet.getRangeByName('F1').columnWidth = 20;
    sheet.getRangeByName('G1').columnWidth = 20;
    sheet.getRangeByName('H1').columnWidth = 20;
    sheet.getRangeByName('A3:I3').merge();
    if (selectedDateBegin != null)
      sheet.getRangeByName('A3').setText('BẢNG BÁO CÁO CHỈ TIÊU TUYỂN DỤNG ${DateFormat("MM/yyyy").format(selectedDateBegin!)}');
    else
      sheet.getRangeByName('A3').setText('BẢNG BÁO CÁO CHỈ TIÊU TUYỂN DỤNG');
    sheet.getRangeByName('A3').cellStyle.bold = true;
    sheet.getRangeByName('A3').cellStyle.fontSize = 14;

    sheet.getRangeByName('A5').setText('STT');
    sheet.getRangeByName('B5').setText('Nhân viên tuyển dụng');
    sheet.getRangeByName('C5').setText('Tiêu đề');
    sheet.getRangeByName('D5').setText('Phòng ban');
    sheet.getRangeByName('E5').setText('Vị trí');
    sheet.getRangeByName('F5').setText('Số lượng cần tuyển');
    sheet.getRangeByName('G5').setText('Số lượng trúng tuyển');
    sheet.getRangeByName('H5').setText('Số cuộc phỏng vấn');
    sheet.getRangeByName('A5:H5').cellStyle.bold = true;
    int index = -1;
    for (var i = 0; i < listInterViews.keys.length; i++) {
      for (var j = 0; j <= listInterViews[listInterViews.keys.toList()[i]].length; j++) {
        index += 1;
        if (j < listInterViews[listInterViews.keys.toList()[i]].length) {
          // print("aaaaaaaaaaaa:${}");
          if (j == 0) sheet.getRangeByIndex(6 + index, 1).setNumber(i + 1);
          if (j == 0) sheet.getRangeByIndex(6 + index, 2).setText("${listUser[i][0]} (${listUser[i][1]})");
          sheet.getRangeByIndex(6 + index, 3).setText("${listInterViews[listInterViews.keys.toList()[i]][j][0]}");
          sheet.getRangeByIndex(6 + index, 4).setText("${listInterViews[listInterViews.keys.toList()[i]][j][1]}");
          sheet.getRangeByIndex(6 + index, 5).setText("${listInterViews[listInterViews.keys.toList()[i]][j][2]}");
          sheet.getRangeByIndex(6 + index, 6).setNumber(listInterViews[listInterViews.keys.toList()[i]][j][3]);
          sheet.getRangeByIndex(6 + index, 7).setNumber(listInterViews[listInterViews.keys.toList()[i]][j][4]);
          sheet.getRangeByIndex(6 + index, 8).setNumber(listInterViews[listInterViews.keys.toList()[i]][j][5]);
        } else {
          sheet.getRangeByIndex(6 + index, 6).setText("Tổng:");
          sheet.getRangeByIndex(6 + index, 7).setNumber(listUser[i][2]);
          sheet.getRangeByIndex(6 + index, 8).setNumber(listUser[i][3]);
          sheet.getRangeByIndex(6 + index, 6, 6 + index, 8).cellStyle.bold = true;
        }
      }
    }
    sheet.getRangeByIndex(5, 1, 6 + index, 8).cellStyle.borders.all.lineStyle = LineStyle.thin;

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();
    if (kIsWeb) {
      AnchorElement(href: 'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
        ..setAttribute('download', 'BaoCaoChiTieuTuyenDung.xlsx')
        ..click();
      setState(() {});
    } else {
      final String path = (await getApplicationSupportDirectory()).path;
      final String fileName = Platform.isWindows ? '$path\\Output.xlsx' : '$path/Output.xlsx';
      final File file = File(fileName);
      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open(fileName);
    }
  }

  var listUser = [];
  bool status = false;
  DateTime? selectedDateBegin = DateTime.now().toLocal();
  void callAPI(selectedDateBegin, them) async {
    setState(() {
      status = false;
    });
    timecheckMonth = selectedDateBegin.month;
    timecheckYear = selectedDateBegin.year;
    startDay = "01-${DateFormat("MM-yyyy").format(selectedDateBegin)}";
    endDay = getDateInMonth(timecheckMonth, timecheckYear).toString() + "-${DateFormat("MM-yyyy").format(selectedDateBegin)}";
    findCTTD = "interviewTime > '${startDay}' and interviewTime < '$endDay' $them";
    await getLPV(findCTTD);
    listUser = [];
    for (var element in listInterViews.keys) {
      UserAAM user = await getUser(element);
      int slTrung = 0;
      int slPv = 0;
      for (var item in listInterViews[element]) {
        slTrung += item[4] as int;
        slPv += item[5] as int;
      }
      listUser.add([user.fullName, user.userCode, slTrung, slPv]);
    }
    setState(() {
      status = true;
    });
  }

  late int timecheckMonth;
  late int timecheckYear;
  late String startDay;
  late String endDay;
  @override
  void initState() {
    super.initState();
    callAPI(selectedDateBegin, "");
  }

  int getDateInMonth(int month, int year) {
    int dateOfMonth = 30;
    if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
      dateOfMonth = 31;
    } else if (month == 2) {
      dateOfMonth = 28;
      if (year / 4 == 0) {
        dateOfMonth = 29;
      }
    }
    return dateOfMonth;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: userRule('/chi-tieu-tuyen-dung', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return ListView(
            controller: ScrollController(),
            children: [
              TitlePage(
                listPreTitle: [
                  {'url': "/nhan-su", 'title': 'Dashboard'},
                ],
                content: 'Báo cáo chỉ tiêu tuyển dụng',
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                margin: EdgeInsets.only(top: 20, left: 18, right: 18),
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
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        //  mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text('Tháng:', style: titleWidgetBox),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Container(
                                          // margin: EdgeInsets.only(bottom: 10),
                                          height: 40,
                                          padding: EdgeInsets.only(left: 10),
                                          decoration: BoxDecoration(border: Border.all(width: 0.5, color: Colors.black)),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              (selectedDateBegin != null)
                                                  ? Text(
                                                      "${DateFormat('MM-yyyy').format(selectedDateBegin!)}",
                                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                                    )
                                                  : Text(
                                                      "Chọn tháng",
                                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                                    ),
                                              SizedBox(
                                                height: 20.0,
                                              ),
                                              (selectedDateBegin == null)
                                                  ? IconButton(
                                                      // onPressed: () => _selectDate(context),
                                                      onPressed: () {
                                                        showMonthPicker(
                                                          context: context,
                                                          firstDate: DateTime(DateTime.now().year - 5, 1),
                                                          lastDate: DateTime(DateTime.now().year + 10, 12),
                                                          initialDate: DateTime.now(),
                                                          locale: Locale("vi"),
                                                        ).then((date) {
                                                          if (date != null) {
                                                            setState(() {
                                                              selectedDateBegin = date;
                                                              print(selectedDateBegin);
                                                              timecheckMonth = selectedDateBegin!.month;
                                                              timecheckYear = selectedDateBegin!.year;
                                                              startDay = "01-${DateFormat("MM-yyyy").format(selectedDateBegin!)}";
                                                              endDay = getDateInMonth(timecheckMonth, timecheckYear).toString() +
                                                                  "-${DateFormat("MM-yyyy").format(selectedDateBegin!)}";
                                                            });
                                                          }
                                                        });
                                                      },
                                                      icon: Icon(Icons.date_range),
                                                      color: Colors.blue[400],
                                                    )
                                                  : IconButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          selectedDateBegin = null;
                                                          print(selectedDateBegin.toString());
                                                        });
                                                      },
                                                      icon: Icon(Icons.close),
                                                    ),
                                            ],
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 100,
                              ),
                              Expanded(
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Row(
                                          // mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Flexible(child: Text('Phòng ban:', style: titleWidgetBox)),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                          flex: 4,
                                          child: Container(
                                            color: Colors.white,
                                            width: MediaQuery.of(context).size.width * 0.20,
                                            height: 40,
                                            child: DropdownSearch<Depart>(
                                              hint: "Tất cả",
                                              maxHeight: 350,
                                              mode: Mode.MENU,
                                              showSearchBox: true,
                                              onFind: (String? filter) => getPhongBan(),
                                              itemAsString: (Depart? u) => u!.departName,
                                              items: resultPhongBan,
                                              dropdownSearchDecoration: styleDropDown,
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedBP = value!.id;
                                                  print(selectedBP);
                                                });
                                              },
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              //tìm kiếm
                              getRule(listRule.data, Role.Xem, context)
                                  ? Container(
                                      margin: EdgeInsets.only(right: 40, top: 20),
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 20.0,
                                            horizontal: 10.0,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                          ),
                                          backgroundColor: (selectedDateBegin != null) ? colorOrange : Color.fromARGB(255, 124, 124, 124),
                                          primary: Theme.of(context).iconTheme.color,
                                          textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                        ),
                                        onPressed: (selectedDateBegin != null)
                                            ? () {
                                                var them = "";
                                                var idPhongBan = "";
                                                if (selectedBP != null && selectedBP != -1)
                                                  idPhongBan = "and tuyendungChitiet.departId:$selectedBP ";
                                                else
                                                  idPhongBan = "";
                                                them = idPhongBan;

                                                callAPI(selectedDateBegin, them);
                                              }
                                            : null,
                                        child: Row(
                                          children: [
                                            Icon(Icons.search, color: colorWhite),
                                            SizedBox(width: 5),
                                            Text('Tìm kiếm', style: textButton),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(),
                              getRule(listRule.data, Role.Xem, context)
                                  ? Container(
                                      margin: EdgeInsets.only(right: 40, top: 20),
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 20.0,
                                            horizontal: 10.0,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                          ),
                                          backgroundColor: (listInterViews.keys.length != 0) ? colorOrange : Color.fromARGB(255, 124, 124, 124),
                                          primary: Theme.of(context).iconTheme.color,
                                          textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                        ),
                                        onPressed: (listInterViews.keys.length != 0)
                                            ? () async {
                                                await createExcel(listInterViews, listUser);
                                              }
                                            : null,
                                        child: Row(
                                          children: [
                                            Icon(Icons.file_download, color: colorWhite),
                                            SizedBox(width: 5),
                                            Text('Xuất file', style: textButton),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: backgroundPage,
                padding: EdgeInsets.symmetric(vertical: verticalPaddingPage, horizontal: horizontalPaddingPage),
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
                  child: (status)
                      ? (listInterViews.keys.length != 0)
                          ? Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Thông tin lịch phỏng vấn',
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
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                            child: DataTable(
                                          showCheckboxColumn: false,
                                          columnSpacing: 10,
                                          columns: [
                                            DataColumn(label: Text('STT', style: titleTableData)),
                                            DataColumn(label: Text('Nhân viên TD', style: titleTableData)),
                                            DataColumn(label: Text('Tiêu đề', style: titleTableData)),
                                            DataColumn(label: Text('Phòng ban', style: titleTableData)),
                                            DataColumn(label: Text('Vị trí', style: titleTableData)),
                                            DataColumn(label: Text('Số lượng\ncần tuyển', style: titleTableData)),
                                            DataColumn(label: Text('Số lượng\ntrúng tuyển', style: titleTableData)),
                                            DataColumn(label: Text('Số cuộc\nPV', style: titleTableData)),
                                          ],
                                          rows: <DataRow>[
                                            for (var i = 0; i < listInterViews.keys.length; i++)
                                              for (var j = 0; j <= listInterViews[listInterViews.keys.toList()[i]].length; j++)
                                                (j < listInterViews[listInterViews.keys.toList()[i]].length)
                                                    ? DataRow(
                                                        cells: <DataCell>[
                                                          DataCell(Text((j == 0) ? " ${i + 1}" : "")),
                                                          DataCell(Text((j == 0) ? "${listUser[i][0]} (${listUser[i][1]})" : "")),
                                                          DataCell(Text("${listInterViews[listInterViews.keys.toList()[i]][j][0]}")),
                                                          DataCell(Text("${listInterViews[listInterViews.keys.toList()[i]][j][1]}")),
                                                          DataCell(Text("${listInterViews[listInterViews.keys.toList()[i]][j][2]}")),
                                                          DataCell(Text("${listInterViews[listInterViews.keys.toList()[i]][j][3]}")),
                                                          DataCell(Text("${listInterViews[listInterViews.keys.toList()[i]][j][4]}")),
                                                          DataCell(Text("${listInterViews[listInterViews.keys.toList()[i]][j][5]}")),
                                                        ],
                                                      )
                                                    : DataRow(
                                                        cells: <DataCell>[
                                                          DataCell(Text("")),
                                                          DataCell(Text("")),
                                                          DataCell(Text("")),
                                                          DataCell(Text("")),
                                                          DataCell(Text("")),
                                                          DataCell(Text("Tổng:", style: titleTableData)),
                                                          DataCell(Text("${listUser[i][2]}", style: titleTableData)),
                                                          DataCell(Text("${listUser[i][3]}", style: titleTableData)),
                                                        ],
                                                      )
                                          ],
                                        )),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            )
                          : Text(
                              "Không có kết quả phù hợp",
                              textAlign: TextAlign.center,
                              style: titleTableData,
                            )
                      : Center(child: const CircularProgressIndicator()),
                ),
              ),
              Footer(marginFooter: EdgeInsets.only(top: 5), paddingFooter: EdgeInsets.all(15)),
              SizedBox(height: 20)
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
