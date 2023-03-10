import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:gentelella_flutter/widgets/forms/market_development/utils/funciton.dart';

import 'package:gentelella_flutter/widgets/ui/navigation.dart';
import 'package:gentelella_flutter/widgets/utils/market_development.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../api.dart';

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

class ChiTietThuPhiUpdate extends StatelessWidget {
  final int? id;

  ChiTietThuPhiUpdate({
    Key? key,
    this.id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
        widgetBody: ChiTietThuPhiUpdateBody(
      id: id,
    ));
  }
}

class ChiTietThuPhiUpdateBody extends StatefulWidget {
  final int? id;

  ChiTietThuPhiUpdateBody({Key? key, this.id}) : super(key: key);

  @override
  State<ChiTietThuPhiUpdateBody> createState() => _ChiTietThuPhiUpdateBodyState();
}

class _ChiTietThuPhiUpdateBodyState extends State<ChiTietThuPhiUpdateBody> {
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
  TextEditingController totalAmount = TextEditingController();
  TextEditingController requestNote = TextEditingController();

  var body = {};
  var page = 1;
  var rowPerPage = 10;
  var totalElements = 0;
  var firstRow = 1, lastRow = 0;
  var rowCount = 0;
  var currentPage = 1;
  List<bool> _selected = [];
  // String titleLog = '';

  late Future<List<dynamic>> futureListChiTietLichXuatCanh;

  var nghiepDoanDeNghi;
  var futureDeNghi;
  var lstNDNCT = [];
  List<dynamic> listPhiQuanLyChiTiet = [];
  Map<dynamic, dynamic> mapNDDNCT = new Map();
  Future getDN(id) async {
    var response = await httpGet("/api/nghiepdoan-denghi/get/$id", context);

    if (response.containsKey("body")) {
      var body = jsonDecode(response['body']);
      nghiepDoanDeNghi = body;
      print(nghiepDoanDeNghi);
      times.text = nghiepDoanDeNghi['times'].toString();
      chargeCycleDate.text = nghiepDoanDeNghi['chargeCycleDate'].toString();
      documentNo.text = nghiepDoanDeNghi['documentNo'].toString();
      title.text = nghiepDoanDeNghi['title'].toString();
      totalAmount.text = nghiepDoanDeNghi['totalAmount'].toString();
      requestNote.text = nghiepDoanDeNghi['requestNote'].toString();
      dueDate = getDateView(nghiepDoanDeNghi['dueDate']);
      requestDate = getDateView(nghiepDoanDeNghi['requestDate']);
      await getTTND(nghiepDoanDeNghi['orgId']);
    }
    return nghiepDoanDeNghi;
  }

