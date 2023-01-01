import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:gentelella_flutter/common/format_date.dart';

import 'package:gentelella_flutter/model/market_development/order.dart';

import 'package:gentelella_flutter/widgets/forms/market_development/utils/funciton.dart';

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_io/io.dart';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:universal_html/html.dart' show AnchorElement;
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../../api.dart';
import '../../../../config.dart';
import '../../../../model/market_development/nghiepdoan_tts_xuat_canh.dart';
import '../../../../model/market_development/user.dart';
import 'package:http/http.dart' as http;

Future<List<int>> _readImageData(String name) async {
  final ByteData data = await rootBundle.load('assets/images/$name');
  return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}

bool validate(data) {
  if (data != null && data != '') {
    return true;
  }
  return false;
}

Future<void> renderCheckBox(Worksheet sheet, checking, row, column) async {
  Picture image = sheet.pictures.addBase64(row, column, checking);
  image.height = 10;
  image.width = 10;
}

Future<void> setText(Worksheet sheet, index, text) async {
  sheet.getRangeByName(index).setText(text);
  sheet.getRangeByName(index).cellStyle.hAlign = HAlignType.left;
}

Future<void> renderIV(Worksheet sheet, Order order) async {
  sheet.getRangeByName('F16:I29').cellStyle.borders.all.lineStyle = LineStyle.thin;
  sheet.getRangeByName('F16:I16').merge();
  sheet.getRangeByName('F19:I19').merge();
  sheet.getRangeByName('F22:I29').merge();
  sheet.getRangeByName('F20:I20').merge();
  sheet.getRangeByName('F21:I21').merge();
  sheet.getRangeByName('F17:I17').merge();
  sheet.getRangeByName('F18:I18').merge();

  sheet.getRangeByName('F16').setText('IV. YÊU CẦU ĐẶC BIỆT');
  sheet.getRangeByName('F16').cellStyle.hAlign = HAlignType.left;
  sheet.getRangeByName('F16').cellStyle.bold = true;
  sheet.getRangeByName('F16').cellStyle.backColor = '#F8CBAD';

  sheet.getRangeByName('F17').setText('4.1: Các trường hợp ưu tiên:');
  sheet.getRangeByName('F17').cellStyle.bold = true;
  sheet.getRangeByName('F17').cellStyle.hAlign = HAlignType.left;
  sheet.getRangeByName('F18').setText(validate(order.priorityCases) ? order.priorityCases.toString() : '');

  sheet.getRangeByName('F20').setText('4.2: Chú ý trường hợp không/Hạn chết tiếp nhận:');
  sheet.getRangeByName('F20').cellStyle.bold = true;
  sheet.getRangeByName('F20').cellStyle.hAlign = HAlignType.left;
  sheet.getRangeByName('F21').setText(validate(order.restrictionCases) ? order.restrictionCases.toString() : '');
}

Future<void> renderVIII(Worksheet sheet, Order order) async {
  sheet.getRangeByName('F38:I50').cellStyle.borders.all.lineStyle = LineStyle.thin;
  sheet.getRangeByName('F38:I38').merge();
  sheet.getRangeByName('F38').setText('VIII. CHỈ HIỆN THỊ NỘI BỘ');
  sheet.getRangeByName('F38').cellStyle.hAlign = HAlignType.left;
  sheet.getRangeByName('F38').cellStyle.bold = true;
  sheet.getRangeByName('F38').cellStyle.backColor = '#F8CBAD';
  sheet.getRangeByName('F39:I39').merge();
  sheet.getRangeByName('F39').setText('8.1: Hình ảnh');
  sheet.getRangeByName('F39').cellStyle.hAlign = HAlignType.left;
  // sheet.getRangeByName('F40:I43').merge();
  // if (validate(order.image)) {
  sheet.getRangeByName('F40:I43').merge();
  // Picture image = sheet.pictures.addBase64(40, 6, base64.encode(await _readImageData('logoAAM.png')));
  // image.height = 200;
  // image.width = 200;

  // // }
  // if (validate(order.image2)) {
  sheet.getRangeByName('F44:I47').merge();
  // Picture image2 = sheet.pictures.addBase64(44, 6, base64.encode(await _readImageData('logoAAM.png')));
  // image2.height = 200;
  // image2.width = 200;

  // }
  List<HAlignType> type = [HAlignType.center, HAlignType.left];

  sheet.getRangeByName('F48:I48').merge();
  setText(sheet, 'F48', '8.2: Nội dung thi tuyển cần chuẩn bị');
  sheet.getRangeByName('F49:I50').merge();
  setText(sheet, 'F49', validate(order.description) ? order.description.toString() : '');
  sheet.getRangeByName('F49').cellStyle.hAlign = HAlignType.left;
}

Future<void> renderV(Worksheet sheet, Order order) async {
  sheet.getRangeByName('A31:D36').cellStyle.borders.all.lineStyle = LineStyle.thin;
  sheet.getRangeByName('A31:D31').merge();
  sheet.getRangeByName('B32:D32').merge();
  sheet.getRangeByName('B33:D33').merge();
  sheet.getRangeByName('A34:D36').merge();
  sheet.getRangeByName('A31').setText('V. HÌNH THỨC VÀ NỘI DUNG THI TUYỂN');
  sheet.getRangeByName('A31').cellStyle.bold = true;
  sheet.getRangeByName('A31').cellStyle.backColor = '#F8CBAD';

  sheet.getRangeByName('A32').setText('5.1: Hình thức thi tuyển');
  sheet.getRangeByName('A32').cellStyle.bold = true;
  sheet.getRangeByName('A32').cellStyle.hAlign = HAlignType.left;
  sheet.getRangeByName('B32').setText(validate(order.recruiMethod) ? order.recruiMethod.toString() : '');

  sheet.getRangeByName('A33').setText('5.2: Nội dung thi tuyển cần chuẩn bị');
  sheet.getRangeByName('A33').cellStyle.bold = true;
  sheet.getRangeByName('A33').cellStyle.hAlign = HAlignType.left;
  sheet.getRangeByName('B33').setText(order.recruiContent);
}

