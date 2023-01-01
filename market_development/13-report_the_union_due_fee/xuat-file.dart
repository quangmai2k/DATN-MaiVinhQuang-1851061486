import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:universal_io/io.dart';
import 'package:flutter/foundation.dart';

import 'package:universal_html/html.dart' show AnchorElement;
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../../model/market_development/nghiepdoan-thanhtoan.dart';

//
Future<List<int>> _readImageData(String name) async {
  final ByteData data = await rootBundle.load('assets/images/$name');
  return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}

Future<void> xuatFileThuPhiQuanLy(List<NghiepDoanThanhToan> listUnionObjectResult) async {
  String getDateViewThanhToan(String? date) {
    try {
      if (date == null) {
        return "Chưa thanh toán";
      }
      var inputFormat = DateFormat('yyyy-MM-dd');
      var inputDate = inputFormat.parse(date); // <-- dd/MM 24H format
      var outputFormat = DateFormat('dd/MM/yyyy');
      var outputDate = outputFormat.format(inputDate);
      return outputDate;
    } catch (e) {}
    return "Chưa thanh toán";
  }

  String getNameStatus(int? status) {
    String name = "Không có dữ liệu";
    if (status == null) {
      return name;
    }
    switch (status) {
      case 0:
        name = "Chưa thanh toán";
        break;
      case 1:
        name = "Đã thanh toán";
        break;
      case 2:
        name = "Thanh toán 1 phần";
        break;
    }
    return name;
  }

  final Workbook workbook = new Workbook();
//Accessing worksheet via index.
  final Worksheet sheet = workbook.worksheets[0];
  // Style
  final Style style = workbook.styles.add('Style1');
  style.fontSize = 16;
  style.bold = true;
  style.hAlign = HAlignType.center;
  final Style header = workbook.styles.add('Style2');
  header.fontSize = 12;
  header.bold = true;
  header.hAlign = HAlignType.center;
  final Style stt = workbook.styles.add("style3");
  stt.hAlign = HAlignType.center;
//Add Data
  sheet.getRangeByName('A1:AO43').cellStyle.hAlign = HAlignType.center;
  sheet.getRangeByName('A1:AO43').cellStyle.vAlign = VAlignType.center;
  sheet.getRangeByName('B6:G6').columnWidth = 40;
  sheet.getRangeByName('A5:G5').merge();
  sheet.getRangeByName('A6:G6').cellStyle = header;
  sheet.getRangeByName('A5').setText('THU PHI QUẢN LÝ');
  sheet.getRangeByName('A5').cellStyle = style;
  sheet.getRangeByName('A6:A${(listUnionObjectResult.length + 4)}').cellStyle = stt;
  sheet.getRangeByName('A6').setText('STT');
  sheet.getRangeByName('B6').setText('Mã Nghiệp Đoàn');
  sheet.getRangeByName('C6').setText('Tên Nghiệp Đoàn');
  sheet.getRangeByName('D6').setText('Người đại diện');
  sheet.getRangeByName('E6').setText('SĐT');
  sheet.getRangeByName('F6').setText('Ngày thanh toán');
  sheet.getRangeByName('G6').setText('Trạng thái thanh toán');

  sheet.getRangeByName("A6").cellStyle.borders.all.lineStyle = LineStyle.medium;
  sheet.getRangeByName("B6").cellStyle.borders.all.lineStyle = LineStyle.medium;
  sheet.getRangeByName("C6").cellStyle.borders.all.lineStyle = LineStyle.medium;
  sheet.getRangeByName("D6").cellStyle.borders.all.lineStyle = LineStyle.medium;
  sheet.getRangeByName("E6").cellStyle.borders.all.lineStyle = LineStyle.medium;
  sheet.getRangeByName("F6").cellStyle.borders.all.lineStyle = LineStyle.medium;
  sheet.getRangeByName("G6").cellStyle.borders.all.lineStyle = LineStyle.medium;
  for (int i = 0; i < listUnionObjectResult.length; ++i) {
    sheet.getRangeByIndex(i + 7, 1).setNumber(i + 1);
    sheet.getRangeByIndex(i + 7, 2).setText(listUnionObjectResult[i].unionObj != null ? listUnionObjectResult[i].unionObj!.orgCode.toString() : "No data!");
    sheet.getRangeByIndex(i + 7, 3).setText(listUnionObjectResult[i].unionObj != null ? listUnionObjectResult[i].unionObj!.orgName.toString() : "No data!");
    sheet.getRangeByIndex(i + 7, 4).setText(listUnionObjectResult[i].unionObj != null ? listUnionObjectResult[i].unionObj!.deputy.toString() : "No data!");
    sheet.getRangeByIndex(i + 7, 5).setText(listUnionObjectResult[i].unionObj != null ? listUnionObjectResult[i].unionObj!.phone.toString() : "No data!");
    // var ngay;
    // ngay = DateFormat('dd-MM-yyy').parse(hienThiNgayTinhHanThuPhi(listUnionObjectResult[i]));

    sheet.getRangeByIndex(i + 7, 6).setText(getDateViewThanhToan(listUnionObjectResult[i].paidDate));
    sheet.getRangeByIndex(i + 7, 7).setText(getNameStatus(listUnionObjectResult[i].status));

    sheet.getRangeByIndex(i + 7, 1).cellStyle.borders.all.lineStyle = LineStyle.medium;
    sheet.getRangeByIndex(7 + i, 2).cellStyle.borders.all.lineStyle = LineStyle.medium;
    sheet.getRangeByIndex(7 + i, 3).cellStyle.borders.all.lineStyle = LineStyle.medium;
    sheet.getRangeByIndex(7 + i, 4).cellStyle.borders.all.lineStyle = LineStyle.medium;
    sheet.getRangeByIndex(7 + i, 5).cellStyle.borders.all.lineStyle = LineStyle.medium;
    sheet.getRangeByIndex(7 + i, 6).cellStyle.borders.all.lineStyle = LineStyle.medium;
    sheet.getRangeByIndex(7 + i, 7).cellStyle.borders.all.lineStyle = LineStyle.medium;
  }
  final String image = base64.encode(await _readImageData('logoAAM.png'));
  sheet.pictures.addBase64(1, 1, image);
// Save the document.
  final List<int> bytes = workbook.saveAsStream();
  workbook.dispose();
  if (kIsWeb) {
    AnchorElement(href: 'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
      ..setAttribute('download', 'thu-phi-quan-ly.xlsx')
      ..click();
  } else {
    final String path = (await getApplicationSupportDirectory()).path;
    final String fileName = Platform.isWindows ? '$path\\thu-phi-quan-ly.xlsx' : '$path/thu-phi-quan-ly.xlsx';
    final File file = File(fileName);
    await file.writeAsBytes(bytes, flush: true);
    OpenFile.open(fileName);
  }
}
