// ignore_for_file: unused_local_variable
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/api.dart';
import 'package:gentelella_flutter/widgets/forms/nhan_su/setting-data/duty.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../common/style.dart';
import '../../../common/toast.dart';
import '../../../common/widgets_form.dart';
import '../../../model/model.dart';
import '../../forms/nhan_su/setting-data/depart.dart';
import '../../ui/navigation.dart';

class AddNewUpdatedntd extends StatelessWidget {
  const AddNewUpdatedntd({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
      widgetBody: AddNewUpdatedntdBody(),
    );
  }
}

class AddNewUpdatedntdBody extends StatefulWidget {
  const AddNewUpdatedntdBody({Key? key}) : super(key: key);

  @override
  State<AddNewUpdatedntdBody> createState() => _AddNewUpdatedntdBodyState();
}

class _AddNewUpdatedntdBodyState extends State<AddNewUpdatedntdBody> {
  TextEditingController tieuDe = TextEditingController();
  TextEditingController moTa = TextEditingController();
  String dayNow =
      "${int.parse(DateFormat("yyyy-MM-dd").format(DateTime.now().toLocal()).toString().substring(8, 10)) - 1}-${DateFormat("yyyy-MM-dd").format(DateTime.now().toLocal()).toString().substring(5, 7)}-${DateFormat("yyyy-MM-dd").format(DateTime.now().toLocal()).toString().substring(0, 4)}";

