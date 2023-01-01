// ignore_for_file: must_be_immutable, unused_import, undefined_hidden_name
import 'dart:convert';
import 'dart:html';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/nhan_su/them-moi-cham-cong.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../../api.dart';
import '../../../common/style.dart';
import '../../../common/toast.dart';
import '../../../config.dart';
import '../../../model/model.dart';
import '../../forms/nhan_su/setting-data/userAAM.dart';
import '../../forms/nhan_su/ver1-cham-cong.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;

class TabBarThemMoiChamCong extends StatefulWidget {
  var listNVCC;
  var userAAM;
  String? fileName;
  String? timeMonth;
  int max;
  TabBarThemMoiChamCong({this.listNVCC, this.userAAM, this.fileName, this.timeMonth, required this.max});
  @override
  State<TabBarThemMoiChamCong> createState() => TabBarThemMoiChamCongState();
}

class TabBarThemMoiChamCongState extends State<TabBarThemMoiChamCong> with SingleTickerProviderStateMixin {
  late final _tabController = TabController(length: widget.listNVCC.keys.length, vsync: this);
  DateFormat dateFormat = DateFormat("dd-MMM-yyyy");
  var forMatNumber = NumberFormat("###.#", "en_US");
  int selectedNV = 0;
  Future<List<UserAAM>> getListUser({lisUserCode}) async {
    List<UserAAM> listUserAAM = [];
    // print("object:$lisUserCode");
    String findUser = "";
    for (var item in lisUserCode) {
      findUser += "or timeKeepingCode:'$item'";
    }
    if (findUser.length > 0) findUser = findUser.substring(3);
    var response2 = await httpGet("/api/nguoidung/get/page?filter=isAam:1&filter=$findUser", context);
    if (response2.containsKey("body")) {
      var body = jsonDecode(response2['body']);
      var content = [];
      setState(() {
        content = body['content'];
        listUserAAM = content.map((e) {
          return UserAAM.fromJson(e);
        }).toList();
      });
    }
    return listUserAAM;
  }

