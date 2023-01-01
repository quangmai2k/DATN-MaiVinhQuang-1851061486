import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../api.dart';
import '../../../common/style.dart';
import '../../../common/toast.dart';
import '../../../common/widgets_form.dart';
import '../../../model/model.dart';
import '../../forms/nhan_su/setting-data/timekeeping-detailed.dart';
import '../../ui/navigation.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row;
import 'package:universal_html/html.dart' show AnchorElement;
import 'package:gentelella_flutter/widgets/forms/nhan_su/setting-data/timekeeping-detailed.dart';
import "package:collection/collection.dart";

import 'package:flutter/foundation.dart';

import 'tabbar-sua-cham-cong.dart';

class UpdateTimeKeeping extends StatefulWidget {
  String idCC;
  UpdateTimeKeeping({
    Key? key,
    required this.idCC,
  }) : super(key: key);

  @override
  State<UpdateTimeKeeping> createState() => _UpdateTimeKeepingState();
}

class _UpdateTimeKeepingState extends State<UpdateTimeKeeping> {
  List<TimeKeepingDetailed> timeKeepingData = [];
  late Future<List<TimeKeepingDetailed>> futureTimekeeping;
  var listNVCC = {};
  var forMatNumber = NumberFormat("###.#", "en_US");
  getChamCongCT(idCC) async {
    var response = await httpGet("/api/chamcong-chitiet/get/page?filter=chamcongId:$idCC and userId is not null&sort=id", context);
    var content = [];
    var body = jsonDecode(response['body']);
    if (response.containsKey("body")) {
      setState(() {
        content = body['content'];

        timeKeepingData = content.map((e) {
          return TimeKeepingDetailed.fromJson(e);
        }).toList();
        listNVCC = groupBy(timeKeepingData, (dynamic obj) {
          return obj.userCode;
        });
        for (var element in listNVCC.keys) {
          if (listNVCC[element].length > 1) {
            listNVCC[element][0].short = 0;
            for (var i = 0; i < listNVCC[element].length; i++) {
              if (listNVCC[element][i].thu != "CN") {
                if (listNVCC[element][i].timeIn == "" || listNVCC[element][i].timeOut == "")
                  listNVCC[element][0].short = listNVCC[element][0].short + 1;
              }
            }
          }
        }
      });
      return listNVCC;
    }
    return listNVCC;
  }

