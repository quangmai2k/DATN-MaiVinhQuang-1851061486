import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/navigation.dart';
import 'package:gentelella_flutter/widgets/ui/source_information/thong_tin_nguon.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../api.dart';
import '../../common/style.dart';

import '../../model/model.dart';

import 'package:hive/hive.dart';

import '../forms/nhan_su/setting-data/recruitment.dart';

final box = Hive.box('myBox');

class DashBoard extends StatelessWidget {
  const DashBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: DashBoardBody());
  }
}

final String urlHoSoNhanSu = "/ho-so-nhan-su";
final String urlQuanLyNghiepDoan = "/quan-li-nghiep-doan";
final String urlQuanLyCTV = "/quan-ly-cong-tac-vien";
final String urlQuanLyThongTinTTS = "/quan-ly-thong-tin-thuc-tap-sinh";
final String urlDanhSachDonHang = "/danh-sach-don-hang-ttn";

// List<ChartDataByMonth> chartData = [];

class DashBoardBody extends StatefulWidget {
  const DashBoardBody({Key? key}) : super(key: key);

  @override
  State<DashBoardBody> createState() => _DashBoardBodyState();
}

class _DashBoardBodyState extends State<DashBoardBody> {
  late Future futureDashBoard;
  var objValue = {};

//   getCountTrainee() async {
//     var countTrainee;
//     var response = await httpGet("/api/nguoidung/get/count?filter=isTts:1", context);
//     if (response.containsKey("body")) {
//       setState(() {
//         countTrainee = jsonDecode(response["body"]);
//       });
//     }
//     // objValue["countTrainee"] = countTrainee;
//     return countTrainee;
//   }

//   getCountCollaborator() async {
//     var response = await httpGet("/api/nguoidung/get/count?filter=isCtv:1", context);
//     var countCollaborator;
//     if (response.containsKey("body")) {
//       setState(() {
//         countCollaborator = jsonDecode(response["body"]);
//       });
//     }
//     return countCollaborator;
//   }

//   getCountSyndicate() async {
//     var countSyndycate;
//     var response = await httpGet("/api/nghiepdoan/get/count?filter=contractStatus:1", context);
//     if (response.containsKey("body")) {
//       setState(() {
//         countSyndycate = jsonDecode(response["body"]);
//       });
//     }
//     return countSyndycate;
//   }

//   getCountOrder() async {
//     var countOrder;
//     var response = await httpGet("/api/donhang/get/count?filter=orderStatusId:1", context);
//     if (response.containsKey("body")) {
//       setState(() {
//         countOrder = jsonDecode(response["body"]);
//       });
//     }
//     return countOrder;
//   }

//   getCountEmployee() async {
//     var countEmployee;
//     var response = await httpGet("/api/nguoidung/get/count?filter=isAam:1", context);
//     if (response.containsKey("body")) {
//       setState(() {
//         countEmployee = jsonDecode(response["body"]);
//       });
//     }
//     return countEmployee;
//   }

//   //------------------------------------------------

//   getCountInterestedTrainee() async {
//     var countInterestedTrainee;
//     var response = await httpGet(
//         "/api/nguoidung/get/count?filter=isTts:1 AND ttsStatusId:1", //Đang quan tâm
//         context);
//     // print(countInterestedTrainee);

//     if (response.containsKey("body")) {
//       setState(() {
//         countInterestedTrainee = jsonDecode(response["body"]);
//         // print("thang");
//         // print(countInterestedTrainee);
//       });
//     }
//     objValue["countInterestedTrainee"] = countInterestedTrainee;
//     return countInterestedTrainee;
//   }

//   getCountPassedTrainee() async {
//     var countPassedTrainee;
//     var response = await httpGet("/api/nguoidung/get/count?filter=isTts:1 AND ttsStatusId:7", context); //Đã trúng tuyển
//     if (response.containsKey("body")) {
//       setState(() {
//         countPassedTrainee = jsonDecode(response['body']);
//         // double y = (numberTTSTrungTuyen / numberAllSTTS) * 100;
//         // _lstDataTTSPieChart
//         //     .add(ChartDataP(getStatusNameTTS(_listStatusTTS, 7), y));
//       });
//     }
//     return countPassedTrainee;
//   }

//   getCountAdvisedTrainee() async {
//     var countAdvisedTrainee;
//     var response = await httpGet("/api/nguoidung/get/count?filter=isTts:1 AND ttsStatusId:5", context);
//     if (response.containsKey("body")) {
//       setState(() {
//         countAdvisedTrainee = jsonDecode(response["body"]);
//       });
//     }
//     return countAdvisedTrainee;
//   }

//   getCountDeclaredTrainee() async {
//     var countDeclaredTrainee;
//     var response = await httpGet(
//         "/api/nguoidung/get/count?filter=isTts:1 AND ttsStatusId:3", //Đã khai form
//         context);
//     if (response.containsKey("body")) {
//       setState(() {
//         countDeclaredTrainee = jsonDecode(response["body"]);
//       });
//     }
//     return countDeclaredTrainee;
//   }

//   getCountExitTrainee() async {
//     var countExitTrainee;
//     var response = await httpGet(
//         "/api/nguoidung/get/count?filter=isTts:1 AND ttsStatusId:11", //Đã xuất cảnh
//         context);
//     if (response.containsKey("body")) {
//       setState(() {
//         countExitTrainee = jsonDecode(response["body"]);
//       });
//     }
//     return countExitTrainee;
//   }

// //-----------------------------Đơn hàng-----------------------------------
//   getCountWaitingForHandleOrder() async {
//     var countWaitingForHandleOrder;
//     var response = await httpGet("/api/donhang/get/count?filter=orderStatusId:2", context);
//     if (response.containsKey("body")) {
//       setState(() {
//         countWaitingForHandleOrder = jsonDecode(response['body']);
//       });
//     }
//     return countWaitingForHandleOrder;
//   }

//   getCountNewlyCreateOrder() async {
//     var countNewlyCreateOrder;
//     var response = await httpGet("/api/donhang/get/count?filter=orderStatusId:1", context);
//     if (response.containsKey("body")) {
//       setState(() {
//         countNewlyCreateOrder = jsonDecode(response['body']);
//       });
//     }
//     return countNewlyCreateOrder;
//   }

//   getCountProcessingOrder() async {
//     var countProcessingOrder;
//     var response = await httpGet("/api/donhang/get/count?filter=orderStatusId:3", context);
//     if (response.containsKey("body")) {
//       setState(() {
//         countProcessingOrder = jsonDecode(response['body']);
//       });
//     }
//     return countProcessingOrder;
//   }

//   getCountCompletedOrder() async {
//     var countCompletedOrder;
//     var response = await httpGet("/api/donhang/get/count?filter=orderStatusId:4", context);
//     if (response.containsKey("body")) {
//       setState(() {
//         countCompletedOrder = jsonDecode(response['body']);
//       });
//     }
//     return countCompletedOrder;
//   }

//   getCountOrders() async {
//     var countCompletedOrder;
//     var response = await httpGet("/api/donhang/get/count?filter!=orderStatusId:1", context).timeout(const Duration(seconds: 50));
//     if (response.containsKey("body")) {
//       setState(() {
//         countCompletedOrder = jsonDecode(response['body']);
//       });
//     }
//     return countCompletedOrder;
//   }