  getNDDeNghiChiTiet(id) async {
    var response = await httpGet("/api/nghiepdoan-denghi-chitiet/get/page?filter=requestId:$id", context);

    if (response.containsKey("body")) {
      var body = jsonDecode(response['body']);
      var id = body['content'][0]['thuctapsinh']['donhang']['nghiepdoan']['manageFeeId'];
      lstNDNCT = body['content'];
      listPhiQuanLyChiTiet = await getPhiQuanLyChiTiet(manageFeeId: body['content'][0]['thuctapsinh']['donhang']['nghiepdoan']['manageFeeId']);

      setState(() {
        for (var element in lstNDNCT) {
          double feeValue = layRaPhiQuanLyChiTietApDungSoVoiNgayHienTai(
              element['thuctapsinh']['feeManageDate'], listPhiQuanLyChiTiet, dueDate != null ? DateTime.parse(getDateInsertDB(dueDate)!) : DateTime.now());
          //element['arfareFee'] = 0;
          // if (element['feeTotal'] == null) {
          element['feeValue'] = feeValue;
          // } else {
          //   element['feeValue'] = element['feeTotal'];
          // }

          // element['incurred'] = 0;

          element['arfareFeeText'] = TextEditingController(text: element['arfareFee'].toString());
          element['feeValueText'] = TextEditingController(text: feeValue.toString());
          element['incurredText'] = TextEditingController(text: element['incurredFee'] != null ? element['incurredFee'].toString() : "0");
        }
        mapNDDNCT = groupBy(lstNDNCT, (dynamic obj) => obj['groupId']);
      });
    }
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

  tinhTongTienIncurredTotalTheoNhom(value) {
    double tongTien = 0;
    for (var item in value) {
      double incurred = double.parse(item['incurredFee'].toString());
      tongTien += incurred;
    }
    return tongTien;
  }

  tinhTongTienTheoTts(feeValue, arfareFee, incurred1, chuKy) {
    double tongTien = 0;
    tongTien += (double.parse(feeValue.toString()) * chuKy) + incurred1 + arfareFee;
    return tongTien;
  }

  tinhFeeTotalTheoNhom(value, chuKy) {
    //.entries
    double tongTien = 0;
    for (var item in value) {
      double feeValue = double.parse(item['feeValue'].toString());
      double arfareFee = 0; //double.parse(item['arfareFee'].toString());
      double incurred = 0; //double.parse(item['incurredFee'].toString());
      tongTien += (feeValue * chuKy) + arfareFee + incurred;
    }
    return tongTien;
  }

  tinhTotalTheoNhom(value, chuKy) {
    //.entries
    double tongTien = 0;
    for (var item in value) {
      double feeValue = double.parse(item['feeValue'].toString());
      double arfareFee = double.parse(item['arfareFee'].toString());
      double incurred = double.parse(item['incurredFee'].toString());
      tongTien += (feeValue * chuKy) + arfareFee + incurred;
    }
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
      tongTien += incurred;
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

        //Ng??y ?????u ti??n c???a chu k??
        ngayBatDauCuaKhoang = DateTime.parse(feeManageDate).toLocal();
        //
        tuNgay = ngayBatDauCuaKhoang;
        //
        denNgay = tuNgay.add(Duration(days: quyVeSoNgayTheoKieuThoiGian(phiQuanLyChiTiet['timeType'], phiQuanLyChiTiet['feeValue'], phiQuanLyChiTiet['effectTime'])));
        //
        ngayBatDauCuaKhoang = denNgay;
      } else {
        //C???ng th??m
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
      //N???u l?? ng??y x??c nh???n th??ng b??o th?? se l???y ph?? qu???n l?? c???a ng??y nh??? nh???t
      if (ngayXacNhanThongBao.isBefore(ngayNhoNhat)) {
        listManagerDetail.add(phiCuaNgayNhoNhat!);
      }
      if (phiCuaNgayLonNhat != null) {
        if (ngayXacNhanThongBao.isAfter(ngayLonNhat)) {
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
        // chargeCycleDate.text = nghiepDoan['chargeCycleDate'].toString();
        print("aaaa" + nghiepDoan['chargeCycleDate'].toString());
      });
    }
  }

