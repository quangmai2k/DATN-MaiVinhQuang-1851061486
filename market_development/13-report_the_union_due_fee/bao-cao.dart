import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:gentelella_flutter/widgets/forms/market_development/utils/funciton.dart';

import 'package:gentelella_flutter/widgets/ui/navigation.dart';
import 'package:gentelella_flutter/widgets/utils/market_development.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../api.dart';

import '../../../../common/format_date.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';
import '../../../../common/widgets_form.dart';

import '../../../../model/market_development/manage_fee_detail.dart';

import '../../../../model/model.dart';
import '../../../forms/market_development/utils/form.dart';

import "package:collection/collection.dart";
import 'package:jiffy/jiffy.dart';

import 'datepicker_custom.dart';
// import '../../../api.dart';
// import '../../../common/widgets_form.dart';
// import '../../../model/model.dart';
// import '../../../common/style.dart';
// import '../../../model/type.dart';

class ChiTietThuPhi extends StatelessWidget {
  final int? id;

  ChiTietThuPhi({
    Key? key,
    this.id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
        widgetBody: ChiTietThuPhiBody(
      id: id,
    ));
  }
}

class ChiTietThuPhiBody extends StatefulWidget {
  final int? id;

  ChiTietThuPhiBody({Key? key, this.id}) : super(key: key);

  @override
  State<ChiTietThuPhiBody> createState() => _ChiTietThuPhiBodyState();
}

class _ChiTietThuPhiBodyState extends State<ChiTietThuPhiBody> {
  String? dueDate;
  String? requestDate;
  String? requestFile;
  String? paymentDate;
  String? requestFileEdited;
  String? requestNoteEdited;

  TextEditingController times = TextEditingController();
  TextEditingController chargeCycleDate = TextEditingController();
  TextEditingController documentNo = TextEditingController();
  TextEditingController title = TextEditingController();
  //TextEditingController totalAmount = TextEditingController();
  TextEditingController requestNote = TextEditingController();

  List<dynamic> listTtsMoiXuatCanh = [];
  List<dynamic> listTtsDaXuatCanh = [];
  List<dynamic> listNghiepDoanDeNghiC = [];

  List<dynamic> chiTietLichXuatCanhs = [];
  List<dynamic> phiQuanLyChiTiets = [];
  List<dynamic> nghiepDoanChiTiets = [];

  var body = {};
  var page = 1;
  var rowPerPage = 10;
  var totalElements = 0;
  var firstRow = 1, lastRow = 0;
  var rowCount = 0;
  var currentPage = 1;
  List<bool> _selected = [];
  // String titleLog = '';

  Map<dynamic, List<dynamic>> mapChiTietLichXuatCanh = new Map();
  Map<dynamic, List<dynamic>> mapCTThucTapSinhMoiXuatCanh = new Map();
  List<dynamic> listPhiQuanLyChiTiet = [];

  late Future<List<dynamic>> futureListChiTietLichXuatCanh;
  Future<List<dynamic>> getListChiTietThucTapSinhXuatCanh(page, context, {tenPhapNhan}) async {
    var response;

    var content = [];
    List<dynamic> listTtsId = [];
    List<dynamic> listTtsIdDaXuatCanh = [];

    response = await httpGet("/api/lichxuatcanh-chitiet/get/page?filter=thuctapsinh.donhang.orgId:${widget.id} AND status:1", context);
    var body = jsonDecode(response['body']);
    if (response.containsKey("body")) {
      var manageFeeId = body['content'][0]['thuctapsinh']['donhang']['nghiepdoan']['manageFeeId'];
      listPhiQuanLyChiTiet = await getPhiQuanLyChiTiet(manageFeeId: manageFeeId);
      content = body['content'];
      for (var item in content) {
        listTtsId.add(item['userId']);
      }

      Set<dynamic> listTtsIdInNDDN = new Set();
      List<dynamic> listTtsInNghiepDoanChiTiet = await getListNghiepDoanChiTiet(listIdTts: listTtsId);
      for (var item in listTtsInNghiepDoanChiTiet) {
        listTtsIdInNDDN.add(item['ttsId']);
      }

      for (var item in content) {
        //Không chứa id thì là mới xuất cảnh
        if (!listTtsIdInNDDN.contains(item['userId'])) {
          listTtsMoiXuatCanh.add(item);
        } else {
          listTtsDaXuatCanh.add(item);
        }
      }
      for (var item in listTtsDaXuatCanh) {
        listTtsIdDaXuatCanh.add(item['userId']);
      }
      List<dynamic> listNghiepDoanDeNghi = [];
      if (listTtsIdDaXuatCanh.isNotEmpty) {
        listNghiepDoanDeNghi = await getListNghiepDoanChiTiet(listIdTts: listTtsIdDaXuatCanh);
      }

      Map<dynamic, dynamic> mapNghiepDoanDeNghi = new Map();
      for (var item in listNghiepDoanDeNghi) {
        if (!mapNghiepDoanDeNghi.containsKey(item['ttsId'])) {
          mapNghiepDoanDeNghi.putIfAbsent(item['ttsId'], () => item);
        } else {
          DateTime dateInMap = DateTime.parse(mapNghiepDoanDeNghi[item['ttsId']]['dateTo']);
          DateTime dateTo = DateTime.parse(item['dateTo']);
          if (dateInMap.isBefore(dateTo)) {
            mapNghiepDoanDeNghi[item['ttsId']] = item;
          }
        }
      }

      List<dynamic> listTtsInNghiepDoanDeNghiDateToMax = [];
      for (var item in mapNghiepDoanDeNghi.entries) {
        var value = item.value;
        listTtsInNghiepDoanDeNghiDateToMax.add(value);
      }

      setState(() {
        listNghiepDoanDeNghi = listNghiepDoanDeNghi;
        listTtsMoiXuatCanh.sort(((a, b) => DateTime.parse(a['thuctapsinh']['feeManageDate']!).compareTo(DateTime.parse(b['thuctapsinh']['feeManageDate']))));
        for (var item in listTtsMoiXuatCanh) {
          double feeValue = layRaPhiQuanLyChiTietApDungSoVoiNgayHienTai(
              item['thuctapsinh']['feeManageDate'], listPhiQuanLyChiTiet.toList(), dueDate != null ? DateTime.parse(getDateInsertDB(dueDate)!) : DateTime.now());
          item['feeValue'] = feeValue;
          item['incurred'] = 0;
          item['arfareFeeText'] = TextEditingController(text: "${item['arfareFee']}");
          item['feeValueText'] = TextEditingController(text: "$feeValue");
          item['incurredText'] = TextEditingController(text: "0");
          item['dateToMax'] = null;
        }

        //List tts đã thu phí
        for (var item in listTtsInNghiepDoanDeNghiDateToMax) {
          double feeValue = layRaPhiQuanLyChiTietApDungSoVoiNgayHienTai(
              item['thuctapsinh']['feeManageDate'], listPhiQuanLyChiTiet.toList(), dueDate != null ? DateTime.parse(getDateInsertDB(dueDate)!) : DateTime.now());
          item['feeValue'] = feeValue;
          item['arfareFee'] = 0;
          item['incurred'] = 0;
          item['arfareFeeText'] = TextEditingController(text: "0");
          item['feeValueText'] = TextEditingController(text: "$feeValue");
          item['incurredText'] = TextEditingController(text: "0");
          item['dateToMax'] = null;
          chiTietLichXuatCanhs.add(item);
        }
        mapChiTietLichXuatCanh = groupBy(chiTietLichXuatCanhs, (dynamic obj) => obj['dateTo']);
        mapCTThucTapSinhMoiXuatCanh = groupBy(listTtsMoiXuatCanh, (dynamic obj) => obj['thuctapsinh']['feeManageDate']);
        print(mapChiTietLichXuatCanh);
      });
    }

    return content;
  }