  var data = {};
  getData() async {
    var response = await httpGet("/api/hethong-chung/get/thongke", context);
    if (response.containsKey("body")) {
      setState(() {
        data = jsonDecode(response['body']);
        print(data);
      });
    }
    // print(widget.callbackData);
  }

  //Dữ liệu biểu đồ
  getMonthListToMonthCurrent(objValue) async {
    List<ChartDataByMonth> listMonth = [];
    var date = new DateTime.now();
    var month = "";
    for (int i = 1; i <= date.month; i++) {
      if (i < 10) {
        month = "0" + i.toString();
      } else {
        month = i.toString();
      }
      var dateFrom = "01-$month-${date.year}";
      var dateTo = "${getDateInMonth(i, date.year)}-$month-${date.year}";
      var response = await httpGet(
          "/api/donhang/get/count?filter=createdDate>:'$dateFrom' AND  createdDate<:'$dateTo'",
          context);
      var body = jsonDecode(response['body']);
      // print("abc"+body.runtimeType.toString());
      ChartDataByMonth item = new ChartDataByMonth("Tháng $i", body, i);
      listMonth.add(item);
    }
    // setState(() {
    // chartData = listMonth;
    // });
    objValue["listMonth"] = listMonth;
    // return listMonth;
  }

  //Get đề nghị tuyển dụng
  List<dynamic> listRecruitResult = [];
  getListTD() async {
    var response = await httpGet(
        "/api/tuyendung/get/page?filter=approve:0&sort=id,desc&size=5&page=0",
        context);
    if (response.containsKey("body")) {
      var body = jsonDecode(response['body']);
      var content = body['content'];
      setState(() {
        listRecruitResult = content.map((e) {
          return Recruitment.fromJson(e);
        }).toList();
      });
    }

    return listRecruitResult;
  }

