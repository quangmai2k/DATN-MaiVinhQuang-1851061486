// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/ho_so_noi/chot_danh_sach_tts_tien_cu/chot_danh_sach_tts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../api.dart';
import '../../../common/style.dart';
import '../../../common/toast.dart';
import '../../../common/widgets_form.dart';
import '../../../model/model.dart';
import '../../forms/nhan_su/form-add-cac-ho-so-lien-quan.dart';
import '../../forms/nhan_su/form-add-thong-tin-co-ban.dart';
import '../../forms/nhan_su/form-add-thong-tin-cong-viec.dart';
import '../../forms/nhan_su/form-add-thong-tin-lien-he.dart';
import '../../forms/nhan_su/setting-data/userAAM.dart';
import '../../ui/navigation.dart';

class Updatehsns extends StatefulWidget {
  String? idHSNS;
  UserAAM? userAAM;
  Function? callBack;
  Updatehsns({Key? key, this.idHSNS, this.userAAM, this.callBack}) : super(key: key);

  @override
  State<Updatehsns> createState() => _UpdatehsnsState();
}

class _UpdatehsnsState extends State<Updatehsns> with TickerProviderStateMixin {
  var formData = {};
  getUserAAM() async {
    var response1 = await httpGet("/api/nguoidung/get/profile?filter=id:${widget.idHSNS}", context);
    if (response1.containsKey("body")) {
      var body = jsonDecode(response1['body']);
      formData['id'] = body['id'] ?? 0;
      formData['userCode'] = body['userCode'] ?? "";
      formData['userName'] = body['userName'] ?? "";
      formData['fullName'] = body['fullName'] ?? "";
      formData['avatar'] = body['avatar'] ?? "";
      formData['birthDate'] = body['birthDate'] ?? "";
      formData['gender'] = body['gender'] ?? 0;
      formData['phone'] = body['phone'] ?? "";
      formData['email'] = body['email'] ?? "";
      formData['address'] = body['address'] ?? "";
      formData['hometown'] = body['hometown'] ?? "";
      formData['residence'] = body['residence'] ?? "";
      formData['departId'] = body['departId'] ?? 0;
      formData['departName'] = (body['phongban'] != null) ? body['phongban']['departName'] : "";
      formData['inWorkflowDepart'] = (body['phongban'] != null) ? body['phongban']['inWorkflow'] : 0;
      formData['teamId'] = body['teamId'] ?? 0;
      formData["teamName"] = (body['doinhom'] != null) ? body['doinhom']['departName'] : "";
      formData['dutyId'] = body['dutyId'] ?? 0;
      formData['dutyName'] = (body['vaitro'] != null) ? body['vaitro']['name'] : "";
      formData['inWorkflowDuty'] = (body['vaitro'] != null) ? body['vaitro']['inWorkflow'] : 0;
      formData['level'] = (body['vaitro'] != null) ? body['vaitro']['level'] : 0;
      formData['maritalStatus'] = body['maritalStatus'] ?? 0;
      formData['issuedDate'] = body['issuedDate'] ?? "";
      formData['issuedBy'] = body['issuedBy'] ?? "";
      formData['idCardNo'] = body['idCardNo'] ?? "";
      formData['dateInCompany'] = body['dateInCompany'] ?? "";
      formData['hsSource'] = body['hsSource'] ?? "";
      formData['pnBhxh'] = body['pnBhxh'] ?? "";
      formData['mst'] = body['mst'] ?? "";
      formData['device'] = body['device'] ?? "";
      formData['nbProvince'] = body['nbProvince'] ?? "";
      formData['note'] = body['note'] ?? "";
      formData['bankAccountName'] = body['bankAccountName'] ?? "";
      formData['bankNumber'] = body['bankNumber'] ?? "";
      formData['bankName'] = body['bankName'] ?? "";
      formData['bankBranch'] = body['bankBranch'] ?? "";
      formData['timeKeepingCode'] = body['timeKeepingCode'] ?? "";
      formData['listHoSo'] = {};
      formData['nhansuTuyendungId'] = body['nhansuTuyendungId'] ?? 0;
      return formData;
    }
    return formData;
  }

  getHoSo() async {
    var response = await httpGet("/api/tts-hoso/get/page?filter=fileGeneric:2", context);
    if (response.containsKey("body")) {
      var body = jsonDecode(response["body"]);
      var content = body['content'];
      for (var element in content) {
        formData['listHoSo']
            [element['id']] = [element['name'], element['required'], element['contentType'], "", 0, false, element['description'] ?? ""];
      }
    }
  }