  DateFormat dateFormat = DateFormat("dd-MMM-yyyy");
  String fileNameExport = "";
  Future<void> createExcel(var listNVCC) async {
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
      10: "J",
      11: "K",
      12: "L",
      13: "M",
      14: "N",
      15: "O",
      16: "P",
      17: "Q",
      18: "R",
      19: "S",
      20: "T",
      21: "U",
      22: "V",
      23: "W",
      24: "X",
      25: "Y",
      26: "Z",
      27: "AA",
      28: "AB",
      29: "AC",
      30: "AD",
      31: "AE",
      32: "AF",
      33: "AG",
      34: "AH",
      35: "AI",
      36: "AJ",
      37: "AK",
      38: "AL",
      39: "AM",
      40: "AN",
      41: "AO",
      42: "AP",
      43: "AQ",
      44: "AR",
      45: "AS",
      46: "AT",
      47: "AU",
      48: "AV",
    };
    int check = listNVCC[listNVCC.keys.first].length;
    print("check:$check");
    int stt = listNVCC.keys.length;
    sheet.getRangeByName('A1:AV430').cellStyle.fontSize = 10;
    sheet.getRangeByName('A1:AV430').cellStyle.fontName = "Arial";
    sheet.getRangeByName('A1:AV430').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('A1:AV430').cellStyle.vAlign = VAlignType.center;
    sheet.getRangeByName('A2').setText('AAM');
    sheet.getRangeByName('A2').cellStyle.fontSize = 14;
    sheet.getRangeByName('A2').cellStyle.bold = true;
    // sheet.getRangeByName('A2').cellStyle.borders.all.lineStyle= LineStyle.thin;
    var monthWork = DateFormat('MM-yyyy').format(listNVCC[listNVCC.keys.first][0].workingDay);
    sheet.getRangeByName('A3').setText('BẢNG CHẤM CÔNG THÁNG $monthWork');
    sheet.getRangeByName('A3').cellStyle.bold = true;
    sheet.getRangeByName('A3').cellStyle.fontSize = 14;
    sheet.getRangeByName('A3:${index[17 + check]}3').merge();
    //bảng dữ liệu
    sheet.getRangeByName('A1').columnWidth = 5.1;
    sheet.getRangeByName('B1:G1').columnWidth = 25;
    for (var i = 0; i < check; i++) sheet.getRangeByIndex(1, 8 + i).columnWidth = 4.5;
    sheet.getRangeByIndex(1, 8 + check).columnWidth = 6.9;
    sheet.getRangeByIndex(1, 9 + check).columnWidth = 6.9;
    sheet.getRangeByIndex(1, 10 + check).columnWidth = 6.9;
    sheet.getRangeByIndex(1, 11 + check).columnWidth = 6.9;
    sheet.getRangeByIndex(1, 12 + check).columnWidth = 6.9;
    sheet.getRangeByIndex(5, 8 + check).cellStyle.hAlign = HAlignType.justify;
    sheet.getRangeByIndex(5, 9 + check).cellStyle.hAlign = HAlignType.justify;
    sheet.getRangeByIndex(5, 10 + check).cellStyle.hAlign = HAlignType.justify;
    sheet.getRangeByIndex(5, 11 + check).cellStyle.hAlign = HAlignType.justify;
    sheet.getRangeByIndex(5, 12 + check).cellStyle.hAlign = HAlignType.justify;
    sheet.getRangeByIndex(5, 13 + check).cellStyle.hAlign = HAlignType.justify;
    sheet.getRangeByIndex(5, 14 + check).cellStyle.hAlign = HAlignType.justify;
    sheet.getRangeByIndex(5, 15 + check).cellStyle.hAlign = HAlignType.justify;
    sheet.getRangeByIndex(5, 16 + check).cellStyle.hAlign = HAlignType.justify;
    sheet.getRangeByIndex(1, 13 + check).columnWidth = 6.9;
    sheet.getRangeByName('A5').rowHeight = 89.25;
    sheet.getRangeByIndex(5, 1, 6, check + 8).cellStyle.backColor = '#C4D79B';
    sheet.getRangeByIndex(5, check + 8, 6, check + 16).cellStyle.backColor = '#fcd6b4';
    sheet.getRangeByIndex(5, check + 17, 6, check + 17).cellStyle.backColor = '#C4D79B';
    sheet.getRangeByIndex(5, 1, 6 + stt, check + 17).cellStyle.borders.all.lineStyle = LineStyle.thin;
    sheet.getRangeByIndex(5, 1, 5, 7).cellStyle.bold = true;
    sheet.getRangeByIndex(5, 7 + check, 5, 17 + check).cellStyle.bold = true;
    sheet.getRangeByName('A5').setText('STT');
    sheet.getRangeByName('B5').setText('Mã nhân viên');
    sheet.getRangeByName('C5').setText('Mã chấm công');
    sheet.getRangeByName('D5').setText('Họ tên');
    sheet.getRangeByName('E5').setText('Vị trí');
    sheet.getRangeByName('F5').setText('Phòng ban');
    sheet.getRangeByName('G5').setText('Nhóm');
    List<int> cn = [];
    for (var i = 0; i < check; i++) {
      var workingDay = DateFormat('dd-MM-yyyy').format(listNVCC[listNVCC.keys.first][i].workingDay);
      var ngay = double.parse(workingDay.substring(0, 2));
      sheet.getRangeByIndex(5, 8 + i).setNumber(ngay);
      if (listNVCC[listNVCC.keys.first][i].thu == "CN") {
        sheet.getRangeByIndex(6, 8 + i).setText('CN');
        cn.add(i);
      }
      if (listNVCC[listNVCC.keys.first][i].thu == "Hai") sheet.getRangeByIndex(6, 8 + i).setText('T2');
      if (listNVCC[listNVCC.keys.first][i].thu == "Ba") sheet.getRangeByIndex(6, 8 + i).setText('T3');
      if (listNVCC[listNVCC.keys.first][i].thu == "Tư") sheet.getRangeByIndex(6, 8 + i).setText('T4');
      if (listNVCC[listNVCC.keys.first][i].thu == "Năm") sheet.getRangeByIndex(6, 8 + i).setText('T5');
      if (listNVCC[listNVCC.keys.first][i].thu == "Sáu") sheet.getRangeByIndex(6, 8 + i).setText('T6');
      if (listNVCC[listNVCC.keys.first][i].thu == "Bảy") sheet.getRangeByIndex(6, 8 + i).setText('T7');
    }
    if (cn.length > 0) for (var i = 0; i < cn.length; i++) sheet.getRangeByIndex(7, 8 + cn[i], 6 + stt, 8 + cn[i]).cellStyle.backColor = '#fcd6b4';

