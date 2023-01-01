// ignore_for_file: unused_local_variable, deprecated_member_use
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/forms/nhan_su/setting-data/userAAM.dart';
import 'package:gentelella_flutter/widgets/ui/navigation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../api.dart';
import '../../../common/style.dart';
import '../../../common/toast.dart';
import '../../../common/widgets_form.dart';
import '../../../model/model.dart';
import '../../forms/nhan_su/setting-data/depart.dart';
import '../../forms/nhan_su/setting-data/detailed-recruitment.dart';
import '../../forms/nhan_su/setting-data/duty.dart';
import '../../forms/nhan_su/setting-data/interview.dart';
import '../../forms/nhan_su/setting-data/recruitment.dart';

class AddNewUpdatelpv extends StatelessWidget {
  const AddNewUpdatelpv({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
      widgetBody: AddNewUpdatelpvBody(),
    );
  }
}

class AddNewUpdatelpvBody extends StatefulWidget {
  const AddNewUpdatelpvBody({Key? key}) : super(key: key);

  @override
  State<AddNewUpdatelpvBody> createState() => _AddNewUpdatelpvBodyState();
}

class _AddNewUpdatelpvBodyState extends State<AddNewUpdatelpvBody> {
  late Interview interview;
  TextEditingController soLuongDaTuyen = TextEditingController();
  TextEditingController yeuCauChiTiet = TextEditingController();

  String soLuongCan = "0";
  String dayNow =
      "${int.parse(DateFormat("yyyy-MM-dd").format(DateTime.now().toLocal()).toString().substring(8, 10)) - 1}-${DateFormat("yyyy-MM-dd").format(DateTime.now().toLocal()).toString().substring(5, 7)}-${DateFormat("yyyy-MM-dd").format(DateTime.now().toLocal()).toString().substring(0, 4)}";

  List<Recruitment>? listRecruitResult = [];
  Future<List<Recruitment>> getListTD() async {
    var response3 = await httpGet("/api/tuyendung/get/page?filter=approve:1 and status:1", context);
    var body = jsonDecode(response3['body']);
    var content = [];

    if (response3.containsKey("body")) {
      setState(() {
        content = body['content'];
        listRecruitResult = content.map((e) {
          return Recruitment.fromJson(e);
        }).toList();
      });
    }
    return content.map((e) {
      return Recruitment.fromJson(e);
    }).toList();
  }

  List<DetailedRecruitment>? listRecruitResultCT = [];
  List<int>? listPB = [];
  Future<List<DetailedRecruitment>> getListTDCT(var id) async {
    var response4 = await httpGet("/api/tuyendung-chitiet/get/page?filter=tuyendungId:$id", context);
    var body = jsonDecode(response4['body']);
    var content = [];
    if (response4.containsKey("body")) {
      listPB = [];
      setState(() {
        content = body['content'];
        listRecruitResultCT = content.map((e) {
          return DetailedRecruitment.fromJson(e);
        }).toList();
      });
      for (var i = 0; i < listRecruitResultCT!.length; i++) {
        listPB!.add(listRecruitResultCT![i].idDepart);
      }
      // return resultPhongBan;
      // print(listPB);
    }
    return content.map((e) {
      return DetailedRecruitment.fromJson(e);
    }).toList();
  }

  List<Depart>? resultPhongBan = [Depart(departName: '', id: -1)];
  Future<List<Depart>> getPhongBan(List<int> listPB) async {
    var findPB = "";
    if (listPB.length > 0)
      for (var i = 0; i < listPB.length; i++) {
        findPB = findPB + " or id :${listPB[i]}";
      }
    var response1;
    if (findPB.length > 0) {
      findPB = findPB.substring(3);
      response1 =
          await httpGet("/api/phongban/get/page?sort=id,asc&filter=parentId:0 and id>2 and deleted:false&filter=$findPB and status:1", context);
    } else
      response1 = await httpGet("/api/phongban/get/page?sort=id,asc&filter=id<0 and status:1", context);
    var body = jsonDecode(response1['body']);
    var content = [];
    resultPhongBan = [];
    if (response1.containsKey("body")) {
      setState(() {
        content = body['content'];
        resultPhongBan = content.map((e) {
          return Depart.fromJson(e);
        }).toList();
      });
    }
    Depart all = new Depart(id: -1, departName: "Tất cả");
    resultPhongBan?.insert(0, all);
    return content.map((e) {
      return Depart.fromJson(e);
    }).toList();
  }

