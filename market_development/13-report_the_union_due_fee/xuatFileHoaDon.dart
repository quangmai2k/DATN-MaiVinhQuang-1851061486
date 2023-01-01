import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:gentelella_flutter/common/widgets_form.dart';
import 'package:gentelella_flutter/widgets/ui/market_development/7-order_management/xuat_file.dart';

import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:universal_io/io.dart';
import 'package:flutter/foundation.dart';

import 'package:universal_html/html.dart' show AnchorElement;
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../../config.dart';
import '../../../../model/market_development/nghiepdoan_tts_xuat_canh.dart';
import '../../../../model/market_development/user.dart';
import 'package:http/http.dart' as http;

Future<List<int>> _readImageData(String name) async {
  final ByteData data = await rootBundle.load('assets/images/$name');
  return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}

Future<void> xuatFileHoaDon(List<dynamic> list, List<dynamic> listCTLXC) async {
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
  sheet.getRangeByName('B6:G6').columnWidth = 20;
  sheet.getRangeByName('A1').columnWidth = 1.7;
  sheet.getRangeByName('B1').columnWidth = 4;
  sheet.getRangeByName('C1').columnWidth = 3;
  sheet.getRangeByName('D1').columnWidth = 51;
  sheet.getRangeByName('E1').columnWidth = 8.5;
  sheet.getRangeByName('F1').columnWidth = 116;
  sheet.getRangeByName('F1').columnWidth = 17;
  sheet.getRangeByName('H1').columnWidth = 20;

  sheet.getRangeByName('A1:H8').merge();
  sheet.getRangeByName('A1:H8').rowHeight = 1;
  sheet.getRangeByName('A9:H9').merge();
  sheet.getRangeByName('A9').setText('AAM TRAVEL DEVELOPMENT JOINT STOCK COMPANY ( AAM TRAVEL .,JSC )');
  sheet.getRangeByName('A9').cellStyle.bold = true;
  sheet.getRangeByName('A9').cellStyle.fontSize = 12;

  sheet.getRangeByName('C10:H10').merge();
  sheet.getRangeByName('C10').setText('Trụ sở chính: Tầng 7, Tòa Nhà Golden field, 24 Nguyễn Cơ Thạch, Mỹ Đình, Nam Từ Liêm, Hà Nội');
  sheet.getRangeByName('C10').cellStyle.fontSize = 12;

  sheet.getRangeByName('A11:H11').merge();
  sheet.getRangeByName('A11').setText('Website: https://veaam.vn');
  sheet.getRangeByName('A10').cellStyle.fontSize = 12;

  sheet.getRangeByName('C15:H15').merge();
  sheet.getRangeByName('C15').setText('INVOICE');
  sheet.getRangeByName('C15').cellStyle.fontSize = 22;
  sheet.getRangeByName('C15').cellStyle.bold = true;

  sheet.getRangeByName('C16:F16').merge();

  sheet.getRangeByName('G16:H16').merge();
  sheet.getRangeByName('G16').setText('Date: 26 September  2022');
  sheet.getRangeByName('G16').cellStyle.fontSize = 12;

  sheet.getRangeByName('C18').setText('');
  sheet.getRangeByName('D18').setText('DESCRIPTION');
  sheet.getRangeByName('E18').setText('Quantity');
  sheet.getRangeByName('F18').setText('Price ( USD)');
  sheet.getRangeByName('G18').setText('Price Total  (USD)');
  sheet.getRangeByName('H18').setText('Note');
  sheet.getRangeByName('C18:H18').cellStyle.bold = true;

  //#BFBFBF

  sheet.getRangeByName('C18:H18').cellStyle.backColor = '#BFBFBF';

  sheet.getRangeByName('C19').setText('');
  sheet.getRangeByName('D19').setText('HAN - NRT');

  sheet.getRangeByName('H19').setText('Economy class');

  await renderDanhSach(list, listCTLXC, sheet);

  sheet.getRangeByName('H19').setText('Economy class');

  // sheet.getRangeByName('C18:G29').cellStyle.borders.all.lineStyle = LineStyle.thin;
  // sheet.getRangeByName('H18:H26').cellStyle.borders.all.lineStyle = LineStyle.thin;

  // sheet.getRangeByName('G27').cellStyle.borders.all.lineStyle = LineStyle.thin;

// Save the document.
  final List<int> bytes = workbook.saveAsStream();
  workbook.dispose();
  if (kIsWeb) {
    AnchorElement(href: 'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
      ..setAttribute('download', 'hoa-don.xlsx')
      ..click();
  } else {
    final String path = (await getApplicationSupportDirectory()).path;
    final String fileName = Platform.isWindows ? '$path\\thu-phi-quan-ly.xlsx' : '$path/thu-phi-quan-ly.xlsx';
    final File file = File(fileName);
    await file.writeAsBytes(bytes, flush: true);
    OpenFile.open(fileName);
  }
}

renderDanhSach(List<dynamic> listTts, List<dynamic> listCTLXC, Worksheet sheet) {
  getCTLXC(int idTts, List<dynamic> listCTLXC) {
    for (var item in listCTLXC) {
      if (idTts == item['userId']) {
        return item;
      }
    }
    return null;
  }

  int index = 20 + listTts.length;
  for (int i = 0; i < listTts.length; i++) {
    try {
      sheet.getRangeByIndex(20 + i, 3).setText("${i + 1}");
      sheet.getRangeByIndex(20 + i, 4).setText("${listTts[i]['thuctapsinh']['fullName']}");
      sheet.getRangeByIndex(20 + i, 5).setNumber(1);
      Range rangePrice = sheet.getRangeByIndex(20 + i, 6);
      rangePrice.setNumber(getCTLXC(listTts[i]['ttsId'], listCTLXC)['arfareFee']);
      rangePrice.numberFormat = '#,##0';

      Range rangePriceTotal = sheet.getRangeByIndex(20 + i, 7);
      rangePriceTotal.setFormula("=F${20 + i}*E${20 + i}");
      rangePriceTotal.numberFormat = '#,##0';

      sheet.getRangeByIndex(20 + i, 8).setText(getCTLXC(listTts[i]['ttsId'], listCTLXC)['userNote']);

      sheet.getRangeByIndex(20 + i, 4).cellStyle.hAlign = HAlignType.left;
      sheet.getRangeByIndex(20 + i, 4).cellStyle.bold = true;
    } catch (e) {
      print(e.toString());
    }
  }
  sheet.getRangeByName('C$index:F$index').merge();
  sheet.getRangeByName('C$index').setText('TOTAL  (VND)');

  sheet.getRangeByName('G$index:H$index').merge();

  Range rangePriceSUM = sheet.getRangeByName('G$index:H$index');
  rangePriceSUM.setFormula("=SUM(F${20}:F${20 + index})");
  rangePriceSUM.numberFormat = '#,##0';

  sheet.getRangeByName('C${index + 1}:F${index + 1}').merge();
  sheet.getRangeByName('C${index + 1}').setText('EXCHANGE RATE (JPY/VND).According to the date of issued ticket');

  sheet.getRangeByName('G${index + 1}:H${index + 1}').merge();

  sheet.getRangeByName('C${index + 2}:F${index + 2}').merge();
  sheet.getRangeByName('C${index + 2}').setText('EX.RATE ( JPY)');

  sheet.getRangeByName('G${index + 2}:H${index + 2}').merge();

  // sheet.getRangeByName('G${index + 2}').setNumber(139299);
  Range range24 = sheet.getRangeByName('G${index + 2}');
  range24.setNumber(139299);
  range24.numberFormat = '#,##0';

  sheet.getRangeByName('C${index + 3}:F${index + 3}').merge();
  sheet.getRangeByName('C${index + 3}').setText('GRAND TOTAL  ( JPY)');
  sheet.getRangeByName('C${index + 3}').cellStyle.fontSize = 14;
  sheet.getRangeByName('C${index + 3}').cellStyle.bold = true;

  // sheet.getRangeByName('').merge();
  // sheet.getRangeByName('G${index + 3}').setText('139.299');
  String condition25 = "=G$index*G${index + 2}";
  sheet.getRangeByName('G${index + 3}:H${index + 3}').merge();
  Range range25 = sheet.getRangeByName('G${index + 3}');

  range25.setFormula(condition25);
  range25.numberFormat = '#,##0';
  range25.cellStyle.fontSize = 14;
  range25.cellStyle.bold = true;

  sheet.getRangeByName('C18:H${index + 3}').cellStyle.borders.all.lineStyle = LineStyle.thin;

  sheet.getRangeByName('B${index + 5}:I${index + 5}').merge();
  sheet.getRangeByName('B${index + 5}').setText('AAM TRAVEL DEVELOPMENT JOINT STOCK COMPANY ( AAM TRAVEL .,JSC )');
  sheet..getRangeByName('B${index + 5}').cellStyle.hAlign = HAlignType.right;
  sheet.getRangeByName('B${index + 5}').cellStyle.bold = true;

  sheet.getRangeByName('C${index + 6}:H${index + 6}').merge();
  sheet.getRangeByName('C${index + 6}').rowHeight = 100;

  sheet.getRangeByName('C${index + 7}:H${index + 7}').merge();
  sheet.getRangeByName('C${index + 7}').setText('Make all checks payable to AAM co ., Ltd. If you have any questions concerning this Invoice,');
  sheet..getRangeByName('C${index + 7}').cellStyle.hAlign = HAlignType.left;

  sheet.getRangeByName('C${index + 8}:H${index + 8}').merge();
  sheet.getRangeByName('C${index + 8}').setText('Please feel free to contact office for information, H.p 0915593339. Thank you very much for your co-operation!');
  sheet.getRangeByName('C${index + 8}').cellStyle.hAlign = HAlignType.left;
}

readImageFromApi(fileName) async {
  final response = await http.get(Uri.parse('$baseUrl/api/files/$fileName'));
  ByteData byte = ByteData.view(response.bodyBytes.buffer);
  return byte.buffer.asUint8List(response.bodyBytes.offsetInBytes, response.bodyBytes.lengthInBytes);
  // return response.body;
}
