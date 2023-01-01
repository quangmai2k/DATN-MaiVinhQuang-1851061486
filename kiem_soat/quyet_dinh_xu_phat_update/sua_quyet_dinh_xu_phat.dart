// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/kiem_soat/quyet_dinh_xu_phat_update/rule.dart';
import 'package:provider/provider.dart';
import '../../../../api.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/model.dart';
import '../../../forms/market_development/utils/funciton.dart';
import '../../../forms/nhan_su/setting-data/duty.dart';
import '../../../forms/nhan_su/setting-data/userAAM.dart';
import '../../navigation.dart';

class SuaQuyetDinhXuPhat extends StatefulWidget {
  final String id;
  SuaQuyetDinhXuPhat({Key? key, required this.id}) : super(key: key);

  @override
  State<SuaQuyetDinhXuPhat> createState() => _SuaQuyetDinhXuPhatState();
}

class _SuaQuyetDinhXuPhatState extends State<SuaQuyetDinhXuPhat> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
        widgetBody: SuaQuyetDinhXuPhatBody(
      id: widget.id,
    ));
  }
}

class SuaQuyetDinhXuPhatBody extends StatefulWidget {
  final String id;
  const SuaQuyetDinhXuPhatBody({Key? key, required this.id}) : super(key: key);

  @override
  State<SuaQuyetDinhXuPhatBody> createState() => _SuaQuyetDinhXuPhatBodyState();
}

class _SuaQuyetDinhXuPhatBodyState extends State<SuaQuyetDinhXuPhatBody> {
  Rule selectedRule =
      new Rule(id: 0, ruleName: '', parentId: 0, status: 0, times: 0);
  var ngayXuPhat;
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

  getQuyetDinhXuPhat() async {
    var response =
        await httpGet("/api/quyetdinh-xuphat/get/${widget.id}", context);
    if (response.containsKey("body")) {
      setState(() {
        var body = jsonDecode(response["body"]);
        selectedRule.id = body['ruleId'];
        selectedRule.ruleName = body['quydinh']['ruleName'];
        ngayXuPhat = body['decisionDate'];
      });
    }
  }

  var quyetDinhXuPhatChiTiet = {};
  var listIdRemove = [];
  late List<Quyetdinhxuphat> listQuyetDinhXuPhat = [];
  getQuyetDinhXuPhatChiTiet() async {
    var response = await httpGet(
        "/api/quyetdinh-xuphat-chitiet/get/page?filter= decisionId:${widget.id}",
        context);
    if (response.containsKey("body")) {
      setState(() {
        var body = jsonDecode(response["body"]);
        var content = body["content"];
        for (var element in content) {
          if (element['nguoidung']['isAam'] == 1) {
            Quyetdinhxuphat item = new Quyetdinhxuphat(
                id: element['id'],
                option: '1',
                userAAM: UserAAM(
                    id: element['userId'],
                    fullName: (element['nguoidung'] != null)
                        ? element['nguoidung']['fullName']
                        : "",
                    userCode: (element['nguoidung'] != null)
                        ? element['nguoidung']['userCode']
                        : ""),
                quyDinhcon: QuyDinh1(
                  id: element['ruleDetailId'],
                  ruleName: (element['quydinh_chitiet'] != null)
                      ? element['quydinh_chitiet']['ruleName']
                      : "",
                  fines: element['finesTotal'],
                  content: element['reason'],
                ));

            listQuyetDinhXuPhat.add(item);
          } else if (element['nguoidung']['isTts'] == 1) {
            Quyetdinhxuphat item = new Quyetdinhxuphat(
                id: element['id'],
                option: "0",
                tts: TTS(
                  id: element['nguoidung']['id'],
                  fullName: element['nguoidung']['fullName'],
                  userCode: element['nguoidung']['userCode'],
                  birthDate: (element['nguoidung']['birthDate'] != null)
                      ? DateTime.parse(element['nguoidung']['birthDate'])
                      : null,
                  careUser: element['nguoidung']['careUser'] ?? 0,
                  nameCareUser: (element['nguoidung']['nhanvientuyendung'] !=
                          null)
                      ? element['nguoidung']['nhanvientuyendung']['fullName']
                      : "",
                  orderId: element['nguoidung']['orderId'] ?? 0,
                  donHang: (element['nguoidung']['donhang'] != null)
                      ? element['nguoidung']['donhang']['orderName']
                      : "",
                ),
                quyDinhcon: QuyDinh1(
                  id: element['ruleDetailId'],
                  ruleName: (element['quydinh_chitiet'] != null)
                      ? element['quydinh_chitiet']['ruleName']
                      : "",
                  fines: element['finesTotal'],
                  content: element['reason'],
                ));
            listQuyetDinhXuPhat.add(item);
          }
        }
      });
    }
  }

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