  getDataUpdateHoSo() async {
    var response = await httpGet("/api/tts-hoso-chitiet/get/page?filter=ttsId:${formData['id']}", context);
    if (response.containsKey("body")) {
      var body = jsonDecode(response["body"]);
      var content = body['content'];
      for (var element in content) {
        if (formData['listHoSo'].containsKey(element['hosoId'])) {
          if (formData['listHoSo'][element['hosoId']][2] == 0 || formData['listHoSo'][element['hosoId']][2] == 3)
            formData['listHoSo'][element['hosoId']][3] = element['fileUrl'];
          else {
            formData['listHoSo'][element['hosoId']][3] = element['content'] ?? "";
          }
          formData['listHoSo'][element['hosoId']][4] = element['id'];
          formData['listHoSo'][element['hosoId']][5] = true;
        }
      }
    }
  }

  getUserTuyenDung(int idUserTD) async {
    if (idUserTD > 0) {
      var response = await httpGet("/api/nguoidung/get/profile?filter=id:$idUserTD", context);
      if (response.containsKey("body")) {
        var body = jsonDecode(response['body']);
        formData['nhansuTuyendungName'] = body['fullName'] ?? "";
        formData['nhansuTuyendungUserCode'] = body['userCode'] ?? "";
      }
    }
  }

  updateHSNS() async {
    var request;
    var result;
    if (formData['teamId'] != 0)
      request = {
        "fullName": formData['fullName'],
        "avatar": formData['avatar'],
        "gender": formData['gender'],
        "birthDate": formData['birthDate'],
        "age": (int.parse(DateFormat("yyyy-MM-dd").format(DateTime.now().toLocal()).toString().substring(0, 4)) -
            int.parse(formData['birthDate'].toString().substring(0, 4))),
        "phone": formData['phone'].toString(),
        "email": formData['email'],
        "address": formData['address'],
        "hometown": formData['hometown'],
        "residence": formData['residence'],
        "departId": formData['departId'],
        "teamId": formData['teamId'],
        "dutyId": formData['dutyId'],
        "isAam": 1,
        "active": 1,
        "idCardNo": formData['idCardNo'],
        "issuedDate": formData['issuedDate'],
        "issuedBy": formData['issuedBy'],
        "maritalStatus": formData['maritalStatus'],
        "dateInCompany": formData['dateInCompany'],
        "hsSource": formData['hsSource'],
        "pnBhxh": formData['pnBhxh'],
        "mst": formData['mst'],
        "device": formData['device'],
        "salary": formData['salary'],
        "note": formData['note'],
        "bankAccountName": formData['bankAccountName'],
        "bankNumber": formData['bankNumber'],
        "bankName": formData['bankName'],
        "bankBranch": formData['bankBranch'],
        "nhansuTuyendungId": (formData['nhansuTuyendungId'] != 0) ? formData['nhansuTuyendungId'] : null,
        "timeKeepingCode": (formData['timeKeepingCode'] != "") ? formData['timeKeepingCode'] : null
      };
    else
      request = {
        "fullName": formData['fullName'],
        "avatar": formData['avatar'],
        "gender": formData['gender'],
        "birthDate": formData['birthDate'],
        "age": (int.parse(DateFormat("yyyy-MM-dd").format(DateTime.now().toLocal()).toString().substring(0, 4)) -
            int.parse(formData['birthDate'].toString().substring(0, 4))),
        "phone": formData['phone'].toString(),
        "email": formData['email'],
        "address": formData['address'],
        "hometown": formData['hometown'],
        "residence": formData['residence'],
        "departId": formData['departId'],
        "dutyId": formData['dutyId'],
        "isAam": 1,
        "active": 1,
        "teamId": null,
        "idCardNo": formData['idCardNo'],
        "issuedDate": formData['issuedDate'],
        "issuedBy": formData['issuedBy'],
        "maritalStatus": formData['maritalStatus'],
        "dateInCompany": formData['dateInCompany'],
        "hsSource": formData['hsSource'],
        "pnBhxh": formData['pnBhxh'],
        "mst": formData['mst'],
        "device": formData['device'],
        "salary": formData['salary'],
        "note": formData['note'],
        "bankAccountName": formData['bankAccountName'],
        "bankNumber": formData['bankNumber'],
        "bankName": formData['bankName'],
        "bankBranch": formData['bankBranch'],
        "nhansuTuyendungId": (formData['nhansuTuyendungId'] != 0) ? formData['nhansuTuyendungId'] : null,
        "timeKeepingCode": (formData['timeKeepingCode'] != "") ? formData['timeKeepingCode'] : null
      };
    if (formData['nhansuTuyendungId'] != 0) {
      request["nhansuTuyendungId"] = formData['nhansuTuyendungId'];
    }
    var response = await httpPut("/api/nguoidung/put/${widget.idHSNS}", request, context);
    print("response:$response");
    if (response.containsKey("body")) {
      setState(() {
        result = jsonDecode(response["body"]);
      });
    }
    return result;
  }