  tinhTongTien(listTtsMoiXuatCanh, mapChiTietLichXuatCanh) {
    //.entries
    double tongTien = 0;

    for (var item in listTtsMoiXuatCanh) {
      int chuKy = tinhChuKy(tuNgayMoiXuatCanh: item['thuctapsinh']['feeManageDate']);
      tongTien += (double.parse(item['feeValue'].toString()) * chuKy) + double.parse(item['arfareFee'].toString()) + double.parse(item['incurred'].toString());
    }

    for (var item in mapChiTietLichXuatCanh.entries) {
      var listValue = item.value;
      for (var value in listValue) {
        int chuKy = tinhChuKy(denNgayThuPhi: value['dateTo']);
        tongTien += (double.parse(value['feeValue'].toString()) * chuKy) + double.parse(value['arfareFee'].toString()) + double.parse(value['incurred'].toString());
      }
    }
    return tongTien;
  }

  tinhTongTienTheoNhom(value, chuKy) {
    //.entries
    double tongTien = 0;
    for (var item in value) {
      double feeValue = double.parse(item['feeValue'].toString());
      double arfareFee = double.parse(item['arfareFee'].toString());
      double incurred = tinhTongTienIncurredTheoTts(item['incurred']);
      tongTien += (feeValue * chuKy) + arfareFee + incurred;
    }
    return tongTien;
  }

  tinhFeeTotalTheoNhom(value, chuKy) {
    double tongTien = 0;
    for (var item in value) {
      double feeValue = double.parse(item['feeValue'].toString());
      double arfareFee = 0;
      double incurred = 0;
      tongTien += (feeValue * chuKy) + arfareFee + incurred;
    }
    return tongTien;
  }

  tinhTongTienArfareFeeTheoNhom(value) {
    double tongTien = 0;
    for (var item in value) {
      double arfareFee = double.parse(item['arfareFee'].toString());
      tongTien += arfareFee;
    }
    return tongTien;
  }

  tinhTongTienIncurredTotalTheoNhom(value) {
    double tongTien = 0;
    for (var item in value) {
      double incurred = double.parse(item['incurred'].toString());
      tongTien += incurred;
    }
    return tongTien;
  }

  tinhTongTienTheoTts(feeValue, incurred1, chuKy) {
    double tongTien = 0;

    double incurred = tinhTongTienIncurredTheoTts(incurred1);
    tongTien += (double.parse(feeValue.toString()) * chuKy) + incurred;
    return tongTien;
  }

  tinhTongTienFeeTotalTheoTts(feeValue, chuKy) {
    double tongTien = 0;
    tongTien += (double.parse(feeValue.toString()) * chuKy);
    return tongTien;
  }

  tinhTongTienArfareFeeTheoTts(arfareFee) {
    double tongTien = 0;
    tongTien += double.parse(arfareFee.toString());
    return tongTien;
  }

  tinhTongTienIncurredTheoTts(incurred) {
    double tongTien = 0;
    try {
      tongTien += double.parse(incurred.toString());
    } catch (e) {
      tongTien = 0;
    }

    return tongTien;
  }

  tinhSoLan(listNghiepDoanDeNghi, orgId) {
    int count = 1;
    for (var item in listNghiepDoanDeNghi) {
      if (item['orgId'] == orgId) {
        count++;
      }
    }
    return count;
  }

  Future<List<dynamic>> getListNghiepDoanChiTiet({listIdTts}) async {
    var response;
    var content = [];
    String condition = " ";
    if (listIdTts != null) {
      condition += " ttsId in (";
      for (int i = 0; i < listIdTts.length; i++) {
        if (i == 0) {
          condition += listIdTts[i].toString();
        } else {
          condition += "," + listIdTts[i].toString();
        }
      }
      condition += ")";
    }

    response = await httpGet("/api/nghiepdoan-denghi-chitiet/get/page?filter=$condition", context);

    var body = jsonDecode(response['body']);

    if (response.containsKey("body")) {
      setState(() {
        content = body['content'];
      });
    }
    return content;
  }

