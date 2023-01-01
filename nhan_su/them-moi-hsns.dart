// ignore_for_file: deprecated_member_use, unused_local_variable

import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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

class AddNewUpdatehsns extends StatelessWidget {
  const AddNewUpdatehsns({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
      widgetBody: AddNewUpdatehsnsBody(),
    );
  }
}

class AddNewUpdatehsnsBody extends StatefulWidget {
  const AddNewUpdatehsnsBody({Key? key}) : super(key: key);

  @override
  State<AddNewUpdatehsnsBody> createState() => _AddNewUpdatehsnsBodyState();
}

class _AddNewUpdatehsnsBodyState extends State<AddNewUpdatehsnsBody> with TickerProviderStateMixin {
  var formData = {};
  var resultID;

  addUser(formData) async {
    var request = {
      "fullName": formData['fullName'],
      "avatar": formData['avatar'],
      "gender": formData['gender'],
      "birthDate": formData['birthDate'] ?? null,
      "age": (int.parse(DateFormat("yyyy-MM-dd").format(DateTime.now().toLocal()).toString().substring(0, 4)) -
          int.parse(formData['birthDate'].toString().substring(0, 4))),
      "phone": formData['phone'].toString(),
      "email": formData['email'],
      "address": formData['address'] ?? null,
      "hometown": formData['hometown'] ?? null,
      "residence": formData['residence'] ?? null,
      "departId": formData['departId'],
      "teamId": formData['teamId'] ?? null,
      "dutyId": formData['dutyId'],
      "isAam": 1,
      "active": 1,
      "idCardNo": formData['idCardNo'] ?? null,
      "issuedDate": formData['issuedDate'] ?? null,
      "issuedBy": formData['issuedBy'] ?? null,
      "maritalStatus": formData['maritalStatus'],
      "stopProcessing": 0,
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
      "timeKeepingCode": formData['timeKeepingCode']
    };
    if (formData['nhansuTuyendungId'] != 0) {
      request["nhansuTuyendungId"] = formData['nhansuTuyendungId'];
    }
    print(request);
    var response = await httpPost("/api/nguoidung/post/save", request, context);
    if (response.containsKey("body")) {
      setState(() {
        resultID = jsonDecode(response["body"]);
      });
      return resultID;
    }
    return resultID;
  }

  addFileUser(formData, int idUser) async {
    print("idUser:$idUser");
    var kqPosst = false;
    List<dynamic> object = [];
    for (var element in formData!['listHoSo'].keys) {
      if (formData!['listHoSo'][element][3] != "") {
        var requestBody;
        if (formData!['listHoSo'][element][2] == 1 || formData!['listHoSo'][element][2] == 2)
          requestBody = {"ttsId": idUser, "hosoId": element, "content": formData!['listHoSo'][element][3], "received": 1, "times": 1};
        else
          requestBody = {"ttsId": idUser, "hosoId": element, "fileUrl": formData!['listHoSo'][element][3], "received": 1, "times": 1};
        object.add(requestBody);
      }
    }
    var kq;
    if (object.length > 0) kq = await httpPost("/api/tts-hoso-chitiet/post/saveAll", object, context);
    if (kq != null) if (kq.containsKey("body")) {
      setState(() {
        print("kq:$kq");
        kqPosst = jsonDecode(kq["body"]);
      });
      return kqPosst;
    }
    return kqPosst;
  }

