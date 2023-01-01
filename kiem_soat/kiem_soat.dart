import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/model/model.dart';
import 'package:gentelella_flutter/common/style.dart';
import 'package:gentelella_flutter/widgets/ui/navigation.dart';
import 'package:provider/provider.dart';

import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../api.dart';
import '../../../common/widgets_form.dart';
import '../source_information/thong_tin_nguon.dart';

class KiemSoat extends StatefulWidget {
  const KiemSoat({Key? key}) : super(key: key);

  @override
  State<KiemSoat> createState() => _KiemSoatState();
}

class _KiemSoatState extends State<KiemSoat> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: KiemSoatBody());
  }
}

class KiemSoatBody extends StatefulWidget {
  const KiemSoatBody({Key? key}) : super(key: key);

  @override
  State<KiemSoatBody> createState() => _KiemSoatBodyState();
}

int countTrainee = 0;
int countEmployee = 0;
int countFile = 0;

class _KiemSoatBodyState extends State<KiemSoatBody> {
  // vi phạm
  late Future futureListVP;
  var listVP = [];
  Future getDSVP() async {
    Future.delayed(const Duration(seconds: 5));
    var response;
    response = await httpGet("/api/tts-thongtindaotao-vipham/get/page?sort=violateDate,asc", context);
    if (response.containsKey("body")) {
      setState(() {
        listVP = jsonDecode(response["body"])['content'];
      });
    }
    return listVP;
  }

  late Future futureListTBND;
  var listStopProcessing;
  Future getTBND() async {
    Future.delayed(const Duration(seconds: 5));
    var response;
    response = await httpGet("/api/tts-donhang-dungxuly/get/page?size=5&sort=createdDate,desc&filter=approvalType:0", context);
    if (response.containsKey("body")) {
      setState(() {
        listStopProcessing = jsonDecode(response["body"]);
      });
    }
    return listStopProcessing;
  }

  late Future futureListTBDH;
  var listTBDH;
  Future getTBDH() async {
    Future.delayed(const Duration(seconds: 5));
    var response;
    response = await httpGet("/api/donhang/get/page?size=2&sort=modifiedDate,asc&filter=stopProcessing:1", context);
    if (response.containsKey("body")) {
      setState(() {
        listTBDH = jsonDecode(response["body"]);
      });
    }
    return listTBDH;
  }

  List<int> _listMonthTrainees = [];
  List<int> _listMonthCollaborator = [];
  List<ChartDataByMonth> chartDataTrainees = [];
  List<ChartDataByMonth> chartDataCollaborator = [];
  List<ChartDataByMonth> listMonth = [];
  List<ChartDataByMonth> chartData = [];

  getNVVP() async {
    Future.delayed(const Duration(seconds: 5));
    List<ChartDataByMonth> listMonthTrainees = [];
    var date = new DateTime.now();
    var month = "";
    for (int i = 1; i <= date.month; i++) {
      if (i < 10) {
        month = "0" + i.toString();
      }
      var dateFrom = "01-$month-${date.year}";
      var dateTo = "${getDateInMonth(i, date.year)}-$month-${date.year}";
      var response =
          await httpGet("/api/quyetdinh-xuphat-chitiet/get/page?filter=quyetdinh.decisionDate>:'$dateFrom' AND  quyetdinh.decisionDate<:'$dateTo' AND nguoidung.isAam:1", context);
      var body = jsonDecode(response['body']);

      ChartDataByMonth item = new ChartDataByMonth("Tháng $i", double.tryParse(body["totalElements"].toString()), i);
      listMonthTrainees.add(item);
    }
    setState(() {
      chartDataTrainees = listMonthTrainees;
    });
  }

  getTTSVP() async {
    List<ChartDataByMonth> listMonthCollaborator = [];
    var date = new DateTime.now();
    var month = "";
    for (int i = 1; i <= date.month; i++) {
      if (i < 10) {
        month = "0" + i.toString();
      }
      var dateFrom = "01-$month-${date.year}";
      var dateTo = "${getDateInMonth(i, date.year)}-$month-${date.year}";
      var response =
          await httpGet("/api/quyetdinh-xuphat-chitiet/get/page?filter=quyetdinh.decisionDate>:'$dateFrom' AND  quyetdinh.decisionDate<:'$dateTo' and nguoidung.isTts:1", context);
      var body = jsonDecode(response['body']);
      ChartDataByMonth item = new ChartDataByMonth("Tháng $i", double.tryParse(body["totalElements"].toString()), i);
      listMonthCollaborator.add(item);
    }
    setState(() {
      chartDataCollaborator = listMonthCollaborator;
    });
  }

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

  getCountFile() async {
    var response = await httpGet("/api/nguoidung/get/count?filter=isTts:1 and ttsStatusId:3 and stopProcessing:0", context);

    if (response.containsKey("body")) {
      setState(() {
        countFile = jsonDecode(response["body"]);
      });
    }
  }

  getCountTrainee() async {
    //var countTrainee;
    var response = await httpGet("/api/nguoidung/get/count?filter=isTts:1 and stopProcessing:0", context);
    if (response.containsKey("body")) {
      setState(() {
        countTrainee = jsonDecode(response["body"]);
      });
    }
  }

