import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/api.dart';
import 'package:gentelella_flutter/common/style.dart';
import 'package:gentelella_flutter/common/widgets_form.dart';
import "package:collection/collection.dart";
import 'package:gentelella_flutter/widgets/forms/market_development/utils/funciton.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../common/format_date.dart';
import '../../../../common/toast.dart';
import '../../../../model/model.dart';
import '../../nhan_su/view-hsns.dart';
import '../thuong_don_hang/CareUser.dart';

TextEditingController maleRoundMax = TextEditingController();
TextEditingController femaleRoundMax = TextEditingController();
TextEditingController maleRoundMaxFix = TextEditingController();
TextEditingController femaleRoundMaxFix = TextEditingController();

double unityWidth = 150;
double unityHeight = 40;
int maleRoundMax1 = 0;
int femaleRoundMax1 = 0;
var resultListTrainee = {};
var listOrderId = [];
var listTraineeId = [];
dynamic listTargerBonus = {};
var listTraineeTookTheExam = [];
int rowPerPage = 10;
bool check = false;

void _showMaterialDialog(BuildContext context, int index) {
  showDialog(
      context: context,
      builder: (context) {
        return Consumer<NavigationModel>(
            builder: (context, navigationModel, child) => AlertDialog(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            child: Image.asset('assets/images/logoAAM.png'),
                            margin: EdgeInsets.only(right: 10),
                          ),
                          Text(
                            'Danh sách thực tập sinh',
                            style: TextStyle(
                                fontSize: 20,
                                color: Color(0xff333333),
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close),
                      ),
                    ],
                  ),
                  //Bảng chot ds
                  content: Container(
                    width: 1000,
                    height: 400,
                    child: ListView(
                      children: [
                        DataTable(
                          showCheckboxColumn: false,
                          columns: [
                            DataColumn(
                                label: Text('STT', style: titleTableData)),
                            DataColumn(
                                label: Text('Tên TTS', style: titleTableData)),
                            DataColumn(
                                label:
                                    Text('Ngày sinh', style: titleTableData)),
                            DataColumn(
                                label: Text('Ngày thi', style: titleTableData)),
                            DataColumn(
                                label: Text('Đơn hàng', style: titleTableData)),
                            DataColumn(
                                label: Text('Tiền chỉ tiêu',
                                    style: titleTableData)),
                          ],
                          rows: <DataRow>[
                            for (var i = 0;
                                i < resultListTrainee["content"].length;
                                i++)
                              for (var j = 0; j < listOrderId.length; j++)
                                if (listOrderId[j] ==
                                    resultListTrainee["content"][i]["orderId"])
                                  if (listTraineeId[j] ==
                                      resultListTrainee["content"][i]["ttsId"])
                                    DataRow(
                                      cells: <DataCell>[
                                        DataCell(Text("${i + 1}")),
                                        DataCell(
                                          TextButton(
                                            child: Text(
                                                (resultListTrainee["content"][i]
                                                            ["thuctapsinh"] !=
                                                        null)
                                                    ? resultListTrainee[
                                                                    "content"][i]
                                                                ["thuctapsinh"]
                                                            ["fullName"] +
                                                        " (${resultListTrainee["content"][i]["thuctapsinh"]["userCode"]})"
                                                    : "nodata",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w400)),
                                            onPressed: () {
                                              navigationModel.add(
                                                pageUrl:
                                                    ("/view-thong-tin-thuc-tap-sinh" +
                                                        "/${resultListTrainee["content"][i]["ttsId"]}"),
                                              );
                                            },
                                          ),
                                        ),
                                        DataCell(Text(
                                            resultListTrainee["content"][i]
                                                            ["thuctapsinh"]
                                                        ["birthDate"] !=
                                                    null
                                                ? DateFormat("dd-MM-yyyy")
                                                    .format(DateTime.parse(
                                                        resultListTrainee[
                                                                    "content"][i]
                                                                ["thuctapsinh"]
                                                            ["birthDate"]))
                                                : "",
                                            style: bangDuLieu)),
                                        DataCell(
                                          Text(
                                              FormatDate.formatDateView(
                                                  DateTime.parse(
                                                      (resultListTrainee[
                                                                  "content"][i]
                                                              ["examDate"]
                                                          .toString()))),
                                              style: bangDuLieu),
                                        ),
                                        DataCell(
                                          TextButton(
                                            child: Text(
                                                resultListTrainee["content"][i]
                                                                ["donhang"]
                                                            ["orderName"] +
                                                        " (${resultListTrainee["content"][i]["donhang"]["orderCode"]})" ??
                                                    "nodata",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w400)),
                                            onPressed: () {
                                              navigationModel.add(
                                                  pageUrl:
                                                      "/xem-chi-tiet-don-hang/${resultListTrainee["content"][i]["orderId"]}");
                                            },
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                              NumberFormat.simpleCurrency(
                                                      locale: "vi")
                                                  .format(listTargerBonus[
                                                      resultListTrainee[
                                                              "content"][i]
                                                          ["orderId"]])
                                                  .toString(),
                                              style: bangDuLieu),
                                        ),
                                      ],
                                    )
                          ],
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[],
                ));
      });
}

class ThuongChiTieu extends StatefulWidget {
  ThuongChiTieu({Key? key}) : super(key: key);

  @override
  State<ThuongChiTieu> createState() => _ThuongChiTieuState();
}

class _ThuongChiTieuState extends State<ThuongChiTieu> {
  late Future futureTargetBonus;
  Map<String, CareUser> listCareUserDuplicate = {};
  List<CareUser>? listCareUser = [];
  var resultCauHinhTinhThuong = {};
  var idTargetBonus;
  var idTargetBonusApproved;
  Future getCauHinhTinhThuong() async {
    var response =
        await httpGet("/api/thuong-chitieu-cauhinh/get/page", context);

    if (response.containsKey("body")) {
      setState(() {
        resultCauHinhTinhThuong = jsonDecode(response["body"]);
      });
    }
    for (var item in resultCauHinhTinhThuong["content"])
      if (item["approve"] == 1) idTargetBonusApproved = item["id"];
  }

  //Áp dụng cấu hình chỉ tiêu
  updateApproveTargetBonus() async {
    try {
      var data = {"approve": 1};
      await httpPut(Uri.parse('/api/thuong-chitieu-cauhinh/put/$idTargetBonus'),
          data, context);
      print("thaida detail success");
    } catch (_) {
      print("Fail!");
    }
  }

  updateApprovedTargetBonus1() async {
    try {
      var data = {"approve": 0};
      await httpPut(
          Uri.parse('/api/thuong-chitieu-cauhinh/put/$idTargetBonusApproved'),
          data,
          context);
      print("thaida detail success");
    } catch (_) {
      print("Fail!");
    }
  }

  //Add số lần thi tuyển tối đa
  addMaleRoundMax() async {
    try {
      var data = {
        "maleRoundMax": maleRoundMax.text,
        "femaleRoundMax": femaleRoundMax.text,
        "approve": 0
      };
      await httpPost(
          Uri.parse('/api/thuong-chitieu-cauhinh/post/save'), data, context);
      print("thaida detail success");
    } catch (_) {
      print("Fail!");
    }
  }

  updateMaleRoundMax() async {
    try {
      var data = {
        "maleRoundMax": maleRoundMaxFix.text,
        "femaleRoundMax": femaleRoundMaxFix.text,
        "approve": 0
      };
      await httpPut(Uri.parse('/api/thuong-chitieu-cauhinh/put/$idTargetBonus'),
          data, context);
      print("thaida detail success");
    } catch (_) {
      print("Fail!");
    }
  }

  delTargetBonus() async {
    await httpDelete(
        Uri.parse('/api/thuong-chitieu-cauhinh/del/$idTargetBonus'), context);
  }

  var response;
  var resultTargetBonus = {};
  Future getTargetBonus(currentPage) async {
    await callAPI();
    var response = await httpGet(
        "/api/thuong-chitieu-cauhinh/get/page?size=$rowPerPage&page=${currentPage - 1}",
        context);
    if (response.containsKey("body")) {
      setState(() {
        resultTargetBonus = jsonDecode(response["body"]) ?? {};
      });
    }
    return 0;
  }

