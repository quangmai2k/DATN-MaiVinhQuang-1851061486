// ignore: duplicate_ignore
// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/forms/market_development/utils/funciton.dart';
import 'package:gentelella_flutter/widgets/ui/kiem_soat/quyet_dinh_xu_phat_update/rule.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../api.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/model.dart';
import '../../../forms/nhan_su/setting-data/duty.dart';
import '../../../forms/nhan_su/setting-data/userAAM.dart';

class ThemQuyetDinhXuPhat extends StatefulWidget {
  const ThemQuyetDinhXuPhat({Key? key}) : super(key: key);

  @override
  State<ThemQuyetDinhXuPhat> createState() => _ThemQuyetDinhXuPhatState();
}

class _ThemQuyetDinhXuPhatState extends State<ThemQuyetDinhXuPhat> {
  var ngayXuPhat;
  var fileName;
  var file;
  late Future<dynamic> getApi;
  Future<List<Rule>> getListRule() async {
    List<Rule> resultRule = [];
    var response = await httpGet(
        "/api/quydinh/get/page?sort=id&filter=parentId:0", context);
    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        content = body['content'];
        resultRule = content.map((e) {
          return Rule.fromJson(e);
        }).toList();
      });
    }
    return resultRule;
  }

  bool _isNumericGreater(String str) {
    bool status = false;
    try {
      int number = int.parse(str);
      if (number >= 0) status = true;
      return status;
    } catch (e) {
      status = false;
      return status;
    }
  }

  late List<Quyetdinhxuphat> listQuyetDinhXuPhat = [];
  //quy định cha
  int quyDinhCha = 0;
  Future<List<QuyDinh1>> getQuyDinh(int parentId) async {
    List<QuyDinh1> quydinh = [];
    var response1;
    response1 = await httpGet(
        "/api/quydinh/get/page?sort=id&filter=parentId:$parentId and deleted: false",
        context);
    if (response1.containsKey("body")) {
      var resultQuyDinh = jsonDecode(response1["body"]);
      setState(() {
        for (var item in resultQuyDinh['content']) {
          QuyDinh1 e = new QuyDinh1(
              id: item['id'],
              ruleName: item['ruleName'],
              parentId: item['parentId']);
          quydinh.add(e);
        }
      });
      //return quydinh;
    }
    return quydinh;
  }

  //Quy định chi tiết
  Future<List<QuyDinh1>> getQuyDinhChiTiet(int? parentId) async {
    List<QuyDinh1> quydinh = [];
    var response1;
    if (parentId == 0) {
      response1 = await httpGet(
          "/api/quydinh/get/page?filter=(dutyId is null or dutyId :0)",
          context);
      print("/api/quydinh/get/page?filter=(dutyId is null or dutyId :0)");
    } else {
      response1 = await httpGet(
          "/api/quydinh/get/page?filter=parentId:$parentId", context);
    }

    if (response1.containsKey("body")) {
      var resultQuyDinh = jsonDecode(response1["body"]);
      setState(() {
        for (var item in resultQuyDinh['content']) {
          QuyDinh1 e = new QuyDinh1(
            id: item['id'] ?? 0,
            ruleId: item['ruleId'],
            ruleName: (item != null) ? item['ruleName'] : "",
            parentId: (item != null) ? item['parentId'] : 0,
            // fines: item['fines'] ?? 0,
            // content: item['content'] ?? ""
          );
          quydinh.add(e);
        }
      });
      return quydinh;
    }
    return quydinh;
  }

  //TTS
  Future<List<TTS>> getTTS() async {
    List<TTS> tTS = [];
    var response =
        await httpGet("/api/nguoidung/get/page?filter=isTts:1", context);
    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        content = body['content'];
        for (var item in content) {
          TTS e = TTS(
            id: item['id'],
            userCode: item['userCode'],
            fullName: item['fullName'],
            birthDate: (item['birthDate'] != null)
                ? DateTime.parse(item['birthDate'])
                : null,
            careUser: item['careUser'] ?? 0,
            nameCareUser: (item['nhanvientuyendung'] != null)
                ? item['nhanvientuyendung']['fullName']
                : "",
            orderId: item['orderId'] ?? 0,
            donHang:
                (item['donhang'] != null) ? item['donhang']['orderName'] : "",
          );
          tTS.add(e);
        }
      });

      return tTS;
    }
    return tTS;
  }

  //Cán bộ
  Future<List<UserAAM>> getListUser() async {
    List<UserAAM> listUserAAM = [];

    var response2 =
        await httpGet("/api/nguoidung/get/page?filter=isAam:1", context);
    var body = jsonDecode(response2['body']);
    var content = [];
    if (response2.containsKey("body")) {
      setState(() {
        content = body['content'];
        for (var item in content) {
          UserAAM e = new UserAAM(
              id: item['id'],
              fullName: item['fullName'],
              userCode: item['userCode']);
          listUserAAM.add(e);
        }
        // listUserAAM
      });
      return listUserAAM;
    }
    return listUserAAM;
  }

