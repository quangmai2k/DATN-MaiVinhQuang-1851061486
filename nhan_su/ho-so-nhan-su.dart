// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'dart:html';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/model/model.dart';
import 'package:gentelella_flutter/widgets/forms/nhan_su/setting-data/userAAM.dart';
import 'package:gentelella_flutter/widgets/ui/nhan_su/sua-hsns.dart';
import 'package:gentelella_flutter/widgets/ui/nhan_su/view-hsns.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;
import '../../../api.dart';
import '../../../common/dynamic_table.dart';
import '../../../common/style.dart';
import '../../../common/toast.dart';
import '../../../common/widgets_form.dart';
import '../../forms/nhan_su/setting-data/depart.dart';
import '../../forms/nhan_su/setting-data/duty.dart';
import '../../forms/nhan_su/setting-data/team.dart';
import '../navigation.dart';

class HoSoNhanSu extends StatefulWidget {
  const HoSoNhanSu({Key? key}) : super(key: key);

  @override
  _HoSoNhanSuState createState() => _HoSoNhanSuState();
}

class _HoSoNhanSuState extends State<HoSoNhanSu> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: HoSoNhanSuBody());
  }
}

class HoSoNhanSuBody extends StatefulWidget {
  const HoSoNhanSuBody({Key? key}) : super(key: key);
  @override
  State<HoSoNhanSuBody> createState() => _HoSoNhanSuBodyState();
}

class _HoSoNhanSuBodyState extends State<HoSoNhanSuBody> {
  TextEditingController nhanVien = TextEditingController();
  TextEditingController sDT = TextEditingController();
  Map<int, String> isBlockedStatus = {
    2: 'Tất cả',
    0: 'Không',
    1: 'Có',
  };
  int? selectedIsBlocked = 2;
  int? selectedBP;
  Depart selectedBP1 = Depart(id: -1, departName: 'Tất cả');
  Future<List<Depart>> getPhongBan() async {
    late List<Depart> resultPhongBan;
    var response1 = await httpGet("/api/phongban/get/page?sort=id,asc&filter=parentId:0 and status:1", context);
    if (response1.containsKey("body")) {
      var body = jsonDecode(response1['body']);
      var content = [];
      setState(() {
        content = body['content'];
        resultPhongBan = content.map((e) {
          return Depart.fromJson(e);
        }).toList();
      });
      Depart all = new Depart(id: -1, departName: "Tất cả");
      resultPhongBan.insert(0, all);
    }
    return resultPhongBan;
  }

  bool checkBP = false;