  postNotifi(String title, String content) {
    var body1 = {
      "title": title,
      "message": content,
    };
    var response1 = httpPost("/api/push/tags/user_type/aam", body1, context);
    print("one-signal: $response1");
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

  bool status = false;
  void callAPI() async {
    await getHoSo();
    setState(() {
      status = true;
    });
  }

  @override
  void initState() {
    super.initState();
    formData['id'] = null;
    formData['fullName'] = "";
    formData['phone'] = "";
    formData['email'] = "";
    formData['departId'] = 1000;
    formData['dutyId'] = 0;
    formData['birthDate'] = "";
    formData['hometown'] = "";
    formData['residence'] = "";
    formData['gender'] = 1;
    formData['maritalStatus'] = 0;
    formData['avatar'] = "";
    formData['idCardNo'] = "";
    formData['issuedBy'] = "";
    formData['issuedDate'] = "";
    //NEW
    formData['dateInCompany'] = "";
    formData['hsSource'] = "";
    formData['pnBhxh'] = "";
    formData['mst'] = "";
    formData['device'] = "";
    formData['nbProvince'] = "";
    formData['note'] = "";
//ngân hàng
    formData['bankAccountName'] = "";
    formData['bankNumber'] = "";
    formData['bankName'] = "";
    formData['bankBranch'] = "";
    formData['check'] = true;
    //hồ sơ
    formData['listHoSo'] = {};
    //nhân viên tuyển dụng;
    formData['nhansuTuyendungId'] = 0;
    callAPI();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: userRule('/them-moi-hsns', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return Consumer2<NavigationModel, SecurityModel>(
            builder: (context, navigationModel, user, child) => (status)
                ? SingleChildScrollView(
                    controller: ScrollController(),
                    child: Column(children: [
                      TitlePage(
                        listPreTitle: [
                          {'url': "/nhan-su", 'title': 'Dashboard'},
                          {'url': "/ho-so-nhan-su", 'title': 'Hồ sơ nhân sự'},
                        ],
                        content: 'Thêm mới',
                        widgetBoxRight: Row(
                          children: [
                            getRule(listRule.data, Role.Them, context)
                                ? Container(
                                    margin: EdgeInsets.only(right: 30),
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
                                            formData['email'] == "" ||
                                            formData['departId'] == 0 ||
                                            formData['dutyId'] == 0 ||
                                            formData['birthDate'] == "" ||
                                            formData['dateInCompany'] == "" ||
                                            formData['check'] == false) {
                                          showToast(
                                            context: context,
                                            msg: "Phải nhập đầy đủ các thông tin bắt buộc",
                                            color: Color.fromRGBO(245, 117, 29, 1),
                                            icon: const Icon(Icons.warning),
                                          );
                                        } else {
                                          processing();
                                          showToast(
                                              context: context,
                                              msg: "Đang xác nhận thông tin. Vui lòng đợi trong giây lát...",
                                              color: Color.fromARGB(135, 231, 184, 82),
                                              icon: const Icon(Icons.hourglass_empty),
                                              timeHint: 1);
                                          if (formData['timeKeepingCode'] != "" && formData['timeKeepingCode'] != null) {
                                            var checkTimeKeeping = await httpGet(
                                                "/api/nguoidung/get/page?filter=timeKeepingCode:'${formData['timeKeepingCode']}'", context);
                                            var bodyTimeKeeping = jsonDecode(checkTimeKeeping['body']);
                                            var contentTimeKeeping = bodyTimeKeeping['content'];
                                            if (contentTimeKeeping.length == 0) {
                                              var result = await addUser(formData);
                                              print("result:$result");
                                              if (int.parse(result.keys.first.toString()) == 1) {
                                                var kq = await addFileUser(formData, int.parse(resultID['1']));
                                                if (kq == true) {
                                                  showToast(
                                                    context: context,
                                                    msg: "Tạo mới người dùng thành công",
                                                    color: Color.fromARGB(136, 72, 238, 67),
                                                    icon: const Icon(Icons.done),
                                                  );
                                                  Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/ho-so-nhan-su");
                                                  postNotifi("Hệ thống thông báo",
                                                      "Chúc mừng nhân sự mới ${formData['fullName']} thuộc phòng ban ${formData['departName']} đã tham gia vào đại gia đình AAM.");
                                                } else {
                                                  showToast(
                                                    context: context,
                                                    msg: "Tạo mới người dùng thành công",
                                                    color: Color.fromARGB(136, 72, 238, 67),
                                                    icon: const Icon(Icons.done),
                                                  );
                                                  Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/ho-so-nhan-su");
                                                  postNotifi("Hệ thống thông báo",
                                                      "Chúc mừng nhân sự mới ${formData['fullName']} thuộc phòng ban ${formData['departName']} đã tham gia vào đại gia đình AAM.");
                                                }
                                              } else {
                                                Navigator.pop(context);
                                                showToast(
                                                  context: context,
                                                  msg: "${result[result.keys.first]}",
                                                  color: colorOrange,
                                                  icon: const Icon(Icons.warning),
                                                );
                                              }
                                            } else {
                                              Navigator.pop(context);
                                              showToast(
                                                context: context,
                                                msg: "Mã chấm công đã tồn tại",
                                                color: colorOrange,
                                                icon: const Icon(Icons.warning),
                                              );
                                            }
                                          } else {
                                            var result = await addUser(formData);
                                            if (result.keys.first == "1") {
                                              var kq = await addFileUser(formData, int.parse(resultID['1']));
                                              if (kq == true) {
                                                showToast(
                                                  context: context,
                                                  msg: "Tạo mới người dùng thành công",
                                                  color: Color.fromARGB(136, 72, 238, 67),
                                                  icon: const Icon(Icons.done),
                                                );
                                                Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/ho-so-nhan-su");
                                                postNotifi("Hệ thống thông báo",
                                                    "Chúc mừng nhân sự mới ${formData['fullName']} thuộc phòng ban ${formData['departName']} đã tham gia vào đại gia đình AAM.");
                                              } else {
                                                showToast(
                                                  context: context,
                                                  msg: "Tạo mới người dùng thành công",
                                                  color: Color.fromARGB(136, 72, 238, 67),
                                                  icon: const Icon(Icons.done),
                                                );
                                                Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/ho-so-nhan-su");
                                                postNotifi("Hệ thống thông báo",
                                                    "Chúc mừng nhân sự mới ${formData['fullName']} thuộc phòng ban ${formData['departName']} đã tham gia vào đại gia đình AAM.");
                                              }
                                            } else {
                                              Navigator.pop(context);
                                              showToast(
                                                context: context,
                                                msg: "${result[result.keys.first]}",
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
                                onPressed: () {
                                  Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/ho-so-nhan-su");
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
                      Container(
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
                                ]),
                              )
                            ],
                          ),
                        ),
                      ),
                      Footer(marginFooter: EdgeInsets.only(top: 5), paddingFooter: EdgeInsets.all(15)),
                      SizedBox(height: 20)
                    ]),
                  )
                : Center(child: CircularProgressIndicator()),
          );
        } else if (listRule.hasError) {
          return Text('${listRule.error}');
        }

        // By default, show a loading spinner.
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