//Vai trò
  Future<List<Duty>> getListDuty() async {
    List<Duty> resultDuty = [];
    var response = await httpGet("/api/vaitro/get/page?sort=id,desc", context);
    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        content = body['content'];
        resultDuty = content.map((e) {
          return Duty.fromJson(e);
        }).toList();
        Duty all =
            new Duty(id: -1, departId: 0, dutyName: 'TTS', departName: "");
        resultDuty.insert(0, all);
      });
    }
    return resultDuty;
  }

  var decisionId;
  addQuyetDinhXuPhat(int ruleId) async {
    var requestBody = {
      "ruleId": ruleId,
      "finesApproval": 0,
      "relateFile": fileName,
      // "decisionDate": DateFormat("yyyy-MM-dd").format(DateTime.now().toLocal()),
    };
    var response;
    print(requestBody);
    response =
        await httpPost("/api/quyetdinh-xuphat/post/save", requestBody, context);

    if (response.containsKey("body")) {
      setState(() {
        decisionId = jsonDecode(response["body"]);
      });
      print("id sau khi post:" + decisionId.toString());
    }

    return decisionId;
  }

  addQuyetDinhXuPhatChiTiet(List<Quyetdinhxuphat> listQuyetDinhXuPhat) async {
    // ignore: unused_local_variable
    var requestBody;
    for (var element in listQuyetDinhXuPhat) {
      if (element.option == "0") {
        requestBody = {
          "decisionId": decisionId,
          "userId": element.tts!.id,
          "ruleDetailId": element.quyDinhcon!.id,
          "finesTotal": element.quyDinhcon!.fines,
          "reason": (element.reason != null)
              ? element.reason
              : element.quyDinhcon!.content,
          // "violateDate": null
        };
      } else {
        requestBody = {
          "decisionId": decisionId,
          "userId": element.userAAM!.id,
          "ruleDetailId": element.quyDinhcon!.id,
          "finesTotal": element.quyDinhcon!.fines,
          "reason": (element.reason != null)
              ? element.reason
              : element.quyDinhcon!.content
        };
      }
      await httpPost(
          "/api/quyetdinh-xuphat-chitiet/post/save", requestBody, context);
    }
  }

  var listItemsDoiTuongPhat = [
    {'name': 'Thực tập sinh', 'value': '0'},
    {'name': 'Nhân viên', 'value': '1'}
  ];
  dynamic selectedDoiTuongPhat = '0';
  callApi() async {
    var listData;
    var response =
        await httpGet("/api/quydinh/get/page?sort=id&filter=parentId", context);
    if (response.containsKey("body")) {
      setState(() {
        listData = jsonDecode(response["body"]);
      });
      // listItemsDoiTuongPhat = [];
      // listItemsDoiTuongPhat.add({'value': '0', 'name': '---'});
      // for (var row in listData['content']) {
      //   listItemsDoiTuongPhat
      //       .add({'value': row['id'].toString(), 'name': row['ruleName']});
      // }
    }

    return 0;
  }

  List<TextEditingController> ghiChu = [];
  @override
  void initState() {
    getApi = callApi();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: getApi,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            decoration: BoxDecoration(
              color: colorWhite,
              borderRadius: borderRadiusContainer,
              boxShadow: [boxShadowContainer],
              border: borderAllContainerBox,
            ),
            padding: paddingBoxContainer,
            margin: EdgeInsets.only(top: 20, left: 20, right: 20),
            child: ListView(controller: ScrollController(), children: [
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
              Container(
                margin: marginTopBottomHorizontalLine,
                child: Divider(
                  thickness: 1,
                  color: ColorHorizontalLine,
                ),
              ),
              Row(
                children: [
                  SizedBox(width: 20),
                  Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              Text('Tên quy định:', style: titleWidgetBox),
                            ],
                          ),
                        ),
                        Expanded(
                            flex: 5,
                            child: Container(
                              color: Colors.white,
                              width: MediaQuery.of(context).size.width * 0.20,
                              height: 40,
                              child: DropdownSearch<Rule>(
                                hint: "Chọn",
                                maxHeight: 350,
                                mode: Mode.MENU,
                                showSearchBox: true,
                                onFind: (String? filter) => getListRule(),
                                itemAsString: (Rule? u) => u!.ruleName,
                                dropdownSearchDecoration: styleDropDown,
                                onChanged: (value) {
                                  setState(() {
                                    quyDinhCha = value!.id;
                                    print(quyDinhCha);

                                    if (listQuyetDinhXuPhat.length == 0)
                                      listQuyetDinhXuPhat.add(
                                          new Quyetdinhxuphat(
                                              option: "0",
                                              vatro: Duty(
                                                  id: -1,
                                                  departId: 0,
                                                  dutyName: 'TTS',
                                                  departName: "")));
                                    else {
                                      for (var i = 0;
                                          i < listQuyetDinhXuPhat.length;
                                          i++) {
                                        listQuyetDinhXuPhat[i].quyDinhcon =
                                            QuyDinh1(id: -1, ruleName: '');
                                      }
                                    }
                                  });
                                },
                              ),
                            )),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 50,
                  ),
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Expanded(
                            flex: 3,
                            child: Text("Thông tin liên quan: ",
                                style: titleWidgetBox)),
                        Expanded(
                            flex: 5,
                            child: TextButton(
                              onPressed: () async {
                                file = await FilePicker.platform.pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: [
                                    'pdf',
                                    'docx',
                                    'jpeg',
                                    'png',
                                    'jpg'
                                  ],
                                  withReadStream: true, //
                                );
                                if (file != null) {
                                  fileName =
                                      await uploadFile(file, context: context);
                                  setState(() {
                                    // listRelateFile["content"][0]["realateFile"] = fileName;
                                  });
                                }
                              },
                              child: file == null
                                  ? Icon(
                                      Icons.upload_file,
                                      color: Colors.blue[400],
                                    )
                                  : Text(file.files.first.name),
                            ))
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Column(children: [
                for (int i = 0; i < listQuyetDinhXuPhat.length; i++)
                  Container(
                    margin: EdgeInsets.only(top: 15, bottom: 10),
                    padding: EdgeInsets.only(left: 20, right: 20),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 250, 250, 250),
                      borderRadius: borderRadiusContainer,
                      boxShadow: [boxShadowContainer],
                      border: borderAllContainerBox,
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        Row(children: [
                          Expanded(
                            flex: 3,
                            child: DropdownBtnSearch(
                              isAll: false,
                              label: 'Đối tượng phạt',
                              listItems: listItemsDoiTuongPhat,
                              search: TextEditingController(),
                              isSearch: true,
                              selectedValue: selectedDoiTuongPhat,
                              setSelected: (selected) {
                                listQuyetDinhXuPhat[i].option = selected;
                                setState(() {});
                              },
                            ),
                          ),
                          SizedBox(
                            width: 30,
                          ),
                          Expanded(
                            flex: 4,
                            child: Row(),
                          ),
                        ]),
                        SizedBox(
                          height: 10,
                        ),
                        (listQuyetDinhXuPhat[i].option == "0") //TTS
                            ? Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              child: Text.rich(TextSpan(
                                                  text: 'TTS',
                                                  style: titleWidgetBox,
                                                  children: <InlineSpan>[
                                                    TextSpan(
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    )
                                                  ])),
                                            ),
                                            Container(
                                              margin:
                                                  const EdgeInsets.only(top: 5),
                                              color: Colors.white,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.20,
                                              height: 40,
                                              child: DropdownSearch<TTS>(
                                                hint: "Chọn",
                                                maxHeight: 300,
                                                mode: Mode.MENU,
                                                showSearchBox: true,
                                                onFind: (String? filter) =>
                                                    getTTS(),
                                                itemAsString: (TTS? u) =>
                                                    "${u!.fullName} (${u.userCode})",
                                                dropdownSearchDecoration:
                                                    styleDropDown,
                                                selectedItem:
                                                    listQuyetDinhXuPhat[i].tts,
                                                onChanged: (value) {
                                                  setState(() {
                                                    listQuyetDinhXuPhat[i].tts =
                                                        value;
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(flex: 1, child: Container()),
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              child: Text.rich(TextSpan(
                                                  text: 'Ngày sinh',
                                                  style: titleWidgetBox,
                                                  children: <InlineSpan>[
                                                    TextSpan(
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    )
                                                  ])),
                                            ),
                                            Container(
                                              margin:
                                                  const EdgeInsets.only(top: 5),
                                              color: Colors.white,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.20,
                                              height: 40,
                                              child: TextFormField(
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0.0),
                                                  ),
                                                ),
                                                enabled: false,
                                                controller:
                                                    TextEditingController(
                                                        text: (listQuyetDinhXuPhat[
                                                                        i]
                                                                    .tts !=
                                                                null)
                                                            ? (listQuyetDinhXuPhat[
                                                                            i]
                                                                        .tts!
                                                                        .birthDate !=
                                                                    null)
                                                                ? (listQuyetDinhXuPhat[
                                                                                i]
                                                                            .tts!
                                                                            .birthDate!
                                                                            .month <
                                                                        10)
                                                                    ? (listQuyetDinhXuPhat[i].tts!.birthDate!.day <
                                                                            10)
                                                                        ? "0${listQuyetDinhXuPhat[i].tts!.birthDate!.day}-0${listQuyetDinhXuPhat[i].tts!.birthDate!.month}-${listQuyetDinhXuPhat[i].tts!.birthDate!.year}"
                                                                        : "${listQuyetDinhXuPhat[i].tts!.birthDate!.day}-0${listQuyetDinhXuPhat[i].tts!.birthDate!.month}-${listQuyetDinhXuPhat[i].tts!.birthDate!.year}"
                                                                    : (listQuyetDinhXuPhat[i].tts!.birthDate!.day <
                                                                            10)
                                                                        ? "0${listQuyetDinhXuPhat[i].tts!.birthDate!.day}-${listQuyetDinhXuPhat[i].tts!.birthDate!.month}-${listQuyetDinhXuPhat[i].tts!.birthDate!.year}"
                                                                        : "${listQuyetDinhXuPhat[i].tts!.birthDate!.day}-${listQuyetDinhXuPhat[i].tts!.birthDate!.month}-${listQuyetDinhXuPhat[i].tts!.birthDate!.year}"
                                                                : ""
                                                            : ""),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Expanded(flex: 1, child: Container()),
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              child: Text.rich(TextSpan(
                                                  text: 'Cán bộ tuyển dụng',
                                                  style: titleWidgetBox,
                                                  children: <InlineSpan>[
                                                    TextSpan(
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    )
                                                  ])),
                                            ),
                                            Container(
                                              margin:
                                                  const EdgeInsets.only(top: 5),
                                              color: Colors.white,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.20,
                                              height: 40,
                                              child: TextFormField(
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0.0),
                                                  ),
                                                ),
                                                enabled: false,
                                                controller: TextEditingController(
                                                    text: (listQuyetDinhXuPhat[
                                                                    i]
                                                                .tts !=
                                                            null)
                                                        ? listQuyetDinhXuPhat[i]
                                                                .tts!
                                                                .nameCareUser ??
                                                            ""
                                                        : ""),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Expanded(flex: 1, child: Container()),
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              child: Text.rich(TextSpan(
                                                  text: 'Đơn hàng',
                                                  style: titleWidgetBox,
                                                  children: <InlineSpan>[
                                                    TextSpan(
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    )
                                                  ])),
                                            ),
                                            Container(
                                              margin:
                                                  const EdgeInsets.only(top: 5),
                                              color: Colors.white,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.20,
                                              child: TextFormField(
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0.0),
                                                  ),
                                                ),
                                                enabled: false,
                                                controller: TextEditingController(
                                                    text: (listQuyetDinhXuPhat[
                                                                    i]
                                                                .tts !=
                                                            null)
                                                        ? listQuyetDinhXuPhat[i]
                                                            .tts!
                                                            .donHang
                                                        : ""),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: Text.rich(TextSpan(
                                                    text:
                                                        'Ngày nhập học trúng tuyển',
                                                    style: titleWidgetBox,
                                                    children: <InlineSpan>[
                                                      TextSpan(
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      )
                                                    ])),
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    top: 5),
                                                color: Colors.white,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.20,
                                                height: 40,
                                                child: TextFormField(
                                                  decoration: InputDecoration(
                                                    border: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        width: 1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              0.0),
                                                    ),
                                                  ),
                                                  enabled: false,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Expanded(flex: 1, child: Container()),
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: Text.rich(TextSpan(
                                                    text: 'Nội dung phạt',
                                                    style: titleWidgetBox,
                                                    children: <InlineSpan>[
                                                      TextSpan(
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      )
                                                    ])),
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    top: 5),
                                                color: Colors.white,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.20,
                                                height: 40,
                                                child:
                                                    DropdownSearch<QuyDinh1?>(
                                                  hint: "Chọn",
                                                  maxHeight: 250,
                                                  mode: Mode.MENU,
                                                  showSearchBox: true,
                                                  onFind: (String? filter) =>
                                                      getQuyDinhChiTiet(
                                                          quyDinhCha),
                                                  itemAsString: (QuyDinh1? u) =>
                                                      "${u!.ruleName}",
                                                  dropdownSearchDecoration:
                                                      styleDropDown,
                                                  selectedItem:
                                                      listQuyetDinhXuPhat[i]
                                                          .quyDinhcon,
                                                  onChanged: (value) async {
                                                    setState(() {
                                                      listQuyetDinhXuPhat[i]
                                                          .quyDinhcon = value;
                                                      print(value!.id);
                                                      // resultPhongBan = [Depart(departName: '', id: -1)];
                                                    });
                                                  },
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Expanded(flex: 1, child: Container()),
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: Text.rich(TextSpan(
                                                    text: 'Mức phạt',
                                                    style: titleWidgetBox,
                                                    children: <InlineSpan>[
                                                      TextSpan(
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      )
                                                    ])),
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    top: 5),
                                                color: Colors.white,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.20,
                                                // height: 40,
                                                child: TextFieldValidatedForm(
                                                  marginBot: 4,
                                                  type: 'Number',
                                                  height: 40,
                                                  controller:
                                                      TextEditingController(),
                                                  onChange: (value) {
                                                    listQuyetDinhXuPhat[i]
                                                            .quyDinhcon!
                                                            .fines =
                                                        int.tryParse(value);
                                                  },
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Expanded(flex: 1, child: Container()),
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: Text.rich(TextSpan(
                                                    text: 'Ghi chú',
                                                    style: titleWidgetBox,
                                                    children: <InlineSpan>[
                                                      TextSpan(
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      )
                                                    ])),
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    top: 5),
                                                color: Colors.white,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.20,
                                                child: TextFormField(
                                                  decoration: InputDecoration(
                                                    border: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        width: 1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              0.0),
                                                    ),
                                                  ),
                                                  // enabled: false,
                                                  controller: TextEditingController(
                                                      text: (listQuyetDinhXuPhat[
                                                                      i]
                                                                  .quyDinhcon !=
                                                              null)
                                                          ? listQuyetDinhXuPhat[
                                                                      i]
                                                                  .quyDinhcon!
                                                                  .content ??
                                                              ""
                                                          : ""),
                                                  onChanged: (value) {
                                                    listQuyetDinhXuPhat[i]
                                                        .quyDinhcon!
                                                        .content = value;
                                                    listQuyetDinhXuPhat[i]
                                                        .reason = value;
                                                    // print("tong tin cua cb");
                                                  },
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          child: Text.rich(TextSpan(
                                              text: 'Họ tên cán bộ',
                                              style: titleWidgetBox,
                                              children: <InlineSpan>[
                                                TextSpan(
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                )
                                              ])),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(top: 5),
                                          color: Colors.white,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.20,
                                          height: 40,
                                          child: DropdownSearch<UserAAM>(
                                            hint: "Tất cả",
                                            maxHeight: 300,
                                            mode: Mode.MENU,
                                            showSearchBox: true,
                                            onFind: (String? filter) =>
                                                getListUser(),
                                            itemAsString: (UserAAM? u) =>
                                                "${u!.fullName} (${u.userCode})",
                                            dropdownSearchDecoration:
                                                styleDropDown,
                                            onChanged: (value) {
                                              setState(() {
                                                listQuyetDinhXuPhat[i].userAAM =
                                                    value;
                                                // print("tong tien cua tts");
                                                // print("Id nhân viên: ${listQuyetDinhXuPhat[i].userAAM!.id}");
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(flex: 1, child: Container()),
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          child: Text.rich(TextSpan(
                                              text: 'Nội dung phạt',
                                              style: titleWidgetBox,
                                              children: <InlineSpan>[
                                                TextSpan(
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                )
                                              ])),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(top: 5),
                                          color: Colors.white,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.20,
                                          height: 40,
                                          child: DropdownSearch<QuyDinh1?>(
                                            hint: "Chọn",
                                            maxHeight: 250,
                                            mode: Mode.MENU,
                                            showSearchBox: true,
                                            onFind: (String? filter) =>
                                                getQuyDinhChiTiet(quyDinhCha),
                                            itemAsString: (QuyDinh1? u) =>
                                                "${u!.ruleName}",
                                            dropdownSearchDecoration:
                                                styleDropDown,
                                            selectedItem: listQuyetDinhXuPhat[i]
                                                .quyDinhcon,
                                            onChanged: (value) async {
                                              setState(() {
                                                listQuyetDinhXuPhat[i]
                                                    .quyDinhcon = value;
                                                print(value!.id);
                                              });
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Expanded(flex: 1, child: Container()),
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          child: Text.rich(TextSpan(
                                              text: 'Mức phạt',
                                              style: titleWidgetBox,
                                              children: <InlineSpan>[
                                                TextSpan(
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                )
                                              ])),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(top: 5),
                                          color: Colors.white,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.20,
                                          child: TextFieldValidatedForm(
                                            marginBot: 4,
                                            type: 'Number',
                                            height: 40,
                                            controller: TextEditingController(),
                                            onChange: (value) {
                                              listQuyetDinhXuPhat[i]
                                                  .quyDinhcon!
                                                  .fines = int.tryParse(value);
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Expanded(flex: 1, child: Container()),
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          child: Text.rich(TextSpan(
                                              text: 'Ghi chú',
                                              style: titleWidgetBox,
                                              children: <InlineSpan>[
                                                TextSpan(
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                )
                                              ])),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(top: 5),
                                          color: Colors.white,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.20,
                                          child: TextFormField(
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                            ),
                                            // enabled: false,
                                            controller: TextEditingController(
                                                text: (listQuyetDinhXuPhat[i]
                                                            .quyDinhcon !=
                                                        null)
                                                    ? listQuyetDinhXuPhat[i]
                                                            .quyDinhcon!
                                                            .content ??
                                                        ""
                                                    : ""),
                                            onChanged: (value) {
                                              print(value);
                                              listQuyetDinhXuPhat[i]
                                                  .quyDinhcon!
                                                  .content = value;
                                              listQuyetDinhXuPhat[i].reason =
                                                  value;
                                              // print("tong tin cua cb");
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                        if (i == listQuyetDinhXuPhat.length - 1)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                    right: 20, top: 10, bottom: 10),
                                width: 50,
                                height: 40,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    backgroundColor: Colors.grey[300],
                                    primary: Theme.of(context).iconTheme.color,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .caption
                                        ?.copyWith(
                                            fontSize: 10.0, letterSpacing: 2.0),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      listQuyetDinhXuPhat.removeAt(i);
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            "-",
                                            style: TextStyle(
                                              color: Color(0xff009C87),
                                              fontSize: 26,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    right: 20, top: 10, bottom: 10),
                                width: 50,
                                height: 40,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    backgroundColor: Color(0xff009C87),
                                    primary: Theme.of(context).iconTheme.color,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .caption
                                        ?.copyWith(
                                            fontSize: 10.0, letterSpacing: 2.0),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      listQuyetDinhXuPhat.add(Quyetdinhxuphat(
                                        option: "0",
                                        vatro: Duty(
                                          id: -1,
                                          departId: 0,
                                          dutyName: 'TTS',
                                          departName: "",
                                        ),
                                      ));
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: Center(
                                        child: Text("+",
                                            style: TextStyle(
                                                fontSize: 26,
                                                color: Colors.white)),
                                      ))
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                    right: 20, top: 10, bottom: 10),
                                width: 50,
                                height: 40,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    backgroundColor: Colors.grey[300],
                                    primary: Theme.of(context).iconTheme.color,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .caption
                                        ?.copyWith(
                                            fontSize: 10.0, letterSpacing: 2.0),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      listQuyetDinhXuPhat.removeAt(i);
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            "-",
                                            style: TextStyle(
                                              color: Color(0xff009C87),
                                              fontSize: 26,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    (listQuyetDinhXuPhat.length > 0)
                        ? Row(
                            children: [
                              // Container(
                              //   margin: EdgeInsets.fromLTRB(0, 20, 20, 0),
                              //   child: TextButton(
                              //     style: TextButton.styleFrom(
                              //       padding: const EdgeInsets.symmetric(
                              //         vertical: 16.0,
                              //         horizontal: 16.0,
                              //       ),
                              //       shape: RoundedRectangleBorder(
                              //         borderRadius: BorderRadius.circular(5.0),
                              //       ),
                              //       backgroundColor: Color.fromRGBO(245, 117, 29, 1),
                              //       primary: Theme.of(context).iconTheme.color,
                              //       textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                              //     ),
                              //     onPressed: () async {
                              //       // await exportExcel(listQuyetDinhXuPhat);
                              //     },
                              //     child: Row(
                              //       children: [
                              //         Icon(Icons.upload_file, color: Colors.white),
                              //         Text('Xuất file', style: textButton),
                              //       ],
                              //     ),
                              //   ),
                              // ),
                              Consumer<NavigationModel>(
                                builder: (context, navigationModel, child) =>
                                    Container(
                                  margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 20.0,
                                        horizontal: 20.0,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      backgroundColor:
                                          Color.fromRGBO(245, 117, 29, 1),
                                      primary:
                                          Theme.of(context).iconTheme.color,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .caption
                                          ?.copyWith(
                                              fontSize: 10.0,
                                              letterSpacing: 2.0),
                                    ),
                                    onPressed: () async {
                                      bool checkValidate = true;
                                      if (listQuyetDinhXuPhat.isEmpty) {
                                        showToast(
                                            context: context,
                                            msg: "Không có quyết định nào",
                                            color: Colors.red,
                                            icon: Icon(Icons.warning));
                                      } else {
                                        for (var row in listQuyetDinhXuPhat) {
                                          if ((row.tts == null &&
                                                  row.userAAM == null) ||
                                              row.quyDinhcon == null ||
                                              row.quyDinhcon!.fines == null &&
                                                  ((row.quyDinhcon!.content !=
                                                              null &&
                                                          row
                                                              .quyDinhcon!
                                                              .content!
                                                              .isEmpty) ||
                                                      row.quyDinhcon!.content ==
                                                          null)) {
                                            checkValidate = false;
                                          }
                                        }
                                        if (checkValidate) {
                                          await addQuyetDinhXuPhat(quyDinhCha);
                                          await addQuyetDinhXuPhatChiTiet(
                                              listQuyetDinhXuPhat);
                                          // await updateRuleDetail(listQuyetDinhXuPhat);
                                          showToast(
                                              context: context,
                                              msg:
                                                  "Thêm quyết định xử phạt thành công",
                                              color: Colors.green,
                                              icon: Icon(Icons.done));
                                          navigationModel.add(
                                              pageUrl: "/quyet-dinh-xu-phat");
                                        } else {
                                          showToast(
                                              context: context,
                                              msg: "Hãy nhập đầy đủ thông tin ",
                                              color: Colors.red,
                                              icon: Icon(Icons.warning));
                                        }
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        Text('Lưu', style: textButton),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        : Container(),
                    Consumer<NavigationModel>(
                      builder: (context, navigationModel, child) => Container(
                        margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 20.0,
                              horizontal: 20.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            backgroundColor: Color.fromRGBO(245, 117, 29, 1),
                            primary: Theme.of(context).iconTheme.color,
                            textStyle: Theme.of(context)
                                .textTheme
                                .caption
                                ?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            navigationModel.add(pageUrl: "/quyet-dinh-xu-phat");
                            setState(() {});
                          },
                          child: Row(
                            children: [
                              Text('Hủy', style: textButton),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ])
            ]),
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        // By default, show a loading spinner.
        return const CircularProgressIndicator();
      },
    );
  }
}

class TTS {
  int? id;
  String? userCode;
  String? fullName;
  DateTime? birthDate;
  int? careUser;
  String? nameCareUser;
  int? orderId;
  String? donHang;
  String? ngayTrungTuyen;
  TTS(
      {this.id,
      this.fullName,
      this.userCode,
      this.birthDate,
      this.careUser,
      this.nameCareUser,
      this.orderId,
      this.donHang,
      this.ngayTrungTuyen});
}

class QuyDinh1 {
  int id;
  String ruleName;
  int? ruleId;
  int? parentId;
  int? object;
  int? fines;
  String? content;
  QuyDinh1(
      {required this.id,
      this.parentId,
      this.ruleId,
      required this.ruleName,
      this.object,
      this.fines,
      this.content});
}

class Quyetdinhxuphat {
  int? quyetDinhCha;
  dynamic option; //0 là TTS, 1 Cán bộ
  TTS? tts;
  UserAAM? userAAM;
  Duty? vatro;
  QuyDinh1? quyDinhcon;
  String? reason;
  Quyetdinhxuphat(
      {this.quyetDinhCha,
      this.option,
      this.tts,
      this.vatro,
      this.quyDinhcon,
      this.userAAM,
      this.reason});
}
