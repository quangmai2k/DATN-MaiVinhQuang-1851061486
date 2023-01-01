// ignore: duplicate_ignore
// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/forms/market_development/utils/funciton.dart';
import 'package:provider/provider.dart';
import '../../../../api.dart';
import '../../../../common/format_date.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/model.dart';
import '../../../forms/nhan_su/setting-data/duty.dart';
import '../../../forms/nhan_su/setting-data/userAAM.dart';
import '../../../utils/market_development.dart';
import 'eduRule.dart';

class ThemDaoTaoXuPhat extends StatefulWidget {
  const ThemDaoTaoXuPhat({Key? key}) : super(key: key);

  @override
  State<ThemDaoTaoXuPhat> createState() => _ThemDaoTaoXuPhatState();
}

class _ThemDaoTaoXuPhatState extends State<ThemDaoTaoXuPhat> {
  var ngayXuPhat;
  var fileName;
  bool _isCheckTreatment = false;
  String? violateDate;
  TextEditingController title = TextEditingController();

  Future<List<EduRule>> getListRule() async {
    List<EduRule> resultRule = [];
    var response = await httpGet(
        "/api/daotao-quydinh/get/page?sort=id&filter=parentId:0", context);
    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        content = body['content'];
        resultRule = content.map((e) {
          return EduRule.fromJson(e);
        }).toList();
      });
    }
    return resultRule;
  }

  late List<daoTaoXuPhat> listDaoTaoXuPhat = [];
  //quy định cha
  int quyDinhCha = 0;

  Future<List<QuyDinh1>> getQuyDinh(int paremtId) async {
    List<QuyDinh1> quydinh = [];
    var response1;
    response1 = await httpGet(
        "/api/daotao-quydinh/get/page?sort=id&filter=parentId:$paremtId and deleted: false",
        context);
    if (response1.containsKey("body")) {
      var resultQuyDinh = jsonDecode(response1["body"]);
      setState(() {
        for (var item in resultQuyDinh['content']) {
          QuyDinh1 e = new QuyDinh1(
              id: item['id'],
              name: item['name'],
              parentId: item['parentId'],
              times: item['times']);
          quydinh.add(e);
        }
      });
      //return quydinh;
    }
    return quydinh;
  }

  //Quy định chi tiết
  Future<List<QuyDinh1>> getQuyDinhChiTiet(int? paremtId) async {
    List<QuyDinh1> quydinh = [];
    var response1;
    if (paremtId == 0) {
      response1 =
          await httpGet("/api/daotao-quydinh-chitiet/get/page", context);
    } else {
      response1 = await httpGet(
          "/api/daotao-quydinh-chitiet/get/page?filter=quydinh.parentId:$paremtId",
          context);
    }

    if (response1.containsKey("body")) {
      var resultQuyDinh = jsonDecode(response1["body"]);
      setState(() {
        for (var item in resultQuyDinh['content']) {
          QuyDinh1 e = new QuyDinh1(
              id: item['id'] ?? 0,
              name: (item['quydinh'] != null) ? item['quydinh']['name'] : "",
              parentId:
                  (item['quydinh'] != null) ? item['quydinh']['parentId'] : 0,
              status: item['status'] ?? 0,
              content: (item['content'] != null) ? item['content'] : "",
              times: (item['times'] != null) ? item['times'] : 0);
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
    var response = await httpGet(
        "/api/nguoidung/get/page?filter=isTts:1 and ttsStatusId:9", context);
    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        content = body['content'];
        for (var item in content) {
          TTS e = TTS(
            id: item['id'],
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
  Future<List<UserAAM>> getListUser(int viTri) async {
    List<UserAAM> listUserAAM = [];
    var response2 = await httpGet(
        "/api/nguoidung/get/page?filter=isAam:1 and dutyId:$viTri ", context);
    var body = jsonDecode(response2['body']);
    var content = [];
    if (response2.containsKey("body")) {
      setState(() {
        content = body['content'];
        for (var item in content) {
          UserAAM e = new UserAAM(id: item['id'], fullName: item['fullName']);
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

  var eduDecisionId;
  addDaoTaoXuPhat(int eduRuleId) async {
    var treatment;
    if (_isCheckTreatment == true)
      treatment = 1;
    else
      treatment = 0;
    var requestBody = {
      "title": title.text,
      "eduRuleId": eduRuleId,
      "treatment": treatment,
      "relateFile": fileName,
      "decisionDate": FormatDate.formatDateInsertDB(DateTime.now()),
      // "decisionDate":null,
      "finesApproval": 0,
    };
    var response;
    print(requestBody);
    if (fileName != null)
      response =
          await httpPost("/api/daotao-xuphat/post/save", requestBody, context);
    else
      showToast(
          context: context,
          msg: "Vui lòng nhập biên bản",
          color: Colors.red,
          icon: Icon(Icons.warning));

    if (response.containsKey("body")) {
      setState(() {
        eduDecisionId = jsonDecode(response["body"]);
      });
      print("id sau khi post:" + eduDecisionId.toString());
    }

    return eduDecisionId;
  }

  addDaoTaoXuPhatChiTiet(List<daoTaoXuPhat> listDaoTaoXuPhat) async {
    // ignore: unused_local_variable
    var requestBody;
    for (var element in listDaoTaoXuPhat) {
      if (_isCheckTreatment == true)
        requestBody = {
          "eduRuleId": element.quyDinhcon!.id,
          "eduDecisionId": eduDecisionId,
          "ttsId": element.tts!.id,
          "fines": element.fines,
          "note": element.note,
          "violateDate": getDateInsertDB(violateDate),
        };
      else
        requestBody = {
          "eduRuleId": element.quyDinhcon!.id,
          "eduDecisionId": eduDecisionId,
          "ttsId": element.tts!.id,
          "note": element.note,
          "violateDate": getDateInsertDB(violateDate),
        };
      await httpPost(
          "/api/daotao-xuphat-chitiet/post/save", requestBody, context);
    }
  }

  // updateRuleDetail(List<DaoTaoxuphat> listDaoTaoXuPhat) async {
  //   var requestBody;
  //   for (var element in listDaoTaoXuPhat) {
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
  var file;
  @override
  void initState() {
    if (listDaoTaoXuPhat.length == 0)
      listDaoTaoXuPhat.add(new daoTaoXuPhat());
    else {
      for (var i = 0; i < listDaoTaoXuPhat.length; i++) {
        listDaoTaoXuPhat[i].quyDinhcon = QuyDinh1(id: -1, name: '', times: 0);
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
            SelectableText(
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
        Column(
          children: [
            Row(
              children: [
                SizedBox(width: 20),
                // Expanded(
                //   flex: 4,
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.start,
                //     children: [
                //       Expanded(
                //         flex: 2,
                //         child: Row(
                //           children: [
                //             SelectableText('Tên quy định:', style: titleWidgetBox),
                //           ],
                //         ),
                //       ),
                //       Expanded(
                //           flex: 5,
                //           child: Container(
                //             color: Colors.white,
                //             width: MediaQuery.of(context).size.width * 0.20,
                //             height: 40,
                //             child: DropdownSearch<EduRule>(
                //               hint: "Chọn",
                //               maxHeight: 250,
                //               mode: Mode.MENU,
                //               showSearchBox: true,
                //               onFind: (String? filter) => getListRule(),
                //               itemAsString: (EduRule? u) => u!.name,
                //               dropdownSearchDecoration: styleDropDown,
                //               onChanged: (value) {
                //                 setState(() {
                //                   quyDinhCha = value!.id;
                //                   print(quyDinhCha);

                //                   if (listDaoTaoXuPhat.length == 0)
                //                     listDaoTaoXuPhat.add(new daoTaoXuPhat());
                //                   else {
                //                     for (var i = 0; i < listDaoTaoXuPhat.length; i++) {
                //                       listDaoTaoXuPhat[i].quyDinhcon = QuyDinh1(id: -1, name: '', times: 0);
                //                     }
                //                   }
                //                 });
                //               },
                //             ),
                //           )),
                //     ],
                //   ),
                // ),
                Expanded(
                  flex: 4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextFieldValidated(
                        type: 'SelectableText',
                        height: 40,
                        controller: title,
                        label: 'Tiêu đề: ',
                        flexLable: 1,
                        flexTextField: 3,
                      ),
                    ],
                  ),
                ),
                Expanded(flex: 1, child: Container()),
                Expanded(
                  flex: 4,
                  child: Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: SelectableText("Thông tin liên quan: ",
                              style: titleWidgetBox)),
                      Expanded(
                          flex: 3,
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
                                : SelectableText(file.files.first.name),
                          ))
                    ],
                  ),
                ),
                Expanded(flex: 3, child: Container())
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  SizedBox(width: 20),
                  Expanded(
                    flex: 4,
                    child: Row(
                      children: [
                        Checkbox(
                            value: _isCheckTreatment,
                            onChanged: (bool? value) {
                              setState(() {
                                _isCheckTreatment = !_isCheckTreatment;
                              });
                            }),
                        SelectableText(
                          "Phạt tài chính",
                          style: titleBox,
                        )
                      ],
                    ),
                  ),
                  Expanded(flex: 1, child: Container()),
                  Expanded(flex: 7, child: Container())
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Column(children: [
          for (int i = 0; i < listDaoTaoXuPhat.length; i++)
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
                    height: 10,
                  ),
                  (_isCheckTreatment == false)
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
                                        child: SelectableText.rich(TextSpan(
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
                                        margin: const EdgeInsets.only(top: 5),
                                        color: Colors.white,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.20,
                                        height: 40,
                                        child: DropdownSearch<TTS>(
                                          hint: "Chọn",
                                          maxHeight: 300,
                                          mode: Mode.MENU,
                                          showSearchBox: true,
                                          onFind: (String? filter) => getTTS(),
                                          itemAsString: (TTS? u) =>
                                              "${u!.fullName}",
                                          dropdownSearchDecoration:
                                              styleDropDown,
                                          selectedItem: listDaoTaoXuPhat[i].tts,
                                          onChanged: (value) {
                                            setState(() {
                                              listDaoTaoXuPhat[i].tts = value;
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
                                        SelectableText(
                                          "Ngày vi phạm",
                                          style: titleWidgetBox,
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(top: 5),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.20,
                                          child: DatePickerBoxCustomForMarkert(
                                              isTime: false,
                                              isBlocDate: false,
                                              isNotFeatureDate: true,
                                              dateDisplay: violateDate,
                                              selectedDateFunction: (day) {
                                                setState(() {
                                                  violateDate = day;
                                                });
                                              }),
                                        ),
                                      ]),
                                ),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                              child: Column(
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
                                              child: SelectableText.rich(
                                                  TextSpan(
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
                                                        quyDinhCha),
                                                itemAsString: (QuyDinh1? u) =>
                                                    (u!.times != 0)
                                                        ? "${u.name}" +
                                                            " lần ${u.times}"
                                                        : "${u.name}",
                                                dropdownSearchDecoration:
                                                    styleDropDown,
                                                selectedItem:
                                                    listDaoTaoXuPhat[i]
                                                        .quyDinhcon,
                                                onChanged: (value) async {
                                                  setState(() {
                                                    listDaoTaoXuPhat[i]
                                                        .quyDinhcon = value;
                                                    print(listDaoTaoXuPhat[i]
                                                        .quyDinhcon!
                                                        .id);
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
                                              child: SelectableText.rich(
                                                  TextSpan(
                                                      text: 'Hình thức xử phạt',
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
                                                    text: (listDaoTaoXuPhat[i]
                                                                .quyDinhcon !=
                                                            null)
                                                        ? listDaoTaoXuPhat[i]
                                                                .quyDinhcon!
                                                                .content ??
                                                            ""
                                                        : ""),
                                                onChanged: (value) {
                                                  listDaoTaoXuPhat[i]
                                                      .quyDinhcon!
                                                      .content = value;
                                                  // print("tong tin cua cb");
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(top: 20),
                                                  child: SelectableText.rich(
                                                      TextSpan(
                                                          text: 'Ghi chú',
                                                          style: titleWidgetBox,
                                                          children: <
                                                              InlineSpan>[
                                                        TextSpan(
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red),
                                                        )
                                                      ])),
                                                ),
                                              ],
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
                                                  // enabled: false,
                                                  // controller: TextEditingController(
                                                  //     text: (listDaoTaoXuPhat[i].quyDinhcon != null)
                                                  //         ? (listDaoTaoXuPhat[i].quyDinhcon!.fines != null)
                                                  //             ? "${listDaoTaoXuPhat[i].quyDinhcon!.fines}"
                                                  //             : ""
                                                  //         : ""),
                                                  onChanged: (value) {
                                                    // print(value);
                                                    listDaoTaoXuPhat[i].note =
                                                        value;
                                                  }),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(flex: 4, child: Container())
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
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
                                        child: SelectableText.rich(TextSpan(
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
                                        margin: const EdgeInsets.only(top: 5),
                                        color: Colors.white,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.20,
                                        height: 40,
                                        child: DropdownSearch<TTS>(
                                          hint: "Chọn",
                                          maxHeight: 300,
                                          mode: Mode.MENU,
                                          showSearchBox: true,
                                          onFind: (String? filter) => getTTS(),
                                          itemAsString: (TTS? u) =>
                                              "${u!.fullName}",
                                          dropdownSearchDecoration:
                                              styleDropDown,
                                          selectedItem: listDaoTaoXuPhat[i].tts,
                                          onChanged: (value) {
                                            setState(() {
                                              listDaoTaoXuPhat[i].tts = value;
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
                                        SelectableText(
                                          "Ngày vi phạm",
                                          style: titleWidgetBox,
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(top: 5),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.20,
                                          child: DatePickerBoxCustomForMarkert(
                                              isTime: false,
                                              isBlocDate: false,
                                              isNotFeatureDate: true,
                                              dateDisplay: violateDate,
                                              selectedDateFunction: (day) {
                                                setState(() {
                                                  violateDate = day;
                                                });
                                              }),
                                        ),
                                      ]),
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
                                          child: SelectableText.rich(TextSpan(
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
                                                (u!.times != 0)
                                                    ? "${u.name}" +
                                                        " lần ${u.times}"
                                                    : "${u.name}",
                                            dropdownSearchDecoration:
                                                styleDropDown,
                                            selectedItem:
                                                listDaoTaoXuPhat[i].quyDinhcon,
                                            onChanged: (value) async {
                                              setState(() {
                                                listDaoTaoXuPhat[i].quyDinhcon =
                                                    value;
                                                print(listDaoTaoXuPhat[i]
                                                    .quyDinhcon!
                                                    .content);
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
                                          child: SelectableText.rich(TextSpan(
                                              text: 'Hình thức xử phạt',
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
                                            enabled: false,
                                            controller: TextEditingController(
                                                text: (listDaoTaoXuPhat[i]
                                                            .quyDinhcon !=
                                                        null)
                                                    ? listDaoTaoXuPhat[i]
                                                            .quyDinhcon!
                                                            .content ??
                                                        ""
                                                    : ""),
                                            onChanged: (value) {
                                              print(value);
                                              // listDaoTaoXuPhat[i].note = value;
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(top: 20),
                                            child: SelectableText.rich(TextSpan(
                                                text: 'Ghi chú',
                                                style: titleWidgetBox,
                                                children: <InlineSpan>[
                                                  TextSpan(
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  )
                                                ])),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(top: 5),
                                        color: Colors.white,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.20,
                                        height: 40,
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
                                            // controller: TextEditingController(
                                            //     text: (listDaoTaoXuPhat[i].quyDinhcon != null)
                                            //         ? (listDaoTaoXuPhat[i].quyDinhcon!.fines != null)
                                            //             ? "${listDaoTaoXuPhat[i].quyDinhcon!.fines}"
                                            //             : ""
                                            //         : ""),
                                            onChanged: (value) {
                                              // print(value);
                                              listDaoTaoXuPhat[i].fines =
                                                  int.parse(value);
                                            }),
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
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(top: 20),
                                            child: SelectableText.rich(TextSpan(
                                                text: 'Mức tiền phạt',
                                                style: titleWidgetBox,
                                                children: <InlineSpan>[
                                                  TextSpan(
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  )
                                                ])),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(top: 5),
                                        color: Colors.white,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.20,
                                        height: 40,
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
                                            // controller: TextEditingController(
                                            //     text: (listDaoTaoXuPhat[i].quyDinhcon != null)
                                            //         ? (listDaoTaoXuPhat[i].quyDinhcon!.fines != null)
                                            //             ? "${listDaoTaoXuPhat[i].quyDinhcon!.fines}"
                                            //             : ""
                                            //         : ""),
                                            onChanged: (value) {
                                              // print(value);
                                              listDaoTaoXuPhat[i].fines =
                                                  int.parse(value);
                                            }),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                  if (i == listDaoTaoXuPhat.length - 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin:
                              EdgeInsets.only(right: 20, top: 10, bottom: 10),
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
                                listDaoTaoXuPhat.removeAt(i);
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
                          margin:
                              EdgeInsets.only(right: 20, top: 10, bottom: 10),
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
                                listDaoTaoXuPhat.add(daoTaoXuPhat());
                              });
                            },
                            child: Row(
                              children: [
                                Expanded(
                                    child: Center(
                                  child: Text("+",
                                      style: TextStyle(
                                          fontSize: 26, color: Colors.white)),
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
                          margin:
                              EdgeInsets.only(right: 20, top: 10, bottom: 10),
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
                                listDaoTaoXuPhat.removeAt(i);
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
              (listDaoTaoXuPhat.length > 0)
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
                        //       // await exportExcel(listDaoTaoXuPhat);
                        //     },
                        //     child: Row(
                        //       children: [
                        //         Icon(Icons.upload_file, color: Colors.white),
                        //         SelectableText('Xuất file', style: textButton),
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
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                backgroundColor:
                                    Color.fromRGBO(245, 117, 29, 1),
                                primary: Theme.of(context).iconTheme.color,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .caption
                                    ?.copyWith(
                                        fontSize: 10.0, letterSpacing: 2.0),
                              ),
                              onPressed: () async {
                                if (violateDate == null) {
                                  showToast(
                                      context: context,
                                      msg: "Vui lòng nhập ngày vi phạm",
                                      color: Colors.red,
                                      icon: Icon(Icons.warning));
                                } else {
                                  if (title.text.isEmpty) {
                                    showToast(
                                        context: context,
                                        msg: "Vui lòng nhập tiêu đề",
                                        color: Colors.red,
                                        icon: Icon(Icons.warning));
                                  } else {
                                    print(1);
                                    await addDaoTaoXuPhat(quyDinhCha);
                                    await addDaoTaoXuPhatChiTiet(
                                        listDaoTaoXuPhat);
                                    // await updateRuleDetail(listDaoTaoXuPhat);
                                    showToast(
                                        context: context,
                                        msg: "Thêm quyết định thành công",
                                        color: Colors.green,
                                        icon: Icon(Icons.done));
                                    navigationModel.add(
                                        pageUrl: "/quyet-dinh-xu-phat-dao-tao");
                                  }
                                }
                                print(listDaoTaoXuPhat);
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
        ]),
        Footer()
      ]),
    );
  }
}

class TTS {
  int? id;
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
      this.birthDate,
      this.careUser,
      this.nameCareUser,
      this.orderId,
      this.donHang,
      this.ngayTrungTuyen});
}

class QuyDinh1 {
  int id;
  int? times;
  String name;
  int? parentId;
  String? content;
  int? status;

  QuyDinh1(
      {required this.id,
      this.parentId,
      required this.name,
      this.content,
      this.status,
      this.times});
}

class daoTaoXuPhat {
  int? daoTaoXuPhatCha;
  TTS? tts;
  QuyDinh1? quyDinhcon;
  String? note;
  int? treatment;
  int? fines;
  daoTaoXuPhat(
      {this.daoTaoXuPhatCha,
      this.tts,
      this.quyDinhcon,
      this.note,
      this.fines,
      this.treatment});
}
