// ignore_for_file: unused_local_variable
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/api.dart';
import 'package:provider/provider.dart';
import '../../../common/style.dart';
import '../../../common/toast.dart';
import '../../../common/widgets_form.dart';
import '../../../model/model.dart';
import '../../forms/nhan_su/setting-data/depart.dart';
import '../../forms/nhan_su/setting-data/duty.dart';
import '../../forms/nhan_su/setting-data/recruitment.dart';
import '../../ui/navigation.dart';

class UpdatedntdBody extends StatefulWidget {
  final String idTTDNTD;
  Recruitment? recruitment;
  Function? callBack;
  UpdatedntdBody({Key? key, required this.idTTDNTD, this.recruitment, this.callBack}) : super(key: key);

  @override
  State<UpdatedntdBody> createState() => _UpdatedntdBodyState();
}

class _UpdatedntdBodyState extends State<UpdatedntdBody> {
  TextEditingController tieuDe = TextEditingController();
  TextEditingController moTa = TextEditingController();

  List<DetailedRecruitment> listRecruitResult = [];
  List<int> checkDelete = [];
  late Future<List<DetailedRecruitment>> futureListRecruit;
  Future<List<DetailedRecruitment>> getDetailedRecruitment() async {
    var response = await httpGet("/api/tuyendung-chitiet/get/page?filter=tuyendungId:${widget.idTTDNTD}&sort=id", context);
    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      content = body['content'];
      if (content.length > 0) {
        for (var item in content) {
          DetailedRecruitment e = new DetailedRecruitment(
              id: item['id'],
              depart: Depart(id: item['departId'], departName: item['phongban']['departName']),
              duty: Duty(id: item['dutyId'], dutyName: item['vaitro']['name'], departId: item['departId']),
              qty: TextEditingController(text: item['qty'].toString()),
              salary: TextEditingController(text: item['salary'].toString()),
              timeNeeded: item['timeNeeded'],
              jdFile: item['jdFile'],
              vision: 0);
          listRecruitResult.add(e);
          // print(e);
        }
        setState(() {
          tieuDe.text = content[0]['tuyendung']['title'] ?? "";
          moTa.text = content[0]['tuyendung']['description'] ?? "";
        });
      }

      return listRecruitResult;
    }