  int getDateInMonth(int month, int year) {
    int dateOfMonth = 30;
    if (month == 1 ||
        month == 3 ||
        month == 5 ||
        month == 7 ||
        month == 8 ||
        month == 10 ||
        month == 12) {
      dateOfMonth = 31;
    } else if (month == 2) {
      dateOfMonth = 28;
      if (year / 4 == 0) {
        dateOfMonth = 29;
      }
    }

    return dateOfMonth;
  }

  callAllApi(objValueModel) async {
    await getMonthListToMonthCurrent(objValueModel.objValue);
    await getListTD();
  }

  // openBox() async {
  //   var countTrainee = await getCountTrainee();
  //   var countCollaborator = await getCountCollaborator();
  //   var countInterestedTrainee = await getCountInterestedTrainee();
  //   var countSyndicate = await getCountSyndicate();
  //   var countPassedTrainee = await getCountPassedTrainee();
  //   var countOrder = await getCountOrder();
  //   var countEmployee = await getCountEmployee();
  //   var countAdvisedTrainee = await getCountAdvisedTrainee();
  //   var countDeclaredTrainee = await getCountDeclaredTrainee();
  //   var countExitTrainee = await getCountExitTrainee();
  //   var countWaitingForHandleOrder = await getCountWaitingForHandleOrder();
  //   var countNewlyCreateOrder = await getCountNewlyCreateOrder();
  //   var countProcessingOrder = await getCountProcessingOrder();
  //   var countCompletedOrder = await getCountCompletedOrder();

  //   // List<ChartDataByMonth> listMonth = await getMonthListToMonthCurrent();
  //   await box.put("countTrainee", countTrainee);
  //   await box.put("countCollaborator", countCollaborator);
  //   await box.put("countInterestedTrainee", countInterestedTrainee);
  //   await box.put("countSyndicate", countSyndicate);
  //   await box.put("countPassedTrainee", countPassedTrainee);
  //   await box.put("countOrder", countOrder);
  //   await box.put("countEmployee", countEmployee);
  //   await box.put("countAdvisedTrainee", countAdvisedTrainee);
  //   await box.put("countDeclaredTrainee", countDeclaredTrainee);
  //   await box.put("countExitTrainee", countExitTrainee);
  //   await box.put("countWaitingForHandleOrder", countWaitingForHandleOrder);
  //   await box.put("countNewlyCreateOrder", countNewlyCreateOrder);
  //   await box.put("countProcessingOrder", countProcessingOrder);
  //   await box.put("countCompletedOrder", countCompletedOrder);
  //   // await box.add(listMonth);
  // }