  Future<List<dynamic>> getPhiQuanLyChiTiet({manageFeeId}) async {
    var response;
    if (manageFeeId != null) {
      response = await httpGet("/api/phiquanly-chitiet/get/page?sort=id,asc&filter=manageFeeId:$manageFeeId ", context);
    } else {
      response = await httpGet("/api/phiquanly-chitiet/get/page?sort=id,asc", context);
    }

    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        content = body['content'];
      });
    }
    return content;
  }

  layRaPhiQuanLyChiTietApDungSoVoiNgayHienTai(feeManageDate, List<dynamic> listChiTietPhi, DateTime ngayXacNhanThongBao) {
    DateTime ngayBatDauCuaKhoang = DateTime.now();
    DateTime tuNgay = DateTime.now();
    DateTime denNgay = DateTime.now();
    DateTime ngayNhoNhat = DateTime.now();
    DateTime ngayLonNhat = DateTime.now();
    ManageFeeDetail? phiCuaNgayNhoNhat;
    ManageFeeDetail? phiCuaNgayLonNhat;
    List<ManageFeeDetail> listManagerDetail = [];

    int count = 0;

    for (var phiQuanLyChiTiet in listChiTietPhi) {
      print("---------" + phiQuanLyChiTiet['feeValue'].toString());
      if (count == 0) {
        //ngayNhoNhat
        ngayNhoNhat = DateTime.parse(feeManageDate).toLocal();
        //Phi cua khoang nho nhat

        phiCuaNgayNhoNhat = new ManageFeeDetail(
            id: phiQuanLyChiTiet['id'],
            manageFeeId: phiQuanLyChiTiet['manageFeeId'],
            feeValue: phiQuanLyChiTiet['feeValue'],
            effectTime: phiQuanLyChiTiet['effectTime'],
            timeType: phiQuanLyChiTiet['timeType']);

        //Ngày đầu tiên của chu kì
        ngayBatDauCuaKhoang = DateTime.parse(feeManageDate).toLocal();
        //
        tuNgay = ngayBatDauCuaKhoang;
        //
        denNgay = tuNgay.add(Duration(days: quyVeSoNgayTheoKieuThoiGian(phiQuanLyChiTiet['timeType'], phiQuanLyChiTiet['feeValue'], phiQuanLyChiTiet['effectTime'])));
        //
        ngayBatDauCuaKhoang = denNgay;
      } else {
        //Cộng thêm
        tuNgay = ngayBatDauCuaKhoang;
        //
        denNgay = tuNgay.add(Duration(days: quyVeSoNgayTheoKieuThoiGian(phiQuanLyChiTiet['timeType'], phiQuanLyChiTiet['feeValue'], phiQuanLyChiTiet['effectTime'])));
        //
        ngayBatDauCuaKhoang = denNgay;
        if (count == listChiTietPhi.length - 1) {
          //Ngay lon nhat
          ngayLonNhat = denNgay;
          //Phi cua khoang lon nhat
          phiCuaNgayLonNhat = new ManageFeeDetail(
              id: phiQuanLyChiTiet['id'],
              manageFeeId: phiQuanLyChiTiet['manageFeeId'],
              feeValue: phiQuanLyChiTiet['feeValue'],
              effectTime: phiQuanLyChiTiet['effectTime'],
              timeType: phiQuanLyChiTiet['timeType']);
        }
      }
      if (kiemTraNgayHienTaiCoNamTrongKhoang(ngayXacNhanThongBao, tuNgay, denNgay)) {
        listManagerDetail.add(ManageFeeDetail.fromJson(phiQuanLyChiTiet));
        return listManagerDetail.first.feeValue;
      }
      count++;
    }

    if (listManagerDetail.isEmpty) {
      //Nếu là ngày xác nhận thông báo thì sex lấy phí quản lý của ngày nhỏ nhất
      if (ngayXacNhanThongBao.isBefore(ngayNhoNhat) || ngayXacNhanThongBao.isAtSameMomentAs(ngayNhoNhat)) {
        listManagerDetail.add(phiCuaNgayNhoNhat!);
      }
      if (phiCuaNgayLonNhat != null) {
        if (ngayXacNhanThongBao.isAfter(ngayLonNhat) || ngayXacNhanThongBao.isAtSameMomentAs(ngayLonNhat)) {
          listManagerDetail.add(phiCuaNgayLonNhat);
        }
      }
    } else {
      listManagerDetail.addAll(listManagerDetail);
    }
    return listManagerDetail.first.feeValue;
  }

  bool kiemTraNgayHienTaiCoNamTrongKhoang(DateTime ngayXacNhanThongBao, DateTime tuNgay, DateTime denNgay) {
    if (ngayXacNhanThongBao.isAfter(tuNgay) && ngayXacNhanThongBao.isBefore(denNgay) && tuNgay.isBefore(denNgay)) {
      return true;
    }
    return false;
  }

  var nghiepDoan;
  getTTND(idNghiepDoan) async {
    var response;
    response = await httpGet("/api/nghiepdoan/get/$idNghiepDoan ", context);

    var body = jsonDecode(response['body']);

    if (response.containsKey("body")) {
      setState(() {
        nghiepDoan = body;
        chargeCycleDate.text = nghiepDoan['chargeCycleDate'] != null ? nghiepDoan['chargeCycleDate'].toString() : "3";
        // print("aaaa" + nghiepDoan['chargeCycleDate'].toString());
      });
    }
  }

  getNghiepdoanDenghi(idNghiepDoan) async {
    var response;
    var content = [];
    response = await httpGet("/api/nghiepdoan-denghi/get/page?filter=orgId:$idNghiepDoan AND paymentStatus:1", context);

    var body = jsonDecode(response['body']);

    if (response.containsKey("body")) {
      content = body['content'];
      setState(() {
        listNghiepDoanDeNghiC = content;
      });
    }
  }

  int quyVeSoNgayTheoKieuThoiGian(int timeType, double feeValue, int effectTime) {
    //Kiểu thời gian = 0:Năm | 1:Tháng
    int soNgay = 0;
    switch (timeType) {
      case 1:
        soNgay = effectTime * 30;
        break;
      case 0:
        soNgay = effectTime * 365;
        break;
      default:
    }
    return soNgay;
  }

  congChuKy(chuKy, tuNgay) {
    DateTime denNgay = Jiffy(tuNgay).add(months: chuKy ?? 0).dateTime.toLocal();
    return denNgay;
  }

  luuNghiepDoanDeNghiHoanThanh(
      {title,
      orgId,
      documentNo,
      chargeCycleDate,
      dueDate,
      requestDate,
      requestSender,
      requestFile,
      requestStatus,
      paymentDate,
      paymentStatus,
      manageFileId,
      totalAmount,
      requestNote,
      requestFileEdited,
      requestNoteEdited,
      times}) async {
    var requestBody = {
      "title": title,
      "orgId": orgId,
      "documentNo": documentNo,
      "chargeCycleDate": chargeCycleDate,
      "dueDate": dueDate,
      "requestDate": requestDate,
      "requestSender": requestSender,
      "requestFile": requestFile,
      "requestStatus": requestStatus,
      "paymentDate": paymentDate,
      "paymentStatus": paymentStatus,
      "manageFileId": manageFileId,
      "totalAmount": totalAmount,
      "requestNote": requestNote,
      "requestFileEdited": requestFileEdited,
      "requestNoteEdited": requestNoteEdited,
      "times": times,
    };
    int i = 0;
    try {
      var response = await httpPost("/api/nghiepdoan-denghi/post/save", requestBody, context);
      i = jsonDecode(response['body']);
    } catch (e) {
      print("Fail!");
    }
    return i;
  }

  luuDeNghiNhomChiTiet({requestId, dateFrom, dateTo, feeTotal, arfareFeeTotal, incurredTotal, totalAmount, invoiced}) async {
    var requestBody = {
      "requestId": requestId,
      "dateFrom": dateFrom,
      "dateTo": dateTo,
      "feeTotal": feeTotal,
      "arfareFeeTotal": arfareFeeTotal,
      "incurredTotal": incurredTotal,
      "totalAmount": totalAmount,
      "invoiced": invoiced
    };
    int i = 0;
    try {
      var response = await httpPost("/api/nghiepdoan-denghi-nhom-chitiet/post/save", requestBody, context);
      i = jsonDecode(response['body']);
    } catch (e) {
      print("Fail!");
    }
    return i;
  }

  luuDeNghiChiTiet({ttsId, requestId, groupId, dateFrom, dateTo, feeTotal, arfareFee, incurredFee, totalAmount}) async {
    var requestBody = {
      "ttsId": ttsId,
      "requestId": requestId,
      "groupId": groupId,
      "dateFrom": dateFrom,
      "dateTo": dateTo,
      "feeTotal": feeTotal,
      "arfareFee": arfareFee,
      "incurredFee": incurredFee,
      "totalAmount": totalAmount,
    };
    int i = 0;
    try {
      var response = await httpPost("/api/nghiepdoan-denghi-chitiet/post/save", requestBody, context);
      i = jsonDecode(response['body']);
    } catch (e) {
      print("Fail!");
    }
    return i;
  }

  tinhChuKy({tuNgayMoiXuatCanh, denNgayThuPhi}) {
    if (tuNgayMoiXuatCanh != null) {
      int chuKy = 0;
      DateTime tuNgayMoiXuatCanhDate = DateTime.parse(tuNgayMoiXuatCanh);

      DateTime dateTimeNow = DateTime.parse(getDateInsertDB(dueDate ?? DateTime.now().toLocal().toString())!);
      print("ddd" + dateTimeNow.toString());
      DateTime.now().toLocal();
      DateTime ngayTru = Jiffy(dateTimeNow).subtract(months: 1).dateTime.toLocal();

      while (ngayTru.isAfter(tuNgayMoiXuatCanhDate)) {
        chuKy++;
        if (chuKy > int.parse(chargeCycleDate.text)) {
          break;
        }
        ngayTru = Jiffy(ngayTru).subtract(months: 1).dateTime.toLocal();
      }
      if (chuKy > int.parse(chargeCycleDate.text)) {
        return int.parse(chargeCycleDate.text);
      }
      print("Chu kỳ" + chuKy.toString());
      return chuKy;
    }
    if (denNgayThuPhi != null) {
      int chuKy = 0;
      DateTime tuNgayMoiXuatCanhDate = DateTime.parse(denNgayThuPhi);
      DateTime dateTimeNow = DateTime.parse(getDateInsertDB(dueDate ?? DateTime.now().toLocal().toString())!);
      DateTime.now().toLocal();
      DateTime ngayCong = Jiffy(tuNgayMoiXuatCanhDate).add(months: 1).dateTime.toLocal();

      while (ngayCong.isBefore(dateTimeNow)) {
        chuKy++;
        if (chuKy > int.parse(chargeCycleDate.text)) {
          break;
        }
        ngayCong = Jiffy(ngayCong).add(months: 1).dateTime.toLocal();
      }
      if (chuKy > int.parse(chargeCycleDate.text)) {
        return int.parse(chargeCycleDate.text);
      }
      return chuKy;
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    futureListChiTietLichXuatCanh = getListChiTietThucTapSinhXuatCanh(page, context);
    getTTND(widget.id);
    getNghiepdoanDenghi(widget.id);
    setState(() {
      requestDate = FormatDate.formatDateddMMyy(DateTime.now());
    });
    // setState(() {
    //   dueDate = getDateView(DateTime.now().toLocal().toString());
    // });
  }

  valiedate() {
    int countErrorForm = 0;
    if (dueDate == null) {
      countErrorForm++;
    }
    if (requestDate == null) {
      countErrorForm++;
    }

    if (chargeCycleDate.text.isEmpty) {
      countErrorForm++;
    }
    if (documentNo.text.isEmpty) {
      countErrorForm++;
    }
    if (title.text.isEmpty) {
      countErrorForm++;
    }
    return countErrorForm;
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return FutureBuilder<dynamic>(
        future: userRule('/quan-ly-phap-nhan', context),
        builder: (context, listRule) {
          if (listRule.hasData) {
            return Consumer2<NavigationModel, SecurityModel>(
                builder: (context, navigationModel, securityModel, child) => FutureBuilder<List<dynamic>>(
                    future: futureListChiTietLichXuatCanh,
                    builder: (context, snapshot) {
                      return ListView(
                        children: [
                          TitlePage(
                            listPreTitle: [
                              {'url': '/phat-trien-thi-truong', 'title': 'Dashboard'},
                              {'url': '/quan-ly-phap-nhan', 'title': 'Báo cáo thu phí'}
                            ],
                            content: 'Báo cáo thu phí',
                          ),
                          Container(
                            color: backgroundPage,
                            padding: EdgeInsets.symmetric(vertical: verticalPaddingPage, horizontal: horizontalPaddingPage),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: paddingBoxContainer,
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
                                      Container(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    widget.id != null ? 'Cập nhật' : 'Thêm mới',
                                                    style: titleBox,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  getRule(listRule.data, widget.id == null ? Role.Them : Role.Sua, context)
                                                      ? Container(
                                                          margin: EdgeInsets.only(left: 20),
                                                          child: TextButton(
                                                              style: TextButton.styleFrom(
                                                                padding: const EdgeInsets.symmetric(
                                                                  vertical: 15.0,
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
                                                                if (valiedate() > 0) {
                                                                  showToast(
                                                                    context: context,
                                                                    msg: "Vui lòng nhập đầy đủ các trường !",
                                                                    color: Color.fromARGB(133, 247, 63, 134),
                                                                    icon: const Icon(Icons.warning),
                                                                  );
                                                                  return;
                                                                }
                                                                int requestId = await luuNghiepDoanDeNghiHoanThanh(
                                                                  title: title.text,
                                                                  orgId: widget.id,
                                                                  documentNo: documentNo.text,
                                                                  chargeCycleDate: chargeCycleDate.text,
                                                                  dueDate: getDateInsertDB(dueDate),
                                                                  requestDate: getDateInsertDB(requestDate),
                                                                  requestSender: securityModel.userLoginCurren['id'],
                                                                  requestFile: requestFile,
                                                                  requestStatus: 0, //Trạng thái đề nghị 0:Nháp|1:Hoàn thành|2:Hủy
                                                                  paymentDate: paymentDate,
                                                                  paymentStatus: 0, //0:Chưa|1:Thanh toán đủ|2:Thanh toán 1 phần
                                                                  manageFileId: nghiepDoan['manageFeeId'],
                                                                  totalAmount: tinhTongTien(listTtsMoiXuatCanh, mapChiTietLichXuatCanh),
                                                                  requestNote: requestNote.text,
                                                                  requestFileEdited: null,
                                                                  requestNoteEdited: null,
                                                                  times: tinhSoLan(listNghiepDoanDeNghiC, widget.id),
                                                                );

                                                                //Lưu mới xuất cảnh
                                                                for (var item in mapCTThucTapSinhMoiXuatCanh.entries) {
                                                                  var listTtsByDate = item.value;
                                                                  var feeTotal = tinhFeeTotalTheoNhom(
                                                                      listTtsByDate, tinhChuKy(tuNgayMoiXuatCanh: listTtsByDate.first['thuctapsinh']['feeManageDate']));
                                                                  var arfareFeeTotal = tinhTongTienArfareFeeTheoNhom(listTtsByDate);
                                                                  var incurredTotal = tinhTongTienIncurredTotalTheoNhom(listTtsByDate);
                                                                  var totalAmount = feeTotal + arfareFeeTotal + incurredTotal;
                                                                  //var dateFrom = getDateInsertDB(listTtsByDate.first['dateTo']);
                                                                  var dateToGroup = congChuKy(tinhChuKy(denNgayThuPhi: listTtsByDate.first['thuctapsinh']['feeManageDate']),
                                                                          listTtsByDate.first['thuctapsinh']['feeManageDate'])
                                                                      .toString();

                                                                  var groupId = await luuDeNghiNhomChiTiet(
                                                                      requestId: requestId,
                                                                      dateFrom: listTtsByDate.first['thuctapsinh']['feeManageDate'],
                                                                      dateTo: getDateInsertDB(getDateView(dateToGroup)),
                                                                      feeTotal: feeTotal,
                                                                      arfareFeeTotal: arfareFeeTotal,
                                                                      incurredTotal: incurredTotal,
                                                                      totalAmount: totalAmount,
                                                                      invoiced: 0);
                                                                  for (var item in listTtsByDate) {
                                                                    var feeTotal = tinhTongTienFeeTotalTheoTts(
                                                                        item['feeValue'], tinhChuKy(tuNgayMoiXuatCanh: item['thuctapsinh']['feeManageDate']));
                                                                    var arfareFeeTotal = tinhTongTienArfareFeeTheoTts(item['arfareFee']);
                                                                    var incurredTotal = tinhTongTienIncurredTheoTts(item['incurred']);
                                                                    var totalAmount = feeTotal + arfareFeeTotal + incurredTotal;
                                                                    var dateToTTS = congChuKy(tinhChuKy(denNgayThuPhi: listTtsByDate.first['thuctapsinh']['feeManageDate']),
                                                                            listTtsByDate.first['thuctapsinh']['feeManageDate'])
                                                                        .toString();
                                                                    await luuDeNghiChiTiet(
                                                                      ttsId: item['userId'],
                                                                      requestId: requestId,
                                                                      groupId: groupId,
                                                                      dateFrom: item['thuctapsinh']['feeManageDate'],
                                                                      dateTo: getDateInsertDB(getDateView(dateToTTS)),
                                                                      feeTotal: feeTotal,
                                                                      arfareFee: arfareFeeTotal,
                                                                      incurredFee: incurredTotal,
                                                                      totalAmount: totalAmount,
                                                                    );
                                                                  }
                                                                }
//Lưu đã xuất cảnh
                                                                for (var item in mapChiTietLichXuatCanh.entries) {
                                                                  var listTtsByDate = item.value;
                                                                  var feeTotal = tinhFeeTotalTheoNhom(listTtsByDate, tinhChuKy(denNgayThuPhi: listTtsByDate.first['dateTo']));
                                                                  var arfareFeeTotal = tinhTongTienArfareFeeTheoNhom(listTtsByDate);
                                                                  var incurredTotal = tinhTongTienIncurredTotalTheoNhom(listTtsByDate);
                                                                  var totalAmount = feeTotal + arfareFeeTotal + incurredTotal;
                                                                  var dateFrom = listTtsByDate.first['dateTo'];

                                                                  var dateTo = DateFormat('yyyy-MM-dd').format(DateTime.parse(listTtsByDate.first['dateToMax']));
                                                                  //var dateFrom = getDateInsertDB(listTtsByDate.first['dateTo']);
                                                                  var groupId = await luuDeNghiNhomChiTiet(
                                                                      requestId: requestId,
                                                                      dateFrom: dateFrom,
                                                                      dateTo: dateTo,
                                                                      feeTotal: feeTotal,
                                                                      arfareFeeTotal: arfareFeeTotal,
                                                                      incurredTotal: incurredTotal,
                                                                      totalAmount: totalAmount,
                                                                      invoiced: 1);
                                                                  for (var item in listTtsByDate) {
                                                                    var feeTotal =
                                                                        tinhTongTienFeeTotalTheoTts(item['feeValue'], tinhChuKy(denNgayThuPhi: listTtsByDate.first['dateTo']));
                                                                    var arfareFeeTotal = tinhTongTienArfareFeeTheoTts(item['arfareFee']);
                                                                    var incurredTotal = tinhTongTienIncurredTheoTts(item['incurred']);
                                                                    var totalAmount = feeTotal + arfareFeeTotal + incurredTotal;
                                                                    await luuDeNghiChiTiet(
                                                                      ttsId: item['ttsId'],
                                                                      requestId: requestId,
                                                                      groupId: groupId,
                                                                      dateFrom: dateFrom,
                                                                      dateTo: dateTo,
                                                                      feeTotal: feeTotal,
                                                                      arfareFee: arfareFeeTotal,
                                                                      incurredFee: incurredTotal,
                                                                      totalAmount: totalAmount,
                                                                    );
                                                                  }
                                                                }
                                                                Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/bao-cao-cac-nghiep-doan-den-han-thu-phi");
                                                                showToast(
                                                                  context: context,
                                                                  msg: "Lưu bản nháp thành công !",
                                                                  color: Color.fromARGB(136, 72, 238, 67),
                                                                  icon: const Icon(Icons.done),
                                                                );
                                                              },
                                                              child: Row(children: [
                                                                Container(
                                                                    padding: EdgeInsets.only(left: 30, right: 30, top: 8, bottom: 8),
                                                                    child: Text('Lưu bản nháp', style: textButton)),
                                                              ])))
                                                      : Container(),
                                                  Container(
                                                      margin: EdgeInsets.only(left: 20),
                                                      child: TextButton(
                                                          style: TextButton.styleFrom(
                                                            padding: const EdgeInsets.symmetric(
                                                              vertical: 15.0,
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
                                                            if (valiedate() > 0) {
                                                              showToast(
                                                                context: context,
                                                                msg: "Vui lòng nhập đầy đủ các trường !",
                                                                color: Color.fromARGB(133, 247, 63, 134),
                                                                icon: const Icon(Icons.warning),
                                                              );
                                                              return;
                                                            }
                                                            int requestId = await luuNghiepDoanDeNghiHoanThanh(
                                                              title: title.text,
                                                              orgId: widget.id,
                                                              documentNo: documentNo.text,
                                                              chargeCycleDate: chargeCycleDate.text,
                                                              dueDate: getDateInsertDB(dueDate),
                                                              requestDate: getDateInsertDB(requestDate),
                                                              requestSender: securityModel.userLoginCurren['id'],
                                                              requestFile: requestFile,
                                                              requestStatus: 1, //Trạng thái đề nghị 0:Nháp|1:Hoàn thành|2:Hủy
                                                              paymentDate: paymentDate,
                                                              paymentStatus: 0, //0:Chưa|1:Thanh toán đủ|2:Thanh toán 1 phần
                                                              manageFileId: nghiepDoan['manageFeeId'],
                                                              totalAmount: tinhTongTien(listTtsMoiXuatCanh, mapChiTietLichXuatCanh),
                                                              requestNote: requestNote.text,
                                                              requestFileEdited: null,
                                                              requestNoteEdited: null,
                                                              times: tinhSoLan(listNghiepDoanDeNghiC, widget.id),
                                                            );
                                                            for (var item in mapCTThucTapSinhMoiXuatCanh.entries) {
                                                              var listTtsByDate = item.value;
                                                              var feeTotal = tinhFeeTotalTheoNhom(
                                                                  listTtsByDate, tinhChuKy(tuNgayMoiXuatCanh: listTtsByDate.first['thuctapsinh']['feeManageDate']));
                                                              var arfareFeeTotal = tinhTongTienArfareFeeTheoNhom(listTtsByDate);
                                                              var incurredTotal = tinhTongTienIncurredTotalTheoNhom(listTtsByDate);
                                                              var totalAmount = feeTotal + arfareFeeTotal + incurredTotal;
                                                              //var dateFrom = getDateInsertDB(listTtsByDate.first['dateTo']);

                                                              var dateTo = congChuKy(tinhChuKy(denNgayThuPhi: listTtsByDate.first['thuctapsinh']['feeManageDate']),
                                                                  listTtsByDate.first['thuctapsinh']['feeManageDate']);
                                                              var groupId = await luuDeNghiNhomChiTiet(
                                                                  requestId: requestId,
                                                                  dateFrom: listTtsByDate.first['thuctapsinh']['feeManageDate'],
                                                                  dateTo: congChuKy(tinhChuKy(denNgayThuPhi: listTtsByDate.first['thuctapsinh']['feeManageDate']),
                                                                      listTtsByDate.first['thuctapsinh']['feeManageDate']),
                                                                  feeTotal: feeTotal,
                                                                  arfareFeeTotal: arfareFeeTotal,
                                                                  incurredTotal: incurredTotal,
                                                                  totalAmount: totalAmount,
                                                                  invoiced: 0);
                                                              for (var item in listTtsByDate) {
                                                                var feeTotal = tinhTongTienFeeTotalTheoTts(
                                                                    item['feeValue'], tinhChuKy(tuNgayMoiXuatCanh: item['thuctapsinh']['feeManageDate']));
                                                                var arfareFeeTotal = tinhTongTienArfareFeeTheoTts(item['arfareFee']);
                                                                var incurredTotal = tinhTongTienIncurredTheoTts(item['incurred']);
                                                                var totalAmount = feeTotal + arfareFeeTotal + incurredTotal;
                                                                await luuDeNghiChiTiet(
                                                                  ttsId: item['userId'],
                                                                  requestId: requestId,
                                                                  groupId: groupId,
                                                                  dateFrom: item['thuctapsinh']['feeManageDate'],
                                                                  dateTo: getDateInsertDB(dueDate),
                                                                  feeTotal: feeTotal,
                                                                  arfareFee: arfareFeeTotal,
                                                                  incurredFee: incurredTotal,
                                                                  totalAmount: totalAmount,
                                                                );
                                                              }
                                                            }

                                                            for (var item in mapChiTietLichXuatCanh.entries) {
                                                              var listTtsByDate = item.value;
                                                              var feeTotal = tinhFeeTotalTheoNhom(listTtsByDate, tinhChuKy(denNgayThuPhi: listTtsByDate.first['dateTo']));
                                                              var arfareFeeTotal = tinhTongTienArfareFeeTheoNhom(listTtsByDate);
                                                              var incurredTotal = tinhTongTienIncurredTotalTheoNhom(listTtsByDate);
                                                              var totalAmount = feeTotal + arfareFeeTotal + incurredTotal;
                                                              var dateFrom = listTtsByDate.first['dateTo'];

                                                              var dateTo = DateFormat('yyyy-MM-dd').format(DateTime.parse(listTtsByDate.first['dateToMax']));
                                                              //var dateFrom = getDateInsertDB(listTtsByDate.first['dateTo']);
                                                              var groupId = await luuDeNghiNhomChiTiet(
                                                                  requestId: requestId,
                                                                  dateFrom: dateFrom,
                                                                  dateTo: dateTo,
                                                                  feeTotal: feeTotal,
                                                                  arfareFeeTotal: arfareFeeTotal,
                                                                  incurredTotal: incurredTotal,
                                                                  totalAmount: totalAmount,
                                                                  invoiced: 1);
                                                              for (var item in listTtsByDate) {
                                                                var feeTotal =
                                                                    tinhTongTienFeeTotalTheoTts(item['feeValue'], tinhChuKy(denNgayThuPhi: listTtsByDate.first['dateTo']));
                                                                var arfareFeeTotal = tinhTongTienArfareFeeTheoTts(item['arfareFee']);
                                                                var incurredTotal = tinhTongTienIncurredTheoTts(item['incurred']);
                                                                var totalAmount = feeTotal + arfareFeeTotal + incurredTotal;
                                                                await luuDeNghiChiTiet(
                                                                  ttsId: item['ttsId'],
                                                                  requestId: requestId,
                                                                  groupId: groupId,
                                                                  dateFrom: dateFrom,
                                                                  dateTo: dateTo,
                                                                  feeTotal: feeTotal,
                                                                  arfareFee: arfareFeeTotal,
                                                                  incurredFee: incurredTotal,
                                                                  totalAmount: totalAmount,
                                                                );
                                                              }
                                                            }
                                                            Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/bao-cao-cac-nghiep-doan-den-han-thu-phi");
                                                            showToast(
                                                              context: context,
                                                              msg: "Hoàn thành !",
                                                              color: Color.fromARGB(136, 72, 238, 67),
                                                              icon: const Icon(Icons.done),
                                                            );
                                                          },
                                                          child: Row(children: [
                                                            Container(
                                                                padding: EdgeInsets.only(left: 30, right: 30, top: 8, bottom: 8), child: Text('Hoàn thành', style: textButton)),
                                                          ]))),
                                                  Container(
                                                      margin: EdgeInsets.only(left: 20),
                                                      child: TextButton(
                                                          style: TextButton.styleFrom(
                                                            padding: const EdgeInsets.symmetric(
                                                              vertical: 15.0,
                                                              horizontal: 10.0,
                                                            ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(5.0),
                                                            ),
                                                            backgroundColor: Color.fromRGBO(245, 117, 29, 1),
                                                            primary: Theme.of(context).iconTheme.color,
                                                            textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                                          ),
                                                          onPressed: () {
                                                            navigationModel.add(pageUrl: "/bao-cao-cac-nghiep-doan-den-han-thu-phi");
                                                          },
                                                          child: Row(children: [
                                                            Container(padding: EdgeInsets.only(left: 30, right: 30, top: 8, bottom: 8), child: Text('Hủy', style: textButton)),
                                                          ]))),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      //--------------Đường line-------------
                                      Container(
                                        child: Divider(
                                          thickness: 1,
                                          color: ColorHorizontalLine,
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(top: 30),
                                        height: 300,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 5,
                                              child: Container(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    TextFieldValidatedMarket(
                                                      labe: 'Tiêu đề',
                                                      flexLable: 2,
                                                      flexTextField: 5,
                                                      isReverse: false,
                                                      type: 'Text',
                                                      controller: title,
                                                      isShowDau: true,
                                                    ),
                                                    TextFieldValidatedMarket(
                                                      labe: 'Chu kỳ tính phí theo tháng',
                                                      flexLable: 2,
                                                      flexTextField: 5,
                                                      isReverse: false,
                                                      type: 'Text',
                                                      controller: chargeCycleDate,
                                                      isShowDau: true,
                                                      marginBottom: 0,
                                                    ),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Container(
                                                        margin: EdgeInsets.only(top: 30),
                                                        child: DatePickerBoxCustomForMarkert(
                                                            isBlocDate: false,
                                                            isTime: false,
                                                            flexLabel: 2,
                                                            flexDatePiker: 5,
                                                            isNotFeatureDate: true,
                                                            label: Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    'Ngày đến hạn thanh toán',
                                                                    style: titleWidgetBox,
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Container(
                                                                    margin: EdgeInsets.only(left: 5),
                                                                    child: Text(
                                                                      "*",
                                                                      style: TextStyle(color: Colors.red, fontSize: 16),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            dateDisplay: dueDate,
                                                            selectedDateFunction: (day) {
                                                              setState(() {
                                                                dueDate = day;
                                                                if (dueDate != null) {
                                                                  for (var element in mapChiTietLichXuatCanh.entries) {
                                                                    List<dynamic> value = element.value;
                                                                    for (var item in value) {
                                                                      double feeValue = layRaPhiQuanLyChiTietApDungSoVoiNgayHienTai(item['thuctapsinh']['feeManageDate'],
                                                                          listPhiQuanLyChiTiet.toList(), DateTime.parse(getDateInsertDB(dueDate)!));
                                                                      setState(() {
                                                                        item['dateToMax'] =
                                                                            congChuKy(tinhChuKy(denNgayThuPhi: item['dateTo']), DateTime.parse(item['dateTo'])).toString();
                                                                        item['feeValue'] = feeValue;
                                                                        item['feeValueText'] = TextEditingController(text: feeValue.toString());
                                                                      });
                                                                    }
                                                                  }
                                                                  for (var element in mapCTThucTapSinhMoiXuatCanh.entries) {
                                                                    List<dynamic> value = element.value;

                                                                    for (var item in value) {
                                                                      double feeValue = layRaPhiQuanLyChiTietApDungSoVoiNgayHienTai(item['thuctapsinh']['feeManageDate'],
                                                                          listPhiQuanLyChiTiet.toList(), DateTime.parse(getDateInsertDB(dueDate)!));
                                                                      setState(() {
                                                                        item['dateToMax'] = congChuKy(tinhChuKy(denNgayThuPhi: value.first['thuctapsinh']['feeManageDate']),
                                                                                value.first['thuctapsinh']['feeManageDate'])
                                                                            .toString();
                                                                        item['feeValue'] = feeValue;
                                                                        item['feeValueText'] = TextEditingController(text: feeValue.toString());
                                                                      });
                                                                    }
                                                                  }
                                                                }
                                                              });
                                                            }),
                                                      ),
                                                    ),
                                                  ], //coloumn --------------------------
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 30,
                                            ),
                                            Expanded(
                                              flex: 5,
                                              child: Container(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    TextFieldValidatedMarket(
                                                      labe: 'Số văn bản',
                                                      isReverse: false,
                                                      type: 'Text',
                                                      controller: documentNo,
                                                      isShowDau: true,
                                                      flexTextField: 5,
                                                      flexLable: 2,
                                                    ),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Container(
                                                        child: DatePickerBoxCustomForMarkert(
                                                            isBlocDate: false,
                                                            isTime: false,
                                                            flexLabel: 2,
                                                            flexDatePiker: 5,
                                                            isNotFeatureDate: true,
                                                            label: Row(
                                                              children: [
                                                                Text(
                                                                  'Ngày làm đề nghị',
                                                                  style: titleWidgetBox,
                                                                ),
                                                                Container(
                                                                  margin: EdgeInsets.only(left: 5),
                                                                  child: Text(
                                                                    "*",
                                                                    style: TextStyle(color: Colors.red, fontSize: 16),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            dateDisplay: requestDate,
                                                            selectedDateFunction: (day) {
                                                              setState(() {
                                                                requestDate = day;
                                                              });
                                                            }),
                                                      ),
                                                    ),
                                                  ], //coloumn --------------------------
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                for (var map in mapChiTietLichXuatCanh.entries)
                                  Container(
                                      width: MediaQuery.of(context).size.width * 1,
                                      margin: marginTopBoxContainer,
                                      decoration: BoxDecoration(
                                        color: colorWhite,
                                        borderRadius: borderRadiusContainer,
                                        boxShadow: [boxShadowContainer],
                                        border: borderAllContainerBox,
                                      ),
                                      padding: paddingBoxContainer,
                                      child: Container(
                                        child: Column(
                                          children: [
                                            if (snapshot.hasData)
                                              Container(
                                                  width: MediaQuery.of(context).size.width * 1,
                                                  child: DataTable(
                                                    dataTextStyle: const TextStyle(color: Color(0xff313131), fontSize: 14, fontWeight: FontWeight.w500),
                                                    showBottomBorder: true,
                                                    dataRowHeight: 60,
                                                    columnSpacing: 5,
                                                    showCheckboxColumn: true,
                                                    dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                                                      (Set<MaterialState> states) {
                                                        if (states.contains(MaterialState.selected)) {
                                                          return MaterialStateColor.resolveWith((states) => const Color(0xffeef3ff));
                                                        }
                                                        return MaterialStateColor.resolveWith((states) => Colors.white); // Use the default value.
                                                      },
                                                    ),
                                                    columns: <DataColumn>[
                                                      DataColumn(
                                                        label: Text(
                                                          'Tên thực tập sinh',
                                                          style: titleTableData,
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: Text(
                                                          'Từ ngày',
                                                          style: titleTableData,
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: Text(
                                                          'Đến ngày',
                                                          style: titleTableData,
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: Text(
                                                          'Đơn giá phí',
                                                          style: titleTableData,
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: Text(
                                                          'Vé máy bay',
                                                          style: titleTableData,
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: Text(
                                                          'Phí phát sinh',
                                                          style: titleTableData,
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: Text(
                                                          'Thành tiền',
                                                          style: titleTableData,
                                                        ),
                                                      ),
                                                    ],
                                                    rows: <DataRow>[
                                                      for (int i = 0; i < mapChiTietLichXuatCanh[map.key]!.length; i++)
                                                        DataRow(
                                                          cells: <DataCell>[
                                                            DataCell(
                                                              Container(
                                                                  width: (MediaQuery.of(context).size.width / 10) * 0.8,
                                                                  child: Tooltip(
                                                                    height: 30,
                                                                    message: chiTietLichXuatCanhs[i]['thuctapsinh'] != null
                                                                        ? chiTietLichXuatCanhs[i]['thuctapsinh']['fullName'].toString()
                                                                        : "Không có mô tả",
                                                                    child: ConstrainedBox(
                                                                      constraints: BoxConstraints(maxWidth: 200),
                                                                      child: Text(
                                                                        mapChiTietLichXuatCanh[map.key]![i]['thuctapsinh'] != null
                                                                            ? mapChiTietLichXuatCanh[map.key]![i]['thuctapsinh']['fullName'].toString() +
                                                                                "\n(Chu kỳ " +
                                                                                tinhChuKy(denNgayThuPhi: mapChiTietLichXuatCanh[map.key]![i]['dateTo']).toString() +
                                                                                " tháng )" +
                                                                                "\n(" +
                                                                                getDateView(mapChiTietLichXuatCanh[map.key]![i]['thuctapsinh']['birthDate']) +
                                                                                ")"
                                                                            : "Không có mô tả",
                                                                        overflow: TextOverflow.ellipsis,
                                                                        maxLines: 3,
                                                                      ),
                                                                    ),
                                                                  )),
                                                            ),
                                                            DataCell(Container(
                                                              width: width * .1,
                                                              child: DatePickerInTable1(
                                                                dateDisplay: getDateView(mapChiTietLichXuatCanh[map.key]![i]['dateTo']),
                                                                function: (date) {},
                                                              ),
                                                            )),
                                                            DataCell(Container(
                                                              width: width * .1,
                                                              child: DatePickerInTable1(
                                                                dateDisplay: getDateView(mapChiTietLichXuatCanh[map.key]![i]['dateToMax']),
                                                                function: (date) {
                                                                  setState(() {
                                                                    mapChiTietLichXuatCanh[map.key]![i]['dateToMax'] = getDateInsertDB(date);
                                                                  });
                                                                },
                                                              ),
                                                            )),
                                                            DataCell(
                                                              Container(
                                                                width: (MediaQuery.of(context).size.width / 10) * 0.8,
                                                                child: TextFormField(
                                                                  readOnly: true,
                                                                  textAlign: TextAlign.center,
                                                                  decoration: InputDecoration(hintText: 'Nhập thông tin', border: InputBorder.none),
                                                                  controller: mapChiTietLichXuatCanh[map.key]![i]['feeValueText'],
                                                                  inputFormatters: [
                                                                    FilteringTextInputFormatter(RegExp("[0-9.-]"), allow: true),
                                                                  ],
                                                                  onChanged: (value) {
                                                                    setState(() {
                                                                      try {
                                                                        mapChiTietLichXuatCanh[map.key]![i]['feeValue'] = double.parse(value);
                                                                      } catch (e) {
                                                                        mapChiTietLichXuatCanh[map.key]![i]['feeValue'] = 0;
                                                                      }
                                                                      ;
                                                                    });
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                            DataCell(
                                                              Container(
                                                                width: (MediaQuery.of(context).size.width / 10) * 0.8,
                                                                child: TextFormField(
                                                                  readOnly: true,
                                                                  textAlign: TextAlign.center,
                                                                  decoration: InputDecoration(hintText: 'Nhập thông tin', border: InputBorder.none),
                                                                  controller: mapChiTietLichXuatCanh[map.key]![i]['arfareFeeText'],
                                                                  inputFormatters: [
                                                                    FilteringTextInputFormatter(RegExp("[0-9.-]"), allow: true),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            DataCell(
                                                              Container(
                                                                width: (MediaQuery.of(context).size.width / 10) * 0.8,
                                                                child: TextFormField(
                                                                  textAlign: TextAlign.center,
                                                                  decoration: InputDecoration(hintText: 'Nhập thông tin', border: InputBorder.none),
                                                                  controller: mapChiTietLichXuatCanh[map.key]![i]['incurredText'],
                                                                  inputFormatters: [
                                                                    FilteringTextInputFormatter(RegExp("[0-9.-]"), allow: true),
                                                                  ],
                                                                  onChanged: (value) {
                                                                    setState(() {
                                                                      try {
                                                                        mapChiTietLichXuatCanh[map.key]![i]['incurred'] = double.parse(value);
                                                                      } catch (e) {
                                                                        mapChiTietLichXuatCanh[map.key]![i]['incurred'] = 0;
                                                                      }
                                                                    });
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                            DataCell(
                                                              Container(
                                                                width: (MediaQuery.of(context).size.width / 10) * 0.8,
                                                                child: Text(NumberFormat.simpleCurrency(name: "USD", decimalDigits: 0)
                                                                    .format(tinhTongTienTheoTts(
                                                                        mapChiTietLichXuatCanh[map.key]![i]['feeValue'],
                                                                        mapChiTietLichXuatCanh[map.key]![i]['incurred'],
                                                                        tinhChuKy(denNgayThuPhi: mapChiTietLichXuatCanh[map.key]![i]['dateTo'])))
                                                                    .toString()),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                    ],
                                                  ))
                                            else if (snapshot.hasError)
                                              Text("Fail! ${snapshot.error}")
                                            else if (!snapshot.hasData)
                                              Center(
                                                child: Center(child: CircularProgressIndicator()),
                                              ),
                                            Container(
                                              margin: EdgeInsets.only(top: 30),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    "Tổng tiền : " +
                                                        NumberFormat.simpleCurrency(name: "USD", decimalDigits: 0)
                                                            .format(tinhTongTienTheoNhom(
                                                              map.value,
                                                              tinhChuKy(denNgayThuPhi: mapChiTietLichXuatCanh[map.key]!.first['dateTo']),
                                                            ))
                                                            .toString(),
                                                    style: titleTableData,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                for (var map in mapCTThucTapSinhMoiXuatCanh.entries)
                                  Container(
                                    width: MediaQuery.of(context).size.width * 1,
                                    margin: marginTopBoxContainer,
                                    decoration: BoxDecoration(
                                      color: colorWhite,
                                      borderRadius: borderRadiusContainer,
                                      boxShadow: [boxShadowContainer],
                                      border: borderAllContainerBox,
                                    ),
                                    padding: paddingBoxContainer,
                                    child: Container(
                                      child: Column(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context).size.width * 1,
                                            child: DataTable(
                                              dataTextStyle: const TextStyle(color: Color(0xff313131), fontSize: 14, fontWeight: FontWeight.w500),
                                              showBottomBorder: true,
                                              dataRowHeight: 60,
                                              columnSpacing: 5,
                                              showCheckboxColumn: true,
                                              dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                                                (Set<MaterialState> states) {
                                                  if (states.contains(MaterialState.selected)) {
                                                    return MaterialStateColor.resolveWith((states) => const Color(0xffeef3ff));
                                                  }
                                                  return MaterialStateColor.resolveWith((states) => Colors.white); // Use the default value.
                                                },
                                              ),
                                              columns: <DataColumn>[
                                                DataColumn(
                                                  label: Text(
                                                    'Tên thực tập sinh',
                                                    style: titleTableData,
                                                    // textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    'Từ ngày',
                                                    style: titleTableData,
                                                    // textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    'Đến ngày',
                                                    style: titleTableData,
                                                    // textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    'Đơn giá phí',
                                                    style: titleTableData,
                                                    // textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    'Vé máy bay',
                                                    style: titleTableData,
                                                    // textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    'Phí phát sinh',
                                                    style: titleTableData,
                                                    // textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ],
                                              rows: <DataRow>[
                                                for (int i = 0; i < map.value.length; i++)
                                                  DataRow(
                                                    cells: <DataCell>[
                                                      DataCell(
                                                        Container(
                                                            width: (MediaQuery.of(context).size.width / 10) * 0.8,
                                                            child: Tooltip(
                                                              height: 30,
                                                              message: map.value[i]['thuctapsinh'] != null ? map.value[i]['thuctapsinh']['fullName'].toString() : "Không có mô tả",
                                                              child: ConstrainedBox(
                                                                constraints: BoxConstraints(maxWidth: 200),
                                                                child: Text(
                                                                  map.value[i]['thuctapsinh'] != null
                                                                      ? map.value[i]['thuctapsinh']['fullName'].toString() +
                                                                          " \n ( Chu kỳ " +
                                                                          tinhChuKy(tuNgayMoiXuatCanh: map.value[i]['thuctapsinh']['feeManageDate']).toString() +
                                                                          " tháng ) \n " +
                                                                          "(" +
                                                                          getDateView(map.value[i]['thuctapsinh']['birthDate']) +
                                                                          ")"
                                                                      : "Không có mô tả",
                                                                  overflow: TextOverflow.ellipsis,
                                                                  maxLines: 5,
                                                                ),
                                                              ),
                                                            )),
                                                      ),
                                                      DataCell(Container(
                                                        width: width * .1,
                                                        child: DatePickerInTable1(
                                                          dateDisplay: getDateView(map.value[i]['thuctapsinh']['feeManageDate']),
                                                          function: (date) {},
                                                        ),
                                                      )),
                                                      DataCell(Container(
                                                        width: width * .1,
                                                        child: DatePickerInTable1(
                                                          dateDisplay: getDateView(map.value[i]['dateToMax']),
                                                          function: (date) {
                                                            setState(() {});
                                                          },
                                                        ),
                                                      )),
                                                      DataCell(
                                                        Container(
                                                          width: (MediaQuery.of(context).size.width / 10) * 0.8,
                                                          child: TextFormField(
                                                            readOnly: true,
                                                            textAlign: TextAlign.center,
                                                            decoration: InputDecoration(hintText: 'Nhập thông tin', border: InputBorder.none),
                                                            controller: map.value[i]['feeValueText'],
                                                            inputFormatters: [
                                                              FilteringTextInputFormatter(RegExp("[0-9.-]"), allow: true),
                                                            ],
                                                            onChanged: (value) {
                                                              setState(() {
                                                                try {
                                                                  map.value[i]['feeValue'] = double.parse(value);
                                                                } catch (e) {
                                                                  map.value[i]['feeValue'] = 0;
                                                                }
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      DataCell(
                                                        Container(
                                                          width: (MediaQuery.of(context).size.width / 10) * 0.8,
                                                          child: TextFormField(
                                                            readOnly: true,
                                                            textAlign: TextAlign.center,
                                                            decoration: InputDecoration(hintText: 'Nhập thông tin', border: InputBorder.none),
                                                            controller: map.value[i]['arfareFeeText'],
                                                            inputFormatters: [
                                                              FilteringTextInputFormatter(RegExp("[0-9.-]"), allow: true),
                                                            ],
                                                            onChanged: (value) {
                                                              setState(() {
                                                                try {
                                                                  map.value[i]['arfareFee'] = double.parse(value);
                                                                } catch (e) {
                                                                  map.value[i]['arfareFee'] = 0;
                                                                }
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      DataCell(
                                                        Container(
                                                          width: (MediaQuery.of(context).size.width / 10) * 0.8,
                                                          child: TextFormField(
                                                              textAlign: TextAlign.center,
                                                              decoration: InputDecoration(hintText: 'Nhập thông tin', border: InputBorder.none),
                                                              controller: map.value[i]['incurredText'],
                                                              inputFormatters: [
                                                                FilteringTextInputFormatter(RegExp("[0-9.-]"), allow: true),
                                                              ],
                                                              onChanged: (value) {
                                                                setState(() {
                                                                  try {
                                                                    map.value[i]['incurred'] = double.parse(value);
                                                                  } catch (e) {
                                                                    map.value[i]['incurred'] = 0;
                                                                  }
                                                                });
                                                              }),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          ),
                                          if (listTtsMoiXuatCanh.isNotEmpty)
                                            Container(
                                              margin: EdgeInsets.only(top: 30),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    "Tổng tiền : " +
                                                        NumberFormat.simpleCurrency(name: "USD", decimalDigits: 0)
                                                            .format(tinhTongTienTheoNhom(map.value, tinhChuKy(tuNgayMoiXuatCanh: map.value.first['thuctapsinh']['feeManageDate'])))
                                                            .toString(),
                                                    style: titleTableData,
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  )
                              ],
                            ),
                          ),
                        ],
                      );
                    }));
          } else if (listRule.hasError) {
            return Text('${listRule.error}');
          }
          return Center(child: CircularProgressIndicator());
        });
  }
}