  getCountEmployee() async {
    //var countEmployee;
    var response = await httpGet("/api/nguoidung/get/count?filter=isAam:1", context);
    if (response.containsKey("body")) {
      setState(() {
        countEmployee = jsonDecode(response["body"]);
      });
    }
  }

  callApi() async {
    await getCountFile();
    await getCountTrainee();
    await getCountEmployee();
    await getNVVP();
    await getTTSVP();
  }

  void initState() {
    super.initState();
    futureListVP = getDSVP();
    futureListTBND = getTBND();
    futureListTBDH = getTBDH();

    callApi();
  }

  void _showXuPhat(idSelect, navigationModel) async {
    var listVP1;

    // Future.delayed(const Duration(seconds: 5));
    var response;
    response = await httpGet("/api/tts-thongtindaotao-vipham/get/$idSelect", context);
    if (response.containsKey("body")) {
      setState(() {
        listVP1 = jsonDecode(response["body"]);
      });
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              children: [
                Image.asset(
                  "assets/images/logoAAM.png",
                  width: 30,
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: Text('Xử phạt'),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.close)),
                  ),
                )
              ],
            ),
            content: Container(
              height: 150,
              width: 400,
              child: Column(
                children: [
                  Text('${listVP1['quydinh']["ruleName"]}'),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: Divider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                  ),
                  if (listVP1['content'] != 0)
                    // for (int j = 0; j < listVP['content'].length; j++)
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Quyết định xử phạt ' +
                            ("TTS ") +
                            listVP1['thuctapsinh']['fullName'].toString() +
                            " " +
                            "(" +
                            listVP1['thuctapsinh']['userCode'].toString() +
                            ") " +
                            listVP1['violateContent']))
                ],
              ),
            ),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Divider(
                  thickness: 1,
                  color: Colors.grey,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 120,
                    height: 40,
                    child: OutlinedButton(
                        style: ElevatedButton.styleFrom(
                          onPrimary: Color(0xffF77919), // Background color
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Hủy')),
                  ),
                  Consumer<NavigationModel>(
                      builder: (context, navigationModel, child) => Container(
                            width: 120,
                            height: 40,
                            padding: EdgeInsets.only(left: 20),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xffF77919),
                                onPrimary: Colors.white, // Background color
                              ),
                              onPressed: () {
                                navigationModel.add(pageUrl: "/quyet-dinh-xu-phat/add");

                                // Navigator.pop(context);
                                // setState(() {});
                              },
                              child: Text('Xử Phạt'),
                            ),
                          ))
                ],
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: userRule('/kiem-soat', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return Consumer<NavigationModel>(
            builder: (context, navigationModel, child) => Scaffold(
              body: ListView(
                children: [
                  TitlePage(
                    listPreTitle: [],
                    content: "Dashboard",
                  ),
                  Container(
                    color: backgroundPage,
                    padding: EdgeInsets.symmetric(vertical: verticalPaddingPage, horizontal: horizontalPaddingPage),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            //Các khối dữ liệu tổng quan ở trên đầu trang
                            OverviewDataBox(
                              bGColorIconBox: colorBGIconOverviewDataBox1,
                              dataBox: countFile,
                              titleBox: 'Hồ sơ mới khai form',
                              colorIconBox: colorWhite,
                              iconBox: Icons.account_box,
                              sizeIconBox: sizeIconOverviewDataBox,
                              function: () {
                                navigationModel.add(pageUrl: "/quan-ly-thong-tin-thuc-tap-sinh");
                              },
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            OverviewDataBox(
                              bGColorIconBox: colorBGIconOverviewDataBox2,
                              dataBox: countTrainee,
                              titleBox: 'Số TTS',
                              colorIconBox: colorWhite,
                              iconBox: Icons.account_balance_wallet_sharp,
                              sizeIconBox: sizeIconOverviewDataBox,
                              function: () {
                                navigationModel.add(pageUrl: "/quan-ly-thong-tin-thuc-tap-sinh");
                              },
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            OverviewDataBox(
                              bGColorIconBox: colorBGIconOverviewDataBox3,
                              dataBox: countEmployee,
                              titleBox: 'Nhân viên',
                              colorIconBox: colorWhite,
                              iconBox: Icons.account_tree_outlined,
                              sizeIconBox: sizeIconOverviewDataBox,
                              function: () {
                                navigationModel.add(pageUrl: "/ho-so-nhan-su");
                              },
                            ),
                          ],
                        ),
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
                                          'Thông báo',
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
                                        FutureBuilder<dynamic>(
                                          future: futureListTBND,
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              int i = 1;
                                              if (listStopProcessing['content'].length < 1) {
                                                return Center(
                                                  child: Text('Chưa có dữ liệu'),
                                                );
                                              } else
                                                return Column(
                                                  children: [
                                                    for (var row in listStopProcessing['content'])
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
                                                                      // border: Border.all(
                                                                      //     color: Colors.blue,
                                                                      //     width: 1),
                                                                      borderRadius: BorderRadius.all(
                                                                        Radius.elliptical(10, 10),
                                                                      ),
                                                                    ),
                                                                    child: Center(
                                                                      child: Text(
                                                                        "#${i++}",
                                                                        textAlign: TextAlign.center,
                                                                        style: TextStyle(color: Colors.white, fontSize: 15),
                                                                      ),
                                                                    )),
                                                              ),
                                                              SizedBox(width: 20),
                                                              Flexible(
                                                                child: Text(
                                                                  row['itemType'] == 0
                                                                      ? "Thực tập sinh ${row['nguoidung']['fullName']} đã bị tạm dừng xử lý ngày ${dateReverse(displayDateTimeStamp(row['createdDate']))}"
                                                                      : "Đơn hàng ${row['donhang']['orderName']} đã bị tạm dừng xử lý ngày ${dateReverse(displayDateTimeStamp(row['createdDate']))}",
                                                                  style: textButtonTable,
                                                                  maxLines: 2,
                                                                  softWrap: false,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          onTap: (() {
                                                            (listStopProcessing['totalElements'] > 0)
                                                                ? navigationModel.add(pageUrl: "/view-thong-tin-thuc-tap-sinh/${row['nguoidung']["id"]}")
                                                                : navigationModel.add(pageUrl: "kiem-soat");
                                                            setState(() {});
                                                          }),
                                                        ),
                                                      ),
                                                  ],
                                                );
                                            } else if (snapshot.hasError) {
                                              return Text('${snapshot.error}');
                                            }
                                            return const Center(child: CircularProgressIndicator());
                                          },
                                        ),
                                      ],
                                    ),

                                    Container(
                                      margin: EdgeInsets.only(top: 18),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              navigationModel.add(pageUrl: "/xac-nhan-dung-xu-ly");
                                            },
                                            child: Text(
                                              'Xem thêm >>',
                                              style: TextStyle(
                                                color: Color(0xffF577C74),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                                          'Vi phạm đào tạo',
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
                                    FutureBuilder(
                                      future: futureListVP,
                                      builder: (context, snapshot) {
                                        print(listVP.length);
                                        if (snapshot.hasData) {
                                          if (listVP.length < 1) {
                                            return Center(
                                              child: Text('Không có dữ liệu'),
                                            );
                                          } else
                                            return Container(
                                              height: 320,
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    for (int j = 0; j < listVP.length; j++)
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
                                                                      // border: Border.all(
                                                                      //     color: Colors.blue,
                                                                      //     width: 1),
                                                                      borderRadius: BorderRadius.all(
                                                                        Radius.elliptical(10, 10),
                                                                      ),
                                                                    ),
                                                                    child: Center(
                                                                      child: Text(
                                                                        "#${j + 1}",
                                                                        textAlign: TextAlign.center,
                                                                        style: TextStyle(color: Colors.white, fontSize: 15),
                                                                      ),
                                                                    )),
                                                              ),
                                                              SizedBox(width: 20),
                                                              Flexible(
                                                                child: Text(
                                                                  listVP[j]['thuctapsinh']['fullName'].toString() +
                                                                      " " +
                                                                      "(" +
                                                                      listVP[j]['thuctapsinh']['userCode'].toString() +
                                                                      ")",
                                                                  style: textButtonTable,
                                                                  maxLines: 2,
                                                                  softWrap: false,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          onTap: (() {
                                                            // Provider.of<NavigationModel>(
                                                            //         context,
                                                            //         listen: false)
                                                            //     .add(
                                                            //         pageUrl:
                                                            //             "/view-thong-tin-thuc-tap-sinh/${listVP[j]['ttsId']}");
                                                            // setState(() {
                                                            _showXuPhat(listVP[j]['id'], navigationModel);
                                                            //   // print('id cua nv tts');
                                                            //   // print(listVP['content'][j]['id']);
                                                            // });
                                                          }),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            );
                                        } else if (snapshot.hasError) {
                                          return Text('${snapshot.error}');
                                        }
                                        return const Center(child: CircularProgressIndicator());
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          child: Column(
                            children: [
                              LineGraph(
                                listMonthTrainees: _listMonthTrainees,
                                chartDataTrainees: chartDataTrainees,
                                chartDataCollaborator: chartDataCollaborator,
                                listMonthCollaborator: _listMonthCollaborator,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Footer()
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
    );
  }
}

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
                  'Số lượng nhân viên và TTS vi phạm',
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
              child: SfCartesianChart(
                legend: Legend(isVisible: true),
                primaryXAxis: CategoryAxis(),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <ChartSeries>[
                  LineSeries<ChartDataByMonth, String>(
                    name: 'Nhân viên vi phạm',
                    dataSource: chartDataTrainees!,
                    xValueMapper: (ChartDataByMonth data, _) => data.x,
                    yValueMapper: (ChartDataByMonth data, _) => data.y,
                    dataLabelSettings: DataLabelSettings(isVisible: true),
                  ),
                  LineSeries<ChartDataByMonth, String>(
                    name: 'TTS vi phạm',
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