  int quyVeSoNgayTheoKieuThoiGian(int timeType, double feeValue, int effectTime) {
    //Ki???u th???i gian = 0:N??m | 1:Th??ng
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

  capNhatNghiepDoanDeNghiHoanThanh(id,
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

    try {
      var response = await httpPut("/api/nghiepdoan-denghi/put/$id", requestBody, context);
    } catch (e) {
      print("Fail!");
    }
  }

  capNhatDeNghiNhomChiTiet(id, {requestId, dateFrom, dateTo, feeTotal, arfareFeeTotal, incurredTotal, totalAmount}) async {
    var requestBody = {
      "requestId": requestId,
      "dateFrom": dateFrom,
      "dateTo": dateTo,
      "feeTotal": feeTotal,
      "arfareFeeTotal": arfareFeeTotal,
      "incurredTotal": incurredTotal,
      "totalAmount": totalAmount,
    };
    int i = 0;
    try {
      var response = await httpPut("/api/nghiepdoan-denghi-nhom-chitiet/put/$id", requestBody, context);
      i = jsonDecode(response['body']);
    } catch (e) {
      print("Fail!");
    }
    return i;
  }

  capNhatDeNghiChiTiet(id, {ttsId, requestId, groupId, dateFrom, dateTo, feeTotal, arfareFee, incurredFee, totalAmount}) async {
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
      var response = await httpPut("/api/nghiepdoan-denghi-chitiet/put/$id", requestBody, context);
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
      print("Chu k???" + chuKy.toString());
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

  tinhTongTien(listTtsMoiXuatCanh, mapChiTietLichXuatCanh) {
    //.entries
    double tongTien = 0;

    for (var item in listTtsMoiXuatCanh) {
      int chuKy = tinhChuKy(tuNgayMoiXuatCanh: item['thuctapsinh']['feeManageDate']);
      tongTien += (double.parse(item['feeValue'].toString()) * chuKy) + double.parse(item['arfareFee'].toString()) + double.parse(item['incurredFee'].toString());
    }

    for (var item in mapChiTietLichXuatCanh.entries) {
      var listValue = item.value;
      for (var value in listValue) {
        int chuKy = tinhChuKy(tuNgayMoiXuatCanh: value['dateFrom'], denNgayThuPhi: value['dateTo']);
        tongTien += (double.parse(value['feeValue'].toString()) * chuKy) + double.parse(value['arfareFee'].toString()) + double.parse(value['incurredFee'].toString());
      }
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

  @override
  void initState() {
    super.initState();
    futureDeNghi = getDN(widget.id);

    getNDDeNghiChiTiet(widget.id);
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
                builder: (context, navigationModel, securityModel, child) => FutureBuilder<dynamic>(
                    future: futureDeNghi,
                    builder: (context, snapshot) {
                      return ListView(
                        children: [
                          TitlePage(
                            listPreTitle: [
                              {'url': '/phat-trien-thi-truong', 'title': 'Dashboard'},
                              {'url': '/quan-ly-phap-nhan', 'title': 'B??o c??o thu ph??'}
                            ],
                            content: 'B??o c??o thu ph??',
                          ),
                          if (snapshot.hasData)
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
                                                      widget.id != null ? 'C???p nh???t' : 'Th??m m???i',
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
                                                                      msg: "Vui l??ng nh???p ?????y ????? c??c tr?????ng !",
                                                                      color: Color.fromARGB(133, 247, 63, 134),
                                                                      icon: const Icon(Icons.warning),
                                                                    );
                                                                    return;
                                                                  }
                                                                  await capNhatNghiepDoanDeNghiHoanThanh(
                                                                    widget.id,
                                                                    title: title.text,
                                                                    orgId: mapNDDNCT[mapNDDNCT.keys.first].first['thuctapsinh']['donhang']['orgId'],
                                                                    documentNo: documentNo.text,
                                                                    chargeCycleDate: chargeCycleDate.text,
                                                                    dueDate: getDateInsertDB(dueDate),
                                                                    requestDate: getDateInsertDB(requestDate),
                                                                    requestSender: securityModel.userLoginCurren['id'],
                                                                    requestFile: requestFile,
                                                                    requestStatus: 0, //Tr???ng th??i ????? ngh??? 0:Nh??p|1:Ho??n th??nh|2:H???y
                                                                    paymentDate: paymentDate,
                                                                    paymentStatus: 0, //0:Ch??a|1:Thanh to??n ?????|2:Thanh to??n 1 ph???n
                                                                    manageFileId: mapNDDNCT[mapNDDNCT.keys.first].first['thuctapsinh']['donhang']['nghiepdoan']['manageFeeId'],
                                                                    totalAmount: tinhTongTien([], mapNDDNCT),
                                                                    requestNote: requestNote.text,
                                                                    requestFileEdited: nghiepDoanDeNghi['requestFileEdited'],
                                                                    requestNoteEdited: nghiepDoanDeNghi['requestNoteEdited'],
                                                                    times: nghiepDoanDeNghi['times'],
                                                                  );
                                                                  for (var itemGroup in mapNDDNCT.entries) {
                                                                    var listTtsByDate = itemGroup.value;
                                                                    var feeTotal = tinhFeeTotalTheoNhom(
                                                                      listTtsByDate,
                                                                      tinhChuKy(
                                                                          tuNgayMoiXuatCanh: mapNDDNCT[itemGroup.key]!.first['dateFrom'],
                                                                          denNgayThuPhi: mapNDDNCT[itemGroup.key]!.first['dateTo']),
                                                                    );
                                                                    var arfareFeeTotal = tinhTongTienArfareFeeTheoNhom(listTtsByDate);
                                                                    var incurredTotal = tinhTongTienIncurredTotalTheoNhom(listTtsByDate);
                                                                    var totalAmount = feeTotal + arfareFeeTotal + incurredTotal;
                                                                    var dateFrom = listTtsByDate.first['dateFrom'];

                                                                    //var dateTo = listTtsByDate.first['dateTo'];
                                                                    var dateTo = DateFormat('yyyy-MM-dd').format(DateTime.parse(listTtsByDate.first['dateTo']));
                                                                    //var dateFrom = getDateInsertDB(listTtsByDate.first['dateTo']);
                                                                    await capNhatDeNghiNhomChiTiet(
                                                                      itemGroup.key,
                                                                      requestId: widget.id,
                                                                      dateFrom: dateFrom,
                                                                      dateTo: dateTo,
                                                                      feeTotal: feeTotal,
                                                                      arfareFeeTotal: arfareFeeTotal,
                                                                      incurredTotal: incurredTotal,
                                                                      totalAmount: totalAmount,
                                                                    );
                                                                    for (var item in listTtsByDate) {
                                                                      var feeTotalTts = tinhTongTienFeeTotalTheoTts(
                                                                          item['feeValue'],
                                                                          tinhChuKy(
                                                                              tuNgayMoiXuatCanh: listTtsByDate.first['dateFrom'], denNgayThuPhi: listTtsByDate.first['dateTo']));
                                                                      var arfareFeeTotalTts = tinhTongTienArfareFeeTheoTts(item['arfareFee']);
                                                                      var incurredTotalTts = tinhTongTienIncurredTheoTts(item['incurredFee']);
                                                                      var totalAmountTts = feeTotalTts + arfareFeeTotalTts + incurredTotalTts;
                                                                      await capNhatDeNghiChiTiet(
                                                                        item['id'],
                                                                        ttsId: item['ttsId'],
                                                                        requestId: widget.id,
                                                                        groupId: item['groupId'],
                                                                        dateFrom: dateFrom,
                                                                        dateTo: dateTo,
                                                                        feeTotal: feeTotalTts,
                                                                        arfareFee: arfareFeeTotalTts,
                                                                        incurredFee: incurredTotalTts,
                                                                        totalAmount: totalAmountTts,
                                                                      );
                                                                    }
                                                                  }
                                                                  Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/bao-cao-cac-nghiep-doan-den-han-thu-phi");
                                                                  showToast(
                                                                    context: context,
                                                                    msg: "L??u th??nh c??ng b???n nh??p !",
                                                                    color: Color.fromARGB(136, 72, 238, 67),
                                                                    icon: const Icon(Icons.done),
                                                                  );
                                                                },
                                                                child: Row(children: [
                                                                  Container(
                                                                      padding: EdgeInsets.only(left: 30, right: 30, top: 8, bottom: 8),
                                                                      child: Text('L??u b???n nh??p', style: textButton)),
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
                                                                  msg: "Vui l??ng nh???p ?????y ????? c??c tr?????ng !",
                                                                  color: Color.fromARGB(133, 247, 63, 134),
                                                                  icon: const Icon(Icons.warning),
                                                                );
                                                                return;
                                                              }
                                                              await capNhatNghiepDoanDeNghiHoanThanh(
                                                                widget.id,
                                                                title: title.text,
                                                                orgId: mapNDDNCT[mapNDDNCT.keys.first].first['thuctapsinh']['donhang']['orgId'],
                                                                documentNo: documentNo.text,
                                                                chargeCycleDate: chargeCycleDate.text,
                                                                dueDate: getDateInsertDB(dueDate),
                                                                requestDate: getDateInsertDB(requestDate),
                                                                requestSender: securityModel.userLoginCurren['id'],
                                                                requestFile: requestFile,
                                                                requestStatus: 1, //Tr???ng th??i ????? ngh??? 0:Nh??p|1:Ho??n th??nh|2:H???y
                                                                paymentDate: paymentDate,
                                                                paymentStatus: 0, //0:Ch??a|1:Thanh to??n ?????|2:Thanh to??n 1 ph???n
                                                                manageFileId: mapNDDNCT[mapNDDNCT.keys.first].first['thuctapsinh']['donhang']['nghiepdoan']['manageFeeId'],
                                                                totalAmount: tinhTongTien([], mapNDDNCT),
                                                                requestNote: requestNote.text,
                                                                requestFileEdited: nghiepDoanDeNghi['requestFileEdited'],
                                                                requestNoteEdited: nghiepDoanDeNghi['requestNoteEdited'],
                                                                times: nghiepDoanDeNghi['times'],
                                                              );
                                                              for (var itemGroup in mapNDDNCT.entries) {
                                                                var listTtsByDate = itemGroup.value;
                                                                var feeTotal = tinhFeeTotalTheoNhom(
                                                                  listTtsByDate,
                                                                  tinhChuKy(
                                                                      tuNgayMoiXuatCanh: mapNDDNCT[itemGroup.key]!.first['dateFrom'],
                                                                      denNgayThuPhi: mapNDDNCT[itemGroup.key]!.first['dateTo']),
                                                                );
                                                                var arfareFeeTotal = tinhTongTienArfareFeeTheoNhom(listTtsByDate);
                                                                var incurredTotal = tinhTongTienIncurredTotalTheoNhom(listTtsByDate);
                                                                var totalAmount = feeTotal + arfareFeeTotal + incurredTotal;
                                                                var dateFrom = listTtsByDate.first['dateFrom'];

                                                                //var dateTo = listTtsByDate.first['dateTo'];
                                                                var dateTo = DateFormat('yyyy-MM-dd').format(DateTime.parse(listTtsByDate.first['dateTo']));
                                                                //var dateFrom = getDateInsertDB(listTtsByDate.first['dateTo']);
                                                                await capNhatDeNghiNhomChiTiet(
                                                                  itemGroup.key,
                                                                  requestId: widget.id,
                                                                  dateFrom: dateFrom,
                                                                  dateTo: dateTo,
                                                                  feeTotal: feeTotal,
                                                                  arfareFeeTotal: arfareFeeTotal,
                                                                  incurredTotal: incurredTotal,
                                                                  totalAmount: totalAmount,
                                                                );
                                                                for (var item in listTtsByDate) {
                                                                  var feeTotalTts = tinhTongTienFeeTotalTheoTts(item['feeValue'],
                                                                      tinhChuKy(tuNgayMoiXuatCanh: listTtsByDate.first['dateFrom'], denNgayThuPhi: listTtsByDate.first['dateTo']));
                                                                  var arfareFeeTotalTts = tinhTongTienArfareFeeTheoTts(item['arfareFee']);
                                                                  var incurredTotalTts = tinhTongTienIncurredTheoTts(item['incurredFee']);
                                                                  var totalAmountTts = feeTotal + arfareFeeTotal + incurredTotal;
                                                                  await capNhatDeNghiChiTiet(
                                                                    item['id'],
                                                                    ttsId: item['ttsId'],
                                                                    requestId: widget.id,
                                                                    groupId: item['groupId'],
                                                                    dateFrom: dateFrom,
                                                                    dateTo: dateTo,
                                                                    feeTotal: feeTotalTts,
                                                                    arfareFee: arfareFeeTotalTts,
                                                                    incurredFee: incurredTotalTts,
                                                                    totalAmount: totalAmountTts,
                                                                  );
                                                                }
                                                              }
                                                              Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/bao-cao-cac-nghiep-doan-den-han-thu-phi");
                                                              showToast(
                                                                context: context,
                                                                msg: "L??u b???n nh??p th??nh c??ng !",
                                                                color: Color.fromARGB(136, 72, 238, 67),
                                                                icon: const Icon(Icons.done),
                                                              );
                                                            },
                                                            child: Row(children: [
                                                              Container(
                                                                  padding: EdgeInsets.only(left: 30, right: 30, top: 8, bottom: 8), child: Text('Ho??n th??nh', style: textButton)),
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
                                                              Container(padding: EdgeInsets.only(left: 30, right: 30, top: 8, bottom: 8), child: Text('H???y', style: textButton)),
                                                            ]))),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        //--------------???????ng line-------------
                                        Container(
                                          child: Divider(
                                            thickness: 1,
                                            color: ColorHorizontalLine,
                                          ),
                                        ),
                                        if (snapshot.hasData)
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
                                                          labe: 'Ti??u ?????',
                                                          flexLable: 2,
                                                          flexTextField: 5,
                                                          isReverse: false,
                                                          type: 'Text',
                                                          controller: title,
                                                          isShowDau: true,
                                                        ),
                                                        TextFieldValidatedMarket(
                                                          labe: 'Chu k??? t??nh ph?? theo th??ng',
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
                                                                label: Text(
                                                                  'Ng??y ?????n h???n thanh to??n',
                                                                  style: titleWidgetBox,
                                                                ),
                                                                dateDisplay: dueDate,
                                                                selectedDateFunction: (day) {
                                                                  setState(() {
                                                                    dueDate = day;
                                                                    if (dueDate != null) {
                                                                      for (var element in mapNDDNCT.entries) {
                                                                        List<dynamic> value = element.value;
                                                                        for (var item in value) {
                                                                          double feeValue = layRaPhiQuanLyChiTietApDungSoVoiNgayHienTai(item['thuctapsinh']['feeManageDate'],
                                                                              listPhiQuanLyChiTiet.toList(), DateTime.parse(getDateInsertDB(dueDate)!));
                                                                          setState(() {
                                                                            item['dateTo'] =
                                                                                congChuKy(tinhChuKy(denNgayThuPhi: item['dateTo']), DateTime.parse(item['dateTo'])).toString();
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
                                                          labe: 'S??? v??n b???n',
                                                          isReverse: false,
                                                          type: 'Text',
                                                          controller: times,
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
                                                                      'Ng??y l??m ????? ngh???',
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
                                          )
                                      ],
                                    ),
                                  ),
                                  for (var map in mapNDDNCT.entries)
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
                                                          'T??n th???c t???p sinh',
                                                          style: titleTableData,
                                                          // textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: Text(
                                                          'T??? ng??y',
                                                          style: titleTableData,
                                                          // textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: Text(
                                                          '?????n ng??y',
                                                          style: titleTableData,
                                                          // textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: Text(
                                                          '????n gi?? ph??',
                                                          style: titleTableData,
                                                          // textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: Text(
                                                          'Ph?? v?? m??y bay',
                                                          style: titleTableData,
                                                          // textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: Text(
                                                          'Ph?? ph??t sinh',
                                                          style: titleTableData,
                                                          // textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: Text(
                                                          'Th??nh ti???n (????n gi?? ph?? x Chu k??? \n+ Ph?? ph??t sinh)',
                                                          style: titleTableData,
                                                          // textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                    ],
                                                    rows: <DataRow>[
                                                      for (int i = 0; i < mapNDDNCT[map.key]!.length; i++)
                                                        DataRow(
                                                          cells: <DataCell>[
                                                            DataCell(
                                                              Container(
                                                                  width: (MediaQuery.of(context).size.width / 10) * 0.8,
                                                                  child: ConstrainedBox(
                                                                    constraints: BoxConstraints(maxWidth: 200),
                                                                    child: Text(
                                                                      mapNDDNCT[map.key]![i]['thuctapsinh'] != null
                                                                          ? mapNDDNCT[map.key]![i]['thuctapsinh']['fullName'].toString() +
                                                                              "( Chu k??? " +
                                                                              tinhChuKy(
                                                                                tuNgayMoiXuatCanh: mapNDDNCT[map.key]![i]['dateFrom'],
                                                                              ).toString() +
                                                                              " th??ng )"
                                                                          : "Kh??ng c?? m?? t???",
                                                                      overflow: TextOverflow.ellipsis,
                                                                      maxLines: 3,
                                                                    ),
                                                                  )),
                                                            ),
                                                            DataCell(Container(
                                                              width: width * .1,
                                                              child: DatePickerInTable1(
                                                                dateDisplay: getDateView(mapNDDNCT[map.key]![i]['dateFrom']),
                                                                function: (date) {},
                                                              ),
                                                            )),
                                                            DataCell(Container(
                                                              width: width * .1,
                                                              child: DatePickerInTable1(
                                                                dateDisplay: getDateView(mapNDDNCT[map.key]![i]['dateTo']),
                                                                function: (date) {
                                                                  setState(() {
                                                                    mapNDDNCT[map.key]![i]['dateToMax'] = getDateInsertDB(date);
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
                                                                  decoration: InputDecoration(hintText: 'Nh???p th??ng tin', border: InputBorder.none),
                                                                  controller: mapNDDNCT[map.key]![i]['feeValueText'],
                                                                  inputFormatters: [
                                                                    FilteringTextInputFormatter(RegExp("[0-9.-]"), allow: true),
                                                                  ],
                                                                  onChanged: (value) {
                                                                    setState(() {
                                                                      mapNDDNCT[map.key]![i]['feeValueText'].text = value;
                                                                      try {
                                                                        mapNDDNCT[map.key]![i]['feeValue'] = double.parse(value);
                                                                      } catch (e) {
                                                                        mapNDDNCT[map.key]![i]['feeValue'] = 0;
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
                                                                  decoration: InputDecoration(hintText: 'Nh???p th??ng tin', border: InputBorder.none),
                                                                  controller: mapNDDNCT[map.key]![i]['arfareFeeText'],
                                                                  inputFormatters: [
                                                                    FilteringTextInputFormatter(RegExp("[0-9.-]"), allow: true),
                                                                  ],
                                                                  onChanged: (value) {
                                                                    setState(() {
                                                                      //mapNDDNCT[map.key]![i]['arfareFeeText'].text = value;
                                                                      try {
                                                                        mapNDDNCT[map.key]![i]['arfareFee'] = double.parse(value);
                                                                      } catch (e) {
                                                                        mapNDDNCT[map.key]![i]['arfareFee'] = 0;
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
                                                                  decoration: InputDecoration(hintText: 'Nh???p th??ng tin', border: InputBorder.none),
                                                                  controller: mapNDDNCT[map.key]![i]['incurredText'],
                                                                  inputFormatters: [
                                                                    FilteringTextInputFormatter(RegExp("[0-9.-]"), allow: true),
                                                                  ],
                                                                  onChanged: (value) {
                                                                    setState(() {
                                                                      //mapNDDNCT[map.key]![i]['incurredText'].text = value;
                                                                      try {
                                                                        mapNDDNCT[map.key]![i]['incurredFee'] = double.parse(value);
                                                                      } catch (e) {
                                                                        mapNDDNCT[map.key]![i]['incurredFee'] = 0;
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
                                                                    .format(tinhTongTienTheoTts(mapNDDNCT[map.key]![i]['feeValue'], mapNDDNCT[map.key]![i]['arfareFee'],
                                                                        mapNDDNCT[map.key]![i]['incurredFee'], tinhChuKy(tuNgayMoiXuatCanh: mapNDDNCT[map.key]![i]['dateFrom'])))
                                                                    .toString()),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                    ],
                                                  )),
                                              Container(
                                                margin: EdgeInsets.only(top: 30),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      "T???ng ti???n : " +
                                                          NumberFormat.simpleCurrency(name: "USD", decimalDigits: 0)
                                                              .format(tinhTotalTheoNhom(
                                                                map.value,
                                                                tinhChuKy(tuNgayMoiXuatCanh: mapNDDNCT[map.key]!.first['dateFrom']),
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
                                ],
                              ),
                            )
                          else if (snapshot.hasError)
                            Text("Fail! ${snapshot.error}")
                          else if (!snapshot.hasData)
                            Center(
                              child: CircularProgressIndicator(),
                            ),
                        ],
                      );
                    }));
          } else if (listRule.hasError) {
            return Text('${listRule.error}');
          }
          return Center(
              child: Row(
            children: [Text("dsdasd"), CircularProgressIndicator()],
          ));
        });
  }
}