  int? selectedVT;
  Duty selectedVT1 = Duty(id: -1, dutyName: 'Tất cả', departId: -1);
  Future<List<Duty>> getVaiTro(var ipBp) async {
    late List<Duty> resultVaiTro;
    if (ipBp == -1) ipBp = 0;
    var response = await httpGet("/api/vaitro/get/page?filter=departId:$ipBp and status:1", context);
    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        content = body['content'];
        resultVaiTro = content.map((e) {
          return Duty.fromJson(e);
        }).toList();
      });
      Duty all = new Duty(id: -1, dutyName: "Tất cả", departId: -1);
      resultVaiTro.insert(0, all);
    }
    return resultVaiTro;
  }

  Team selectedTeam = Team(id: 0, teamName: 'Tất cả');
  Future<List<Team>> getTeam(var ipBp) async {
    List<Team> resultTeam = [];
    var response2;
    if (ipBp != 0)
      response2 = await httpGet("/api/phongban/get/page?sort=id,asc&filter=parentId:$ipBp and id>2 and status:1", context);
    else
      response2 = await httpGet("/api/phongban/get/page?sort=id,asc&filter=parentId:10000 and id>2 and status:1", context);
    var body = jsonDecode(response2['body']);
    var content = [];
    if (response2.containsKey("body")) {
      setState(() {
        content = body['content'];
        resultTeam = content.map((e) {
          return Team.fromJson(e);
        }).toList();
      });
      int start = 0;
      while (resultTeam.length > start) {
        List<Team> abc = await getDoiNhomCon(resultTeam[start]);
        setState(() {
          resultTeam.addAll(abc);
        });
        start += 1;
      }
    }
    Team all = Team(id: 0, teamName: 'Tất cả');
    resultTeam.insert(0, all);
    return resultTeam;
  }

  Future<List<Team>> getDoiNhomCon(Team teamCon) async {
    List<Team> listPBCha = [];
    var response = await httpGet("/api/phongban/get/page?filter=parentId:${teamCon.id} and status:1", context);
    if (response.containsKey("body")) {
      var body = jsonDecode(response['body']);
      var content;
      content = body['content'];
      if (content.length > 0) {
        for (var element in content) {
          Team item = Team(
            id: element['id'] ?? 0,
            teamName: element['departName'] ?? "",
          );
          listPBCha.add(item);
        }
      }
      return listPBCha;
    }

    return listPBCha;
  }

  var body = {};
  var page = 1;
  var rowPerPage = 10;
  var totalElements = 0;
  var firstRow = 1, lastRow = 0;
  var rowCount = 0;
  var currentPage = 1;
  var tableIndex = 1;
  List<bool> isSwitched = [];
  List<UserAAM> listUserAAMResult = [];
  List<dynamic> listUserAAMEP = [];
  late Future<List<UserAAM>> _futureListUserAAM;
  String findHSNS = "";
  Future<List<UserAAM>> getListHSNS(page, String findHSNS) async {
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }
    if (page < 1) {
      page = 0;
    }
    var response;
    if (findHSNS == "") {
      response = await httpGet("/api/nguoidung/get/page?size=$rowPerPage&page=$page&filter=isAam:1 ", context);
    } else {
      response = await httpGet("/api/nguoidung/get/page?size=$rowPerPage&page=$page&filter=isAam:1 $findHSNS ", context);
    }
    // print(response);

    if (response.containsKey("body")) {
      var body = jsonDecode(response['body']);
      var content = [];
      setState(() {
        print("11111111");
        currentPage = page + 1;
        content = body['content'];
        rowCount = body["totalElements"];
        totalElements = body["totalElements"];
        lastRow = totalElements;

        listUserAAMResult = content.map((e) {
          return UserAAM.fromJson(e);
        }).toList();
        if (listUserAAMResult.length > 0) {
          var firstRow = (currentPage) * rowPerPage + 1;
          var lastRow = (currentPage + 1) * rowPerPage;
          if (lastRow > totalElements) {
            lastRow = totalElements;
          }
          tableIndex = (currentPage - 1) * rowPerPage + 1;
        }
        isSwitched = [];
        for (var item in listUserAAMResult) {
          if (item.isBlocked == 0)
            isSwitched.add(true);
          else
            isSwitched.add(false);
        }
      });
      listUserAAMEP = listUserAAMResult;
      return listUserAAMResult;
    }

    return listUserAAMResult;
  }

  Future<void> createExcel(var listUser) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    int stt = listUser.length - 1;
    sheet.getRangeByIndex(1, 1, 1 + stt, 24).cellStyle.fontSize = 12;

    sheet.getRangeByIndex(1, 1, 1 + stt, 24).cellStyle.fontName = "Times New Roman";
    sheet.getRangeByIndex(1, 1, 1 + stt, 24).cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByIndex(1, 1, 1 + stt, 24).cellStyle.vAlign = VAlignType.center;
    sheet.getRangeByIndex(1, 1, 1 + stt, 24).cellStyle.borders.all.lineStyle = LineStyle.thin;
    sheet.getRangeByIndex(1, 1, 1, 24).cellStyle.backColor = '#009c87';
    sheet.getRangeByIndex(1, 1, 1, 24).cellStyle.fontSize = 13;
    sheet.getRangeByIndex(1, 1, 1, 24).cellStyle.bold = true;
    sheet.getRangeByIndex(1, 1).rowHeight = 40;
    sheet.getRangeByIndex(2, 1, 1 + stt, 1).rowHeight = 25;
    sheet.getRangeByName('A1').columnWidth = 6.4;
    sheet.getRangeByName('B1').columnWidth = 14.3;
    sheet.getRangeByName('C1').columnWidth = 26.43;
    sheet.getRangeByName('D1').columnWidth = 10.3;
    sheet.getRangeByName('E1').columnWidth = 17.3;
    sheet.getRangeByName('F1').columnWidth = 22;
    sheet.getRangeByName('G1').columnWidth = 27.3;
    sheet.getRangeByName('H1').columnWidth = 15;
    sheet.getRangeByName('I1').columnWidth = 35;
    sheet.getRangeByName('J1').columnWidth = 16;
    sheet.getRangeByName('K1').columnWidth = 15;
    sheet.getRangeByName('L1').columnWidth = 32;
    sheet.getRangeByName('M1').columnWidth = 15;
    sheet.getRangeByName('N1').columnWidth = 86;
    sheet.getRangeByName('O1').columnWidth = 34;
    sheet.getRangeByName('P1').columnWidth = 20;
    sheet.getRangeByName('Q1').columnWidth = 20;
    sheet.getRangeByName('R1').columnWidth = 25;
    sheet.getRangeByName('S1').columnWidth = 35;
    sheet.getRangeByName('T1').columnWidth = 25;
    sheet.getRangeByName('U1').columnWidth = 15;
    sheet.getRangeByName('V1').columnWidth = 15;
    sheet.getRangeByName('W1').columnWidth = 20;
    sheet.getRangeByName('X1').columnWidth = 20;
    sheet.getRangeByName('A1').setText("STT");
    sheet.getRangeByName('B1').setText("Mã số NV");
    sheet.getRangeByName('C1').setText("Họ và tên");
    sheet.getRangeByName('D1').setText("Giới tính");
    sheet.getRangeByName('E1').setText("Ngày vào");
    sheet.getRangeByName('F1').setText("Vị trí");
    sheet.getRangeByName('G1').setText("Phòng ban");
    sheet.getRangeByName('H1').setText("SĐT");
    sheet.getRangeByName('I1').setText("Email");
    sheet.getRangeByName('J1').setText("Số CMT/CCCD");
    sheet.getRangeByName('K1').setText("Ngày cấp");
    sheet.getRangeByName('L1').setText("Nơi cấp");
    sheet.getRangeByName('M1').setText("Ngày sinh");
    sheet.getRangeByName('N1').setText("Địa chỉ thường trú");
    sheet.getRangeByName('O1').setText("Nhân viên tuyển dụng");
    sheet.getRangeByName('P1').setText("Đóng BHXH");
    sheet.getRangeByName('Q1').setText("MST TNCN");
    sheet.getRangeByName('R1').setText("STK");
    sheet.getRangeByName('S1').setText("Tên ngân hành");
    sheet.getRangeByName('T1').setText("Chi nhánh");
    sheet.getRangeByName('U1').setText("Tỉnh NB");
    sheet.getRangeByName('V1').setText("Máy tính");
    sheet.getRangeByName('W1').setText("Ghi chú");
    sheet.getRangeByName('X1').setText("Mã chấm công");
    sheet.autoFilters.filterRange = sheet.getRangeByName('A1:X${1 + stt}');
    for (var i = 1; i < listUser.length; i++) {
      sheet.getRangeByName('A${i + 1}').setNumber(i + 0);
      sheet.getRangeByName('B${i + 1}').setText(listUser[i].userCode);
      sheet.getRangeByName('C${i + 1}').setText(listUser[i].fullName);
      sheet.getRangeByName('D${i + 1}').setText((listUser[i].gender == 0) ? "Nữ" : "Nam");
      if (listUser[i].dateInCompany != "")
        sheet.getRangeByName('E${i + 1}').setText(DateFormat('dd-MM-yyyy').format(DateTime.parse(listUser[i].dateInCompany)));
      if (listUser[i].dutyName != "") sheet.getRangeByName('F${i + 1}').setText(listUser[i].dutyName);
      if (listUser[i].departName != "") sheet.getRangeByName('G${i + 1}').setText(listUser[i].departName);
      sheet.getRangeByName('H${i + 1}').setText(listUser[i].phone);
      sheet.getRangeByName('I${i + 1}').setText(listUser[i].email);
      sheet.getRangeByName('J${i + 1}').setText(listUser[i].idCardNo);
      if (listUser[i].issuedDate != "")
        sheet.getRangeByName('K${i + 1}').setText(DateFormat('dd-MM-yyyy').format(DateTime.parse(listUser[i].issuedDate)));
      sheet.getRangeByName('L${i + 1}').setText(listUser[i].issuedBy);
      if (listUser[i].birthDate != "")
        sheet.getRangeByName('M${i + 1}').setText(DateFormat('dd-MM-yyyy').format(DateTime.parse(listUser[i].birthDate)));
      sheet.getRangeByName('N${i + 1}').setText(listUser[i].address);
      sheet.getRangeByName('O${i + 1}').setText(listUser[i].nhansuTuyendungId != 0
          ? "${listUser[i].nhansuTuyendungUserCode} - ${listUser[i].nhansuTuyendungName}"
          : (listUser[i].hsSource));
      sheet.getRangeByName('P${i + 1}').setText(listUser[i].pnBhxh);
      sheet.getRangeByName('Q${i + 1}').setText(listUser[i].mst);
      sheet.getRangeByName('R${i + 1}').setText(listUser[i].bankNumber);
      sheet.getRangeByName('S${i + 1}').setText(listUser[i].bankName);
      sheet.getRangeByName('T${i + 1}').setText(listUser[i].bankBranch);
      sheet.getRangeByName('U${i + 1}').setText(listUser[i].nbProvince);
      sheet.getRangeByName('V${i + 1}').setText(listUser[i].device);
      sheet.getRangeByName('W${i + 1}').setText(listUser[i].note);
      sheet.getRangeByName('X${i + 1}').setText(listUser[i].timeKeepingCode);
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();
    if (kIsWeb) {
      AnchorElement(href: 'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
        ..setAttribute('download', 'Nhan_su_AAM.xlsx')
        ..click();
    }
  }

  postNotifi(String title, String content) {
    print("Thông báo đã bắn thành công");
    var body1 = {
      "title": title,
      "message": content,
    };
    httpPost("/api/push/tags/user_type/aam", body1, context);
  }

  @override
  void initState() {
    super.initState();
    _futureListUserAAM = getListHSNS(0, findHSNS);
  }

  void dispose() {
    nhanVien.dispose();
    sDT.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: userRule('/ho-so-nhan-su', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return Consumer2<NavigationModel, SecurityModel>(
            builder: (context, navigationModel, user, child) => ListView(
              controller: ScrollController(),
              children: [
                TitlePage(
                  listPreTitle: [
                    {'url': "/nhan-su", 'title': 'Dashboard'},
                  ],
                  content: 'Hồ sơ nhân sự',
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: verticalPaddingPage, horizontal: horizontalPaddingPage),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nhap thong tin
                      Container(
                        width: MediaQuery.of(context).size.width * 1,
                        decoration: BoxDecoration(
                          color: colorWhite,
                          borderRadius: borderRadiusContainer,
                          boxShadow: [boxShadowContainer],
                          border: borderAllContainerBox,
                        ),
                        padding: paddingBoxContainer,
                        child: Column(
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
                                  color: Color(0xff9aa5ce),
                                  size: 14,
                                ),
                              ],
                            ),
                            //Đường line
                            Container(
                              margin: marginTopBottomHorizontalLine,
                              child: Divider(
                                thickness: 1,
                                color: ColorHorizontalLine,
                              ),
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    child: TextFieldValidatedForm(
                                      type: 'None',
                                      height: 40,
                                      controller: nhanVien,
                                      label: 'Họ tên:',
                                      flexLable: 2,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 200),
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    child: TextFieldValidatedForm(
                                      type: 'None',
                                      height: 40,
                                      controller: sDT,
                                      label: 'SĐT:',
                                      flexLable: 2,
                                    ),
                                  ),
                                ),
                                Expanded(flex: 1, child: Container()),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 30),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text('Phòng ban:', style: titleWidgetBox),
                                        ),
                                        Expanded(
                                            flex: 5,
                                            child: Container(
                                              color: Colors.white,
                                              width: MediaQuery.of(context).size.width * 0.20,
                                              height: 40,
                                              child: DropdownSearch<Depart>(
                                                mode: Mode.MENU,
                                                maxHeight: 350,
                                                showSearchBox: true,
                                                onFind: (String? filter) => getPhongBan(),
                                                itemAsString: (Depart? u) => u!.departName,
                                                dropdownSearchDecoration: styleDropDown,
                                                selectedItem: selectedBP1,
                                                onChanged: (value) {
                                                  setState(() {
                                                    selectedBP = value!.id;
                                                    selectedBP1 = value;
                                                    selectedVT1 = Duty(id: -1, dutyName: "Tất cả", departId: -1);
                                                    print(selectedBP);
                                                    if (selectedBP != -1 && selectedBP != 1 && selectedBP != 2)
                                                      setState(() {
                                                        checkBP = true;
                                                      });
                                                    else
                                                      setState(() {
                                                        checkBP = false;
                                                      });

                                                    // if (selectedBP != -1) getDNTDChiTiet(selectedBP);
                                                  });
                                                },
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 200),
                                (checkBP)
                                    ? Expanded(
                                        flex: 3,
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 30),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Text('Vị trí:', style: titleWidgetBox),
                                              ),
                                              Expanded(
                                                  flex: 5,
                                                  child: Container(
                                                    color: Colors.white,
                                                    width: MediaQuery.of(context).size.width * 0.20,
                                                    height: 40,
                                                    child: DropdownSearch<Duty>(
                                                      mode: Mode.MENU,
                                                      selectedItem: selectedVT1,
                                                      showSearchBox: true,
                                                      onFind: (String? filter) => getVaiTro(selectedBP ?? 0),
                                                      itemAsString: (Duty? u) => u!.dutyName,
                                                      dropdownSearchDecoration: styleDropDown,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          selectedVT = value!.id;
                                                          selectedVT1 = value;
                                                          print(selectedVT);

                                                          // widget.formData!["dutyId"] = selectedVT;
                                                        });
                                                      },
                                                    ),
                                                  ))
                                            ],
                                          ),
                                        ),
                                      )
                                    : Expanded(
                                        flex: 3,
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 30),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Text('Trạng thái khóa:', style: titleWidgetBox),
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: Container(
                                                  color: Colors.white,
                                                  width: MediaQuery.of(context).size.width * 0.20,
                                                  // width: MediaQuery.of(context).size.width * 0.15,
                                                  height: 40,
                                                  child: DropdownButtonHideUnderline(
                                                    child: DropdownButton2(
                                                      dropdownMaxHeight: 250,
                                                      items: isBlockedStatus.entries
                                                          .map((item) => DropdownMenuItem<int>(value: item.key, child: Text(item.value)))
                                                          .toList(),
                                                      value: selectedIsBlocked,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          selectedIsBlocked = value as int;
                                                        });
                                                      },
                                                      buttonHeight: 40,
                                                      itemHeight: 40,
                                                      dropdownDecoration:
                                                          BoxDecoration(border: Border.all(color: const Color.fromRGBO(216, 218, 229, 1))),
                                                      buttonDecoration: BoxDecoration(border: Border.all(width: 0.5, style: BorderStyle.solid)),
                                                      buttonElevation: 0,
                                                      buttonPadding: const EdgeInsets.only(left: 14, right: 14),
                                                      itemPadding: const EdgeInsets.only(left: 14, right: 14),
                                                      dropdownElevation: 5,
                                                      focusColor: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                Expanded(flex: 1, child: Container()),
                              ],
                            ),
                            (checkBP)
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 30),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Text('Phòng:', style: titleWidgetBox),
                                              ),
                                              Expanded(
                                                  flex: 5,
                                                  child: Container(
                                                    color: Colors.white,
                                                    width: MediaQuery.of(context).size.width * 0.20,
                                                    height: 40,
                                                    child: DropdownSearch<Team>(
                                                      maxHeight: 350,
                                                      mode: Mode.MENU,
                                                      showSearchBox: true,
                                                      onFind: (String? filter) => getTeam(selectedBP ?? 0),
                                                      itemAsString: (Team? u) => u!.teamName,
                                                      dropdownSearchDecoration: styleDropDown,
                                                      selectedItem: selectedTeam,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          selectedTeam = value!;
                                                        });
                                                      },
                                                    ),
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 200),
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 30),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Text('Trạng thái khóa:', style: titleWidgetBox),
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: Container(
                                                  color: Colors.white,
                                                  width: MediaQuery.of(context).size.width * 0.20,
                                                  // width: MediaQuery.of(context).size.width * 0.15,
                                                  height: 40,
                                                  child: DropdownButtonHideUnderline(
                                                    child: DropdownButton2(
                                                      dropdownMaxHeight: 250,
                                                      items: isBlockedStatus.entries
                                                          .map((item) => DropdownMenuItem<int>(value: item.key, child: Text(item.value)))
                                                          .toList(),
                                                      value: selectedIsBlocked,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          selectedIsBlocked = value as int;
                                                        });
                                                      },
                                                      buttonHeight: 40,
                                                      itemHeight: 40,
                                                      dropdownDecoration:
                                                          BoxDecoration(border: Border.all(color: const Color.fromRGBO(216, 218, 229, 1))),
                                                      buttonDecoration: BoxDecoration(border: Border.all(width: 0.5, style: BorderStyle.solid)),
                                                      buttonElevation: 0,
                                                      buttonPadding: const EdgeInsets.only(left: 14, right: 14),
                                                      itemPadding: const EdgeInsets.only(left: 14, right: 14),
                                                      dropdownElevation: 5,
                                                      focusColor: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(flex: 1, child: Container()),
                                    ],
                                  )
                                : Row(),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  getRule(listRule.data, Role.Xem, context)
                                      ? Container(
                                          margin: EdgeInsets.only(left: 20),
                                          child: TextButton(
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
                                              textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                            ),
                                            onPressed: () {
                                              findHSNS = "";
                                              var nhanVien1 = "";
                                              var phone = "";
                                              var idPhongBan = "";
                                              var isBlockedSearch = "";

                                              // and fullName~'*Thái*' and phone~'*0631*' and departId:10 and dutyId:16
                                              if (nhanVien.text != "")
                                                nhanVien1 = "and fullName~'*${nhanVien.text}*' ";
                                              else
                                                nhanVien1 = "";
                                              if (sDT.text != "") {
                                                phone = "and phone~'*${sDT.text}*' ";
                                                var check = int.tryParse(sDT.text);
                                                if (check == null)
                                                  showToast(
                                                    context: context,
                                                    msg: "Định dạng SĐT không đúng",
                                                    color: colorOrange,
                                                    icon: const Icon(Icons.warning),
                                                  );
                                              } else
                                                phone = "";
                                              if (selectedBP != null && selectedBP != -1) {
                                                if (selectedVT != null && selectedVT != -1) {
                                                  if (selectedTeam.id == 0)
                                                    idPhongBan = "and departId:$selectedBP and dutyId:$selectedVT ";
                                                  else
                                                    idPhongBan = "and departId:$selectedBP and teamId:${selectedTeam.id} and dutyId:$selectedVT ";
                                                } else {
                                                  if (selectedTeam.id == 0)
                                                    idPhongBan = "and departId:$selectedBP ";
                                                  else
                                                    idPhongBan = "and departId:$selectedBP and teamId:${selectedTeam.id} ";
                                                }
                                              } else
                                                idPhongBan = "";
                                              if (selectedIsBlocked != 2)
                                                isBlockedSearch = "and isBlocked:$selectedIsBlocked ";
                                              else
                                                isBlockedSearch = "";
                                              //
                                              findHSNS = nhanVien1 + phone + idPhongBan + isBlockedSearch;
                                              getListHSNS(0, findHSNS);
                                            },
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.search,
                                                  color: colorWhite,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text('Tìm kiếm', style: textButton),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  Container(
                                    margin: marginLeftBtn,
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        padding: paddingBtn,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: borderRadiusBtn,
                                        ),
                                        backgroundColor: backgroundColorBtn,
                                        primary: Theme.of(context).iconTheme.color,
                                        textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                      ),
                                      onPressed: () {
                                        Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/them-moi-hsns");
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.add,
                                            color: colorWhite,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text('Thêm mới', style: textButton),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: marginLeftBtn,
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        padding: paddingBtn,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: borderRadiusBtn,
                                        ),
                                        backgroundColor: (listUserAAMEP.length > 0) ? backgroundColorBtn : Color.fromARGB(255, 197, 197, 197),
                                        primary: Theme.of(context).iconTheme.color,
                                        textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                      ),
                                      onPressed: (listUserAAMEP.length > 0)
                                          ? () async {
                                              processing();
                                              listUserAAMEP = [];
                                              var responseEP = await httpGet(
                                                  "/api/nguoidung/get/page?sort=departId&sort=vaitro.level,desc&filter=isAam:1 and isBlocked:0 $findHSNS&sort=id",
                                                  context);
                                              if (responseEP.containsKey("body")) {
                                                var body = jsonDecode(responseEP['body']);
                                                var content = body['content'];
                                                setState(() {
                                                  listUserAAMEP = content.map((e) {
                                                    return UserAAM.fromJson(e);
                                                  }).toList();
                                                });
                                                for (var element in listUserAAMEP) {
                                                  if (element.nhansuTuyendungId != 0) {
                                                    var response =
                                                        await httpGet("/api/nguoidung/get/profile?filter=id:${element.nhansuTuyendungId}", context);
                                                    if (response.containsKey("body")) {
                                                      var body = jsonDecode(response['body']);
                                                      element.nhansuTuyendungName = body['fullName'] ?? "";
                                                      element.nhansuTuyendungUserCode = body['userCode'] ?? "";
                                                    }
                                                  }
                                                }
                                                if (findHSNS != "") listUserAAMEP.insert(0, UserAAM());
                                                await createExcel(listUserAAMEP);
                                              }
                                              Navigator.pop(context);
                                            }
                                          : null,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.download,
                                            color: colorWhite,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text('Xuất file', style: textButton),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: backgroundPage,
                  padding: EdgeInsets.only(left: 25, right: 25),
                  child: Container(
                      width: MediaQuery.of(context).size.width * 1,
                      decoration: BoxDecoration(
                        color: colorWhite,
                        borderRadius: borderRadiusContainer,
                        boxShadow: [boxShadowContainer],
                        border: borderAllContainerBox,
                      ),
                      padding: paddingBoxContainer,
                      child: Column(
                        children: [
                          FutureBuilder(
                            future: _futureListUserAAM,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                            child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Thông tin hồ sơ nhân sự',
                                                  style: titleBox,
                                                ),
                                              ],
                                            ),
                                            Container(
                                              margin: marginTopBottomHorizontalLine,
                                              child: Divider(
                                                thickness: 1,
                                                color: ColorHorizontalLine,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                    child: DataTable(
                                                  columnSpacing: 5,
                                                  showCheckboxColumn: false,
                                                  columns: [
                                                    DataColumn(label: Container(width: 25, child: Text('STT', style: titleTableData))),
                                                    DataColumn(
                                                        label: Container(
                                                      child: Text('Mã Nhân viên', style: titleTableData),
                                                    )),
                                                    DataColumn(
                                                        label: Center(
                                                      child: Text('Họ và tên', style: titleTableData),
                                                    )),
                                                    DataColumn(label: Text('Giới\ntính', style: titleTableData)),
                                                    DataColumn(label: Text('Ngày vào', style: titleTableData)),
                                                    DataColumn(label: Text('SĐT', style: titleTableData)),
                                                    DataColumn(label: Text('Vị trí', style: titleTableData)),
                                                    DataColumn(label: Text('Phòng ban', style: titleTableData)),
                                                    DataColumn(label: Text('Hành động', style: titleTableData)),
                                                  ],
                                                  rows: <DataRow>[
                                                    for (int i = 0; i < listUserAAMResult.length; i++)
                                                      DataRow(
                                                        cells: <DataCell>[
                                                          DataCell(Text(" ${tableIndex + i}")),
                                                          DataCell(
                                                            SelectableText(listUserAAMResult[i].userCode.toString(), style: bangDuLieu),
                                                          ),
                                                          DataCell(
                                                            SelectableText(listUserAAMResult[i].fullName.toString(), style: bangDuLieu),
                                                          ),

                                                          DataCell(
                                                            SelectableText(
                                                                (listUserAAMResult[i].gender.toString() == "1")
                                                                    ? "Nam"
                                                                    : (listUserAAMResult[i].gender.toString() == "0")
                                                                        ? "Nữ"
                                                                        : "Khác",
                                                                style: bangDuLieu),
                                                          ),
                                                          DataCell(
                                                            SelectableText(
                                                                (listUserAAMResult[i].dateInCompany != "")
                                                                    ? DateFormat('dd-MM-yyyy').format(
                                                                        DateTime.parse(listUserAAMResult[i].dateInCompany.toString()).toLocal())
                                                                    : "",
                                                                style: bangDuLieu),
                                                          ),
                                                          DataCell(
                                                            SelectableText(listUserAAMResult[i].phone.toString(), style: bangDuLieu),
                                                          ),
                                                          DataCell(
                                                            SelectableText(listUserAAMResult[i].dutyName.toString(), style: bangDuLieu),
                                                          ),
                                                          (listUserAAMResult[i].teamName != "")
                                                              ? DataCell(
                                                                  Column(
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      SelectableText(listUserAAMResult[i].departName.toString(), style: bangDuLieu),
                                                                      SelectableText(listUserAAMResult[i].teamName.toString(), style: bangDuLieu),
                                                                    ],
                                                                  ),
                                                                )
                                                              : DataCell(
                                                                  SelectableText(listUserAAMResult[i].departName.toString(), style: bangDuLieu),
                                                                ),
                                                          DataCell(Row(
                                                            children: [
                                                              getRule(listRule.data, Role.Xem, context)
                                                                  ? Tooltip(
                                                                      message: "Xem",
                                                                      textStyle: TextStyle(fontSize: 15, color: colorWhite),
                                                                      verticalOffset: 15,
                                                                      child: Consumer<NavigationModel>(
                                                                        builder: (context, navigationModel, child) => Container(
                                                                            margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                                            child: InkWell(
                                                                                onTap: () {
                                                                                  Navigator.push(
                                                                                    context,
                                                                                    MaterialPageRoute(
                                                                                        builder: (context) =>
                                                                                            ViewHSNSBody(idHSNS: listUserAAMResult[i].id.toString())),
                                                                                  );
                                                                                },
                                                                                child: Icon(Icons.visibility))),
                                                                      ),
                                                                    )
                                                                  : Text(""),
                                                              Tooltip(
                                                                message: "Sửa",
                                                                textStyle: TextStyle(fontSize: 15, color: colorWhite),
                                                                verticalOffset: 15,
                                                                child: Consumer<NavigationModel>(
                                                                  builder: (context, navigationModel, child) => Container(
                                                                      margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                      child: InkWell(
                                                                          onTap: () {
                                                                            Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                  builder: (context) => Updatehsns(
                                                                                        idHSNS: listUserAAMResult[i].id.toString(),
                                                                                        userAAM: listUserAAMResult[i],
                                                                                        callBack: (value) {
                                                                                          setState(() {
                                                                                            listUserAAMResult[i] = value;
                                                                                          });
                                                                                        },
                                                                                      )),
                                                                            );
                                                                            // navigationModel.add(
                                                                            //     pageUrl: ("/sua-hsns" + "/${listUserAAMResult[i].id}"));
                                                                          },
                                                                          child: Icon(
                                                                            Icons.edit_calendar,
                                                                            color: mainColorPage,
                                                                          ))),
                                                                ),
                                                              ),
                                                              // (user.userLoginCurren['departId'] == 2 || user.userLoginCurren['departId'] == 1)
                                                              //     ? Consumer<NavigationModel>(
                                                              //         builder: (context, navigationModel, child) => Container(
                                                              //             margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                              //             child: InkWell(
                                                              //                 onTap: () {
                                                              //                   Navigator.push(
                                                              //                     context,
                                                              //                     MaterialPageRoute(
                                                              //                         builder: (context) =>
                                                              //                             Updatehsns(idHSNS: listUserAAMResult[i].id.toString())),
                                                              //                   );
                                                              //                   // navigationModel.add(
                                                              //                   //     pageUrl: ("/sua-hsns" + "/${listUserAAMResult[i].id}"));
                                                              //                 },
                                                              //                 child: Icon(
                                                              //                   Icons.edit_calendar,
                                                              //                   color: mainColorPage,
                                                              //                 ))),
                                                              //       )
                                                              //     : (user.userLoginCurren['id'] == listUserAAMResult[i].id ||
                                                              //             user.userLoginCurren['id'] == listUserAAMResult[i].nhansuTuyendungId)
                                                              //         ? Consumer<NavigationModel>(
                                                              //             builder: (context, navigationModel, child) => Container(
                                                              //                 margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                              //                 child: InkWell(
                                                              //                     onTap: () {
                                                              //                       navigationModel.add(
                                                              //                           pageUrl: ("/sua-hsns" + "/${listUserAAMResult[i].id}"));
                                                              //                     },
                                                              //                     child: Icon(
                                                              //                       Icons.edit_calendar,
                                                              //                       color: mainColorPage,
                                                              //                     ))),
                                                              //           )
                                                              //         : (user.userLoginCurren['vaitro'] != null &&
                                                              //                 user.userLoginCurren['vaitro']['level'] != 0)
                                                              //             ? Consumer<NavigationModel>(
                                                              //                 builder: (context, navigationModel, child) => Container(
                                                              //                     margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                              //                     child: InkWell(
                                                              //                         onTap: () {
                                                              //                           navigationModel.add(
                                                              //                               pageUrl: ("/sua-hsns" + "/${listUserAAMResult[i].id}"));
                                                              //                         },
                                                              //                         child: Icon(
                                                              //                           Icons.edit_calendar,
                                                              //                           color: mainColorPage,
                                                              //                         ))),
                                                              //               )
                                                              //             : Text(""),
                                                              (user.userLoginCurren['departId'] == 2 ||
                                                                      user.userLoginCurren['departId'] == 1 ||
                                                                      (user.userLoginCurren['vaitro'] != null &&
                                                                          user.userLoginCurren['vaitro']['level'] != 0) ||
                                                                      (user.userLoginCurren['id'] == listUserAAMResult[i].nhansuTuyendungId))
                                                                  ? Container(
                                                                      child: Tooltip(
                                                                          message: (listUserAAMResult[i].isBlocked == 0) ? 'Hoạt động' : 'Đã khóa',
                                                                          textStyle: const TextStyle(fontSize: 15, color: Colors.white),
                                                                          verticalOffset: 15,
                                                                          decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(25),
                                                                            color:
                                                                                (listUserAAMResult[i].isBlocked == 0) ? mainColorPage : colorOrange,
                                                                          ),
                                                                          child: Switch(
                                                                            onChanged: (value) async {
                                                                              setState(() {
                                                                                isSwitched[i] = value;
                                                                              });
                                                                              if (isSwitched[i] == false) {
                                                                                TextEditingController blockNote = TextEditingController();
                                                                                blockNote.text = "";
                                                                                await showDialog(
                                                                                    context: context,
                                                                                    builder: (BuildContext context) => AlertDialog(
                                                                                          title: Row(
                                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                              children: [
                                                                                                SizedBox(
                                                                                                  child: Row(
                                                                                                    children: [
                                                                                                      Container(
                                                                                                        width: 40,
                                                                                                        height: 40,
                                                                                                        child:
                                                                                                            Image.asset('assets/images/logoAAM.png'),
                                                                                                        margin: EdgeInsets.only(right: 10),
                                                                                                      ),
                                                                                                      Text(
                                                                                                        'Xác nhận khóa nhân sự',
                                                                                                        style: titleAlertDialog,
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                                IconButton(
                                                                                                  onPressed: () => {Navigator.pop(context)},
                                                                                                  icon: Icon(
                                                                                                    Icons.close,
                                                                                                  ),
                                                                                                ),
                                                                                              ]),
                                                                                          //content
                                                                                          content: Container(
                                                                                            width: 400,
                                                                                            height: 200,
                                                                                            child: Column(
                                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                                              children: [
                                                                                                //đường line
                                                                                                Row(
                                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                                  children: [
                                                                                                    Text(
                                                                                                        "${listUserAAMResult[i].userCode} - ${listUserAAMResult[i].fullName}")
                                                                                                  ],
                                                                                                ),
                                                                                                Container(
                                                                                                  height: 150,
                                                                                                  child: Column(
                                                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                    children: [
                                                                                                      Row(
                                                                                                        children: [
                                                                                                          Text('Lý do khóa:', style: titleWidgetBox),
                                                                                                          Text("*",
                                                                                                              style: TextStyle(
                                                                                                                color: Colors.red,
                                                                                                                fontSize: 16,
                                                                                                              )),
                                                                                                        ],
                                                                                                      ),
                                                                                                      SizedBox(
                                                                                                        height: 20,
                                                                                                      ),
                                                                                                      TextField(
                                                                                                        controller: blockNote,
                                                                                                        maxLines: 5,
                                                                                                        minLines: 3,
                                                                                                        decoration: InputDecoration(
                                                                                                          border: OutlineInputBorder(
                                                                                                            borderRadius:
                                                                                                                BorderRadius.all(Radius.circular(0)),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                          //actions
                                                                                          actions: [
                                                                                            ElevatedButton(
                                                                                              onPressed: () {
                                                                                                Navigator.pop(context);
                                                                                              },
                                                                                              child: Text('Hủy'),
                                                                                              style: ElevatedButton.styleFrom(
                                                                                                primary: colorOrange,
                                                                                                onPrimary: colorWhite,
                                                                                                elevation: 3,
                                                                                                minimumSize: Size(100, 40),
                                                                                              ),
                                                                                            ),
                                                                                            ElevatedButton(
                                                                                              onPressed: () async {
                                                                                                processing();
                                                                                                if (blockNote.text != "") {
                                                                                                  var result;
                                                                                                  var request = {
                                                                                                    "departId": listUserAAMResult[i].departId,
                                                                                                    "timeKeepingCode":
                                                                                                        listUserAAMResult[i].timeKeepingCode,
                                                                                                    "isAam": 1,
                                                                                                    "active": 1,
                                                                                                    "isBlocked": 1,
                                                                                                    "blockedReason": blockNote.text
                                                                                                  };
                                                                                                  var response = await httpPut(
                                                                                                      "/api/nguoidung/put/${listUserAAMResult[i].id}",
                                                                                                      request,
                                                                                                      context);
                                                                                                  // print(response);
                                                                                                  if (response.containsKey("body")) {
                                                                                                    setState(() {
                                                                                                      result = jsonDecode(response["body"]);
                                                                                                    });
                                                                                                    print("result:$result");
                                                                                                    if (result.keys.first == "1") {
                                                                                                      Navigator.pop(context);
                                                                                                      Navigator.pop(context);
                                                                                                      showToast(
                                                                                                          context: context,
                                                                                                          msg:
                                                                                                              "Đã khóa nhân sự ${listUserAAMResult[i].userCode} - ${listUserAAMResult[i].fullName}",
                                                                                                          color: mainColorPage,
                                                                                                          icon: const Icon(Icons.done),
                                                                                                          timeHint: 2);
                                                                                                      postNotifi("Hệ thống thông báo",
                                                                                                          "Đã khóa nhân sự ${listUserAAMResult[i].userCode} - ${listUserAAMResult[i].fullName}");
                                                                                                    } else {
                                                                                                      Navigator.pop(context);
                                                                                                      showToast(
                                                                                                          context: context,
                                                                                                          msg: "${result[result.keys.first]}",
                                                                                                          color: colorOrange,
                                                                                                          icon: const Icon(Icons.warning),
                                                                                                          timeHint: 2);
                                                                                                    }
                                                                                                  } else {
                                                                                                    Navigator.pop(context);
                                                                                                  }
                                                                                                } else {
                                                                                                  Navigator.pop(context);
                                                                                                  showToast(
                                                                                                    context: context,
                                                                                                    msg: "Nhập lý do khóa",
                                                                                                    color: colorOrange,
                                                                                                    icon: const Icon(Icons.warning),
                                                                                                  );
                                                                                                }
                                                                                              },
                                                                                              child: Text(
                                                                                                'Xác nhận',
                                                                                                style: TextStyle(),
                                                                                              ),
                                                                                              style: ElevatedButton.styleFrom(
                                                                                                primary: mainColorPage,
                                                                                                onPrimary: colorWhite,
                                                                                                elevation: 3,
                                                                                                minimumSize: Size(100, 40),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ));
                                                                                setState(() {
                                                                                  getListHSNS(currentPage - 1, findHSNS);
                                                                                });
                                                                              } else {
                                                                                TextEditingController blockNote = TextEditingController();
                                                                                blockNote.text = "";
                                                                                await showDialog(
                                                                                    context: context,
                                                                                    builder: (BuildContext context) => AlertDialog(
                                                                                          title: Row(
                                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                              children: [
                                                                                                SizedBox(
                                                                                                  child: Row(
                                                                                                    children: [
                                                                                                      Container(
                                                                                                        width: 40,
                                                                                                        height: 40,
                                                                                                        child:
                                                                                                            Image.asset('assets/images/logoAAM.png'),
                                                                                                        margin: EdgeInsets.only(right: 10),
                                                                                                      ),
                                                                                                      Text(
                                                                                                        'Xác nhận mở khóa nhân sự',
                                                                                                        style: titleAlertDialog,
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                                IconButton(
                                                                                                  onPressed: () => {Navigator.pop(context)},
                                                                                                  icon: Icon(
                                                                                                    Icons.close,
                                                                                                  ),
                                                                                                ),
                                                                                              ]),
                                                                                          //content
                                                                                          content: Container(
                                                                                            width: 400,
                                                                                            height: 100,
                                                                                            child: Column(
                                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                                              children: [
                                                                                                //đường line
                                                                                                Row(
                                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                                  children: [
                                                                                                    Text(
                                                                                                        "${listUserAAMResult[i].userCode} - ${listUserAAMResult[i].fullName}")
                                                                                                  ],
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                          //actions
                                                                                          actions: [
                                                                                            ElevatedButton(
                                                                                              onPressed: () {
                                                                                                Navigator.pop(context);
                                                                                              },
                                                                                              child: Text('Hủy'),
                                                                                              style: ElevatedButton.styleFrom(
                                                                                                primary: colorOrange,
                                                                                                onPrimary: colorWhite,
                                                                                                elevation: 3,
                                                                                                minimumSize: Size(100, 40),
                                                                                              ),
                                                                                            ),
                                                                                            ElevatedButton(
                                                                                              onPressed: () async {
                                                                                                processing();
                                                                                                var result;
                                                                                                var request = {
                                                                                                  "departId": listUserAAMResult[i].departId,
                                                                                                  "timeKeepingCode":
                                                                                                      listUserAAMResult[i].timeKeepingCode,
                                                                                                  "isAam": 1,
                                                                                                  "active": 1,
                                                                                                  "isBlocked": 0,
                                                                                                  "blockedReason": ""
                                                                                                };
                                                                                                var response = await httpPut(
                                                                                                    "/api/nguoidung/put/${listUserAAMResult[i].id}",
                                                                                                    request,
                                                                                                    context);
                                                                                                // print(response);
                                                                                                if (response.containsKey("body")) {
                                                                                                  setState(() {
                                                                                                    result = jsonDecode(response["body"]);
                                                                                                  });
                                                                                                  print("result:$result");
                                                                                                  if (result.keys.first == "1") {
                                                                                                    Navigator.pop(context);
                                                                                                    Navigator.pop(context);
                                                                                                    showToast(
                                                                                                        context: context,
                                                                                                        msg:
                                                                                                            "Đã mở nhân sự ${listUserAAMResult[i].userCode} - ${listUserAAMResult[i].fullName}",
                                                                                                        color: mainColorPage,
                                                                                                        icon: const Icon(Icons.done),
                                                                                                        timeHint: 2);
                                                                                                    postNotifi("Hệ thống thông báo",
                                                                                                        "Đã mở nhân sự ${listUserAAMResult[i].userCode} - ${listUserAAMResult[i].fullName}");
                                                                                                  } else {
                                                                                                    Navigator.pop(context);
                                                                                                    showToast(
                                                                                                        context: context,
                                                                                                        msg: "${result[result.keys.first]}",
                                                                                                        color: colorOrange,
                                                                                                        icon: const Icon(Icons.warning),
                                                                                                        timeHint: 2);
                                                                                                  }
                                                                                                } else {
                                                                                                  Navigator.pop(context);
                                                                                                }
                                                                                              },
                                                                                              child: Text(
                                                                                                'Xác nhận',
                                                                                                style: TextStyle(),
                                                                                              ),
                                                                                              style: ElevatedButton.styleFrom(
                                                                                                primary: mainColorPage,
                                                                                                onPrimary: colorWhite,
                                                                                                elevation: 3,
                                                                                                minimumSize: Size(100, 40),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ));
                                                                                setState(() {
                                                                                  getListHSNS(currentPage - 1, findHSNS);
                                                                                });
                                                                              }
                                                                            },
                                                                            value: isSwitched[i],
                                                                            activeColor: mainColorPage,
                                                                            activeTrackColor: Color(0xfffcccccc),
                                                                            inactiveThumbColor: Color.fromARGB(255, 158, 158, 158),
                                                                            inactiveTrackColor: Color(0xfffcccccc),
                                                                          )),
                                                                    )
                                                                  : Container(),
                                                            ],
                                                          )),
                                                          //
                                                        ],
                                                      )
                                                  ],
                                                )),
                                              ],
                                            ),
                                          ],
                                        )),
                                      ],
                                    ),
                                  ],
                                );
                              } else if (snapshot.hasError) {
                                return Text('${snapshot.error}');
                              }
                              // By default, show a loading spinner.
                              return const CircularProgressIndicator();
                            },
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 50),
                            child: DynamicTablePagging(
                              rowCount,
                              currentPage,
                              rowPerPage,
                              pageChangeHandler: (page) {
                                setState(() {
                                  currentPage = page - 1;
                                  print("findHSNS:$findHSNS");
                                  getListHSNS(currentPage, findHSNS);
                                });
                              },
                              rowPerPageChangeHandler: (rowPerPage) {
                                setState(() {
                                  this.rowPerPage = rowPerPage!;
                                  this.firstRow = page * currentPage;
                                  getListHSNS(0, findHSNS);
                                });
                              },
                            ),
                          ),
                        ],
                      )),
                ),
                Footer(marginFooter: EdgeInsets.only(top: 5), paddingFooter: EdgeInsets.all(15)),
                SizedBox(height: 20)
              ],
            ),
          );
        } else if (listRule.hasError) {
          return Text('${listRule.error}');
        }
        return Center(child: CircularProgressIndicator());
      },
    );
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