Future<void> renderVII(Worksheet sheet, Order order) async {
  sheet.getRangeByName('A38:D43').cellStyle.borders.all.lineStyle = LineStyle.thin;
  sheet.getRangeByName('A38:D38').merge();
  sheet.getRangeByName('A38').setText('VII. QUYỀN LỢI VÀ MỨC LƯƠNG THỰC TẬP SINH');
  sheet.getRangeByName('A38').cellStyle.bold = true;
  sheet.getRangeByName('A38').cellStyle.backColor = '#F8CBAD';

  sheet.getRangeByName('A39').setText('7.1: Trợ cấp tháng đầu');
  sheet.getRangeByName('A39').cellStyle.bold = true;
  sheet.getRangeByName('A39:A43').cellStyle.hAlign = HAlignType.left;
  sheet.getRangeByName('B39:D39').merge();
  sheet.getRangeByName('B39').cellStyle.hAlign = HAlignType.left;
  sheet.getRangeByName('B39').setText(validate(order.firstMonthSubsidy) ? order.firstMonthSubsidy.toString() : '');

  sheet.getRangeByName('A40').setText('7.2: Lương cơ bản');
  sheet.getRangeByName('A40').cellStyle.bold = true;
  sheet.getRangeByName('B40').setText(validate(order.salary) ? order.salary.toString() : '');
  sheet.getRangeByName('B40').cellStyle.hAlign = HAlignType.left;

  sheet.getRangeByName('A41').setText('7.3: Các loại bảo hiểm');
  sheet.getRangeByName('A41').cellStyle.bold = true;
  sheet.getRangeByName('B41:D41').merge();
  sheet.getRangeByName('B42:D42').merge();
  sheet.getRangeByName('B43:D43').merge();
  sheet.getRangeByName('B40:D40').merge();
  sheet.getRangeByName('B41').setText(validate(order.insurance) ? order.insurance.toString() : '');
  sheet.getRangeByName('B41').cellStyle.hAlign = HAlignType.left;

  sheet.getRangeByName('A42').setText('7.4: Tiền điện, nước, wifi');
  sheet.getRangeByName('A42').cellStyle.bold = true;
  sheet.getRangeByName('B42').setText(validate(order.livingCost) ? order.livingCost.toString() : '');
  sheet.getRangeByName('B42').cellStyle.hAlign = HAlignType.left;

  sheet.getRangeByName('A43').setText('7.5: Thực lĩnh');
  sheet.getRangeByName('A43').cellStyle.bold = true;
  sheet.getRangeByName('B43').setText(validate(order.netMoney) ? order.netMoney.toString() : '');
  sheet.getRangeByName('B43').cellStyle.hAlign = HAlignType.left;
}

Future<void> renderVI(Worksheet sheet, Order order) async {
  sheet.getRangeByName('F31:I36').cellStyle.borders.all.lineStyle = LineStyle.thin;
  sheet.getRangeByName('F31:I31').merge();
  sheet.getRangeByName('G32:I32').merge();
  sheet.getRangeByName('G33:I33').merge();
  sheet.getRangeByName('G34:I34').merge();
  sheet.getRangeByName('G35:I35').merge();
  sheet.getRangeByName('G36:I36').merge();

  sheet.getRangeByName('F31').setText('VI. LỊCH THI TUYỂN');
  sheet.getRangeByName('F31').cellStyle.hAlign = HAlignType.left;
  sheet.getRangeByName('F31').cellStyle.bold = true;
  sheet.getRangeByName('F31').cellStyle.backColor = '#F8CBAD';

  sheet.getRangeByName('F32').setText('6.1: Số form cần test');
  sheet.getRangeByName('F32').cellStyle.hAlign = HAlignType.left;
  sheet.getRangeByName('F32').cellStyle.bold = true;
  sheet.getRangeByName('G32').setText((validate(order.testFormNumber)) ? order.testFormNumber.toString() : '');

  sheet.getRangeByName('F33').setText('6.2: Ngày gửi list và form cho đối tác');
  sheet.getRangeByName('F33').cellStyle.hAlign = HAlignType.left;
  sheet.getRangeByName('F33').cellStyle.bold = true;
  sheet.getRangeByName('G33').setText(getDateView(order.sendListFormDate));

  sheet.getRangeByName('F34').setText('6.3: Ngày thi tuyển');
  sheet.getRangeByName('F34').cellStyle.hAlign = HAlignType.left;
  sheet.getRangeByName('F34').cellStyle.bold = true;
  sheet.getRangeByName('G34').setText(getDateView(order.estimatedInterviewDate));

  sheet.getRangeByName('F35').setText('6.4: Ngày nhập học');
  sheet.getRangeByName('F35').cellStyle.hAlign = HAlignType.left;
  sheet.getRangeByName('F35').cellStyle.bold = true;
  sheet.getRangeByName('G35').setText(getDateView(order.estimatedAdmissionDate));

  sheet.getRangeByName('F36').setText('6.5: Lịch nhập cảnh dự kiến');
  sheet.getRangeByName('F36').cellStyle.hAlign = HAlignType.left;
  sheet.getRangeByName('F36').cellStyle.bold = true;
  sheet.getRangeByName('G36').setText(getDateView(order.estimatedEntryDate));
}