    sheet.getRangeByIndex(5, 8 + check).setText('Tổng NC Tính lương tháng');
    sheet.getRangeByIndex(5, 9 + check).setText('Tổng ngày nghỉ phép hưởng lương');
    sheet.getRangeByIndex(5, 10 + check).setText('Tổng ngày nghỉ chế độ, lễ tết, TS');
    sheet.getRangeByIndex(5, 11 + check).setText('Tổng ngày đi công tác');
    sheet.getRangeByIndex(5, 12 + check).setText('Tổng nghỉ không lương');
    sheet.getRangeByIndex(5, 13 + check).setText('Tổng giờ làm');
    sheet.getRangeByIndex(5, 14 + check).setText('Thiếu\n(giờ)');
    sheet.getRangeByIndex(5, 15 + check).setText('Đi muộn');
    sheet.getRangeByIndex(5, 16 + check).setText('Về sớm');
    sheet.getRangeByIndex(5, 17 + check).setText('Ghi chú');

    sheet.getRangeByIndex(8 + stt, 12).setText('BAN LÃNH ĐẠO');
    sheet.getRangeByIndex(8 + stt, 19).setText('PHÒNG HCNS');
    sheet.getRangeByIndex(8 + stt, 27).setText('TRƯỞNG BP');
    sheet.getRangeByIndex(8 + stt, 33).setText('NGƯỜI LẬP BẢNG');
    sheet.getRangeByIndex(8 + stt, 12, 8 + stt, 33).cellStyle.bold = true;

    sheet.getRangeByIndex(11 + stt, 2).setText('Ghi chú: Để đơn giản, sử dụng các ký tự viết tắt trong bảng chấm công như sau:');
    sheet.getRangeByIndex(11 + stt, 2).cellStyle.italic = true;
    sheet.getRangeByIndex(11 + stt, 2).cellStyle.underline = true;
    sheet.getRangeByIndex(11 + stt, 2).cellStyle.hAlign = HAlignType.left;

