import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../api.dart';
import '../../../common/style.dart';
import '../../../common/widgets_form.dart';
import '../../../model/model.dart';
import '../../forms/nhan_su/setting-data/userAAM.dart';
import '../../forms/nhan_su/view-chslq.dart';
import '../../forms/nhan_su/view-tt-lien-lac.dart';
import '../../forms/nhan_su/view-ttcb.dart';
import '../../forms/nhan_su/view-ttcv.dart';
import '../../ui/navigation.dart';

class ViewHSNSBody extends StatefulWidget {
  String? idHSNS;
  ViewHSNSBody({Key? key, this.idHSNS}) : super(key: key);

  @override
  State<ViewHSNSBody> createState() => _ViewHSNSBodyState();
}

class _ViewHSNSBodyState extends State<ViewHSNSBody> {
  UserAAM uerAAMResult = new UserAAM();
  late Future<UserAAM> futureAAM;
  Future<UserAAM> getUserAAM() async {
    var response1 = await httpGet("/api/nguoidung/get/profile?filter=id:${widget.idHSNS}", context);
    if (response1.containsKey("body")) {
      var body = jsonDecode(response1['body']);
      uerAAMResult.id = body['id'] ?? 0;
      uerAAMResult.userCode = body['userCode'] ?? "";
      uerAAMResult.userName = body['userName'] ?? "";
      uerAAMResult.fullName = body['fullName'] ?? "";
      uerAAMResult.avatar = body['avatar'] ?? "";
      uerAAMResult.birthDate = body['birthDate'] ?? "";
      uerAAMResult.gender = body['gender'] ?? 0;
      uerAAMResult.phone = body['phone'] ?? "";
      uerAAMResult.email = body['email'] ?? "";
      uerAAMResult.address = body['address'] ?? "";
      uerAAMResult.hometown = body['hometown'] ?? "";
      uerAAMResult.residence = body['residence'] ?? "";
      uerAAMResult.departId = body['departId'] ?? 0;
      uerAAMResult.departName = (body['phongban'] != null) ? body['phongban']['departName'] : "";
      uerAAMResult.teamId = body['teamId'] ?? 0;
      uerAAMResult.teamName = (body['doinhom'] != null) ? body['doinhom']['departName'] : "";
      uerAAMResult.dutyId = body['dutyId'] ?? 0;
      uerAAMResult.dutyName = (body['vaitro'] != null) ? body['vaitro']['name'] : "";
      uerAAMResult.level = (body['vaitro'] != null) ? body['vaitro']['level'] : 0;
      uerAAMResult.maritalStatus = body['maritalStatus'] ?? 0;
      uerAAMResult.issuedDate = body['issuedDate'] ?? "";
      uerAAMResult.issuedBy = body['issuedBy'] ?? "";
      uerAAMResult.idCardNo = body['idCardNo'] ?? "";
      uerAAMResult.dateInCompany = body['dateInCompany'] ?? "";
      uerAAMResult.hsSource = body['hsSource'] ?? "";
      uerAAMResult.pnBhxh = body['pnBhxh'] ?? "";
      uerAAMResult.mst = body['mst'] ?? "";
      uerAAMResult.device = body['device'] ?? "";
      uerAAMResult.salary = body['salary'] ?? "";
      uerAAMResult.note = body['note'] ?? "";
      uerAAMResult.bankAccountName = body['bankAccountName'] ?? "";
      uerAAMResult.bankNumber = body['bankNumber'] ?? "";
      uerAAMResult.bankName = body['bankName'] ?? "";
      uerAAMResult.bankBranch = body['bankBranch'] ?? "";
      uerAAMResult.nhansuTuyendungId = body['nhansuTuyendungId'] ?? 0;
      uerAAMResult.nhansuTuyendungId = body['nhansuTuyendungId'] ?? 0;
      uerAAMResult.qrcodeUrl = body['qrcodeUrl'];
      uerAAMResult.timeKeepingCode = body['timeKeepingCode'] ?? "";
      uerAAMResult.refUrl = body['refUrl'] ?? "";
      uerAAMResult.listHoSo = {};
      uerAAMResult.isBlocked = body['isBlocked'];
      uerAAMResult.blockedReason = body['blockedReason'] ?? "";

      return uerAAMResult;
    }
    return uerAAMResult;
  }

  getHoSo() async {
    var response = await httpGet("/api/tts-hoso/get/page?filter=fileGeneric:2", context);
    if (response.containsKey("body")) {
      var body = jsonDecode(response["body"]);
      var content = body['content'];
      for (var element in content) {
        uerAAMResult.listHoSo[element['id']] = [element['name'], element['required'], element['contentType'], "", 0, false];
      }
    }
  }

  getDataUpdateHoSo() async {
    var response = await httpGet("/api/tts-hoso-chitiet/get/page?filter=ttsId:${uerAAMResult.id}", context);
    if (response.containsKey("body")) {
      var body = jsonDecode(response["body"]);
      var content = body['content'];
      for (var element in content) {
        if (uerAAMResult.listHoSo.containsKey(element['hosoId'])) {
          if (uerAAMResult.listHoSo[element['hosoId']][2] == 0 || uerAAMResult.listHoSo[element['hosoId']][2] == 3)
            uerAAMResult.listHoSo[element['hosoId']][3] = element['fileUrl'];
          else {
            uerAAMResult.listHoSo[element['hosoId']][3] = element['content'] ?? "";
          }
          uerAAMResult.listHoSo[element['hosoId']][4] = element['id'];
          uerAAMResult.listHoSo[element['hosoId']][5] = true;
        }
      }
    }
  }

  UserAAM? selectedNVTD;
  getUserTuyenDung(int? idUserTD) async {
    if (idUserTD! > 0) {
      var response = await httpGet("/api/nguoidung/get/profile?filter=id:$idUserTD", context);
      if (response.containsKey("body")) {
        var body = jsonDecode(response['body']);
        selectedNVTD = UserAAM(id: body['id'], userCode: body['userCode'], fullName: body['fullName']);
        uerAAMResult.nhansuTuyendungName = body['fullName'] ?? "";
        uerAAMResult.nhansuTuyendungUserCode = body['userCode'] ?? "";
      }
    }
  }

  bool status = false;
  void callAPI() async {
    await getUserAAM();
    await getHoSo();
    await getDataUpdateHoSo();
    await getUserTuyenDung(uerAAMResult.nhansuTuyendungId);
    setState(() {
      status = true;
    });
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
      future: userRule('/view-hsns', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return Consumer<NavigationModel>(
              builder: (context, navigationModel, child) => SingleChildScrollView(
                    controller: ScrollController(),
                    child: Column(children: [
                      TitlePage(
                        listPreTitle: [
                          {'url': "/nhan-su", 'title': 'Dashboard'},
                          {'url': "/ho-so-nhan-su", 'title': 'Hồ sơ nhân sự'},
                        ],
                        content: 'Thông tin chi tiết',
                        widgetBoxRight: Container(
                            margin: EdgeInsets.only(left: 20, top: 20, right: 50),
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
                                Navigator.pop(context);
                              },
                              child: Text('Trở về', style: textButton),
                            )),
                      ),
                      (status)
                          ? Container(
                              height: 800,
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
                                        ViewTTCB(uerAAMResult),
                                        ViewTTCV(uerAAMResult),
                                        ViewTTLL(uerAAMResult),
                                        ViewCHSLQ(uerAAMResult)
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