renderI(Worksheet sheet, Order order) {
  //Row 1
  //Row 1 Clolumn 1
  sheet.getRangeByName('A8:D8').merge();
  sheet.getRangeByName('A8').setText('I. THÔNG TIN ĐƠN HÀNG');
  sheet.getRangeByName('A8').cellStyle.bold = true;
  sheet.getRangeByName('A8').cellStyle.hAlign = HAlignType.left;
  sheet.getRangeByName('A8').cellStyle.backColor = '#F8CBAD';

  sheet.getRangeByName('A9').setText('1.1: Nghiệp đoàn');
  sheet.getRangeByName('A9').cellStyle.bold = true;

  sheet.getRangeByName('B9').setText('${order.union!.orgCode.toString()}');
  sheet.getRangeByName('A9').cellStyle.hAlign = HAlignType.left;
  sheet.getRangeByName('B9').cellStyle.hAlign = HAlignType.left;

  sheet.getRangeByName('A10').setText('1.1: Xí nghiệp tiếp nhận');
  sheet.getRangeByName('A10').cellStyle.bold = true;
  sheet.getRangeByName('B10').setText('${order.enterprise!.companyCode.toString()}');
  sheet.getRangeByName('A10').cellStyle.hAlign = HAlignType.left;
  sheet.getRangeByName('B10').cellStyle.hAlign = HAlignType.left;

  sheet.getRangeByName('A11').setText('1.2: Địa điểm làm việc');
  sheet.getRangeByName('A11').cellStyle.bold = true;
  sheet.getRangeByName('B11').setText('${order.workAddress.toString()}');
  sheet.getRangeByName('A11').cellStyle.hAlign = HAlignType.left;
  sheet.getRangeByName('B11').cellStyle.hAlign = HAlignType.left;

  sheet.getRangeByName('A12').setText('1.3: Ngành nghề xin visa');
  sheet.getRangeByName('A12').cellStyle.bold = true;
  sheet.getRangeByName('B12').setText(order.jobs!.jobName);
  sheet.getRangeByName('A12').cellStyle.hAlign = HAlignType.left;
  sheet.getRangeByName('B12').cellStyle.hAlign = HAlignType.left;

  sheet.getRangeByName('A13').setText('1.4: Mô tả công việc cụ thể');
  sheet.getRangeByName('A13').cellStyle.bold = true;
  sheet.getRangeByName('B13').setText(order.jobsDetail!.jobName);
  sheet.getRangeByName('A13').cellStyle.hAlign = HAlignType.left;
  sheet.getRangeByName('B13').cellStyle.hAlign = HAlignType.left;

  sheet.getRangeByName('A14').setText('');
  sheet.getRangeByName('A14').cellStyle.bold = true;
  sheet.getRangeByName('B14').setText("");
  sheet.getRangeByName('A14').cellStyle.hAlign = HAlignType.left;
  sheet.getRangeByName('B14').cellStyle.hAlign = HAlignType.left;

  sheet.getRangeByName('A9:D14').cellStyle.borders.all.lineStyle = LineStyle.thin;
  sheet.getRangeByName('B9:D9').merge();
  sheet.getRangeByName('B10:D10').merge();
  sheet.getRangeByName('B11:D11').merge();
  sheet.getRangeByName('B12:D12').merge();
  sheet.getRangeByName('B13:D13').merge();
  sheet.getRangeByName('B14:D14').merge();

  sheet.getRangeByName('A8').cellStyle.borders.all.lineStyle = LineStyle.thin;
  sheet.getRangeByName('B7').cellStyle.borders.bottom.lineStyle = LineStyle.thin;
  sheet.getRangeByName('C7').cellStyle.borders.bottom.lineStyle = LineStyle.thin;
  sheet.getRangeByName('D7').cellStyle.borders.bottom.lineStyle = LineStyle.thin;

  sheet.getRangeByName('E8').cellStyle.borders.left.lineStyle = LineStyle.thin;
  sheet.getRangeByName('E8').cellStyle.borders.right.lineStyle = LineStyle.thin;
}

renderII(Worksheet sheet, Order order, checkImage, notCheckImage, selectedImage, unselectedImage) {
  //Add ảnh
  PicturesCollection img1 = sheet.pictures;

  if (order.genderRequired == 2) {
    Picture picture1 = img1.addBase64(9, 7, checkImage);
    Picture picture2 = img1.addBase64(9, 8, checkImage);
    picture1.height = 10;
    picture1.width = 10;

    picture2.height = 10;
    picture2.width = 10;
  } else if (order.genderRequired == 0) {
    Picture picture1 = img1.addBase64(9, 7, checkImage);
    Picture picture2 = img1.addBase64(9, 8, notCheckImage);
    picture1.height = 10;
    picture1.width = 10;

    picture2.height = 10;
    picture2.width = 10;
  } else {
    Picture picture1 = img1.addBase64(9, 7, notCheckImage);
    Picture picture2 = img1.addBase64(9, 8, checkImage);
    picture1.height = 10;
    picture1.width = 10;

    picture2.height = 10;
    picture2.width = 10;
  }

  sheet.getRangeByName('F10').setText('2.2: Độ tuổi');
  sheet.getRangeByName('F10').cellStyle.bold = true;
  sheet.getRangeByName('G10').setText("Từ " + order.ageFrom!.toString() + " đến " + order.ageTo!.toString() + " tuổi");
  sheet.getRangeByName('F10').cellStyle.hAlign = HAlignType.left;
  sheet.getRangeByName('G10').cellStyle.hAlign = HAlignType.left;

  sheet.getRangeByName('F11:F12').merge();
  sheet.getRangeByName('F11').setText('2.3: Số lượng');
  sheet.getRangeByName('F11').cellStyle.bold = true;
  sheet.getRangeByName('G11').setText('${order.ttsRequired} Thi tuyển \t ${order.ttsMaleRequired} Nam\t ${order.ttsFemaleRequired} Nữ');
  sheet.getRangeByName('F11').cellStyle.hAlign = HAlignType.left;
  sheet.getRangeByName('G11').cellStyle.hAlign = HAlignType.left;

  // sheet.getRangeByName('F12').setText('2.4: Trình độ');
  // sheet.getRangeByName('F12').cellStyle.bold = true;
  sheet.getRangeByName('G12').setText('${order.ttsCandidates} Trúng tuyển \t ${order.ttsMaleCandidates} Nam\t ${order.ttsFemaleCandidates} Nữ');
  sheet.getRangeByName('F12').cellStyle.hAlign = HAlignType.left;
  sheet.getRangeByName('G12').cellStyle.hAlign = HAlignType.left;

  sheet.getRangeByName('F13').setText('2.4: Trình độ');
  sheet.getRangeByName('F13').cellStyle.bold = true;
  sheet.getRangeByName('G13').setText(order.level != null ? order.level!.name : "Chưa có dữ liệu");
  sheet.getRangeByName('F13').cellStyle.hAlign = HAlignType.left;
  sheet.getRangeByName('G13').cellStyle.hAlign = HAlignType.left;

  sheet.getRangeByName('F14').setText('2.5: Yêu cầu tay nghề');
  sheet.getRangeByName('F14').cellStyle.bold = true;
  sheet.getRangeByName('G14').setText('${order.skill.toString()}');
  sheet.getRangeByName('F14').cellStyle.hAlign = HAlignType.left;
  sheet.getRangeByName('G14').cellStyle.hAlign = HAlignType.left;

  // sheet.getRangeByName('G9:I9').merge();
  sheet.getRangeByName('G10:I10').merge();
  sheet.getRangeByName('G11:I11').merge();
  sheet.getRangeByName('G12:I12').merge();
  sheet.getRangeByName('G13:I13').merge();
  sheet.getRangeByName('G14:I14').merge();

  sheet.getRangeByName('F9:I14').cellStyle.borders.all.lineStyle = LineStyle.thin;

  sheet.getRangeByName('F7').cellStyle.borders.bottom.lineStyle = LineStyle.thin;
  sheet.getRangeByName('G7').cellStyle.borders.bottom.lineStyle = LineStyle.thin;
  sheet.getRangeByName('H7').cellStyle.borders.bottom.lineStyle = LineStyle.thin;
  sheet.getRangeByName('I7').cellStyle.borders.bottom.lineStyle = LineStyle.thin;
  sheet.getRangeByName('J8').cellStyle.borders.left.lineStyle = LineStyle.thin;
}