  List<DetailedRecruitment> listRecruitmentDetail = [];
  List<Depart>? resultPhongBan;
  Future<List<Depart>> getPhongBan(int userDepartID) async {
    var response1;
    if (userDepartID == 1 || userDepartID == 2 || userDepartID == 10)
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

  postNotifi(String title, String content) {
    var body1 = {
      "title": title,
      "message": content,
    };
    var response1 = httpPost("/api/push/tags/depart_id/2", body1, context);
    var response2 = httpPost("/api/push/tags/depart_id/10", body1, context);
  }

  var resultNextID;
  addTuyenDung(int requestUser) async {
    var requestBody = {"title": tieuDe.text, "description": moTa.text, "approve": 0, "status": 1, "requestUser": requestUser};

    print(requestBody);
    var response1 = await httpPost("/api/tuyendung/post/save", requestBody, context);

    if (response1.containsKey("body")) {
      setState(() {
        resultNextID = jsonDecode(response1["body"]);
        print(resultNextID);
      });
    }
  }

  addTuyenDungChiTiet(var resultNextID, List<DetailedRecruitment> listRecruitmentDetail) async {
    bool request = true;
    var response;
    var body;
    List<dynamic> requestBody = [];
    for (var i = 0; i < listRecruitmentDetail.length; i++) {
      body = {
        "tuyendungId": resultNextID,
        "departId": listRecruitmentDetail[i].depart.id,
        "dutyId": listRecruitmentDetail[i].duty.id,
        "qty": listRecruitmentDetail[i].qty.text,
        "salary": listRecruitmentDetail[i].salary.text,
        "timeNeeded": listRecruitmentDetail[i].timeNeeded,
        "jdFile": listRecruitmentDetail[i].jdFile
      };
      requestBody.add(body);
    }
    response = await httpPost("/api/tuyendung-chitiet/post/saveAll", requestBody, context);
    print(requestBody);
    if (response.containsKey("body")) {
      setState(() {
        response = jsonDecode(response["body"]);
        print(response);
      });
      return request;
    }
  }

  List<String> itemsGrid = [];
  @override
  void initState() {
    var user = Provider.of<SecurityModel>(context, listen: false);
    listRecruitmentDetail.add(DetailedRecruitment(
      id: -1,
      depart: (user.userLoginCurren['departId'] == 1 || user.userLoginCurren['departId'] == 2 || user.userLoginCurren['departId'] == 10)
          ? Depart(id: 0, departName: '')
          : Depart(
              id: user.userLoginCurren['departId'],
              departName: (user.userLoginCurren['phongban'] != null) ? user.userLoginCurren['phongban']['departName'] : ""),
      duty: Duty(id: 0, dutyName: '', departId: 0),
      qty: TextEditingController(text: ""),
      salary: TextEditingController(text: ""),
      timeNeeded: "",
    ));
    super.initState();
  }

  @override
  void dispose() {
    tieuDe.dispose();
    moTa.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: userRule('/them-moi-dntd', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return Consumer2<NavigationModel, SecurityModel>(
            builder: (context, navigationModel, user, child) => Container(
              child: Container(
                child: ListView(
                  controller: ScrollController(),
                  children: [
                    TitlePage(
                      listPreTitle: [
                        {'url': "/nhan-su", 'title': 'Dashboard'},
                        {'url': "/de-nghi-tuyen-dung-chuc-nang", 'title': 'Đề nghị tuyển dụng'},
                      ],
                      content: 'Thêm mới',
                    ),
                    Container(
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
                          Container(
                            width: MediaQuery.of(context).size.width * 1,
                            padding: paddingTitledPage,
                            child: Column(children: [
                              for (int i = 0; i < listRecruitmentDetail.length; i++)
                                Container(
                                  margin: EdgeInsets.only(bottom: 30, left: 20, right: 20),
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 250, 250, 250),
                                    borderRadius: borderRadiusContainer,
                                    boxShadow: [boxShadowContainer],
                                    border: borderAllContainerBox,
                                  ),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 30, top: 30),
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
                                                            selectedItem: listRecruitmentDetail[i].depart,
                                                            onChanged: (value) {
                                                              setState(() {
                                                                listRecruitmentDetail[i].depart = value!;
                                                                listRecruitmentDetail[i].duty = Duty(id: 0, dutyName: "", departId: value.id);
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
                                                            onFind: (String? filter) => getVaiTro(listRecruitmentDetail[i].depart.id),
                                                            itemAsString: (Duty? u) => u!.dutyName,
                                                            dropdownSearchDecoration: styleDropDown,
                                                            selectedItem: listRecruitmentDetail[i].duty,
                                                            onChanged: (value) {
                                                              setState(() {
                                                                listRecruitmentDetail[i].duty = value!;
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
                                        padding: const EdgeInsets.only(left: 30),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                child: TextFieldValidatedForm(
                                                  type: 'Number',
                                                  controller: listRecruitmentDetail[i].qty,
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
                                                          child: MonthPickerLimit(
                                                            pickTime: (listRecruitmentDetail[i].timeNeeded != "")
                                                                ? DateTime(int.parse(listRecruitmentDetail[i].timeNeeded.toString().substring(0, 4)),
                                                                    int.parse(listRecruitmentDetail[i].timeNeeded.toString().substring(5, 7)))
                                                                : null,
                                                            afterLimit: DateTime(DateTime.now().year, DateTime.now().month),
                                                            callBack: (day) {
                                                              if (day != "")
                                                                listRecruitmentDetail[i].timeNeeded = "$day-28";
                                                              else
                                                                listRecruitmentDetail[i].timeNeeded = "";
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
                                        padding: const EdgeInsets.only(left: 30),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                child: TextFieldValidatedForm(
                                                  type: 'Text',
                                                  controller: listRecruitmentDetail[i].salary,
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
                                                                  listRecruitmentDetail[i].jdFile = fileName;
                                                                });
                                                              }
                                                            },
                                                            child: (listRecruitmentDetail[i].jdFile != "" && listRecruitmentDetail[i].jdFile != null)
                                                                ? Text(listRecruitmentDetail[i].jdFile!)
                                                                : Icon(Icons.upload_file),
                                                          ))
                                                    ],
                                                  ),
                                                )),
                                            Expanded(flex: 1, child: Container()),
                                          ],
                                        ),
                                      ),
                                      if (i == listRecruitmentDetail.length - 1)
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
                                                    textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      if (listRecruitmentDetail.length > 1) {
                                                        listRecruitmentDetail.remove(listRecruitmentDetail[i]);
                                                      }
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
                                                    textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      listRecruitmentDetail.add(DetailedRecruitment(
                                                        id: -1,
                                                        depart: (user.userLoginCurren['departId'] == 1 ||
                                                                user.userLoginCurren['departId'] == 2 ||
                                                                user.userLoginCurren['departId'] == 10)
                                                            ? Depart(id: 0, departName: '')
                                                            : Depart(
                                                                id: user.userLoginCurren['departId'],
                                                                departName: (user.userLoginCurren['phongban'] != null)
                                                                    ? user.userLoginCurren['phongban']['departName']
                                                                    : ""),
                                                        duty: Duty(id: 0, dutyName: '', departId: 0),
                                                        qty: TextEditingController(text: ""),
                                                        salary: TextEditingController(text: ""),
                                                        timeNeeded: '',
                                                      ));
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
                                                    textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      if (listRecruitmentDetail.length > 1) {
                                                        listRecruitmentDetail.remove(listRecruitmentDetail[i]);
                                                      }
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

                                      //////
                                    ],
                                  ),
                                ),
                            ]),
                          ),
                          Padding(
                              padding: const EdgeInsets.fromLTRB(50, 10, 50, 30),
                              child: Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                                SizedBox(width: 10),
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
                            padding: const EdgeInsets.fromLTRB(50, 0, 30, 20),
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
                                            backgroundColor: Color.fromRGBO(245, 117, 29, 1),
                                            primary: Theme.of(context).iconTheme.color,
                                            textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                          ),
                                          onPressed: () async {
                                            bool check = true;

                                            if (tieuDe.text != "") {
                                              for (var item in listRecruitmentDetail) {
                                                if (item.depart.id == 0 ||
                                                    item.duty.id == 0 ||
                                                    item.qty.text == "" ||
                                                    item.salary.text == "" ||
                                                    item.timeNeeded == null ||
                                                    item.timeNeeded == "" ||
                                                    int.tryParse(item.qty.text) == null) {
                                                  check = false;
                                                  break;
                                                }
                                              }
                                            } else
                                              check = false;
                                            if (check) {
                                              await addTuyenDung(user.userLoginCurren['id']);
                                              if (int.tryParse(resultNextID.toString()) != null) {
                                                var check = await addTuyenDungChiTiet(resultNextID.toString(), listRecruitmentDetail);
                                                if (check == true) {
                                                  Navigator.pop(context);
                                                  showToast(
                                                    context: context,
                                                    msg: "Thêm mới đề nghị tuyển dụng thành công",
                                                    color: Color.fromARGB(136, 72, 238, 67),
                                                    icon: const Icon(Icons.done),
                                                  );
                                                  postNotifi("Hệ thống thông báo", "Có đề nghị tuyển dụng mới đang chờ được phê duyệt.");
                                                } else {
                                                  await httpDelete("/api/tuyendung/del/$resultNextID", context);
                                                  showToast(
                                                    context: context,
                                                    msg: "Kiểm tra lại dữ liệu",
                                                    color: colorOrange,
                                                    icon: const Icon(Icons.warning),
                                                  );
                                                }
                                              } else {
                                                showToast(
                                                  context: context,
                                                  msg: "Thêm mới đề nghị tuyển dụng không thành công",
                                                  color: colorOrange,
                                                  icon: const Icon(Icons.warning),
                                                );
                                              }
                                            } else {
                                              showToast(
                                                context: context,
                                                msg: "Cần điền đầy đủ thông tin",
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
                                        msg: "Đã hủy tạo mới đề nghị tuyển dụng",
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
    );
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
  DetailedRecruitment(
      {required this.id, required this.depart, required this.duty, required this.qty, required this.salary, this.timeNeeded, this.jdFile});
}