    sheet.getRangeByIndex(12 + stt, 2).setText('NỘI DUNG');
    sheet.getRangeByIndex(12 + stt, 3).setText('KÝ HIỆU');
    sheet.getRangeByIndex(12 + stt, 4).setText('TÍNH CÔNG');
    sheet.getRangeByIndex(12 + stt, 4).cellStyle.hAlign = HAlignType.left;
    sheet.getRangeByIndex(12 + stt, 2, 12 + stt, 4).cellStyle.bold = true;
    sheet.getRangeByIndex(13 + stt, 2).setText('Ngày công làm việc (Ngày T7 tính là 1 ngày làm việc)');
    sheet.getRangeByIndex(13 + stt, 3).setText('1');
    sheet.getRangeByIndex(13 + stt, 4).setNumber(1);
    sheet.getRangeByIndex(13 + stt, 4).rowHeight = 44;
    sheet.getRangeByIndex(14 + stt, 2).setText('Nghỉ phép');
    sheet.getRangeByIndex(14 + stt, 3).setText('P');
    sheet.getRangeByIndex(14 + stt, 4).setNumber(1);
    sheet.getRangeByIndex(15 + stt, 2).setText('Nghỉ phép nửa ngày, nửa ngày còn lại làm việc, có lương');
    sheet.getRangeByIndex(15 + stt, 3).setText('P/2');
    sheet.getRangeByIndex(15 + stt, 4).setNumber(1);
    sheet.getRangeByIndex(15 + stt, 4).rowHeight = 44;
    sheet.getRangeByIndex(16 + stt, 2).setText('Nghỉ phép nửa ngày, nửa ngày còn lại nghỉ ko lương (hoặc ko làm việc)');
    sheet.getRangeByIndex(16 + stt, 3).setText('NP/2');
    sheet.getRangeByIndex(16 + stt, 4).setNumber(0.5);
    sheet.getRangeByIndex(16 + stt, 4).rowHeight = 44;
    sheet.getRangeByIndex(17 + stt, 2).setText('Nghỉ cá nhân theo chế độ (Hiếu, hỉ, …)');
    sheet.getRangeByIndex(17 + stt, 3).setText('NC');
    sheet.getRangeByIndex(17 + stt, 4).setNumber(1);
    sheet.getRangeByIndex(17 + stt, 4).rowHeight = 25;
    sheet
        .getRangeByIndex(17 + stt, 6)
        .setText('Không thuộc ngày nghỉ P năm: Nghỉ kết hôn: 03 ngày; Nghỉ đám hiếu tứ thân phụ mẫu: 03 ngày; Nghỉ con kết hôn: 01 ngày; ');
    sheet.getRangeByIndex(17 + stt, 6).cellStyle.hAlign = HAlignType.left;
    sheet.getRangeByIndex(18 + stt, 2).setText('Nghỉ lễ tết (30/4, 1/5, …theo quy định NN)');
    sheet.getRangeByIndex(18 + stt, 3).setText('NL');
    sheet.getRangeByIndex(18 + stt, 4).setNumber(1);
    sheet.getRangeByIndex(18 + stt, 4).rowHeight = 25;
    sheet.getRangeByIndex(19 + stt, 2).setText('Công tác');
    sheet.getRangeByIndex(19 + stt, 3).setText('CT');
    sheet.getRangeByIndex(19 + stt, 4).setNumber(1);
    sheet.getRangeByIndex(20 + stt, 2).setText('Nghỉ không lương (có phép) cả ngày');
    sheet.getRangeByIndex(20 + stt, 3).setText('KLP');
    sheet.getRangeByIndex(20 + stt, 4).setNumber(0);
    sheet.getRangeByIndex(20 + stt, 4).rowHeight = 25;
    sheet.getRangeByIndex(21 + stt, 2).setText('Nghỉ không lương (có phép) nửa ngày');
    sheet.getRangeByIndex(21 + stt, 3).setText('KLP/2');
    sheet.getRangeByIndex(21 + stt, 4).setNumber(0.5);
    sheet.getRangeByIndex(21 + stt, 4).rowHeight = 25;
    sheet.getRangeByIndex(22 + stt, 2).setText('Nghỉ thai sản');
    sheet.getRangeByIndex(22 + stt, 3).setText('TS');
    sheet.getRangeByIndex(22 + stt, 4).setNumber(1);
    sheet.getRangeByIndex(12 + stt, 2, 22 + stt, 4).cellStyle.borders.all.lineStyle = LineStyle.thin;
    sheet.getRangeByIndex(12 + stt, 2, 22 + stt, 2).cellStyle.hAlign = HAlignType.justify;

