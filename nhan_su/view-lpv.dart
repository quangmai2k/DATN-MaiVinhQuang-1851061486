import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../api.dart';
import '../../../common/style.dart';
import '../../../common/widgets_form.dart';
import '../../../model/model.dart';
import '../../forms/nhan_su/setting-data/depart.dart';
import '../../forms/nhan_su/setting-data/duty.dart';
import '../../forms/nhan_su/setting-data/interview.dart';
import '../../forms/nhan_su/setting-data/userAAM.dart';
import '../../ui/navigation.dart';

class ViewLPVBody extends StatefulWidget {
  final String idLPV;
  const ViewLPVBody({Key? key, required this.idLPV}) : super(key: key);

  @override
  State<ViewLPVBody> createState() => _ViewLPVBodyState();
}

class _ViewLPVBodyState extends State<ViewLPVBody> {
  Map<int, String> trangThai = {0: 'Chưa phỏng vấn', 1: 'Đã phỏng vấn', 2: 'Hủy'};
  Interview interview = Interview();
  bool checkTime = true;
  bool checkHeight = true;
  var resultLPV = {};
  late Future<dynamic> listLPV;
  Future<Interview> getLPV1() async {
    var getLPV1 = await httpGet("/api/tuyendung-phongvan/get/${widget.idLPV}", context);
    if (getLPV1.containsKey("body")) {
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
      interview.qty = resultLPV['qty'] ?? 0;
      interview.candidateQty = resultLPV['candidateQty'] ?? 0;
      interview.qtyRecruited = resultLPV['qtyRecruited'] ?? 0;
      interview.interviewAddress = resultLPV['interviewAddress'] ?? "";
      interview.interviewTime = resultLPV['interviewTime'];
      interview.jobDesc = resultLPV['jobDesc'] ?? "";
      interview.status = resultLPV['status'] ?? 0;
      interview.interviewComponents = resultLPV['interviewComponents'] ?? "";
      interview.createUser = UserAAM(
        id: resultLPV['recruitmentUser'],
        userCode: (resultLPV['nhanvientuyendung'] != null) ? (resultLPV['nhanvientuyendung']['userCode']) ?? "" : "",
        fullName: (resultLPV['nhanvientuyendung'] != null) ? (resultLPV['nhanvientuyendung']['fullName']) ?? "" : "",
      );
      return interview;
    }
    return interview;
  }

  List<UserAAM> listUserAAMSelect = [];
  Future<List<UserAAM>> getListUserSelected(String listUserAAM) async {
    listUserAAMSelect = [];
    var listUser = listUserAAM.split(",");
    String findID = "";
    for (var i = 0; i < listUser.length; i++) {
      findID += "or id:${listUser[i]} ";
    }
    if (findID.length > 0) findID = findID.substring(3);
    var response2;
    if (listUserAAM.length > 0) {
      response2 = await httpGet("/api/nguoidung/get/page?filter=$findID", context);
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
    }

    return listUserAAMSelect;
  }

  bool status = false;
  void callAPI() async {
    await getLPV1();
    await getListUserSelected(interview.interviewComponents.toString());
    setState(() {
      status = true;
    });
  }

  void initState() {
    super.initState();
    callAPI();
  }

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
        widgetBody: FutureBuilder<dynamic>(
      future: userRule('/view-lpv', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return Consumer<NavigationModel>(
            builder: (context, navigationModel, child) => Container(
              child: ListView(
                children: [
                  TitlePage(
                    listPreTitle: [
                      {'url': "/nhan-su", 'title': 'Dashboard'},
                      {'url': "/lich-phong-van", 'title': 'Lịch phỏng vấn'},
                    ],
                    content: 'Thông tin',
                  ),
                  //thông tin
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
                              'Thông tin chi tiết',
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

                        //body content
                        (status)
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
                                                  height: 40,
                                                  margin: EdgeInsets.only(bottom: 30),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        flex: 3,
                                                        child: Text(
                                                            (listUserAAMSelect.length == 1)
                                                                ? 'Nhân viên phỏng vấn:'
                                                                : "Nhân viên phỏng vấn ${i + 1}:",
                                                            style: titleWidgetBox),
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
                                                                text: "${listUserAAMSelect[i].fullName} - ${listUserAAMSelect[i].userCode}"),
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
                                            height: 40,
                                            margin: EdgeInsets.only(bottom: 30),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  flex: 3,
                                                  child: Text('Phòng ban:', style: titleWidgetBox),
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
                                                      controller: TextEditingController(text: "${interview.depart!.departName}"),
                                                    )),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 200),
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
                                                  child: Text('Vị trí:', style: titleWidgetBox),
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
                                                      controller: TextEditingController(text: "${interview.duty!.dutyName}"),
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
                                            margin: EdgeInsets.only(bottom: 30),
                                            height: 40,
                                            // decoration: borderAllContainerBox,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    'Số lượng tham gia:',
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
                                                      controller: TextEditingController(text: "${interview.candidateQty}"),
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
                                      mainAxisAlignment: MainAxisAlignment.start,
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
                                                    'Thời gian phỏng vấn:',
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
                                                              "${DateFormat('HH:mm -- dd/MM/yyyy').format(DateTime.parse(interview.interviewTime.toString()))}"),
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
                                            height: 40,
                                            // decoration: borderAllContainerBox,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    'Địa điểm:',
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
                                                      controller: TextEditingController(text: "${interview.interviewAddress}"),
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
                                                      enabled: false,
                                                      minLines: 5,
                                                      maxLines: 10,
                                                      decoration: InputDecoration(
                                                        disabledBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(0),
                                                          borderSide: BorderSide(
                                                            color: const Color(0xFF000000),
                                                            width: 0.5,
                                                            style: BorderStyle.solid,
                                                          ),
                                                        ),
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
                                                Container(
                                                  margin: EdgeInsets.only(bottom: 30),
                                                  height: 40,
                                                  // decoration: borderAllContainerBox,
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 3,
                                                        child: Text(
                                                          'Trạng thái:',
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
                                                            controller: TextEditingController(text: "${trangThai[interview.status]}"),
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                                (interview.status == 1)
                                                    ? Container(
                                                        child: TextFieldValidatedForm(
                                                          type: 'Number',
                                                          height: 40,
                                                          controller: TextEditingController(text: "${interview.qtyRecruited}"),
                                                          label: 'Số lượng đã tuyển:',
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
                                                            text: "${interview.createUser!.fullName} - ${interview.createUser!.userCode} "),
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
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
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
                                ],
                              )
                            : Center(child: CircularProgressIndicator())
                      ],
                    ),
                  ),
                  Footer(marginFooter: EdgeInsets.only(top: 5), paddingFooter: EdgeInsets.all(15)),
                  SizedBox(height: 20)
                ],
              ),
            ),
          );
        } else if (listRule.hasError) {
          return Text('${listRule.error}');
        }

        // By default, show a loading spinner.
        return Center(child: CircularProgressIndicator());
      },
    ));
  }
}
