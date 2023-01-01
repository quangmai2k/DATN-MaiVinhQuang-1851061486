import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/format_date.dart';
import 'package:gentelella_flutter/model/market_development/order.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_io/io.dart';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row;
import 'package:universal_html/html.dart' show AnchorElement;
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> createExcel(List<Order> listDonHang) async {
  for (var i = 0; i < listDonHang.length; i++) {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];

    sheet.getRangeByName('A1:AO43').cellStyle.fontSize = 10;
    sheet.getRangeByName('A1:AO43').cellStyle.fontName = "Times New Roman";

    sheet.getRangeByName('A1:AO43').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('A1:AO43').cellStyle.vAlign = VAlignType.center;

    sheet.getRangeByName('A1:D1').merge();
    sheet.getRangeByName('A2:D2').merge();
    sheet.getRangeByName('A3:D3').merge();
    sheet.getRangeByName('A4:D4').merge();
    sheet.getRangeByName('A5:D5').merge();
    sheet.getRangeByName('A6:D6').merge();

    sheet.getRangeByName('A3').setText('THÔNG BÁO ĐƠN HÀNG');
    sheet.getRangeByName('A3').cellStyle.fontSize = 14;
    sheet.getRangeByName('A3').cellStyle.bold = true;

    sheet.getRangeByName('A4').setText('Đơn hàng ' + listDonHang[i].implementTime!);
    sheet.getRangeByName('A4').cellStyle.fontSize = 9;
    sheet.getRangeByName('A4').cellStyle.bold = true;

    sheet.getRangeByName('A6').setText('I. Yêu cầu tuyển dụng');
    sheet.getRangeByName('A6').cellStyle.fontSize = 9;
    sheet.getRangeByName('A6').cellStyle.bold = true;
    sheet.getRangeByName('A6').cellStyle.hAlign = HAlignType.left;
    sheet.getRangeByName('A27').rowHeight = 30;

    //Row 1
    sheet.getRangeByName('A7').setText('STT');
    sheet.getRangeByName('A7').cellStyle.fontSize = 9;
    sheet.getRangeByName('A7').cellStyle.bold = true;
    sheet.getRangeByName('A7').cellStyle.hAlign = HAlignType.center;

    sheet.getRangeByName('B7').setText('Hạng mục');
    sheet.getRangeByName('B7').cellStyle.fontSize = 9;
    sheet.getRangeByName('B7').cellStyle.bold = true;
    sheet.getRangeByName('B7').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('B7').columnWidth = 20;

    sheet.getRangeByName('C7:D7').merge();
    sheet.getRangeByName('C7').setText('Nội dung');
    sheet.getRangeByName('C7').cellStyle.fontSize = 9;
    sheet.getRangeByName('C7').cellStyle.bold = true;
    sheet.getRangeByName('C7').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('C7').columnWidth = 20;

    sheet.getRangeByName('C8:D8').merge();
    sheet.getRangeByName('C8').setText(listDonHang[i].workAddress);
    sheet.getRangeByName('C8').cellStyle.fontSize = 9;
    sheet.getRangeByName('C8').cellStyle.bold = true;
    sheet.getRangeByName('C8').cellStyle.hAlign = HAlignType.center;

    sheet.getRangeByName('A8').setText('1');
    sheet.getRangeByName('A8').cellStyle.fontSize = 9;
    sheet.getRangeByName('A8').cellStyle.bold = true;
    sheet.getRangeByName('A8').cellStyle.hAlign = HAlignType.center;

    sheet.getRangeByName('B8').setText('Địa điểm làm việc: ');
    sheet.getRangeByName('B8').cellStyle.hAlign = HAlignType.left;
    sheet.getRangeByName('B8').cellStyle.fontSize = 9;
    sheet.getRangeByName('B8').cellStyle.bold = true;
    sheet.getRangeByName('B8').columnWidth = 20;

    //Row 2
    sheet.getRangeByName('A9').setText('2');
    sheet.getRangeByName('A9').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('A9').cellStyle.fontSize = 9;
    sheet.getRangeByName('A9').cellStyle.bold = true;

    sheet.getRangeByName('B9').setText('Ngành nghề xin Visa: ');
    sheet.getRangeByName('B9').cellStyle.hAlign = HAlignType.left;
    sheet.getRangeByName('B9').cellStyle.fontSize = 9;
    sheet.getRangeByName('B9').cellStyle.bold = true;
    sheet.getRangeByName('B9').columnWidth = 20;

    sheet.getRangeByName('C9:D9').merge();
    sheet.getRangeByName('C9').setText(listDonHang[i].jobs!.jobName);
    sheet.getRangeByName('C9').cellStyle.fontSize = 9;
    sheet.getRangeByName('C9').cellStyle.bold = true;
    sheet.getRangeByName('C9').cellStyle.hAlign = HAlignType.center;

    //Row 3
    sheet.getRangeByName('A10').setText('3');
    sheet.getRangeByName('A10').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('A10').cellStyle.fontSize = 9;
    sheet.getRangeByName('A10').cellStyle.bold = true;

    sheet.getRangeByName('B10').setText('Tên và nội dung CV cụ thể: ');
    sheet.getRangeByName('B10').cellStyle.fontSize = 9;
    sheet.getRangeByName('B10').cellStyle.bold = true;
    sheet.getRangeByName('B10').columnWidth = 20;
    sheet.getRangeByName('B10').cellStyle.hAlign = HAlignType.left;

    sheet.getRangeByName('C10:D10').merge();
    sheet.getRangeByName('C10').setText(listDonHang[i].jobsDetail!.jobName);
    sheet.getRangeByName('C10').cellStyle.fontSize = 9;
    sheet.getRangeByName('C10').cellStyle.bold = true;
    sheet.getRangeByName('C10').cellStyle.hAlign = HAlignType.center;

    sheet.getRangeByName('A11').setText('4');
    sheet.getRangeByName('A11').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('A11').cellStyle.fontSize = 9;
    sheet.getRangeByName('A11').cellStyle.bold = true;

    sheet.getRangeByName('B11').setText('Điều kiện tuyển dụng:  ');
    sheet.getRangeByName('B11').cellStyle.fontSize = 9;
    sheet.getRangeByName('B11').cellStyle.bold = true;
    sheet.getRangeByName('B11').columnWidth = 20;
    sheet.getRangeByName('B11').cellStyle.hAlign = HAlignType.left;

    sheet.getRangeByName('A12:A20').merge();
    sheet.getRangeByName('A12').setText('5');
    sheet.getRangeByName('A12').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('A12').cellStyle.fontSize = 9;
    sheet.getRangeByName('A12').cellStyle.bold = true;

    sheet.getRangeByName('B12').setText('1. Độ tuổi: ');
    sheet.getRangeByName('B12').cellStyle.fontSize = 9;
    sheet.getRangeByName('B12').cellStyle.bold = true;
    sheet.getRangeByName('B12').columnWidth = 20;
    sheet.getRangeByName('B12').cellStyle.hAlign = HAlignType.left;

    sheet.getRangeByName('C12:D12').merge();
    sheet.getRangeByName('C12').setText("Từ " + listDonHang[i].ageFrom!.toString() + " tuổi" + " đến " + listDonHang[i].ageTo!.toString() + " tuổi");
    sheet.getRangeByName('C12').cellStyle.fontSize = 9;
    sheet.getRangeByName('C12').cellStyle.bold = true;
    sheet.getRangeByName('C12').cellStyle.hAlign = HAlignType.center;

    sheet.getRangeByName('B13').setText('2. Trình độ: ');
    sheet.getRangeByName('B13').cellStyle.fontSize = 9;
    sheet.getRangeByName('B13').cellStyle.bold = true;
    sheet.getRangeByName('B13').columnWidth = 20;
    sheet.getRangeByName('B13').cellStyle.hAlign = HAlignType.left;

    sheet.getRangeByName('C13:D13').merge();
    sheet.getRangeByName('C13').setText(listDonHang[i].level!.name);
    sheet.getRangeByName('C13').cellStyle.fontSize = 9;
    sheet.getRangeByName('C13').cellStyle.bold = true;
    sheet.getRangeByName('C13').cellStyle.hAlign = HAlignType.center;

    sheet.getRangeByName('B14').setText('3. Tay nghề: ');
    sheet.getRangeByName('B14').cellStyle.fontSize = 9;
    sheet.getRangeByName('B14').cellStyle.bold = true;
    sheet.getRangeByName('B14').columnWidth = 20;
    sheet.getRangeByName('B14').cellStyle.hAlign = HAlignType.left;

    sheet.getRangeByName('B15:B17').merge();
    sheet.getRangeByName('B15').setText('4. Yêu cầu khác: ');
    sheet.getRangeByName('B15').cellStyle.fontSize = 9;
    sheet.getRangeByName('B15').cellStyle.bold = true;
    sheet.getRangeByName('B15').columnWidth = 20;
    sheet.getRangeByName('B15').cellStyle.hAlign = HAlignType.left;
    sheet.getRangeByName('B15').cellStyle.vAlign = VAlignType.center;

    sheet.getRangeByName('C15').setText("Thị lực : " + listDonHang[i].eyeSight!);
    sheet.getRangeByName('C15').cellStyle.fontSize = 9;
    sheet.getRangeByName('C15').cellStyle.bold = true;
    sheet.getRangeByName('C15').cellStyle.hAlign = HAlignType.center;

    sheet.getRangeByName('C16').setValue(Checkbox(value: true, onChanged: null));

    sheet
        .getRangeByName('D15')
        .setText("Thể lực : Chiều cao > " + listDonHang[i].heigth!.toString() + " , Cân nặng > " + listDonHang[i].weight!.toString());
    sheet.getRangeByName('D15').cellStyle.fontSize = 9;
    sheet.getRangeByName('D15').cellStyle.bold = true;
    sheet.getRangeByName('D15').cellStyle.hAlign = HAlignType.center;

    sheet.getRangeByName('B18:B20').merge();
    sheet.getRangeByName('B18').setText('5. Yêu cầu đặc biệt: ');
    sheet.getRangeByName('B18').cellStyle.fontSize = 9;
    sheet.getRangeByName('B18').cellStyle.bold = true;
    sheet.getRangeByName('B18').columnWidth = 20;
    sheet.getRangeByName('B18').cellStyle.hAlign = HAlignType.left;
    sheet.getRangeByName('B18').cellStyle.vAlign = VAlignType.center;

    sheet.getRangeByName('C18').setText(''' Các trường hợp đặc biệt + ${listDonHang[i].priorityCases!.toString()}
     Chú ý trường hợp hạn chế tiếp nhận + ${listDonHang[i].restrictionCases!.toString()}''');
    sheet.getRangeByName('C18').cellStyle.fontSize = 9;
    sheet.getRangeByName('C18').cellStyle.bold = true;
    sheet.getRangeByName('C18').columnWidth = 20;
    sheet.getRangeByName('C18').cellStyle.hAlign = HAlignType.left;
    sheet.getRangeByName('C18').cellStyle.vAlign = VAlignType.top;
    sheet.getRangeByName('A21').setText('6');
    sheet.getRangeByName('A21').cellStyle.fontSize = 9;
    sheet.getRangeByName('A21').cellStyle.bold = true;
    sheet.getRangeByName('A21').cellStyle.hAlign = HAlignType.center;

    sheet.getRangeByName('B21').setText('Hình thức tuyển dụng: ');
    sheet.getRangeByName('B21').cellStyle.hAlign = HAlignType.left;
    sheet.getRangeByName('B21').cellStyle.fontSize = 9;
    sheet.getRangeByName('B21').cellStyle.bold = true;
    sheet.getRangeByName('B21').columnWidth = 20;

    sheet.getRangeByName('C21:D21').merge();
    sheet.getRangeByName('C21').setText(listDonHang[i].recruiMethod.toString());
    sheet.getRangeByName('C21').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('C21').cellStyle.fontSize = 9;
    sheet.getRangeByName('C21').cellStyle.bold = true;
    sheet.getRangeByName('C21').columnWidth = 20;

    sheet.getRangeByName('C22:D22').merge();
    sheet.getRangeByName('C22').setText(listDonHang[i].insurance.toString());
    sheet.getRangeByName('C22').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('C22').cellStyle.fontSize = 9;
    sheet.getRangeByName('C22').cellStyle.bold = true;
    sheet.getRangeByName('C22').columnWidth = 20;

    sheet.getRangeByName('C23:D23').merge();
    sheet.getRangeByName('C23').setText(listDonHang[i].firstMonthSubsidy.toString());
    sheet.getRangeByName('C23').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('C23').cellStyle.fontSize = 9;
    sheet.getRangeByName('C23').cellStyle.bold = true;
    sheet.getRangeByName('C23').columnWidth = 20;

    sheet.getRangeByName('C24:D24').merge();
    sheet.getRangeByName('C24').setText(listDonHang[i].salary.toString());
    sheet.getRangeByName('C24').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('C24').cellStyle.fontSize = 9;
    sheet.getRangeByName('C24').cellStyle.bold = true;
    sheet.getRangeByName('C24').columnWidth = 20;

    sheet.getRangeByName('C25:D25').merge();
    sheet.getRangeByName('C25').setText(listDonHang[i].estimatedEntryDate != null
        ? FormatDate.formatDateView(DateTime.tryParse(listDonHang[i].estimatedEntryDate!.toString())!)
        : "");
    sheet.getRangeByName('C25').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('C25').cellStyle.fontSize = 9;
    sheet.getRangeByName('C25').cellStyle.bold = true;
    sheet.getRangeByName('C25').columnWidth = 20;

    sheet.getRangeByName('C26:D26').merge();
    sheet.getRangeByName('C26').setText(listDonHang[i].estimatedInterviewDate != null
        ? FormatDate.formatDateView(DateTime.tryParse(listDonHang[i].estimatedInterviewDate!.toString())!)
        : "");
    sheet.getRangeByName('C26').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('C26').cellStyle.vAlign = VAlignType.center;
    sheet.getRangeByName('C26').cellStyle.fontSize = 9;
    sheet.getRangeByName('C26').cellStyle.bold = true;
    sheet.getRangeByName('C26').columnWidth = 20;

    sheet.getRangeByName('A22').setText('7');
    sheet.getRangeByName('A22').cellStyle.fontSize = 9;
    sheet.getRangeByName('A22').cellStyle.bold = true;
    sheet.getRangeByName('A22').cellStyle.hAlign = HAlignType.center;

    sheet.getRangeByName('B22').setText('Tiền lương cơ bản: ');
    sheet.getRangeByName('B22').cellStyle.hAlign = HAlignType.left;
    sheet.getRangeByName('B22').cellStyle.fontSize = 9;
    sheet.getRangeByName('B22').cellStyle.bold = true;
    sheet.getRangeByName('B22').columnWidth = 20;

    sheet.getRangeByName('A23').setText('8');
    sheet.getRangeByName('A23').cellStyle.fontSize = 9;
    sheet.getRangeByName('A23').cellStyle.bold = true;
    sheet.getRangeByName('A23').cellStyle.hAlign = HAlignType.center;

    sheet.getRangeByName('B23').setText('Trợ cấp đào tạo tháng đầu: ');
    sheet.getRangeByName('B23').cellStyle.hAlign = HAlignType.left;
    sheet.getRangeByName('B23').cellStyle.fontSize = 9;
    sheet.getRangeByName('B23').cellStyle.bold = true;
    sheet.getRangeByName('B23').columnWidth = 20;

    sheet.getRangeByName('A24').setText('9');
    sheet.getRangeByName('A24').cellStyle.fontSize = 9;
    sheet.getRangeByName('A24').cellStyle.bold = true;
    sheet.getRangeByName('A24').cellStyle.hAlign = HAlignType.center;

    sheet.getRangeByName('B24').setText('Bảo hiểm xã hội, thân thể, bảo hiểm thất nghiệp : ');
    sheet.getRangeByName('B24').cellStyle.hAlign = HAlignType.left;
    sheet.getRangeByName('B24').cellStyle.fontSize = 9;
    sheet.getRangeByName('B24').cellStyle.bold = true;
    sheet.getRangeByName('B24').columnWidth = 20;

    sheet.getRangeByName('A25').setText('10');
    sheet.getRangeByName('A25').cellStyle.fontSize = 9;
    sheet.getRangeByName('A25').cellStyle.bold = true;
    sheet.getRangeByName('A25').cellStyle.hAlign = HAlignType.center;

    sheet.getRangeByName('B25').setText('Ngày dự kiến nhập cảnh: ');
    sheet.getRangeByName('B25').cellStyle.hAlign = HAlignType.left;
    sheet.getRangeByName('B25').cellStyle.fontSize = 9;
    sheet.getRangeByName('B25').cellStyle.bold = true;
    sheet.getRangeByName('B25').columnWidth = 20;

    sheet.getRangeByName('A26').setText('11');
    sheet.getRangeByName('A26').cellStyle.fontSize = 9;
    sheet.getRangeByName('A26').cellStyle.bold = true;
    sheet.getRangeByName('A26').cellStyle.hAlign = HAlignType.center;

    sheet.getRangeByName('B26').setText('Thời gian dự kiến thi tuyển: ');
    sheet.getRangeByName('B26').cellStyle.hAlign = HAlignType.left;
    sheet.getRangeByName('B26').cellStyle.fontSize = 9;
    sheet.getRangeByName('B26').cellStyle.bold = true;
    sheet.getRangeByName('B26').columnWidth = 20;

    sheet.getRangeByName('A27:D27').merge();
    sheet.getRangeByName('A27').setText('II. Yêu cầu phối hợp thực hiện (Các phòng/Bộ phận phải nắm rõ và chấp hành )');
    sheet.getRangeByName('A27').cellStyle.fontSize = 9;
    sheet.getRangeByName('A27').cellStyle.bold = true;
    sheet.getRangeByName('A27').cellStyle.hAlign = HAlignType.left;
    sheet.getRangeByName('A27').rowHeight = 30;

//II
    sheet.getRangeByName('A28').setText('STT');
    sheet.getRangeByName('A28').cellStyle.fontSize = 9;
    sheet.getRangeByName('A28').cellStyle.bold = true;
    sheet.getRangeByName('A28').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('A28').cellStyle.vAlign = VAlignType.center;

    sheet.getRangeByName('B28:D28').columnWidth = 37;
    sheet.getRangeByName('A28:D28').rowHeight = 30;

    sheet.getRangeByName('B28').setText('Công việc');
    sheet.getRangeByName('B28').cellStyle.fontSize = 9;
    sheet.getRangeByName('B28').cellStyle.bold = true;
    sheet.getRangeByName('B28').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('B28').cellStyle.vAlign = VAlignType.center;

    sheet.getRangeByName('C28').setText('Thời gian phải hoàn thành');
    sheet.getRangeByName('C28').cellStyle.fontSize = 9;
    sheet.getRangeByName('C28').cellStyle.bold = true;
    sheet.getRangeByName('C28').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('C28').cellStyle.vAlign = VAlignType.center;

    sheet.getRangeByName('D28').setText('Bộ phận chịu trách nhiệm');
    sheet.getRangeByName('D28').cellStyle.fontSize = 9;
    sheet.getRangeByName('D28').cellStyle.bold = true;
    sheet.getRangeByName('D28').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('D28').cellStyle.vAlign = VAlignType.center;

    sheet.getRangeByName('A29').setText('1');
    sheet.getRangeByName('A29').cellStyle.fontSize = 9;
    sheet.getRangeByName('A29').cellStyle.hAlign = HAlignType.center;

    sheet.getRangeByName('B29').setText('Số form cần test: ');
    sheet.getRangeByName('B29').cellStyle.hAlign = HAlignType.left;
    sheet.getRangeByName('B29').cellStyle.fontSize = 9;

    sheet.getRangeByName('C29').setText(listDonHang[i].testFormNumber.toString());
    sheet.getRangeByName('C29').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('C29').cellStyle.vAlign = VAlignType.center;
    sheet.getRangeByName('C29').cellStyle.fontSize = 9;
    sheet.getRangeByName('C29').cellStyle.bold = true;
    sheet.getRangeByName('C29').columnWidth = 20;

    sheet.getRangeByName('C30').setText(
        listDonHang[i].sendListFormDate != null ? FormatDate.formatDateView(DateTime.tryParse(listDonHang[i].sendListFormDate!.toString())!) : "");
    sheet.getRangeByName('C30').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('C30').cellStyle.vAlign = VAlignType.center;
    sheet.getRangeByName('C30').cellStyle.fontSize = 9;
    sheet.getRangeByName('C30').cellStyle.bold = true;
    sheet.getRangeByName('C30').columnWidth = 20;

    sheet.getRangeByName('C30').setText(
        listDonHang[i].sendListFormDate != null ? FormatDate.formatDateView(DateTime.tryParse(listDonHang[i].sendListFormDate!.toString())!) : "");
    sheet.getRangeByName('C31').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('C31').cellStyle.vAlign = VAlignType.center;
    sheet.getRangeByName('C31').cellStyle.fontSize = 9;
    sheet.getRangeByName('C31').cellStyle.bold = true;
    sheet.getRangeByName('C31').columnWidth = 20;

    sheet.getRangeByName('A30').setText('2');
    sheet.getRangeByName('A30').cellStyle.fontSize = 9;
    sheet.getRangeByName('A30').cellStyle.hAlign = HAlignType.center;

    sheet.getRangeByName('B30').setText('Check Form tiến cử (test IQ + tay nghề: ');
    sheet.getRangeByName('B30').cellStyle.hAlign = HAlignType.left;
    sheet.getRangeByName('B30').cellStyle.fontSize = 9;

    sheet.getRangeByName('A31').setText('3');
    sheet.getRangeByName('A31').cellStyle.fontSize = 9;
    sheet.getRangeByName('A31').cellStyle.hAlign = HAlignType.center;

    sheet.getRangeByName('B31').setText('Gửi list và Form cho đối tác: ');
    sheet.getRangeByName('B31').cellStyle.hAlign = HAlignType.left;
    sheet.getRangeByName('B31').cellStyle.fontSize = 9;

    sheet.getRangeByName('A32').setText('4');
    sheet.getRangeByName('A32').cellStyle.fontSize = 9;
    sheet.getRangeByName('A32').cellStyle.hAlign = HAlignType.center;

    sheet.getRangeByName('B32').setText('Kiểm tra lại TTS trước thi tuyển ít nhất 03 ngày: ');
    sheet.getRangeByName('B32').cellStyle.hAlign = HAlignType.left;
    sheet.getRangeByName('B32').cellStyle.fontSize = 9;

    sheet.getRangeByName('A33').setText('5');
    sheet.getRangeByName('A33').cellStyle.fontSize = 9;
    sheet.getRangeByName('A33').cellStyle.hAlign = HAlignType.center;

    sheet.getRangeByName('B33').setText('Căn dặn nhắc nhở TTS trước thi tuyển ít nhất 02 ngày.: ');
    sheet.getRangeByName('B33').cellStyle.hAlign = HAlignType.left;
    sheet.getRangeByName('B33').cellStyle.fontSize = 9;

    sheet.getRangeByName('A34:D34').merge();
    sheet.getRangeByName('A35:D35').merge();
    sheet.getRangeByName('A36:C36').merge();
    sheet.getRangeByName('A37:C37').merge();
    sheet.getRangeByName('A38:C38').merge();

    sheet.getRangeByName('D36').setText('Ngày 18 tháng03 năm 2022');
    sheet.getRangeByName('D36').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('D36').cellStyle.fontSize = 9;
    sheet.getRangeByName('D36').cellStyle.bold = true;

    sheet.getRangeByName('A37').setText('Yêu cầu các phòng ban nắm rõ chính xác yêu cầu và thực hiện nghiêm túc');
    sheet.getRangeByName('A37').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('A37').cellStyle.fontSize = 9;
    sheet.getRangeByName('A37').cellStyle.bold = true;

    sheet.getRangeByName('D38').setText(' PHÒNG PTTT NB');
    sheet.getRangeByName('D38').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('D38').cellStyle.fontSize = 9;
    sheet.getRangeByName('D38').cellStyle.bold = true;

    sheet.getRangeByName('A38').setText('GĐ TUYỂN DỤNG ');
    sheet.getRangeByName('A38').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('A38').cellStyle.fontSize = 9;
    sheet.getRangeByName('A38').cellStyle.bold = true;

    sheet.getRangeByName('A39:D39').merge();
    sheet.getRangeByName('A40:D40').merge();
    sheet.getRangeByName('A41:D41').merge();
    sheet.getRangeByName('A42:D42').merge();
    sheet.getRangeByName('A43:C43').merge();
    // sheet.getRangeByName('C18:D18').merge();
    // sheet.getRangeByName('C19:D19').merge();
    // sheet.getRangeByName('C20:D20').merge();
    sheet.getRangeByName('C18:D20').merge();

    sheet.getRangeByName('D43').setText('TỐNG THỊ THAO');
    sheet.getRangeByName('D43').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('D43').cellStyle.fontSize = 9;
    sheet.getRangeByName('D43').cellStyle.bold = true;

    sheet.getRangeByName('A44:D44').merge();

    sheet.getRangeByName('A1:D1').cellStyle.borders.top.lineStyle = LineStyle.medium;
    sheet.getRangeByName('A1:A44').cellStyle.borders.left.lineStyle = LineStyle.medium;
    sheet.getRangeByName('A44:D44').cellStyle.borders.bottom.lineStyle = LineStyle.medium;
    sheet.getRangeByName('D1:D44').cellStyle.borders.right.lineStyle = LineStyle.medium;
    sheet.getRangeByName('A6:D6').cellStyle.borders.bottom.lineStyle = LineStyle.medium;
    sheet.getRangeByName('A28:D34').cellStyle.borders.top.lineStyle = LineStyle.medium;

    sheet.getRangeByName('A7:D7').cellStyle.borders.bottom.lineStyle = LineStyle.thin;
    sheet.getRangeByName('A8:D8').cellStyle.borders.bottom.lineStyle = LineStyle.thin;
    sheet.getRangeByName('A9:D9').cellStyle.borders.bottom.lineStyle = LineStyle.thin;
    sheet.getRangeByName('A10:D10').cellStyle.borders.bottom.lineStyle = LineStyle.thin;
    sheet.getRangeByName('A2').cellStyle.borders.all.lineStyle = LineStyle.thin;
    sheet.getRangeByName('A11:D11').cellStyle.borders.bottom.lineStyle = LineStyle.thin;
    sheet.getRangeByName('B12:D12').cellStyle.borders.bottom.lineStyle = LineStyle.thin;
    sheet.getRangeByName('B13:D13').cellStyle.borders.bottom.lineStyle = LineStyle.thin;
    sheet.getRangeByName('B14:D14').cellStyle.borders.bottom.lineStyle = LineStyle.thin;

    sheet.getRangeByName('B15:D17').cellStyle.borders.bottom.lineStyle = LineStyle.thin;
    sheet.getRangeByName('B18:D20').cellStyle.borders.bottom.lineStyle = LineStyle.thin;

    sheet.getRangeByName('A7:A27').cellStyle.borders.right.lineStyle = LineStyle.thin;
    sheet.getRangeByName('B7:B27').cellStyle.borders.right.lineStyle = LineStyle.thin;
    sheet.getRangeByName('A21:D21').cellStyle.borders.bottom.lineStyle = LineStyle.thin;
    sheet.getRangeByName('A21:D21').cellStyle.borders.top.lineStyle = LineStyle.thin;
    sheet.getRangeByName('A22:D22').cellStyle.borders.bottom.lineStyle = LineStyle.thin;
    sheet.getRangeByName('A23:D23').cellStyle.borders.bottom.lineStyle = LineStyle.thin;
    sheet.getRangeByName('A24:D24').cellStyle.borders.bottom.lineStyle = LineStyle.thin;
    sheet.getRangeByName('A25:D25').cellStyle.borders.bottom.lineStyle = LineStyle.thin;
    sheet.getRangeByName('A26:D26').cellStyle.borders.bottom.lineStyle = LineStyle.thin;
    sheet.getRangeByName('A26:D26').cellStyle.borders.right.lineStyle = LineStyle.thin;
    sheet.getRangeByName('B28:B34').cellStyle.borders.right.lineStyle = LineStyle.thin;
    sheet.getRangeByName('A28:A34').cellStyle.borders.right.lineStyle = LineStyle.thin;
    sheet.getRangeByName('C28:C34').cellStyle.borders.right.lineStyle = LineStyle.thin;

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    if (kIsWeb) {
      AnchorElement(href: 'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
        ..setAttribute('download', 'Output.xlsx')
        ..click();
    } else {
      final String path = (await getApplicationSupportDirectory()).path;
      final String fileName = Platform.isWindows ? '$path\\Output.xlsx' : '$path/Output.xlsx';
      final File file = File(fileName);

      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open(fileName);
      File(fileName).writeAsBytes(bytes);
    }
  }
}