    for (var i = 0; i < listNVCC.keys.length; i++) {
      double sumHourWork = 0;
      double sumHourWorkShort = 0;
      int sumBeLate = 0;
      int sumBackSoon = 0;
      sheet.getRangeByIndex(7 + i, 1).setNumber(i + 1);
      sheet.getRangeByIndex(7 + i, 2).setText('${listNVCC[listNVCC.keys.toList()[i]][0].userCode}');
      sheet.getRangeByIndex(7 + i, 3).setText('${listNVCC[listNVCC.keys.toList()[i]][0].timeKeepingCode}');
      sheet.getRangeByIndex(7 + i, 4).setText('${listNVCC[listNVCC.keys.toList()[i]][0].fullName}');
      sheet.getRangeByIndex(7 + i, 5).setText('${listNVCC[listNVCC.keys.toList()[i]][0].dutyName}');
      sheet.getRangeByIndex(7 + i, 6).setText('${listNVCC[listNVCC.keys.toList()[i]][0].departName}');
      sheet.getRangeByIndex(7 + i, 7).setText('${listNVCC[listNVCC.keys.toList()[i]][0].teamName}');
      for (var j = 0; j < check; j++) {
        if (listNVCC[listNVCC.keys.toList()[i]][j].kh == "X")
          sheet.getRangeByIndex(7 + i, 8 + j).setNumber(1);
        else if (listNVCC[listNVCC.keys.toList()[i]][j].kh == "**") {
          if (listNVCC[listNVCC.keys.toList()[i]][j].thu != "Bảy")
            sheet.getRangeByIndex(7 + i, 8 + j).setText("KLP/2");
          else
            sheet.getRangeByIndex(7 + i, 8 + j).setNumber(1);
        } else if (listNVCC[listNVCC.keys.toList()[i]][j].kh == "V")
          sheet.getRangeByIndex(7 + i, 8 + j).setText("KLP");
        else if (listNVCC[listNVCC.keys.toList()[i]][j].kh == "KR") {
          if (listNVCC[listNVCC.keys.toList()[i]][j].thu != "CN") sheet.getRangeByIndex(7 + i, 8 + j).setText("KLP");
        } else if (listNVCC[listNVCC.keys.toList()[i]][j].kh == "Off") {
          if (listNVCC[listNVCC.keys.toList()[i]][j].thu != "CN") sheet.getRangeByIndex(7 + i, 8 + j).setText("KLP");
        }
        double hourWork = 0;
        if (listNVCC[listNVCC.keys.toList()[i]][j].timeOut != "" && listNVCC[listNVCC.keys.toList()[i]][j].timeIn != "") {
          DateTime vao = DateTime.parse("1944-06-06T${listNVCC[listNVCC.keys.toList()[i]][j].timeIn}:00.000");
          DateTime ra = DateTime.parse("1944-06-06T${listNVCC[listNVCC.keys.toList()[i]][j].timeOut}:00.000");
          var difference = ra.difference(vao);
          if (difference.inMinutes > 300) {
            sumHourWork += (difference.inMinutes - 60);
            hourWork = (difference.inMinutes - 60);
          } else {
            sumHourWork += (difference.inMinutes - 0);
            hourWork = (difference.inMinutes - 0);
          }
        } else
          hourWork = 0;
        if (listNVCC[listNVCC.keys.toList()[i]][j].thu == "CN") {
        } else if (listNVCC[listNVCC.keys.toList()[i]][j].thu == "Bảy") {
          if (hourWork < 240) sumHourWorkShort = sumHourWorkShort + hourWork - 240;
        } else {
          if (hourWork < 480) sumHourWorkShort = sumHourWorkShort + hourWork - 480;
        }
        if (listNVCC[listNVCC.keys.toList()[i]][j].beLate == 1) {
          sumBeLate += 1;
        }
        if (listNVCC[listNVCC.keys.toList()[i]][j].backSoon == 1) {
          sumBackSoon += 1;
        }
      }
      //Tổng ngày công tính lương tháng
      String sumNC = "=COUNTIF(H${7 + i}:${index[7 + check]}${7 + i},\$${index[3]}\$${13 + stt})*\$${index[4]}\$${13 + stt}+" +
          "COUNTIF(H${7 + i}:${index[7 + check]}${7 + i},\$${index[3]}\$${14 + stt})*\$${index[4]}\$${14 + stt}+" +
          "COUNTIF(H${7 + i}:${index[7 + check]}${7 + i},\$${index[3]}\$${15 + stt})*\$${index[4]}\$${15 + stt}+" +
          "COUNTIF(H${7 + i}:${index[7 + check]}${7 + i},\$${index[3]}\$${16 + stt})*\$${index[4]}\$${16 + stt}+" +
          "COUNTIF(H${7 + i}:${index[7 + check]}${7 + i},\$${index[3]}\$${17 + stt})*\$${index[4]}\$${17 + stt}+" +
          "COUNTIF(H${7 + i}:${index[7 + check]}${7 + i},\$${index[3]}\$${18 + stt})*\$${index[4]}\$${18 + stt}+" +
          "COUNTIF(H${7 + i}:${index[7 + check]}${7 + i},\$${index[3]}\$${19 + stt})*\$${index[4]}\$${19 + stt}+" +
          "COUNTIF(H${7 + i}:${index[7 + check]}${7 + i},\$${index[3]}\$${20 + stt})*\$${index[4]}\$${20 + stt}+" +
          "COUNTIF(H${7 + i}:${index[7 + check]}${7 + i},\$${index[3]}\$${21 + stt})*\$${index[4]}\$${21 + stt}+" +
          "COUNTIF(H${7 + i}:${index[7 + check]}${7 + i},\$${index[3]}\$${22 + stt})*\$${index[4]}\$${22 + stt}";
      sheet.getRangeByIndex(7 + i, 8 + check).setFormula(sumNC);
      sheet.getRangeByIndex(7 + i, 8 + check).cellStyle.bold = true;

      //Tổng ngày nghỉ phép hưởng lương
      String sumNNPHL = "=COUNTIF(H${7 + i}:${index[7 + check]}${7 + i},\$${index[3]}\$${14 + stt})+" +
          "COUNTIF(H${7 + i}:${index[7 + check]}${7 + i},\$${index[3]}\$${15 + stt})/2+" +
          "COUNTIF(H${7 + i}:${index[7 + check]}${7 + i},\$${index[3]}\$${16 + stt})/2";
      sheet.getRangeByIndex(7 + i, 9 + check).setFormula(sumNNPHL);

      //Tổng ngày nghỉ chế độ, lễ tết, TS
      String sumNNLCD = "=COUNTIF(H${7 + i}:${index[7 + check]}${7 + i},\$${index[3]}\$${17 + stt})+" +
          "COUNTIF(H${7 + i}:${index[7 + check]}${7 + i},\$${index[3]}\$${18 + stt})+" +
          "COUNTIF(H${7 + i}:${index[7 + check]}${7 + i},\$${index[3]}\$${22 + stt})";
      sheet.getRangeByIndex(7 + i, 10 + check).setFormula(sumNNLCD);
      //Tổng ngày đi công tác
      String sumCT = "=COUNTIF(H${7 + i}:${index[7 + check]}${7 + i},\$${index[3]}\$${19 + stt})";
      sheet.getRangeByIndex(7 + i, 11 + check).setFormula(sumCT);
      //Tổng ngày nghỉ không lương
      String sumNKT = "=COUNTIF(H${7 + i}:${index[7 + check]}${7 + i},\$${index[3]}\$${20 + stt})+" +
          "COUNTIF(H${7 + i}:${index[7 + check]}${7 + i},\$${index[3]}\$${21 + stt})/2";
      sheet.getRangeByIndex(7 + i, 12 + check).setFormula(sumNKT);
      sheet.getRangeByIndex(7 + i, 13 + check).setText("${forMatNumber.format(sumHourWork / 60)}");
      sheet.getRangeByIndex(7 + i, 14 + check).setText("${forMatNumber.format(sumHourWorkShort / 60)}");
      sheet.getRangeByIndex(7 + i, 15 + check).setNumber(sumBeLate as double);
      sheet.getRangeByIndex(7 + i, 16 + check).setNumber(sumBackSoon as double);
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    if (kIsWeb) {
      AnchorElement(href: 'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
        ..setAttribute('download', 'Output.xlsx')
        ..click();
      var result;
      result = await uploadFileByter(bytes, context: context);
      setState(() {
        fileNameExport = result;
      });
      await updateTimeKeeping(fileNameExport);
    }
  }

  updateTimeKeeping(String fileNameExport) async {
    bool result = false;
    var requestBody = {"fileEditedLatest": fileNameExport};
    var response = await httpPut("/api/chamcong/put/${widget.idCC}", requestBody, context);
    if (response.containsKey('body')) {
      result = jsonDecode(response['body']);
      return result;
    }
    return result;
  }

  updateTimeKeepingDetailed(var listNVCC) async {
    var result;
    List<dynamic> lstObj = [];
    for (var element in listNVCC.keys) {
      for (var i = 0; i < listNVCC[element].length; i++) {
        String dayWorking = DateFormat('yyyy-MM-dd').format(listNVCC[element][i].workingDay);
        var request;
        if (listNVCC[element][i].timeIn != "" && listNVCC[element][i].timeOut != "")
          request = {
            "id": listNVCC[element][i].id,
            "timeIn": "${dayWorking}T${listNVCC[element][i].timeIn}:00.000+00:00",
            "timeOut": "${dayWorking}T${listNVCC[element][i].timeOut}:00.000+00:00",
            "beLate": listNVCC[element][i].beLate,
            "backSoon": listNVCC[element][i].backSoon,
            "notation": listNVCC[element][i].kh
          };
        else if (listNVCC[element][i].timeIn != "")
          request = {
            "id": listNVCC[element][i].id,
            "timeIn": "${dayWorking}T${listNVCC[element][i].timeIn}:00.000+00:00",
            "timeOut": null,
            "beLate": listNVCC[element][i].beLate,
            "backSoon": listNVCC[element][i].backSoon,
            "notation": listNVCC[element][i].kh
          };
        else if (listNVCC[element][i].timeOut != "")
          request = {
            "id": listNVCC[element][i].id,
            "timeIn": null,
            "timeOut": "${dayWorking}T${listNVCC[element][i].timeOut}:00.000+00:00",
            "beLate": listNVCC[element][i].beLate,
            "backSoon": listNVCC[element][i].backSoon,
            "notation": listNVCC[element][i].kh
          };
        else
          request = {
            "id": listNVCC[element][i].id,
            "timeIn": null,
            "timeOut": null,
            "beLate": listNVCC[element][i].beLate,
            "backSoon": listNVCC[element][i].backSoon,
            "notation": listNVCC[element][i].kh
          };
        // print(request);

        lstObj.add(request);
      }
    }
    print(lstObj.length);
    var response = await httpPut("/api/chamcong-chitiet/put/all", lstObj, context);
    print(response);
    if (response.containsKey("body")) {
      result = jsonDecode(response['body']);

      return result;
    }
    return result;
  }

  bool status = false;
  void callAPI() async {
    await getChamCongCT(widget.idCC);
    setState(() {
      status = true;
    });
  }

  @override
  void initState() {
    super.initState();
    callAPI();
  }

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
        widgetBody: FutureBuilder<dynamic>(
      future: userRule('/sua-cham-cong', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return Consumer<NavigationModel>(
              builder: (context, navigationModel, child) => (status)
                  ? SingleChildScrollView(
                      controller: ScrollController(),
                      child: Column(children: [
                        TitlePage(
                          listPreTitle: [
                            {'url': "/nhan-su", 'title': 'Dashboard'},
                            {'url': "/cham-cong", 'title': 'Chấm công'},
                          ],
                          content: 'Cập nhật',
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: borderAllContainerBox,
                            color: colorWhite,
                            borderRadius: borderRadiusContainer,
                            boxShadow: [boxShadowContainer],
                          ),
                          padding: EdgeInsets.all(20),
                          margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 30,
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text('Tháng', style: titleWidgetBox),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Container(
                                          child: Text(
                                              (timeKeepingData.length > 0)
                                                  ? "${timeKeepingData[0].timekeepingMonth.toString().substring(5, 7)}/${timeKeepingData[0].timekeepingMonth.toString().substring(0, 4)}"
                                                  : "",
                                              style: titleWidgetBox),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(''),
                              ),
                              Expanded(
                                flex: 1,
                                child: getRule(listRule.data, Role.Sua, context)
                                    ? Container(
                                        // margin: EdgeInsets.only(left: 20),
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 20,
                                              horizontal: 30.0,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(5.0),
                                            ),
                                            backgroundColor:
                                                (listNVCC.keys.length > 0) ? Color.fromRGBO(245, 117, 29, 1) : Color.fromARGB(255, 192, 192, 192),
                                            primary: Theme.of(context).iconTheme.color,
                                            textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                          ),
                                          onPressed: (listNVCC.keys.length > 0)
                                              ? () async {
                                                  var result = await updateTimeKeepingDetailed(listNVCC);
                                                  if (result == true) {
                                                    // Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/cham-cong");
                                                    Navigator.pop(context);
                                                    showToast(
                                                      context: context,
                                                      msg: "Cập nhật chấm công chi tiết thành công",
                                                      color: Color.fromARGB(136, 72, 238, 67),
                                                      icon: const Icon(Icons.done),
                                                    );
                                                  } else {
                                                    showToast(
                                                      context: context,
                                                      msg: "Lưu thất bại. Kiển tra lại dữ liệu nhập",
                                                      color: colorOrange,
                                                      icon: const Icon(Icons.warning),
                                                    );
                                                  }
                                                }
                                              : null,
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text('Lưu', style: textButton),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  // margin: EdgeInsets.only(left: 20),
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 20,
                                        horizontal: 30.0,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5.0),
                                      ),
                                      backgroundColor: Color.fromRGBO(245, 117, 29, 1),
                                      primary: Theme.of(context).iconTheme.color,
                                      textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('Trở về', style: textButton),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                flex: 1,
                                child: getRule(listRule.data, Role.Xem, context)
                                    ? Container(
                                        // margin: EdgeInsets.only(left: 20),
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 20,
                                              // horizontal: 30.0,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(5.0),
                                            ),
                                            backgroundColor:
                                                (listNVCC.keys.length > 0) ? Color.fromRGBO(245, 117, 29, 1) : Color.fromARGB(255, 192, 192, 192),
                                            primary: Theme.of(context).iconTheme.color,
                                            textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                          ),
                                          onPressed: (listNVCC.keys.length > 0)
                                              ? () async {
                                                  await createExcel(listNVCC);
                                                  var result = await updateTimeKeeping(fileNameExport);
                                                  if (result == true) {
                                                    showToast(
                                                      context: context,
                                                      msg: "Đã tải file chấm công lên server",
                                                      color: Color.fromARGB(136, 72, 238, 67),
                                                      icon: const Icon(Icons.done),
                                                    );
                                                  }
                                                }
                                              : null,
                                          child: Text(
                                            'Xuất file',
                                            style: textButton,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                    : Container(),
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                flex: 1,
                                child: getRule(listRule.data, Role.Xem, context)
                                    ? Container(
                                        // margin: EdgeInsets.only(left: 20),
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 20,
                                              // horizontal: 30.0,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(5.0),
                                            ),
                                            backgroundColor:
                                                (listNVCC.keys.length > 0) ? Color.fromRGBO(245, 117, 29, 1) : Color.fromARGB(255, 192, 192, 192),
                                            primary: Theme.of(context).iconTheme.color,
                                            textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                          ),
                                          onPressed: (listNVCC.keys.length > 0)
                                              ? () async {
                                                  downloadFile(timeKeepingData[0].fileOrigin.toString());
                                                }
                                              : null,
                                          child: Text(
                                            'Bản gốc',
                                            style: textButton,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                    : Container(),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(''),
                              ),
                            ],
                          ),
                        ),
                        (listNVCC.keys.length > 0)
                            ? TabBarSuaChamCong(listNVCC: listNVCC)
                            : Column(
                                children: [
                                  Icon(Icons.no_accounts),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text("Không có người dùng nào trong hệ thống"),
                                ],
                              ),
                        Footer(marginFooter: EdgeInsets.only(top: 5), paddingFooter: EdgeInsets.all(15)),
                        SizedBox(height: 20)
                      ]),
                    )
                  : Container(
                      margin: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 30),
                      width: MediaQuery.of(context).size.width * 1,
                      padding: EdgeInsets.only(top: 20, bottom: 20),
                      decoration: BoxDecoration(
                        color: colorWhite,
                        borderRadius: borderRadiusContainer,
                        boxShadow: [boxShadowContainer],
                        border: borderAllContainerBox,
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.hourglass_bottom),
                          SizedBox(
                            height: 10,
                          ),
                          Text("Đang tải, vui lòng đợi"),
                        ],
                      )));
        } else if (listRule.hasError) {
          return Text('${listRule.error}');
        }

        // By default, show a loading spinner.
        return Center(child: CircularProgressIndicator());
      },
    ));
  }
}