renderIII(Worksheet sheet, Order order, checkImage, notCheckImage, selectedImage, unselectedImage) {
  sheet.getRangeByName('A16:D29').cellStyle.borders.all.lineStyle = LineStyle.thin;
  sheet.getRangeByName('A16:D16').merge();
  sheet.getRangeByName('B17:D17').merge();
  sheet.getRangeByName('B18:D18').merge();
  sheet.getRangeByName('B19:D19').merge();
  sheet.getRangeByName('A16').setText('III. YÊU CẦU SỨC KHỎE');
  sheet.getRangeByName('A16').cellStyle.bold = true;
  sheet.getRangeByName('A16').cellStyle.hAlign = HAlignType.left;
  sheet.getRangeByName('A16').cellStyle.backColor = '#F8CBAD';

  sheet.getRangeByName('A17').setText('3.1: Thị lực');
  sheet.getRangeByName('A17').cellStyle.bold = true;

  sheet.getRangeByName('B17').setText('${order.eyeSight.toString()}');
  sheet.getRangeByName('A17').cellStyle.hAlign = HAlignType.left;
  sheet.getRangeByName('B17').cellStyle.hAlign = HAlignType.left;

  sheet.getRangeByName('A18').setText('Đối với TTS đeo kính: ');
  sheet.getRangeByName('B18').setText('${order.eyeSightGlasses.toString()}');
  sheet.getRangeByName('A18').cellStyle.hAlign = HAlignType.left;
  sheet.getRangeByName('B18').cellStyle.hAlign = HAlignType.left;

  sheet.getRangeByName('A19').setText('Đối với TTS cam kết mổ mắt: ');
  sheet.getRangeByName('B19').setText('${order.eyeSightSurgery.toString()}');
  sheet.getRangeByName('A19').cellStyle.hAlign = HAlignType.left;
  sheet.getRangeByName('B19').cellStyle.hAlign = HAlignType.left;

  sheet.getRangeByName('A20').setText('3.2: Thể lực');
  sheet.getRangeByName('A20').cellStyle.bold = true;
  sheet.getRangeByName('A20').cellStyle.hAlign = HAlignType.left;
  sheet.getRangeByName('B20').cellStyle.hAlign = HAlignType.left;

  sheet.getRangeByName('B20').setText('Chiều cao ${order.heigth.toString()} cm');
  sheet.getRangeByName('B20').cellStyle.hAlign = HAlignType.left;

  sheet.getRangeByName('C20').setText('Cân nặng ${order.weight.toString()} kg');
  sheet.getRangeByName('C20').cellStyle.hAlign = HAlignType.left;

  sheet.getRangeByName('A21').setText('3.3: Tay thuận');

  sheet.getRangeByName('A21').cellStyle.bold = true;
  sheet.getRangeByName('A21').cellStyle.hAlign = HAlignType.left;
  sheet.getRangeByName('B21').cellStyle.hAlign = HAlignType.left;
  sheet.getRangeByName('C21:D21').merge();
  sheet.getRangeByName('C22:D22').merge();
  setText(sheet, 'B21', 'Tay trái');
  setText(sheet, 'C21', 'Tay phải');
  if (validate(order.leftHanded) && validate(order.rightHanded)) {
    if (order.leftHanded == 1) {
      renderCheckBox(sheet, checkImage, 21, 2);
    }
    if (order.leftHanded == 0) {
      renderCheckBox(sheet, notCheckImage, 21, 2);
    }
    if (order.rightHanded == 1) {
      renderCheckBox(sheet, checkImage, 21, 3);
    }
    if (order.rightHanded == 0) {
      renderCheckBox(sheet, notCheckImage, 21, 3);
    }
  } else {
    renderCheckBox(sheet, notCheckImage, 21, 2);
    renderCheckBox(sheet, notCheckImage, 21, 3);
  }
  setText(sheet, 'A22', '3.4: Tình trạng hôn nhân');
  sheet.getRangeByName('A22').cellStyle.bold = true;
  sheet.getRangeByName('A22').cellStyle.hAlign = HAlignType.left;
  sheet.getRangeByName('B22').cellStyle.hAlign = HAlignType.left;

  sheet.getRangeByName('B22').setText('Chưa kết hôn');
  sheet.getRangeByName('C22').setText('Đã kết hôn');
  if (validate(order.maritalStatus)) {
    if (order.maritalStatus == 2) {
      renderCheckBox(sheet, checkImage, 22, 2);
      renderCheckBox(sheet, checkImage, 22, 3);
    } else if (order.maritalStatus == 0) {
      renderCheckBox(sheet, checkImage, 22, 2);
      renderCheckBox(sheet, notCheckImage, 22, 3);
    } else {
      renderCheckBox(sheet, notCheckImage, 22, 2);
      renderCheckBox(sheet, checkImage, 22, 3);
    }
  } else {
    renderCheckBox(sheet, notCheckImage, 22, 2);
    renderCheckBox(sheet, notCheckImage, 22, 3);
  }
  sheet.getRangeByName('C24:D24').merge();
  sheet.getRangeByName('C25:D25').merge();
  sheet.getRangeByName('C26:D26').merge();
  sheet.getRangeByName('C27:D27').merge();
  sheet.getRangeByName('C28:D28').merge();
  sheet.getRangeByName('C29:D29').merge();
  setText(sheet, 'A23', '3.5: Yêu cầu khác');
  sheet.getRangeByName('A23').cellStyle.bold = true;
  setText(sheet, 'B23', 'Nhận form');
  sheet.getRangeByName('B23').cellStyle.bold = true;
  setText(sheet, 'C23', 'Không nhận form');
  sheet.getRangeByName('C23').cellStyle.bold = true;
  setText(sheet, 'A24', 'Hút thuốc');
  if (validate(order.smoke)) {
    if (order.smoke == 1) {
      renderCheckBox(sheet, selectedImage, 24, 2);
      renderCheckBox(sheet, unselectedImage, 24, 3);
    } else {
      renderCheckBox(sheet, unselectedImage, 24, 2);
      renderCheckBox(sheet, selectedImage, 24, 3);
    }
  }
  setText(sheet, 'A25', 'Uống rượu');
  if (validate(order.drinkAlcohol)) {
    if (order.drinkAlcohol == 1) {
      renderCheckBox(sheet, selectedImage, 25, 2);
      renderCheckBox(sheet, unselectedImage, 25, 3);
    } else {
      renderCheckBox(sheet, unselectedImage, 25, 2);
      renderCheckBox(sheet, selectedImage, 25, 3);
    }
  }
  setText(sheet, 'A26', 'Có hình xăm');
  if (validate(order.tattoo)) {
    if (order.tattoo == 1) {
      renderCheckBox(sheet, selectedImage, 26, 2);
      renderCheckBox(sheet, unselectedImage, 26, 3);
    } else {
      renderCheckBox(sheet, unselectedImage, 26, 2);
      renderCheckBox(sheet, selectedImage, 26, 3);
    }
  }
  setText(sheet, 'A27', 'Đã từng phẫu thuật');
  if (validate(order.everSurgery)) {
    if (order.everSurgery == 1) {
      renderCheckBox(sheet, selectedImage, 27, 2);
      renderCheckBox(sheet, unselectedImage, 27, 3);
    } else {
      renderCheckBox(sheet, unselectedImage, 27, 2);
      renderCheckBox(sheet, selectedImage, 27, 3);
    }
  }
  setText(sheet, 'A28', 'Đã từng mổ đẻ(Nữ)');
  if (validate(order.everCesareanSection)) {
    if (order.everCesareanSection == 1) {
      renderCheckBox(sheet, selectedImage, 28, 2);
      renderCheckBox(sheet, unselectedImage, 28, 3);
    } else {
      renderCheckBox(sheet, unselectedImage, 28, 2);
      renderCheckBox(sheet, selectedImage, 28, 3);
    }
  }
  setText(sheet, 'A29', 'Khác');
  if (validate(order.otherHealthRequiredAccept)) {
    if (order.otherHealthRequiredAccept == 1) {
      renderCheckBox(sheet, selectedImage, 29, 2);
      renderCheckBox(sheet, unselectedImage, 29, 3);
    } else {
      renderCheckBox(sheet, unselectedImage, 29, 2);
      renderCheckBox(sheet, selectedImage, 29, 3);
    }
  }

  //
  sheet.getRangeByName('A16').cellStyle.borders.all.lineStyle = LineStyle.thin;
  sheet.getRangeByName('A17:D17').cellStyle.borders.bottom.lineStyle = LineStyle.thin;
  sheet.getRangeByName('C7').cellStyle.borders.bottom.lineStyle = LineStyle.thin;
  sheet.getRangeByName('D7').cellStyle.borders.bottom.lineStyle = LineStyle.thin;

  sheet.getRangeByName('E8').cellStyle.borders.left.lineStyle = LineStyle.thin;
  sheet.getRangeByName('E8').cellStyle.borders.right.lineStyle = LineStyle.thin;
}