  String fileNameExport = "";
  // DateFormat dateFormat = DateFormat("dd-MMM-yyyy");
  Future<void> createExcel(var listNVCC) async {
    bool checkDL = true;
    String error = "";
    for (var element in listNVCC.keys) {
      if (listNVCC[element][0]['map']['error'] > 0) {
        checkDL = false;
        if (userAAM.containsKey(listNVCC[element][0]['map']['Mã N.Viên']))
          error = "${userAAM[listNVCC[element][0]['map']['Mã N.Viên']].userCode}-${userAAM[listNVCC[element][0]['map']['Mã N.Viên']].fullName}";
        else
          error = "${listNVCC[element][0]['map']['Mã N.Viên']}";
        break;
      } else
        error = "";
    }
    if (checkDL) {
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
      int stt = listNVCC.keys.length;
      sheet.getRangeByName('A1:AV430').cellStyle.fontSize = 10;
      sheet.getRangeByName('A1:AV430').cellStyle.fontName = "Arial";
      sheet.getRangeByName('A1:AV430').cellStyle.hAlign = HAlignType.center;
      sheet.getRangeByName('A1:AV430').cellStyle.vAlign = VAlignType.center;
      sheet.getRangeByName('A2').setText('AAM');
      sheet.getRangeByName('A2').cellStyle.fontSize = 14;
      sheet.getRangeByName('A2').cellStyle.bold = true;
      var monthWork = DateFormat('MM-yyyy').format(dateFormat.parse('${listNVCC[listNVCC.keys.first][3]['map']['Ngày']}'));
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
        var workingDay = DateFormat('dd-MM-yyyy').format(dateFormat.parse('${listNVCC[listNVCC.keys.first][i]['map']['Ngày']}'));
        var ngay = double.parse(workingDay.substring(0, 2));
        sheet.getRangeByIndex(5, 8 + i).setNumber(ngay);
        if (listNVCC[listNVCC.keys.first][i]['map']['Thứ'] == "CN") {
          sheet.getRangeByIndex(6, 8 + i).setText('CN');
          cn.add(i);
        }
        if (listNVCC[listNVCC.keys.first][i]['map']['Thứ'] == "Hai") sheet.getRangeByIndex(6, 8 + i).setText('T2');
        if (listNVCC[listNVCC.keys.first][i]['map']['Thứ'] == "Ba") sheet.getRangeByIndex(6, 8 + i).setText('T3');
        if (listNVCC[listNVCC.keys.first][i]['map']['Thứ'] == "Tư") sheet.getRangeByIndex(6, 8 + i).setText('T6');
        if (listNVCC[listNVCC.keys.first][i]['map']['Thứ'] == "Năm") sheet.getRangeByIndex(6, 8 + i).setText('T5');
        if (listNVCC[listNVCC.keys.first][i]['map']['Thứ'] == "Sáu") sheet.getRangeByIndex(6, 8 + i).setText('T6');
        if (listNVCC[listNVCC.keys.first][i]['map']['Thứ'] == "Bảy") sheet.getRangeByIndex(6, 8 + i).setText('T7');
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
        var maChamCong = listNVCC[listNVCC.keys.toList()[i]][0]['map']['Mã N.Viên'];
        sheet.getRangeByIndex(7 + i, 1).setNumber(i + 1);
        sheet.getRangeByIndex(7 + i, 2).setText('${userAAM[maChamCong]?.userCode}');
        sheet.getRangeByIndex(7 + i, 3).setText('$maChamCong');
        sheet.getRangeByIndex(7 + i, 4).setText('${userAAM[maChamCong]?.fullName}');
        sheet.getRangeByIndex(7 + i, 5).setText('${userAAM[maChamCong]?.dutyName}');
        sheet.getRangeByIndex(7 + i, 6).setText('${userAAM[maChamCong]?.departName}');
        sheet.getRangeByIndex(7 + i, 7).setText('${userAAM[maChamCong]?.teamName}');
        // print("độ dài hàng:${listNVCC[listNVCC.keys.toList()[i]].length}");
        for (var j = 0; j < check; j++) {
          if (listNVCC[listNVCC.keys.toList()[i]][j]['map']['Kí hiệu'].toString() == "X")
            sheet.getRangeByIndex(7 + i, 8 + j).setNumber(1);
          else if (listNVCC[listNVCC.keys.toList()[i]][j]['map']['Kí hiệu'] == "**") {
            if (listNVCC[listNVCC.keys.toList()[i]][j]['map']['Thứ'] != "Bảy")
              sheet.getRangeByIndex(7 + i, 8 + j).setText("KLP/2");
            else
              sheet.getRangeByIndex(7 + i, 8 + j).setNumber(1);
          } else if (listNVCC[listNVCC.keys.toList()[i]][j]['map']['Kí hiệu'] == "V")
            sheet.getRangeByIndex(7 + i, 8 + j).setText("KLP");
          else if (listNVCC[listNVCC.keys.toList()[i]][j]['map']['Kí hiệu'] == "KR")
            sheet.getRangeByIndex(7 + i, 8 + j).setText("KLP");
          else if (listNVCC[listNVCC.keys.toList()[i]][j]['map']['Kí hiệu'] == "Off") {
            if (listNVCC[listNVCC.keys.toList()[i]][j]['map']['Thứ'] != "CN") sheet.getRangeByIndex(7 + i, 8 + j).setText("");
          }
          double hourWork = 0;
          if (listNVCC[listNVCC.keys.toList()[i]][j]['map']['Ra'] != "" && listNVCC[listNVCC.keys.toList()[i]][j]['map']['Vào'] != "") {
            DateTime vao = DateTime.parse("1944-06-06T${listNVCC[listNVCC.keys.toList()[i]][j]['map']['Vào']}:00.000");
            DateTime ra = DateTime.parse("1944-06-06T${listNVCC[listNVCC.keys.toList()[i]][j]['map']['Ra']}:00.000");
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
          if (listNVCC[listNVCC.keys.toList()[i]][j]['map']['Thứ'] == "CN") {
          } else if (listNVCC[listNVCC.keys.toList()[i]][j]['map']['Thứ'] == "Bảy") {
            if (hourWork < 240) sumHourWorkShort = sumHourWorkShort + hourWork - 240;
          } else {
            if (hourWork < 480) sumHourWorkShort = sumHourWorkShort + hourWork - 480;
          }
          if (listNVCC[listNVCC.keys.toList()[i]][j]['map']['Vào Trễ'] != "0.0" && listNVCC[listNVCC.keys.toList()[i]][j]['map']['Vào Trễ'] != "0") {
            sumBeLate += 1;
          }
          if (listNVCC[listNVCC.keys.toList()[i]][j]['map']['Ra sớm'] != "0.0" && listNVCC[listNVCC.keys.toList()[i]][j]['map']['Ra sớm'] != "0.0") {
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
      }
    } else {
      showToast(
        context: context,
        msg: "Dữ liệu nhân viên $error chưa hợp lệ",
        color: Color.fromRGBO(245, 117, 29, 1),
        icon: const Icon(Icons.info),
      );
    }
  }

  // post Chấm công
  var resultID;
  addTimeKeeping(String timeMonth, String fileName) async {
    print("timeMonth:$timeMonth");
    print("fileName:$fileName");
    var request;
    if (fileNameExport != "")
      request = {"timekeepingMonth": "$timeMonth", "fileOrigin": fileName, "fileEditedLatest": fileNameExport};
    else
      request = {"timekeepingMonth": "$timeMonth", "fileOrigin": fileName};
    print(request);
    var response1 = await httpPost("/api/chamcong/post/save", request, context);

    if (response1.containsKey("body")) {
      setState(() {
        resultID = jsonDecode(response1["body"]);
        print(resultID);
      });
      return resultID;
    } else
      print("Tải chấm công that bai");

    return resultID;
  }

  addTimeKeepingDetailed(var resultID, var listNVCC) async {
    var check = false;
    List<dynamic> lstObj = [];
    for (var element in listNVCC.keys) {
      for (var i = 0; i < listNVCC[element].length; i++) {
        if (userAAM.containsKey(listNVCC[element][i]['map']['Mã N.Viên'])) {
          String dayWorking = DateFormat('yyyy-MM-dd').format(dateFormat.parse('${listNVCC[element][i]['map']['Ngày']}'));
          var request;
          if (listNVCC[element][i]['map']['Vào'] != "" && listNVCC[element][i]['map']['Ra'] != "")
            request = {
              "chamcongId": int.parse(resultID.toString()),
              "userId": (userAAM.containsKey(listNVCC[element][i]['map']['Mã N.Viên'])) ? userAAM[listNVCC[element][i]['map']['Mã N.Viên']].id : null,
              "workingDay": dayWorking,
              "day": listNVCC[element][i]['map']['Thứ'],
              "timeIn": "${dayWorking}T${listNVCC[element][i]['map']['Vào']}:00.000+00:00",
              "timeOut": "${dayWorking}T${listNVCC[element][i]['map']['Ra']}:00.000+00:00",
              "beLate": (listNVCC[element][i]['map']['Vào Trễ'] != "0.0" && listNVCC[element][i]['map']['Vào Trễ'] != "0") ? 1 : 0,
              "backSoon": (listNVCC[element][i]['map']['Ra sớm'] != "0.0" && listNVCC[element][i]['map']['Ra sớm'] != "0") ? 1 : 0,
              "notation": listNVCC[element][i]['map']['Kí hiệu'],
              "revision": 1
            };
          else if (listNVCC[element][i]['map']['Vào'] != "")
            request = {
              "chamcongId": int.parse(resultID.toString()),
              "userId": (userAAM.containsKey(listNVCC[element][i]['map']['Mã N.Viên'])) ? userAAM[listNVCC[element][i]['map']['Mã N.Viên']].id : null,
              "workingDay": dayWorking,
              "day": listNVCC[element][i]['map']['Thứ'],
              "timeIn": "${dayWorking}T${listNVCC[element][i]['map']['Vào']}:00.000+00:00",
              "beLate": (listNVCC[element][i]['map']['Vào Trễ'] != "0.0" && listNVCC[element][i]['map']['Vào Trễ'] != "0") ? 1 : 0,
              "backSoon": (listNVCC[element][i]['map']['Ra sớm'] != "0.0" && listNVCC[element][i]['map']['Ra sớm'] != "0") ? 1 : 0,
              "notation": listNVCC[element][i]['map']['Kí hiệu'],
              "revision": 1
            };
          else if (listNVCC[element][i]['map']['Ra'] != "")
            request = {
              "chamcongId": int.parse(resultID.toString()),
              "userId": (userAAM.containsKey(listNVCC[element][i]['map']['Mã N.Viên'])) ? userAAM[listNVCC[element][i]['map']['Mã N.Viên']].id : null,
              "workingDay": dayWorking,
              "day": listNVCC[element][i]['map']['Thứ'],
              "timeOut": "${dayWorking}T${listNVCC[element][i]['map']['Ra']}:00.000+00:00",
              "beLate": (listNVCC[element][i]['map']['Vào Trễ'] != "0.0" && listNVCC[element][i]['map']['Vào Trễ'] != "0") ? 1 : 0,
              "backSoon": (listNVCC[element][i]['map']['Ra sớm'] != "0.0" && listNVCC[element][i]['map']['Ra sớm'] != "0") ? 1 : 0,
              "notation": listNVCC[element][i]['map']['Kí hiệu'],
              "revision": 1
            };
          else
            request = {
              "chamcongId": int.parse(resultID.toString()),
              "userId": (userAAM.containsKey(listNVCC[element][i]['map']['Mã N.Viên'])) ? userAAM[listNVCC[element][i]['map']['Mã N.Viên']].id : null,
              "workingDay": dayWorking,
              "day": listNVCC[element][i]['map']['Thứ'],
              "beLate": (listNVCC[element][i]['map']['Vào Trễ'] != "0.0" && listNVCC[element][i]['map']['Vào Trễ'] != "0") ? 1 : 0,
              "backSoon": (listNVCC[element][i]['map']['Ra sớm'] != "0.0" && listNVCC[element][i]['map']['Ra sớm'] != "0") ? 1 : 0,
              "notation": listNVCC[element][i]['map']['Kí hiệu'],
              "revision": 1
            };
          lstObj.add(request);
        }
      }
    }
    if (lstObj.length > 0) {
      var response = await httpPost("/api/chamcong-chitiet/post/saveAll", lstObj, context);
      if (response.containsKey("body")) {
        setState(() {
          check = jsonDecode(response["body"]);
          print(check);
        });
        return check;
      }
    }

    return check;
  }

  var listNVCC;
  var userAAM;
  late UserAAM selectedNVAAM;
  late double height;
  @override
  void initState() {
    super.initState();
    listNVCC = widget.listNVCC;
    userAAM = widget.userAAM;
    selectedNVAAM = UserAAM(
        userCode: (userAAM.containsKey(listNVCC.keys.first)) ? "${userAAM[listNVCC.keys.first].userCode}" : "",
        fullName: (userAAM.containsKey(listNVCC.keys.first)) ? "${userAAM[listNVCC.keys.first].fullName}" : "");
    height = (31 + widget.max) * 60;
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: DefaultTabController(
        length: listNVCC.keys.length,
        initialIndex: selectedNV,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20, right: 20, top: 20),
              decoration: BoxDecoration(
                color: colorWhite,
                borderRadius: borderRadiusContainer,
                boxShadow: [boxShadowContainer],
                border: borderAllContainerBox,
              ),
              padding: EdgeInsets.only(top: 20, left: 30, right: 30, bottom: 20),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      // margin: EdgeInsets.only(bottom: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text('Nhân viên:', style: titleWidgetBox),
                          ),
                          Expanded(
                              flex: 5,
                              child: Container(
                                color: Colors.white,
                                width: MediaQuery.of(context).size.width * 0.20,
                                height: 40,
                                child: DropdownSearch<UserAAM>(
                                  // hint: "Chọn",
                                  maxHeight: 250,
                                  mode: Mode.MENU,
                                  showSearchBox: true,
                                  onFind: (String? filter) => getListUser(lisUserCode: listNVCC.keys.toList()),
                                  itemAsString: (UserAAM? u) => u!.fullName.toString() + " - " + u.userCode.toString(),
                                  dropdownSearchDecoration: styleDropDown,
                                  selectedItem: selectedNVAAM,
                                  onChanged: (value) {
                                    for (var i = 0; i < listNVCC.keys.length; i++) {
                                      if (listNVCC.keys.toList()[i] == value?.timeKeepingCode) {
                                        setState(() {
                                          selectedNV = i;
                                        });
                                        _tabController.index = i;
                                        print(selectedNV);
                                      }
                                    }
                                  },
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  Expanded(
                      flex: 1,
                      child: Container(
                        // margin: EdgeInsets.only(bottom: 10),
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
                            createExcel(listNVCC);
                          },
                          // : null,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Xuất file', style: textButton),
                            ],
                          ),
                        ),
                      )),
                  SizedBox(width: 25),
                  Expanded(
                    flex: 1,
                    child: Container(
                      // margin: EdgeInsets.only(bottom: 10),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
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
                        onPressed: () async {
                          processing();
                          bool checkDL = true;
                          String error = "";
                          for (var element in listNVCC.keys) {
                            if (listNVCC[element][0]['map']['error'] > 0) {
                              checkDL = false;
                              if (userAAM.containsKey(listNVCC[element][0]['map']['Mã N.Viên']))
                                error =
                                    "${userAAM[listNVCC[element][0]['map']['Mã N.Viên']].userCode}-${userAAM[listNVCC[element][0]['map']['Mã N.Viên']].fullName}";
                              else
                                error = "${listNVCC[element][0]['map']['Mã N.Viên']}";
                              break;
                            } else
                              error = "";
                          }
                          if (checkDL) {
                            if (widget.timeMonth != "") {
                              await addTimeKeeping("${widget.timeMonth}", "${widget.fileName}");
                              var value = int.tryParse(resultID.toString());
                              if (value != null) {
                                var check;
                                check = await addTimeKeepingDetailed(resultID, listNVCC);
                                if (check == true) {
                                  Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/cham-cong");
                                  showToast(
                                    context: context,
                                    msg: "Lưu file chấm công thành công",
                                    color: Color.fromARGB(136, 72, 238, 67),
                                    icon: Icon(Icons.done),
                                  );
                                } else {
                                  await httpDelete("/api/chamcong/del/$value", context);
                                  showToast(
                                    context: context,
                                    msg: "Thêm mới không thành công, kiển tra lại thông tin",
                                    color: colorOrange,
                                    icon: Icon(Icons.warning),
                                  );
                                  Navigator.pop(context);
                                }
                              }
                            } else {
                              Navigator.pop(context);
                              showToast(
                                context: context,
                                msg: "Chọn tháng cần lưu",
                                color: colorOrange,
                                icon: Icon(Icons.warning),
                              );
                            }
                          } else {
                            Navigator.pop(context);
                            showToast(
                              context: context,
                              msg: "Dữ liệu nhân viên $error hợp lệ",
                              color: colorOrange,
                              icon: Icon(Icons.warning),
                            );
                          }
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Lưu', style: textButton),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(''),
                  ),
                ],
              ),
            ),
            Container(
              // color: Colors.red,
              constraints: BoxConstraints.expand(height: 50),
              padding: EdgeInsets.only(left: 20, right: 20),
              child: TabBar(
                onTap: (value) {
                  print(value);

                  setState(() {
                    selectedNVAAM = UserAAM(
                        userCode: (userAAM.containsKey(listNVCC.keys.toList()[value])) ? "${userAAM[listNVCC.keys.toList()[value]].userCode}" : "",
                        fullName: (userAAM.containsKey(listNVCC.keys.toList()[value])) ? "${userAAM[listNVCC.keys.toList()[value]].fullName}" : "");
                  });
                },
                isScrollable: true,
                indicatorColor: mainColorPage,
                controller: _tabController,
                tabs: [
                  for (var element in listNVCC.keys)
                    (listNVCC[element][0]['map']['short'] > 0)
                        ? (listNVCC[element][0]['map']['error'] > 0)
                            ? Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: Colors.red,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    (userAAM.containsKey(element)) ? "${userAAM[element]?.fullName}\n${userAAM[element]?.userCode}" : "$element",
                                    style: TextStyle(color: Colors.red, fontSize: 14),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                                    child: Center(
                                      child: Text(
                                        "${listNVCC[element][0]['map']['error'] + listNVCC[element][0]['map']['short']}",
                                        style: TextStyle(color: colorWhite, fontSize: 10),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            : Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: mainColorPage,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    (userAAM.containsKey(element)) ? "${userAAM[element]?.fullName}\n${userAAM[element]?.userCode}" : "$element",
                                    style: titleTabbar,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(color: Color.fromARGB(255, 250, 181, 91), borderRadius: BorderRadius.circular(10)),
                                    child: Center(
                                      child: Text(
                                        "${listNVCC[element][0]['map']['error'] + listNVCC[element][0]['map']['short']}",
                                        style: TextStyle(color: colorWhite, fontSize: 10),
                                      ),
                                    ),
                                  )
                                ],
                              )
                        : (listNVCC[element][0]['map']['error'] > 0)
                            ? Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: Colors.red,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    (userAAM.containsKey(element)) ? "${userAAM[element]?.fullName}\n${userAAM[element]?.userCode}" : "$element",
                                    style: TextStyle(color: Colors.red, fontSize: 14),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                                    child: Center(
                                      child: Text(
                                        "${listNVCC[element][0]['map']['error'] + listNVCC[element][0]['map']['short']}",
                                        style: TextStyle(color: colorWhite, fontSize: 10),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            : Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: mainColorPage,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    (userAAM.containsKey(element)) ? "${userAAM[element]?.fullName}\n${userAAM[element]?.userCode}" : "$element",
                                    style: titleTabbar,
                                  ),
                                ],
                              ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(controller: _tabController, children: [
                for (var element in listNVCC.keys)
                  ViewVer1CC(
                      timeKeepingData: listNVCC[element],
                      userAAM: userAAM,
                      callBack: (value) {
                        setState(() {});
                      },
                      callBackShort: (value) {
                        setState(() {});
                      }),
              ]),
            )
          ],
        ),
      ),
    );
  }
}
