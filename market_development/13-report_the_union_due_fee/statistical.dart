import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/format_date.dart';
import 'package:gentelella_flutter/widgets/forms/market_development/utils/funciton.dart';

import 'package:gentelella_flutter/widgets/ui/market_development/13-report_the_union_due_fee/xuatFileHoaDon.dart';

import 'package:jiffy/jiffy.dart';

import 'package:provider/provider.dart';
import '../../../../api.dart';
import '../../../../common/dynamic_table.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';
import '../../../../common/widgets_form.dart';

import '../../../../model/market_development/manage_fee_detail.dart';
import '../../../../model/market_development/nghiepdoan-thanhtoan.dart';
import '../../../../model/market_development/nghiepdoan_tts_xuat_canh.dart';

import '../../../../model/market_development/user.dart';
import '../../../../model/model.dart';
import '../../../utils/market_development.dart';

import "package:collection/collection.dart";

import '../7-order_management/xuat_file.dart';
import 'modal_send_email.dart';
import 'xuatFIleDoc.dart';

class Statistical extends StatefulWidget {
  final Function? func;
  Statistical({Key? key, this.func}) : super(key: key);

  @override
  State<Statistical> createState() => _StatisticalState();
}

class _StatisticalState extends State<Statistical> {
  String? dateFrom;
  String? dateTo;

  late List<User>? listUser = [];

  late Future<List<NghiepDoanThucTapSinhXuatCanh>> _futureListUnion;

  List<bool> _selected = []; // List này chứa trạng thái selected của data table

  DateTime selectedDate = DateTime.now();

  var body = {};
  var page = 1;
  var rowPerPage = 5;
  var totalElements = 0;
  var firstRow = 1, lastRow = 0;
  var rowCount = 0;
  var currentPage = 1;
  bool _setLoading = false;
  List<NghiepDoanThucTapSinhXuatCanh> listUnionObjectResult = [];
  List<NghiepDoanThucTapSinhXuatCanh> listUnionObjectResultSelected = [];
  List<dynamic> listIdUnionChecked = [];
  var mapDuLieuNghiepDoan;
  Future<List<NghiepDoanThanhToan>> getListNghiepDoanThanhThoan() async {
    var response = await httpGet("/api/nghiepdoan-thanhtoan/get/page?sort=id", context);

    var body = jsonDecode(response['body']);
    var content = [];

    if (response.containsKey("body")) {
      setState(() {
        content = body['content'];
      });
    }

    return content.map((e) {
      return NghiepDoanThanhToan.fromJson(e);
    }).toList();
  }

