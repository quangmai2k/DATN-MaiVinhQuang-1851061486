import 'dart:convert';
import 'dart:typed_data';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gentelella_flutter/widgets/ui/market_development/13-report_the_union_due_fee/alertdialog_comfim_payment.dart';
import 'package:gentelella_flutter/widgets/ui/market_development/13-report_the_union_due_fee/xuatFileHoaDon.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../api.dart';
import '../../../../common/dynamic_table.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/model.dart';
import '../../../forms/market_development/utils/form.dart';
import '../../../utils/market_development.dart';
import "package:collection/collection.dart";
import 'package:universal_html/html.dart' show AnchorElement;
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;
import 'dart:js' as js;
import 'package:jiffy/jiffy.dart';

import '../3-enterprise_manager/enterprise_manager.dart';

//
class ManagerFee extends StatefulWidget {
  ManagerFee({Key? key}) : super(key: key);

  @override
  State<ManagerFee> createState() => _ManagerFeeState();
}

class _ManagerFeeState extends State<ManagerFee> {
  var listData = [];
  List<bool> _selected = [];
  String findLPV = "";
  var time1;
  var time2;
  var page = 1;
  var rowPerPage = 10;
  var totalElements = 0;
  var firstRow = 1, lastRow = 0;
  var rowCount = 0;
  var currentPage = 1;
  var tableIndex = 1;
  String find = "";

  TextEditingController title = TextEditingController();
  TextEditingController union = TextEditingController();

  Map<int, String> tranhThai = {-1: "Tất cả", 0: 'Chưa', 1: 'Thanh toán đủ', 2: 'Thanh toán 1 phần'};
  int selectedTT = -1;
  getManagerFee(int page, String find) async {
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }
    if (page < 1) {
      page = 0;
    }
    var response5;
    if (find == "")
      response5 = await httpGet("/api/nghiepdoan-denghi/get/page?size=$rowPerPage&page=$page", context);
    else
      response5 = await httpGet("/api/nghiepdoan-denghi/get/page?size=$rowPerPage&page=$page&filter=$find", context);
    // print("response5:$response5");
    if (response5.containsKey("body")) {
      var body = jsonDecode(response5['body']);
      setState(() {
        listData = body['content'] ?? [];
      });
      currentPage = page + 1;
      rowCount = body["totalElements"];
      totalElements = body["totalElements"];
      lastRow = totalElements;
      _selected = List<bool>.generate(listData.length, (int index) => false);
    } else
      throw Exception('Không có data');
  }

  getCTTLXC({condition}) async {
    List<dynamic> listCTLXC = [];
    if (condition == null && condition.isEmpty()) {
      return [];
    }
    var response = await httpGet("/api/lichxuatcanh-chitiet/get/page?filter=status:1 and userId in ($condition)", context);
    // print("response5:$response5");
    if (response.containsKey("body")) {
      var body = jsonDecode(response['body']);
      setState(() {
        listCTLXC = body['content'];
      });
    }
    return listCTLXC;
  }

  bool statusData = false;
  void callAPI() async {
    await getManagerFee(page, find);
    setState(() {
      statusData = true;
    });
  }

  String? dateFrom;
  String? dateTo;
  int? idChange;
