import 'dart:convert';
import 'dart:html';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/model/model.dart';
import 'package:gentelella_flutter/widgets/forms/nhan_su/setting-data/userAAM.dart';
import 'package:gentelella_flutter/widgets/ui/nhan_su/view-hsns.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row;
import '../../../api.dart';
import '../../../common/dynamic_table.dart';
import '../../../common/style.dart';
import '../../../common/toast.dart';
import '../../../common/widgets_form.dart';
import '../../forms/nhan_su/setting-data/depart.dart';
import '../../forms/nhan_su/setting-data/duty.dart';
import '../../forms/nhan_su/setting-data/team.dart';
import '../navigation.dart';

class DanhSachNhanSu extends StatefulWidget {
  const DanhSachNhanSu({Key? key}) : super(key: key);

  @override
  _DanhSachNhanSuState createState() => _DanhSachNhanSuState();
}

class _DanhSachNhanSuState extends State<DanhSachNhanSu> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: DanhSachNhanSuBody());
  }
}

class DanhSachNhanSuBody extends StatefulWidget {
  const DanhSachNhanSuBody({Key? key}) : super(key: key);
  @override
  State<DanhSachNhanSuBody> createState() => _DanhSachNhanSuBodyState();
}

class _DanhSachNhanSuBodyState extends State<DanhSachNhanSuBody> {
  TextEditingController nhanVien = TextEditingController();
  TextEditingController sDT = TextEditingController();
  int? selectedBP;
  Depart selectedBP1 = Depart(id: -1, departName: 'Tất cả');
  Future<List<Depart>> getPhongBan(int departId) async {
    late List<Depart> resultPhongBan;
    var response1;
    if (departId <= 2) {
      response1 = await httpGet("/api/phongban/get/page?sort=id,asc&filter=parentId:0 and status:1", context);
    } else {
      response1 = await httpGet("/api/phongban/get/page?sort=id,asc&filter=id:$departId and status:1", context);
    }
    if (response1.containsKey("body")) {
      var body = jsonDecode(response1['body']);
      var content = [];
      setState(() {
        content = body['content'];
        resultPhongBan = content.map((e) {
          return Depart.fromJson(e);
        }).toList();
      });
      if (departId <= 2) {
        Depart all = new Depart(id: -1, departName: "Tất cả");
        resultPhongBan.insert(0, all);
      }
    }
    return resultPhongBan;
  }