  bool checkDate(element, dateFromTime, dateToTime) {
    if (element.firstDueDate != null || element.nextDueDate != null) {
      if (element.firstDueDate != null && element.nextDueDate != null) {
        DateTime nextDueDate = DateTime.parse(element.nextDueDate!);
        if (dateFrom != null && dateTo != null) {
          if ((nextDueDate.isAfter(dateFromTime!) && nextDueDate.isBefore(dateToTime!)) ||
              nextDueDate.isAtSameMomentAs(dateFromTime) ||
              nextDueDate.isAtSameMomentAs(dateToTime!)) {
            return true;
          }
        }
        if (dateFrom != null && dateTo == null) {
          if ((nextDueDate.isAfter(dateFromTime!)) || nextDueDate.isAtSameMomentAs(dateFromTime)) {
            return true;
          }
        }
        if (dateFrom == null && dateTo != null) {
          if (nextDueDate.isBefore(dateToTime!) || nextDueDate.isAtSameMomentAs(dateToTime)) {
            return true;
          }
        }
      }
      if (element.firstDueDate == null && element.nextDueDate != null) {
        DateTime nextDueDate = DateTime.parse(element.nextDueDate!);
        if (dateFrom != null && dateTo != null) {
          if ((nextDueDate.isAfter(dateFromTime!) && nextDueDate.isBefore(dateToTime!)) ||
              nextDueDate.isAtSameMomentAs(dateFromTime) ||
              nextDueDate.isAtSameMomentAs(dateToTime!)) {
            return true;
          }
        }
        if (dateFrom != null && dateTo == null) {
          if ((nextDueDate.isAfter(dateFromTime!)) || nextDueDate.isAtSameMomentAs(dateFromTime)) {
            return true;
          }
        }
        if (dateFrom == null && dateTo != null) {
          if (nextDueDate.isBefore(dateToTime!) || nextDueDate.isAtSameMomentAs(dateToTime)) {
            return true;
          }
        }
      } else if (element.firstDueDate != null && element.nextDueDate == null) {
        DateTime nextDueDate = DateTime.parse(element.firstDueDate!);
        if (dateFrom != null && dateTo != null) {
          if ((nextDueDate.isAfter(dateFromTime!) && nextDueDate.isBefore(dateToTime!)) ||
              nextDueDate.isAtSameMomentAs(dateFromTime) ||
              nextDueDate.isAtSameMomentAs(dateToTime!)) {
            return true;
          }
        }
        if (dateFrom != null && dateTo == null) {
          if ((nextDueDate.isAfter(dateFromTime!)) || nextDueDate.isAtSameMomentAs(dateFromTime)) {
            return true;
          }
        }
        if (dateFrom == null && dateTo != null) {
          if (nextDueDate.isBefore(dateToTime!) || nextDueDate.isAtSameMomentAs(dateToTime)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  Future<List<NghiepDoanThucTapSinhXuatCanh>> getListUnionSearchBy(page, {fromDate, toDate}) async {
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }
    if (page < 1) {
      page = 0;
    }
    var response;

    String condition = "";
    if (fromDate != null) {
      condition += " chargeStartDate >: '$fromDate'";
    }
    if (toDate != null) {
      condition += " AND chargeStartDate <: '$toDate'";
    }

    response = await httpGet("/api/nghiepdoan/get/tts_xuatcanh", context);

    var body = jsonDecode(response['body']);
    var content = [];

    setState(() {
      currentPage = page + 1;
      content = body;
      List<NghiepDoanThucTapSinhXuatCanh> listResult = [];
      // totalElements = body["totalElements"];
      // lastRow = totalElements;
      // rowCount = totalElements;
      listResult = content.map((e) {
        return NghiepDoanThucTapSinhXuatCanh.fromJson(e);
      }).toList();
      int i = listResult.length;
      DateTime? dateFromTime;
      DateTime? dateToTime;
      if (dateFrom != null && dateTo != null) {
        dateFromTime = DateTime.parse(getDateInsertDB(dateFrom)!);
        dateToTime = DateTime.parse(getDateInsertDB(dateTo)!);
        listUnionObjectResult = listResult.where((element) => checkDate(element, dateFromTime, dateToTime)).skip(page * rowPerPage).take(rowPerPage).toList();
        totalElements = listUnionObjectResult.length;
        lastRow = listUnionObjectResult.length;
        rowCount = listUnionObjectResult.length;
      } else {
        totalElements = i;
        lastRow = listUnionObjectResult.length;
        rowCount = i;
        listUnionObjectResult = listResult.skip(page * rowPerPage).take(rowPerPage).toList();
      }

      _selected = List<bool>.generate(listUnionObjectResult.length, (int index) => false);
    });

    return content.map((e) {
      return NghiepDoanThucTapSinhXuatCanh.fromJson(e);
    }).toList();
  }

  tinhHanThuPhi(String? dateTime, int? chuKyThuPhi) {
    try {
      if (dateTime != null) {
        DateTime time = DateTime.parse(dateTime);
        DateTime timeAdd;
        timeAdd = time.add(new Duration(days: chuKyThuPhi ?? 0));
        // var string = FormatDate.formatDateddMMyy(timeAdd);
        return FormatDate.formatDateddMMyy(timeAdd);
      }
    } catch (_) {
      print("Ngoại lệ tinhHanThuPhi");
    }

    return "Chưa có ngày thu phí";
  }

  int countTTSDaXuatCanh(int id, List<User> list) {
    int count = 0;
    for (int i = 0; i < listUser!.length; i++) {
      if (id.toString() == list[i].order?.union?.id.toString() && list[i].ttsStatusId == 11) {
        count++;
      }
    }
    return count;
  }

  Future<List<User>> getAllUserIsDaXuatCanh({orgIdList}) async {
    var response;

    if (orgIdList != null) {
      String condition = " ";
      for (int i = 0; i < orgIdList.length; i++) {
        if (i == 0) {
          condition += "AND donhang.orgId IN (";
          condition += "${orgIdList[i]}";
        } else {
          condition += ",${orgIdList[i]}";
        }
        if (i == orgIdList.length - 1) {
          condition += ")";
        }
      }

      response = await httpGet("/api/nguoidung/get/page?filter=isTts:1 AND ttsStatusId:11 AND ttsTrangthai.active:1 $condition ", context);
    } else {
      response = await httpGet("/api/nguoidung/get/page?filter=isTts:1 AND ttsStatusId:11 AND ttsTrangthai.active:1", context);
    }

    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        // currentPage = page + 1;
        content = body['content'];
        // rowCount = body["totalElements"];
        // totalElements = body["totalElements"];
        // lastRow = totalElements;
      });
    }

    return content.map((e) {
      return User.fromJson(e);
    }).toList();
  }

  Future<List<User>> getAllUserIsDaXuatCanh1() async {
    var response;

    response = await httpGet("/api/nguoidung/get/page?filter=isTts:1 AND ttsStatusId:11 AND ttsTrangthai.active:1", context);

    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        // currentPage = page + 1;
        content = body['content'];
        // rowCount = body["totalElements"];
        // totalElements = body["totalElements"];
        // lastRow = totalElements;
        listUser = content.map((e) {
          return User.fromJson(e);
        }).toList();
      });
    }

    return content.map((e) {
      return User.fromJson(e);
    }).toList();
  }

  Future<List<dynamic>> getPhiQuanLyChiTiet({managerIdList}) async {
    var response;

    if (managerIdList != null) {
      String condition = " ";
      for (int i = 0; i < managerIdList.length; i++) {
        if (i == 0) {
          condition += " manageFeeId IN (";
          condition += "${managerIdList[i]}";
        } else {
          condition += ",${managerIdList[i]}";
        }
        if (i == managerIdList.length - 1) {
          condition += ")";
        }
      }
      response = await httpGet("/api/phiquanly-chitiet/get/page?filter=$condition ", context);
    } else {
      response = await httpGet("/api/phiquanly-chitiet/get/page", context);
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

  sendEmail(dynamic requestBody) async {
    try {
      var response = await httpPost(Uri.parse('/api/utils/post/mail'), requestBody, context);
      return response['body'].toString();
    } catch (e) {
      print("Fail! $e");
    }
    return "Gửi mail thất bại";
  }

  //Chỉ cần truyển vào listUser vì trong user đã có nghiện đoàn
  Map<int, List<User>> nhomDanhSachThucTapSinhTheoTungNghiepDoan(List<User> listUser) {
    Map<int, List<User>> map = {};
    for (var item in listUser) {
      if (item.order != null && item.order!.union != null) {
        if (!map.containsKey(item.order!.union!.id)) {
          List<User> listUserTrungNghiepDoan = [];
          listUserTrungNghiepDoan.add(item);
          map.putIfAbsent(item.order!.union!.id!, () => listUserTrungNghiepDoan);
        } else {
          map[item.order!.union!.id!]!.add(item);
        }
      }
    }
    return map;
  }

  @override
  void initState() {
    super.initState();
    _futureListUnion = getListUnionSearchBy(page);
    _selected = List<bool>.generate(listUnionObjectResult.length, (int index) => false);
    // initData();
  }

  List<ManageFeeDetail> layDanhSachPhiQuanLy(List<dynamic> listJsonPhiQuanLyChiTiet) {
    List<ManageFeeDetail> listPhiQuanLyChiTiet = [];
    for (int i = 0; i < listJsonPhiQuanLyChiTiet.length; i++) {
      ManageFeeDetail phiQuanLyChiTiet = ManageFeeDetail.fromJson(listJsonPhiQuanLyChiTiet[i]);
      listPhiQuanLyChiTiet.add(phiQuanLyChiTiet);
    }

    listPhiQuanLyChiTiet.sort(((a, b) => a.id.compareTo(b.id)));

    return listPhiQuanLyChiTiet;
  }

  themMoiPhiQuanLyChiTietVao(List<User> listTts, mapPhiQuanLyChiTiet) {
    // List<ManageFeeDetail> listManageFeeDetail = [];
    if (listTts.isNotEmpty && mapPhiQuanLyChiTiet.isNotEmpty) {
      for (var tts in listTts) {
        try {
          for (var phiQuanLyCha in mapPhiQuanLyChiTiet.keys) {
            if (tts.order != null && tts.order!.union != null) {
              if (tts.order!.union!.manageFeeId == phiQuanLyCha) {
                List<ManageFeeDetail> listPhiQuanLyChiTiet = layDanhSachPhiQuanLy(mapPhiQuanLyChiTiet[phiQuanLyCha]);
                // listManageFeeDetail.addAll(listPhiQuanLyChiTiet);
                tts.listPhiQuanLyChiTiet.addAll(listPhiQuanLyChiTiet);
              }
            }
          }
        } catch (e) {
          print("themMoiPhiQuanLyChiTietVao " + e.toString());
        }
      }
    }
  }

  bool kiemTraNgayHienTaiCoNamTrongKhoang(DateTime ngayXacNhanThongBao, DateTime tuNgay, DateTime denNgay) {
    if (ngayXacNhanThongBao.isAfter(tuNgay) && ngayXacNhanThongBao.isBefore(denNgay) && tuNgay.isBefore(denNgay)) {
      return true;
    }
    return false;
  }

  //int timeType : kiểu thời gian, double feeValue : phí quản lý, int effectTime:thời gian
  //Trả về số ngày theo kiểu thời gian
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

  layRaPhiQuanLyChiTietApDungSoVoiNgayHienTai(List<User> listTts, DateTime ngayXacNhanThongBao) {
    print(listTts);

    DateTime ngayBatDauCuaKhoang = DateTime.now();
    DateTime tuNgay = DateTime.now();
    DateTime denNgay = DateTime.now();
    DateTime ngayNhoNhat = DateTime.now();
    DateTime ngayLonNhat = DateTime.now();
    ManageFeeDetail? phiCuaNgayNhoNhat;
    ManageFeeDetail? phiCuaNgayLonNhat;

    for (int i = 0; i < listTts.length; i++) {
      //Ngày xuất cảnh khác null
      try {
        if (listTts[i].departureDate != null && listTts[i].listPhiQuanLyChiTiet.isNotEmpty) {
          int count = 0;
          List<ManageFeeDetail> listManagerDetail = [];
          for (var phiQuanLyChiTiet in listTts[i].listPhiQuanLyChiTiet) {
            if (count == 0) {
              //ngayNhoNhat
              ngayNhoNhat = DateTime.parse(listTts[i].departureDate.toString());
              //Phi cua khoang nho nhat

              phiCuaNgayNhoNhat = new ManageFeeDetail(
                  id: phiQuanLyChiTiet.id,
                  manageFeeId: phiQuanLyChiTiet.manageFeeId,
                  feeValue: phiQuanLyChiTiet.feeValue,
                  effectTime: phiQuanLyChiTiet.effectTime,
                  timeType: phiQuanLyChiTiet.timeType);

              //Ngày đầu tiên của chu kì
              ngayBatDauCuaKhoang = DateTime.parse(listTts[i].departureDate.toString());
              //
              tuNgay = ngayBatDauCuaKhoang;
              //
              denNgay = tuNgay.add(Duration(days: quyVeSoNgayTheoKieuThoiGian(phiQuanLyChiTiet.timeType, phiQuanLyChiTiet.feeValue, phiQuanLyChiTiet.effectTime)));
              //
              ngayBatDauCuaKhoang = denNgay;
            } else {
              //Cộng thêm
              tuNgay = ngayBatDauCuaKhoang;
              //
              denNgay = tuNgay.add(Duration(days: quyVeSoNgayTheoKieuThoiGian(phiQuanLyChiTiet.timeType, phiQuanLyChiTiet.feeValue, phiQuanLyChiTiet.effectTime)));
              //
              ngayBatDauCuaKhoang = denNgay;
              if (count == listTts[i].listPhiQuanLyChiTiet.length - 1) {
                //Ngay lon nhat
                ngayLonNhat = denNgay;
                //Phi cua khoang lon nhat
                phiCuaNgayLonNhat = new ManageFeeDetail(
                    id: phiQuanLyChiTiet.id,
                    manageFeeId: phiQuanLyChiTiet.manageFeeId,
                    feeValue: phiQuanLyChiTiet.feeValue,
                    effectTime: phiQuanLyChiTiet.effectTime,
                    timeType: phiQuanLyChiTiet.timeType);
              }
            }
            if (kiemTraNgayHienTaiCoNamTrongKhoang(ngayXacNhanThongBao, tuNgay, denNgay)) {
              listManagerDetail.add(phiQuanLyChiTiet);
              break;
            }
            count++;
          }

          if (listManagerDetail.isEmpty) {
            //Nếu là ngày xác nhận thông báo thì sex lấy phí quản lý của ngày nhỏ nhất
            if (ngayXacNhanThongBao.isBefore(ngayNhoNhat)) {
              listManagerDetail.add(phiCuaNgayNhoNhat!);
              listTts[i].listPhiQuanLyChiTiet = listManagerDetail;
            }
            if (ngayXacNhanThongBao.isAfter(ngayLonNhat)) {
              listManagerDetail.add(phiCuaNgayLonNhat!);
              listTts[i].listPhiQuanLyChiTiet = listManagerDetail;
            }
          } else {
            listTts[i].listPhiQuanLyChiTiet = listManagerDetail;
          }
        }
      } catch (e) {
        print("Lỗi1 " + e.toString());
      }
    }
  }

  layNgayGuiThongBaoGanNhatCuaTungNghiepDoan(List<NghiepDoanThanhToan> listNghiepDoanThanhToan) {
    //Sort theo chiều giảm giần
    List<NghiepDoanThanhToan> listNghiepDoanThanhToanDateMax = [];
    try {
      listNghiepDoanThanhToan.sort((a, b) {
        return DateTime.parse(b.requestDate!).compareTo(DateTime.parse(a.requestDate!));
      });
      listNghiepDoanThanhToanDateMax.add(listNghiepDoanThanhToan.first);
      listNghiepDoanThanhToan.clear();
      listNghiepDoanThanhToan.addAll(listNghiepDoanThanhToanDateMax);
    } catch (e) {
      print("Lỗi $e");
    }
  }

  //layNgayGuiThongBaoGanNhatCuaTungThucTapSinhTheoNgayXuatCanh(List<NghiepDoanThanhToan> listNghiepDoanThanhToan, List<User> listTts) {}

  //kiểm tra ngày xuất cảnh nằm trong khoảng ngày thông báo gần nhất cộng thêm chu kỳ
  kiemTraNgayXuatCanhNamTrongKhoangGanNhatNamCongChuKy(ngayXuatCanh, requestDate, int? chuKy) {}

  //List listNghiepDoanThanhToan là danh sách nghiệp đoàn có ngày thông báo gần nhất so với ngày hiện tại
  int layNgayGuiThongBaoGanNhatCuaTungThucTapSinhTheoNgayXuatCanh(String? requestDate, int? chuKy, String ngayXuatCanh) {
    try {
      if (chuKy != null) {
        if (requestDate != null) {
          DateTime ngayXuatCanhTime = DateTime.parse(ngayXuatCanh);
          DateTime ngayGuiThongBao = DateTime.parse(requestDate);
          DateTime ngayHanGuiThongBao = Jiffy(ngayGuiThongBao).add(months: chuKy).dateTime;

          if (((ngayXuatCanhTime.isAfter(ngayGuiThongBao) && ngayXuatCanhTime.isBefore(ngayHanGuiThongBao)) ||
                  ngayXuatCanhTime.isAtSameMomentAs(ngayGuiThongBao) ||
                  ngayXuatCanhTime.isAtSameMomentAs(ngayHanGuiThongBao)) &&
              ngayGuiThongBao.isBefore(ngayHanGuiThongBao)) {
            return layRaChuKyTrongKhoang(chuKy, ngayXuatCanhTime, ngayHanGuiThongBao);
          }
          // if ((ngayXuatCanhTime.isAfter(ngayHanGuiThongBao) && ngayXuatCanhTime.isBefore(ngayHanGuiThongBao))) {
          //   return layRaChuKyTrongKhoang(chuKy, ngayXuatCanhTime, ngayHanGuiThongBao);
          // }
        }
      }
    } catch (e) {
      print(e);
    }
    return chuKy!;
  }

  int layRaChuKyTrongKhoang(int? chuKy, DateTime ngayXuatCanh, DateTime ngayThongBaoGanNhatCongChuKy) {
    try {
      DateTime ngayXuatCanhTime = ngayXuatCanh;
      DateTime ngayThongBaoGanNhatCongChuKyTime = ngayThongBaoGanNhatCongChuKy;

      int year = ngayXuatCanhTime.year;
      int month = ngayXuatCanhTime.month;
      int day = ngayXuatCanhTime.day;
      String monthString = "";
      String dayString = "";
      if (month < 10) {
        monthString = "0" + month.toString();
      } else {
        monthString = month.toString();
      }

      String test = "$year-$monthString-01";
      print("$year-$monthString-$dayString");
      DateTime lamTronThanhDauThang = DateTime.parse("$year-$monthString-01");

      if (ngayXuatCanhTime.day >= 15) {
        int chuKy = (ngayThongBaoGanNhatCongChuKyTime.difference(lamTronThanhDauThang).inDays / 30).floor() - 1;

        return chuKy;
      } else {
        int chuKy = (ngayThongBaoGanNhatCongChuKyTime.difference(lamTronThanhDauThang).inDays / 30).floor();
        return chuKy;
      }
    } catch (e) {
      print(e);
    }
    return 0;
  }

  String congThemChuKy(String ngayThongBaoGanNhat, int chuKy) {
    try {
      DateTime time = DateTime.parse(ngayThongBaoGanNhat);
      DateTime ngayHanGuiThongBao = Jiffy(time).add(months: chuKy).dateTime;
      return FormatDate.formatDateInsertDBHHss(ngayHanGuiThongBao);
    } catch (e) {
      print(e);
    }
    return "";
  }

  quyVeDauThang(String? date) {
    try {
      DateTime ngayQuyVeDauThang = DateTime.parse(date!);

      DateTime ngayQuyVeDauThangTruoc = DateTime.now();
      DateTime ngayQuyVeDauThangSau = DateTime.now();

      int year = ngayQuyVeDauThang.year;
      int month = ngayQuyVeDauThang.month;

      String monthString = "";

      if (month < 10) {
        monthString = "0" + month.toString();
      } else {
        monthString = month.toString();
      }
      DateTime lamTronThanhDauThang = DateTime.parse("$year-$monthString-01");
      String dateDauThang = lamTronThanhDauThang.year.toString() + "-" + monthString + "-01";

      if (ngayQuyVeDauThang.day >= 15) {
        return congThemChuKy(dateDauThang, 1);
      } else {
        return lamTronThanhDauThang.year.toString() + "-" + monthString + "-01";
      }
    } catch (e) {
      print(e);
    }
  }

  capNhatDuLieuNgayThongBaoGanNhatChoMapNhomNghiepDoan(Map<int?, List<NghiepDoanThanhToan>> mapNghiepDoanThanhToan, List<User> listTts, orgId) {
    mapNghiepDoanThanhToan.forEach((key, listNghiepDoanThanhToan) {
      // if (key == orgId) {
      for (var item in listTts) {
        try {
          if (item.order!.union!.id == key) {
            // item.ngayThongBaoGanNhat = mapNghiepDoanThanhToan[key]!.first.dueDate;
            item.ngayThongBaoGanNhat = quyVeDauThang(mapNghiepDoanThanhToan[key]!.first.dueDate);
            item.chuKy = layNgayGuiThongBaoGanNhatCuaTungThucTapSinhTheoNgayXuatCanh(item.ngayThongBaoGanNhat, item.order!.union!.chargeCycleDate, item.departureDate!);
            item.ngayThongBaoGanNhatCongChuKy = congThemChuKy(item.ngayThongBaoGanNhat!, item.order!.union!.chargeCycleDate!);
          } else {
            item.ngayThongBaoGanNhat = item.order!.union!.chargeStartDate;
            item.chuKy = item.order!.union!.chargeCycleDate ?? 0;
            item.ngayThongBaoGanNhatCongChuKy = congThemChuKy(item.ngayThongBaoGanNhat!, item.chuKy!);
          }
        } catch (e) {
          print(e);
        }
      }
      // }
    });
  }

  initData() async {
    await getAllUserIsDaXuatCanh1();
  }

  hienThiHanTinhPhi(String? firstDueDate, String? nextDueDate) {
    try {
      if (firstDueDate == null && nextDueDate == null) {
        return "Chưa có hạn thu phí";
      }
      if (firstDueDate != null || nextDueDate != null) {
        if (firstDueDate != null && nextDueDate != null) {
          return getDateView(nextDueDate);
        }
        if (firstDueDate == null && nextDueDate != null) {
          return getDateView(nextDueDate);
        } else if (firstDueDate != null && nextDueDate == null) {
          return getDateView(firstDueDate);
        }
      }
    } catch (e) {
      print(e);
    }
    return "Chưa có hạn thu phí";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<NavigationModel, SecurityModel>(
        builder: (context, navigationModel, securityModel, child) => FutureBuilder<Object>(
            future: _futureListUnion,
            builder: (context, snapshot) {
              return ListView(
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
                              Row(
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
                                            // Text(' *',
                                            //     style: TextStyle(
                                            //       color: Color.fromARGB(255, 213, 6, 6),
                                            //       fontSize: 16,
                                            //       fontWeight: FontWeight.w600,
                                            //     )),
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
                                            // Text(' *',
                                            //     style: TextStyle(
                                            //       color: Color.fromARGB(255, 213, 6, 6),
                                            //       fontSize: 16,
                                            //       fontWeight: FontWeight.w600,
                                            //     )),
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
                              Padding(
                                  padding: const EdgeInsets.fromLTRB(50, 50, 20, 0),
                                  child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
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
                                          textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 20.0, letterSpacing: 2.0),
                                        ),
                                        onPressed: () async {
                                          onLoading(context);
                                          await Future.delayed(Duration(milliseconds: 200));
                                          Navigator.of(context).pop(true);
                                          if (dateFrom == null && dateTo == null) {
                                            getListUnionSearchBy(0);
                                            setState(() {});
                                            return;
                                          }
                                          if (dateFrom != null && dateTo != null) {
                                            DateTime? dateFromTime;
                                            DateTime? dateToTime;
                                            dateFromTime = DateTime.tryParse(dateReverse(dateFrom));
                                            dateToTime = DateTime.tryParse(dateReverse(dateTo));
                                            if (dateFromTime!.isAfter(dateToTime!)) {
                                              showToast(
                                                  context: context,
                                                  msg: "Từ ngày phải nhỏ hơn đến ngày",
                                                  color: Color.fromARGB(255, 255, 204, 0),
                                                  icon: Icon(Icons.warning_amber_rounded));
                                              return;
                                            } else {
                                              await getListUnionSearchBy(page - 1,
                                                  fromDate: FormatDate.formatDateddMMyy(dateFromTime), toDate: FormatDate.formatDateddMMyy(dateToTime));
                                            }
                                          } else {
                                            showToast(
                                                context: context, msg: "Nhập ngày tìm kiếm", color: Color.fromARGB(255, 255, 204, 0), icon: Icon(Icons.warning_amber_rounded));
                                            return;
                                          }
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
                                          textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 20.0, letterSpacing: 2.0),
                                        ),
                                        onPressed: () async {
                                          try {
                                            onLoading(context);
                                            List<User> listTTSDaXuatCanhTheoNghiepDoan = await getAllUserIsDaXuatCanh(orgIdList: listIdUnionChecked);

                                            var mapNhomNghiepDoan = nhomDanhSachThucTapSinhTheoTungNghiepDoan(listTTSDaXuatCanhTheoNghiepDoan);

                                            List<int> managerIdList = [];
                                            for (var itemValue in mapNhomNghiepDoan.values) {
                                              if (itemValue.first.order != null && itemValue.first.order!.union != null && itemValue.first.order!.union!.manageFeeId != null) {
                                                managerIdList.add(itemValue.first.order!.union!.manageFeeId!);
                                              }
                                            }
                                            var mapPhiQuanLyChiTiet = {};
                                            if (managerIdList.isNotEmpty) {
                                              List<dynamic> listChiTietPhiQuanLy = await getPhiQuanLyChiTiet(managerIdList: managerIdList);
                                              mapPhiQuanLyChiTiet = groupBy(listChiTietPhiQuanLy, (dynamic obj) => obj["manageFeeId"]);
                                            }
                                            mapNhomNghiepDoan.forEach((idNghiepDoan, listTts) {
                                              themMoiPhiQuanLyChiTietVao(listTts, mapPhiQuanLyChiTiet);
                                            });

                                            mapNhomNghiepDoan.forEach((idNghiepDoan, listTts) {
                                              layRaPhiQuanLyChiTietApDungSoVoiNgayHienTai(listTts, DateTime.parse('2025-01-01'));
                                              //layRaPhiQuanLyChiTietApDungSoVoiNgayHienTai(listTts, DateTime.now());
                                            });

                                            //Lẩy ra tất cả data của bảng nghiệp đoàn thanh toán

                                            List<NghiepDoanThanhToan> listNghiepDoanThanhToan = await getListNghiepDoanThanhThoan();
                                            //Trường hợp chưa có bản ghi nào trong nghiệp đoàn thanh toán
                                            if (listNghiepDoanThanhToan.isNotEmpty) {
                                              //Nhóm lại theo id nghiệp đoàn
                                              var mapNghiepDoanThanhToan = groupBy(listNghiepDoanThanhToan, (NghiepDoanThanhToan obj) => obj.unionObj!.id);

                                              //Lọc ra ngày gửi thông báo gần nhất của từng nghiệp đoàn
                                              mapNghiepDoanThanhToan.forEach((key, listNDTT) {
                                                layNgayGuiThongBaoGanNhatCuaTungNghiepDoan(listNDTT);
                                              });

                                              mapNhomNghiepDoan.forEach((key, listTts) {
                                                capNhatDuLieuNgayThongBaoGanNhatChoMapNhomNghiepDoan(mapNghiepDoanThanhToan, listTts, key);
                                              });
                                            } else {
                                              mapNhomNghiepDoan.forEach((orgId, listTts) {
                                                for (var tts in listTts) {
                                                  try {
                                                    tts.ngayThongBaoGanNhat = tts.order!.union!.chargeStartDate;
                                                    tts.chuKy = tts.order!.union!.chargeCycleDate != null ? (tts.order!.union!.chargeCycleDate! ~/ 30) : 0;
                                                  } catch (e) {
                                                    print(e);
                                                  }
                                                }
                                              });
                                            }

                                            print(mapNhomNghiepDoan);

                                            await exportFile1(listUnionObjectResultSelected, context, mapNhomNghiepDoan);
                                            //await xuatFileHoaDon(listUnionObjectResultSelected, mapNhomNghiepDoan);
                                            await exportFile1(listUnionObjectResultSelected, context, mapNhomNghiepDoan);
                                            await xuatFileDoc(listUnionObjectResult, {});
                                          } catch (e) {}
                                          Navigator.pop(context);

                                          showToast(context: context, msg: "Coming soon ^^", color: Colors.greenAccent, icon: Icon(Icons.abc));
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
                                      ),
                                    ),
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
                      borderRadius: borderRadiusContainer,
                      color: colorWhite,
                      boxShadow: [boxShadowContainer],
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
                              'Danh sách nghiệp đoàn đến hạn thu phí',
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
                        if (snapshot.hasData)
                          //Start Datatable
                          !_setLoading
                              ? Row(
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
                                          label: Text(
                                            'STT',
                                            style: titleTableData,
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Mã nghiệp đoàn',
                                            style: titleTableData,
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Tên nghiệp đoàn',
                                            style: titleTableData,
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Tổng số TTS đã xuất cảnh',
                                            style: titleTableData,
                                          ),
                                        ),
                                        // DataColumn(
                                        //   label: Text(
                                        //     'Hạn thu phí',
                                        //     style: titleTableData,
                                        //   ),
                                        // ),
                                        DataColumn(
                                          label: Text(
                                            'Thu phí',
                                            style: titleTableData,
                                          ),
                                        ),
                                      ],
                                      rows: <DataRow>[
                                        for (int i = 0; i < listUnionObjectResult.length; i++)
                                          DataRow(
                                            cells: <DataCell>[
                                              DataCell(
                                                Container(
                                                  width: (MediaQuery.of(context).size.width / 10) * 0.2,
                                                  child: SelectableText("${(currentPage - 1) * rowPerPage + i + 1}"),
                                                ),
                                              ),
                                              DataCell(
                                                Container(
                                                  width: (MediaQuery.of(context).size.width / 10) * 0.8,
                                                  child: SelectableText(listUnionObjectResult[i].orgCode ?? "Không có dữ liệu"),
                                                ),
                                              ),
                                              DataCell(
                                                Container(
                                                  width: (MediaQuery.of(context).size.width / 10) * 1,
                                                  child: SelectableText(listUnionObjectResult[i].orgName ?? "Không có dữ liệu"),
                                                ),
                                              ),
                                              DataCell(
                                                Container(
                                                  width: (MediaQuery.of(context).size.width / 10) * 1,
                                                  child: Center(child: SelectableText(listUnionObjectResult[i].totalTts.toString())),
                                                ),
                                              ),
                                              // DataCell(
                                              //   Container(
                                              //     width: (MediaQuery.of(context).size.width / 10) * 1,
                                              //     child: SelectableText(hienThiHanTinhPhi(listUnionObjectResult[i].firstDueDate, listUnionObjectResult[i].nextDueDate)),
                                              //   ),
                                              // ),
                                              DataCell(
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
                                                      textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 20.0, letterSpacing: 2.0),
                                                    ),
                                                    onPressed: () async {
                                                      //processing();
                                                      var respnseCheck = await httpGet(
                                                          "/api/nghiepdoan-denghi/get/page?filter=requestStatus:0 and orgId:${listUnionObjectResult[i].id} &size=1", context);
                                                      if (respnseCheck.containsKey("body")) {
                                                        var bodyCheck = jsonDecode(respnseCheck['body']);
                                                        print("object:${bodyCheck['totalElements']}");
                                                        if (bodyCheck['totalElements'] == 0) {
                                                          //Navigator.pop(context);
                                                          Provider.of<NavigationModel>(context, listen: false)
                                                              .add(pageUrl: "/chi-tiet-bao-cao-thu-phi/${listUnionObjectResult[i].id}");
                                                        } else {
                                                          Navigator.pop(context);
                                                          showToast(
                                                            context: context,
                                                            msg: "Tồn tại bản nháp, vui lòng hoàn thành",
                                                            color: Color.fromARGB(135, 250, 115, 36),
                                                            icon: const Icon(Icons.warning),
                                                          );
                                                        }
                                                      } else {
                                                        //Navigator.pop(context);
                                                        throw Exception('Không có data');
                                                      }
                                                      //
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
                                                        Text('Tạo biểu phí ', style: textButton),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                            selected: _selected[i],
                                            onSelectChanged: (bool? value) {
                                              setState(() {
                                                _selected[i] = value!;
                                                listUnionObjectResultSelected.clear();
                                                listIdUnionChecked.clear();
                                                for (int j = 0; j < _selected.length; j++) {
                                                  if (_selected[j]) {
                                                    listIdUnionChecked.add(listUnionObjectResult[j].id);
                                                    listUnionObjectResultSelected.add(listUnionObjectResult[j]);
                                                  }
                                                }

                                                print(listUnionObjectResultSelected.toList().toString());
                                              });
                                            },
                                          ),
                                      ],
                                    )),
                                  ],
                                )
                              : Center(
                                  child: CircularProgressIndicator(),
                                )
                        else if (snapshot.hasError)
                          Text("Fail! ${snapshot.error}")
                        else if (!snapshot.hasData)
                          Center(
                            child: CircularProgressIndicator(),
                          ),
                        //End Datatable
                        Container(
                          margin: const EdgeInsets.only(right: 50),
                          child: DynamicTablePagging(
                            rowCount,
                            currentPage,
                            rowPerPage,
                            pageChangeHandler: (page) {
                              setState(() {
                                getListUnionSearchBy(page - 1);
                              });
                            },
                            rowPerPageChangeHandler: (rowPerPage) {
                              setState(() {
                                this.rowPerPage = rowPerPage!;
                                if (dateFrom != null && dateTo != null) {
                                  DateTime? dateFromTime;
                                  DateTime? dateToTime;
                                  {
                                    dateFromTime = DateTime.tryParse(dateReverse(dateFrom));
                                    dateToTime = DateTime.tryParse(dateReverse(dateTo));
                                    getListUnionSearchBy(0, fromDate: FormatDate.formatDateddMMyy(dateFromTime!), toDate: FormatDate.formatDateddMMyy(dateToTime!));
                                  }
                                } else {
                                  getListUnionSearchBy(0);
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }));
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
}
