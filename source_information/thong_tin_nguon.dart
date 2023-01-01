import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/model/model.dart';
import 'package:gentelella_flutter/widgets/ui/navigation.dart';
import 'package:gentelella_flutter/widgets/ui/source_information/common_ource_information/constant.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../api.dart';
import '../../../common/style.dart';
import '../../../common/widgets_form.dart';
import '../../../model/source_information/test_schedule/test_schedule.dart';
import 'package:http/http.dart' as http;

import 'setting-data/tts.dart';

final double heightBox = 100;

class ThongTinNguon extends StatelessWidget {
  const ThongTinNguon({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: ThongTinNguonBody());
  }
}

class ThongTinNguonBody extends StatefulWidget {
  const ThongTinNguonBody({Key? key}) : super(key: key);

  @override
  State<ThongTinNguonBody> createState() => _ThongTinNguonBodyState();
}

class _ThongTinNguonBodyState extends State<ThongTinNguonBody> {
  int promotions = 0;
  int countCollaborator = 0;
  int collaborators = 0;
  // int countInterestedTrainee = -1; //--Đang quan tâm
  var listUserResult = {};
  List<TestSchedule> listNotifyTestTchedule = [];
  //Biểu đồ đường tròn
  late TooltipBehavior _tooltipBehavior;
  double countDeclaredTrainee = 0; //--Đã xuất cảnh
  double countadvisoryTrainee = 0; //--Đã tư vấn
  double countInterestedTrainee = 0; //--Đang quan tâm
  double countDeclaredFormTrainee = 0; //--Đã khai form
  double countBeenRecruitedTrainee = 0; //--Đã trúng tuyển

  bool daLoadXong = false;

  //----------------Khai báo biểu đồ đường------------------------
  List<int> _listMonthTrainees = [];
  List<int> _listMonthCollaborator = [];
  List<ChartDataByMonth> chartDataTrainees = [];
  List<ChartDataByMonth> chartDataCollaborator = [];
  //----------------------------------------
  int getDateInMonth(int month, int year) {
    int dateOfMonth = 30;
    if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
      dateOfMonth = 31;
    } else if (month == 2) {
      dateOfMonth = 28;
      if (year / 4 == 0) {
        dateOfMonth = 29;
      }
    }
    return dateOfMonth;
  }

//-------------------Api biểu đồ đường----------------------------
  // Biến này kiểm tra xem biểu đồ số lượng TTS và CTV đã load xong hay chưa
  Future ttsAndCttv() async {
    await getLineChartOfTrainees();
    await getCollaboratorNumberLineChart();
  }

