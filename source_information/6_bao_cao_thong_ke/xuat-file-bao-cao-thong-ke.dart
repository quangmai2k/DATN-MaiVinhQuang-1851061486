import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_io/io.dart';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Alignment, Column, Row;
import 'package:universal_html/html.dart' show AnchorElement;
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> xuatFileBaoCaoThongKe(var thongKeTien) async {
  final oCcy = new NumberFormat("#,##0", "en_US");
  final Workbook workbook = new Workbook();
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
  stt.vAlign = VAlignType.center;
//Add Data
  sheet.getRangeByName('B1').columnWidth = 30;
  sheet.getRangeByName('C1').columnWidth = 30;
  sheet.getRangeByName('D1').columnWidth = 30;
  sheet.getRangeByName('A2:D2').merge();
  sheet.getRangeByName('A3:E3').cellStyle = header;
  sheet.getRangeByName('A2').setText('THỐNG KÊ CỘNG TÁC VIÊN');
  sheet.getRangeByName('A2').cellStyle = style;
  sheet.getRangeByName('A4:D${(thongKeTien.length + 4)}').cellStyle = stt;
  sheet.getRangeByName('A3').setText('STT');
  sheet.getRangeByName('B3').setText('Mã cộng tác viên');
  sheet.getRangeByName('C3').setText('Họ và tên');
  sheet.getRangeByName('D3').setText('Tổng tiền(VNĐ)');
  sheet.getRangeByName('A3:D${thongKeTien.length + 3}').cellStyle.borders.all.lineStyle = LineStyle.thin;

  for (int i = 0; i < thongKeTien.length; ++i) {
    sheet.getRangeByIndex(i + 4, 1).setNumber(i + 1);
    sheet.getRangeByIndex(i + 4, 2).setText(thongKeTien[i].maCTV);
    sheet.getRangeByIndex(i + 4, 3).setText(thongKeTien[i].hoTen);
    sheet.getRangeByIndex(i + 4, 4).setText("${oCcy.format(thongKeTien[i].tongTien)}");
  }
// Save the document.
  final List<int> bytes = workbook.saveAsStream();
  workbook.dispose();
  if (kIsWeb) {
    AnchorElement(href: 'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
      ..setAttribute('download', 'thong-ke-cong-tac-vien.xlsx')
      ..click();
  } else {
    final String path = (await getApplicationSupportDirectory()).path;
    final String fileName = Platform.isWindows ? '$path\\thong-ke-cong-tac-vien.xlsx' : '$path/thong-ke-cong-tac-vien.xlsx';
    final File file = File(fileName);
    await file.writeAsBytes(bytes, flush: true);
    OpenFile.open(fileName);
  }
}