  updateHoSo(listHoSo, int userId) async {
    print("Đây rồi");
    for (var key in listHoSo.keys) {
      if (listHoSo[key][4] == 0) {
        if (listHoSo[key][3] != "") {
          // print(listHoSo);
          var requestBody;
          if (listHoSo[key][2] == 1 || listHoSo[key][2] == 2)
            requestBody = {"ttsId": userId, "hosoId": key, "content": listHoSo[key][3], "received": 1, "times": 1};
          else
            requestBody = {"ttsId": userId, "hosoId": key, "fileUrl": listHoSo[key][3], "received": 1, "times": 1};
          // print(requestBody);
          await httpPost("/api/tts-hoso-chitiet/post/save", requestBody, context);
        }
      } else {
        if (listHoSo[key][5]) {
          var requestBody;
          if (listHoSo[key][2] == 1 || listHoSo[key][2] == 2) {
            requestBody = {"content": listHoSo[key][3]};
            // print(requestBody);
          } else {
            requestBody = {
              "fileUrl": listHoSo[key][3],
            };
          }
          print(requestBody);
          await httpPut("/api/tts-hoso-chitiet/put/${listHoSo[key][4]}", requestBody, context);
        } else {
          await httpDelete("/api/tts-hoso-chitiet/del/${listHoSo[key][4]}", context);
        }
      }
    }
  }

  bool status = false;
  void callAPI() async {
    await getUserAAM();
    await getUserTuyenDung(formData['nhansuTuyendungId']);
    await getHoSo();
    await getDataUpdateHoSo();
    setState(() {
      status = true;
    });
    print("formData['inWorkflowDepart']:${formData['inWorkflowDepart']}");
    print("formData['inWorkflowDuty']:${formData['inWorkflowDuty']}");
  }

