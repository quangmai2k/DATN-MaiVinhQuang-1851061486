// ignore_for_file: deprecated_member_use, unused_local_variable
import 'dart:convert';
import 'dart:core';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/forms/nhan_su/setting-data/userAAM.dart';
import 'package:gentelella_flutter/widgets/ui/nhan_su/tabbar-them-moi-cham-cong.dart';
import 'package:provider/provider.dart';
import '../../../api.dart';
import '../../../common/style.dart';
import '../../../common/toast.dart';
import '../../../common/widgets_form.dart';
import '../../../config.dart';
import '../../../model/model.dart';
import '../../ui/navigation.dart';
import 'package:http/http.dart' as http;
import "package:collection/collection.dart";

Color borderBlack = Colors.black54;

class AddNewUpdateCC extends StatelessWidget {
  const AddNewUpdateCC({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
      widgetBody: AddNewUpdateCCBody(),
    );
  }
}

class AddNewUpdateCCBody extends StatefulWidget {
  const AddNewUpdateCCBody({Key? key}) : super(key: key);

  @override
  State<AddNewUpdateCCBody> createState() => _AddNewUpdateCCBodyState();
}

class _AddNewUpdateCCBodyState extends State<AddNewUpdateCCBody> {
  late String fileName = "";
  String timeMonth = "";
  int lengthRow = 0;
  List<dynamic> timeKeepingData = [];
  bool status = false;
  getTimeKeeping(String timeMonthtt) async {
    int checkMonth = 0;
    var response2 = await httpGet("/api/chamcong/get/page?filter=timekeepingMonth~'*$timeMonthtt*'", context);
    var body = jsonDecode(response2['body']);
    if (response2.containsKey("body")) {
      checkMonth = jsonDecode(response2["body"])['content'].length;
      setState(() {
        if (checkMonth > 0) {
          showToast(
            context: context,
            msg: "Tháng $timeMonthtt đã có file chấm công",
            color: Color.fromRGBO(245, 117, 29, 1),
            icon: const Icon(Icons.info),
          );
          timeMonth = "";
        }
      });
    }
  }