  int careUser = 0;
  Future getListTrainee() async {
    int lastday = DateTime(2022, int.parse(month) + 1, 0).day;
    String query =
        "and examDate>:'01-$month-$year' and examDate<:'$lastday-$month-$year'";
    var resultListTrainee1;
    var listTraineeGroupByOrder = {};
    var listTraineeGroupById = {};
    var response = await httpGet(
        "/api/tts-lichsu-thituyen/get/page?sort=ttsId&filter=thuctapsinh.careUser:$careUser and rewardOfferId is null and examResult in (1,2,3) $query and (thuctapsinh.stopProcessing is null or thuctapsinh.stopProcessing:0)",
        context);

    if (response.containsKey("body")) {
      setState(() {
        resultListTrainee = jsonDecode(response["body"]);
        resultListTrainee1 = jsonDecode(response["body"])["content"];
      });
    }

    //Add orderId
    listTraineeGroupByOrder = groupBy(resultListTrainee1, (dynamic obj) {
      return obj['orderId'];
    });
    listTraineeGroupById = groupBy(resultListTrainee1, (dynamic obj) {
      return obj['ttsId'];
    });
    listOrderId.clear();
    listTraineeId.clear();
    for (var element in resultListTrainee1) {
      if (element["thuctapsinh"]["gender"] == 0) {
        if (element["examTimes"] <= maleRoundMax1) {
          listTraineeGroupByOrder.forEach((key, value) {
            if (key == element["orderId"]) listOrderId.add(key);
          });
          listTraineeGroupById.forEach((key, value) {
            if (key == element["ttsId"]) listTraineeId.add(key);
          });
        }
      } else {
        if (element["examTimes"] <= femaleRoundMax1) {
          listTraineeGroupByOrder.forEach((key, value) {
            if (key == element["orderId"]) listOrderId.add(key);
          });
          listTraineeGroupById.forEach((key, value) {
            if (key == element["ttsId"]) listTraineeId.add(key);
          });
        }
      }
    }
  }

//Get targetBonus by orderId
  var resultListTargetBonus = {};
  Future getBonus() async {
    String request = '';
    for (int i = 0; i < listOrderId.length; i++) {
      if (listOrderId[i] != null) {
        request += listOrderId[i].toString();
        if (i < listOrderId.length - 1) {
          request += ',';
        }
      }
    }
    if (listOrderId.isEmpty) request = "0";
    var response = await httpGet(
        "/api/thuong-chitieu-donhang/get/page?filter=orderId in ($request) and approve:1",
        context);
    if (response.containsKey("body")) {
      setState(() {
        resultListTargetBonus = jsonDecode(response["body"]);
      });
    }
    listTargerBonus.clear();
    for (int i = 0; i < resultListTargetBonus["content"].length; i++) {
      if (resultListTargetBonus["content"][i]["orderId"] != null)
        listTargerBonus[resultListTargetBonus["content"][i]["orderId"]] =
            resultListTargetBonus["content"][i]["targetBonus"];
    }
  }

  var listBonus = {};
  Future getTotalBonus() async {
    var resultListTargetBonus1;
    var response = await httpGet(
        "/api/thuong-chitieu-donhang/get/page?filter= approve:1", context);
    if (response.containsKey("body")) {
      setState(() {
        resultListTargetBonus1 = jsonDecode(response["body"]);
      });
    }
    for (int i = 0; i < resultListTargetBonus1["content"].length; i++) {
      if (resultListTargetBonus1["content"][i]["orderId"] != null)
        listBonus[resultListTargetBonus1["content"][i]["orderId"]] =
            resultListTargetBonus1["content"][i]["targetBonus"];
    }
  }

  @override
  void initState() {
    super.initState();
    futureTargetBonus = getTargetBonus(1);
  }

  callAPI() async {
    await getCauHinhTinhThuong();
    await getExamTimeMax();
    await getTraineeTookTheExam();
    await getListGroupByCareUser();
    await getListAam();
    await getPaidExamTimes();
    await getExamTimes();
    await getTotalBonus();
    await getIdExamHistory();
  }

  var listCareUserFilter = {};
  var listAamId = [];

  getTraineeTookTheExam() async {
    int lastday = DateTime(2022, int.parse(month) + 1, 0).day;
    String query =
        "and examDate>:'01-$month-$year' and examDate<:'$lastday-$month-$year'";
    var resultListTraineeTookTheExam = {};
    var response = await httpGet(
        "/api/tts-lichsu-thituyen/get/page?filter=rewardOfferId is null and examResult in (1,2,3) $query and (thuctapsinh.stopProcessing is null or thuctapsinh.stopProcessing:0)",
        context);
    if (response.containsKey("body")) {
      setState(() {
        resultListTraineeTookTheExam = jsonDecode(response["body"]);
      });
    }
    listTraineeTookTheExam.clear();
    for (var element in resultListTraineeTookTheExam["content"]) {
      if (listTraineeTookTheExam.contains(element["ttsId"]) == false)
        listTraineeTookTheExam.add(element["ttsId"]);
    }
    print(listTraineeTookTheExam.toString() + "líttts");
    // setState(() {});
  }

  var resultListIdExamHistory = {};
  var listId = [];
  getIdExamHistory() async {
    int lastday = DateTime(2022, int.parse(month) + 1, 0).day;
    String query =
        "and examDate>:'01-$month-$year' and examDate<:'$lastday-$month-$year'";
    String request = '';
    for (int i = 0; i < listTraineeTookTheExam.length; i++) {
      if (listTraineeTookTheExam[i] != null) {
        request += listTraineeTookTheExam[i].toString();
        if (i < listTraineeTookTheExam.length - 1) {
          request += ',';
        }
      }
    }
    if (listTraineeTookTheExam.isEmpty) request = "0";
    var response = await httpGet(
        "/api/tts-lichsu-thituyen/get/page?filter=ttsId in ($request) and rewardOfferId is null and examResult in (1,2,3) $query and (thuctapsinh.stopProcessing is null or thuctapsinh.stopProcessing:0)",
        context);
    if (response.containsKey("body")) {
      setState(() {
        resultListIdExamHistory = jsonDecode(response["body"]);
      });
    }
    for (var element in resultListIdExamHistory["content"]) {
      if (element["rewardOfferId"] == null) listId.add(element);
    }
  }

  var listCountTraineeGroupByCareUser = {};
  getListGroupByCareUser() async {
    var listGroupByCareUser = {};
    var listUser;
    String request = '';
    for (int i = 0; i < listTraineeTookTheExam.length; i++) {
      if (listTraineeTookTheExam[i] != null) {
        request += listTraineeTookTheExam[i].toString();
        if (i < listTraineeTookTheExam.length - 1) {
          request += ',';
        }
      }
    }
    if (listTraineeTookTheExam.isEmpty) request = "0";
    var response = await httpGet(
        "/api/nguoidung/get/page?filter=isTts:1 and id in($request)&sort=careUser",
        context);
    if (response.containsKey("body")) {
      setState(() {
        listUser = jsonDecode(response["body"])['content'];
        listGroupByCareUser = groupBy(listUser, (dynamic obj) {
          return obj['careUser'];
        });
      });
      listAamId.clear();
      listGroupByCareUser.forEach((key, value) {
        if (key != null) {
          listAamId.add(key);
        }
        listCountTraineeGroupByCareUser[key] = {'sumOfTts': value.length};
      });
      print(listAamId.toString() + "listAAM");
      return listGroupByCareUser;
    } else
      throw Exception('Fail to load data');
  }

  var listAam = {};
  getListAam() async {
    print(1);
    String request = '';
    for (int i = 0; i < listAamId.length; i++) {
      if (listAamId[i] != null) {
        request += listAamId[i].toString();
        if (i < listAamId.length - 1) {
          request += ',';
        }
      }
    }
    if (request == '') request = '0';
    var response = await httpGet(
        "/api/nguoidung/get/page?sort=id&filter=id in ($request) ", context);
    if (response.containsKey("body")) {
      setState(() {
        listAam = jsonDecode(response["body"]);
      });
    }
    return 0;
  }