  Future getProvider() async {
    await getData();

    var objValueModel = context.read<ObjValueModel>();
    var currentTimeStamp = DateTime.now().toUtc().second;
    if (objValueModel.objValue.isEmpty) {
      await callAllApi(objValueModel);
      objValue = objValueModel.objValue;
      objValueModel.timeBefore = DateTime.now().toUtc().second;
    } else {
      if (currentTimeStamp - objValueModel.timeBefore > 1800) {
        callAllApi(objValueModel);
        objValue = objValueModel.objValue;
        objValueModel.timeBefore = DateTime.now().toUtc().second;
      }
      objValue = objValueModel.objValue;
    }
    return 0;
  }

  @override
  void initState() {
    futureDashBoard = getProvider();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futureDashBoard,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Consumer<SecurityModel>(
              builder: (context, user, child) => ListView(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 1,
                    decoration: BoxDecoration(
                      color: colorWhite,
                      boxShadow: [boxShadowContainer],
                      border: Border(
                        bottom: borderTitledPage,
                      ),
                    ),
                    padding: paddingTitledPage,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                            margin: EdgeInsets.only(bottom: 15),
                            child: Text('Dashboard', style: titlePage)),
                      ],
                    ),
                  ),
                  Container(
                    color: backgroundPage,
                    padding: EdgeInsets.symmetric(
                        vertical: verticalPaddingPage,
                        horizontal: horizontalPaddingPage),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Consumer<NavigationModel>(
                          builder: (context, navigationModel, child) => Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // Các khối dữ liệu tổng quan ở trên đầu trang
                              Expanded(
                                flex: 5,
                                child: InkWell(
                                  child: OverviewDataBox(
                                    bGColorIconBox: colorBGIconOverviewDataBox1,
                                    // dataBox: (box.get('countTrainee') is int) ? box.get('countTrainee') : 0,
                                    dataBox: (data['tong_tts'] != null)
                                        ? data["tong_tts"]
                                        : 0,
                                    titleBox: 'TTS ',
                                    colorIconBox: colorWhite,
                                    iconBox: Icons.account_box,
                                    sizeIconBox: sizeIconOverviewDataBox,
                                  ),
                                  onTap: () {
                                    navigationModel.add(
                                        pageUrl: urlQuanLyThongTinTTS);
                                  },
                                ),
                              ),

                              Expanded(flex: 1, child: Container()),
                              Expanded(
                                flex: 5,
                                child: InkWell(
                                  child: OverviewDataBox(
                                    bGColorIconBox: colorBGIconOverviewDataBox2,
                                    // dataBox: (box.get('countCollaborator') is int) ? box.get('countCollaborator') : 0,
                                    dataBox: (data['tong_ctv'] != null)
                                        ? data["tong_ctv"]
                                        : 0,
                                    titleBox: 'CTV',
                                    colorIconBox: colorWhite,
                                    iconBox: Icons.account_balance_wallet_sharp,
                                    sizeIconBox: sizeIconOverviewDataBox,
                                  ),
                                  onTap: () {
                                    navigationModel.add(pageUrl: urlQuanLyCTV);
                                  },
                                ),
                              ),

                              Expanded(flex: 1, child: Container()),
                              Expanded(
                                flex: 5,
                                child: InkWell(
                                  child: OverviewDataBox(
                                    bGColorIconBox: colorBGIconOverviewDataBox3,
                                    // dataBox: (box.get('countSyndicate') is int) ? box.get('countSyndicate') : 0,
                                    dataBox:
                                        (data['nghiepdoan_dakyhopdong'] != null)
                                            ? data["nghiepdoan_dakyhopdong"]
                                            : 0,
                                    titleBox: 'Nghiệp đoàn ',
                                    colorIconBox: colorWhite,
                                    iconBox: Icons.account_tree_outlined,
                                    sizeIconBox: sizeIconOverviewDataBox,
                                  ),
                                  onTap: () {
                                    navigationModel.add(
                                        pageUrl: urlQuanLyNghiepDoan);
                                  },
                                ),
                              ),

                              Expanded(flex: 1, child: Container()),
                              Expanded(
                                flex: 5,
                                child: InkWell(
                                  child: OverviewDataBox(
                                    bGColorIconBox: colorBGIconOverviewDataBox3,
                                    dataBox: data['donhang_choxuly'] +
                                        data['donhang_dangthuchien'] +
                                        data['donhang_hoanthanh'] +
                                        data['donhang_dungxuly'],
                                    titleBox: 'Đơn hàng',
                                    colorIconBox: colorWhite,
                                    iconBox: Icons.article_outlined,
                                    sizeIconBox: sizeIconOverviewDataBox,
                                  ),
                                  onTap: () {
                                    navigationModel.add(
                                        pageUrl: '/quan-li-don-hang');
                                  },
                                ),
                              ),

                              Expanded(flex: 1, child: Container()),
                              Expanded(
                                flex: 5,
                                child: InkWell(
                                  child: OverviewDataBox(
                                    bGColorIconBox: colorBGIconOverviewDataBox3,
                                    // dataBox: (box.get('countEmployee') is int) ? box.get('countEmployee') : 0,
                                    dataBox: (data['tong_nv'] != null)
                                        ? data["tong_nv"]
                                        : 0,
                                    titleBox: 'Nhân viên',
                                    colorIconBox: colorWhite,
                                    iconBox: Icons.account_box,
                                    sizeIconBox: sizeIconOverviewDataBox,
                                  ),
                                  onTap: () {
                                    navigationModel.add(pageUrl: urlHoSoNhanSu);
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                        (user.userLoginCurren['departId'] == 2 ||
                                user.userLoginCurren['departId'] == 1)
                            ? Row(
                                //biểu đồ
                                children: [
                                  Expanded(
                                      flex: 5,
                                      child: PieChart(
                                        data: data,
                                      )),
                                  SizedBox(width: 20),
                                  Expanded(
                                      flex: 5, child: PieChart1(data: data)),
                                  SizedBox(width: 20),
                                  Expanded(
                                      flex: 5,
                                      child: TabBarComfim(
                                        listXacNhan: [],
                                        listDeNghi: listRecruitResult,
                                      )),
                                  //thông báo
                                ],
                              )
                            : Row(
                                //biểu đồ
                                children: [
                                  Expanded(flex: 2, child: Container()),
                                  Expanded(
                                      flex: 5,
                                      child: PieChart(
                                        data: data,
                                      )),
                                  Spacer(),
                                  Expanded(
                                      flex: 5, child: PieChart1(data: data)),
                                  Expanded(flex: 2, child: Container())
                                  //thông báo
                                ],
                              ),

                        ///////////////////
                        Row(
                          //biểu đồ
                          children: [
                            Expanded(
                              flex: 6,
                              // child: PieChart(),
                              child: BieuDo(chartData: objValue["listMonth"]),
                              //thông báo
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 30.0),
                                child: Text(
                                  'Copyright © 2022 - AAM',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff73879C),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Delivery error: ${snapshot.error.toString()}');
          } else {
            return Center(child: const CircularProgressIndicator());
          }
        });
  }
}

class BieuDo extends StatelessWidget {
  // List<int>? listMonth;
  final List<ChartDataByMonth> chartData;
  const BieuDo({Key? key, required this.chartData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(30),
        margin: EdgeInsets.only(top: 30),
        width: MediaQuery.of(context).size.width * 1,
        height: 450,
        // margin: EdgeInsets.fromLTRB(30, 40, 0, 0),
        decoration: BoxDecoration(
          color: colorWhite,
          borderRadius: BorderRadius.all(
            Radius.elliptical(20, 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xffE7EAF1).withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 0), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Số lượng đơn hàng',
              style: TextStyle(
                color: Color(
                  0xff212529,
                ),
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Expanded(
              // width: MediaQuery.of(context).size.width * 13,
              child: SfCartesianChart(
                legend: Legend(isVisible: true),
                // primaryXAxis: DateTimeAxis(
                //     // Interval type will be months
                //     rangePadding: ChartRangePadding.additional,
                //     intervalType: DateTimeIntervalType.months,
                //     interval: 2),
                primaryXAxis: CategoryAxis(),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <ChartSeries>[
                  // Renders line chart
                  LineSeries<ChartDataByMonth, String>(
                    name: 'Số lượng đơn hàng',
                    dataSource: chartData,
                    xValueMapper: (ChartDataByMonth data, _) => data.x,
                    yValueMapper: (ChartDataByMonth data, _) => data.y,
                    dataLabelSettings: DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//------------Biểu đồ tròn trạng thái TTS----

class PieChart extends StatefulWidget {
  final data;
  const PieChart({Key? key, required this.data}) : super(key: key);

  @override
  State<PieChart> createState() => _PieChartState();
}

class _PieChartState extends State<PieChart> {
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ObjValueModel>(
      builder: (context, valueObject, child) {
        // print(valueObject.objValue);
        return Container(
          padding: paddingBoxContainer,
          margin: marginTopBoxContainer,
          width: MediaQuery.of(context).size.width * 1,
          height: heightBoxContainer,
          decoration: BoxDecoration(
            color: colorWhite,
            borderRadius: borderRadiusContainer,
            boxShadow: [boxShadowContainer],
            border: borderAllContainerBox,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trạng thái thực tập sinh',
                    style: titleBox,
                  ),
                  // Icon(
                  //   Icons.more_horiz,
                  //   color: colorIconTitleBox,
                  //   size: sizeIconTitleBox,
                  // ),
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
              Expanded(
                child: SfCircularChart(
                  tooltipBehavior: _tooltipBehavior,
                  legend: Legend(
                      isVisible: true,
                      overflowMode: LegendItemOverflowMode.wrap),
                  // title: ChartTitle(text: 'Trạng thái TTS', alignment: Alignment.topLeft),
                  series: <CircularSeries>[
                    // Render pie chart
                    PieSeries<ChartDataP, String>(
                      enableTooltip: true,
                      dataSource: [
                        // Bind data source
                        // ChartDataP('Đang quan tâm', (box.get("countInterestedTrainee") is double) ? box.get("countInterestedTrainee") : 0),
                        // ChartDataP('Đã khai form', (box.get("countDeclaredTrainee") is double ? box.get("countDeclaredTrainee") : 0)),
                        // ChartDataP('Đã tiến cử', (box.get("countAdvisedTrainee") is double ? box.get("countAdvisedTrainee") : 0)),
                        // ChartDataP('Đã trúng tuyển', box.get("countPassedTrainee") is double ? box.get("countPassedTrainee") : 0),
                        // ChartDataP('Đã xuất cảnh', (box.get("countExitTrainee") is double ? box.get("countExitTrainee") : 0))
                        ChartDataP(
                            'Đang quan tâm',
                            (widget.data["tts_dangquantam"] != null)
                                ? widget.data["tts_dangquantam"]
                                : 0),
                        ChartDataP(
                            'Đã khai form',
                            (widget.data["tts_dakhaiform"] != null)
                                ? widget.data["tts_dakhaiform"]
                                : 0),
                        ChartDataP(
                            'Đã tiến cử',
                            (widget.data["tts_datiencu"] != null)
                                ? widget.data["tts_datiencu"]
                                : 0),
                        ChartDataP(
                            'Đã trúng tuyển',
                            (widget.data["tts_datrungtuyen"] != null)
                                ? widget.data["tts_datrungtuyen"]
                                : 0),
                        ChartDataP(
                            'Đã xuất cảnh',
                            (widget.data["tts_daxuatcanh"] != null)
                                ? widget.data["tts_daxuatcanh"]
                                : 0)
                      ],
                      xValueMapper: (ChartDataP data, _) => data.x,
                      yValueMapper: (ChartDataP data, _) => data.y,
                      // name: 'Data',
                      dataLabelSettings: DataLabelSettings(isVisible: true),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

//Biểu đồ trạng thái đơn hàng
class PieChart1 extends StatefulWidget {
  final data;
  const PieChart1({Key? key, required this.data}) : super(key: key);

  @override
  State<PieChart1> createState() => _PieChart1State();
}

class _PieChart1State extends State<PieChart1> {
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ObjValueModel>(builder: (context, valueObject, child) {
      return Container(
        padding: paddingBoxContainer,
        margin: marginTopBoxContainer,
        width: MediaQuery.of(context).size.width * 1,
        height: heightBoxContainer,
        decoration: BoxDecoration(
          color: colorWhite,
          borderRadius: borderRadiusContainer,
          boxShadow: [boxShadowContainer],
          border: borderAllContainerBox,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trạng thái đơn hàng',
                  style: titleBox,
                ),
                // Icon(
                //   Icons.more_horiz,
                //   color: colorIconTitleBox,
                //   size: sizeIconTitleBox,
                // ),
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
            Expanded(
              child: SfCircularChart(
                tooltipBehavior: _tooltipBehavior,
                legend: Legend(
                    isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
                // title: ChartTitle(text: 'Trạng thái TTS', alignment: Alignment.topLeft),
                series: <CircularSeries>[
                  // Render pie chart
                  PieSeries<ChartDataP, String>(
                    enableTooltip: true,
                    dataSource: [
                      // Bind data source
                      ChartDataP(
                          'Chưa phát hành',
                          (widget.data["donhang_chuaphathanh"] != null)
                              ? widget.data["donhang_chuaphathanh"]
                              : 0),
                      ChartDataP(
                          'Chờ xử lý',
                          (widget.data["donhang_choxuly"] != null)
                              ? widget.data["donhang_choxuly"]
                              : 0),
                      ChartDataP(
                          'Đang thực hiện',
                          (widget.data["donhang_dangthuchien"] != null)
                              ? widget.data["donhang_dangthuchien"]
                              : 0),
                      ChartDataP(
                          'Đã hoàn thành',
                          (widget.data["donhang_hoanthanh"] != null)
                              ? widget.data["donhang_hoanthanh"]
                              : 0),
                    ],
                    xValueMapper: (ChartDataP data, _) => data.x,
                    yValueMapper: (ChartDataP data, _) => data.y,
                    // name: 'Data',
                    dataLabelSettings: DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class ChartDataP {
  ChartDataP(this.x, this.y, [this.color]);
  final String x;
  final double y;
  final Color? color;
}

class OverviewDataBox extends StatefulWidget {
  final String titleBox;
  final int dataBox;
  final IconData iconBox;
  final Color colorIconBox;
  final Color bGColorIconBox;
  final double sizeIconBox;

  const OverviewDataBox(
      {Key? key,
      required this.titleBox,
      required this.dataBox,
      required this.iconBox,
      required this.colorIconBox,
      required this.bGColorIconBox,
      required this.sizeIconBox})
      : super(key: key);

  @override
  State<OverviewDataBox> createState() => _OverviewDataBoxState();
}

class _OverviewDataBoxState extends State<OverviewDataBox> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.25,
            height: heightBox,
            decoration: BoxDecoration(
              color: colorWhite,
              borderRadius: borderRadiusContainer,
              boxShadow: [boxShadowContainer],
              border: borderAllContainerBox,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: paddingLeftOverviewDataBox,
                      child: Container(
                        width: widthIconOverviewDataBox,
                        height: heightIconOverviewDataBox,
                        decoration: BoxDecoration(
                          color: widget.bGColorIconBox,
                          borderRadius: borderRadiusIconOverviewDataBox,
                        ),
                        child: Icon(
                          widget.iconBox,
                          // Icons.account_balance_wallet_outlined,
                          color: widget.colorIconBox,
                          size: widget.sizeIconBox,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: SizedBox(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.titleBox.toString(),
                              style: titleOverviewDataBox,
                              maxLines: 2,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              widget.dataBox.toString(),
                              style: dataOverviewDataBox,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class TabBarComfim extends StatefulWidget {
  List<dynamic> listXacNhan;
  List<dynamic> listDeNghi;
  TabBarComfim({required this.listXacNhan, required this.listDeNghi});

  @override
  State<TabBarComfim> createState() => _TabBarComfimState();
}

class _TabBarComfimState extends State<TabBarComfim> {
  @override
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: paddingBoxContainer,
      margin: marginTopBoxContainer,
      width: MediaQuery.of(context).size.width * 1,
      height: heightBoxContainer,
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: borderRadiusContainer,
        boxShadow: [boxShadowContainer],
        border: borderAllContainerBox,
      ),
      child: DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 40,
              // constraints: BoxConstraints.expand(height: 50),
              // padding: EdgeInsets.only(left: 20, right: 20),
              child: TabBar(
                // isScrollable: true,
                labelColor: Colors.black,
                indicatorColor: mainColorPage,
                tabs: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("XN thanh toán", style: titleWidgetBox),
                      (widget.listXacNhan.length > 0)
                          ? Icon(
                              Icons.notifications_active,
                              color: Colors.red,
                              size: 20,
                            )
                          : Row()
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("XN đề nghị TD", style: titleWidgetBox),
                      (widget.listDeNghi.length > 0)
                          ? Icon(
                              Icons.notifications_active,
                              color: Colors.red,
                              size: 20,
                            )
                          : Row()
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          for (int j = 0; j < widget.listXacNhan.length; j++)
                            Container(
                              padding: EdgeInsets.only(
                                top: 13,
                                bottom: 15,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: 1,
                                    color: Color(0xffC8C9CA),
                                  ),
                                ),
                              ),
                              child: InkWell(
                                // onHover: (value) => Colors.red,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      //Số thứ tự
                                      child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: Color(0xffF577C74),
                                            borderRadius: BorderRadius.all(
                                              Radius.elliptical(10, 10),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '#${j + 1}',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15),
                                            ),
                                          )),
                                    ),
                                    SizedBox(width: 20),
                                    Flexible(
                                      child: Text(
                                        "",
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: (() {}),
                              ),
                            ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 18),
                        child: TextButton(
                          onPressed: () {
                            // Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/ho-so-nhan-su");
                          },
                          child: Text(
                            'Xem tất cả các thông báo ',
                            style: TextStyle(
                              color: Color(0xffF577C74),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          SizedBox(height: 30),
                          for (int j = 0; j < widget.listDeNghi.length; j++)
                            Container(
                              padding: EdgeInsets.only(
                                top: 13,
                                bottom: 15,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: 1,
                                    color: Color(0xffC8C9CA),
                                  ),
                                ),
                              ),
                              child: InkWell(
                                // onHover: (value) => Colors.red,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      //Số thứ tự
                                      child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: Color(0xffF577C74),
                                            borderRadius: BorderRadius.all(
                                              Radius.elliptical(10, 10),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '#${j + 1}',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15),
                                            ),
                                          )),
                                    ),
                                    SizedBox(width: 20),
                                    Flexible(
                                      child: Text(
                                          "${widget.listDeNghi[j].title}",
                                          softWrap: false,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Provider.of<NavigationModel>(context,
                                          listen: false)
                                      .add(
                                          pageUrl:
                                              "/view-dntd/${widget.listDeNghi[j].id}");
                                },
                              ),
                            ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 18),
                        child: TextButton(
                          onPressed: () {
                            Provider.of<NavigationModel>(context, listen: false)
                                .add(pageUrl: "/de-nghi-tuyen-dung-chuc-nang");
                          },
                          child: Text(
                            'Xem tất cả các thông báo ',
                            style: TextStyle(
                              color: Color(0xffF577C74),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