  exportFileExcel(file, {context}) async {
    var securityModel = Provider.of<SecurityModel>(context, listen: false);
    if (file != null) {
      final request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/api/utils/post/excel2json"),
      );
      request.headers['authorization'] = "aam ${securityModel.authorization!}";
      request.files.add(new http.MultipartFile(
        "file",
        file!.files.first.readStream!,
        file.files.first.size,
        filename: file.files.first.name,
      ));
      //-------Send request
      var resp = await request.send();
      var result = await resp.stream.bytesToString();
      return result;
    } else {
      print("null");
      return "null";
    }
  }

  var listNVCC = {};
  var listNVCCEnd = {};

  int checkSL = 1;
  var file;
  int max = 0;
  chooseFile() async {
    setState(() {
      timeKeepingData = [];
      status = false;
    });
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withReadStream: true,
    );
    if (result != null) {
      file = result;
      int check = 0;
      var body = await exportFileExcel(result, context: context);
      setState(() {
        status = true;
        var result = jsonDecode(body);
        fileName = result.keys.first;
        timeKeepingData = result[fileName];
        timeKeepingData.removeLast();
        listNVCC = groupBy(timeKeepingData, (dynamic obj) {
          return obj['map']['Mã N.Viên'];
        });
      });
      for (var element in listNVCC.keys) {
        if (listNVCC[element].length > 1) {
          if (userAAM.containsKey(element)) {
            listNVCC[element][0]['map']['error'] = 0;
            listNVCC[element][0]['map']['short'] = 0;
            for (var i = 0; i < listNVCC[element].length; i++) {
              if (i > 0) {
                if (listNVCC[element][i]['map']['Ngày'] == listNVCC[element][i - 1]['map']['Ngày']) {
                  listNVCC[element][0]['map']['error'] = listNVCC[element][0]['map']['error'] + 1;
                  if (listNVCC[element][0]['map']['error'] < max) max = listNVCC[element][0]['map']['error'];
                } else {
                  if (listNVCC[element][i]['map']['Thứ'] != "CN") {
                    if (listNVCC[element][i]['map']['Ra'] == "" || listNVCC[element][i]['map']['Vào'] == "")
                      listNVCC[element][0]['map']['short'] = listNVCC[element][0]['map']['short'] + 1;
                  }
                }
                if (listNVCC[element][i]['map']['Vào'] != "" && listNVCC[element][i]['map']['Ra'] != "") {
                  DateTime vao = DateTime.parse("1944-06-06T${listNVCC[element][i]['map']['Vào']}:00.000");
                  DateTime ra = DateTime.parse("1944-06-06T${listNVCC[element][i]['map']['Ra']}:00.000");
                  var difference = ra.difference(vao);
                  listNVCC[element][i]['map']['giờ làm việc'] = difference.inMinutes - 60;
                } else
                  listNVCC[element][i]['map']['giờ làm việc'] = 0;
              } else {
                if (listNVCC[element][i]['map']['Thứ'] != "CN") {
                  if (listNVCC[element][i]['map']['Ra'] == "" || listNVCC[element][i]['map']['Vào'] == "")
                    listNVCC[element][0]['map']['short'] = listNVCC[element][0]['map']['short'] + 1;
                }
                if (listNVCC[element][i]['map']['Vào'] != "" && listNVCC[element][i]['map']['Ra'] != "") {
                  DateTime vao = DateTime.parse("1944-06-06T${listNVCC[element][i]['map']['Vào']}:00.000");
                  DateTime ra = DateTime.parse("1944-06-06T${listNVCC[element][i]['map']['Ra']}:00.000");
                  var difference = ra.difference(vao);
                  if (difference.inMinutes > 240)
                    listNVCC[element][i]['map']['giờ làm việc'] = difference.inMinutes - 60;
                  else
                    listNVCC[element][i]['map']['giờ làm việc'] = difference.inMinutes;
                } else
                  listNVCC[element][i]['map']['giờ làm việc'] = 0;
              }

              if (listNVCC[element][i]['map']['Thứ'] != "CN") {
                if (listNVCC[element][i]['map']['Ra'] != "" && listNVCC[element][i]['map']['Vào'] != "") {
                  listNVCC[element][i]['map']['status'] = true;
                } else
                  listNVCC[element][i]['map']['status'] = false;
              } else {
                listNVCC[element][i]['map']['status'] = true;
              }
            }
            setState(() {
              listNVCCEnd[element] = listNVCC[element];
            });
          }
        }
      }
      showToast(
          context: context,
          msg: "Đã tải file chấm công gốc lên server",
          color: Color.fromARGB(136, 72, 238, 67),
          icon: const Icon(Icons.done),
          timeHint: 5);
    } else {
      return showToast(
        context: context,
        msg: "Chọn lại file",
        color: Color.fromRGBO(245, 117, 29, 1),
        icon: const Icon(Icons.info),
      );
    }
  }

  Map<String, UserAAM> userAAM = {};
  getListUserAAM() async {
    var response2 = await httpGet("/api/nguoidung/get/page?filter=isAam:1", context);
    if (response2.containsKey("body")) {
      var body = jsonDecode(response2['body']);
      var content = body['content'];
      for (var element in content) {
        userAAM['${element['timeKeepingCode']}'] = UserAAM(
          id: element['id'],
          userCode: element['userCode'],
          fullName: element['fullName'],
          departName: (element['phongban'] != null) ? element['phongban']['departName'] : "",
          teamName: (element['doinhom'] != null) ? element['doinhom']['departName'] : "",
          dutyName: (element['vaitro'] != null) ? element['vaitro']['name'] : "",
        );
      }
    }

    return userAAM;
  }

  bool statusData = false;
  void callAPI() async {
    await getListUserAAM();
    setState(() {
      statusData = true;
    });
  }

  @override
  void initState() {
    super.initState();
    callAPI();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> processing() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return Center(child: const CircularProgressIndicator());
        },
      );
    }

    return FutureBuilder<dynamic>(
      future: userRule('/them-moi-cham-cong', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return (statusData)
              ? Consumer<NavigationModel>(
                  builder: (context, navigationModel, child) => SingleChildScrollView(
                        controller: ScrollController(),
                        child: Column(children: [
                          TitlePage(
                            listPreTitle: [
                              {'url': "/nhan-su", 'title': 'Dashboard'},
                              {'url': "/cham-cong", 'title': 'Chấm công'},
                            ],
                            content: 'Thêm mới',
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: borderAllContainerBox,
                              color: colorWhite,
                              borderRadius: borderRadiusContainer,
                              boxShadow: [boxShadowContainer],
                            ),
                            padding: EdgeInsets.only(top: 20, left: 30, right: 30, bottom: 20),
                            margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text('Tháng:', style: titleWidgetBox),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Container(
                                            height: 40,
                                            padding: EdgeInsets.only(left: 10),
                                            decoration: BoxDecoration(border: Border.all(width: 0.5, color: Colors.black)),
                                            child: MonthPickerLimit(
                                                pickTime: (timeMonth != "")
                                                    ? DateTime(
                                                        int.parse(timeMonth.substring(0, 4)),
                                                        int.parse(
                                                          timeMonth.substring(5),
                                                        ))
                                                    : null,
                                                callBack: (value) {
                                                  processing();
                                                  setState(() {
                                                    if (value != "") {
                                                      timeMonth = value;
                                                      getTimeKeeping(timeMonth);
                                                    } else
                                                      timeMonth = "";
                                                  });
                                                  Navigator.pop(context);
                                                })),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(''),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    // margin: EdgeInsets.only(bottom: 10),
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
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
                                      onPressed: () {
                                        processing();
                                        chooseFile();
                                        Navigator.pop(context);
                                      },
                                      // : null,
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text('Tải file', style: textButton),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 25,
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Container(
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
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
                                        onPressed: () {
                                          Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/cham-cong");
                                          showToast(
                                            context: context,
                                            msg: "Đã hủy tạo mới file chấm công",
                                            color: colorOrange,
                                            icon: Icon(Icons.close),
                                          );
                                        },
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('Hủy', style: textButton),
                                          ],
                                        ),
                                      ),
                                    )),
                                Expanded(
                                  flex: 1,
                                  child: Text(''),
                                ),
                              ],
                            ),
                          ),
                          (timeKeepingData.length > 0)
                              ? (listNVCCEnd.keys.length > 0)
                                  ? TabBarThemMoiChamCong(
                                      listNVCC: listNVCCEnd,
                                      userAAM: userAAM,
                                      fileName: fileName,
                                      timeMonth: timeMonth,
                                      max: max,
                                    )
                                  : Column(
                                      children: [
                                        Icon(Icons.no_accounts),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text("Không có người dùng nào trong hệ thống"),
                                      ],
                                    )
                              : Container(
                                  margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                                  width: MediaQuery.of(context).size.width * 1,
                                  decoration: BoxDecoration(
                                    border: borderAllContainerBox,
                                    color: colorWhite,
                                    borderRadius: borderRadiusContainer,
                                    boxShadow: [boxShadowContainer],
                                  ),
                                  padding: paddingBoxContainer,
                                  child: Center(child: Text("Chưa có file nào được tải lên"))),
                          Footer(marginFooter: EdgeInsets.only(top: 5), paddingFooter: EdgeInsets.all(15)),
                          SizedBox(height: 20)
                        ]),
                      ))
              : Center(child: CircularProgressIndicator());
        } else if (listRule.hasError) {
          return Text('${listRule.error}');
        }

        // By default, show a loading spinner.
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
