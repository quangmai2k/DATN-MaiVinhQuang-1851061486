import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/forms/nhan_su/setting-data/depart.dart';
import 'package:gentelella_flutter/widgets/forms/nhan_su/setting-data/duty.dart';
import 'package:gentelella_flutter/widgets/forms/nhan_su/setting-data/userAAM.dart';
import 'package:gentelella_flutter/widgets/ui/navigation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../api.dart';
import '../../../common/style.dart';
import '../../../common/toast.dart';
import '../../../common/widgets_form.dart';
import '../../../model/model.dart';
import '../../forms/nhan_su/setting-data/detailed-recruitment.dart';
import '../../forms/nhan_su/setting-data/interview.dart';

class Updatelpv extends StatefulWidget {
  final String idLPV;
  Interview? interViewData;
  Function? callback;
  Updatelpv({Key? key, required this.idLPV, this.interViewData, this.callback}) : super(key: key);

  @override
  State<Updatelpv> createState() => _UpdatelpvState();
}

class _UpdatelpvState extends State<Updatelpv> {
  late Interview interview;
  TextEditingController soLuongDaTuyen = TextEditingController();
  var timeDayPV;
  var timeHoursPV;
  bool checkTime = true;
  bool checkHeight = true;
  Map<int, String> trangThai = {0: 'Chưa phỏng vấn', 1: 'Đã phỏng vấn', 2: 'Hủy'};
  var resultLPV = {};
  late Future<dynamic> listLPV;
  Future<Interview> getLPV() async {
    var getLPV1 = await httpGet("/api/tuyendung-phongvan/get/${widget.idLPV}", context);
    if (getLPV1.containsKey("body")) {
      setState(() {
        resultLPV = jsonDecode(getLPV1["body"]);
        interview.id = resultLPV['id'];
        interview.tuyendungId = resultLPV['tuyendungId'];
        interview.title = resultLPV['tuyendung']['title'];
        interview.tuyendungChitietId = resultLPV['tuyendungChitietId'];
        interview.depart = Depart(id: resultLPV['tuyendungChitiet']['departId'], departName: resultLPV['tuyendungChitiet']['phongban']['departName']);
        interview.duty = Duty(
            id: resultLPV['tuyendungChitiet']['dutyId'],
            dutyName: resultLPV['tuyendungChitiet']['vaitro']['name'],
            departId: resultLPV['tuyendungChitiet']['departId']);
        interview.qty = resultLPV['qty'];
        interview.candidateQty = resultLPV['candidateQty'] ?? 0;
        interview.qtyRecruited = resultLPV['qtyRecruited'] ?? 0;
        interview.interviewAddress = resultLPV['interviewAddress'] ?? "";
        interview.interviewTime = resultLPV['interviewTime'];
        interview.jobDesc = resultLPV['jobDesc'] ?? "";
        interview.status = resultLPV['status'];
        interview.interviewComponents = resultLPV['interviewComponents'] ?? "";
        interview.createUser = UserAAM(
          id: resultLPV['recruitmentUser'],
          userCode: (resultLPV['nhanvientuyendung'] != null) ? (resultLPV['nhanvientuyendung']['userCode']) ?? "" : "",
          fullName: (resultLPV['nhanvientuyendung'] != null) ? (resultLPV['nhanvientuyendung']['fullName']) ?? "" : "",
        );
        timeDayPV = DateFormat('yyyy-MM-dd').format(DateTime.parse(interview.interviewTime.toString()).toLocal());
        timeHoursPV = DateFormat('HH:mm').format(DateTime.parse(interview.interviewTime.toString()).toLocal());
      });
      return interview;
    }
    return interview;
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

  List<UserAAM> listUserAAMSelect = [];
  Future<List<UserAAM>> getListUserSelected(String listUserAAM) async {
    var listUser = listUserAAM.split(",");
    String findID = "";
    for (var i = 0; i < listUser.length; i++) {
      findID += "or id:${listUser[i]} ";
    }
    if (findID.length > 0) findID = findID.substring(3);
    var response2 = await httpGet("/api/nguoidung/get/page?filter=$findID", context);
    var body = jsonDecode(response2['body']);
    var content = [];
    if (response2.containsKey("body")) {
      setState(() {
        content = body['content'];
        listUserAAMSelect = content.map((e) {
          return UserAAM.fromJson(e);
        }).toList();
      });
    }

    return listUserAAMSelect;
  }

  Future<List<UserAAM>> getListUser() async {
    List<UserAAM> listUserAAM = [];
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

    return listUserAAM;
  }

  upDateLPV(Interview interview) async {
    var requestBody = {
      "tuyendungChitietId": interview.tuyendungChitietId,
      "dutyId": interview.duty!.id,
      "qty": interview.qty,
      "candidateQty": interview.candidateQty,
      "interviewAddress": interview.interviewAddress,
      "interviewTime": interview.interviewTime,
      "jobDesc": interview.jobDesc,
      "status": interview.status,
      "qtyRecruited": interview.qtyRecruited,
      "interviewComponents": interview.interviewComponents
    };
    print("response:$requestBody");
    var response = await httpPut("/api/tuyendung-phongvan/put/${widget.idLPV}", requestBody, context);
    print("response:$response");
  }

  void callAPI() async {
    if (widget.interViewData != null) {
      print("Gans");
      interview = widget.interViewData!;
      timeDayPV = DateFormat('yyyy-MM-dd').format(DateTime.parse(interview.interviewTime.toString()).toLocal());
      timeHoursPV = DateFormat('HH:mm').format(DateTime.parse(interview.interviewTime.toString()).toLocal());
    } else
      await getLPV();
    await getListTDCT(interview.tuyendungId);
    await getListUserSelected(interview.interviewComponents.toString());
  }

  @override
  void initState() {
    super.initState();
    interview = new Interview();
    callAPI();
  }

  @override
  void dispose() {
    soLuongDaTuyen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
      widgetBody: FutureBuilder<dynamic>(
        future: userRule('/sua-lpv', context),
        builder: (context, listRule) {
          if (listRule.hasData) {
            return Consumer<NavigationModel>(
                builder: (context, navigationModel, child) => Container(
                      child: Container(
                        child: ListView(
                          children: [
                            Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                              TitlePage(
                                listPreTitle: [
                                  {'url': "/nhan-su", 'title': 'Dashboard'},
                                  {'url': "/lich-phong-van", 'title': 'Lịch phỏng vấn'},
                                ],
                                content: 'Cập nhật',
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
                                    (interview.id != null)
                                        ? Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(50, 10, 50, 0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      flex: 3,
                                                      child: Container(
                                                        height: 40,
                                                        margin: EdgeInsets.only(bottom: 30),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: [
                                                            Expanded(
                                                              flex: 3,
                                                              child: Text('Tiêu đề:', style: titleWidgetBox),
                                                            ),
                                                            Expanded(
                                                                flex: 5,
                                                                child: TextField(
                                                                  enabled: false,
                                                                  decoration: InputDecoration(
                                                                    contentPadding: const EdgeInsets.fromLTRB(10, 7, 5, 0),
                                                                    disabledBorder: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.circular(0),
                                                                      borderSide: BorderSide(
                                                                        color: const Color(0xFF000000),
                                                                        width: 0.5,
                                                                        style: BorderStyle.solid,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  controller: TextEditingController(text: "${interview.title}"),
                                                                )),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 200),
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
                                                      ),
                                                    ),
                                                    // Expanded(flex: 1, child: Container()),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                                                child: Row(
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
                                                                    // hint: "${resultPhongBan![0].departName}",
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
                                                    SizedBox(width: 200),
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
                                                                        interview.qtyRecruited = 0;
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
                                                    // Expanded(flex: 1, child: Container()),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
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
                                                                        borderRadius: BorderRadius.circular(0),
                                                                        borderSide: BorderSide(
                                                                          color: const Color(0xFF000000),
                                                                          width: 0.5,
                                                                          style: BorderStyle.solid,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    controller: TextEditingController(text: "${interview.qty}"),
                                                                  )),
                                                            ],
                                                          ),
                                                        )),
                                                    SizedBox(width: 200),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Container(
                                                        child: TextFieldValidatedForm(
                                                          type: 'Number',
                                                          height: 40,
                                                          controller: TextEditingController(text: "${interview.candidateQty}"),
                                                          label: 'Số lượng ứng viên:',
                                                          flexLable: 3,
                                                          callbackValue: (value) {
                                                            if (value == 40)
                                                              checkHeight = true;
                                                            else
                                                              checkHeight = false;
                                                            print(checkHeight);
                                                          },
                                                          onChange: (e) {
                                                            if (checkHeight) interview.candidateQty = int.parse(e);
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    // Expanded(flex: 1, child: Container()),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
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
                                                            flexLabel: 3,
                                                            dateDisplay:
                                                                "${timeDayPV.toString().substring(8)}${timeDayPV.toString().substring(4, 8)}${timeDayPV.toString().substring(0, 4)}",
                                                            timeDisplay: timeHoursPV,
                                                            isTime: true,
                                                            selectedDateFunction: (day) {
                                                              setState(() {
                                                                if (day == null)
                                                                  checkTime = false;
                                                                else {
                                                                  checkTime = true;
                                                                  interview.interviewTime = day.toString().substring(6) +
                                                                      day.toString().substring(2, 6) +
                                                                      day.toString().substring(0, 2) +
                                                                      interview.interviewTime!.substring(10);
                                                                  print(interview.interviewTime);
                                                                }
                                                              });
                                                            },
                                                            selectedTimeFunction: (hour) {
                                                              setState(() {
                                                                // print(hour);
                                                                if (hour == null)
                                                                  checkTime = false;
                                                                else
                                                                  checkTime = true;
                                                                print(interview.interviewTime);
                                                              });
                                                            },
                                                            getFullTime: (time) {
                                                              print(time);
                                                              setState(() {
                                                                if (time != null)
                                                                  interview.interviewTime = time.toString();
                                                                else
                                                                  interview.interviewTime = "";
                                                                print(interview.interviewTime);
                                                              });
                                                            }),
                                                      ),
                                                    ),
                                                    SizedBox(width: 200),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Container(
                                                        child: TextFieldValidatedForm(
                                                          type: 'None',
                                                          height: 40,
                                                          controller: TextEditingController(text: "${interview.interviewAddress}"),
                                                          label: 'Địa điểm:',
                                                          flexLable: 3,
                                                          onChange: (e) {
                                                            interview.interviewAddress = e;
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    // Expanded(flex: 1, child: Container()),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                  padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
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
                                                                  controller: TextEditingController(text: "${interview.jobDesc}"),
                                                                  onChanged: (e) {
                                                                    interview.jobDesc = e;
                                                                  },
                                                                ),
                                                              ),
                                                            ],
                                                          )),
                                                      SizedBox(width: 200),
                                                      Expanded(
                                                        flex: 3,
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              children: [
                                                                Expanded(
                                                                  flex: 3,
                                                                  child: Text('Trạng thái:', style: titleWidgetBox),
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
                                                                          '${trangThai[interview.status]}',
                                                                          style: const TextStyle(
                                                                            fontWeight: FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                        items: trangThai.entries
                                                                            .map((item) =>
                                                                                DropdownMenuItem<int>(value: item.key, child: Text(item.value)))
                                                                            .toList(),
                                                                        value: interview.status,
                                                                        onChanged: (value) {
                                                                          setState(() {
                                                                            interview.status = value as int?;
                                                                            if (interview.status == 0 || interview.status == 2) {
                                                                              interview.qtyRecruited = 0;
                                                                            }
                                                                          });
                                                                        },
                                                                        buttonHeight: 40,
                                                                        itemHeight: 40,
                                                                        dropdownDecoration: BoxDecoration(
                                                                            border: Border.all(color: const Color.fromRGBO(216, 218, 229, 1))),
                                                                        buttonDecoration:
                                                                            BoxDecoration(border: Border.all(width: 0.5, style: BorderStyle.solid)),
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
                                                            (interview.status == 1)
                                                                ? Container(
                                                                    margin: EdgeInsets.only(top: 30),
                                                                    child: TextFieldValidatedForm(
                                                                      type: 'Number',
                                                                      height: 40,
                                                                      controller: TextEditingController(text: "${interview.qtyRecruited}"),
                                                                      label: 'Số lượng trúng tuyển:',
                                                                      flexLable: 3,
                                                                      callbackValue: (value) {
                                                                        if (value == 40)
                                                                          checkHeight = true;
                                                                        else
                                                                          checkHeight = false;
                                                                        print(checkHeight);
                                                                      },
                                                                      onChange: (e) {
                                                                        if (checkHeight) interview.qtyRecruited = int.parse(e);
                                                                      },
                                                                    ),
                                                                  )
                                                                : Container()
                                                          ],
                                                        ),
                                                      ),
                                                      // Expanded(flex: 1, child: Container()),
                                                    ],
                                                  )),
                                              Padding(
                                                  padding: const EdgeInsets.fromLTRB(50, 0, 50, 30),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Expanded(flex: 3, child: Row()),
                                                      SizedBox(width: 200),
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
                                                                  'Nhân viên tuyển dụng:',
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
                                                                        borderRadius: BorderRadius.circular(0),
                                                                        borderSide: BorderSide(
                                                                          color: const Color(0xFF000000),
                                                                          width: 0.5,
                                                                          style: BorderStyle.solid,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    controller: TextEditingController(
                                                                        text:
                                                                            "${interview.createUser!.fullName} - ${interview.createUser!.userCode} "),
                                                                  )),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      // Expanded(flex: 1, child: Container()),
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
                                                                textStyle:
                                                                    Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                                              ),
                                                              onPressed: () async {
                                                                String interviewComponents = "";
                                                                var checkLenght = listUserAAMSelect.length;
                                                                for (var i = 0; i < listUserAAMSelect.length; i++) {
                                                                  if (listUserAAMSelect[i].id == 0) {
                                                                    break;
                                                                  } else {
                                                                    interviewComponents += ",";
                                                                    var checkString = interviewComponents.indexOf(",${listUserAAMSelect[i].id},");
                                                                    if (checkString == -1) {
                                                                      int components = interviewComponents.length;
                                                                      interviewComponents = interviewComponents.substring(0, components - 1);
                                                                      interviewComponents += ",${listUserAAMSelect[i].id}";
                                                                      checkLenght -= 1;
                                                                    } else {
                                                                      showToast(
                                                                        context: context,
                                                                        msg: "Nhân viên tuyển dụng trùng",
                                                                        color: colorOrange,
                                                                        icon: const Icon(Icons.warning),
                                                                      );
                                                                      int components = interviewComponents.length;
                                                                      interviewComponents = interviewComponents.substring(0, components - 1);
                                                                      break;
                                                                    }
                                                                  }
                                                                }
                                                                if (checkLenght > 0) {
                                                                  showToast(
                                                                    context: context,
                                                                    msg: "Nhân viên tuyển dụng không được để trống",
                                                                    color: colorOrange,
                                                                    icon: const Icon(Icons.warning),
                                                                  );
                                                                } else if (interview.tuyendungId == 0 ||
                                                                    interview.candidateQty == 0 ||
                                                                    interview.interviewTime == "" ||
                                                                    checkTime == false)
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
                                                                else if (checkHeight) {
                                                                  interview.interviewComponents = interviewComponents.substring(1);
                                                                  await upDateLPV(interview);
                                                                  Navigator.pop(context);
                                                                  setState(() {
                                                                    widget.callback!(interview);
                                                                  });
                                                                  showToast(
                                                                    context: context,
                                                                    msg: "Cập nhật lịch phỏng vấn thành công",
                                                                    color: Color.fromARGB(136, 72, 238, 67),
                                                                    icon: const Icon(Icons.done),
                                                                  );
                                                                } else {
                                                                  showToast(
                                                                    context: context,
                                                                    msg: "Số lượng tuyển dụng không được nhập chữ",
                                                                    color: colorOrange,
                                                                    icon: const Icon(Icons.warning),
                                                                  );
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
                                                          textStyle:
                                                              Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                          showToast(
                                                            context: context,
                                                            msg: "Đã hủy cập nhật lịch phỏng vấn",
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
                                          )
                                        : Center(
                                            child: const CircularProgressIndicator(),
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
      ),
    );
  }
}