  getExamTimeMax() async {
    var listExamTimeMax = {};
    var response = await httpGet(
        "/api/thuong-chitieu-cauhinh/get/page?filter=approve:1", context);
    if (response.containsKey("body")) {
      setState(() {
        listExamTimeMax = jsonDecode(response["body"]);
        (listExamTimeMax["content"].isNotEmpty)
            ? maleRoundMax1 = listExamTimeMax["content"][0]["maleRoundMax"]
            : maleRoundMax1 = 1;
        (listExamTimeMax["content"].isNotEmpty)
            ? femaleRoundMax1 = listExamTimeMax["content"][0]["femaleRoundMax"]
            : femaleRoundMax1 = 1;
      });
    }
  }

  var listPaidExamTimes = [];
  dynamic max1 = {};
  var listIdTTS1 = [];
  getPaidExamTimes() async {
    // Lấy tts đã được tính tiền
    // String request = '';
    // for (int i = 0; i < listAamId.length; i++) {
    //   if (listAamId[i] != null) {
    //     request += listAamId[i].toString();
    //     if (i < listAamId.length - 1) {
    //       request += ',';
    //     }
    //   }
    // }
    int lastday = DateTime(2022, int.parse(month) + 1, 0).day;
    String query =
        "and examDate>:'01-$month-$year' and examDate<:'$lastday-$month-$year'";
    // if (request == '') request = '0';
    var response = await httpGet(
        "/api/tts-lichsu-thituyen/get/page?sort=examTimes,desc&filter=rewardOfferId is not null $query",
        context);
    // print(response);
    if (response.containsKey("body")) {
      setState(() {
        listPaidExamTimes = jsonDecode(response["body"])['content'];
        var check;
        for (var row in listPaidExamTimes) {
          check = true;
          for (var data in listIdTTS1)
            if (row['ttsId'] == data['ttsId']) check = false;
          if (check == true) {
            listIdTTS1.add(row);
          }
        }
        max1 = {};
        for (var i = 0; i < listIdTTS1.length; i++) {
          max1[listIdTTS1[i]['ttsId']] = listIdTTS1[i]["examTimes"];
        }
        print("thangggggg1");
        print(max1);
      });
    }
  }

  DateTime now = DateTime.now();
  dynamic month =
      int.parse(DateFormat('MM').format(DateTime.now().toLocal())).toString();
  dynamic year =
      int.parse(DateFormat('yyyy').format(DateTime.now().toLocal())).toString();
  var listMonthItems = [
    {'name': 'Tháng 1', 'value': '1'},
    {'name': 'Tháng 2', 'value': '2'},
    {'name': 'Tháng 3', 'value': '3'},
    {'name': 'Tháng 4', 'value': '4'},
    {'name': 'Tháng 5', 'value': '5'},
    {'name': 'Tháng 6', 'value': '6'},
    {'name': 'Tháng 7', 'value': '7'},
    {'name': 'Tháng 8', 'value': '8'},
    {'name': 'Tháng 9', 'value': '9'},
    {'name': 'Tháng 10', 'value': '10'},
    {'name': 'Tháng 11', 'value': '11'},
    {'name': 'Tháng 12', 'value': '12'},
  ];
  var listIdTTS = [];
  dynamic total = {};
  dynamic max = {};
  var listExamTimesGroupByCareUser = {};
  getExamTimes() async {
    // Tính tổng số lần thi tuyển(trừ tts đã đc tính)
    var listIdExamHistory = [];
    String request = '';
    var listExamTimes;
    for (int i = 0; i < listAamId.length; i++) {
      if (listAamId[i] != null) {
        request += listAamId[i].toString();
        if (i < listAamId.length - 1) {
          request += ',';
        }
      }
    }
    int lastday = DateTime(2022, int.parse(month) + 1, 0).day;
    String query =
        "and examDate>:'01-$month-$year' and examDate<:'$lastday-$month-$year'";
    if (request == '') request = '0';
    var response = await httpGet(
        "/api/tts-lichsu-thituyen/get/page?sort=examTimes,desc&filter=thuctapsinh.careUser in ($request) and rewardOfferId is null and examResult in (1,2,3) $query and (thuctapsinh.stopProcessing is null or thuctapsinh.stopProcessing:0)",
        context);
    if (response.containsKey("body")) {
      setState(() {
        listExamTimes = jsonDecode(response["body"])['content'];
        listExamTimesGroupByCareUser = groupBy(
            listExamTimes, (dynamic obj) => obj['thuctapsinh']['careUser']);
        var check;
        for (var row in listExamTimes) {
          check = true;
          for (var data in listIdTTS)
            if (row['ttsId'] == data['ttsId']) check = false;
          if (check == true) {
            listIdTTS.add(row);
          }
          listIdExamHistory.add(row["id"]); //List id update rewardOfferId
        }
        if (listIdTTS1.isNotEmpty)
          for (var i = 0; i < listIdTTS.length; i++) {
            for (var j = 0; j < listIdTTS1.length; j++) {
              if (listIdTTS[i]["ttsId"] == listIdTTS1[j]["ttsId"]) {
                max[listIdTTS[i]['ttsId']] =
                    listIdTTS[i]["examTimes"] - max1[listIdTTS1[j]['ttsId']];
                break;
              } else {
                max[listIdTTS[i]['ttsId']] = listIdTTS[i]["examTimes"];
              }
            }
          }
        else
          for (var i = 0; i < listIdTTS.length; i++) {
            max[listIdTTS[i]['ttsId']] = listIdTTS[i]["examTimes"];
          }
        print("thaaaaannnggggg");
        print(max);
      });
      total.clear();
      for (int i = 0; i < listIdTTS.length; i++) {
        for (int j = 0; j < listAamId.length; j++) {
          if (listIdTTS[i]["thuctapsinh"]["careUser"] == listAamId[j]) {
            if (listIdTTS[i]["thuctapsinh"]["gender"] == 0) {
              if (max[listIdTTS[i]["ttsId"]] > maleRoundMax1) {
                max[listIdTTS[i]["ttsId"]] = maleRoundMax1;
              }
              if (total[listIdTTS[i]["thuctapsinh"]["careUser"]] == null) {
                total[listIdTTS[i]["thuctapsinh"]["careUser"]] = 0;
              }
              total[listIdTTS[i]["thuctapsinh"]["careUser"]] +=
                  max[listIdTTS[i]["ttsId"]];
              break;
            } else {
              if (max[listIdTTS[i]["ttsId"]] > femaleRoundMax1) {
                max[listIdTTS[i]["ttsId"]] = femaleRoundMax1;
              }
              if (total[listIdTTS[i]["thuctapsinh"]["careUser"]] == null) {
                total[listIdTTS[i]["thuctapsinh"]["careUser"]] = 0;
              }
              total[listIdTTS[i]["thuctapsinh"]["careUser"]] +=
                  max[listIdTTS[i]["ttsId"]];
              break;
            }
          }
        }
      }
      print("thangngggggggtotal");
      print(total);
    }
  }

  int getTotalMoney(int idNv) {
    int count = 0;
    for (var row in listExamTimesGroupByCareUser[idNv]) {
      int bonus = listBonus[row['orderId']] != null
          ? int.parse(listBonus[row['orderId']].toString())
          : 0;

      if (row['orderId'] != null) if (row["thuctapsinh"]["gender"] == 0) {
        if (row['examTimes'] <= maleRoundMax1) count = count + bonus;
      } else {
        if (row['examTimes'] <= femaleRoundMax1) count = count + bonus;
      }
    }

    return count;
  }