//--Biểu đồ số lượng thực tập sinh--
  Future getLineChartOfTrainees() async {
    try {
      List<ChartDataByMonth> listMonthTrainees = [];
      var date = new DateTime.now();
      var month = "";
      for (int i = 1; i <= date.month; i++) {
        try {
          if (i < 10) {
            month = "0" + i.toString();
          } else {
            month = i.toString();
          }
          var dateFrom = "01-$month-${date.year}";
          var dateTo = "${getDateInMonth(i, date.year)}-$month-${date.year}";
          var response =
              await httpGet("/api/nguoidung/get/count?filter=isTts:1 AND active:1 AND createdDate>:'$dateFrom' AND  createdDate<:'$dateTo'", context);
          var body = jsonDecode(response['body']);

          ChartDataByMonth item = new ChartDataByMonth("Tháng $i", body, i);
          listMonthTrainees.add(item);
        } catch (e) {
          print(e);
        }
      }
      setState(() {
        chartDataTrainees = listMonthTrainees;
      });
    } catch (e) {
      print("Ngoại lệ tổng" + e.toString());
    }
  }

  //--Biểu đồ số lượng cộng tác viên--
  Future getCollaboratorNumberLineChart() async {
    try {
      List<ChartDataByMonth> listMonthCollaborator = [];
      var date = new DateTime.now();
      var month = "";
      for (int i = 1; i <= date.month; i++) {
        try {
          if (i < 10) {
            month = "0" + i.toString();
          } else {
            month = i.toString();
          }
          var dateFrom = "01-$month-${date.year}";
          var dateTo = "${getDateInMonth(i, date.year)}-$month-${date.year}";
          var response = await httpGet(
              "/api/nguoidung/get/count?filter=isCtv:1 AND active:1  AND createdDate>:'$dateFrom' AND  createdDate<:'$dateTo'", context);
          var body = jsonDecode(response['body']);

          ChartDataByMonth item = new ChartDataByMonth("Tháng $i", body, i);
          listMonthCollaborator.add(item);
        } catch (e) {
          print(e);
        }
      }
      setState(() {
        chartDataCollaborator = listMonthCollaborator;
      });
    } catch (e) {
      print("Ngoại lệ tổng" + e.toString());
    }
  }

  List<InformationTTS> listTTS = [];
  late Future<List<InformationTTS>> futureListTTS;
  //--Cộng tác viên mới--
  Future<List<InformationTTS>> getCollaborators() async {
    var response = await httpGet(API_NGUOI_DUNG + "page=0&size=5&sort=createdDate,desc&filter=isCtv:1 and active:1", context);
    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        content = body['content'];
        listTTS = content.map((e) {
          return InformationTTS.fromJson(e);
        }).toList();
      });
    }
    return content.map((e) {
      return InformationTTS.fromJson(e);
    }).toList();
  }

  //--api thông báo lịch thi tuyển
  List<dynamic> listNotifyTestTchedule1 = [];
  Future getNotifyTestTchedule() async {
    var response = await httpGet("/api/lichthituyen/get/page?page=0&size=5&sort=createdDate,desc", context);
    if (response.containsKey("body")) {
      var body = jsonDecode(response['body']);
      var content = body['content'];

      List<dynamic> item = [];
      for (var element in content) {
        item = [];
        item.add(element['id']);
        item.add((element['donhang'] != null) ? (element['donhang']['orderName']) : "");
        item.add((element['examDate'] != null) ? (DateTime.parse(element['examDate'])) : null);

        listNotifyTestTchedule1.add(item);
      }
    } else {
      print("Không có dữ liệu");
    }
  }

  callApiDasboard() async {
    var response = await httpGet("/api/hethong-chung/get/thongke", context);
    var content = jsonDecode(response["body"]);
    print(content);
    if (response.containsKey("body")) {
      //Đang quan tâm
      countInterestedTrainee = double.tryParse(content["tts_dangquantam"].toString())!;
      //Đã trúng tuyển
      countBeenRecruitedTrainee = double.tryParse(content["tts_datrungtuyen"].toString())!;
      //Đã tư vấn ( thiếu )
      countadvisoryTrainee = double.tryParse(content["tts_datuvan"].toString())!;
      //Đã khai form
      countDeclaredFormTrainee = double.tryParse(content["tts_dakhaiform"].toString())!;
      //Đã xuất cảnh
      countDeclaredTrainee = double.tryParse(content["tts_daxuatcanh"].toString())!;
      //Số lượng cộng tác viên
      countCollaborator = int.parse(content["tong_ctv"].toString());
      //Số lượng chương trình khuyến mãi
      promotions = int.parse(content["tong_khuyenmai"].toString());
    } else {
      print("object");
    }
  }

  callCTV() async {
    futureListTTS = getCollaborators();
  }

  callApi() async {
    await callApiDasboard();
    await ttsAndCttv();
    await getNotifyTestTchedule();
    await callCTV();
    setState(() {
      daLoadXong = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(enable: true);
    callApi();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: userRule('/thong-tin-nguon', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return daLoadXong
              ? Consumer2<NavigationModel, SecurityModel>(
                  builder: (context, navigationModel, user, child) => ListView(
                    controller: ScrollController(),
                    children: [
                      //---------- Breadcrumbs----------------
                      TitlePageWidget(
                        textSpanWidget: [
                          TextSpan(
                            text: 'Dashboard',
                            style: titlePage,
                            mouseCursor: MaterialStateMouseCursor.clickable,
                          ),
                        ],
                        widgetBoxRight: [Container()],
                      ),
                      //----------end Breadcrumbs----------------
                      Container(
                        color: backgroundPage,
                        padding: EdgeInsets.symmetric(vertical: verticalPaddingPage, horizontal: horizontalPaddingPage),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            (user.userLoginCurren["departId"] == 3 || user.userLoginCurren["departId"] == 1 || user.userLoginCurren["departId"] == 2)
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      //Các khối dữ liệu tổng quan ở trên đầu trang
                                      OverviewDataBox(
                                        function: () {
                                          Provider.of<NavigationModel>(context, listen: false)
                                              .add(pageUrl: "/quan-ly-thong-tin-thuc-tap-sinh/${"1"}");
                                          // Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/cap-nhat-thuc-tap-sinh/${listTTS[i]["id"]}");
                                        },
                                        bGColorIconBox: colorBGIconOverviewDataBox1,
                                        dataBox: countInterestedTrainee,
                                        titleBox: 'TTS Đang quan tâm',
                                        colorIconBox: colorWhite,
                                        iconBox: Icons.account_box,
                                        sizeIconBox: sizeIconOverviewDataBox,
                                      ),
                                      SizedBox(
                                        width: 30,
                                      ),
                                      OverviewDataBox(
                                        function: () {
                                          Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/quan-ly-cong-tac-vien");
                                        },
                                        bGColorIconBox: colorBGIconOverviewDataBox3,
                                        dataBox: countCollaborator,
                                        titleBox: 'Số lượng cộng tác viên',
                                        colorIconBox: colorWhite,
                                        iconBox: Icons.account_tree_outlined,
                                        sizeIconBox: sizeIconOverviewDataBox,
                                      ),

                                      SizedBox(
                                        width: 30,
                                      ),
                                      OverviewDataBox(
                                        function: () {
                                          Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/quan-ly-chuong-trinh-khuyen-mai");
                                        },
                                        bGColorIconBox: colorBGIconOverviewDataBox2,
                                        dataBox: promotions,
                                        titleBox: 'Chương trình khuyến mãi',
                                        colorIconBox: colorWhite,
                                        iconBox: Icons.account_balance_wallet_sharp,
                                        sizeIconBox: sizeIconOverviewDataBox,
                                      ),
                                    ],
                                  )
                                : Container(),
                            Row(
                              //biểu đồ
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Container(
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
                                              Icon(
                                                Icons.more_horiz,
                                                color: colorIconTitleBox,
                                                size: sizeIconTitleBox,
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
                                          Expanded(
                                            child: SfCircularChart(
                                              tooltipBehavior: _tooltipBehavior,
                                              legend: Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
                                              // title: ChartTitle(text: 'Trạng thái TTS', alignment: Alignment.topLeft),
                                              series: <CircularSeries>[
                                                // Render pie chart
                                                PieSeries<ChartDataP, String>(
                                                  enableTooltip: true,
                                                  dataSource: [
                                                    // Bind data source
                                                    ChartDataP('Đang quan tâm', countInterestedTrainee),
                                                    ChartDataP('Đã trúng tuyển', countBeenRecruitedTrainee),
                                                    ChartDataP('Đã tư vấn', countadvisoryTrainee),
                                                    ChartDataP('Đã khai form', countDeclaredFormTrainee),
                                                    ChartDataP('Đã xuất cảnh', countDeclaredTrainee)
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
                                      )),
                                  // child: PieChartDashboardTrainee(),
                                ),
                                //thông báo
                                Expanded(
                                  flex: 5,
                                  child: Container(
                                    padding: paddingBoxContainer,
                                    margin: marginTopLeftContainer,
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
                                              'Thông báo lịch thi tuyển',
                                              style: titleBox,
                                            ),
                                            Icon(
                                              Icons.more_horiz,
                                              color: colorIconTitleBox,
                                              size: sizeIconTitleBox,
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
                                            for (int i = 0; i < listNotifyTestTchedule1.length; i++)
                                              getRule(listRule.data, Role.Xem, context) == true
                                                  ? Container(
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
                                                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 10),
                                                              //Số thứ tự
                                                              child: Container(
                                                                  width: 30,
                                                                  height: 30,
                                                                  decoration: BoxDecoration(
                                                                    color: Color(0xffF577C74),
                                                                    // border: Border.all(
                                                                    //     color: Colors.blue,
                                                                    //     width: 1),
                                                                    borderRadius: BorderRadius.all(
                                                                      Radius.elliptical(10, 10),
                                                                    ),
                                                                  ),
                                                                  child: Center(
                                                                    child: Text(
                                                                      ("${i + 1}"),
                                                                      textAlign: TextAlign.center,
                                                                      style: TextStyle(color: Colors.white, fontSize: 15),
                                                                    ),
                                                                  )),
                                                            ),
                                                            SizedBox(width: 20),
                                                            Flexible(
                                                              // decoration: BoxDecoration(color: Colors.red),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Flexible(
                                                                    child: Text(
                                                                      "${listNotifyTestTchedule1[i][1]}",
                                                                      // maxLines: 2,
                                                                      softWrap: true,
                                                                      overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Text(
                                                                    (listNotifyTestTchedule1[i][2] != null)
                                                                        ? "${DateFormat('dd-MM-yyyy').format(listNotifyTestTchedule1[i][2])}"
                                                                        : "",
                                                                    // maxLines: 2,
                                                                    softWrap: false,
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        onTap: (() {
                                                          Provider.of<NavigationModel>(context, listen: false)
                                                              .add(pageUrl: '/xem-chi-tiet-lich-thi-tuyen/${listNotifyTestTchedule1[i][0]}');
                                                        }),
                                                      ),
                                                    )
                                                  : Container(),
                                            getRule(listRule.data, Role.Xem, context) == true
                                                ? Container(
                                                    margin: EdgeInsets.only(top: 18),
                                                    child: TextButton(
                                                      onPressed: () {
                                                        Provider.of<NavigationModel>(context, listen: false).add(pageUrl: '/lich-thi-tuyen');
                                                      },
                                                      child: Text(
                                                        'Xem tất cả các thông báo ',
                                                        style: TextStyle(
                                                          color: Color(0xffF577C74),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : Container(),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            (user.userLoginCurren["departId"] == 3 || user.userLoginCurren["departId"] == 1 || user.userLoginCurren["departId"] == 2)
                                ? Row(
                                    children: [
                                      Expanded(
                                          flex: 5,
                                          //--Biểu đồ đường--
                                          child: LineGraph(
                                            listMonthTrainees: _listMonthTrainees,
                                            chartDataTrainees: chartDataTrainees,
                                            chartDataCollaborator: chartDataCollaborator,
                                            listMonthCollaborator: _listMonthCollaborator,
                                          )),
                                      // thông báo
                                      Expanded(
                                        flex: 4,
                                        child: FutureBuilder<List<InformationTTS>>(
                                          future: futureListTTS,
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              return Container(
                                                margin: marginTopLeftContainer,
                                                decoration: BoxDecoration(
                                                  color: colorWhite,
                                                  borderRadius: borderRadiusContainer,
                                                  boxShadow: [boxShadowContainer],
                                                  border: borderAllContainerBox,
                                                ),
                                                padding: paddingBoxContainer,
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(
                                                          'Cộng tác viên mới',
                                                          style: titleBox,
                                                        ),
                                                        Icon(
                                                          Icons.more_horiz,
                                                          color: colorIconTitleBox,
                                                          size: sizeIconTitleBox,
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
                                                    Container(
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: DataTable(
                                                                  columnSpacing: 3,
                                                                  dataTextStyle: const TextStyle(
                                                                      color: Color(0xff313131), fontSize: 14, fontWeight: FontWeight.w500),
                                                                  showBottomBorder: true,
                                                                  dataRowHeight: 50,
                                                                  showCheckboxColumn: true,
                                                                  dataRowColor:
                                                                      MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                                                                    if (states.contains(MaterialState.selected)) {
                                                                      return MaterialStateColor.resolveWith((states) => const Color(0xffeef3ff));
                                                                    }
                                                                    return MaterialStateColor.resolveWith(
                                                                        (states) => Colors.white); // Use the default value.
                                                                  }),
                                                                  // showCheckboxColumn: true,
                                                                  // columnSpacing: 20,
                                                                  horizontalMargin: 10,
                                                                  // dataRowHeight: 60,
                                                                  columns: [
                                                                    DataColumn(label: Text('STT', style: titleTableData)),
                                                                    DataColumn(
                                                                        label: Container(
                                                                            child: Expanded(
                                                                                child: Text(
                                                                      'Tên CTV',
                                                                      style: titleTableData,
                                                                      maxLines: 2,
                                                                      softWrap: true,
                                                                      // overflow: TextOverflow.ellipsis,
                                                                    )))),
                                                                    DataColumn(
                                                                        label: Container(
                                                                            child: Expanded(
                                                                                child: Text(
                                                                      'Mã CTV',
                                                                      style: titleTableData,
                                                                      maxLines: 2,
                                                                      softWrap: true,
                                                                      // overflow: TextOverflow.ellipsis,
                                                                    )))),
                                                                  ],
                                                                  rows: <DataRow>[
                                                                    for (int i = 0; i < listTTS.length; i++)
                                                                      DataRow(
                                                                        cells: <DataCell>[
                                                                          DataCell(
                                                                            Container(
                                                                                width: 30,
                                                                                height: 30,
                                                                                decoration: BoxDecoration(
                                                                                  color: Color(0xffF577C74),
                                                                                  // border: Border.all(
                                                                                  //     color: Colors.blue,
                                                                                  //     width: 1),
                                                                                  borderRadius: BorderRadius.all(
                                                                                    Radius.elliptical(10, 10),
                                                                                  ),
                                                                                ),
                                                                                child: Center(
                                                                                  child: Text(
                                                                                    ("${i + 1}"),
                                                                                    textAlign: TextAlign.center,
                                                                                    style: TextStyle(color: Colors.white, fontSize: 15),
                                                                                  ),
                                                                                )),
                                                                          ),
                                                                          // Text("${i + 1}")),
                                                                          DataCell(
                                                                            Container(
                                                                                width: MediaQuery.of(context).size.width * 0.1,
                                                                                child: Text(listTTS[i].fullName ?? "", style: bangDuLieu)),
                                                                          ),
                                                                          DataCell(
                                                                            Container(
                                                                              width: MediaQuery.of(context).size.width * 0.09,
                                                                              child: Text(listTTS[i].userCode ?? "", style: bangDuLieu),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                        // selected: _selectedDataRow[i],
                                                                        // onSelectChanged:
                                                                        //     ((listTTS[i].stopProcessing! == 0 && listTTS[i].ttsStatusId != 13))
                                                                        //         ? (bool? selected) {
                                                                        //             setState(
                                                                        //               () {
                                                                        //                 _selectedDataRow[i] = selected!;

                                                                        //                 if (_selectedDataRow[i]) {
                                                                        //                   listObjectTTS.add(listTTS[i]);
                                                                        //                 } else {
                                                                        //                   listObjectTTS.remove(listTTS[i]);
                                                                        //                 }
                                                                        //               },
                                                                        //             );
                                                                        //           }
                                                                        //         : null,
                                                                      )
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Center(
                                                            child: Container(
                                                              margin: EdgeInsets.only(top: 18),
                                                              child: TextButton(
                                                                onPressed: () {
                                                                  // Provider.of<NavigationModel>(context, listen: false).add(pageUrl: '/lich-thi-tuyen');
                                                                  Provider.of<NavigationModel>(context, listen: false)
                                                                      .add(pageUrl: '/quan-ly-cong-tac-vien');
                                                                },
                                                                child: Text(
                                                                  'Xem thêm các cộng tác viên ',
                                                                  style: TextStyle(
                                                                    color: Color(0xffF577C74),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            } else if (snapshot.hasError) {
                                              return Center(
                                                  child: Padding(
                                                padding: EdgeInsets.all(250),
                                                child: Text('${snapshot.error}'),
                                              ));
                                              // Text('${snapshot.error}');
                                            }
                                            return Center(
                                                child: Padding(
                                              padding: EdgeInsets.all(250),
                                              child: CircularProgressIndicator(),
                                            ));
                                          },
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(),
                            Footer(paddingFooter: paddingBoxContainer, marginFooter: EdgeInsets.only(top: 30)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(),
                );
        } else if (listRule.hasError) {
          return Text('${listRule.error}');
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

//---------------------------------Biểu đồ đường-----------------
class ChartDataByMonth {
  ChartDataByMonth(this.x, this.y, this.month);
  final String? x;
  final int? month;
  final double? y;
}

// ignore: must_be_immutable
class LineGraph extends StatelessWidget {
  List<int>? listMonthTrainees;
  List<ChartDataByMonth>? chartDataTrainees;
  List<int>? listMonthCollaborator; //--Danh sách tháng của cộng tác viên--
  List<ChartDataByMonth>? chartDataCollaborator; //--Dữ liệu của biểu đồ đường--
  LineGraph({Key? key, this.listMonthTrainees, this.chartDataTrainees, this.chartDataCollaborator, this.listMonthCollaborator}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 1,
        margin: marginTopBoxContainer,
        decoration: BoxDecoration(
          color: colorWhite,
          borderRadius: borderRadiusContainer,
          boxShadow: [boxShadowContainer],
          border: borderAllContainerBox,
        ),
        padding: paddingBoxContainer,
        height: heightBoxContainer,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Số lượng cộng tác viên và thực tập sinh',
                  style: titleBox,
                ),
                Icon(
                  Icons.more_horiz,
                  color: colorIconTitleBox,
                  size: sizeIconTitleBox,
                ),
              ],
            ),
            Container(
              margin: marginTopBottomHorizontalLine,
              child: Divider(
                thickness: 1,
                color: ColorHorizontalLine,
              ),
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
                  LineSeries<ChartDataByMonth, String>(
                    name: 'Số lượng thực tập sinh',
                    dataSource: chartDataTrainees!,
                    xValueMapper: (ChartDataByMonth data, _) => data.x,
                    yValueMapper: (ChartDataByMonth data, _) => data.y,
                    dataLabelSettings: DataLabelSettings(isVisible: true),
                  ),
                  LineSeries<ChartDataByMonth, String>(
                    name: 'Số lượng cộng tác viên',
                    dataSource: chartDataCollaborator!,
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
//----------------------Kết thúc biểu đồ đường-----------------------------------

//--Biểu đồ hình tròn phần Dashboard thực tập sinh--
class CharDataDashboardTrainee {
  CharDataDashboardTrainee(this.x, this.y, [this.color]);
  final String x;
  final double y;
  final Color? color;
}

class ChartDataP {
  ChartDataP(this.x, this.y, [this.color]);
  final String x;
  final double y;
  final Color? color;
}

// ignore: must_be_immutable
class OverviewDataBox extends StatefulWidget {
  Function? function;
  final String titleBox;
  final dynamic dataBox;
  final IconData iconBox;
  final Color colorIconBox;
  final Color bGColorIconBox;
  final double sizeIconBox;

  OverviewDataBox(
      {Key? key,
      this.function,
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
    return Expanded(
      child: InkWell(
        onTap: () {
          if (widget.function != null) widget.function!();
        },
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
                  Expanded(
                    child: Padding(
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
                            widget.dataBox != -1
                                ? Text(
                                    widget.dataBox.toString(),
                                    style: dataOverviewDataBox,
                                  )
                                : const Center(
                                    child: CircularProgressIndicator(),
                                  )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