  List<Duty>? resultVaiTro;
  Future<List<Duty>> getVaiTro(var idBP) async {
    var response;
    if (idBP != null)
      response = await httpGet("/api/vaitro/get/page?filter=departId:$idBP and status:1", context);
    else
      response = await httpGet("/api/vaitro/get/page?filter=departId:0 and status:1", context);
    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        content = body['content'];
        resultVaiTro = content.map((e) {
          return Duty.fromJson(e);
        }).toList();
      });
    }
    return content.map((e) {
      return Duty.fromJson(e);
    }).toList();
  }

  getQty(int? idTD, int? idBP, int? idVT) async {
    var responseQty = await httpGet("/api/tuyendung-chitiet/get/page?filter=tuyendungId:$idTD and departId:$idBP and dutyId:$idVT", context);
    if (responseQty.containsKey("body")) {
      var getqty = jsonDecode(responseQty["body"]);
      if (getqty['content'].length > 0)
        setState(() {
          interview.tuyendungChitietId = getqty["content"][0]["id"];
          if (getqty["content"].length > 0)
            interview.qty = getqty["content"][0]["qty"];
          else
            interview.qty = 0;
        });
      else
        setState(() {
          interview.qty = 0;
        });
    }
  }

  List<UserAAM>? listUserAAM = [];
  List<UserAAM> listUserAAMSelect = [UserAAM(id: 0, userCode: "", fullName: "")];
  Future<List<UserAAM>> getListUser() async {
    var response2 = await httpGet("/api/nguoidung/get/page?filter=isAam:1", context);
    var body = jsonDecode(response2['body']);
    var content = [];

    if (response2.containsKey("body")) {
      setState(() {
        content = body['content'];
        listUserAAM = content.map((e) {
          return UserAAM.fromJson(e);
        }).toList();
      });
    }

    return content.map((e) {
      return UserAAM.fromJson(e);
    }).toList();
  }

  addLPV(Interview interview, int recruitmentUser) async {
    bool checkSTT = false;
    var requestBody = {
      "tuyendungId": interview.tuyendungId,
      "tuyendungChitietId": interview.tuyendungChitietId,
      "interviewComponents": interview.interviewComponents,
      "dutyId": interview.duty!.id,
      "qty": interview.qty,
      "interviewAddress": interview.interviewAddress,
      "interviewTime": interview.interviewTime,
      "jobDesc": interview.jobDesc,
      "candidateQty": interview.candidateQty,
      "status": 0,
      "recruitmentUser": recruitmentUser
    };
    print("requestBody:$requestBody");
    var response2 = await httpPost("/api/tuyendung-phongvan/post/save", requestBody, context);
    if (response2.containsKey("body")) {
      setState(() {
        var idInterView = jsonDecode(response2["body"]);
        var checkid = int.tryParse(idInterView.toString());
        if (checkid != null)
          checkSTT = true;
        else
          checkSTT = false;
      });
    }
    return checkSTT;
  }

  postNotifi(String title, String content, int idPBPV) async {
    var body1 = {
      "title": title,
      "message": content,
    };
    if (idPBPV != 10) {
      await httpPost("/api/push/tags/depart_id/10", body1, context);
      await httpPost("/api/push/tags/depart_id/$idPBPV", body1, context);
    } else {
      await httpPost("/api/push/tags/depart_id/10", body1, context);
    }
  }

  @override
  void initState() {
    super.initState();
    interview = new Interview(
        tuyendungId: 0,
        tuyendungChitietId: 0,
        qtyRecruited: 0,
        recruitmentUser: 0,
        interviewAddress: "",
        interviewTime: "",
        depart: Depart(id: 0, departName: ''),
        duty: Duty(id: 0, dutyName: '', departId: 0),
        qty: 0);
  }

  @override
  void dispose() {
    yeuCauChiTiet.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: userRule('/them-moi-lpv', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return Consumer2<NavigationModel, SecurityModel>(
              builder: (context, navigationModel, user, child) => Container(
                    child: Container(
                      child: ListView(
                        children: [
                          Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                            TitlePage(
                              listPreTitle: [
                                {'url': "/nhan-su", 'title': 'Dashboard'},
                                {'url': "/lich-phong-van", 'title': 'Lịch phỏng vấn'},
                              ],
                              content: 'Thêm mới',
                            ),
                            //body
                            Container(
                              width: MediaQuery.of(context).size.width * 1,
                              padding: paddingTitledPage,
                              margin: EdgeInsets.only(right: 30, top: 30, left: 30, bottom: 30),
                              decoration: BoxDecoration(
                                color: colorWhite,
                                boxShadow: [boxShadowContainer],
                                border: Border(
                                  bottom: borderTitledPage,
                                ),
                              ),
                              child: Column(
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
                                  Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(50, 10, 0, 0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                margin: EdgeInsets.only(bottom: 30),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      flex: 3,
                                                      child: Row(
                                                        children: [
                                                          Text('Tiêu đề:', style: titleWidgetBox),
                                                          Text("*",
                                                              style: TextStyle(
                                                                color: Colors.red,
                                                                fontSize: 16,
                                                              )),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                        flex: 5,
                                                        child: Container(
                                                          color: Colors.white,
                                                          width: MediaQuery.of(context).size.width * 0.20,
                                                          height: 40,
                                                          child: DropdownSearch<Recruitment>(
                                                            hint: "Chọn",
                                                            maxHeight: 350,
                                                            mode: Mode.MENU,
                                                            showSearchBox: true,
                                                            onFind: (String? filter) => getListTD(),
                                                            itemAsString: (Recruitment? u) => u!.title,
                                                            dropdownSearchDecoration: styleDropDown,
                                                            onChanged: (value) async {
                                                              setState(() {
                                                                interview.tuyendungId = value!.id;
                                                                print(interview.tuyendungId);
                                                                interview.depart = Depart(id: 0, departName: '');
                                                                interview.duty = Duty(id: 0, dutyName: '', departId: 0);
                                                                interview.qty = 0;
                                                              });
                                                              await getListTDCT(interview.tuyendungId);
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
                                                child: Column(
                                                  children: [
                                                    for (var i = 0; i < listUserAAMSelect.length; i++)
                                                      Container(
                                                        margin: EdgeInsets.only(bottom: 30),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: [
                                                            Expanded(
                                                              flex: 3,
                                                              child: Row(
                                                                children: [
                                                                  Flexible(
                                                                      child: Text(
                                                                          (listUserAAMSelect.length == 1)
                                                                              ? 'Người phỏng vấn:'
                                                                              : "Người phỏng vấn ${i + 1}:",
                                                                          style: titleWidgetBox)),
                                                                  SizedBox(width: 5),
                                                                  Text(
                                                                    "*",
                                                                    style: TextStyle(color: Colors.red),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            Expanded(
                                                                flex: 5,
                                                                child: Row(
                                                                  children: [
                                                                    Flexible(
                                                                      child: Container(
                                                                        color: Colors.white,
                                                                        width: MediaQuery.of(context).size.width * 0.20,
                                                                        height: 40,
                                                                        child: DropdownSearch<UserAAM>(
                                                                          hint: "Chọn",
                                                                          maxHeight: 350,
                                                                          mode: Mode.MENU,
                                                                          showSearchBox: true,
                                                                          onFind: (String? filter) => getListUser(),
                                                                          itemAsString: (UserAAM? u) => (u!.fullName != "" || u.userCode != "")
                                                                              ? "${u.fullName} - ${u.userCode}"
                                                                              : "",
                                                                          dropdownSearchDecoration: styleDropDown,
                                                                          selectedItem: listUserAAMSelect[i],
                                                                          onChanged: (value) {
                                                                            setState(() {
                                                                              listUserAAMSelect[i] = value!;
                                                                              print(value.id);
                                                                            });
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(width: 5),
                                                                    (listUserAAMSelect.length == 1)
                                                                        ? Row(
                                                                            children: [
                                                                              IconButton(
                                                                                onPressed: () {
                                                                                  setState(() {
                                                                                    listUserAAMSelect.add(UserAAM(id: 0, userCode: "", fullName: ""));
                                                                                  });
                                                                                },
                                                                                icon: Icon(
                                                                                  Icons.add,
                                                                                  size: 25,
                                                                                  color: mainColorPage,
                                                                                ),
                                                                              ),
                                                                              SizedBox(width: 40)
                                                                            ],
                                                                          )
                                                                        : (listUserAAMSelect.length - 1 == i)
                                                                            ? Row(
                                                                                children: [
                                                                                  IconButton(
                                                                                    onPressed: () {
                                                                                      setState(() {
                                                                                        listUserAAMSelect.removeAt(i);
                                                                                      });
                                                                                    },
                                                                                    icon: Icon(
                                                                                      Icons.remove,
                                                                                      size: 25,
                                                                                      color: mainColorPage,
                                                                                    ),
                                                                                  ),
                                                                                  IconButton(
                                                                                    onPressed: () {
                                                                                      setState(() {
                                                                                        listUserAAMSelect
                                                                                            .add(UserAAM(id: 0, userCode: "", fullName: ""));
                                                                                      });
                                                                                    },
                                                                                    icon: Icon(
                                                                                      Icons.add,
                                                                                      size: 25,
                                                                                      color: mainColorPage,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              )
                                                                            : Row(
                                                                                children: [
                                                                                  IconButton(
                                                                                    onPressed: () {
                                                                                      setState(() {
                                                                                        listUserAAMSelect.removeAt(i);
                                                                                      });
                                                                                    },
                                                                                    icon: Icon(
                                                                                      Icons.remove,
                                                                                      size: 25,
                                                                                      color: mainColorPage,
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(width: 40)
                                                                                ],
                                                                              )
                                                                  ],
                                                                )),
                                                          ],
                                                        ),
                                                      ),
                                                  ],
                                                )),
                                            Expanded(flex: 1, child: Container()),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(50, 0, 0, 0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                child: Container(
                                                  margin: EdgeInsets.only(bottom: 30),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        flex: 3,
                                                        child: Row(
                                                          children: [
                                                            Text('Phòng ban:', style: titleWidgetBox),
                                                            Text("*",
                                                                style: TextStyle(
                                                                  color: Colors.red,
                                                                  fontSize: 16,
                                                                )),
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                          flex: 5,
                                                          child: Container(
                                                            color: Colors.white,
                                                            width: MediaQuery.of(context).size.width * 0.20,
                                                            height: 40,
                                                            child: DropdownSearch<Depart>(
                                                              hint: "${resultPhongBan![0].departName}",
                                                              mode: Mode.MENU,
                                                              showSearchBox: true,
                                                              selectedItem: interview.depart,
                                                              onFind: (String? filter) => getPhongBan(listPB!),
                                                              itemAsString: (Depart? u) => u!.departName,
                                                              dropdownSearchDecoration: styleDropDown,
                                                              onChanged: (value) {
                                                                setState(() {
                                                                  interview.depart = value;
                                                                  interview.duty = Duty(id: 0, dutyName: '', departId: 0);
                                                                  interview.qty = 0;
                                                                });
                                                              },
                                                            ),
                                                          )),
                                                    ],
                                                  ),
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
                                                      flex: 3,
                                                      child: Row(
                                                        children: [
                                                          Text('Vị trí:', style: titleWidgetBox),
                                                          Text("*",
                                                              style: TextStyle(
                                                                color: Colors.red,
                                                                fontSize: 16,
                                                              )),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                        flex: 5,
                                                        child: Container(
                                                          color: Colors.white,
                                                          width: MediaQuery.of(context).size.width * 0.20,
                                                          height: 40,
                                                          child: DropdownSearch<Duty>(
                                                            mode: Mode.MENU,
                                                            showSearchBox: true,
                                                            selectedItem: interview.duty,
                                                            onFind: (String? filter) => getVaiTro(interview.depart!.id),
                                                            itemAsString: (Duty? u) => u!.dutyName,
                                                            dropdownSearchDecoration: styleDropDown,
                                                            onChanged: (value) {
                                                              setState(() {
                                                                interview.duty = value;
                                                                print(value!.id);
                                                                getQty(interview.tuyendungId, interview.depart!.id, interview.duty!.id);
                                                              });
                                                            },
                                                          ),
                                                        )),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(flex: 1, child: Container()),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(50, 0, 0, 0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                flex: 3,
                                                child: Container(
                                                  margin: EdgeInsets.only(bottom: 30),
                                                  height: 40,
                                                  // decoration: borderAllContainerBox,
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 3,
                                                        child: Text(
                                                          'Số lượng cần tuyển:',
                                                          style: titleWidgetBox,
                                                        ),
                                                      ),
                                                      Expanded(
                                                          flex: 5,
                                                          child: TextField(
                                                            enabled: false,
                                                            decoration: InputDecoration(
                                                              contentPadding: const EdgeInsets.fromLTRB(10, 7, 5, 0),
                                                              disabledBorder: OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                    color: Color(0xFF000000),
                                                                    width: 0.5,
                                                                    style: BorderStyle.solid,
                                                                  ),
                                                                  borderRadius: BorderRadius.all(Radius.circular(0))),
                                                            ),
                                                            controller: TextEditingController(text: "${interview.qty}"),
                                                          )),
                                                    ],
                                                  ),
                                                )),
                                            SizedBox(width: 100),
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                child: TextFieldValidatedForm(
                                                  type: 'Number',
                                                  height: 40,
                                                  controller: soLuongDaTuyen,
                                                  label: 'Số lượng ứng viên:',
                                                  requiredValue: 1,
                                                  flexLable: 3,
                                                  onChange: (e) {
                                                    setState(() {
                                                      if (e != "") {
                                                        int item = int.parse(e);
                                                        interview.candidateQty = item;
                                                      }
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                            Expanded(flex: 1, child: Container()),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(50, 0, 0, 0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                margin: EdgeInsets.only(bottom: 30),
                                                child: DatePickerBox1(
                                                    label: Row(
                                                      children: [
                                                        Text(
                                                          'Thời gian:',
                                                          style: titleWidgetBox,
                                                        ),
                                                        Text("*",
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                              fontSize: 16,
                                                            )),
                                                      ],
                                                    ),
                                                    requestDayAfter: dayNow,
                                                    flexLabel: 3,
                                                    isTime: true,
                                                    selectedDateFunction: (day) {
                                                      // timeNeed = day;
                                                      setState(() {});
                                                    },
                                                    selectedTimeFunction: (time) {
                                                      // print(time);
                                                      setState(() {});
                                                    },
                                                    getFullTime: (time) {
                                                      print(time);
                                                      setState(() {
                                                        interview.interviewTime = time.toString();
                                                      });
                                                    }),
                                              ),
                                            ),
                                            SizedBox(width: 100),
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                child: TextFieldValidatedForm(
                                                  type: 'None',
                                                  height: 40,
                                                  label: 'Địa điểm:',
                                                  flexLable: 3,
                                                  onChange: (e) {
                                                    interview.interviewAddress = e;
                                                  },
                                                ),
                                              ),
                                            ),
                                            Expanded(flex: 1, child: Container()),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.fromLTRB(50, 0, 0, 30),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                  flex: 3,
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                          flex: 3,
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              Flexible(
                                                                child: Text(
                                                                  "Yêu cầu chi tiết về công việc:",
                                                                  style: titleWidgetBox,
                                                                ),
                                                              ),
                                                            ],
                                                          )),
                                                      Expanded(
                                                        flex: 5,
                                                        child: TextField(
                                                          minLines: 5,
                                                          maxLines: 10,
                                                          decoration: InputDecoration(
                                                            contentPadding: EdgeInsets.fromLTRB(10, 10, 5, 5),
                                                            filled: true,
                                                            fillColor: Colors.white,
                                                            focusedBorder: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(0),
                                                            ),
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(0),
                                                            ),
                                                          ),
                                                          onChanged: (e) {
                                                            interview.jobDesc = e;
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                              SizedBox(width: 100),
                                              Expanded(flex: 3, child: Container()),
                                              Expanded(child: Row())
                                            ],
                                          )),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(50, 0, 30, 0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            getRule(listRule.data, Role.Sua, context)
                                                ? Container(
                                                    margin: EdgeInsets.only(left: 20),
                                                    child: TextButton(
                                                      style: TextButton.styleFrom(
                                                        padding: const EdgeInsets.symmetric(
                                                          vertical: 20.0,
                                                          horizontal: 30.0,
                                                        ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(5.0),
                                                        ),
                                                        backgroundColor: Color.fromRGBO(245, 117, 29, 1),
                                                        primary: Theme.of(context).iconTheme.color,
                                                        textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                                      ),
                                                      onPressed: () async {
                                                        String interviewComponents = "";
                                                        var check = listUserAAMSelect.length;
                                                        for (var i = 0; i < listUserAAMSelect.length; i++) {
                                                          if (listUserAAMSelect[i].id == 0) {
                                                            break;
                                                          } else {
                                                            interviewComponents += ",";
                                                            var checkString = interviewComponents.indexOf(",${listUserAAMSelect[i].id},");
                                                            if (checkString == -1) {
                                                              int cmm = interviewComponents.length;
                                                              interviewComponents = interviewComponents.substring(0, cmm - 1);
                                                              interviewComponents += ",${listUserAAMSelect[i].id}";
                                                              check -= 1;
                                                            } else {
                                                              showToast(
                                                                context: context,
                                                                msg: "Người tuyển dụng trùng",
                                                                color: colorOrange,
                                                                icon: const Icon(Icons.warning),
                                                              );
                                                              int cmm = interviewComponents.length;
                                                              interviewComponents = interviewComponents.substring(0, cmm - 1);
                                                              break;
                                                            }
                                                          }
                                                        }
                                                        if (check == 0) {
                                                          if (interview.tuyendungId == 0 ||
                                                              interview.candidateQty == null ||
                                                              interview.candidateQty == 0 ||
                                                              interview.depart!.id == 0 ||
                                                              interview.duty!.id == 0 ||
                                                              interview.interviewTime == "")
                                                            showToast(
                                                              context: context,
                                                              msg: "Phải điền đầy đủ thông tin",
                                                              color: colorOrange,
                                                              icon: const Icon(Icons.warning),
                                                            );
                                                          else if (interview.qty == 0)
                                                            showToast(
                                                              context: context,
                                                              msg: "Vị trí này không có yêu cầu tuyển dụng",
                                                              color: colorOrange,
                                                              icon: const Icon(Icons.warning),
                                                            );
                                                          else {
                                                            interview.interviewComponents = interviewComponents.substring(1);
                                                            var checkNow = await addLPV(interview, user.userLoginCurren['id']);
                                                            if (checkNow == true) {
                                                              Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/lich-phong-van");
                                                              showToast(
                                                                context: context,
                                                                msg: "Tạo lịch phỏng vấn thành công",
                                                                color: Color.fromARGB(136, 72, 238, 67),
                                                                icon: const Icon(Icons.done),
                                                              );
                                                              postNotifi(
                                                                  "Hệ thống thông báo",
                                                                  "Có lịch phỏng vấn nhân sự lúc ${DateFormat('HH:mm -- dd/MM/yyyy').format(DateTime.parse(interview.interviewTime.toString()).toLocal())}.",
                                                                  interview.depart!.id);
                                                            } else {
                                                              showToast(
                                                                context: context,
                                                                msg: "Tạo lịch phỏng vấn không thành công",
                                                                color: colorOrange,
                                                                icon: const Icon(Icons.close),
                                                              );
                                                            }
                                                          }
                                                        } else
                                                          showToast(
                                                            context: context,
                                                            msg: "Phải điền đầy đủ thông tin",
                                                            color: colorOrange,
                                                            icon: const Icon(Icons.warning),
                                                          );
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
                                              margin: EdgeInsets.only(left: 20),
                                              child: TextButton(
                                                style: TextButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(
                                                    vertical: 20,
                                                    horizontal: 30,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(5.0),
                                                  ),
                                                  backgroundColor: Color.fromRGBO(245, 117, 29, 1),
                                                  primary: Theme.of(context).iconTheme.color,
                                                  textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                                ),
                                                onPressed: () {
                                                  Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/lich-phong-van");
                                                  showToast(
                                                    context: context,
                                                    msg: "Đã hủy tạo lịch phỏng vấn",
                                                    color: colorOrange,
                                                    icon: const Icon(Icons.done),
                                                  );
                                                },
                                                child: Row(
                                                  children: [
                                                    Text('Hủy', style: textButton),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ]),
                          Footer(marginFooter: EdgeInsets.only(top: 5), paddingFooter: EdgeInsets.all(15)),
                          SizedBox(height: 20)
                        ],
                      ),
                    ),
                  ));
        } else if (listRule.hasError) {
          return Text('${listRule.error}');
        }

        // By default, show a loading spinner.
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
