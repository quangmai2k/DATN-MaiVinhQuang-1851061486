// ignore_for_file: unused_local_variable, unused_field, deprecated_member_use
import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/forms/nhan_su/setting-data/depart.dart';
import 'package:gentelella_flutter/widgets/ui/nhan_su/sua-dntd.dart';
import 'package:gentelella_flutter/widgets/ui/nhan_su/view-dntd.dart';
import 'package:provider/provider.dart';
import '../../../api.dart';
import '../../../common/dynamic_table.dart';
import '../../../common/style.dart';
import '../../../common/toast.dart';
import '../../../common/widgets_form.dart';
import '../../../model/model.dart';
import '../../forms/nhan_su/setting-data/recruitment.dart';
import '../navigation.dart';

// /de-nghi-tuyen-dung-chuc-nang
class DeNghiTuyenDung extends StatefulWidget {
  const DeNghiTuyenDung({Key? key}) : super(key: key);
  @override
  _DeNghiTuyenDungState createState() => _DeNghiTuyenDungState();
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _DeNghiTuyenDungState extends State<DeNghiTuyenDung> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: DeNghiTuyenDungBody());
  }
}

class DeNghiTuyenDungBody extends StatefulWidget {
  const DeNghiTuyenDungBody({Key? key}) : super(key: key);
  @override
  State<DeNghiTuyenDungBody> createState() => _DeNghiTuyenDungBodyState();
}

class _DeNghiTuyenDungBodyState extends State<DeNghiTuyenDungBody> {
  final String urlViewDNTD = "/view-dntd";
  final String urlUpdateDNTD = "/sua-dntd";
  String? selectedPD;
  var trangThaiPD;
  List<String> appRoveNote = ['Chưa phê duyệt', 'Đã phê duyệt', 'Từ chối'];
  Map<int, String> appRove = {
    3: 'Tất cả',
    0: 'Chưa phê duyệt',
    1: 'Đã phê duyệt',
    2: 'Từ chối',
  };
  TextEditingController tieuDe = TextEditingController();
  TextEditingController approveNote = TextEditingController();
  final TextEditingController textEditingController = TextEditingController();
  List<bool> _selectedDataRow = [];
  var idCheck = [];
  int? selectedBP;
  var body = {};
  var page = 1;
  var rowPerPage = 10;
  var totalElements = 0;
  var firstRow = 1, lastRow = 0;
  var rowCount = 0;
  var currentPage = 1;
  var tableIndex = 1;

  List<Recruitment> listRecruitResult = [];
  late Future<List<Recruitment>> _futureListRecruit;
  String findDNTD = "";
  Future<List<Recruitment>> getListTDCT(page, String findDNTD, int userDepartID) async {
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }
    if (page < 1) {
      page = 0;
    }
    var response;
    if (findDNTD == "") {
      response = await httpGet("/api/tuyendung/get/page?sort=approve&sort=id,desc&size=$rowPerPage&page=$page", context);
    } else {
      response =
          await httpGet("/api/tuyendung/get/page?sort=approve&sort=id,desc&size=$rowPerPage&page=$page&filter=deleted:false $findDNTD ", context);
    }

    var body = jsonDecode(response['body']);
    var content = [];