  bool checkBP = false;
  int? selectedVTFix;
  int? selectedVT;
  Duty selectedVT1 = Duty(id: -1, dutyName: 'Tất cả', departId: -1);
  Future<List<Duty>> getVaiTro(var ipBp, int fixVT) async {
    late List<Duty> resultVaiTro;
    if (ipBp == -1) ipBp = 0;
    var response = await httpGet("/api/vaitro/get/page?filter=departId:$ipBp and status:1 and level<:$fixVT", context);
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
    }
    Team all = Team(id: 0, teamName: 'Tất cả');
    resultTeam.insert(0, all);
    return resultTeam;
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
  Future<List<UserAAM>> getListHSNS(page, String findHSNS, int departId, int dutyId, int teamId, int level) async {
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }
    if (page < 1) {
      page = 0;
    }
    var response;
    if (departId == -1 || departId == 0 || departId == 1 || departId == 2) {
      if (findHSNS == "") {
        response = await httpGet("/api/nguoidung/get/page?size=$rowPerPage&page=$page&filter=isAam:1 and isBlocked:0 ", context);
      } else {
        response = await httpGet("/api/nguoidung/get/page?size=$rowPerPage&page=$page&filter=isAam:1 and isBlocked:0 $findHSNS ", context);
      }
    } else {
      if (level > 1) {
        if (findHSNS == "") {
          response = await httpGet(
              "/api/nguoidung/get/page?size=$rowPerPage&page=$page&filter=isAam:1 and isBlocked:0 and departId:$departId &sort=vaitro.level,desc",
              context);
        } else {
          response = await httpGet(
              "/api/nguoidung/get/page?size=$rowPerPage&page=$page&filter=isAam:1 and isBlocked:0 and departId:$departId $findHSNS &sort=vaitro.level,desc",
              context);
        }
      } else {
        if (teamId != 0) {
          if (findHSNS == "") {
            response = await httpGet(
                "/api/nguoidung/get/page?size=$rowPerPage&page=$page&filter=isAam:1 and isBlocked:0 and departId:$departId and teamId:$teamId &sort=vaitro.level,desc",
                context);
          } else {
            response = await httpGet(
                "/api/nguoidung/get/page?size=$rowPerPage&page=$page&filter=isAam:1 and isBlocked:0 and departId:$departId and teamId:$teamId $findHSNS &sort=vaitro.level,desc",
                context);
          }
        } else {
          if (findHSNS == "") {
            response = await httpGet(
                "/api/nguoidung/get/page?size=$rowPerPage&page=$page&filter=isAam:1 and isBlocked:0 and departId:$departId and teamId is null &sort=vaitro.level,desc",
                context);
          } else {
            response = await httpGet(
                "/api/nguoidung/get/page?size=$rowPerPage&page=$page&filter=isAam:1 and isBlocked:0 and departId:$departId and teamId is null $findHSNS &sort=vaitro.level,desc",
                context);
          }
        }
      }
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
    int stt = listUser.length;
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
    for (var i = 0; i < listUser.length; i++) {
      sheet.getRangeByName('A${i + 2}').setNumber(i + 1);
      sheet.getRangeByName('B${i + 2}').setText(listUser[i].userCode);
      sheet.getRangeByName('C${i + 2}').setText(listUser[i].fullName);
      sheet.getRangeByName('D${i + 2}').setText((listUser[i].gender == 0) ? "Nữ" : "Nam");
      if (listUser[i].dateInCompany != "")
        sheet.getRangeByName('E${i + 2}').setText(DateFormat('dd-MM-yyyy').format(DateTime.parse(listUser[i].dateInCompany).toLocal()));
      if (listUser[i].dutyName != "") sheet.getRangeByName('F${i + 2}').setText(listUser[i].dutyName);
      if (listUser[i].departName != "") sheet.getRangeByName('G${i + 2}').setText(listUser[i].departName);
      sheet.getRangeByName('H${i + 2}').setText(listUser[i].phone);
      sheet.getRangeByName('I${i + 2}').setText(listUser[i].email);
      sheet.getRangeByName('J${i + 2}').setText(listUser[i].idCardNo);
      if (listUser[i].issuedDate != "")
        sheet.getRangeByName('K${i + 2}').setText(DateFormat('dd-MM-yyyy').format(DateTime.parse(listUser[i].issuedDate).toLocal()));
      sheet.getRangeByName('L${i + 2}').setText(listUser[i].issuedBy);
      if (listUser[i].birthDate != "")
        sheet.getRangeByName('M${i + 2}').setText(DateFormat('dd-MM-yyyy').format(DateTime.parse(listUser[i].birthDate).toLocal()));
      sheet.getRangeByName('N${i + 2}').setText(listUser[i].address);
      sheet.getRangeByName('O${i + 2}').setText(listUser[i].nhansuTuyendungId != 0
          ? "${listUser[i].nhansuTuyendungUserCode} - ${listUser[i].nhansuTuyendungName}"
          : (listUser[i].hsSource));
      sheet.getRangeByName('P${i + 2}').setText(listUser[i].pnBhxh);
      sheet.getRangeByName('Q${i + 2}').setText(listUser[i].mst);
      sheet.getRangeByName('R${i + 2}').setText(listUser[i].bankNumber);
      sheet.getRangeByName('S${i + 2}').setText(listUser[i].bankName);
      sheet.getRangeByName('T${i + 2}').setText(listUser[i].bankBranch);
      sheet.getRangeByName('U${i + 2}').setText(listUser[i].nbProvince);
      sheet.getRangeByName('V${i + 2}').setText(listUser[i].device);
      sheet.getRangeByName('W${i + 2}').setText(listUser[i].note);
      sheet.getRangeByName('X${i + 2}').setText(listUser[i].timeKeepingCode);
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
    var body1 = {
      "title": title,
      "message": content,
    };
    httpPost("/api/push/tags/user_type/aam", body1, context);
  }

  @override
  void initState() {
    super.initState();
    var user = Provider.of<SecurityModel>(context, listen: false);
    selectedVTFix = (user.userLoginCurren['vaitro'] != null) ? user.userLoginCurren['vaitro']['level'] : null;
    selectedTeam = Team(
        id: user.userLoginCurren['teamId'] ?? 0,
        teamName: (user.userLoginCurren['doinhom'] != null) ? user.userLoginCurren['doinhom']['departName'] : 'Tất cả');
    if (user.userLoginCurren['departId'] == 1 || user.userLoginCurren['departId'] == 2) {
      selectedBP1 = Depart(id: -1, departName: 'Tất cả');
    } else {
      selectedBP1 = Depart(id: user.userLoginCurren['departId'], departName: user.userLoginCurren['phongban']['departName']);
      selectedBP = user.userLoginCurren['departId'];
      checkBP = true;
    }
    _futureListUserAAM = getListHSNS(0, findHSNS, user.userLoginCurren['departId'], selectedVT1.id, selectedTeam.id, selectedVTFix ?? 100);
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
              builder: (context, navigationModel, user, child) => (user.userLoginCurren['departId'] == 1 ||
                      user.userLoginCurren['departId'] == 2 ||
                      (user.userLoginCurren['vaitro'] != null && user.userLoginCurren['vaitro']['level'] != 0))
                  ? ListView(
                      controller: ScrollController(),
                      children: [
                        TitlePage(
                          listPreTitle: [
                            {'url': "/dashboard", 'title': 'Dashboard'},
                          ],
                          content: 'Danh sách nhân sự',
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
                                    (user.userLoginCurren['departId'] == 1 || user.userLoginCurren['departId'] == 2)
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
                                                              onFind: (String? filter) => getPhongBan(user.userLoginCurren['departId']),
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
                                                                    onFind: (String? filter) => getVaiTro(selectedBP ?? 0, selectedVTFix ?? 100),
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
                                                  : Expanded(flex: 3, child: Container()),
                                              Expanded(flex: 1, child: Container()),
                                            ],
                                          )
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: (selectedVTFix! > 1)
                                                    ? Container(
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
                                                      )
                                                    : Container(),
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
                                                                    onFind: (String? filter) => getVaiTro(selectedBP ?? 0, selectedVTFix ?? 100),
                                                                    itemAsString: (Duty? u) => u!.dutyName,
                                                                    dropdownSearchDecoration: styleDropDown,
                                                                    onChanged: (value) {
                                                                      setState(() {
                                                                        selectedVT = value!.id;
                                                                        selectedVT1 = value;
                                                                      });
                                                                    },
                                                                  ),
                                                                ))
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  : Expanded(flex: 3, child: Container()),
                                              Expanded(flex: 1, child: Container()),
                                            ],
                                          ),
                                    ((user.userLoginCurren['departId'] == 1 || user.userLoginCurren['departId'] == 2) && checkBP)
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
                                              Expanded(flex: 4, child: Container()),
                                            ],
                                          )
                                        : Row(),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Container(
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
                                                findHSNS = nhanVien1 + phone + idPhongBan;
                                                getListHSNS(0, findHSNS, selectedBP1.id, selectedVT1.id, selectedTeam.id, selectedVTFix ?? 100);
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
                                                      createExcel(listUserAAMResult);
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
                                                                                DateTime.parse(listUserAAMResult[i].dateInCompany.toString())
                                                                                    .toLocal())
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
                                                                              SelectableText(listUserAAMResult[i].departName.toString(),
                                                                                  style: bangDuLieu),
                                                                              SelectableText(listUserAAMResult[i].teamName.toString(),
                                                                                  style: bangDuLieu),
                                                                            ],
                                                                          ),
                                                                        )
                                                                      : DataCell(
                                                                          SelectableText(listUserAAMResult[i].departName.toString(),
                                                                              style: bangDuLieu),
                                                                        ),
                                                                  DataCell(Row(
                                                                    children: [
                                                                      Container(
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
                                                                              child: Icon(Icons.visibility)))
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
                                          getListHSNS(currentPage, findHSNS, selectedBP1.id, selectedVT1.id, selectedTeam.id, selectedVTFix ?? 100);
                                        });
                                      },
                                      rowPerPageChangeHandler: (rowPerPage) {
                                        setState(() {
                                          this.rowPerPage = rowPerPage!;
                                          this.firstRow = page * currentPage;
                                          getListHSNS(0, findHSNS, selectedBP1.id, selectedVT1.id, selectedTeam.id, selectedVTFix ?? 100);
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
                    )
                  : Center(
                      child: Text(
                      "Không có quyền truy cập vào tính năng này",
                      style: titleTableData,
                    )));
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