  TextEditingController title = TextEditingController(
      text: "Danh sách chỉ tiêu tuyển dụng tháng ${DateTime.now().month}");
  int totalAmount = 0;
  int examTotal = 0;
  int rewardOfferId = 0;
  addTargetBonus() async {
    try {
      for (int i = 0; i < listAamId.length; i++) {
        totalAmount += getTotalMoney(listAam["content"][i]['id']);
        examTotal += int.parse(total[listAamId[i]].toString());
      }

      var data = {
        "title": title.text,
        "paidStatus": 0,
        "bonusType": 1,
        "totalAmount": totalAmount,
        "chitieuCauhinhId": idTargetBonusApproved,
      };
      var response = await httpPost(
          Uri.parse('/api/thuong-chitieu-denghi/post/save'), data, context);
      setState(() {
        rewardOfferId = int.parse(jsonDecode(response["body"]).toString());
      });
      print("thaida detail success");
    } catch (e) {
      print("Fail!$e");
    }
  }

  bool checkData() {
    if (listAamId.isEmpty)
      return false;
    else
      return true;
  }

  var status;
  addDetailTargetBonus() async {
    try {
      List<dynamic> listData = [];
      var data;
      for (int i = 0; i < listAamId.length; i++) {
        data = {
          "rewardOfferId": rewardOfferId,
          "userId": listAamId[i],
          "ttsTotal": listCountTraineeGroupByCareUser[listAamId[i]]['sumOfTts'],
          "amountTotal": getTotalMoney(listAam["content"][i]['id']),
          "examTotal": total[listAamId[i]],
        };
        listData.add(data);
      }
      var response = await httpPost(
          Uri.parse('/api/thuong-chitieu-chitiet/post/saveAll'),
          listData,
          context);
      setState(() {
        status = jsonDecode(response["body"]);
      });
      print("thaida detail success");
    } catch (e) {
      print("Fail!$e");
    }
  }