Future<void> createExcel(List<Order> listDonHang) async {
  try {
    Map<int, String> _listExamForm = {
      0: 'Thi tuyển trực tiếp',
      1: 'Thi tuyển online',
    };
    for (var i = 0; i < listDonHang.length; i++) {
      final Workbook workbook = Workbook();
      final Worksheet sheet = workbook.worksheets[0];

      try {
        final String imgae = base64.encode(await readImageFromApi(listDonHang[i].union!.phapNhan!.image));
        PicturesCollection img1 = sheet.pictures;
        Picture picture1 = img1.addBase64(1, 1, imgae);
        picture1.height = 60;
        picture1.width = 60;
      } catch (e) {
        print("Ngoại lệ null " + e.toString());
        final String image = base64.encode(await _readImageData('logoAAM.png'));
        sheet.pictures.addBase64(9, 2, image);
      }

      sheet.getRangeByName('A1:AO43').cellStyle.fontSize = 10;
      sheet.getRangeByName('A1:AO43').cellStyle.fontName = "Times New Roman";
      sheet.getRangeByName('A1:A6').columnWidth = 10;
      sheet.getRangeByName('B7').columnWidth = 47;
      sheet.getRangeByName('C7').columnWidth = 26;

      // sheet.getRangeByName('D11:D20').columnWidth = 38;
      sheet.getRangeByName('A1:AO43').cellStyle.hAlign = HAlignType.center;
      sheet.getRangeByName('A1:AO43').cellStyle.vAlign = VAlignType.center;
      sheet.getRangeByName('A1:I1').merge();
      sheet.getRangeByName('A2:I2').merge();
      sheet.getRangeByName('A3:I3').merge();
      sheet.getRangeByName('A4:I4').merge();
      sheet.getRangeByName('A5:I5').merge();
      sheet.getRangeByName('A6:I6').merge();

      sheet.getRangeByName('A3').setText("THÔNG BÁO ĐƠN HÀNG");
      sheet.getRangeByName('A3').cellStyle.fontSize = 16;
      sheet.getRangeByName('A3').cellStyle.bold = true;
      sheet.getRangeByName('A3').displayText;

      sheet.getRangeByName('A4').setText('Đơn hàng ' + listDonHang[i].orderName.toString());
      sheet.getRangeByName('A4').cellStyle.fontSize = 12;
      sheet.getRangeByName('A4').cellStyle.bold = true;

      //Row 1 Clolumn 2
      sheet.getRangeByName('F8:I8').merge();
      sheet.getRangeByName('F8').setText('II. THÔNG TIN TUYỂN DỤNG');
      sheet.getRangeByName('F8').cellStyle.bold = true;
      sheet.getRangeByName('F8').cellStyle.hAlign = HAlignType.left;
      sheet.getRangeByName('F8').cellStyle.backColor = '#F8CBAD';

      sheet.getRangeByName('F9').setText('2.1: Giới tính');
      sheet.getRangeByName('F9').cellStyle.bold = true;
      sheet.getRangeByName('G9').setText('Nam');
      sheet.getRangeByName('F9').cellStyle.hAlign = HAlignType.left;
      sheet.getRangeByName('G9').cellStyle.hAlign = HAlignType.left;
      sheet.getRangeByName('H9:I9').merge();
      sheet.getRangeByName('H9').setText('Nữ');

      final String checkImage = base64.encode(await _readImageData('checked.jpg'));
      final String notCheckImage = base64.encode(await _readImageData('not-check.png'));
      final String selectedImage = base64.encode(await _readImageData('selected.jpg'));
      final String unselectedImage = base64.encode(await _readImageData('unselected.jpg'));

      print("Ping1" + checkImage);
      print("Ping2" + notCheckImage);
      print("Ping3" + selectedImage);
      print("Ping4" + unselectedImage);

      //Add ảnh pháp nhân

      //Row 2
      //Row 2 Clolumn 1

      sheet.getRangeByName('A8:F49').rowHeight = 20;
      renderI(sheet, listDonHang[i]);
      renderII(sheet, listDonHang[i], checkImage, notCheckImage, selectedImage, unselectedImage);
      renderIII(sheet, listDonHang[i], checkImage, notCheckImage, selectedImage, unselectedImage);
      renderIV(sheet, listDonHang[i]);
      renderV(sheet, listDonHang[i]);
      renderVI(sheet, listDonHang[i]);
      renderVII(sheet, listDonHang[i]);
      renderVIII(sheet, listDonHang[i]);

      try {
        final String imgae = base64.encode(await readImageFromApi(listDonHang[i].image));
        PicturesCollection img1 = sheet.pictures;
        Picture picture1 = img1.addBase64(40, 6, imgae);
        picture1.height = 100;
        picture1.width = 200;

        final String imgae1 = base64.encode(await readImageFromApi(listDonHang[i].image));
        PicturesCollection img2 = sheet.pictures;
        Picture picture2 = img2.addBase64(44, 6, imgae1);
        picture2.height = 100;
        picture2.width = 200;
      } catch (e) {
        print("Ngoại lệ null " + e.toString());
        Picture image = sheet.pictures.addBase64(40, 6, base64.encode(await _readImageData('logoAAM.png')));
        image.height = 100;
        image.width = 200;

        // }
        // if (validate(order.image2)) {
        //sheet.getRangeByName('F44:I47').merge();
        Picture image2 = sheet.pictures.addBase64(44, 6, base64.encode(await _readImageData('logoAAM.png')));
        image2.height = 100;
        image2.width = 200;
      }

      //Set độ rộng cho các cột chính
      sheet.getRangeByName('A7').columnWidth = 26;
      sheet.getRangeByName('B7').columnWidth = 13;
      sheet.getRangeByName('C7').columnWidth = 10;
      sheet.getRangeByName('D7').columnWidth = 7;

      sheet.getRangeByName('E7').columnWidth = 2;

      sheet.getRangeByName('F7').columnWidth = 26;
      sheet.getRangeByName('G7').columnWidth = 13;
      sheet.getRangeByName('H7').columnWidth = 10;
      sheet.getRangeByName('I7').columnWidth = 7;

      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      if (kIsWeb) {
        AnchorElement(href: 'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
          ..setAttribute('download', '${listDonHang[i].orderName}.xlsx')
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
  } catch (e) {
    print(e);
  }
}

getNgay(String? dateTime) {
  try {
    if (dateTime != null) {
      return FormatDate.formatDateView(DateTime.parse(dateTime));
    }
  } catch (e) {}
  return "Không có dữ liệu ngày";
}

getThoiHanVaThoiGian(String? ngayXuatCanh, int? chuKyTinhPhi) {
  var object = {};
  try {
    DateTime time = DateTime.parse(ngayXuatCanh!);
    DateTime timeTo = time.add(new Duration(days: chuKyTinhPhi ?? 0));
    object.putIfAbsent("thoiHan", () => "${FormatDate.formatTimeViewYyyyMmDd(time)} ~ ${FormatDate.formatTimeViewYyyyMmDd(timeTo)}");
    object.putIfAbsent("thoiGian", () => chuKyTinhPhi != null ? chuKyTinhPhi ~/ 30 : 0);
    return object;
  } catch (e) {}
  return object;
}

double getDouble(String so) {
  try {
    return double.parse(so);
  } catch (e) {}
  return 0.0;
}

renderDanhSach(List<User> listTts, Worksheet sheet) {
  List<String> listMergeColumnD = [];
  print(listTts);

  try {
    listTts.sort(((a, b) => DateTime.parse(a.departureDate!).compareTo(DateTime.parse(b.departureDate!))));

    Map<String, List<int>> mapLocTheoNgay = {};
    for (int i = 0; i < listTts.length; i++) {
      List<int> index = [];
      if (!mapLocTheoNgay.keys.contains(listTts[i].departureDate)) {
        index.add(i + 1);
        mapLocTheoNgay.putIfAbsent(listTts[i].departureDate!, () => index);
      } else {
        mapLocTheoNgay[listTts[i].departureDate!]!.add(i + 1);
      }
    }

    mapLocTheoNgay.forEach((key, value) {
      if (value.length > 1) {
        listMergeColumnD.add("D${value.first + 4}:D${value.last + 4}");
      }
    });
  } catch (e) {
    print(e);
  }

  // Map<int >
  int indexColumLast = 0;
  String tenHangDauTien = "";
  String tenHangCuoiCung = "";
  for (int i = 0; i < listTts.length; i++) {
    try {
      if (i == 0) {
        tenHangDauTien = "J${5 + i}";
      }
      if (i == listTts.length - 1) {
        tenHangCuoiCung = "J${5 + i}";
      }
      sheet.getRangeByIndex(5 + i, 1).setText("${i + 1}");
      sheet.getRangeByIndex(5 + i, 2).setText(listTts[i].fullName.toString());
      sheet.getRangeByIndex(5 + i, 3).setText(listTts[i].order!.enterprise!.companyName.toString());
      sheet.getRangeByIndex(5 + i, 4).setText(getNgay(listTts[i].departureDate));

      Range range = sheet.getRangeByIndex(5 + i, 5);
      range.setNumber(getDouble(listTts[i].order!.union!.arfareFee.toString()));
      range.numberFormat = '#,##0';

      Range range1 = sheet.getRangeByIndex(5 + i, 6);
      range1.setNumber(getDouble(listTts[i].order!.union!.trainingFee.toString()));
      range1.numberFormat = '#,##0';

      Range range2 = sheet.getRangeByIndex(5 + i, 7);
      range2.setNumber(getDouble(listTts[i].listPhiQuanLyChiTiet.first.feeValue.toString()));
      range2.numberFormat = '#,##0';

      sheet.getRangeByIndex(5 + i, 8).setText(getDateView(listTts[i].ngayThongBaoGanNhat) + "~" + getDateView(listTts[i].ngayThongBaoGanNhatCongChuKy));

      Range range3 = sheet.getRangeByIndex(5 + i, 9);
      range3.setNumber(double.parse(listTts[i].chuKy!.toString()));

      // sheet.getRangeByIndex(5 + i, 9).setText("Thời gian");

      Range range4 = sheet.getRangeByIndex(5 + i, 10);
      range4.setFormula('=G${5 + i}*I${5 + i}');
      range4 = sheet.getRangeByIndex(5 + i, 10);
      range4.numberFormat = '#,##0';

      // sheet.getRangeByIndex(5 + i, 10).setText("");

      sheet.getRangeByIndex(5 + i, 1).cellStyle.borders.all.lineStyle = LineStyle.thin;
      sheet.getRangeByIndex(5 + i, 2).cellStyle.borders.all.lineStyle = LineStyle.thin;
      sheet.getRangeByIndex(5 + i, 3).cellStyle.borders.all.lineStyle = LineStyle.thin;
      sheet.getRangeByIndex(5 + i, 4).cellStyle.borders.all.lineStyle = LineStyle.thin;
      sheet.getRangeByIndex(5 + i, 5).cellStyle.borders.all.lineStyle = LineStyle.thin;
      sheet.getRangeByIndex(5 + i, 6).cellStyle.borders.all.lineStyle = LineStyle.thin;
      sheet.getRangeByIndex(5 + i, 7).cellStyle.borders.all.lineStyle = LineStyle.thin;
      sheet.getRangeByIndex(5 + i, 8).cellStyle.borders.all.lineStyle = LineStyle.thin;
      sheet.getRangeByIndex(5 + i, 9).cellStyle.borders.all.lineStyle = LineStyle.thin;
      sheet.getRangeByIndex(5 + i, 10).cellStyle.borders.all.lineStyle = LineStyle.thin;
    } catch (e) {
      print(e.toString());
    }
    if (i == listTts.length - 1) {
      indexColumLast = 5 + i + 1;
    }
  }

  sheet.getRangeByIndex(indexColumLast, 1, indexColumLast, 4).merge();
  sheet.getRangeByIndex(indexColumLast, 1, indexColumLast, 4).setText("合計");

  sheet.getRangeByIndex(indexColumLast, 1, indexColumLast, 4).cellStyle.fontSize = 14;
  sheet.getRangeByIndex(indexColumLast, 1, indexColumLast, 4).cellStyle.bold = true;

  sheet.getRangeByIndex(indexColumLast, 1, indexColumLast, 10).cellStyle.borders.all.lineStyle = LineStyle.thin;

  sheet.getRangeByIndex(indexColumLast, 4).cellStyle.hAlign = HAlignType.center;

  Range range5 = sheet.getRangeByName("J$indexColumLast");
  range5.setFormula("=SUM($tenHangDauTien:$tenHangCuoiCung)");
  range5.numberFormat = '#,##0';

  for (var element in listMergeColumnD) {
    sheet.getRangeByName(element).merge();
  }
}

renderBodyExcell(NghiepDoanThucTapSinhXuatCanh unionObj, Map<int, List<User>> mapNhomNghiepDoan, Worksheet sheet) {
  mapNhomNghiepDoan.forEach((orgId, listTts) {
    if (unionObj.id == orgId) {
      renderDanhSach(listTts, sheet);
    }
  });
}

Future<List<dynamic>> exportFile1(List<NghiepDoanThucTapSinhXuatCanh> listUnionObjectResultSelected, context, Map<int, List<User>> mapNhomNghiepDoan) async {
  var fileName;

  List<dynamic> listObjectOrgIdAndFileName = [];

  for (int i = 0; i < listUnionObjectResultSelected.length; i++) {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    final String image = base64.encode(await _readImageData('logoAAM.png'));
    sheet.pictures.addBase64(1, 1, image);
    final Style style = workbook.styles.add('Style1');
    style.wrapText = true;

    sheet.getRangeByName('A1:AO43').cellStyle.fontSize = 10;
    sheet.getRangeByName('A1:AO43').cellStyle.fontName = "Times New Roman";

    sheet.getRangeByName('A1:AO43').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('A1:AO43').cellStyle.vAlign = VAlignType.center;

    sheet.getRangeByName('A1:J2').merge();

    sheet.getRangeByName('A1').setText("AAM 技能実習生の渡航費、管理費の詳細表");
    sheet.getRangeByName('A1').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('A1').cellStyle.fontSize = 14;
    sheet.getRangeByName('A1').cellStyle.bold = true;
    sheet.getRangeByName('A1').cellStyle.bold = true;

    sheet.getRangeByName('A1').rowHeight = 65.40;
    sheet.getRangeByName('A1:J1').cellStyle.borders.all.lineStyle = LineStyle.thin;

    sheet.getRangeByName('A3:J3').merge();
    sheet.getRangeByName('A3').setText(listUnionObjectResultSelected[i].orgName.toString());
    sheet.getRangeByName('A3').cellStyle.backColor = '#92D050';
    sheet.getRangeByName('A3').cellStyle.fontSize = 14;
    sheet.getRangeByName('A3').cellStyle.bold = true;
    sheet.getRangeByName('A3').cellStyle.bold = true;
    sheet.getRangeByName('A3:J3').cellStyle.borders.all.lineStyle = LineStyle.thin;

    sheet.getRangeByName('A4').setText("番号");
    sheet.getRangeByName('A4').columnWidth = 10;
    sheet.getRangeByName('A4').rowHeight = 103;

    sheet.getRangeByName('B4').setText("氏名 \nHỌ VÀ TÊN");
    sheet.getRangeByName('B4').cellStyle = style;
    sheet.getRangeByName('B4').columnWidth = 20;

    sheet.getRangeByName('C4').setText("受入れ企業 \n XN TIẾP NHẬN");
    sheet.getRangeByName('C4').cellStyle = style;
    sheet.getRangeByName('C4').columnWidth = 20;

    sheet.getRangeByName('D4').setText("入国日\nNGÀY NHẬP CẢNH");
    sheet.getRangeByName('D4').cellStyle = style;
    sheet.getRangeByName('D4').columnWidth = 20;

    sheet.getRangeByName('E4').setText("渡航費\nVé máy bay");
    sheet.getRangeByName('E4').cellStyle = style;
    sheet.getRangeByName('E4').columnWidth = 6;

    sheet.getRangeByName('F4').setText("講習費\nPhí Đào Tạo");
    sheet.getRangeByName('F4').cellStyle = style;
    sheet.getRangeByName('F4').columnWidth = 6;

    sheet.getRangeByName('G4').setText("管理費\n1\n Tháng\nPHÍ QL");
    sheet.getRangeByName('G4').cellStyle = style;
    sheet.getRangeByName('G4').columnWidth = 10;

    sheet.getRangeByName('H4').setText("期間\nthời hạn");
    sheet.getRangeByName('H4').cellStyle = style;
    sheet.getRangeByName('H4').columnWidth = 40;

    sheet.getRangeByName('I4').setText("期間\nThời\ngian\n（tháng)");
    sheet.getRangeByName('I4').cellStyle = style;
    sheet.getRangeByName('H4').columnWidth = 8;

    sheet.getRangeByName('J4').setText("合計\nTỔNG");
    sheet.getRangeByName('J4').cellStyle = style;
    sheet.getRangeByName('H4').columnWidth = 8;

    sheet.getRangeByName('A4:J4').cellStyle.backColor = '#538DD5';
    sheet.getRangeByName('A4:J4').cellStyle.borders.all.lineStyle = LineStyle.thin;
    sheet.getRangeByName('A4:J4').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('A4:J4').cellStyle.vAlign = VAlignType.center;
    await renderBodyExcell(listUnionObjectResultSelected[i], mapNhomNghiepDoan, sheet);
    sheet.getRangeByName('H4').columnWidth = 30;
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    if (kIsWeb) {
      print("web");
      AnchorElement(href: 'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
        ..setAttribute('download', 'Output.xlsx')
        ..click();
      fileName = await uploadFileByter(bytes, context: context);
      var object = {
        "orgId": listUnionObjectResultSelected[i].id,
        "payRequestFile": fileName,
        "email": listUnionObjectResultSelected[i].email,
        "orgCode": listUnionObjectResultSelected[i].orgCode,
        "orgName": listUnionObjectResultSelected[i].orgName,
        "manageFeeId": listUnionObjectResultSelected[i].manageFeeId,
        "chargeCycleDate": listUnionObjectResultSelected[i].chargeCycleDate,
        "chargeStartDate": listUnionObjectResultSelected[i].chargeStartDate,
        "firstDueDate": listUnionObjectResultSelected[i].firstDueDate,
        "nextDueDate": listUnionObjectResultSelected[i].nextDueDate
      };
      listObjectOrgIdAndFileName.add(object);
    } else {
      print("not web");
      final String path = (await getApplicationSupportDirectory()).path;
      final String fileName = Platform.isWindows ? '$path\\Output.xlsx' : '$path/Output.xlsx';
      final File file = File(fileName);

      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open(fileName);
      File(fileName).writeAsBytes(bytes);
    }
  }
  return listObjectOrgIdAndFileName;
}

readImageFromApi(fileName) async {
  final response = await http.get(Uri.parse('$baseUrl/api/files/$fileName'));
  ByteData byte = ByteData.view(response.bodyBytes.buffer);
  return byte.buffer.asUint8List(response.bodyBytes.offsetInBytes, response.bodyBytes.lengthInBytes);
  // return response.body;
}