  //quy định cha
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
      print(
          "/api/quydinh/get/page?filter=parentId:$parentId and (dutyId is null or dutyId :0)");
    }

    if (response1.containsKey("body")) {
      var resultQuyDinh = jsonDecode(response1["body"]);
      setState(() {
        for (var item in resultQuyDinh['content']) {
          QuyDinh1 e = new QuyDinh1(
              id: item['id'] ?? 0,
              ruleId: item['ruleId'],
              ruleName:
                  (item['quydinh'] != null) ? item['quydinh']['ruleName'] : "",
              parentId:
                  (item['quydinh'] != null) ? item['quydinh']['parentId'] : 0,
              object: (item['quydinh'] != null) ? item['quydinh']['dutyId'] : 0,
              fines: item['fines'] ?? 0,
              content: item['content'] ?? "");
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
            fullName: item['fullName'],
            userCode: item['userCode'],
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
    var response =
        await httpGet("/api/nguoidung/get/page?filter=isAam:1", context);

    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        var body = jsonDecode(response['body']);
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
  // Future<List<Duty>> getListDuty() async {
  //   List<Duty> resultDuty = [];
  //   var response = await httpGet(
  //       "/api/vaitro/get/page?sort=id,desc&filter=status:1", context);
  //   var body = jsonDecode(response['body']);
  //   var content = [];
  //   if (response.containsKey("body")) {
  //     setState(() {
  //       content = body['content'];
  //       resultDuty = content.map((e) {
  //         return Duty.fromJson(e);
  //       }).toList();
  //       Duty all =
  //           new Duty(id: -1, departId: 0, dutyName: 'TTS', departName: '');
  //       resultDuty.insert(0, all);
  //     });
  //   }
  //   return resultDuty;
  // }

  updateQuyetDinhXuPhat() async {
    var requestBody;
    requestBody = {
      "ruleId": selectedRule.id,
      "decisionDate": ngayXuPhat,
      "finesApproval": 0
    };
    await httpPut(
        "/api/quyetdinh-xuphat/put/${widget.id}", requestBody, context);
  }

  updateQuyetDinhXuPhatChiTiet(
      List<Quyetdinhxuphat> listQuyetDinhXuPhat) async {
    var requestBody;
    for (var element in listQuyetDinhXuPhat) {
      if (element.id != null) {
        if (element.option == "0") {
          requestBody = {
            "userId": element.tts!.id,
            "ruleDetailId": element.quyDinhcon!.id,
            "finesTotal": element.quyDinhcon!.fines,
            "reason": element.reason,
          };
        } else {
          requestBody = {
            "dutyId": element.vatro!.id,
            "userId": element.userAAM!.id,
            "ruleDetailId": element.quyDinhcon!.id,
            "finesTotal": element.quyDinhcon!.fines,
            "reason": element.reason
          };
        }
        await httpPut("/api/quyetdinh-xuphat-chitiet/put/${element.id}",
            requestBody, context);
      } else {
        if (element.option == "0") {
          requestBody = {
            "decisionId": widget.id,
            "userId": element.tts!.id,
            "ruleDetailId": element.quyDinhcon!.id,
            "finesTotal": element.quyDinhcon!.fines,
            "reason": element.quyDinhcon!.reason,
          };
        } else {
          requestBody = {
            "decisionId": widget.id,
            "dutyId": element.vatro!.id,
            "userId": element.userAAM!.id,
            "ruleDetailId": element.quyDinhcon!.id,
            "finesTotal": element.quyDinhcon!.fines,
            "reason": element.quyDinhcon!.reason
          };
        }
        print(element.quyDinhcon!.fines);
        await httpPost(
            "/api/quyetdinh-xuphat-chitiet/post/save", requestBody, context);
      }
    }
  }

  // updateRuleDetail(List<Quyetdinhxuphat> listQuyetDinhXuPhat) async {
  //   var requestBody;
  //   for (var element in listQuyetDinhXuPhat) {
  //     if (element.option == 0) {
  //       requestBody = {"content": element.quyDinhcon!.content};
  //       print(element.quyDinhcon!.fines);
  //     } else {
  //       requestBody = {"content": element.quyDinhcon!.content};
  //     }
  //     print("requestBody:$requestBody");
  //     print(element.quyDinhcon!.fines);
  //     await httpPut("/api/quydinh-chitiet/put/${element.quyDinhcon!.id}", requestBody, context);
  //   }
  // }
  var listItemsDoiTuongPhat = [
    {'name': 'Thực tập sinh', 'value': '0'},
    {'name': 'Nhân viên', 'value': '1'}
  ];
  dynamic selectedDoiTuongPhat = '0';

  deleteQuyetDinhXuPhatChiTiet() async {
    for (int i = 0; i < listIdRemove.length; i++) {
      if (listIdRemove[i] != null) {
        await httpDelete(
            "/api/quyetdinh-xuphat-chitiet/del/${listIdRemove[i]}", context);
      }
    }
  }

  callApi() async {
    await getQuyetDinhXuPhat();
    await getQuyetDinhXuPhatChiTiet();
  }

  @override
  void initState() {
    super.initState();
    callApi();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: ScrollController(),
      children: [
        TitlePage(
          listPreTitle: [
            {'url': "/kiem-soat", 'title': 'Dashboard'},
            {'url': "/quyet-dinh-xu-phat", 'title': 'Quyết định xử phạt'},
          ],
          content: 'Cập nhật',
        ),
        Container(
          decoration: BoxDecoration(
            color: colorWhite,
            borderRadius: borderRadiusContainer,
            boxShadow: [boxShadowContainer],
            border: borderAllContainerBox,
          ),
          padding: paddingBoxContainer,
          margin: EdgeInsets.only(top: 20, left: 20, right: 20),
          child: Column(children: [
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
                              selectedItem: selectedRule,
                              onChanged: (value) {
                                setState(() {
                                  selectedRule = value!;
                                  print(selectedRule.id);
                                  if (listQuyetDinhXuPhat.length == 0)
                                    listQuyetDinhXuPhat.add(new Quyetdinhxuphat(
                                        option: "0",
                                        vatro: Duty(
                                            id: -1,
                                            departId: 0,
                                            dutyName: 'TTS',
                                            departName: '')));
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
                  child: Container(
                      // child: DatePickerBox1(
                      //     label: RichText(
                      //       text: TextSpan(
                      //         text: 'Ngày xử phạt:',
                      //         style: titleWidgetBox,
                      //         children: <TextSpan>[
                      //           TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                      //         ],
                      //       ),
                      //     ),
                      //     isTime: false,
                      //     dateDisplay: (ngayXuPhat != "" && ngayXuPhat != null) ? DateFormat("dd-MM-yyyy").format(DateTime.parse(ngayXuPhat)) : null,
                      //     selectedDateFunction: (day) {
                      //       setState(() {
                      //         if (day != null) ngayXuPhat = "${day.toString().substring(6)}${day.toString().substring(2, 6)}${day.toString().substring(0, 2)}";
                      //         print(ngayXuPhat);
                      //       });
                      //     }),
                      ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(),
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
                            selectedValue: listQuyetDinhXuPhat[i].option,
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
                                              controller: TextEditingController(
                                                  text: (listQuyetDinhXuPhat[i]
                                                              .tts !=
                                                          null)
                                                      ? (listQuyetDinhXuPhat[i]
                                                                  .tts!
                                                                  .birthDate !=
                                                              null)
                                                          ? (listQuyetDinhXuPhat[
                                                                          i]
                                                                      .tts!
                                                                      .birthDate!
                                                                      .month <
                                                                  10)
                                                              ? (listQuyetDinhXuPhat[
                                                                              i]
                                                                          .tts!
                                                                          .birthDate!
                                                                          .day <
                                                                      10)
                                                                  ? "0${listQuyetDinhXuPhat[i].tts!.birthDate!.day}-0${listQuyetDinhXuPhat[i].tts!.birthDate!.month}-${listQuyetDinhXuPhat[i].tts!.birthDate!.year}"
                                                                  : "${listQuyetDinhXuPhat[i].tts!.birthDate!.day}-0${listQuyetDinhXuPhat[i].tts!.birthDate!.month}-${listQuyetDinhXuPhat[i].tts!.birthDate!.year}"
                                                              : (listQuyetDinhXuPhat[
                                                                              i]
                                                                          .tts!
                                                                          .birthDate!
                                                                          .day <
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
                                                  text: (listQuyetDinhXuPhat[i]
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
                                            // height: 40,
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
                                                  text: (listQuyetDinhXuPhat[i]
                                                              .tts !=
                                                          null)
                                                      ? listQuyetDinhXuPhat[i]
                                                              .tts!
                                                              .donHang ??
                                                          ""
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
                                                  text: 'Ngày nhập học',
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
                                              margin:
                                                  const EdgeInsets.only(top: 5),
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
                                                    getQuyDinhChiTiet(
                                                        selectedRule.id),
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
                                                    // print(value!.id);
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
                                              margin:
                                                  const EdgeInsets.only(top: 5),
                                              color: Colors.white,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.20,
                                              child: TextFieldValidatedForm(
                                                marginBot: 4,
                                                type: 'Number',
                                                height: 40,
                                                controller:
                                                    TextEditingController(
                                                        text: (listQuyetDinhXuPhat[
                                                                        i]
                                                                    .quyDinhcon !=
                                                                null)
                                                            ? (listQuyetDinhXuPhat[
                                                                            i]
                                                                        .quyDinhcon!
                                                                        .fines !=
                                                                    null)
                                                                ? "${listQuyetDinhXuPhat[i].quyDinhcon!.fines}"
                                                                : ""
                                                            : ""),
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
                                                // enabled: false,
                                                controller: TextEditingController(
                                                    text: (listQuyetDinhXuPhat[
                                                                    i]
                                                                .quyDinhcon !=
                                                            null)
                                                        ? listQuyetDinhXuPhat[i]
                                                                .quyDinhcon!
                                                                .content ??
                                                            ""
                                                        : ""),
                                                onChanged: (value) {
                                                  listQuyetDinhXuPhat[i]
                                                      .reason = value;
                                                  listQuyetDinhXuPhat[i]
                                                      .quyDinhcon!
                                                      .content = value;
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
                          : Container(
                              margin: EdgeInsets.only(top: 20),
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
                                            selectedItem:
                                                listQuyetDinhXuPhat[i].userAAM,
                                            onChanged: (value) {
                                              setState(() {
                                                listQuyetDinhXuPhat[i].userAAM =
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
                                                getQuyDinhChiTiet(
                                                    selectedRule.id),
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
                                            controller: TextEditingController(
                                                text: (listQuyetDinhXuPhat[i]
                                                            .quyDinhcon !=
                                                        null)
                                                    ? (listQuyetDinhXuPhat[i]
                                                                .quyDinhcon!
                                                                .fines !=
                                                            null)
                                                        ? "${listQuyetDinhXuPhat[i].quyDinhcon!.fines}"
                                                        : ""
                                                    : ""),
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
                                              print(listQuyetDinhXuPhat[i]
                                                  .quyDinhcon!
                                                  .fines);
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
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
                                onPressed: (listQuyetDinhXuPhat.length > 1)
                                    ? () {
                                        setState(() {
                                          print(listQuyetDinhXuPhat[i].id);
                                          listQuyetDinhXuPhat.removeAt(i);
                                        });
                                      }
                                    : null,
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
                                            departName: '')));
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
                                    print(listQuyetDinhXuPhat[i].id);
                                    listIdRemove.add(listQuyetDinhXuPhat[i].id);
                                    listQuyetDinhXuPhat.removeAt(i);
                                    print(listIdRemove);
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
                        )
                    ],
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  (listQuyetDinhXuPhat.length > 0)
                      ? Row(
                          children: [
                            Consumer<NavigationModel>(
                                builder: (context, navigationModel, child) =>
                                    Container(
                                      margin:
                                          EdgeInsets.fromLTRB(20, 20, 20, 0),
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
                                            for (var row
                                                in listQuyetDinhXuPhat) {
                                              if ((row.tts == null &&
                                                      row.userAAM == null) ||
                                                  row.quyDinhcon == null ||
                                                  row.quyDinhcon!.fines ==
                                                          null &&
                                                      ((row.quyDinhcon!
                                                                      .content !=
                                                                  null &&
                                                              row
                                                                  .quyDinhcon!
                                                                  .content!
                                                                  .isEmpty) ||
                                                          row.quyDinhcon!
                                                                  .content ==
                                                              null)) {
                                                checkValidate = false;
                                              }
                                            }
                                            if (checkValidate) {
                                              await updateQuyetDinhXuPhat();
                                              await updateQuyetDinhXuPhatChiTiet(
                                                  listQuyetDinhXuPhat);
                                              // await updateRuleDetail(listQuyetDinhXuPhat);
                                              await deleteQuyetDinhXuPhatChiTiet();
                                              showToast(
                                                  context: context,
                                                  msg: "Sửa qdxp thành công",
                                                  color: Colors.green,
                                                  icon: Icon(Icons.done));
                                              navigationModel.add(
                                                  pageUrl:
                                                      "/quyet-dinh-xu-phat");
                                            } else {
                                              showToast(
                                                  context: context,
                                                  msg:
                                                      "Hãy nhập đầy đủ thông tin",
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
                                    )),
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
                          navigationModel.add(pageUrl: "/quyet-dinh-xu-phat");
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
        ),
      ],
    );
  }
}

class TTS {
  int? id;
  String? fullName;
  String? userCode;
  DateTime? birthDate;
  int? careUser;
  String? nameCareUser;
  int? orderId;
  String? donHang;
  String? ngayTrungTuyen;
  TTS(
      {this.id,
      this.fullName,
      this.birthDate,
      this.careUser,
      this.nameCareUser,
      this.orderId,
      this.donHang,
      this.ngayTrungTuyen,
      this.userCode});
}

class QuyDinh1 {
  int id;
  String ruleName;
  int? ruleId;
  int? parentId;
  int? object;
  int? fines;
  String? content;
  String? reason;
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
  int? id;
  int? quyetDinhCha;
  dynamic option; //0 là TTS, 1 Cán bộ
  TTS? tts;
  UserAAM? userAAM;
  Duty? vatro;
  QuyDinh1? quyDinhcon;
  int? checkNew;
  String? reason;
  Quyetdinhxuphat(
      {this.id,
      this.quyetDinhCha,
      this.option,
      this.tts,
      this.vatro,
      this.quyDinhcon,
      this.userAAM,
      this.checkNew});
}
