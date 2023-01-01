// ignore_for_file: unused_local_variable

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/api.dart';
import 'package:gentelella_flutter/common/format_date.dart';
import 'package:gentelella_flutter/common/style.dart';
import 'package:gentelella_flutter/common/widgets_form.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart';

import '../../../../common/dynamic_table.dart';
import '../../../../common/toast.dart';
import '../../../utils/market_development.dart';
import '../../nhan_su/view-hsns.dart';
import '../danh_sach_don_hang_hsn.dart';
import '../thuong_don_hang/CareUser.dart';
import "package:collection/collection.dart";
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row;

TextEditingController title = TextEditingController();

var resultListTrainee = {};
var listOrderId = [];
var listTraineeId = [];
dynamic listTargerBonus = {};
var resultTargetBonusDetail = {};
var resultTargetBonusRequire = {};
int rewardOfferId = 0;
String? dateFrom;
String? dateTo;

class ThuongChiTieuLichSu extends StatefulWidget {
  ThuongChiTieuLichSu({Key? key}) : super(key: key);

  @override
  State<ThuongChiTieuLichSu> createState() => _ThuongChiTieuLichSuState();
}

class _ThuongChiTieuLichSuState extends State<ThuongChiTieuLichSu> {
  late Future futureTargetBonusRequire;
  Map<String, CareUser> listCareUserDuplicate = {};
  List<CareUser>? listCareUser = [];
  int rowCount = 0;
  int currentPageDef = 1;
  int rowPerPage = 10;
  String? request;
  var response;
  void _showMaterialDialog(BuildContext context, int index) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.55,
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        child: Image.asset('assets/images/logoAAM.png'),
                        margin: EdgeInsets.only(right: 10),
                      ),
                      Text(
                        'Danh sách nhân viên',
                        style: TextStyle(
                            fontSize: 20,
                            color: Color(0xff333333),
                            fontWeight: FontWeight.w700),
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
            //Bảng chot ds
            content: Container(
              width: 800,
              height: 400,
              child: ListView(
                children: [
                  DataTable(
                    showCheckboxColumn: false,
                    columns: [
                      DataColumn(label: Text('STT', style: titleTableData)),
                      DataColumn(
                          label: Text('Tên nhân viên', style: titleTableData)),
                      DataColumn(
                          label: Text('Phòng ban', style: titleTableData)),
                      DataColumn(
                          label: Text('Tổng số TTS', style: titleTableData)),
                      DataColumn(
                          label: Text('Tổng số lần thi tuyển',
                              style: titleTableData)),
                      DataColumn(label: Text('Số tiền', style: titleTableData)),
                    ],
                    rows: <DataRow>[
                      for (int i = 0;
                          i < resultTargetBonusDetail["content"].length;
                          i++)
                        DataRow(
                          cells: <DataCell>[
                            DataCell(Text("${i + 1}")),
                            DataCell(
                              TextButton(
                                child: Text(
                                    resultTargetBonusDetail["content"][i]
                                            ["nhanvien"]["fullName"] +
                                        " (${resultTargetBonusDetail["content"][i]["nhanvien"]["userCode"]})",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400)),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ViewHSNSBody(
                                            idHSNS: resultTargetBonusDetail[
                                                    "content"][i]["userId"]
                                                .toString())),
                                  );
                                },
                              ),
                            ),
                            DataCell(
                              Text(
                                  resultTargetBonusDetail["content"][i]
                                          ["nhanvien"]["phongban"]['departName']
                                      .toString(),
                                  style: bangDuLieu),
                            ),
                            DataCell(
                              Text(
                                  resultTargetBonusDetail["content"][i]
                                          ["ttsTotal"]
                                      .toString(),
                                  style: bangDuLieu),
                            ),
                            DataCell(
                              TextButton(
                                  onPressed: () async {
                                    await getLichSuThiTuyen(
                                        resultTargetBonusDetail["content"][i]
                                            ["userId"],
                                        rewardOfferId);
                                    showData(resultLichSuThiTuyen);
                                  },
                                  child: Text(
                                      resultTargetBonusDetail["content"][i]
                                              ["examTotal"]
                                          .toString(),
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400))),
                            ),
                            DataCell(
                              Text(
                                  NumberFormat.simpleCurrency(locale: "vi")
                                      .format(resultTargetBonusDetail["content"]
                                          [i]["amountTotal"])
                                      .toString(),
                                  style: bangDuLieu),
                            ),
                          ],
                        )
                    ],
                  ),
                ],
              ),
            ),
            actions: <Widget>[],
          );
        });
  }

  void showData(var resultLichSuThiTuyen) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.55,
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        child: Image.asset('assets/images/logoAAM.png'),
                        margin: EdgeInsets.only(right: 10),
                      ),
                      Text(
                        'Lịch sử thi tuyển',
                        style: TextStyle(
                            fontSize: 20,
                            color: Color(0xff333333),
                            fontWeight: FontWeight.w700),
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
            //Bảng chot ds
            content: Container(
              width: 800,
              height: 400,
              child: ListView(
                children: [
                  DataTable(
                    showCheckboxColumn: false,
                    columns: [
                      DataColumn(label: Text('STT', style: titleTableData)),
                      DataColumn(label: Text('Tên TTS', style: titleTableData)),
                      DataColumn(
                          label: Text('Ngày sinh', style: titleTableData)),
                      DataColumn(
                          label: Text('Ngày thi', style: titleTableData)),
                      DataColumn(
                          label: Text('Đơn hàng', style: titleTableData)),
                      DataColumn(
                          label:
                              Text('Thưởng chỉ tiêu', style: titleTableData)),
                    ],
                    rows: <DataRow>[
                      for (int i = 0; i < resultLichSuThiTuyen.length; i++)
                        DataRow(
                          cells: <DataCell>[
                            DataCell(Text("${i + 1}")),
                            DataCell(
                              Text(
                                  (resultLichSuThiTuyen[i]["thuctapsinh"] !=
                                          null)
                                      ? resultLichSuThiTuyen[i]["thuctapsinh"]
                                              ["fullName"] +
                                          " (${resultLichSuThiTuyen[i]["thuctapsinh"]["userCode"]})"
                                      : "nodata",
                                  style: bangDuLieu),
                            ),
                            DataCell(Text(
                                resultLichSuThiTuyen[i]["thuctapsinh"]
                                            ["birthDate"] !=
                                        null
                                    ? DateFormat("dd-MM-yyyy").format(
                                        DateTime.parse(resultLichSuThiTuyen[i]
                                            ["thuctapsinh"]["birthDate"]))
                                    : "",
                                style: bangDuLieu)),
                            DataCell(
                              Text(
                                  (resultLichSuThiTuyen[i]["examDate"] != null)
                                      ? DateFormat('dd-MM-yyy').format(
                                          DateTime.parse(resultLichSuThiTuyen[i]
                                                  ["examDate"]
                                              .toString()))
                                      : "",
                                  style: bangDuLieu),
                            ),
                            DataCell(
                              Text(
                                  resultLichSuThiTuyen[i]["donhang"]
                                          ["orderName"] ??
                                      "" +
                                          " (${resultLichSuThiTuyen[i]["donhang"]["orderCode"]})" ??
                                      "",
                                  style: bangDuLieu),
                            ),
                            DataCell(
                              Text(
                                  resultLichSuThiTuyen[i]["targetBonus"]
                                      .toString(),
                                  style: bangDuLieu),
                            ),
                          ],
                        )
                    ],
                  ),
                ],
              ),
            ),
            actions: <Widget>[],
          );
        });
  }

  getTargetBonusRequire(currentPage, {dateTo, dateFrom}) async {
    String condition = "";
    if (dateFrom != null && dateFrom != "") {
      condition += "and dateApprove >:'${dateFrom!}'";
    }
    if (dateTo != null && dateTo != "") {
      condition += " AND dateApprove <:'${dateTo!}'";
    }

    if (request == null) {
      response = await httpGet(
          "/api/thuong-chitieu-denghi/get/page?page=${currentPage - 1}&size=$rowPerPage&sort=id&filter=bonusType:1 $condition",
          context);
    } else {
      response = await httpGet(
          "/api/thuong-chitieu-denghi/get/page?page=${currentPage - 1}&size=$rowPerPage&filter=bonusType:1 and title~'*$request*' $condition",
          context);
    }
    if (response.containsKey("body")) {
      setState(() {
        resultTargetBonusRequire = jsonDecode(response["body"]);
        rowCount = jsonDecode(response["body"])['totalElements'];
      });
    }
    return 0;
  }

  getTargetBonusDetail() async {
    var response = await httpGet(
        "/api/thuong-chitieu-chitiet/get/page?filter=rewardOfferId:$rewardOfferId",
        context);
    if (response.containsKey("body")) {
      setState(() {
        resultTargetBonusDetail = jsonDecode(response["body"]);
      });
    }
  }

  var resultLichSuThiTuyen = [];
  getLichSuThiTuyen(var a, var rewardOfferId) async {
    var response = await httpGet(
        "/api/tts-lichsu-thituyen/get/page?sort=ttsId&filter=thuctapsinh.careUser:$a and rewardOfferId:$rewardOfferId and examResult in (1,2,3)",
        context);
    if (response.containsKey("body")) {
      resultLichSuThiTuyen = jsonDecode(response["body"])['content'] ?? [];
      for (var i = 0; i < resultLichSuThiTuyen.length; i++) {
        resultLichSuThiTuyen[i]["targetBonus"] =
            await getThuongChiTieu(resultLichSuThiTuyen[i]["orderId"]);
        print("tien:${resultLichSuThiTuyen[i]["targetBonus"]}");
      }
    }
  }

  Future<double> getThuongChiTieu(int idDonHang) async {
    double tien = 0;
    var response1 = await httpGet(
        "/api/thuong-chitieu-donhang/get/page?filter=orderId:$idDonHang and approve:1",
        context);
    if (response1.containsKey("body")) {
      setState(() {
        var result = jsonDecode(response1["body"])['content'] ?? [];
        if (result.length > 0) {
          tien = result.first['targetBonus'] ?? 0;
        }
      });
    }

    return tien;
  }

  Future<void> createExcel(var listChiTieu, String title) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    sheet.getRangeByName('A1').columnWidth = 8;
    sheet.getRangeByName('B1').columnWidth = 21;
    sheet.getRangeByName('C1').columnWidth = 25;
    sheet.getRangeByName('D1').columnWidth = 25;
    sheet.getRangeByName('E1').columnWidth = 25;
    sheet.getRangeByName('F1').columnWidth = 25;
    sheet.getRangeByName('G1').columnWidth = 25;
    sheet.getRangeByName('H1').columnWidth = 20;
    sheet.getRangeByName('I1').columnWidth = 45;
    sheet.getRangeByName('J1').columnWidth = 30;
    sheet.getRangeByName('K1').columnWidth = 20;
    sheet.getRangeByName('L1').columnWidth = 20;
    sheet.getRangeByName('A2:A3').merge();
    sheet.getRangeByName('B2:B3').merge();
    sheet.getRangeByName('C2:C3').merge();
    sheet.getRangeByName('D2:D3').merge();
    sheet.getRangeByName('E2:E3').merge();
    sheet.getRangeByName('J2:J3').merge();
    sheet.getRangeByName('K2:K3').merge();
    sheet.getRangeByName('L2:L3').merge();
    sheet.getRangeByName('F2:I2').merge();
    sheet
        .getRangeByName('A1')
        .setText("Danh sách thưởng chỉ tiêu cho đề nghị: $title");
    sheet.getRangeByName('A2').setText("STT");
    sheet.getRangeByName('B2').setText("Mã số");
    sheet.getRangeByName('C2').setText("Cán bộ tuyển dụng");
    sheet.getRangeByName('D2').setText("Vị trí");
    sheet.getRangeByName('E2').setText("Phòng ban");
    sheet.getRangeByName('F2').setText("Thực tập sinh");
    sheet.getRangeByName('F3').setText("Mã TTS");
    sheet.getRangeByName('G3').setText("Tên TTS");
    sheet.getRangeByName('H3').setText("Ngày sinh");
    sheet.getRangeByName('I3').setText("Địa chỉ");
    sheet.getRangeByName('J2').setText("Đơn hàng");
    sheet.getRangeByName('K2').setText("Tiền thưởng(VND)");
    sheet.getRangeByName('L2').setText("Ngày thi tuyển");
    sheet.getRangeByIndex(1, 1, 300, 12).cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByIndex(1, 1, 300, 12).cellStyle.vAlign = VAlignType.center;
    int index = 0;
    for (var i = 0; i < listChiTieu.length; i++) {
      sheet
          .getRangeByIndex(
              4 + index, 1, 4 + index + listChiTieu[i]['TTS'].length as int, 1)
          .merge();
      sheet
          .getRangeByIndex(
              4 + index, 2, 4 + index + listChiTieu[i]['TTS'].length as int, 2)
          .merge();
      sheet
          .getRangeByIndex(
              4 + index, 3, 4 + index + listChiTieu[i]['TTS'].length as int, 3)
          .merge();
      sheet
          .getRangeByIndex(
              4 + index, 4, 4 + index + listChiTieu[i]['TTS'].length as int, 4)
          .merge();
      sheet
          .getRangeByIndex(
              4 + index, 5, 4 + index + listChiTieu[i]['TTS'].length as int, 5)
          .merge();
      sheet.getRangeByIndex(4 + index, 1).setNumber(i + 1);
      sheet.getRangeByIndex(4 + index, 2).setText(listChiTieu[i]['userCode']);
      sheet.getRangeByIndex(4 + index, 3).setText(listChiTieu[i]['fullName']);
      sheet.getRangeByIndex(4 + index, 4).setText(listChiTieu[i]['viTri']);
      sheet.getRangeByIndex(4 + index, 5).setText(listChiTieu[i]['phongBan']);
      int sumTT = 0;
      for (var j = 0; j <= listChiTieu[i]['TTS'].length; j++) {
        if (j < listChiTieu[i]['TTS'].length) {
          sumTT += listChiTieu[i]['tienThuong'][j] as int;
          sheet
              .getRangeByIndex(4 + index + j, 6)
              .setText(listChiTieu[i]['TTS'][j]['userCode']);
          sheet
              .getRangeByIndex(4 + index + j, 7)
              .setText(listChiTieu[i]['TTS'][j]['fullName']);
          sheet.getRangeByIndex(4 + index + j, 8).setText((listChiTieu[i]['TTS']
                      [j]['birthDate'] !=
                  "")
              ? DateFormat('dd-MM-yyyy')
                  .format(DateTime.parse(listChiTieu[i]['TTS'][j]['birthDate']))
              : "");
          sheet
              .getRangeByIndex(4 + index + j, 9)
              .setText(listChiTieu[i]['TTS'][j]['queQuan']);
          sheet
              .getRangeByIndex(4 + index + j, 10)
              .setText(listChiTieu[i]['donHang'][j]);
          sheet
              .getRangeByIndex(4 + index + j, 11)
              .setNumber(listChiTieu[i]['tienThuong'][j]);
          sheet.getRangeByIndex(4 + index + j, 12).setText(
              (listChiTieu[i]['ngayThiTuyen'][j] != "")
                  ? DateFormat('dd-MM-yyyy')
                      .format(DateTime.parse(listChiTieu[i]['ngayThiTuyen'][j]))
                  : "");
        } else {
          sheet.getRangeByIndex(4 + index + j, 11).setNumber(sumTT as double);
          sheet.getRangeByIndex(4 + index + j, 6, 4 + index + j, 10).merge();
          sheet
              .getRangeByIndex(4 + index + j, 6, 4 + index + j, 10)
              .cellStyle
              .hAlign = HAlignType.right;
          sheet.getRangeByIndex(4 + index + j, 6).setText("Tổng       ");
          sheet.getRangeByIndex(4 + index + j, 6).cellStyle.bold = true;
          sheet.getRangeByIndex(4 + index + j, 11).cellStyle.bold = true;
        }
      }
      index += listChiTieu[i]['TTS'].length + 1 as int;
    }
    sheet.getRangeByIndex(1, 1, 3 + index, 12).cellStyle.fontSize = 12;
    sheet.getRangeByIndex(1, 1, 3 + index, 12).cellStyle.fontName =
        "Times New Roman";
    sheet.getRangeByIndex(2, 1, 3 + index, 12).cellStyle.borders.all.lineStyle =
        LineStyle.thin;
    sheet.getRangeByIndex(2, 1, 3, 12).cellStyle.backColor = '#009c87';
    sheet.getRangeByIndex(2, 1, 3, 12).cellStyle.fontSize = 13;
    sheet.getRangeByIndex(2, 1, 3, 12).cellStyle.bold = true;
    sheet.getRangeByIndex(1, 1, 1, 12).merge();
    sheet.getRangeByIndex(1, 1).rowHeight = 29;
    sheet.getRangeByIndex(1, 1).cellStyle.fontSize = 16;
    sheet.getRangeByIndex(1, 1).cellStyle.bold = true;
    sheet.getRangeByIndex(2, 1, 2 + index, 1).rowHeight = 20;
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();
    if (kIsWeb) {
      AnchorElement(
          href:
              'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
        ..setAttribute('download', 'Chi_Tieu_Nguon.xlsx')
        ..click();
    }
  }

  @override
  void initState() {
    super.initState();
    futureTargetBonusRequire = getTargetBonusRequire(currentPage);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futureTargetBonusRequire,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView(children: [
              Container(
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
                  child: Column(
                    children: [
                      Row(
                        children: [
                          TextFieldValidated(
                            type: 'Null',
                            height: 40,
                            controller: title,
                            label: 'Tiêu đề',
                            flexLable: 2,
                            flexTextField: 5,
                            enter: () {
                              request = title.text;
                              getTargetBonusRequire(0);
                            },
                          ),
                          Expanded(
                            flex: 6,
                            child: Container(),
                          )
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(children: [
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
                        Expanded(flex: 1, child: Container()),
                        Expanded(
                          flex: 3,
                          child: DatePickerBoxCustomForMarkert(
                              flexLabel: 3,
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
                        Expanded(flex: 1, child: Container()),
                        Expanded(
                          flex: 1,
                          child: Row(children: []),
                        ),
                      ]),
                      Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20.0,
                                    horizontal: 20.0,
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
                                  request = title.text;
                                  futureTargetBonusRequire =
                                      getTargetBonusRequire(0,
                                          dateFrom: dateFrom, dateTo: dateTo);
                                },
                                child: Row(
                                  children: [
                                    Icon(Icons.search,
                                        color: Colors.white, size: 15),
                                    Text(' Tìm kiếm', style: textButton),
                                  ],
                                ),
                              ),
                              SizedBox(width: 25),
                            ]),
                      )
                    ],
                  ),
                ),
              ),

              Container(
                color: backgroundPage,
                padding:
                    EdgeInsets.symmetric(horizontal: horizontalPaddingPage),
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
                        children: [
                          Expanded(
                            child: DataTable(
                              showCheckboxColumn: false,
                              columns: [
                                DataColumn(
                                    label: Text('STT', style: titleTableData)),
                                DataColumn(
                                    label: Text('Ngày gửi',
                                        style: titleTableData)),
                                DataColumn(
                                    label:
                                        Text('Tiêu đề', style: titleTableData)),
                                DataColumn(
                                    label: Text('Tổng tiền',
                                        style: titleTableData)),
                                DataColumn(
                                    label: Text('Kế toán xác nhận',
                                        style: titleTableData)),
                                DataColumn(
                                    label: Text('Ngày xác nhận',
                                        style: titleTableData)),
                                DataColumn(
                                    label: Text('Tải file',
                                        style: titleTableData)),
                              ],
                              rows: <DataRow>[
                                for (int i = 0;
                                    i <
                                        resultTargetBonusRequire["content"]
                                            .length;
                                    i++)
                                  DataRow(
                                    cells: <DataCell>[
                                      DataCell(Text("${i + 1}")),
                                      DataCell(Text(
                                        FormatDate.formatDateView(
                                            DateTime.parse(
                                                resultTargetBonusRequire[
                                                            "content"][i]
                                                        ['createdDate']
                                                    .toString())),
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400),
                                      )),
                                      DataCell(
                                        TextButton(
                                          onPressed: () async {
                                            rewardOfferId =
                                                resultTargetBonusRequire[
                                                    "content"][i]["id"];
                                            await getTargetBonusDetail();
                                            _showMaterialDialog(context, i);
                                          },
                                          child: Text(
                                              resultTargetBonusRequire[
                                                  "content"][i]['title'],
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400)),
                                        ),
                                      ),
                                      DataCell(
                                        TextButton(
                                          onPressed: () async {
                                            rewardOfferId =
                                                resultTargetBonusRequire[
                                                    "content"][i]["id"];
                                            print(rewardOfferId);
                                            await getTargetBonusDetail();
                                            _showMaterialDialog(context, i);
                                          },
                                          child: Text(
                                              NumberFormat.simpleCurrency(
                                                      locale: "vi")
                                                  .format(
                                                      resultTargetBonusRequire[
                                                              "content"][i]
                                                          ['totalAmount'])
                                                  .toString(),
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400)),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                            (resultTargetBonusRequire["content"]
                                                        [i]['acctApprove'] ==
                                                    1)
                                                ? "Đã duyệt"
                                                : (resultTargetBonusRequire[
                                                                "content"][i]
                                                            ['acctApprove'] ==
                                                        0)
                                                    ? "Chưa duyệt"
                                                    : "Từ chối",
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400)),
                                      ),
                                      DataCell(
                                        Text(
                                            resultTargetBonusRequire["content"]
                                                        [i]['dateApprove'] !=
                                                    null
                                                ? FormatDate.formatDateView(
                                                    DateTime.parse(
                                                        resultTargetBonusRequire[
                                                                    "content"][i]
                                                                ['dateApprove']
                                                            .toString()))
                                                : " ",
                                            style: bangDuLieu),
                                      ),
                                      DataCell(InkWell(
                                          onTap: () async {
                                            processing();
                                            var listChiTieuNguon = [];
                                            var response1 = await httpGet(
                                                "/api/thuong-chitieu-denghi/get/page?filter=id:${resultTargetBonusRequire["content"][i]['id']}",
                                                context);
                                            var rewardOfferIdI;
                                            if (response1.containsKey("body")) {
                                              var listThuongChiTieuDN;
                                              listThuongChiTieuDN = jsonDecode(
                                                  response1["body"])['content'];
                                              for (var element
                                                  in listThuongChiTieuDN) {
                                                rewardOfferIdI = element['id'];
                                                var response2 = await httpGet(
                                                    "/api/thuong-chitieu-chitiet/get/page?filter=rewardOfferId:$rewardOfferIdI",
                                                    context);
                                                if (response2
                                                    .containsKey("body")) {
                                                  var result = jsonDecode(
                                                          response2["body"])[
                                                      'content'];

                                                  for (var element1 in result) {
                                                    var response3 = await httpGet(
                                                        "/api/tts-lichsu-thituyen/get/page?sort=ttsId&filter=thuctapsinh.careUser:${element1['userId']} and rewardOfferId:$rewardOfferIdI and examResult in (1,2,3)",
                                                        context);
                                                    if (response3
                                                        .containsKey("body")) {
                                                      var resultLichSuThiTuyen1 =
                                                          jsonDecode(response3[
                                                                      "body"])[
                                                                  'content'] ??
                                                              [];
                                                      if (resultLichSuThiTuyen1
                                                              .length >
                                                          0) {
                                                        for (var i = 0;
                                                            i <
                                                                resultLichSuThiTuyen1
                                                                    .length;
                                                            i++) {
                                                          resultLichSuThiTuyen1[
                                                                      i][
                                                                  "targetBonus"] =
                                                              await getThuongChiTieu(
                                                                  resultLichSuThiTuyen1[
                                                                          i][
                                                                      "orderId"]);
                                                          // print("tien:${resultLichSuThiTuyen1[i]["targetBonus"]}");
                                                        }
                                                      }
                                                      element1[
                                                              'resultLichSuThiTuyen'] =
                                                          resultLichSuThiTuyen1;
                                                    }
                                                    listChiTieuNguon
                                                        .add(element1);
                                                  }
                                                }
                                              }
                                              Navigator.pop(context);
                                            }
                                            if (listChiTieuNguon.length > 0) {
                                              var mapChiTieuNguon =
                                                  groupBy(listChiTieuNguon,
                                                      (dynamic obj) {
                                                return obj["nhanvien"]
                                                    ["userCode"];
                                              });
                                              var listChiTieuNguonLoc = [];
                                              if (mapChiTieuNguon.keys.length >
                                                  0) {
                                                for (var element2
                                                    in mapChiTieuNguon.keys) {
                                                  var chiTieuNguon = {
                                                    "userCode": element2,
                                                    "fullName": mapChiTieuNguon[
                                                                element2]!
                                                            .first['nhanvien']
                                                        ['fullName'],
                                                    "phongBan": mapChiTieuNguon[
                                                                            element2]!
                                                                        .first[
                                                                    'nhanvien']
                                                                ['phongban']
                                                            ['departName'] ??
                                                        "",
                                                    "viTri": (mapChiTieuNguon[
                                                                            element2]!
                                                                        .first[
                                                                    'nhanvien']
                                                                ['vaitro'] !=
                                                            null)
                                                        ? mapChiTieuNguon[
                                                                    element2]!
                                                                .first['nhanvien']
                                                            ['vaitro']['name']
                                                        : "",
                                                    "TTS": [],
                                                    "donHang": [],
                                                    "tienThuong": [],
                                                    "ngayThiTuyen": [],
                                                  };
                                                  for (var element3
                                                      in mapChiTieuNguon[
                                                          element2]!) {
                                                    for (var element4 in element3[
                                                        'resultLichSuThiTuyen']) {
                                                      chiTieuNguon['TTS'].add(
                                                          (element4["thuctapsinh"] !=
                                                                  null)
                                                              ? {
                                                                  "userCode": element4[
                                                                          "thuctapsinh"]
                                                                      [
                                                                      "userCode"],
                                                                  "fullName": element4[
                                                                          "thuctapsinh"]
                                                                      [
                                                                      "fullName"],
                                                                  "birthDate":
                                                                      element4['thuctapsinh']
                                                                              [
                                                                              'birthDate'] ??
                                                                          "",
                                                                  "queQuan":
                                                                      element4['thuctapsinh']
                                                                              [
                                                                              'address'] ??
                                                                          "",
                                                                }
                                                              : {});
                                                      chiTieuNguon['donHang'].add(
                                                          (element4["donhang"] !=
                                                                  null)
                                                              ? "${element4["donhang"]["orderName"]} (${element4["donhang"]["orderCode"]})"
                                                              : "");
                                                      chiTieuNguon['tienThuong']
                                                          .add(element4[
                                                              "targetBonus"]);
                                                      chiTieuNguon[
                                                              'ngayThiTuyen']
                                                          .add(element4[
                                                                  "examDate"] ??
                                                              "");
                                                    }
                                                  }
                                                  listChiTieuNguonLoc
                                                      .add(chiTieuNguon);
                                                }
                                              }

                                              // print("listChiTieuNguonLoc:$listChiTieuNguonLoc");
                                              createExcel(
                                                  listChiTieuNguonLoc,
                                                  resultTargetBonusRequire[
                                                      "content"][i]['title']);
                                            } else {
                                              showToast(
                                                context: context,
                                                msg: "Danh sách trống",
                                                color: colorOrange,
                                                icon: const Icon(Icons.warning),
                                              );
                                            }
                                          },
                                          child: Icon(
                                            Icons.download,
                                            color: mainColorPage,
                                          ))),
                                    ],
                                  )
                              ],
                            ),
                          ),
                        ],
                      ),
                      DynamicTablePagging(rowCount, currentPageDef, rowPerPage,
                          pageChangeHandler: (currentPage) {
                        setState(() {
                          futureTargetBonusRequire =
                              getTargetBonusRequire(currentPage);
                          currentPageDef = currentPage;
                        });
                      }, rowPerPageChangeHandler: (rowPerPageChange) {
                        rowPerPage = rowPerPageChange;
                        futureTargetBonusRequire =
                            getTargetBonusRequire(currentPage);

                        setState(() {});
                      })
                    ],
                  ),
                ),
              ),
              //
              Footer(
                  marginFooter: EdgeInsets.only(top: 25),
                  paddingFooter: EdgeInsets.all(15))
            ]);
          } else if (snapshot.hasError) {
            return Text('Delivery error: ${snapshot.error.toString()}');
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                ],
              ),
            ],
          );
        });
  }

  Future<void> processing() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return Center(child: const CircularProgressIndicator());
      },
    );
  }
}