  updateRewardOfferId() async {
    try {
      List<dynamic> listData = [];
      for (int i = 0; i < listId.length; i++) {
        var data = {
          "ttsId": listId[i]["ttsId"],
          "orderId": listId[i]["orderId"],
          "examDate": listId[i]["examDate"],
          "examTimes": listId[i]["examTimes"],
          "rewardOfferId": rewardOfferId
        };
        listData.add(data);
      }
      await httpPut(
          Uri.parse('/api/tts-lichsu-thituyen/put/all'), listData, context);
    } catch (e) {
      print("Fail!$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: userRule('/thuong-chi-tieu', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return FutureBuilder(
              future: futureTargetBonus,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Consumer2<NavigationModel, SecurityModel>(
                      builder: (context, navigationModel, user, child) =>
                          ListView(children: [
                            Container(
                              color: backgroundPage,
                              padding: EdgeInsets.symmetric(
                                  vertical: verticalPaddingPage,
                                  horizontal: horizontalPaddingPage),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 1,
                                decoration: BoxDecoration(
                                  color: colorWhite,
                                  borderRadius: borderRadiusContainer,
                                  boxShadow: [boxShadowContainer],
                                  border: borderAllContainerBox,
                                ),
                                padding: paddingBoxContainer,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        child: Expanded(
                                          child: DropdownBtnSearch(
                                            isAll: false,
                                            label: 'Thời gian',
                                            listItems: listMonthItems,
                                            search: TextEditingController(),
                                            isSearch: false,
                                            flexLabel: 3,
                                            flexDropdown: 10,
                                            selectedValue: month,
                                            setSelected: (selected) {
                                              month = selected;
                                              futureTargetBonus =
                                                  getTargetBonus(1);
                                              // setState(() {});
                                            },
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin:
                                            EdgeInsets.fromLTRB(30, 0, 30, 0),
                                        child: Row(
                                          children: [
                                            getRule(listRule.data, Role.Sua,
                                                        context) ==
                                                    true
                                                ? ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      primary: Color.fromRGBO(
                                                          245, 117, 29, 1),
                                                      onPrimary: Colors.white,
                                                      // shadowColor: Colors.greenAccent,
                                                      elevation: 3,
                                                      // shape: RoundedRectangleBorder(
                                                      //     borderRadius: BorderRadius.circular(32.0)),
                                                      minimumSize: Size(140,
                                                          50), //////// HERE
                                                    ),
                                                    // textColor: Color(0xFF6200EE),
                                                    // highlightColor: Colors.transparent,
                                                    onPressed: () {
                                                      showDialog<void>(
                                                          context: context,
                                                          builder:
                                                              (context) =>
                                                                  Container(
                                                                    height: 500,
                                                                    child:
                                                                        SingleChildScrollView(
                                                                      child:
                                                                          AlertDialog(
                                                                        title:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            SizedBox(
                                                                              child: Row(
                                                                                children: [
                                                                                  Container(
                                                                                    width: 50,
                                                                                    height: 50,
                                                                                    child: Image.asset('assets/images/logoAAM.png'),
                                                                                    margin: EdgeInsets.only(right: 10),
                                                                                  ),
                                                                                  Text(
                                                                                    'Cấu hình chỉ tiêu tính thưởng',
                                                                                    style: TextStyle(fontSize: 20, color: Color(0xff333333), fontWeight: FontWeight.w700),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            IconButton(
                                                                              onPressed: () => Navigator.pop(context),
                                                                              icon: Icon(Icons.close),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        content:
                                                                            Container(
                                                                          // width: 800,
                                                                          height:
                                                                              500,
                                                                          // color: Colors.black,
                                                                          padding:
                                                                              EdgeInsets.only(top: 25),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            border:
                                                                                Border(
                                                                              bottom: BorderSide(
                                                                                width: 1,
                                                                                color: Color(0xffD7D7D7),
                                                                              ),
                                                                              top: BorderSide(
                                                                                width: 1,
                                                                                color: Color(0xffD7D7D7),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              SingleChildScrollView(
                                                                            child:
                                                                                Column(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Container(
                                                                                  child: Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                    children: [
                                                                                      Row(
                                                                                        children: [
                                                                                          Expanded(
                                                                                            flex: 4,
                                                                                            child: Container(),
                                                                                          ),
                                                                                          Expanded(
                                                                                              flex: 1,
                                                                                              child: ElevatedButton(
                                                                                                style: ElevatedButton.styleFrom(
                                                                                                  primary: Color.fromRGBO(245, 117, 29, 1),
                                                                                                  onPrimary: Colors.white,
                                                                                                  // shadowColor: Colors.greenAccent,
                                                                                                  elevation: 3,
                                                                                                  // shape: RoundedRectangleBorder(
                                                                                                  //     borderRadius: BorderRadius.circular(32.0)),
                                                                                                  minimumSize: Size(140, 50), //////// HERE
                                                                                                ),
                                                                                                child: Text("Thêm mới"),
                                                                                                onPressed: () {
                                                                                                  final AlertDialog dialog1 = AlertDialog(
                                                                                                    title: Row(
                                                                                                      children: [
                                                                                                        Container(
                                                                                                          width: MediaQuery.of(context).size.width * 0.35,
                                                                                                          child: Row(
                                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                            children: [
                                                                                                              SizedBox(
                                                                                                                child: Row(
                                                                                                                  children: [
                                                                                                                    Container(
                                                                                                                      height: 50,
                                                                                                                      width: 50,
                                                                                                                      child: Image.asset('assets/images/logoAAM.png'),
                                                                                                                      margin: EdgeInsets.only(right: 10),
                                                                                                                    ),
                                                                                                                    Text(
                                                                                                                      'Thêm mới',
                                                                                                                      style: TextStyle(fontSize: 20, color: Color(0xff333333), fontWeight: FontWeight.w700),
                                                                                                                    ),
                                                                                                                  ],
                                                                                                                ),
                                                                                                              ),
                                                                                                              IconButton(
                                                                                                                onPressed: () => Navigator.pop(context),
                                                                                                                icon: Icon(Icons.close),
                                                                                                              ),
                                                                                                            ],
                                                                                                          ),
                                                                                                        ),
                                                                                                      ],
                                                                                                    ),
                                                                                                    content: Container(
                                                                                                      height: 200,
                                                                                                      // color: Colors.black,
                                                                                                      padding: EdgeInsets.only(top: 25),
                                                                                                      decoration: BoxDecoration(
                                                                                                        border: Border(
                                                                                                          bottom: BorderSide(
                                                                                                            width: 1,
                                                                                                            color: Color(0xffD7D7D7),
                                                                                                          ),
                                                                                                          top: BorderSide(
                                                                                                            width: 1,
                                                                                                            color: Color(0xffD7D7D7),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                      child: Column(
                                                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                        children: [
                                                                                                          Row(
                                                                                                            children: [
                                                                                                              TextFieldValidated(
                                                                                                                type: 'Number',
                                                                                                                height: 40,
                                                                                                                controller: maleRoundMax,
                                                                                                                label: 'Số lần thi tuyển cho nam: ',
                                                                                                                flexLable: 2,
                                                                                                                flexTextField: 3,
                                                                                                              ),
                                                                                                            ],
                                                                                                          ),
                                                                                                          Container(
                                                                                                            margin: EdgeInsets.only(top: 10),
                                                                                                            child: Row(
                                                                                                              children: [
                                                                                                                TextFieldValidated(
                                                                                                                  type: 'Number',
                                                                                                                  height: 40,
                                                                                                                  controller: femaleRoundMax,
                                                                                                                  label: 'Số lần thi tuyển cho nữ:',
                                                                                                                  flexLable: 2,
                                                                                                                  flexTextField: 3,
                                                                                                                ),
                                                                                                              ],
                                                                                                            ),
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ),
                                                                                                    actions: [
                                                                                                      ElevatedButton(
                                                                                                        // textColor: Color(0xFF6200EE),
                                                                                                        onPressed: () async {
                                                                                                          if (isNumber(maleRoundMax.text) && isNumber(femaleRoundMax.text)) {
                                                                                                            await addMaleRoundMax();
                                                                                                            await getCauHinhTinhThuong();

                                                                                                            showToast(context: context, msg: "Thêm thành công!", color: Colors.green, icon: Icon(Icons.supervised_user_circle));
                                                                                                            Navigator.pop(context);
                                                                                                            Navigator.pop(context);
                                                                                                          } else {
                                                                                                            showToast(context: context, msg: "Vui lòng nhập đúng thông tin", color: Colors.red, icon: Icon(Icons.notification_important_rounded));
                                                                                                          }
                                                                                                        },
                                                                                                        child: Text('Lưu'),
                                                                                                        style: ElevatedButton.styleFrom(
                                                                                                          primary: Color(0xffFF7F10),
                                                                                                          onPrimary: Color.fromARGB(221, 255, 255, 255),
                                                                                                          // shadowColor: Colors.greenAccent,
                                                                                                          elevation: 3,
                                                                                                          // shape: RoundedRectangleBorder(
                                                                                                          //     borderRadius: BorderRadius.circular(32.0)),
                                                                                                          minimumSize: Size(140, 50), //////// HERE
                                                                                                        ),
                                                                                                      ),
                                                                                                      ElevatedButton(
                                                                                                        // textColor: Color(0xFF6200EE),
                                                                                                        onPressed: () => Navigator.pop(context),
                                                                                                        child: Text(
                                                                                                          'Đóng',
                                                                                                          style: TextStyle(),
                                                                                                        ),
                                                                                                        style: ElevatedButton.styleFrom(
                                                                                                          primary: Color.fromARGB(255, 255, 255, 255),
                                                                                                          onPrimary: Color(0xffFF7F10),
                                                                                                          // shadowColor: Colors.greenAccent,
                                                                                                          elevation: 3,
                                                                                                          // shape: RoundedRectangleBorder(
                                                                                                          //     borderRadius: BorderRadius.circular(32.0)),
                                                                                                          minimumSize: Size(140, 50), //////// HERE
                                                                                                        ),
                                                                                                      ),
                                                                                                    ],
                                                                                                  );
                                                                                                  showDialog<void>(context: context, builder: (context) => dialog1);
                                                                                                },
                                                                                              ))
                                                                                        ],
                                                                                      ),
                                                                                      Row(
                                                                                        children: [
                                                                                          Expanded(
                                                                                            child: Column(
                                                                                              children: [
                                                                                                Container(
                                                                                                  child: DataTable(
                                                                                                    showCheckboxColumn: false,
                                                                                                    columns: [
                                                                                                      DataColumn(label: Text('STT', style: titleTableData)),
                                                                                                      DataColumn(label: Text('Ngày tạo', style: titleTableData)),
                                                                                                      DataColumn(label: Text('Số lần thi tối đa cho nữ', style: titleTableData)),
                                                                                                      DataColumn(label: Text('Số lần thi tối đa cho nam', style: titleTableData)),
                                                                                                      DataColumn(label: Text('Áp dụng', style: titleTableData)),
                                                                                                      DataColumn(label: Text('Thao tác', style: titleTableData)),
                                                                                                    ],
                                                                                                    rows: <DataRow>[
                                                                                                      for (var i = 0; i < resultCauHinhTinhThuong["content"].length; i++)
                                                                                                        DataRow(
                                                                                                          cells: <DataCell>[
                                                                                                            DataCell(Text("${i + 1}")),
                                                                                                            DataCell(Text(
                                                                                                              FormatDate.formatDateView(DateTime.parse(resultCauHinhTinhThuong["content"][i]["createdDate"].toString())),
                                                                                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                                                                                                            )),
                                                                                                            DataCell(
                                                                                                              Text(resultCauHinhTinhThuong["content"][i]["femaleRoundMax"].toString(), style: bangDuLieu),
                                                                                                            ),
                                                                                                            DataCell(
                                                                                                              Text(resultCauHinhTinhThuong["content"][i]["maleRoundMax"].toString(), style: bangDuLieu),
                                                                                                            ),
                                                                                                            if (resultCauHinhTinhThuong["content"][i]["approve"] != 1)
                                                                                                              DataCell(
                                                                                                                Row(
                                                                                                                  children: [
                                                                                                                    Consumer<NavigationModel>(
                                                                                                                      builder: (context, navigationModel, child) => ElevatedButton(
                                                                                                                          style: ElevatedButton.styleFrom(
                                                                                                                            primary: Colors.blue,
                                                                                                                            onPrimary: Colors.white,
                                                                                                                            // shadowColor: Colors.greenAccent,
                                                                                                                            elevation: 3,
                                                                                                                            // shape: RoundedRectangleBorder(
                                                                                                                            //     borderRadius: BorderRadius.circular(32.0)),
                                                                                                                            minimumSize: Size(140, 50), //////// HERE
                                                                                                                          ),
                                                                                                                          child: Text("Áp dụng"),
                                                                                                                          onPressed: () async {
                                                                                                                            idTargetBonus = resultCauHinhTinhThuong["content"][i]["id"];
                                                                                                                            await updateApprovedTargetBonus1();
                                                                                                                            await updateApproveTargetBonus();
                                                                                                                            await getCauHinhTinhThuong();
                                                                                                                            Navigator.pop(context);
                                                                                                                            showToast(context: context, msg: "Áp dụng thành công!", color: Colors.green, icon: Icon(Icons.supervised_user_circle));
                                                                                                                            await getCauHinhTinhThuong();
                                                                                                                            futureTargetBonus = getTargetBonus(1);
                                                                                                                          }),
                                                                                                                    )
                                                                                                                  ],
                                                                                                                ),
                                                                                                                // Text(resultCauHinhTinhThuong["content"][i]["approve"].toString(), style: bangDuLieu),
                                                                                                              )
                                                                                                            else
                                                                                                              DataCell(
                                                                                                                ElevatedButton(
                                                                                                                    style: ElevatedButton.styleFrom(
                                                                                                                      primary: Color.fromRGBO(245, 117, 29, 1),
                                                                                                                      onPrimary: Colors.white,
                                                                                                                      // shadowColor: Colors.greenAccent,
                                                                                                                      elevation: 3,
                                                                                                                      // shape: RoundedRectangleBorder(
                                                                                                                      //     borderRadius: BorderRadius.circular(32.0)),
                                                                                                                      minimumSize: Size(140, 50), //////// HERE
                                                                                                                    ),
                                                                                                                    child: Text("Đang áp dụng"),
                                                                                                                    onPressed: () {}),
                                                                                                                // Text(resultCauHinhTinhThuong["content"][i]["approve"].toString(), style: bangDuLieu),
                                                                                                              ),
                                                                                                            DataCell(
                                                                                                              Row(
                                                                                                                children: [
                                                                                                                  (resultCauHinhTinhThuong["content"][i]["approve"] != 1)
                                                                                                                      ? Row(
                                                                                                                          children: [
                                                                                                                            InkWell(
                                                                                                                              onTap: () {
                                                                                                                                final AlertDialog dialog2 = AlertDialog(
                                                                                                                                  title: Row(
                                                                                                                                    children: [
                                                                                                                                      Container(
                                                                                                                                        width: MediaQuery.of(context).size.width * 0.35,
                                                                                                                                        height: 80,
                                                                                                                                        child: Row(
                                                                                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                                                          children: [
                                                                                                                                            SizedBox(
                                                                                                                                              child: Row(
                                                                                                                                                children: [
                                                                                                                                                  Container(
                                                                                                                                                    width: 50,
                                                                                                                                                    height: 50,
                                                                                                                                                    child: Image.asset('assets/images/logoAAM.png'),
                                                                                                                                                    margin: EdgeInsets.only(right: 10),
                                                                                                                                                  ),
                                                                                                                                                  Text(
                                                                                                                                                    'Sửa',
                                                                                                                                                    style: TextStyle(fontSize: 20, color: Color(0xff333333), fontWeight: FontWeight.w700),
                                                                                                                                                  ),
                                                                                                                                                ],
                                                                                                                                              ),
                                                                                                                                            ),
                                                                                                                                            IconButton(
                                                                                                                                              onPressed: () => Navigator.pop(context),
                                                                                                                                              icon: Icon(Icons.close),
                                                                                                                                            ),
                                                                                                                                          ],
                                                                                                                                        ),
                                                                                                                                      ),
                                                                                                                                    ],
                                                                                                                                  ),
                                                                                                                                  content: Container(
                                                                                                                                    width: 50,
                                                                                                                                    height: 150,
                                                                                                                                    // color: Colors.black,
                                                                                                                                    padding: EdgeInsets.only(top: 25),
                                                                                                                                    decoration: BoxDecoration(
                                                                                                                                      border: Border(
                                                                                                                                        bottom: BorderSide(
                                                                                                                                          width: 1,
                                                                                                                                          color: Color(0xffD7D7D7),
                                                                                                                                        ),
                                                                                                                                        top: BorderSide(
                                                                                                                                          width: 1,
                                                                                                                                          color: Color(0xffD7D7D7),
                                                                                                                                        ),
                                                                                                                                      ),
                                                                                                                                    ),
                                                                                                                                    child: Column(
                                                                                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                                                      children: [
                                                                                                                                        Row(
                                                                                                                                          children: [
                                                                                                                                            TextFieldValidated(
                                                                                                                                              type: 'Number',
                                                                                                                                              height: 40,
                                                                                                                                              controller: maleRoundMaxFix,
                                                                                                                                              label: 'Số lần thi tuyển cho nam: ',
                                                                                                                                              flexLable: 2,
                                                                                                                                              flexTextField: 3,
                                                                                                                                            ),
                                                                                                                                          ],
                                                                                                                                        ),
                                                                                                                                        Container(
                                                                                                                                          margin: EdgeInsets.only(top: 10),
                                                                                                                                          child: Row(
                                                                                                                                            children: [
                                                                                                                                              TextFieldValidated(
                                                                                                                                                type: 'Number',
                                                                                                                                                height: 40,
                                                                                                                                                controller: femaleRoundMaxFix,
                                                                                                                                                label: 'Số lần thi tuyển cho nữ:',
                                                                                                                                                flexLable: 2,
                                                                                                                                                flexTextField: 3,
                                                                                                                                              ),
                                                                                                                                            ],
                                                                                                                                          ),
                                                                                                                                        ),
                                                                                                                                      ],
                                                                                                                                    ),
                                                                                                                                  ),
                                                                                                                                  actions: [
                                                                                                                                    ElevatedButton(
                                                                                                                                      onPressed: () async {
                                                                                                                                        if (isNumber(maleRoundMaxFix.text) && isNumber(femaleRoundMaxFix.text)) {
                                                                                                                                          idTargetBonus = resultCauHinhTinhThuong["content"][i]["id"];
                                                                                                                                          await updateMaleRoundMax();
                                                                                                                                          await getCauHinhTinhThuong();
                                                                                                                                          Navigator.pop(context);
                                                                                                                                          Navigator.pop(context);
                                                                                                                                          showToast(context: context, msg: "Sửa thành công!", color: Colors.green, icon: Icon(Icons.supervised_user_circle));
                                                                                                                                        } else {
                                                                                                                                          showToast(context: context, msg: "Vui lòng nhập đúng thông tin", color: Colors.red, icon: Icon(Icons.notification_important_rounded));
                                                                                                                                        }
                                                                                                                                      },
                                                                                                                                      child: Text('Lưu'),
                                                                                                                                      style: ElevatedButton.styleFrom(
                                                                                                                                        primary: Color(0xffFF7F10),
                                                                                                                                        onPrimary: Color.fromARGB(221, 255, 255, 255),
                                                                                                                                        elevation: 3,
                                                                                                                                        minimumSize: Size(140, 50), //////// HERE
                                                                                                                                      ),
                                                                                                                                    ),
                                                                                                                                    ElevatedButton(
                                                                                                                                      // textColor: Color(0xFF6200EE),
                                                                                                                                      onPressed: () => Navigator.pop(context),
                                                                                                                                      child: Text(
                                                                                                                                        'Đóng',
                                                                                                                                        style: TextStyle(),
                                                                                                                                      ),
                                                                                                                                      style: ElevatedButton.styleFrom(
                                                                                                                                        primary: Color.fromARGB(255, 255, 255, 255),
                                                                                                                                        onPrimary: Color(0xffFF7F10),
                                                                                                                                        // shadowColor: Colors.greenAccent,
                                                                                                                                        elevation: 3,
                                                                                                                                        // shape: RoundedRectangleBorder(
                                                                                                                                        //     borderRadius: BorderRadius.circular(32.0)),
                                                                                                                                        minimumSize: Size(140, 50), //////// HERE
                                                                                                                                      ),
                                                                                                                                    ),
                                                                                                                                  ],
                                                                                                                                );
                                                                                                                                showDialog<void>(context: context, builder: (context) => dialog2);
                                                                                                                              },
                                                                                                                              child: Icon(
                                                                                                                                Icons.edit_calendar,
                                                                                                                                color: Color(0xff009C87),
                                                                                                                              ),
                                                                                                                            ),
                                                                                                                            IconButton(
                                                                                                                                onPressed: () async {
                                                                                                                                  idTargetBonus = resultCauHinhTinhThuong["content"][i]["id"];
                                                                                                                                  final AlertDialog dialog3 = AlertDialog(
                                                                                                                                    title: Row(
                                                                                                                                      children: [
                                                                                                                                        Container(
                                                                                                                                          width: MediaQuery.of(context).size.width * 0.35,
                                                                                                                                          height: 80,
                                                                                                                                          child: Row(
                                                                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                                                            children: [
                                                                                                                                              SizedBox(
                                                                                                                                                child: Row(
                                                                                                                                                  children: [
                                                                                                                                                    Container(
                                                                                                                                                      width: 50,
                                                                                                                                                      height: 50,
                                                                                                                                                      child: Image.asset('assets/images/logoAAM.png'),
                                                                                                                                                      margin: EdgeInsets.only(right: 10),
                                                                                                                                                    ),
                                                                                                                                                    Text(
                                                                                                                                                      'Xóa',
                                                                                                                                                      style: TextStyle(fontSize: 20, color: Color(0xff333333), fontWeight: FontWeight.w700),
                                                                                                                                                    ),
                                                                                                                                                  ],
                                                                                                                                                ),
                                                                                                                                              ),
                                                                                                                                              IconButton(
                                                                                                                                                onPressed: () => Navigator.pop(context),
                                                                                                                                                icon: Icon(Icons.close),
                                                                                                                                              ),
                                                                                                                                            ],
                                                                                                                                          ),
                                                                                                                                        ),
                                                                                                                                      ],
                                                                                                                                    ),
                                                                                                                                    content: Row(
                                                                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                                                                      children: [
                                                                                                                                        Text("Xóa cấu hình tính thưởng ?"),
                                                                                                                                      ],
                                                                                                                                    ),
                                                                                                                                    actions: [
                                                                                                                                      ElevatedButton(
                                                                                                                                        onPressed: () async {
                                                                                                                                          await delTargetBonus();
                                                                                                                                          Navigator.pop(context);
                                                                                                                                          showToast(context: context, msg: "Xóa thành công!", color: Colors.green, icon: Icon(Icons.supervised_user_circle));

                                                                                                                                          await getCauHinhTinhThuong();
                                                                                                                                        },
                                                                                                                                        child: Text('Đồng ý'),
                                                                                                                                        style: ElevatedButton.styleFrom(
                                                                                                                                          primary: Color(0xffFF7F10),
                                                                                                                                          onPrimary: Color.fromARGB(221, 255, 255, 255),
                                                                                                                                          elevation: 3,
                                                                                                                                          minimumSize: Size(140, 50), //////// HERE
                                                                                                                                        ),
                                                                                                                                      ),
                                                                                                                                      ElevatedButton(
                                                                                                                                        onPressed: () {
                                                                                                                                          Navigator.pop(context);
                                                                                                                                        },
                                                                                                                                        child: Text('Không'),
                                                                                                                                        style: ElevatedButton.styleFrom(
                                                                                                                                          primary: Color(0xffFF7F10),
                                                                                                                                          onPrimary: Color.fromARGB(221, 255, 255, 255),
                                                                                                                                          elevation: 3,
                                                                                                                                          minimumSize: Size(140, 50), //////// HERE
                                                                                                                                        ),
                                                                                                                                      )
                                                                                                                                    ],
                                                                                                                                  );

                                                                                                                                  showDialog<void>(context: context, builder: (context) => dialog3);
                                                                                                                                },
                                                                                                                                icon: Icon(Icons.delete))
                                                                                                                          ],
                                                                                                                        )
                                                                                                                      : Row(
                                                                                                                          children: [
                                                                                                                            Icon(
                                                                                                                              Icons.edit_calendar,
                                                                                                                            ),
                                                                                                                            IconButton(
                                                                                                                              icon: Icon(Icons.delete),
                                                                                                                              onPressed: () {
                                                                                                                                showToast(context: context, msg: "Cấu hình đang áp dụng không được xóa", color: Colors.red, icon: Icon(Icons.warning));
                                                                                                                              },
                                                                                                                            )
                                                                                                                          ],
                                                                                                                        ),
                                                                                                                ],
                                                                                                              ),
                                                                                                            ),
                                                                                                          ],
                                                                                                        )
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ));
                                                    },
                                                    child: Text(
                                                      "Cấu hình chỉ tiêu",
                                                      style: textButton,
                                                    ),
                                                  )
                                                : Container(),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin:
                                            EdgeInsets.fromLTRB(0, 0, 30, 0),
                                        child: Row(children: [
                                          getRule(listRule.data, Role.Sua,
                                                      context) ==
                                                  true
                                              ? ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary: Color.fromRGBO(
                                                        245, 117, 29, 1),
                                                    onPrimary: Colors.white,
                                                    // shadowColor: Colors.greenAccent,
                                                    elevation: 3,
                                                    // shape: RoundedRectangleBorder(
                                                    //     borderRadius: BorderRadius.circular(32.0)),
                                                    minimumSize: Size(
                                                        140, 50), //////// HERE
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Text('Gửi',
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      255,
                                                                      255,
                                                                      255))),
                                                    ],
                                                  ),
                                                  onPressed: () {
                                                    if (checkData()) {
                                                      if (check == true) {
                                                        showDialog(
                                                            context: context,
                                                            builder: (BuildContext
                                                                    context) =>
                                                                AlertDialog(
                                                                  title: Row(
                                                                    children: [
                                                                      Container(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            0.25,
                                                                        height:
                                                                            80,
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            SizedBox(
                                                                              child: Row(
                                                                                children: [
                                                                                  Container(
                                                                                    width: 50,
                                                                                    height: 50,
                                                                                    child: Image.asset('assets/images/logoAAM.png'),
                                                                                    margin: EdgeInsets.only(right: 10),
                                                                                  ),
                                                                                  Text(
                                                                                    'Tiêu đề',
                                                                                    style: TextStyle(fontSize: 20, color: Color(0xff333333), fontWeight: FontWeight.w700),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            IconButton(
                                                                              onPressed: () {
                                                                                Navigator.pop(context);
                                                                              },
                                                                              icon: Icon(Icons.close),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  content:
                                                                      Container(
                                                                    width: 50,
                                                                    height: 150,
                                                                    // color: Colors.black,
                                                                    padding: EdgeInsets
                                                                        .only(
                                                                            top:
                                                                                25),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      border:
                                                                          Border(
                                                                        bottom:
                                                                            BorderSide(
                                                                          width:
                                                                              1,
                                                                          color:
                                                                              Color(0xffD7D7D7),
                                                                        ),
                                                                        top:
                                                                            BorderSide(
                                                                          width:
                                                                              1,
                                                                          color:
                                                                              Color(0xffD7D7D7),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            TextFieldValidated(
                                                                              type: 'Text',
                                                                              height: 40,
                                                                              controller: title,
                                                                              label: 'Nhập tiêu đề',
                                                                              flexLable: 2,
                                                                              flexTextField: 4,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  actions: [
                                                                    ElevatedButton(
                                                                      // textColor: Color(0xFF6200EE),
                                                                      onPressed:
                                                                          () =>
                                                                              Navigator.pop(context),
                                                                      child: Text(
                                                                          'Hủy'),
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        primary:
                                                                            Color(0xffFF7F10),
                                                                        onPrimary: Color.fromARGB(
                                                                            221,
                                                                            255,
                                                                            255,
                                                                            255),
                                                                        // shadowColor: Colors.greenAccent,
                                                                        elevation:
                                                                            3,
                                                                        // shape: RoundedRectangleBorder(
                                                                        //     borderRadius: BorderRadius.circular(32.0)),
                                                                        minimumSize: Size(
                                                                            140,
                                                                            50), //////// HERE
                                                                      ),
                                                                    ),
                                                                    Consumer<
                                                                        NavigationModel>(
                                                                      builder: (context,
                                                                              navigationModel,
                                                                              child) =>
                                                                          ElevatedButton(
                                                                        // textColor: Color(0xFF6200EE),
                                                                        onPressed:
                                                                            () async {
                                                                          await addTargetBonus();
                                                                          await addDetailTargetBonus();
                                                                          await updateRewardOfferId();
                                                                          (status == true)
                                                                              ? showToast(context: context, msg: "Gửi thanh toán thành công", color: Colors.green, icon: Icon(Icons.supervised_user_circle))
                                                                              : showToast(context: context, msg: "Gửi thanh toán không thành công", color: Colors.red, icon: Icon(Icons.warning));
                                                                          addNotification() async {
                                                                            try {
                                                                              var data = {
                                                                                "title": " Hệ thống thông báo",
                                                                                "message": 'Có đề nghị mới thưởng chỉ tiêu tuyển dụng.',
                                                                              };
                                                                              await httpPost('/api/push/tags/depart_id/2&6&9', data, context);
                                                                            } catch (_) {
                                                                              print("Fail!");
                                                                            }
                                                                          }

                                                                          await addNotification();
                                                                          //  getTargetBonus(0);
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        child:
                                                                            Text(
                                                                          'Xác nhận',
                                                                          style:
                                                                              TextStyle(),
                                                                        ),
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          primary: Color.fromARGB(
                                                                              255,
                                                                              255,
                                                                              255,
                                                                              255),
                                                                          onPrimary:
                                                                              Color(0xFFFF7F10),
                                                                          // shadowColor: Colors.greenAccent,
                                                                          elevation:
                                                                              3,
                                                                          // shape: RoundedRectangleBorder(
                                                                          //     borderRadius: BorderRadius.circular(32.0)),
                                                                          minimumSize: Size(
                                                                              140,
                                                                              50), //////// HERE
                                                                        ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ));
                                                      } else {
                                                        showToast(
                                                            context: context,
                                                            msg:
                                                                "Đơn hàng chưa có cấu hình thưởng",
                                                            color: Colors.red,
                                                            icon: Icon(
                                                                Icons.warning));
                                                      }
                                                    } else {
                                                      print("thanggg2");
                                                      showToast(
                                                          context: context,
                                                          msg:
                                                              "Không có thưởng chỉ tiêu nào !",
                                                          color: Color.fromARGB(
                                                              255,
                                                              235,
                                                              255,
                                                              81),
                                                          icon: Icon(
                                                              Icons.warning));
                                                    }
                                                  },
                                                  // style: ElevatedButton.styleFrom(
                                                  //   primary: Color.fromRGBO(245, 117, 29, 1),
                                                  //   onPrimary: Colors.white,
                                                  //   // shadowColor: Colors.greenAccent,
                                                  //   elevation: 3,
                                                  //   // shape: RoundedRectangleBorder(
                                                  //   //     borderRadius: BorderRadius.circular(32.0)),
                                                  //   minimumSize: Size(100, 50), //////// HERE
                                                  // ),
                                                )
                                              : Container(),
                                        ]),
                                      ),
                                    ]),
                              ),
                            ),
                            Container(
                              // width: MediaQuery.of(context).size.width * 1,
                              decoration: BoxDecoration(
                                color: colorWhite,
                                borderRadius: borderRadiusContainer,
                                boxShadow: [boxShadowContainer],
                                border: borderAllContainerBox,
                              ),
                              padding: paddingBoxContainer,
                              margin: EdgeInsets.only(left: 25, right: 25),
                              child: Column(
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 1,
                                    child: DataTable(
                                      columns: [
                                        DataColumn(
                                            label: Text('STT',
                                                style: titleTableData)),
                                        DataColumn(
                                            label: Text('Tên nhân viên',
                                                style: titleTableData)),
                                        DataColumn(
                                            label: Text('Phòng ban',
                                                style: titleTableData)),
                                        DataColumn(
                                            label: Text('Tổng số TTS',
                                                style: titleTableData)),
                                        DataColumn(
                                            label: Text('Tổng số lần thi tuyển',
                                                style: titleTableData)),
                                        DataColumn(
                                            label: Text('Số tiền',
                                                style: titleTableData)),
                                        // DataColumn(label: Text('Trạng thái thanh toán', style: titleTableData)),
                                        // DataColumn(label: Text('Ngày thanh toán', style: titleTableData)),
                                      ],
                                      rows: <DataRow>[
                                        if (listAamId.isNotEmpty)
                                          for (int i = 0;
                                              i < listAamId.length;
                                              i++)
                                            DataRow(
                                              cells: <DataCell>[
                                                DataCell(Text("${i + 1}")),
                                                DataCell(
                                                  TextButton(
                                                    child: Text(
                                                        listAam["content"][i]
                                                                ['fullName'] +
                                                            " (${listAam["content"][i]['userCode']})",
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400)),
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => ViewHSNSBody(
                                                                idHSNS: listAam[
                                                                            "content"]
                                                                        [
                                                                        i]["id"]
                                                                    .toString())),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                      listAam["content"][i]
                                                                  ['phongban']
                                                              ['departName']
                                                          .toString(),
                                                      style: bangDuLieu),
                                                ),
                                                DataCell(
                                                  Text(
                                                      listCountTraineeGroupByCareUser[
                                                                  listAam["content"]
                                                                      [i]['id']]
                                                              ['sumOfTts']
                                                          .toString(),
                                                      style: bangDuLieu),
                                                ),
                                                DataCell(
                                                  TextButton(
                                                    onPressed: () async {
                                                      careUser =
                                                          listAam["content"][i]
                                                              ['id'];
                                                      await getListTrainee();
                                                      await getBonus();
                                                      String orderName = "";
                                                      var listTargetBonus = [];
                                                      var listTrainee = [];
                                                      for (int i = 0;
                                                          i <
                                                              resultListTargetBonus[
                                                                      "content"]
                                                                  .length;
                                                          i++) {
                                                        listTargetBonus.add(
                                                            resultListTargetBonus[
                                                                "content"][i]);
                                                      }
                                                      for (int i = 0;
                                                          i <
                                                              resultListTrainee[
                                                                      "content"]
                                                                  .length;
                                                          i++) {
                                                        listTrainee.add(
                                                            resultListTrainee[
                                                                "content"][i]);
                                                      }
                                                      for (int i = 0;
                                                          i <
                                                              listTargetBonus
                                                                  .length;
                                                          i++) {
                                                        for (int j = 0;
                                                            j <
                                                                listTrainee
                                                                    .length;
                                                            j++) {
                                                          if (listTrainee[j]
                                                                  ["orderId"] ==
                                                              listTargetBonus[i]
                                                                  ["orderId"]) {
                                                            listTrainee
                                                              ..removeWhere((element) =>
                                                                  element[
                                                                      'orderId'] ==
                                                                  listTargetBonus[
                                                                          i][
                                                                      "orderId"]);
                                                          }
                                                        }
                                                      }
                                                      orderName = "";
                                                      var listRemove = {};
                                                      if (listTrainee
                                                          .isNotEmpty) {
                                                        // for (int j = 0; j < listTrainee.length; j++) {
                                                        //   if (listTrainee.contains(listTrainee[j])) {
                                                        //     listTrainee.removeWhere((element) => element == listTrainee[j]);
                                                        //   }
                                                        // }
                                                        listTrainee
                                                            .forEach((element) {
                                                          listRemove.putIfAbsent(
                                                              "${element["donhang"]["orderCode"]}",
                                                              () => element[
                                                                      "donhang"]
                                                                  [
                                                                  "orderCode"]);
                                                        });
                                                        orderName += (listRemove
                                                            .keys
                                                            .toList()
                                                            .toString());
                                                        showToast(
                                                            context: context,
                                                            msg:
                                                                "Đơn hàng $orderName chưa có cấu hình thưởng",
                                                            color: Colors.red,
                                                            icon: Icon(
                                                                Icons.warning));
                                                        check = false;
                                                      } else {
                                                        _showMaterialDialog(
                                                            context, i);
                                                        check = true;
                                                      }
                                                    },
                                                    child: Text(
                                                        total[listAamId[i]]
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400)),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                      NumberFormat
                                                              .simpleCurrency(
                                                                  locale: "vi")
                                                          .format(getTotalMoney(
                                                              listAam["content"]
                                                                  [i]['id']))
                                                          .toString(),
                                                      style: bangDuLieu),
                                                  // Text(getTotalMoney(listAam["content"][i]['id']).toString(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                                                ),
                                              ],
                                            )
                                      ],
                                    ),
                                  ),
                                  if (listAamId.isEmpty)
                                    Center(
                                      child: Text("Không có dữ liệu"),
                                    )
                                  // DynamicTablePagging(rowCount, currentPageDef, rowPerPage, pageChangeHandler: (currentPage) {
                                  //   setState(() {
                                  //     futureTargetBonus = getTargetBonus(currentPage);
                                  //     currentPageDef = currentPage;
                                  //   });
                                  // }, rowPerPageChangeHandler: (rowPerPageChange) {
                                  //   rowPerPage = rowPerPageChange;
                                  //   futureTargetBonus = getTargetBonus(1);

                                  //   setState(() {});
                                  // })
                                ],
                              ),
                            ),
                            Footer(
                                marginFooter: EdgeInsets.only(top: 25),
                                paddingFooter: EdgeInsets.all(15))
                          ]));
                } else if (snapshot.hasError) {
                  return Text('Delivery error: ${snapshot.error.toString()}');
                } else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                        ],
                      ),
                    ],
                  );
                }
              });
        } else if (listRule.hasError) {
          return Text('${listRule.error}');
        }

        // By default, show a loading spinner.
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