    if (response.containsKey("body")) {
      setState(() {
        currentPage = page + 1;
        content = body['content'];
        rowCount = body["totalElements"];
        totalElements = body["totalElements"];
        lastRow = totalElements;

        listRecruitResult = content.map((e) {
          return Recruitment.fromJson(e);
        }).toList();

        if (listRecruitResult.length > 0) {
          var firstRow = (currentPage) * rowPerPage + 1;
          var lastRow = (currentPage + 1) * rowPerPage;
          if (lastRow > totalElements) {
            lastRow = totalElements;
          }
          tableIndex = (currentPage - 1) * rowPerPage + 1;
        }
        _selectedDataRow = List<bool>.generate(content.length, (int index) => false);
      });
    }
    return listRecruitResult;
  }

  List<int> idTD = [];
  List<int> filterIdTD = [];

  getDNTDChiTiet(var idBP) async {
    var response = await httpGet("/api/tuyendung-chitiet/get/page?filter=departId:$idBP", context);
    if (response.containsKey("body")) {
      idTD = [];
      var listRecruit;
      setState(() {
        var body = jsonDecode(response['body']);
        listRecruit = body['content'];
        for (var item in listRecruit) idTD.add(item['tuyendungId']);
        // print(listRecruit['content'][i]['tuyendungId']);
        // print(result);
      });
      print(idTD);
      return idTD;
    }
    return idTD;
  }

  Future<List<Depart>> getPhongBan() async {
    List<Depart> resultPhongBan = [];
    var response1 = await httpGet("/api/phongban/get/page?sort=id,asc&filter=parentId:0 and id>2 and status:1", context);
    var body = jsonDecode(response1['body']);
    var content = [];
    if (response1.containsKey("body")) {
      setState(() {
        content = body['content'];
        resultPhongBan = content.map((e) {
          return Depart.fromJson(e);
        }).toList();
      });
    }
    Depart all = new Depart(id: -1, departName: "Tất cả");
    resultPhongBan.insert(0, all);
    return resultPhongBan;
  }

  //update phe duyệt
  upDateApprove(var idCheck, int approve, String approveNote, int status, approver) async {
    for (var i = 0; i < idCheck.length; i++) {
      var requestBody = {
        "approver": approver,
        "approve": approve,
        "approveNote": approveNote,
        "status": status,
      };
      var response6 = await httpPut("/api/tuyendung/put/${idCheck[i]}", requestBody, context);
    }
  }

  @override
  void initState() {
    super.initState();
    var user = Provider.of<SecurityModel>(context, listen: false);
    _futureListRecruit = getListTDCT(0, findDNTD, user.userLoginCurren['departId']);
    print("=============");
  }

  bool checkSelected = false;
  var error1 = 'Trường này không được bỏ trống';
  var timeNeed;
  void dispose() {
    tieuDe.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: userRule('/de-nghi-tuyen-dung', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return Consumer2<NavigationModel, SecurityModel>(
            builder: (context, navigationModel, user, child) => FutureBuilder<List<Recruitment>>(
              future: _futureListRecruit,
              builder: (context, snapshot) {
                // if (snapshot.hasData) {
                return ListView(
                  controller: ScrollController(),
                  children: [
                    TitlePage(
                      listPreTitle: [
                        {'url': "/nhan-su", 'title': 'Dashboard'},
                        // {'url': "/ho-so-nhan-su", 'title': 'Hồ sơ nhân sự'},
                      ],
                      content: 'Đề nghị tuyển dụng',
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: verticalPaddingPage, horizontal: horizontalPaddingPage),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                      child: TextFieldValidatedForm(
                                        type: 'None',
                                        height: 40,
                                        controller: tieuDe,
                                        label: 'Tiêu đề:',
                                        flexLable: 2,
                                      ),
                                    ),
                                    SizedBox(width: 100),
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                          margin: EdgeInsets.only(bottom: 30),
                                          child: DatePickerBox1(
                                              label: Text(
                                                'Thời gian đề nghị:',
                                                style: titleWidgetBox,
                                              ),
                                              isTime: false,
                                              selectedDateFunction: (day) {
                                                timeNeed = day;
                                                setState(() {});
                                              })),
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
                                                    hint: "Tất cả",
                                                    mode: Mode.MENU,
                                                    maxHeight: 350,
                                                    showSearchBox: true,
                                                    onFind: (String? filter) => getPhongBan(),
                                                    itemAsString: (Depart? u) => u!.departName,
                                                    dropdownSearchDecoration: styleDropDown,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        selectedBP = value!.id;
                                                        print(selectedBP);
                                                        if (selectedBP != -1) getDNTDChiTiet(selectedBP);
                                                      });
                                                    },
                                                  ),
                                                )),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 100),
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: 30),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Text('Phê duyệt:', style: titleWidgetBox),
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
                                                    hint: Text(
                                                      '${appRove[3]}',
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    items: appRove.entries
                                                        .map((item) => DropdownMenuItem<String>(value: item.key.toString(), child: Text(item.value)))
                                                        .toList(),
                                                    value: selectedPD,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        selectedPD = value as String;
                                                        trangThaiPD = int.parse(selectedPD.toString());
                                                        print(trangThaiPD);
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

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    (user.userLoginCurren['departId'] == 2 || user.userLoginCurren['departId'] == 1)
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
                                                backgroundColor: (idCheck.length > 0) ? Color.fromRGBO(245, 117, 29, 1) : Colors.grey,
                                                primary: Theme.of(context).iconTheme.color,
                                                textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 20.0, letterSpacing: 2.0),
                                              ),
                                              onPressed: (idCheck.length > 0)
                                                  ? () {
                                                      print(idCheck);
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) => AlertDialog(
                                                          title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                            SizedBox(
                                                              child: Row(
                                                                children: [
                                                                  Container(
                                                                    width: 40,
                                                                    height: 40,
                                                                    child: Image.asset('assets/images/logoAAM.png'),
                                                                    margin: EdgeInsets.only(right: 10),
                                                                  ),
                                                                  Text(
                                                                    'Phê duyệt đề nghị tuyển dụng',
                                                                    style: titleAlertDialog,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            IconButton(
                                                              onPressed: () => {
                                                                Navigator.pop(context),
                                                              },
                                                              icon: Icon(
                                                                Icons.close,
                                                              ),
                                                            ),
                                                          ]),
                                                          //content
                                                          content: Container(
                                                            width: 700,
                                                            height: 300,
                                                            child: ListView(
                                                              children: [
                                                                Column(
                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    //đường line
                                                                    Container(
                                                                      margin: marginTopBottomHorizontalLine,
                                                                      child: Divider(
                                                                        thickness: 1,
                                                                        color: ColorHorizontalLine,
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      height: 150,
                                                                      child: Text(
                                                                        'Xác nhận phê duyệt ${idCheck.length} đề nghị tuyển dụng',
                                                                        style: titleWidgetBox,
                                                                      ),
                                                                    ),
                                                                    //đường line
                                                                    Container(
                                                                      margin: marginTopBottomHorizontalLine,
                                                                      child: Divider(
                                                                        thickness: 1,
                                                                        color: ColorHorizontalLine,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),

                                                          //actions
                                                          actions: [
                                                            ElevatedButton(
                                                              onPressed: () => {
                                                                showDialog(
                                                                    context: context,
                                                                    builder: (BuildContext context) => AlertDialog(
                                                                          title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                                            SizedBox(
                                                                              child: Row(
                                                                                children: [
                                                                                  Container(
                                                                                    width: 40,
                                                                                    height: 40,
                                                                                    child: Image.asset('assets/images/logoAAM.png'),
                                                                                    margin: EdgeInsets.only(right: 10),
                                                                                  ),
                                                                                  Text(
                                                                                    'Phê duyệt đề nghị tuyển dụng',
                                                                                    style: titleAlertDialog,
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            IconButton(
                                                                              onPressed: () => {
                                                                                Navigator.pop(context),
                                                                                Navigator.pop(context),
                                                                              },
                                                                              icon: Icon(
                                                                                Icons.close,
                                                                              ),
                                                                            ),
                                                                          ]),
                                                                          //content
                                                                          content: Container(
                                                                            width: 700,
                                                                            height: 300,
                                                                            child: ListView(
                                                                              children: [
                                                                                Column(
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    //đường line
                                                                                    Container(
                                                                                      margin: marginTopBottomHorizontalLine,
                                                                                      child: Divider(
                                                                                        thickness: 1,
                                                                                        color: ColorHorizontalLine,
                                                                                      ),
                                                                                    ),
                                                                                    Container(
                                                                                      height: 150,
                                                                                      child: Column(
                                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          Row(
                                                                                            children: [
                                                                                              Text('Lý do:', style: titleWidgetBox),
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
                                                                                            controller: approveNote,
                                                                                            maxLines: 5,
                                                                                            minLines: 3,
                                                                                            decoration: InputDecoration(
                                                                                              border: OutlineInputBorder(
                                                                                                borderRadius: BorderRadius.all(Radius.circular(0)),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                    //đường line
                                                                                    Container(
                                                                                      margin: marginTopBottomHorizontalLine,
                                                                                      child: Divider(
                                                                                        thickness: 1,
                                                                                        color: ColorHorizontalLine,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          //actions
                                                                          actions: [
                                                                            ElevatedButton(
                                                                              onPressed: () => Navigator.pop(context),
                                                                              child: Text('Hủy'),
                                                                              style: ElevatedButton.styleFrom(
                                                                                primary: colorIconTitleBox,
                                                                                onPrimary: colorWhite,
                                                                                elevation: 3,
                                                                                minimumSize: Size(140, 50),
                                                                              ),
                                                                            ),
                                                                            ElevatedButton(
                                                                              onPressed: () async {
                                                                                await upDateApprove(
                                                                                    idCheck, 2, approveNote.text, 0, user.userLoginCurren['id']);
                                                                                if (approveNote.text != "") {
                                                                                  print(approveNote.text);
                                                                                  for (int i = 0; i < idCheck.length; i++) {
                                                                                    upDateApprove(idCheck[i], 2, approveNote.text, 0,
                                                                                        user.userLoginCurren['id']);
                                                                                  }

                                                                                  Navigator.pop(context);
                                                                                  Navigator.pop(context);
                                                                                  await getListTDCT(
                                                                                      currentPage - 1, findDNTD, user.userLoginCurren['departId']);
                                                                                  showToast(
                                                                                    context: context,
                                                                                    msg: "Đã từ chối đề nghị tuyển dụng",
                                                                                    color: colorOrange,
                                                                                    icon: const Icon(Icons.done),
                                                                                  );
                                                                                  setState(() {
                                                                                    idCheck = [];
                                                                                  });
                                                                                } else
                                                                                  showToast(
                                                                                    context: context,
                                                                                    msg: "Nhập lý do từ chối",
                                                                                    color: colorOrange,
                                                                                    icon: const Icon(Icons.warning),
                                                                                  );
                                                                              },
                                                                              child: Text(
                                                                                'Xác nhận',
                                                                                style: TextStyle(),
                                                                              ),
                                                                              style: ElevatedButton.styleFrom(
                                                                                primary: mainColorPage,
                                                                                onPrimary: colorWhite,
                                                                                elevation: 3,
                                                                                minimumSize: Size(140, 50),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ))
                                                              },
                                                              // Navigator.pop(context),
                                                              child: Text('Từ chối'),
                                                              style: ElevatedButton.styleFrom(
                                                                primary: colorIconTitleBox,
                                                                onPrimary: colorWhite,
                                                                elevation: 3,
                                                                minimumSize: Size(140, 50),
                                                              ),
                                                            ),
                                                            ElevatedButton(
                                                              onPressed: () async {
                                                                print(idCheck);
                                                                await upDateApprove(idCheck, 1, "Đã phê duyệt", 1, user.userLoginCurren['id']);
                                                                // getListTDCT(0, findDNTD);
                                                                await getListTDCT(currentPage - 1, findDNTD, user.userLoginCurren['departId']);
                                                                setState(() {
                                                                  idCheck = [];
                                                                });
                                                                Navigator.pop(context);
                                                                showToast(
                                                                  context: context,
                                                                  msg: "Đã phê duyệt đề nghị tuyển dụng",
                                                                  color: Color.fromARGB(136, 72, 238, 67),
                                                                  icon: const Icon(Icons.done),
                                                                );
                                                              },
                                                              child: Text(
                                                                'Duyệt',
                                                                style: TextStyle(),
                                                              ),
                                                              style: ElevatedButton.styleFrom(
                                                                primary: mainColorPage,
                                                                onPrimary: colorWhite,
                                                                elevation: 3,
                                                                minimumSize: Size(140, 50),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        // PheDuyet(titleDialog: 'Phê duyệt đề nghị tuyển dụng'),
                                                      );
                                                    }
                                                  : null,
                                              child: Row(
                                                children: [
                                                  Icon(Icons.fact_check, color: colorWhite),
                                                  SizedBox(width: 5),
                                                  Text('Phê duyệt', style: textButton),
                                                ],
                                              ),
                                            ),
                                          )
                                        : Container(),
                                    //tìm kiếm
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
                                          findDNTD = "";
                                          filterIdTD = [];
                                          if (idTD.length != 0) filterIdTD.add(idTD[0]);
                                          print('=====================');
                                          for (var i = 1; i < idTD.length; i++) {
                                            if (filterIdTD[filterIdTD.length - 1] != idTD[i]) filterIdTD.add(idTD[i]);
                                          }
                                          print(filterIdTD);

                                          var title1 = "";
                                          var idPhongBan = "";
                                          var timeNeed1 = "";
                                          var trangThaiPD1 = "";

                                          if (tieuDe.text != "")
                                            title1 = "and title~'*${tieuDe.text}*' ";
                                          else
                                            title1 = "";

                                          if (filterIdTD.length > 0 && selectedBP != -1)
                                            for (var i = 0; i < filterIdTD.length; i++) {
                                              idPhongBan = idPhongBan + " or id:" + filterIdTD[i].toString();
                                            }
                                          else
                                            idPhongBan = "";

                                          if (timeNeed != null) {
                                            DateTime now = DateTime(int.parse(timeNeed.toString().substring(6)),
                                                int.parse(timeNeed.toString().substring(3, 5)), int.parse(timeNeed.toString().substring(0, 2)));
                                            DateTime nowNext = now.add(Duration(days: 1));
                                            print(nowNext);

                                            timeNeed1 =
                                                "and createdDate>:'${now.day}-${now.month}-${now.year}' and createdDate<'${nowNext.day}-${nowNext.month}-${nowNext.year}' ";
                                          } else
                                            timeNeed1 = "";
                                          if (trangThaiPD != null && trangThaiPD != 3)
                                            trangThaiPD1 = "and approve:$trangThaiPD ";
                                          else
                                            trangThaiPD1 = "";
                                          findDNTD = title1 + timeNeed1 + trangThaiPD1;
                                          if (idPhongBan.length > 0) {
                                            idPhongBan = idPhongBan.substring(3);
                                            findDNTD = findDNTD + " &filter=" + idPhongBan;
                                          }
                                          print(findDNTD);
                                          getListTDCT(0, findDNTD, user.userLoginCurren['departId']);
                                        },
                                        child: Row(
                                          children: [
                                            Icon(Icons.search, color: colorWhite),
                                            SizedBox(width: 5),
                                            Text('Tìm kiếm', style: textButton),
                                          ],
                                        ),
                                      ),
                                    ),
                                    (user.userLoginCurren['departId'] == 2 || user.userLoginCurren['departId'] == 1)
                                        ? Container(
                                            margin: marginLeftBtn,
                                            child: TextButton(
                                              style: TextButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(
                                                  vertical: 20.0,
                                                  horizontal: 10.0,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: borderRadiusBtn,
                                                ),
                                                backgroundColor: backgroundColorBtn,
                                                primary: Theme.of(context).iconTheme.color,
                                                textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                              ),
                                              onPressed: () {
                                                Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/them-moi-dntd");
                                              },
                                              child: Row(
                                                children: [
                                                  Icon(Icons.add, color: colorWhite),
                                                  SizedBox(width: 5),
                                                  Text('Thêm mới', style: textButton),
                                                ],
                                              ),
                                            ),
                                          )
                                        : (user.userLoginCurren['vaitro'] != 7 && user.userLoginCurren['vaitro']['level'] > 1)
                                            ? Container(
                                                margin: marginLeftBtn,
                                                child: TextButton(
                                                  style: TextButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(
                                                      vertical: 20.0,
                                                      horizontal: 10.0,
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: borderRadiusBtn,
                                                    ),
                                                    backgroundColor: backgroundColorBtn,
                                                    primary: Theme.of(context).iconTheme.color,
                                                    textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                                  ),
                                                  onPressed: () {
                                                    Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/them-moi-dntd");
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.add, color: colorWhite),
                                                      SizedBox(width: 5),
                                                      Text('Thêm mới', style: textButton),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : (user.userLoginCurren['vaitro'] != null && user.userLoginCurren['vaitro']['level'] != 0)
                                                ? Container(
                                                    margin: marginLeftBtn,
                                                    child: TextButton(
                                                      style: TextButton.styleFrom(
                                                        padding: const EdgeInsets.symmetric(
                                                          vertical: 20.0,
                                                          horizontal: 10.0,
                                                        ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: borderRadiusBtn,
                                                        ),
                                                        backgroundColor: backgroundColorBtn,
                                                        primary: Theme.of(context).iconTheme.color,
                                                        textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                                      ),
                                                      onPressed: () {
                                                        Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/them-moi-dntd");
                                                      },
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.add, color: colorWhite),
                                                          SizedBox(width: 5),
                                                          Text('Thêm mới', style: textButton),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : Container(),
                                    SizedBox(width: 20),
                                  ],
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
                        // margin: marginTopBoxContainer,
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
                              children: [
                                Expanded(
                                    child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Thông tin đề nghị tuyển dụng',
                                          style: titleBox,
                                        ),
                                        Icon(
                                          Icons.more_horiz,
                                          color: Color(0xff9aa5ce),
                                          size: 14,
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
                                    if (snapshot.hasData)
                                      Container(
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: DataTable(showCheckboxColumn: true, columnSpacing: 10, columns: [
                                                    DataColumn(label: Text('STT', style: titleTableData)),
                                                    DataColumn(label: Text('Tiêu đề', style: titleTableData)),
                                                    DataColumn(label: Text('Phê duyệt', style: titleTableData)),
                                                    DataColumn(label: Text('Người phê duyệt', style: titleTableData)),
                                                    DataColumn(label: Text('Hành động', style: titleTableData)),
                                                  ], rows: <DataRow>[
                                                    for (var i = 0; i < listRecruitResult.length; i++)
                                                      DataRow(
                                                        selected: _selectedDataRow[i],
                                                        onSelectChanged: (listRecruitResult[i].appRove == 0)
                                                            ? (bool? selected) {
                                                                setState(() {
                                                                  idCheck.clear();
                                                                  _selectedDataRow[i] = selected!;
                                                                  for (int j = 0; j < _selectedDataRow.length; j++)
                                                                    if (_selectedDataRow[j] == true) {
                                                                      idCheck.add(listRecruitResult[j].id);
                                                                    }
                                                                });
                                                              }
                                                            : (bool? selected) {
                                                                _selectedDataRow[i] = false;
                                                              },
                                                        cells: [
                                                          DataCell(Text(" ${tableIndex + i}")),
                                                          DataCell(TextButton(
                                                            onPressed: () {
                                                              navigationModel.add(pageUrl: (urlViewDNTD + "/${listRecruitResult[i].id}"));
                                                            },
                                                            child: Text(listRecruitResult[i].title.toString()),
                                                          )),
                                                          DataCell(
                                                            (listRecruitResult[i].appRove != 2)
                                                                ? Text(appRoveNote[listRecruitResult[i].appRove])
                                                                : TextButton(
                                                                    onPressed: () {
                                                                      showDialog(
                                                                          context: context,
                                                                          builder: (BuildContext context) => AlertDialog(
                                                                                title:
                                                                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                                                  SizedBox(
                                                                                    child: Row(
                                                                                      children: [
                                                                                        Container(
                                                                                          width: 40,
                                                                                          height: 40,
                                                                                          child: Image.asset('assets/images/logoAAM.png'),
                                                                                          margin: EdgeInsets.only(right: 10),
                                                                                        ),
                                                                                        Text(
                                                                                          'Lý do từ chối đề nghị tuyển dụng ',
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
                                                                                content: Container(
                                                                                  width: 300,
                                                                                  height: 150,
                                                                                  child: Column(
                                                                                    children: [
                                                                                      Container(
                                                                                        margin: marginTopBottomHorizontalLine,
                                                                                        child: Divider(
                                                                                          thickness: 1,
                                                                                          color: ColorHorizontalLine,
                                                                                        ),
                                                                                      ),
                                                                                      Center(
                                                                                        child: Text("${listRecruitResult[i].approveNote}"),
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ));
                                                                    },
                                                                    child: Text("Từ chối"),
                                                                  ),
                                                          ),
                                                          DataCell(Text((listRecruitResult[i].appRover != 0)
                                                              ? " ${listRecruitResult[i].appRoverName} (${listRecruitResult[i].appRoverCode})"
                                                              : "")),
                                                          DataCell(Row(
                                                            children: [
                                                              Consumer<NavigationModel>(
                                                                builder: (context, navigationModel, child) => Container(
                                                                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                                    child: InkWell(
                                                                        onTap: () {
                                                                          Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                                builder: (context) =>
                                                                                    ViewDNTDBody(idTTDNTD: listRecruitResult[i].id.toString())),
                                                                          );
                                                                        },
                                                                        child: Icon(Icons.visibility))),
                                                              ),
                                                              // Consumer<NavigationModel>(
                                                              //   builder: (context, navigationModel, child) => Container(
                                                              //       margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                              //       child: InkWell(
                                                              //           onTap: () {
                                                              //             Navigator.push(
                                                              //               context,
                                                              //               MaterialPageRoute(
                                                              //                   builder: (context) => UpdatedntdBody(
                                                              //                         idTTDNTD: listRecruitResult[i].id.toString(),
                                                              //                         recruitment: listRecruitResult[i],
                                                              //                         callBack: (value) {
                                                              //                           setState(() {
                                                              //                             listRecruitResult[i] = value;
                                                              //                           });
                                                              //                         },
                                                              //                       )),
                                                              //             );
                                                              //           },
                                                              //           child: Icon(Icons.edit_calendar, color: Color(0xff009C87)))),
                                                              // ),
                                                              (user.userLoginCurren['departId'] == 2 || user.userLoginCurren['departId'] == 1)
                                                                  ? Consumer<NavigationModel>(
                                                                      builder: (context, navigationModel, child) => Container(
                                                                        margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                        child: (listRecruitResult[i].appRove == 0)
                                                                            ? InkWell(
                                                                                onTap: () {
                                                                                  Navigator.push(
                                                                                    context,
                                                                                    MaterialPageRoute(
                                                                                        builder: (context) => UpdatedntdBody(
                                                                                              idTTDNTD: listRecruitResult[i].id.toString(),
                                                                                              recruitment: listRecruitResult[i],
                                                                                              callBack: (value) {
                                                                                                setState(() {
                                                                                                  listRecruitResult[i] = value;
                                                                                                });
                                                                                              },
                                                                                            )),
                                                                                  );
                                                                                },
                                                                                child: Icon(Icons.edit_calendar, color: Color(0xff009C87)))
                                                                            : (listRecruitResult[i].appRove == 1)
                                                                                ? Tooltip(
                                                                                    message: 'Đã phê duyệt',
                                                                                    textStyle: const TextStyle(
                                                                                      fontSize: 15,
                                                                                    ),
                                                                                    decoration: BoxDecoration(
                                                                                      borderRadius: BorderRadius.circular(25),
                                                                                      color: colorOrange,
                                                                                    ),
                                                                                    child: Icon(Icons.edit_calendar, color: Color(0xfffcccccc)))
                                                                                : Tooltip(
                                                                                    message: 'Đã từ chối',
                                                                                    textStyle: const TextStyle(
                                                                                      fontSize: 15,
                                                                                    ),
                                                                                    decoration: BoxDecoration(
                                                                                      borderRadius: BorderRadius.circular(25),
                                                                                      color: Colors.red,
                                                                                    ),
                                                                                    child: Icon(Icons.edit_calendar, color: Color(0xfffcccccc))),
                                                                      ),
                                                                    )
                                                                  : (user.userLoginCurren['vaitro'] != 7 &&
                                                                          user.userLoginCurren['vaitro']['level'] > 1 &&
                                                                          (user.userLoginCurren['departId'] ==
                                                                              listRecruitResult[i].nguoidenghi!.departId))
                                                                      ? Consumer<NavigationModel>(
                                                                          builder: (context, navigationModel, child) => Container(
                                                                            margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                            child: (listRecruitResult[i].appRove == 0)
                                                                                ? InkWell(
                                                                                    onTap: () {
                                                                                      Navigator.push(
                                                                                        context,
                                                                                        MaterialPageRoute(
                                                                                            builder: (context) => UpdatedntdBody(
                                                                                                  idTTDNTD: listRecruitResult[i].id.toString(),
                                                                                                  recruitment: listRecruitResult[i],
                                                                                                  callBack: (value) {
                                                                                                    setState(() {
                                                                                                      listRecruitResult[i] = value;
                                                                                                    });
                                                                                                  },
                                                                                                )),
                                                                                      );
                                                                                    },
                                                                                    child: Icon(Icons.edit_calendar, color: Color(0xff009C87)))
                                                                                : (listRecruitResult[i].appRove == 1)
                                                                                    ? Tooltip(
                                                                                        message: 'Đã phê duyệt',
                                                                                        textStyle: const TextStyle(
                                                                                          fontSize: 15,
                                                                                        ),
                                                                                        decoration: BoxDecoration(
                                                                                          borderRadius: BorderRadius.circular(25),
                                                                                          color: colorOrange,
                                                                                        ),
                                                                                        child: Icon(Icons.edit_calendar, color: Color(0xfffcccccc)))
                                                                                    : Tooltip(
                                                                                        message: 'Đã từ chối',
                                                                                        textStyle: const TextStyle(
                                                                                          fontSize: 15,
                                                                                        ),
                                                                                        decoration: BoxDecoration(
                                                                                          borderRadius: BorderRadius.circular(25),
                                                                                          color: Colors.red,
                                                                                        ),
                                                                                        child: Icon(Icons.edit_calendar, color: Color(0xfffcccccc))),
                                                                          ),
                                                                        )
                                                                      : (user.userLoginCurren['vaitro'] != null &&
                                                                              user.userLoginCurren['vaitro']['level'] != 0 &&
                                                                              (user.userLoginCurren['departId'] ==
                                                                                  listRecruitResult[i].nguoidenghi!.departId))
                                                                          ? Consumer<NavigationModel>(
                                                                              builder: (context, navigationModel, child) => Container(
                                                                                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                                child: (listRecruitResult[i].appRove == 0)
                                                                                    ? InkWell(
                                                                                        onTap: () {
                                                                                          Navigator.push(
                                                                                            context,
                                                                                            MaterialPageRoute(
                                                                                                builder: (context) => UpdatedntdBody(
                                                                                                      idTTDNTD: listRecruitResult[i].id.toString(),
                                                                                                      recruitment: listRecruitResult[i],
                                                                                                      callBack: (value) {
                                                                                                        setState(() {
                                                                                                          listRecruitResult[i] = value;
                                                                                                        });
                                                                                                      },
                                                                                                    )),
                                                                                          );
                                                                                        },
                                                                                        child: Icon(Icons.edit_calendar, color: Color(0xff009C87)))
                                                                                    : (listRecruitResult[i].appRove == 1)
                                                                                        ? Tooltip(
                                                                                            message: 'Đã phê duyệt',
                                                                                            textStyle: const TextStyle(
                                                                                              fontSize: 15,
                                                                                            ),
                                                                                            decoration: BoxDecoration(
                                                                                              borderRadius: BorderRadius.circular(25),
                                                                                              color: colorOrange,
                                                                                            ),
                                                                                            child:
                                                                                                Icon(Icons.edit_calendar, color: Color(0xfffcccccc)))
                                                                                        : Tooltip(
                                                                                            message: 'Đã từ chối',
                                                                                            textStyle: const TextStyle(
                                                                                              fontSize: 15,
                                                                                            ),
                                                                                            decoration: BoxDecoration(
                                                                                              borderRadius: BorderRadius.circular(25),
                                                                                              color: Colors.red,
                                                                                            ),
                                                                                            child:
                                                                                                Icon(Icons.edit_calendar, color: Color(0xfffcccccc))),
                                                                              ),
                                                                            )
                                                                          : Text(""),
                                                              (user.userLoginCurren['departId'] == 2 || user.userLoginCurren['departId'] == 1)
                                                                  ? Consumer<NavigationModel>(
                                                                      builder: (context, navigationModel, child) => Container(
                                                                          margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                          child: (listRecruitResult[i].appRove == 0 ||
                                                                                  listRecruitResult[i].appRove == 2)
                                                                              ? InkWell(
                                                                                  onTap: (listRecruitResult[i].appRove == 0 ||
                                                                                          listRecruitResult[i].appRove == 2)
                                                                                      ? () {
                                                                                          showDialog(
                                                                                              context: context,
                                                                                              builder: (BuildContext context) => AlertDialog(
                                                                                                    title: Row(
                                                                                                        mainAxisAlignment:
                                                                                                            MainAxisAlignment.spaceBetween,
                                                                                                        children: [
                                                                                                          SizedBox(
                                                                                                            child: Row(
                                                                                                              children: [
                                                                                                                Container(
                                                                                                                  width: 40,
                                                                                                                  height: 40,
                                                                                                                  child: Image.asset(
                                                                                                                      'assets/images/logoAAM.png'),
                                                                                                                  margin: EdgeInsets.only(right: 10),
                                                                                                                ),
                                                                                                                Text(
                                                                                                                  'Xác nhận xóa đề nghị tuyển dụng ',
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
                                                                                                      height: 150,
                                                                                                      child: Column(
                                                                                                        mainAxisAlignment:
                                                                                                            MainAxisAlignment.spaceBetween,
                                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                        children: [
                                                                                                          //đường line
                                                                                                          Container(
                                                                                                            margin: marginTopBottomHorizontalLine,
                                                                                                            child: Divider(
                                                                                                              thickness: 1,
                                                                                                              color: ColorHorizontalLine,
                                                                                                            ),
                                                                                                          ),
                                                                                                          Container(
                                                                                                            child: Text(
                                                                                                                'Xóa đề nghị tuyển dụng: "${listRecruitResult[i].title}"'),
                                                                                                          ),
                                                                                                          //đường line
                                                                                                          Container(
                                                                                                            margin: marginTopBottomHorizontalLine,
                                                                                                            child: Divider(
                                                                                                              thickness: 1,
                                                                                                              color: ColorHorizontalLine,
                                                                                                            ),
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ),
                                                                                                    //actions
                                                                                                    actions: [
                                                                                                      ElevatedButton(
                                                                                                        onPressed: () => Navigator.pop(context),
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
                                                                                                          var response = await httpDelete(
                                                                                                              "/api/tuyendung/del/${listRecruitResult[i].id}",
                                                                                                              context);
                                                                                                          print(response['body']);
                                                                                                          await getListTDCT(currentPage - 1, findDNTD,
                                                                                                              user.userLoginCurren['departId']);
                                                                                                          Navigator.pop(context);
                                                                                                          showToast(
                                                                                                            context: context,
                                                                                                            msg: "Xóa đề nghị tuyển dụng thành công",
                                                                                                            color: Color.fromARGB(136, 72, 238, 67),
                                                                                                            icon: const Icon(Icons.done),
                                                                                                          );
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
                                                                                        }
                                                                                      : null,
                                                                                  child: Icon(Icons.delete_outline,
                                                                                      color: (listRecruitResult[i].appRove == 0 ||
                                                                                              listRecruitResult[i].appRove == 2)
                                                                                          ? Colors.red
                                                                                          : Color(0xfffcccccc)))
                                                                              : Tooltip(
                                                                                  message: 'Đã phê duyệt',
                                                                                  textStyle: const TextStyle(
                                                                                    fontSize: 15,
                                                                                  ),
                                                                                  decoration: BoxDecoration(
                                                                                    borderRadius: BorderRadius.circular(25),
                                                                                    color: colorOrange,
                                                                                  ),
                                                                                  child: Icon(Icons.delete_outline, color: Color(0xfffcccccc)))),
                                                                    )
                                                                  : (user.userLoginCurren['vaitro'] != 7 &&
                                                                          user.userLoginCurren['vaitro']['level'] > 1 &&
                                                                          (user.userLoginCurren['departId'] ==
                                                                              listRecruitResult[i].nguoidenghi!.departId))
                                                                      ? Consumer<NavigationModel>(
                                                                          builder: (context, navigationModel, child) => Container(
                                                                              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                              child: (listRecruitResult[i].appRove == 0 ||
                                                                                      listRecruitResult[i].appRove == 2)
                                                                                  ? InkWell(
                                                                                      onTap: (listRecruitResult[i].appRove == 0 ||
                                                                                              listRecruitResult[i].appRove == 2)
                                                                                          ? () {
                                                                                              showDialog(
                                                                                                  context: context,
                                                                                                  builder: (BuildContext context) => AlertDialog(
                                                                                                        title: Row(
                                                                                                            mainAxisAlignment:
                                                                                                                MainAxisAlignment.spaceBetween,
                                                                                                            children: [
                                                                                                              SizedBox(
                                                                                                                child: Row(
                                                                                                                  children: [
                                                                                                                    Container(
                                                                                                                      width: 40,
                                                                                                                      height: 40,
                                                                                                                      child: Image.asset(
                                                                                                                          'assets/images/logoAAM.png'),
                                                                                                                      margin:
                                                                                                                          EdgeInsets.only(right: 10),
                                                                                                                    ),
                                                                                                                    Text(
                                                                                                                      'Xác nhận xóa đề nghị tuyển dụng ',
                                                                                                                      style: titleAlertDialog,
                                                                                                                    ),
                                                                                                                  ],
                                                                                                                ),
                                                                                                              ),
                                                                                                              IconButton(
                                                                                                                onPressed: () =>
                                                                                                                    {Navigator.pop(context)},
                                                                                                                icon: Icon(
                                                                                                                  Icons.close,
                                                                                                                ),
                                                                                                              ),
                                                                                                            ]),
                                                                                                        //content
                                                                                                        content: Container(
                                                                                                          width: 400,
                                                                                                          height: 150,
                                                                                                          child: Column(
                                                                                                            mainAxisAlignment:
                                                                                                                MainAxisAlignment.spaceBetween,
                                                                                                            crossAxisAlignment:
                                                                                                                CrossAxisAlignment.start,
                                                                                                            children: [
                                                                                                              //đường line
                                                                                                              Container(
                                                                                                                margin: marginTopBottomHorizontalLine,
                                                                                                                child: Divider(
                                                                                                                  thickness: 1,
                                                                                                                  color: ColorHorizontalLine,
                                                                                                                ),
                                                                                                              ),
                                                                                                              Container(
                                                                                                                child: Text(
                                                                                                                    'Xóa đề nghị tuyển dụng: "${listRecruitResult[i].title}"'),
                                                                                                              ),
                                                                                                              //đường line
                                                                                                              Container(
                                                                                                                margin: marginTopBottomHorizontalLine,
                                                                                                                child: Divider(
                                                                                                                  thickness: 1,
                                                                                                                  color: ColorHorizontalLine,
                                                                                                                ),
                                                                                                              ),
                                                                                                            ],
                                                                                                          ),
                                                                                                        ),
                                                                                                        //actions
                                                                                                        actions: [
                                                                                                          ElevatedButton(
                                                                                                            onPressed: () => Navigator.pop(context),
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
                                                                                                              var response = await httpDelete(
                                                                                                                  "/api/tuyendung/del/${listRecruitResult[i].id}",
                                                                                                                  context);
                                                                                                              print(response['body']);
                                                                                                              await getListTDCT(
                                                                                                                  currentPage - 1,
                                                                                                                  findDNTD,
                                                                                                                  user.userLoginCurren['departId']);
                                                                                                              Navigator.pop(context);
                                                                                                              showToast(
                                                                                                                context: context,
                                                                                                                msg:
                                                                                                                    "Xóa đề nghị tuyển dụng thành công",
                                                                                                                color:
                                                                                                                    Color.fromARGB(136, 72, 238, 67),
                                                                                                                icon: const Icon(Icons.done),
                                                                                                              );
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
                                                                                            }
                                                                                          : null,
                                                                                      child: Icon(Icons.delete_outline,
                                                                                          color: (listRecruitResult[i].appRove == 0 ||
                                                                                                  listRecruitResult[i].appRove == 2)
                                                                                              ? Colors.red
                                                                                              : Color(0xfffcccccc)))
                                                                                  : Tooltip(
                                                                                      message: 'Đã phê duyệt',
                                                                                      textStyle: const TextStyle(
                                                                                        fontSize: 15,
                                                                                      ),
                                                                                      decoration: BoxDecoration(
                                                                                        borderRadius: BorderRadius.circular(25),
                                                                                        color: colorOrange,
                                                                                      ),
                                                                                      child: Icon(Icons.delete_outline, color: Color(0xfffcccccc)))),
                                                                        )
                                                                      : (user.userLoginCurren['vaitro'] != null &&
                                                                              user.userLoginCurren['vaitro']['level'] != 0 &&
                                                                              (user.userLoginCurren['departId'] ==
                                                                                  listRecruitResult[i].nguoidenghi!.departId))
                                                                          ? Consumer<NavigationModel>(
                                                                              builder: (context, navigationModel, child) => Container(
                                                                                  margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                                  child: (listRecruitResult[i].appRove == 0 ||
                                                                                          listRecruitResult[i].appRove == 2)
                                                                                      ? InkWell(
                                                                                          onTap: (listRecruitResult[i].appRove == 0 ||
                                                                                                  listRecruitResult[i].appRove == 2)
                                                                                              ? () {
                                                                                                  showDialog(
                                                                                                      context: context,
                                                                                                      builder: (BuildContext context) => AlertDialog(
                                                                                                            title: Row(
                                                                                                                mainAxisAlignment:
                                                                                                                    MainAxisAlignment.spaceBetween,
                                                                                                                children: [
                                                                                                                  SizedBox(
                                                                                                                    child: Row(
                                                                                                                      children: [
                                                                                                                        Container(
                                                                                                                          width: 40,
                                                                                                                          height: 40,
                                                                                                                          child: Image.asset(
                                                                                                                              'assets/images/logoAAM.png'),
                                                                                                                          margin: EdgeInsets.only(
                                                                                                                              right: 10),
                                                                                                                        ),
                                                                                                                        Text(
                                                                                                                          'Xác nhận xóa đề nghị tuyển dụng ',
                                                                                                                          style: titleAlertDialog,
                                                                                                                        ),
                                                                                                                      ],
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                  IconButton(
                                                                                                                    onPressed: () =>
                                                                                                                        {Navigator.pop(context)},
                                                                                                                    icon: Icon(
                                                                                                                      Icons.close,
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ]),
                                                                                                            //content
                                                                                                            content: Container(
                                                                                                              width: 400,
                                                                                                              height: 150,
                                                                                                              child: Column(
                                                                                                                mainAxisAlignment:
                                                                                                                    MainAxisAlignment.spaceBetween,
                                                                                                                crossAxisAlignment:
                                                                                                                    CrossAxisAlignment.start,
                                                                                                                children: [
                                                                                                                  //đường line
                                                                                                                  Container(
                                                                                                                    margin:
                                                                                                                        marginTopBottomHorizontalLine,
                                                                                                                    child: Divider(
                                                                                                                      thickness: 1,
                                                                                                                      color: ColorHorizontalLine,
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                  Container(
                                                                                                                    child: Text(
                                                                                                                        'Xóa đề nghị tuyển dụng: "${listRecruitResult[i].title}"'),
                                                                                                                  ),
                                                                                                                  //đường line
                                                                                                                  Container(
                                                                                                                    margin:
                                                                                                                        marginTopBottomHorizontalLine,
                                                                                                                    child: Divider(
                                                                                                                      thickness: 1,
                                                                                                                      color: ColorHorizontalLine,
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ],
                                                                                                              ),
                                                                                                            ),
                                                                                                            //actions
                                                                                                            actions: [
                                                                                                              ElevatedButton(
                                                                                                                onPressed: () =>
                                                                                                                    Navigator.pop(context),
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
                                                                                                                  var response = await httpDelete(
                                                                                                                      "/api/tuyendung/del/${listRecruitResult[i].id}",
                                                                                                                      context);
                                                                                                                  print(response['body']);
                                                                                                                  await getListTDCT(
                                                                                                                      currentPage - 1,
                                                                                                                      findDNTD,
                                                                                                                      user.userLoginCurren[
                                                                                                                          'departId']);
                                                                                                                  Navigator.pop(context);
                                                                                                                  showToast(
                                                                                                                    context: context,
                                                                                                                    msg:
                                                                                                                        "Xóa đề nghị tuyển dụng thành công",
                                                                                                                    color: Color.fromARGB(
                                                                                                                        136, 72, 238, 67),
                                                                                                                    icon: const Icon(Icons.done),
                                                                                                                  );
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
                                                                                                }
                                                                                              : null,
                                                                                          child: Icon(Icons.delete_outline,
                                                                                              color: (listRecruitResult[i].appRove == 0 ||
                                                                                                      listRecruitResult[i].appRove == 2)
                                                                                                  ? Colors.red
                                                                                                  : Color(0xfffcccccc)))
                                                                                      : Tooltip(
                                                                                          message: 'Đã phê duyệt',
                                                                                          textStyle: const TextStyle(
                                                                                            fontSize: 15,
                                                                                          ),
                                                                                          decoration: BoxDecoration(
                                                                                            borderRadius: BorderRadius.circular(25),
                                                                                            color: colorOrange,
                                                                                          ),
                                                                                          child:
                                                                                              Icon(Icons.delete_outline, color: Color(0xfffcccccc)))),
                                                                            )
                                                                          : Text(""),
                                                            ],
                                                          )),
                                                        ],
                                                      )
                                                  ]),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    else if (snapshot.hasError)
                                      Text("Fail! ${snapshot.error}")
                                    else if (!snapshot.hasData)
                                      Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    Container(
                                      margin: const EdgeInsets.only(right: 50),
                                      child: DynamicTablePagging(
                                        rowCount,
                                        currentPage,
                                        rowPerPage,
                                        pageChangeHandler: (page) {
                                          setState(() {
                                            getListTDCT(page - 1, findDNTD, user.userLoginCurren['departId']);
                                            currentPage = page - 1;
                                          });
                                        },
                                        rowPerPageChangeHandler: (rowPerPage) {
                                          setState(() {
                                            this.rowPerPage = rowPerPage!;
                                            this.firstRow = page * currentPage;
                                            getListTDCT(0, findDNTD, user.userLoginCurren['departId']);
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Footer(marginFooter: EdgeInsets.only(top: 5), paddingFooter: EdgeInsets.all(15)),
                    SizedBox(height: 20)
                  ],
                );
              },
            ),
          );
        } else if (listRule.hasError) {
          return Text('${listRule.error}');
        }

        // By default, show a loading spinner.
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