  @override
  void initState() {
    super.initState();
    callAPI();
  }

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
        widgetBody: FutureBuilder<dynamic>(
      future: userRule('/sua-hsns', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return Consumer2<NavigationModel, SecurityModel>(
              builder: (context, navigationModel, user, child) => SingleChildScrollView(
                    controller: ScrollController(),
                    child: Column(children: [
                      TitlePage(
                        listPreTitle: [
                          {'url': "/nhan-su", 'title': 'Dashboard'},
                          {'url': "/ho-so-nhan-su", 'title': 'Hồ sơ nhân sự'},
                        ],
                        content: 'Cập nhật',
                        widgetBoxRight: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            getRule(listRule.data, Role.Sua, context)
                                ? Container(
                                    // margin: EdgeInsets.only(right: 150),
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 20.0,
                                          horizontal: 50.0,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5.0),
                                        ),
                                        backgroundColor: Color.fromRGBO(245, 117, 29, 1),
                                        primary: Theme.of(context).iconTheme.color,
                                        textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                      ),
                                      onPressed: () async {
                                        if (formData['fullName'] == "" ||
                                            formData['phone'] == "" ||
                                            formData['departId'] == "" ||
                                            formData['dutyId'] == "" ||
                                            formData['birthDate'] == "" ||
                                            formData['dateInCompany'] == "") {
                                          showToast(
                                            context: context,
                                            msg: "Phải nhập đầy đủ các thông tin bắt buộc",
                                            color: Color.fromRGBO(245, 117, 29, 1),
                                            icon: const Icon(Icons.close),
                                          );
                                        } else {
                                          if (formData['timeKeepingCode'] != "" && formData['timeKeepingCode'] != null) {
                                            var checkTimeKeeping = await httpGet(
                                                "/api/nguoidung/get/page?filter=timeKeepingCode:'${formData['timeKeepingCode']}'", context);
                                            var bodyTimeKeeping = jsonDecode(checkTimeKeeping['body']);
                                            var contentTimeKeeping = bodyTimeKeeping['content'];
                                            if (contentTimeKeeping.length == 0 || contentTimeKeeping.first['id'] == formData['id']) {
                                              var result1 = await updateHSNS();
                                              int? checkUpdate = int.tryParse(result1.keys.first);
                                              if (checkUpdate == 1) {
                                                await updateHoSo(formData['listHoSo'], formData['id']);
                                                await updateHoSo(formData['listHoSo'], formData['id']);
                                                widget.userAAM!.fullName = formData['fullName'];
                                                widget.userAAM!.gender = formData['gender'];
                                                widget.userAAM!.dateInCompany = formData['dateInCompany'];
                                                widget.userAAM!.phone = formData['phone'];
                                                widget.userAAM!.dutyName = formData['dutyName'];
                                                widget.userAAM!.departName = formData['departName'];
                                                widget.userAAM!.teamName = formData['teamName'];
                                                widget.callBack!(widget.userAAM);
                                                showToast(
                                                  context: context,
                                                  msg: "Cập nhập tài khoản người dùng thành công",
                                                  color: Color.fromARGB(136, 72, 238, 67),
                                                  icon: const Icon(Icons.done),
                                                  timeHint: 1,
                                                );
                                              } else {
                                                showToast(
                                                  context: context,
                                                  msg: "${result1[result1.keys.first]}",
                                                  color: colorOrange,
                                                  icon: const Icon(Icons.warning),
                                                );
                                              }
                                            } else {
                                              showToast(
                                                context: context,
                                                msg: "Mã chấm công đâ tồn tại",
                                                color: colorOrange,
                                                icon: const Icon(Icons.warning),
                                              );
                                            }
                                          } else {
                                            var result1 = await updateHSNS();

                                            int? checkUpdate = int.tryParse(result1.keys.first);
                                            if (checkUpdate == 1) {
                                              await updateHoSo(formData['listHoSo'], formData['id']);
                                              widget.userAAM!.fullName = formData['fullName'];
                                              widget.userAAM!.gender = formData['gender'];
                                              widget.userAAM!.dateInCompany = formData['dateInCompany'];
                                              widget.userAAM!.phone = formData['phone'];
                                              widget.userAAM!.dutyName = formData['dutyName'];
                                              widget.userAAM!.departName = formData['departName'];
                                              widget.userAAM!.teamName = formData['teamName'];
                                              widget.callBack!(widget.userAAM);
                                              showToast(
                                                context: context,
                                                msg: "Cập nhập tài khoản người dùng thành công",
                                                color: Color.fromARGB(136, 72, 238, 67),
                                                icon: const Icon(Icons.done),
                                                timeHint: 1,
                                              );
                                            } else {
                                              showToast(
                                                context: context,
                                                msg: "${result1[result1.keys.first]}",
                                                color: colorOrange,
                                                icon: const Icon(Icons.warning),
                                              );
                                            }
                                          }
                                        }
                                      },
                                      child: Row(
                                        children: [
                                          Text('Lưu', style: textButton),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(),
                            SizedBox(
                              width: 20,
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 150),
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20.0,
                                    horizontal: 50.0,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  backgroundColor: Color.fromRGBO(245, 117, 29, 1),
                                  primary: Theme.of(context).iconTheme.color,
                                  textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                ),
                                onPressed: () async {
                                  // Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/ho-so-nhan-su");
                                  Navigator.pop(context);
                                },
                                child: Row(
                                  children: [
                                    Text('Trở về', style: textButton),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      (status)
                          ? Container(
                              height: 860,
                              child: DefaultTabController(
                                length: 4,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Container(
                                      // color: Colors.red,
                                      constraints: BoxConstraints.expand(height: 50),
                                      padding: EdgeInsets.only(left: 20, right: 20),
                                      child: TabBar(
                                        isScrollable: true,
                                        indicatorColor: mainColorPage,
                                        tabs: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.person,
                                                color: mainColorPage,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "Thông tin cơ bản",
                                                style: titleTabbar,
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.work,
                                                color: mainColorPage,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "Thông tin công việc",
                                                style: titleTabbar,
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.contacts,
                                                color: mainColorPage,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "Thông tin liên hệ",
                                                style: titleTabbar,
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.folder_open,
                                                color: mainColorPage,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "Hồ sơ liên quan",
                                                style: titleTabbar,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: TabBarView(children: [
                                        FormAddTTCB(formData: formData),
                                        FormAddTTCV(formData: formData),
                                        FormAddTTLH(formData: formData),
                                        FormAddCHSLQ(formData: formData),
                                        // FormAddCHSLQ(),
                                        // FormAddTTL(),
                                      ]),
                                    )
                                  ],
                                ),
                              ),
                            )
                          : Center(child: const CircularProgressIndicator()),
                      Footer(marginFooter: EdgeInsets.only(top: 5), paddingFooter: EdgeInsets.all(15)),
                      SizedBox(height: 20)
                    ]),
                  ));
        } else if (listRule.hasError) {
          return Text('${listRule.error}');
        }

        // By default, show a loading spinner.
        return Center(child: CircularProgressIndicator());
      },
    ));
  }
}