    return listRecruitResult;
  }

  List<Depart>? resultPhongBan;
  List<int?> selectedBP = [];
  Future<List<Depart>> getPhongBan(int userDepartID) async {
    var response1;
    if (userDepartID == 1 || userDepartID == 2)
      response1 = await httpGet("/api/phongban/get/page?sort=id,asc&filter=parentId:0 and id>2 and status:1", context);
    else
      response1 = await httpGet("/api/phongban/get/page?sort=id,asc&filter=id:$userDepartID and status:1 ", context);
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
    return content.map((e) {
      return Depart.fromJson(e);
    }).toList();
  }

  List<Duty>? resultVaiTro;
  List<int?> selectedVT = [];
  Future<List<Duty>> getVaiTro(var ipBp) async {
    var response = await httpGet("/api/vaitro/get/page?filter=departId:$ipBp and status:1", context);
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

  @override
  void initState() {
    futureListRecruit = getDetailedRecruitment();
    super.initState();
  }

//update đề nghị tuyển dụng
  upDateTuyenDung(int id, String title, String des) async {
    var requestBody = {"title": title, "description": des};
    print(requestBody);
    var a = await httpPut("/api/tuyendung/put/$id", requestBody, context);
    print(a);
    return a;
  }

  upDateTuyenDungChiTiet(DetailedRecruitment recruitResult) async {
    var requestBody = {
      "departId": recruitResult.depart.id,
      "dutyId": recruitResult.duty.id,
      "qty": recruitResult.qty.text,
      "salary": recruitResult.salary.text,
      "timeNeeded": recruitResult.timeNeeded,
      "jdFile": recruitResult.jdFile
    };
    var request = await httpPut("/api/tuyendung-chitiet/put/${recruitResult.id}", requestBody, context);
    print(request);
  }

  addTuyenDungChiTiet(int idTD, DetailedRecruitment recruitResult) async {
    var requestBody = {
      "tuyendungId": idTD,
      "departId": recruitResult.depart.id,
      "dutyId": recruitResult.duty.id,
      "qty": recruitResult.qty.text,
      "salary": recruitResult.salary.text,
      "timeNeeded": recruitResult.timeNeeded,
      "jdFile": recruitResult.jdFile
    };
    await httpPost("/api/tuyendung-chitiet/post/save", requestBody, context);
  }

  @override
  void dispose() {
    tieuDe.dispose();
    moTa.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
        widgetBody: FutureBuilder<dynamic>(
      future: userRule('/sua-dntd', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return Consumer2<NavigationModel, SecurityModel>(
            builder: (context, navigationModel, user, child) => Container(
              child: Container(
                child: ListView(
                  controller: ScrollController(),
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TitlePage(
                          listPreTitle: [
                            {'url': "/nhan-su", 'title': 'Dashboard'},
                            {'url': "/de-nghi-tuyen-dung-chuc-nang", 'title': 'Đề nghị tuyển dụng'},
                          ],
                          content: 'Cập nhật',
                        ),
                        FutureBuilder(
                            future: futureListRecruit,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Container(
                                  width: MediaQuery.of(context).size.width * 1,
                                  padding: paddingTitledPage,
                                  margin: EdgeInsets.only(right: 30, top: 30, left: 30),
                                  decoration: BoxDecoration(
                                    color: colorWhite,
                                    boxShadow: [boxShadowContainer],
                                    border: Border(
                                      bottom: borderTitledPage,
                                    ),
                                  ),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                                          padding: const EdgeInsets.fromLTRB(80, 0, 0, 0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: Container(
                                                  child: TextFieldValidatedForm(
                                                    type: 'Text',
                                                    height: 40,
                                                    controller: tieuDe,
                                                    label: 'Tiêu đề:',
                                                    flexLable: 2,
                                                    requiredValue: 1,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 150),
                                              Expanded(flex: 4, child: Container()),
                                            ],
                                          ),
                                        ),
                                        for (var i = 0; i < listRecruitResult.length; i++)
                                          Container(
                                            width: MediaQuery.of(context).size.width * 1,
                                            padding: paddingTitledPage,
                                            margin: EdgeInsets.only(bottom: 20),
                                            decoration: BoxDecoration(
                                              color: Color.fromARGB(255, 250, 250, 250),
                                              borderRadius: borderRadiusContainer,
                                              boxShadow: [boxShadowContainer],
                                              border: borderAllContainerBox,
                                            ),
                                            child: Column(children: [
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(50, 20, 0, 0),
                                                child: Row(
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
                                                                    mode: Mode.MENU,
                                                                    showSearchBox: true,
                                                                    maxHeight: 300,
                                                                    onFind: (String? filter) => getPhongBan(user.userLoginCurren['departId']),
                                                                    itemAsString: (Depart? u) => u!.departName,
                                                                    dropdownSearchDecoration: styleDropDown,
                                                                    selectedItem: listRecruitResult[i].depart,
                                                                    onChanged: (value) {
                                                                      setState(() {
                                                                        listRecruitResult[i].depart = value!;
                                                                        listRecruitResult[i].duty = Duty(id: 0, dutyName: "", departId: value.id);
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
                                                                    onFind: (String? filter) => getVaiTro(listRecruitResult[i].depart.id),
                                                                    itemAsString: (Duty? u) => u!.dutyName,
                                                                    dropdownSearchDecoration: styleDropDown,
                                                                    selectedItem: listRecruitResult[i].duty,
                                                                    onChanged: (value) {
                                                                      setState(() {
                                                                        listRecruitResult[i].duty = value!;

                                                                        // print(listRecruitmentDetail[i].idDuty);
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
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      flex: 3,
                                                      child: Container(
                                                        child: TextFieldValidatedForm(
                                                          type: 'Number',
                                                          controller: listRecruitResult[i].qty,
                                                          height: 40,
                                                          label: 'Số lượng\ncần tuyển:',
                                                          flexLable: 2,
                                                          requiredValue: 1,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 100),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Container(
                                                        margin: EdgeInsets.only(bottom: 30),
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              flex: 2,
                                                              child: Row(
                                                                children: [
                                                                  Flexible(
                                                                      child: Text(
                                                                    "Thời gian cần:",
                                                                    style: titleWidgetBox,
                                                                  )),
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
                                                                  decoration: BoxDecoration(
                                                                    border: Border.all(width: 0.5, style: BorderStyle.solid),
                                                                    color: Colors.white,
                                                                  ),
                                                                  padding: EdgeInsets.only(left: 8),
                                                                  child: (listRecruitResult[i].timeNeeded != "")
                                                                      ? MonthPickerLimit(
                                                                          pickTime: DateTime(
                                                                              int.parse(listRecruitResult[i].timeNeeded.toString().substring(0, 4)),
                                                                              int.parse(listRecruitResult[i].timeNeeded.toString().substring(5, 7))),
                                                                          afterLimit: DateTime(DateTime.now().year, DateTime.now().month),
                                                                          callBack: (day) {
                                                                            if (day != "")
                                                                              listRecruitResult[i].timeNeeded = "$day-28";
                                                                            else
                                                                              listRecruitResult[i].timeNeeded = "";
                                                                          },
                                                                        )
                                                                      : MonthPickerLimit(
                                                                          afterLimit: DateTime(DateTime.now().year, DateTime.now().month),
                                                                          callBack: (day) {
                                                                            if (day != "")
                                                                              listRecruitResult[i].timeNeeded = "$day-28";
                                                                            else
                                                                              listRecruitResult[i].timeNeeded = "";
                                                                          },
                                                                        )),
                                                            )
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
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      flex: 3,
                                                      child: Container(
                                                        child: TextFieldValidatedForm(
                                                          type: 'Text',
                                                          controller: listRecruitResult[i].salary,
                                                          height: 40,
                                                          label: 'Mức lương:',
                                                          flexLable: 2,
                                                          requiredValue: 1,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 100),
                                                    Expanded(
                                                        flex: 3,
                                                        child: Container(
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                  flex: 2,
                                                                  child: Row(
                                                                    children: [
                                                                      Text(
                                                                        "Tải file JD",
                                                                        style: titleWidgetBox,
                                                                      ),
                                                                    ],
                                                                  )),
                                                              Expanded(
                                                                  flex: 5,
                                                                  child: TextButton(
                                                                    onPressed: () async {
                                                                      var file = await FilePicker.platform.pickFiles(
                                                                        type: FileType.custom,
                                                                        allowedExtensions: ['pdf', 'docx', 'jpeg', 'png', 'jpg', 'xlsx'],
                                                                        withReadStream: true, //
                                                                      );
                                                                      if (file != null) {
                                                                        String fileName = await uploadFile(file, context: context) ?? "";
                                                                        setState(() {
                                                                          listRecruitResult[i].jdFile = fileName;
                                                                        });
                                                                      }
                                                                    },
                                                                    child: (listRecruitResult[i].jdFile != "" && listRecruitResult[i].jdFile != null)
                                                                        ? Text(listRecruitResult[i].jdFile!)
                                                                        : Icon(Icons.upload_file),
                                                                  ))
                                                            ],
                                                          ),
                                                        )),
                                                    Expanded(flex: 1, child: Container()),
                                                  ],
                                                ),
                                              ),
                                              if (i == listRecruitResult.length - 1)
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 30, bottom: 30),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      Container(
                                                        margin: EdgeInsets.only(left: 20),
                                                        child: TextButton(
                                                          style: TextButton.styleFrom(
                                                            padding: const EdgeInsets.symmetric(
                                                              vertical: 17.0,
                                                              horizontal: 10.0,
                                                            ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(5.0),
                                                            ),
                                                            backgroundColor: Color(0xff009c87),
                                                            primary: Theme.of(context).iconTheme.color,
                                                            textStyle:
                                                                Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                                          ),
                                                          onPressed: () async {
                                                            if (listRecruitResult[i].vision == 0) checkDelete.add(listRecruitResult[i].id);
                                                            // await httpDelete("/api/tuyendung-chitiet/del/${listRecruitResult[i].id}",context);
                                                            setState(() {
                                                              listRecruitResult.removeAt(i);
                                                            });
                                                          },
                                                          child: Row(
                                                            children: [
                                                              const Icon(Icons.indeterminate_check_box, color: Colors.white),
                                                            ],
                                                          ),
                                                        ),
                                                      ),

                                                      Container(
                                                        margin: EdgeInsets.only(left: 20),
                                                        child: TextButton(
                                                          style: TextButton.styleFrom(
                                                            padding: const EdgeInsets.symmetric(
                                                              vertical: 17,
                                                              horizontal: 10,
                                                            ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(5.0),
                                                            ),
                                                            backgroundColor: Color(0xff009c87),
                                                            primary: Theme.of(context).iconTheme.color,
                                                            textStyle:
                                                                Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                                          ),
                                                          onPressed: () {
                                                            setState(() {
                                                              listRecruitResult.add(DetailedRecruitment(
                                                                  id: -1,
                                                                  qty: TextEditingController(text: ""),
                                                                  salary: TextEditingController(text: ""),
                                                                  vision: 1,
                                                                  depart:
                                                                      (user.userLoginCurren['departId'] == 1 || user.userLoginCurren['departId'] == 2)
                                                                          ? Depart(id: 0, departName: '')
                                                                          : Depart(
                                                                              id: user.userLoginCurren['departId'],
                                                                              departName: (user.userLoginCurren['phongban'] != null)
                                                                                  ? user.userLoginCurren['phongban']['departName']
                                                                                  : ""),
                                                                  duty: Duty(id: 0, dutyName: '', departId: 0),
                                                                  timeNeeded: ""));
                                                            });
                                                          },
                                                          child: Row(
                                                            children: [
                                                              const Icon(Icons.add_box, color: Colors.white),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      // SizedBox(width: 450),
                                                    ],
                                                  ),
                                                )
                                              else
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 30, bottom: 30),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      Container(
                                                        margin: EdgeInsets.only(left: 20),
                                                        child: TextButton(
                                                          style: TextButton.styleFrom(
                                                            padding: const EdgeInsets.symmetric(
                                                              vertical: 17.0,
                                                              horizontal: 10.0,
                                                            ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(5.0),
                                                            ),
                                                            backgroundColor: Color(0xff009c87),
                                                            primary: Theme.of(context).iconTheme.color,
                                                            textStyle:
                                                                Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                                          ),
                                                          onPressed: () async {
                                                            if (listRecruitResult[i].vision == 0) checkDelete.add(listRecruitResult[i].id);
                                                            // await httpDelete("/api/tuyendung-chitiet/del/${listRecruitResult[i].id}",context);
                                                            setState(() {
                                                              listRecruitResult.removeAt(i);
                                                            });
                                                          },
                                                          child: Row(
                                                            children: [
                                                              const Icon(Icons.indeterminate_check_box, color: Colors.white),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ]),
                                          ),
                                        Padding(
                                            padding: const EdgeInsets.fromLTRB(50, 10, 50, 30),
                                            child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                      // flex: 3,
                                                      child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          'Mô tả chung cho đề nghị tuyển dụng:',
                                                          style: titleWidgetBox,
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    flex: 5,
                                                    child: TextField(
                                                      minLines: 5,
                                                      maxLines: 10,
                                                      controller: moTa,
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
                                                      onChanged: (e) {},
                                                    ),
                                                  ),
                                                ])),
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
                                                            vertical: 20,
                                                            horizontal: 30.0,
                                                          ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(5.0),
                                                          ),
                                                          // ignore: unnecessary_null_comparison
                                                          backgroundColor: Color.fromRGBO(245, 117, 29, 1),

                                                          primary: Theme.of(context).iconTheme.color,
                                                          textStyle:
                                                              Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                                        ),
                                                        onPressed: () async {
                                                          bool check = true;
                                                          if (tieuDe.text != "") {
                                                            for (var item in listRecruitResult)
                                                              if (item.depart.id == 0 ||
                                                                  item.duty.id == 0 ||
                                                                  item.qty.text == "" ||
                                                                  item.salary.text == "" ||
                                                                  item.timeNeeded == "") {
                                                                check = false;
                                                                break;
                                                              }
                                                          } else
                                                            check = false;
                                                          if (check) {
                                                            var result = await upDateTuyenDung(int.parse(widget.idTTDNTD), tieuDe.text, moTa.text);
                                                            if (result.containsKey("body")) {
                                                              for (var item in listRecruitResult) {
                                                                // print(item.id);
                                                                // print(item.qty);
                                                                // print(item.salary);
                                                                // print(item.timeNeeded);

                                                                // print("========");
                                                                if (item.vision == 0)
                                                                  await upDateTuyenDungChiTiet(item);
                                                                else
                                                                  await addTuyenDungChiTiet(int.parse(widget.idTTDNTD), item);
                                                              }
                                                              if (checkDelete.length > 0)
                                                                for (var item in checkDelete)
                                                                  await httpDelete("/api/tuyendung-chitiet/del/$item", context);
                                                              Navigator.pop(context);
                                                              widget.recruitment!.title = tieuDe.text;
                                                              widget.recruitment!.description = moTa.text;
                                                              widget.callBack!(widget.recruitment);
                                                              showToast(
                                                                context: context,
                                                                msg: "Sửa đề nghị tuyển dụng thành công",
                                                                color: Color.fromARGB(136, 72, 238, 67),
                                                                icon: const Icon(Icons.done),
                                                              );
                                                            }
                                                          } else {
                                                            showToast(
                                                              context: context,
                                                              msg: "Phải nhập đầy đủ thông tin",
                                                              color: colorOrange,
                                                              icon: const Icon(Icons.warning),
                                                            );
                                                          }
                                                        },
                                                        child: Row(
                                                          children: [
                                                            Text('Gửi', style: textButton),
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
                                                    Navigator.pop(context);
                                                    showToast(
                                                      context: context,
                                                      msg: "Đã hủy cập nhập đề nghị tuyển dụng",
                                                      color: Color.fromARGB(135, 247, 217, 179),
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
                                  ]),
                                );
                              } else if (snapshot.hasError) {
                                return Text('${snapshot.error}');
                              }
                              return const Center(child: CircularProgressIndicator());
                            }),
                      ],
                    ),
                    Footer(marginFooter: EdgeInsets.only(top: 5), paddingFooter: EdgeInsets.all(15)),
                    SizedBox(height: 20)
                  ],
                ),
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

class DetailedRecruitment {
  int id;
  Depart depart;
  Duty duty;
  TextEditingController qty;
  TextEditingController salary;
  String? timeNeeded;
  String? jdFile;
  int vision;
  DetailedRecruitment(
      {required this.id,
      required this.depart,
      required this.duty,
      required this.qty,
      required this.salary,
      this.timeNeeded,
      required this.vision,
      this.jdFile});
}