//Xuất file nghiệp đàon đề nghị
  Future<void> createExcelAll(var listDataExport) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    sheet.getRangeByName('A1:I3').cellStyle.fontName = "Times New Roman";
    sheet.getRangeByName('A1:I3').cellStyle.bold = true;
    sheet.getRangeByName('A1:I3').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('A1:I3').cellStyle.vAlign = VAlignType.center;
    sheet.getRangeByName('A1').setText("AAM");
    sheet.getRangeByName('A2').setText("Thu phí quản lý");
    sheet.getRangeByName('A2:I2').merge();
    sheet.getRangeByName('A2').cellStyle.fontSize = 16;
    sheet.getRangeByName('A2').rowHeight = 42;
    sheet.getRangeByName('A1').columnWidth = 6.5;
    sheet.getRangeByName('B1').columnWidth = 21;
    sheet.getRangeByName('C1').columnWidth = 23;
    sheet.getRangeByName('D1').columnWidth = 27;
    sheet.getRangeByName('E1').columnWidth = 29;
    sheet.getRangeByName('F1').columnWidth = 21;
    sheet.getRangeByName('G1').columnWidth = 21;
    sheet.getRangeByName('H1').columnWidth = 24;
    sheet.getRangeByName('I1').columnWidth = 21;
    sheet.getRangeByName('A3:I3').cellStyle.borders.all.lineStyle = LineStyle.thin;
    sheet.getRangeByName('A3').setText("STT");
    sheet.getRangeByName('B3').setText("Tiêu đề");
    sheet.getRangeByName('C3').setText("Mã nghiệp đoàn");
    sheet.getRangeByName('D3').setText("Tên nghiệp đoàn");
    sheet.getRangeByName('E3').setText("Ngày đến hạn thanh toán");
    sheet.getRangeByName('F3').setText("Ngày làm đề nghị");
    sheet.getRangeByName('G3').setText("Trạng thái đề nghị");
    sheet.getRangeByName('H3').setText("Trạng thái thanh toán");
    sheet.getRangeByName('I3').setText("Ngày thanh toán");
    sheet.getRangeByName('A3').rowHeight = 33;
    sheet.getRangeByName('A3:I3').cellStyle.fontSize = 13;
    sheet.getRangeByName('A3:I3').cellStyle.backColorRgb = Color.fromARGB(255, 6, 141, 29);
    for (var i = 0; i < listDataExport.length; i++) {
      sheet.getRangeByIndex(4 + i, 1, 4 + i, 9).cellStyle.fontName = "Times New Roman";
      sheet.getRangeByIndex(4 + i, 1, 4 + i, 9).cellStyle.hAlign = HAlignType.center;
      sheet.getRangeByIndex(4 + i, 1, 4 + i, 9).cellStyle.vAlign = VAlignType.center;
      sheet.getRangeByIndex(4 + i, 1, 4 + i, 9).cellStyle.fontSize = 13;
      sheet.getRangeByIndex(4 + i, 1, 4 + i, 9).cellStyle.borders.all.lineStyle = LineStyle.thin;
      sheet.getRangeByIndex(4 + i, 1).rowHeight = 25;
      sheet.getRangeByIndex(4 + i, 1).setNumber(i + 1);
      sheet.getRangeByIndex(4 + i, 2).setText((listDataExport[i]['title'] != null) ? listDataExport[i]['title'] : "");
      sheet.getRangeByIndex(4 + i, 3).setText((listDataExport[i]['nghiepdoan'] != null) ? listDataExport[i]['nghiepdoan']['orgCode'] : "");
      sheet.getRangeByIndex(4 + i, 4).setText((listDataExport[i]['nghiepdoan'] != null) ? listDataExport[i]['nghiepdoan']['orgName'] : "");
      sheet.getRangeByIndex(4 + i, 5).setText((listDataExport[i]['dueDate'] != null) ? "${DateFormat('dd-MM-yyyy').format(DateTime.parse(listDataExport[i]['dueDate']))}" : "");
      sheet
          .getRangeByIndex(4 + i, 6)
          .setText((listDataExport[i]['requestDate'] != null) ? "${DateFormat('dd-MM-yyyy').format(DateTime.parse(listDataExport[i]['requestDate']))}" : "");
      sheet.getRangeByIndex(4 + i, 7).setText((listDataExport[i]['requestStatus'] != null)
          ? (listDataExport[i]['requestStatus'] == 0)
              ? "Nháp"
              : (listDataExport[i]['requestStatus'] == 1)
                  ? "Hoàn thành"
                  : "Hủy"
          : "");
      sheet.getRangeByIndex(4 + i, 8).setText((listDataExport[i]['paymentStatus'] != null)
          ? (listDataExport[i]['paymentStatus'] == 0)
              ? "Chưa thanh toán"
              : (listDataExport[i]['paymentStatus'] == 1)
                  ? "Thanh toán đủ"
                  : "Tanh toán 1 phần"
          : "");
      sheet.getRangeByIndex(4 + i, 9).setText((listDataExport[i]['paymentDate'] != null && listDataExport[i]['paymentStatus'] != 0)
          ? "${DateFormat('dd-MM-yyyy').format(DateTime.parse(listDataExport[i]['paymentDate']))}"
          : "");
    }
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();
    if (kIsWeb) {
      AnchorElement(href: 'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
        ..setAttribute('download', 'ThuPhiQuanLy.xlsx')
        ..click();
    }
  }

  tinhChuKy(tuNgay, denNgay, chuKyNhom) {
    if (tuNgay != null && denNgay != null) {
      int chuKy = 0;
      DateTime tuNgayMoiXuatCanhDate = DateTime.parse(tuNgay);
      DateTime dateTimeNow = DateTime.parse(denNgay);
      DateTime ngayCong;
      while (tuNgayMoiXuatCanhDate.isBefore(dateTimeNow)) {
        chuKy++;
        tuNgayMoiXuatCanhDate = Jiffy(tuNgayMoiXuatCanhDate).add(months: 1).dateTime.toLocal();
      }
      if (chuKy > chuKyNhom) {
        return chuKyNhom;
      }
      return chuKy;
    }
  }

  Future<List<int>> _readImageData(String name) async {
    final ByteData data = await rootBundle.load('assets/images/$name');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

//xuất file excel nghiệp đoàn đề nghị chi tiết
  Future<void> createExcel(var mapTTS) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    Map<int, String> index = {
      1: "A",
      2: "B",
      3: "C",
      4: "D",
      5: "E",
      6: "F",
      7: "G",
      8: "H",
      9: "I",
    };

    sheet.getRangeByName('B2:H2').merge();
    sheet.getRangeByName('B2').setText("AAM 技能実習生の管理費・渡航費の詳細表");
    sheet.getRangeByName('B2').cellStyle.fontName = "ＭＳ Ｐゴシック";
    sheet.getRangeByName('B2').cellStyle.fontSize = 18;
    sheet.getRangeByName('B2').cellStyle.bold = true;
    sheet.getRangeByName('B2').cellStyle.vAlign = VAlignType.center;
    sheet.getRangeByName('B2').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('A3:C3').merge();
    sheet.getRangeByName('A3').setText("組合名: 企業技術研修協同組合");
    sheet.getRangeByName('A3').cellStyle.fontName = "ＭＳ 明朝";
    sheet.getRangeByName('A3').cellStyle.fontSize = 16;
    sheet.getRangeByName('A3').cellStyle.bold = true;

    sheet.getRangeByName('A1').columnWidth = 6;
    sheet.getRangeByName('B1').columnWidth = 38;
    sheet.getRangeByName('C1').columnWidth = 33;
    sheet.getRangeByName('D1').columnWidth = 21;
    sheet.getRangeByName('E1').columnWidth = 21;
    sheet.getRangeByName('F1').columnWidth = 15;
    sheet.getRangeByName('G1').columnWidth = 11;
    sheet.getRangeByName('H1').columnWidth = 16;
    sheet.getRangeByName('I1').columnWidth = 16;
    sheet.getRangeByName('A1').rowHeight = 27;
    sheet.getRangeByName('A2').rowHeight = 32;
    sheet.getRangeByName('A3').rowHeight = 48;
    sheet.getRangeByName('A4').rowHeight = 48;

    sheet.getRangeByName('G3:I3').merge();
    sheet.getRangeByName('G3').setText(
        "作成日：${(mapTTS[mapTTS.keys.toList().first].first['denghi']['dueDate'] != "" && mapTTS[mapTTS.keys.toList().first].first['denghi']['dueDate'] != null) ? DateFormat('yyyy/MM/dd').format(DateTime.parse(mapTTS[mapTTS.keys.toList().first].first['denghi']['dueDate'])) : ""}");
    sheet.getRangeByName('G3').cellStyle.fontName = "Times New Roman";
    sheet.getRangeByName('G3').cellStyle.fontSize = 12;
    sheet.getRangeByName('G4').setText("Currency: USD");
    sheet.getRangeByName('A3').cellStyle.fontName = "ＭＳ 明朝";
    sheet.getRangeByName('A3').cellStyle.fontSize = 12;

    try {
      final String imgae = base64.encode(await readImageFromApi(mapTTS[mapTTS.keys.toList().first].first['denghi']['nghiepdoan']['phapnhan']['image']));
      PicturesCollection img1 = sheet.pictures;
      Picture picture1 = img1.addBase64(1, 1, imgae);
      picture1.height = 60;
      picture1.width = 60;
    } catch (e) {
      print("Ngoại lệ null " + e.toString());
      final String image = base64.encode(await _readImageData('logoAAM.png'));
      sheet.pictures.addBase64(1, 1, image);
    }
    int stt = 0;
    double countTT = 0;
    for (var element in mapTTS.keys) {
      var lenghtElement = mapTTS[element].length;
      stt = stt + 1;
      sheet.getRangeByIndex(4 + stt, 1).setText("番\n号");
      sheet.getRangeByIndex(4 + stt, 1).rowHeight = 80;
      sheet.getRangeByIndex(4 + stt, 2).setText("氏名");
      sheet.getRangeByIndex(4 + stt, 3).setText("受入れ企業");
      sheet.getRangeByIndex(4 + stt, 4).setText("生年月日");
      sheet.getRangeByIndex(4 + stt, 5).setText("入国日");
      sheet.getRangeByIndex(4 + stt, 6).setText(
          "管理費\n${(mapTTS[element].first['dateFrom'] != null) ? DateFormat('dd-MM-yyyy').format(DateTime.parse(mapTTS[element].first['dateFrom'])) : ""} ~\n${(mapTTS[element].first['dateTo'] != null) ? DateFormat('dd-MM-yyyy').format(DateTime.parse(mapTTS[element].first['dateTo'])) : ""}\n${tinhChuKy(mapTTS[element].first['dateFrom'], mapTTS[element].first['dateTo'], mapTTS[element].first['denghi']['chargeCycleDate'])}ヶ月");
      sheet.getRangeByIndex(4 + stt, 7).setText("差引額");
      sheet.getRangeByIndex(4 + stt, 8).setText("渡航費");
      sheet.getRangeByIndex(4 + stt, 9).setText("合計");
      sheet.getRangeByIndex(4 + stt, 1, 4 + stt, 9).cellStyle.fontName = "ＭＳ 明朝";
      sheet.getRangeByIndex(4 + stt, 1, 4 + stt, 9).cellStyle.fontSize = 12;
      sheet.getRangeByIndex(4 + stt, 1, 4 + stt, 9).cellStyle.bold = true;
      sheet.getRangeByIndex(4 + stt, 1, 4 + stt, 9).cellStyle.vAlign = VAlignType.center;
      sheet.getRangeByIndex(4 + stt, 1, 4 + stt, 9).cellStyle.hAlign = HAlignType.center;
      sheet.getRangeByIndex(4 + stt, 6).cellStyle.hAlign = HAlignType.justify;
      sheet.getRangeByIndex(4 + stt, 1, 4 + stt, 9).cellStyle.borders.all.lineStyle = LineStyle.thin;
      // print("lenghtElement:$stt");
      for (var i = 0; i < lenghtElement; i++) {
        sheet.getRangeByIndex(4 + stt + i + 1, 1).rowHeight = 37;
        sheet.getRangeByIndex(4 + stt, 1, 4 + stt, 9).cellStyle.fontName = "Times New Roman";
        sheet.getRangeByIndex(4 + stt + i + 1, 1, 4 + stt + i + 1, 9).cellStyle.fontSize = 14;
        sheet.getRangeByIndex(4 + stt + i + 1, 1, 4 + stt + i + 1, 9).cellStyle.vAlign = VAlignType.center;
        sheet.getRangeByIndex(4 + stt + i + 1, 1, 4 + stt + i + 1, 5).cellStyle.hAlign = HAlignType.center;
        sheet.getRangeByIndex(4 + stt + i + 1, 6, 4 + stt + i + 1, 9).cellStyle.hAlign = HAlignType.right;
        sheet.getRangeByIndex(4 + stt + i + 1, 2).cellStyle.hAlign = HAlignType.left;
        sheet.getRangeByIndex(4 + stt + i + 1, 1, 4 + stt + i + 1, 9).cellStyle.borders.all.lineStyle = LineStyle.thin;
        //set data
        sheet.getRangeByIndex(4 + stt + i + 1, 1).setNumber(i + 1);
        sheet.getRangeByIndex(4 + stt + i + 1, 2).setText(mapTTS[element][i]['thuctapsinh']['fullName']);
        sheet.getRangeByIndex(4 + stt + i + 1, 3).setText(mapTTS[element][i]['denghi']['nghiepdoan']['orgName']);
        sheet.getRangeByIndex(4 + stt + i + 1, 4).setText(
            (mapTTS[element][i]['thuctapsinh']['birthDate'] != null) ? DateFormat('dd-MM-yyyy').format(DateTime.parse(mapTTS[element][i]['thuctapsinh']['birthDate'])) : "");
        sheet.getRangeByIndex(4 + stt + i + 1, 5).setText((mapTTS[element][i]['thuctapsinh']['departureDate'] != null)
            ? DateFormat('dd-MM-yyyy').format(DateTime.parse(mapTTS[element][i]['thuctapsinh']['departureDate']))
            : "");
        sheet.getRangeByIndex(4 + stt + i + 1, 6).setNumber(mapTTS[element][i]['feeTotal']);
        sheet.getRangeByIndex(4 + stt + i + 1, 6).numberFormat = '#,##0';
        (mapTTS[element][i]['incurredFee'] != null && mapTTS[element][i]['incurredFee'] != 0)
            ? sheet.getRangeByIndex(4 + stt + i + 1, 7).setNumber(mapTTS[element][i]['incurredFee'])
            : sheet.getRangeByIndex(4 + stt + i + 1, 7).setText("-");
        sheet.getRangeByIndex(4 + stt + i + 1, 8).setNumber(mapTTS[element][i]['arfareFee'] ?? 0);
        sheet.getRangeByIndex(4 + stt + i + 1, 8).numberFormat = '#,##0';
        sheet.getRangeByIndex(4 + stt + i + 1, 9).setNumber(mapTTS[element][i]['totalAmount']);
        sheet.getRangeByIndex(4 + stt + i + 1, 9).numberFormat = '#,##0';
        countTT += mapTTS[element][i]['totalAmount'];
      }
      stt = stt + lenghtElement + 1 as int;
      sheet.getRangeByIndex(4 + stt, 1, 4 + stt, 5).merge();
      sheet.getRangeByIndex(4 + stt, 1).setText("小計");
      sheet.getRangeByIndex(4 + stt, 1, 4 + stt, 9).cellStyle.borders.all.lineStyle = LineStyle.thin;
      sheet.getRangeByIndex(4 + stt, 1, 4 + stt, 9).cellStyle.borders.all.lineStyle = LineStyle.thin;
      sheet.getRangeByIndex(4 + stt, 1, 4 + stt, 9).cellStyle.fontName = "Times New Roman";
      sheet.getRangeByIndex(4 + stt, 1, 4 + stt, 9).cellStyle.fontSize = 14;
      sheet.getRangeByIndex(4 + stt, 1, 4 + stt, 9).cellStyle.bold = true;
      sheet.getRangeByIndex(4 + stt, 1, 4 + stt, 9).cellStyle.vAlign = VAlignType.center;
      sheet.getRangeByIndex(4 + stt, 1, 4 + stt, 9).cellStyle.hAlign = HAlignType.center;
      sheet.getRangeByIndex(4 + stt, 6).setFormula("=SUM(F${4 + stt - lenghtElement}:F${4 + stt - 1})");
      sheet.getRangeByIndex(4 + stt, 7).setFormula("=SUM(G${4 + stt - lenghtElement}:G${4 + stt - 1})");
      sheet.getRangeByIndex(4 + stt, 8).setFormula("=SUM(H${4 + stt - lenghtElement}:H${4 + stt - 1})");
      sheet.getRangeByIndex(4 + stt, 9).setFormula("=SUM(I${4 + stt - lenghtElement}:I${4 + stt - 1})");
      sheet.getRangeByIndex(4 + stt, 6, 4 + stt, 9).numberFormat = '#,##0';
    }
    sheet.getRangeByIndex(5 + stt, 1, 5 + stt, 7).merge();
    sheet.getRangeByIndex(5 + stt, 1).setText("合計");
    sheet.getRangeByIndex(5 + stt, 1, 5 + stt, 9).cellStyle.borders.all.lineStyle = LineStyle.thin;
    sheet.getRangeByIndex(5 + stt, 1, 5 + stt, 9).cellStyle.vAlign = VAlignType.center;
    sheet.getRangeByIndex(5 + stt, 1, 5 + stt, 9).cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByIndex(5 + stt, 1).rowHeight = 40;
    sheet.getRangeByIndex(5 + stt, 1, 5 + stt, 9).cellStyle.fontName = "Times New Roman";
    sheet.getRangeByIndex(5 + stt, 1, 5 + stt, 9).cellStyle.bold = true;
    sheet.getRangeByIndex(5 + stt, 1, 5 + stt, 9).cellStyle.fontSize = 14;
    sheet.getRangeByIndex(5 + stt, 8, 5 + stt, 9).merge();
    sheet.getRangeByIndex(5 + stt, 8).setNumber(countTT);
    sheet.getRangeByIndex(5 + stt, 8).numberFormat = '#,##0';
    sheet.getRangeByIndex(6 + stt, 1).rowHeight = 40;
    sheet.getRangeByIndex(6 + stt, 1, 6 + stt, 9).merge();
    sheet.getRangeByIndex(6 + stt, 1).cellStyle.vAlign = VAlignType.center;
    sheet.getRangeByIndex(6 + stt, 1).cellStyle.fontName = "Times New Roman";
    sheet.getRangeByIndex(6 + stt, 1).cellStyle.bold = true;
    sheet.getRangeByIndex(6 + stt, 1).setText("AAM 国際人材株式会社");
    sheet.getRangeByIndex(6 + stt, 1).cellStyle.hAlign = HAlignType.right;
    sheet.getRangeByIndex(6 + stt, 1, 6 + stt, 9).cellStyle.borders.all.lineStyle = LineStyle.thin;
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();
    if (kIsWeb) {
      AnchorElement(href: 'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
        ..setAttribute('download',
            '${(mapTTS[mapTTS.keys.toList().first].first['denghi']['title'] != "" && mapTTS[mapTTS.keys.toList().first].first['denghi']['title'] != null) ? mapTTS[mapTTS.keys.toList().first].first['denghi']['title'] : "BaoCao"}.xlsx')
        ..click();
      var result;
      result = await uploadFileByter(bytes, context: context);

      mapTTS[mapTTS.keys.toList().first].first['denghi']['requestFile'] = result;
      await httpPut("/api/nghiepdoan-denghi/put/${mapTTS[mapTTS.keys.toList().first].first['denghi']['id']}", mapTTS[mapTTS.keys.toList().first].first['denghi'], context);

      setState(() {});
    }
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

  List<dynamic> idCheck = [];
  @override
  void initState() {
    super.initState();
    callAPI();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationModel>(
        builder: (context, navigationModel, child) => (statusData)
            ? ListView(
                children: [
                  Container(
                    padding: paddingBoxContainer,
                    margin: marginBoxFormTab,
                    width: MediaQuery.of(context).size.width * 1,
                    decoration: BoxDecoration(
                      color: colorWhite,
                      borderRadius: borderRadiusContainer,
                      boxShadow: [boxShadowContainer],
                      border: borderAllContainerBox,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                              color: colorIconTitleBox,
                              size: sizeIconTitleBox,
                            ),
                          ],
                        ),
                        //--------------Đường line-------------
                        Container(
                          margin: marginTopBottomHorizontalLine,
                          child: Divider(
                            thickness: 1,
                            color: ColorHorizontalLine,
                          ),
                        ),
                        //------------kết thúc đường line-------
                        Container(
                          width: MediaQuery.of(context).size.width * 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 6,
                                      child: TextFieldValidatedMarket(
                                        labe: 'Tiêu đề',
                                        flexLable: 2,
                                        flexTextField: 4,
                                        isReverse: false,
                                        type: 'None',
                                        controller: title,
                                        isShowDau: true,
                                      ),
                                    ),
                                    Expanded(flex: 1, child: Container()),
                                    Expanded(
                                      flex: 6,
                                      child: TextFieldValidatedMarket(
                                        labe: 'Nghiệp đoàn',
                                        flexLable: 2,
                                        flexTextField: 4,
                                        isReverse: false,
                                        type: 'None',
                                        controller: union,
                                        isShowDau: true,
                                      ),
                                    ),
                                    Expanded(flex: 5, child: Container()),
                                  ],
                                ),
                              ),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text('Trạng thái thanh toán', style: titleWidgetBox),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Container(
                                        // width: MediaQuery.of(context).size.width * 0.15,
                                        height: 40,
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton2(
                                            buttonDecoration: BoxDecoration(border: Border.all(width: 0.5, style: BorderStyle.solid)),
                                            buttonPadding: EdgeInsets.only(left: 8),
                                            hint: Text('${tranhThai[-1]}', style: TextStyle(fontSize: 16, color: Theme.of(context).hintColor)),
                                            items: tranhThai.entries
                                                .map((item) => DropdownMenuItem<int>(value: item.key, child: Text(item.value, style: const TextStyle(fontSize: 16))))
                                                .toList(),
                                            value: selectedTT,
                                            onChanged: (value) {
                                              setState(() {
                                                selectedTT = value as int;
                                              });
                                            },
                                            buttonHeight: 40,
                                            itemHeight: 40,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(flex: 1, child: Container()),
                                    Expanded(flex: 6, child: Container()),
                                    Expanded(flex: 5, child: Container()),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 30),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 6,
                                      child: DatePickerBoxCustomForMarkert(
                                          isTime: false,
                                          title: "Từ ngày",
                                          isBlocDate: false,
                                          isNotFeatureDate: true,
                                          flexLabel: 2,
                                          flexDatePiker: 4,
                                          label: Row(
                                            children: [
                                              Text(
                                                'Từ ngày',
                                                style: titleWidgetBox,
                                              ),
                                            ],
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
                                      flex: 6,
                                      child: DatePickerBoxCustomForMarkert(
                                          isTime: false,
                                          title: "Đến ngày",
                                          isBlocDate: false,
                                          isNotFeatureDate: true,
                                          flexLabel: 2,
                                          flexDatePiker: 4,
                                          label: Row(
                                            children: [
                                              Text(
                                                'Đến ngày',
                                                style: titleWidgetBox,
                                              ),
                                            ],
                                          ),
                                          dateDisplay: dateTo,
                                          selectedDateFunction: (day) {
                                            setState(() {
                                              dateTo = day;
                                            });
                                          }),
                                    ),
                                    Expanded(flex: 5, child: Container()),
                                  ],
                                ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.fromLTRB(50, 50, 20, 0),
                                  child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                    Container(
                                      margin: marginLeftBtn,
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: borderRadiusBtn,
                                          ),
                                          backgroundColor: (idCheck.length > 0) ? Color.fromRGBO(245, 117, 29, 1) : Color.fromARGB(255, 134, 134, 134),
                                          primary: Theme.of(context).iconTheme.color,
                                          textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                        ),
                                        onPressed: (idCheck.length > 0)
                                            ? () async {
                                                await showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) => XacNhanThanhToan(
                                                        idCheck: idCheck,
                                                        callBack: (value) {
                                                          setState(() {
                                                            listData[idChange!]["paymentStatus"] = value[0];
                                                            if (listData[idChange!]["paymentStatus"] == 1) _selected[idChange!] = false;
                                                            listData[idChange!]["paymentDate"] = value[1];
                                                            listData[idChange!]["requestFileEdited"] = value[2];
                                                            listData[idChange!]["requestNoteEdited"] = value[3];
                                                          });
                                                        }));
                                              }
                                            : null,
                                        child: Row(
                                          children: [
                                            Text('Xác nhận thanh toán', style: textButton),
                                          ],
                                        ),
                                      ),
                                    ),
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
                                              find = "";
                                              var dateFromSearch = "";
                                              var dateToSearch = "";
                                              var titleS = "";
                                              var unionS = "";
                                              var trangThaiTT = "";
                                              if (dateFrom != null)
                                                dateFromSearch = "and dueDate>:'$dateFrom' ";
                                              else
                                                dateFromSearch = "";
                                              if (dateTo != null)
                                                dateToSearch = "and dueDate<:'$dateTo 23:59:59' ";
                                              else
                                                dateToSearch = "";
                                              if (title.text.isNotEmpty) {
                                                titleS = " and title ~'%${title.text}%'";
                                              } else {
                                                titleS = "";
                                              }

                                              unionS = "  ( nghiepdoan.orgCode ~'%${union.text}%' OR nghiepdoan.orgName ~'%${union.text}%' )";

                                              if (selectedTT != -1) {
                                                trangThaiTT = " and paymentStatus:$selectedTT";
                                              }
                                              find = unionS + dateFromSearch + dateToSearch + titleS + trangThaiTT;

                                              // if (find != "") if (find.substring(0, 3) == "and") find = find.substring(4);
                                              print(find);
                                              getManagerFee(0, find);
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
                                            ))),
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
                                            var response1;
                                            if (find == "")
                                              response1 = await httpGet("/api/nghiepdoan-denghi/get/page", context);
                                            else
                                              response1 = await httpGet("/api/nghiepdoan-denghi/get/page?filter=$find", context);
                                            if (response1.containsKey("body")) {
                                              var body = jsonDecode(response1['body']);
                                              var listDataExport = body['content'] ?? [];
                                              createExcelAll(listDataExport);
                                            } else
                                              throw Exception('Không có data');
                                          },
                                          icon: Transform.rotate(
                                            angle: 270,
                                            child: Icon(
                                              Icons.upload_file,
                                              color: Colors.white,
                                              size: 15,
                                            ),
                                          ),
                                          label: Row(
                                            children: [
                                              Text('Xuất file ', style: textButton),
                                            ],
                                          ),
                                        )),
                                  ])),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: marginBoxFormTab,
                    decoration: BoxDecoration(
                      color: colorWhite,
                      boxShadow: [boxShadowContainer],
                      borderRadius: borderRadiusContainer,
                      border: borderAllContainerBox,
                    ),
                    padding: paddingBoxContainer,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Thu phí quản lý',
                              style: titleBox,
                            ),
                            Icon(
                              Icons.more_horiz,
                              color: colorIconTitleBox,
                              size: sizeIconTitleBox,
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
                              columnSpacing: 5,
                              dataTextStyle: const TextStyle(color: Color(0xff313131), fontSize: 14, fontWeight: FontWeight.w500),
                              showBottomBorder: true,
                              dataRowHeight: 60,
                              showCheckboxColumn: true,
                              dataRowColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                                if (states.contains(MaterialState.selected)) {
                                  return MaterialStateColor.resolveWith((states) => const Color(0xffeef3ff));
                                }
                                return MaterialStateColor.resolveWith((states) => Colors.white); // Use the default value.
                              }),
                              columns: <DataColumn>[
                                DataColumn(
                                  label: Text('STT', style: titleTableData),
                                ),
                                DataColumn(
                                  label: Text('Tiêu đề', style: titleTableData),
                                ),
                                DataColumn(
                                  label: Text('Nghiệp đoàn', style: titleTableData),
                                ),
                                DataColumn(
                                  label: Text('Ngày đến hạn\nthanh toán', style: titleTableData),
                                ),
                                DataColumn(
                                  label: Text('Ngày làm đề nghị', style: titleTableData),
                                ),
                                DataColumn(
                                  label: Text('File đề nghị', style: titleTableData),
                                ),
                                DataColumn(
                                  label: Text('Trạng thái', style: titleTableData),
                                ),
                                DataColumn(
                                  label: Text('Ngày thanh toán', style: titleTableData),
                                ),
                                DataColumn(
                                  label: Text('Hành động', style: titleTableData),
                                ),
                              ],
                              rows: <DataRow>[
                                for (int i = 0; i < listData.length; i++)
                                  DataRow(
                                    cells: <DataCell>[
                                      DataCell(
                                        Container(
                                          width: (MediaQuery.of(context).size.width / 10) * 0.2,
                                          child: Text("${(currentPage - 1) * rowPerPage + i + 1}"),
                                        ),
                                      ),
                                      DataCell(TextButton(
                                          onPressed: listData[i]['requestStatus'] != 1
                                              ? () async {
                                                  Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/cap-nhat-chi-tiet-phi/${listData[i]['id']}");
                                                }
                                              : null,
                                          child: Tooltip(
                                              message: listData[i]['requestStatus'] == 1 ? "Không cho phép chỉnh sửa khi trạng thái đã hoàn thành" : "Chỉnh sửa",
                                              child: Text(listData[i]['title'] + " (Chu kỳ " + listData[i]['times'].toString() + ")" ?? "",
                                                  style: TextStyle(color: listData[i]['requestStatus'] == 1 ? Colors.red : Colors.blue))))),
                                      DataCell(
                                        Text("${listData[i]['nghiepdoan']['orgName']}\n(${listData[i]['nghiepdoan']['orgCode']})"),
                                      ),
                                      DataCell(Text((listData[i]['dueDate'] != null) ? "${DateFormat('dd-MM-yyyy').format(DateTime.parse(listData[i]['dueDate']))}" : "")),
                                      DataCell(Text((listData[i]['requestDate'] != null) ? "${DateFormat('dd-MM-yyyy').format(DateTime.parse(listData[i]['requestDate']))}" : "")),
                                      DataCell(TextButton(
                                          onPressed: () async {
                                            var response =
                                                await httpGet("/api/nghiepdoan-denghi-chitiet/get/page?filter=requestId:${listData[i]['id']}&sort=groupId,desc", context);
                                            var listTTS = [];
                                            if (response.containsKey("body")) {
                                              var body = jsonDecode(response['body']);
                                              listTTS = body['content'];
                                              print(listTTS);
                                              if (listTTS.length > 0) {
                                                var mapTTS = groupBy(listTTS, (dynamic obj) {
                                                  return obj['groupId'];
                                                });
                                                createExcel(mapTTS);
                                              } else {
                                                showToast(
                                                  context: context,
                                                  msg: "Không có file",
                                                  color: colorOrange,
                                                  icon: const Icon(Icons.warning),
                                                );
                                              }
                                            }

                                            List<dynamic> listGroupId = [];

                                            var response1 =
                                                await httpGet("/api/nghiepdoan-denghi-nhom-chitiet/get/page?filter=requestId:${listData[i]['id']} AND invoiced:0", context);
                                            if (response1.containsKey("body")) {
                                              var body = jsonDecode(response1['body']);
                                              var listGroup = body['content'];
                                              for (var item in listGroup) {
                                                listGroupId.add(item['id']);
                                              }
                                            }
                                            String dk = "";
                                            for (int i = 0; i < listGroupId.length; i++) {
                                              if (i == 0) {
                                                dk += "" + listGroupId[i].toString();
                                              } else {
                                                dk += "," + listGroupId[i].toString();
                                              }
                                            }
                                            if (dk.isNotEmpty) {
                                              List<dynamic> listCTLXC = [];
                                              var responseNDDNCT = await httpGet("/api/nghiepdoan-denghi-chitiet/get/page?filter=groupId in($dk)", context);
                                              if (responseNDDNCT.containsKey("body")) {
                                                var body = jsonDecode(responseNDDNCT['body']);
                                                var listTTS = body['content'];
                                                List<dynamic> listIdTts = [];
                                                for (var item in listTTS) {
                                                  listIdTts.add(item['ttsId']);
                                                }
                                                String conditonId = listIdTts.join(',');
                                                listCTLXC = await getCTTLXC(condition: conditonId);
                                                await xuatFileHoaDon(listTTS, listCTLXC);
                                              }
                                            }
                                            //(title,orgCode,orgName,deputy,duty,address,countryName,phone,fax,email,bankAccount,documentNo,dueDate,requestDate,paymentDate,totalAmount,requestNote,requestFileEdited,requestNoteEdited)
                                            await js.context.callMethod("exportHTML", [
                                              listTTS.first['denghi']['title'],
                                              listTTS.first['denghi']['nghiepdoan']['orgCode'],
                                              listTTS.first['denghi']['nghiepdoan']['orgName'],
                                              listTTS.first['denghi']['nghiepdoan']['deputy'],
                                              listTTS.first['denghi']['nghiepdoan']['duty'],
                                              listTTS.first['denghi']['nghiepdoan']['address'],
                                              listTTS.first['denghi']['nghiepdoan']['countryName'],
                                              listTTS.first['denghi']['nghiepdoan']['phone'],
                                              listTTS.first['denghi']['nghiepdoan']['fax'],
                                              listTTS.first['denghi']['nghiepdoan']['email'],
                                              listTTS.first['denghi']['nghiepdoan']['bankAccount'],
                                              listTTS.first['denghi']['documentNo'],
                                              listTTS.first['denghi']['dueDate'],
                                              listTTS.first['denghi']['requestDate'],
                                              listTTS.first['denghi']['paymentDate'],
                                              listTTS.first['denghi']['totalAmount'],
                                              listTTS.first['denghi']['requestNote'],
                                              listTTS.first['denghi']['requestFileEdited'],
                                              listTTS.first['denghi']['requestNoteEdited'],
                                            ]);
                                          },
                                          child: Text("Tải file"))),
                                      DataCell(
                                        (listData[i]['requestStatus'] != null)
                                            ? (listData[i]['requestStatus'] == 0)
                                                ? Tooltip(
                                                    message: "Cập nhật",
                                                    child: TextButton(
                                                        onPressed: () {
                                                          Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/cap-nhat-chi-tiet-phi/${listData[i]['id']}");
                                                        },
                                                        child: Text("Nháp")),
                                                  )
                                                : (listData[i]['requestStatus'] == 1)
                                                    ? Tooltip(message: "Không cho phép chỉnh sửa khi đã hoàn thành", child: Text("Hoàn thành"))
                                                    : Text("Hủy")
                                            : Row(),
                                      ),
                                      DataCell((listData[i]['requestStatus'] == 1 && listData[i]['paymentDate'] != null && listData[i]['paymentStatus'] != 0)
                                          ? Row(
                                              children: [
                                                Text("${DateFormat('dd-MM-yyyy').format(DateTime.parse(listData[i]['paymentDate']))}"),
                                                SizedBox(width: 10),
                                                IconButton(
                                                    onPressed: () {
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) => AlertDialog(
                                                                title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
                                                                          'Xác nhận thanh toán',
                                                                          style: titleAlertDialog,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  IconButton(
                                                                    onPressed: () => {Navigator.pop(context)},
                                                                    icon: Icon(
                                                                      Icons.close,
                                                                    ),
                                                                  ),
                                                                ]),
                                                                //content
                                                                content: Container(
                                                                  width: 550,
                                                                  height: 330,
                                                                  child: Column(
                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      //đường line
                                                                      Container(
                                                                        margin: marginTopBottomHorizontalLine,
                                                                        child: Divider(
                                                                          thickness: 1,
                                                                          color: ColorHorizontalLine,
                                                                        ),
                                                                      ),
                                                                      TextFieldValidatedForm(
                                                                        type: 'None',
                                                                        height: 40,
                                                                        controller: TextEditingController(
                                                                            text: (listData[i]['paymentStatus'] == 1) ? "Thanh toán đủ" : "Thanh toán 1 phần"),
                                                                        label: 'Mô tả:',
                                                                        flexLable: 2,
                                                                        enabled: false,
                                                                      ),

                                                                      Container(
                                                                        margin: EdgeInsets.only(bottom: 30),
                                                                        child: Row(
                                                                          children: [
                                                                            Expanded(
                                                                                flex: 2,
                                                                                child: Row(
                                                                                  children: [
                                                                                    Text(
                                                                                      "Tải file",
                                                                                      style: titleWidgetBox,
                                                                                    ),
                                                                                    Container(
                                                                                      margin: EdgeInsets.only(left: 5),
                                                                                      child: Text("*",
                                                                                          style: TextStyle(
                                                                                            color: Colors.red,
                                                                                            fontSize: 16,
                                                                                          )),
                                                                                    ),
                                                                                  ],
                                                                                )),
                                                                            Expanded(
                                                                                flex: 5,
                                                                                child: IconButton(
                                                                                    onPressed: () {
                                                                                      downloadFile(listData[i]['requestFileEdited']);
                                                                                    },
                                                                                    icon: Icon(Icons.download)))
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      TextFieldValidatedForm(
                                                                        type: 'None',
                                                                        height: 40,
                                                                        controller: TextEditingController(
                                                                            text: (listData[i]['paymentStatus'] == 1) ? "Thanh toán đủ" : "Thanh toán 1 phần"),
                                                                        label: 'Ngày thanh toán:',
                                                                        flexLable: 2,
                                                                        enabled: false,
                                                                      ),
                                                                      TextFieldValidatedForm(
                                                                        type: 'None',
                                                                        height: 40,
                                                                        controller: TextEditingController(
                                                                            text: (listData[i]['requestNoteEdited'] != null) ? listData[i]['requestNoteEdited'] : ""),
                                                                        label: 'Mô tả:',
                                                                        flexLable: 2,
                                                                        enabled: false,
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                                //actions
                                                                actions: [],
                                                              ));
                                                    },
                                                    icon: Icon(Icons.visibility)),
                                              ],
                                            )
                                          : Text("")),
                                      DataCell(Row(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                            child: Tooltip(
                                              message: "Xem chi tiết",
                                              child: InkWell(
                                                onTap: () {
                                                  Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/chi-tiet-de-nghi/${listData[i]['id']}");
                                                },
                                                child: Icon(Icons.visibility),
                                              ),
                                            ),
                                          ),
                                          Container(
                                              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                              child: Tooltip(
                                                message:
                                                    listData[i]['requestStatus'] == 0 ? "Chỉnh sửa đề nghị" : "Không cho phép sửa đề nghị khi ở trạng thái hoàn thành và đã hủy",
                                                child: InkWell(
                                                    onTap: listData[i]['requestStatus'] == 0
                                                        ? () {
                                                            Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/cap-nhat-chi-tiet-phi/${listData[i]['id']}");
                                                          }
                                                        : null,
                                                    child: Icon(
                                                      Icons.edit_calendar,
                                                      color: listData[i]['requestStatus'] == 0 ? Color(0xff009C87) : Colors.grey,
                                                    )),
                                              )),
                                          Container(
                                              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                              child: Tooltip(
                                                message: listData[i]['requestStatus'] == 0 ? "Hủy đề nghị" : "Chỉ trạng thái nháp mới hủy được đề nghị",
                                                child: InkWell(
                                                    onTap: listData[i]['requestStatus'] == 0
                                                        ? () async {
                                                            showDialog(
                                                              context: context,
                                                              builder: (BuildContext context) => XacNhanXoaXiNghiep(
                                                                label: "Bạn có muốn gủy đề nghị ?",
                                                                function: () async {
                                                                  processing();
                                                                  listData[i]['requestStatus'] = 2;
                                                                  await httpPut('/api/nghiepdoan-denghi/put/${listData[i]['id']}', listData[i], context);

                                                                  var responseTts =
                                                                      await httpGet("/api/nghiepdoan-denghi-chitiet/get/page?filter=requestId:${listData[i]['id']}", context);
                                                                  var bodyTts = jsonDecode(responseTts['body']);
                                                                  if (responseTts.containsKey("body")) {
                                                                    for (var itemTts in bodyTts['content']) {
                                                                      itemTts['deleted'] = true;
                                                                      await httpPut('/api/nghiepdoan-denghi-chitiet/put/' + itemTts['id'].toString(), itemTts, context);
                                                                    }
                                                                  }
                                                                  var responseNhom =
                                                                      await httpGet("/api/nghiepdoan-denghi-nhom-chitiet/get/page?filter=requestId:${listData[i]['id']}", context);
                                                                  var bodyNhom = jsonDecode(responseNhom['body']);
                                                                  if (responseNhom.containsKey("body")) {
                                                                    for (var itemNhom in bodyNhom['content']) {
                                                                      itemNhom['deleted'] = true;
                                                                      await httpPut('/api/nghiepdoan-denghi-nhom-chitiet/put/' + itemNhom['id'].toString(), itemNhom, context);
                                                                    }
                                                                  }

                                                                  await getManagerFee(0, "");
                                                                  showToast(context: context, msg: "", color: Colors.green, icon: Icon(Icons.done));
                                                                  Navigator.pop(context);
                                                                },
                                                              ),
                                                            );
                                                          }
                                                        : null,
                                                    child: Icon(
                                                      Icons.delete_outlined,
                                                      color: listData[i]['requestStatus'] == 0 ? Colors.red : Colors.grey,
                                                    )),
                                              )),
                                        ],
                                      )),
                                    ],
                                    selected: _selected[i],
                                    onSelectChanged: (bool? value) {
                                      if (_selected.contains(true)) {
                                        if (value == false)
                                          setState(() {
                                            _selected[i] = value!;
                                            idCheck.clear();
                                          });
                                      } else {
                                        if (listData[i]['requestStatus'] == 1 && listData[i]['paymentStatus'] != 1)
                                          setState(() {
                                            _selected[i] = value!;
                                            idCheck.clear();
                                            for (int j = 0; j < _selected.length; j++)
                                              if (_selected[j] == true) {
                                                idCheck.add(listData[j]);
                                                idChange = j;
                                              }
                                          });
                                      }
                                    },
                                  ),
                              ],
                            )),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 50),
                          child: DynamicTablePagging(
                            rowCount,
                            currentPage,
                            rowPerPage,
                            pageChangeHandler: (page) {
                              setState(() {
                                getManagerFee(page - 1, find);
                              });
                            },
                            rowPerPageChangeHandler: (rowPerPage) {
                              setState(() {
                                getManagerFee(page - 1, find);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Center(child: CircularProgressIndicator()));
  }
}
