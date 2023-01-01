import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
// import 'package:pie_chart/pie_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../../api.dart';
import '../../../../../common/style.dart';
import '../../../../../model/model.dart';
import "package:collection/collection.dart";

import '../../../../common/widgets_form.dart';
import '../../dashboard.dart';
import '../../navigation.dart';

final String urlThuongDonHang = "/thuong-don-hang";
final String urlDonHang = "ho-so-noi/don-hang";
final String urlThuongDonHangDangPhatHanh = "/don-hang-dang-phat-hanh";
int countOrder = 0;
int countRecomendedTrainee = 0;
double countNewlyCreateOrder = 0;
double countWaitingForHandleOrder = 0;
double countHandlingOrder = 0;
double countExitTrainee = 0;
double countTrainingTrainee = 0;
double countRecomendedTrainee1 = 0;
double countTookTheExam = 0;
double countWaitEntranceExam = 0;
var listNewlyCreateOrder = {};
var thongKe;

class InternalProfile extends StatefulWidget {
  const InternalProfile({Key? key}) : super(key: key);

  @override
  State<InternalProfile> createState() => _InternalProfileState();
}

class _InternalProfileState extends State<InternalProfile> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: InternalProfileBody());
  }
}

class InternalProfileBody extends StatefulWidget {
  const InternalProfileBody({Key? key}) : super(key: key);

  @override
  State<InternalProfileBody> createState() => _InternalProfileBodyState();
}

class _InternalProfileBodyState extends State<InternalProfileBody> {
  getCountOrder() async {
    var response = await httpGet("/api/donhang/get/count", context);
    if (response.containsKey("body")) {
      setState(() {
        countOrder = jsonDecode(response["body"]);
      });
    }
  }

  getCountRecomendedTrainee() async {
    var response = await httpGet(
        "/api/nguoidung/get/count?filter=isTts:1 and ttsStatusId:5", context);
    if (response.containsKey("body")) {
      setState(() {
        countRecomendedTrainee = jsonDecode(response["body"]);
        countRecomendedTrainee1 = jsonDecode(response["body"]);
      });
    }
  }

  getCountNewlyCreateOrder() async {
    var response =
        await httpGet("/api/donhang/get/count?filter=orderStatusId:1", context);
    if (response.containsKey("body")) {
      setState(() {
        countNewlyCreateOrder = jsonDecode(response['body']);
      });
    }
  }

  getCountWaitingForHandleOrder() async {
    var response =
        await httpGet("/api/donhang/get/count?filter=orderStatusId:2", context);
    if (response.containsKey("body")) {
      setState(() {
        countWaitingForHandleOrder = jsonDecode(response['body']);
      });
    }
  }

  getCountHandlingOrder() async {
    var response = await httpGet(
        "/api/nguoidung/get/count?filter=isTts:1 and ttsStatusId:2", //Đang xử lý
        context);
    if (response.containsKey("body")) {
      setState(() {
        countHandlingOrder = jsonDecode(response['body']);
      });
    }
  }

  getCountExitTrainee() async {
    var response = await httpGet(
        "/api/nguoidung/get/count?filter=isTts:1 and ttsStatusId:11", //Đã xuất cảnh
        context);
    if (response.containsKey("body")) {
      setState(() {
        countExitTrainee = jsonDecode(response["body"]);
      });
    }
  }

  getCountTrainingTrainee() async {
    var response = await httpGet(
        "/api/nguoidung/get/count?filter=isTts:1 and ttsStatusId:9", context);
    if (response.containsKey("body")) {
      setState(() {
        countTrainingTrainee = jsonDecode(response["body"]);
      });
    }
  }

  var listTrainee = {};
  var listTraineeTookTheExam;
  var listTraineeId = [];
  getListTraineeTookTheExam() async {
    var response = await httpGet("/api/tts-lichsu-thituyen/get/page", context);
    if (response.containsKey("body")) {
      setState(() {
        listTraineeTookTheExam = jsonDecode(response["body"])["content"];
      });
      listTrainee = groupBy(listTraineeTookTheExam, (dynamic obj) {
        return obj['ttsId'];
      });
      listTrainee.forEach((key, value) {
        if (key != null) listTraineeId.add(key);
      });
      countTookTheExam = double.parse(listTraineeId.length.toString());
    }
  }

  getCountWaitEntranceExam() async {
    var response =
        await httpGet("/api/nguoidung/get/count?filter=ttsStatusId:6", context);
    if (response.containsKey("body")) {
      setState(() {
        countWaitEntranceExam = jsonDecode(response["body"]);
      });
    }
  }

  late Future<dynamic> getOrderList;

  getNewlyCreateOrder() async {
    var response = await httpGet(
        "/api/donhang/get/page?page=0&size=5&createdDate:max(date)&filter=orderStatusId:2",
        context);
    if (response.containsKey("body")) {
      setState(() {
        listNewlyCreateOrder = jsonDecode(response["body"]);
      });
    }
    return 0;
  }

  late Future<dynamic> getThongKeFuture;
  getThongKe() async {
    var dashboard = await httpGet("/api/hethong-chung/get/thongke", context);
    if (dashboard.containsKey("body")) thongKe = jsonDecode(dashboard['body']);
    return 0;
  }

  callApi() async {
    getThongKeFuture = getThongKe();
    getOrderList = getNewlyCreateOrder();
    await getCountOrder();
    await getCountRecomendedTrainee();
    await getCountNewlyCreateOrder();
    await getCountWaitingForHandleOrder();
    await getCountHandlingOrder();
    await getCountTrainingTrainee();
    await getCountExitTrainee();
    await getListTraineeTookTheExam();
    await getCountWaitEntranceExam();
    await getNewlyCreateOrder();
  }

  @override
  void initState() {
    super.initState();
    callApi();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: userRule('/ho-so-noi', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return FutureBuilder<dynamic>(
            future: getThongKeFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView(
                  children: [
                    Consumer<NavigationModel>(
                      builder: (context, navigationModel, child) => Column(
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
                            child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.fromLTRB(25, 10, 0, 10),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Home',
                                        style:
                                            TextStyle(color: Color(0xff009C87)),
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.only(left: 5, right: 5),
                                        child: Text(
                                          '/',
                                          style: TextStyle(
                                            color: Color(0xffC8C9CA),
                                          ),
                                        ),
                                      ),
                                      Text('Hồ sơ nội',
                                          style: TextStyle(
                                              color: Color(0xff009C87))),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(25, 0, 0, 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text("Bảng thống kê nhanh",
                                          style: titlePage),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(25, 0, 25, 0),
                            width: MediaQuery.of(context).size.width * 1,
                            decoration: BoxDecoration(
                              color: backgroundPage,
                              boxShadow: [boxShadowContainer],
                              border: Border(
                                bottom: borderTitledPage,
                              ),
                            ),
                            child: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    color: backgroundPage,
                                    padding: EdgeInsets.symmetric(
                                        vertical: verticalPaddingPage,
                                        horizontal: horizontalPaddingPage),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          //Các khối dữ liệu tổng quan ở trên đầu trang
                                          Expanded(flex: 2, child: Container()),

                                          Expanded(
                                            flex: 5,
                                            child: InkWell(
                                              child: OverviewDataBox(
                                                bGColorIconBox:
                                                    colorBGIconOverviewDataBox1,
                                                dataBox: countOrder,
                                                titleBox: 'Đơn hàng',
                                                colorIconBox: colorWhite,
                                                iconBox: Icons.account_box,
                                                sizeIconBox:
                                                    sizeIconOverviewDataBox,
                                              ),
                                              onTap: () {
                                                navigationModel.add(
                                                    pageUrl: urlThuongDonHang);
                                              },
                                            ),
                                          ),

                                          Expanded(flex: 2, child: Container()),

                                          Expanded(
                                            flex: 5,
                                            child: InkWell(
                                              child: OverviewDataBox(
                                                bGColorIconBox:
                                                    colorBGIconOverviewDataBox3,
                                                dataBox:
                                                    thongKe['tts_datiencu'],
                                                titleBox:
                                                    'Tổng số TTS đã tiến cử ',
                                                colorIconBox: colorWhite,
                                                iconBox:
                                                    Icons.account_tree_outlined,
                                                sizeIconBox:
                                                    sizeIconOverviewDataBox,
                                              ),
                                              onTap: () {
                                                navigationModel.add(
                                                    pageUrl: urlThuongDonHang);
                                              },
                                            ),
                                          ),
                                          Expanded(flex: 2, child: Container()),
                                        ]),
                                  ),
                                  Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 5,
                                          // child: Container(
                                          //     padding: paddingBoxContainer,
                                          //     margin: EdgeInsets.fromLTRB(0, 30, 20, 0),
                                          //     width: MediaQuery.of(context).size.width * 1,
                                          //     height: heightBoxContainer,
                                          //     decoration: BoxDecoration(
                                          //       color: colorWhite,
                                          //       borderRadius: borderRadiusContainer,
                                          //       boxShadow: [boxShadowContainer],
                                          //       border: borderAllContainerBox,
                                          //     ),
                                          child: bieuDoTron(),
                                        ),
                                        Expanded(
                                          flex: 5,
                                          // child: Container(
                                          //     padding: paddingBoxContainer,
                                          //     margin: EdgeInsets.fromLTRB(0, 30, 20, 0),
                                          //     width: MediaQuery.of(context).size.width * 1,
                                          //     height: heightBoxContainer,
                                          //     decoration: BoxDecoration(
                                          //       color: colorWhite,
                                          //       borderRadius: borderRadiusContainer,
                                          //       boxShadow: [boxShadowContainer],
                                          //       border: borderAllContainerBox,
                                          //     ),
                                          child: bieuDoTron2(),
                                        ),
                                        Expanded(
                                          flex: 5,
                                          // child: Container(
                                          //     padding: paddingBoxContainer,
                                          //     margin: EdgeInsets.fromLTRB(0, 30, 20, 0),
                                          //     width: MediaQuery.of(context).size.width * 1,
                                          //     height: heightBoxContainer,
                                          //     decoration: BoxDecoration(
                                          //       color: colorWhite,
                                          //       borderRadius: borderRadiusContainer,
                                          //       boxShadow: [boxShadowContainer],
                                          //       border: borderAllContainerBox,
                                          //     ),
                                          child: bieuDoTron3(),
                                        )
                                        // Expanded(child: bieuDoTron2()),
                                        // Expanded(child: bieuDoTron3())
                                      ]),
                                  Container(
                                    margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                    decoration: BoxDecoration(
                                        color: colorWhite,
                                        border: borderAllContainerBox,
                                        borderRadius: borderRadiusContainer,
                                        boxShadow: [boxShadowContainer]),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                  margin: EdgeInsets.fromLTRB(
                                                      20, 20, 0, 0),
                                                  child: Text(
                                                      'Danh sách đơn hàng đang phát hành (${thongKe['donhang_choxuly']})',
                                                      style: titleBox
                                                      // textAlign: TextAlign.start,
                                                      )),
                                              Icon(
                                                Icons.more_horiz,
                                                color: colorIconTitleBox,
                                                size: sizeIconTitleBox,
                                              ),
                                            ]),
                                        Container(
                                          margin: marginTopBottomHorizontalLine,
                                          child: Divider(
                                            thickness: 1,
                                            color: ColorHorizontalLine,
                                          ),
                                        ),
                                        FutureBuilder<dynamic>(
                                          future: getOrderList,
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              return Container(
                                                padding:
                                                    EdgeInsets.only(left: 20),
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 10),
                                                child: Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Column(
                                                    children: [
                                                      if (listNewlyCreateOrder[
                                                                  'content']
                                                              .length >
                                                          0)
                                                        for (var row
                                                            in listNewlyCreateOrder[
                                                                'content'])
                                                          Container(
                                                              padding:
                                                                  EdgeInsets
                                                                      .only(
                                                                top: 13,
                                                                bottom: 15,
                                                              ),
                                                              decoration:
                                                                  BoxDecoration(
                                                                      border:
                                                                          Border(
                                                                              bottom:
                                                                                  BorderSide(
                                                                width: 1,
                                                                color: Color(
                                                                    0xffC8C9CA),
                                                              ))),
                                                              child: Consumer<
                                                                  NavigationModel>(
                                                                builder: (context,
                                                                        navigationModel,
                                                                        child) =>
                                                                    Container(
                                                                  child:
                                                                      InkWell(
                                                                    // onHover: (value) => Colors.red,
                                                                    child: Row(
                                                                      children: [
                                                                        Container(
                                                                          child: Padding(
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
                                                                                // child: Center(
                                                                                //   child: Text(
                                                                                //     '#${_dsDonHang[j].maDonHang.toString()}',
                                                                                //     // '${}',
                                                                                //     textAlign: TextAlign.center,
                                                                                //     style: TextStyle(
                                                                                //         color: Colors.white,
                                                                                //         fontSize: 15),
                                                                                //   ),
                                                                                // )),
                                                                              )),
                                                                        ),
                                                                        SizedBox(
                                                                            width:
                                                                                20),
                                                                        Flexible(
                                                                          child:
                                                                              Text(
                                                                            row["orderName"],
                                                                            maxLines:
                                                                                2,
                                                                            softWrap:
                                                                                false,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    onTap: (() {
                                                                      // navigationModel.add(pageUrl: "ho-so-noi/don-hang/id/${listNewlyCreateOrder["content"][j]["id"]}");
                                                                      navigationModel.add(
                                                                          pageUrl:
                                                                              "/xem-chi-tiet-don-hang/${row["id"]}");
                                                                    }),
                                                                  ),
                                                                ),
                                                                // TextButton.icon(
                                                                //   icon: Icon(
                                                                //     Icons.brightness_1,
                                                                //     size: 10,
                                                                //   ),
                                                                //   onPressed: () {},
                                                                //   label: Text(
                                                                //     _dsDonHang[j].maDonHang,
                                                                //     style: TextStyle(
                                                                //       fontSize: 15,
                                                                //       color: Colors.blue[400],
                                                                //       decoration: TextDecoration.underline,
                                                                //     ),
                                                                //   ),
                                                                // ),
                                                              ))
                                                      else
                                                        Center(
                                                          child: Container(
                                                            child: Text(
                                                                "Không có đơn hàng nào đang phát hành"),
                                                          ),
                                                        )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            } else if (snapshot.hasError) {
                                              return Text('${snapshot.error}');
                                            }

                                            // By default, show a loading spinner.
                                            return Center(
                                                child:
                                                    const CircularProgressIndicator());
                                          },
                                        ),
                                        Consumer<NavigationModel>(
                                          builder: (context, navigationModel,
                                                  child) =>
                                              Row(
                                            // crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              (getRule(listRule.data, Role.Xem,
                                                          context) ==
                                                      true)
                                                  ? TextButton(
                                                      onPressed: () {
                                                        print(
                                                            listNewlyCreateOrder[
                                                                    'content']
                                                                .length);
                                                        // navigationModel.add(
                                                        //     pageUrl:
                                                        //         urlThuongDonHangDangPhatHanh);
                                                      },
                                                      child: Text(
                                                        'Xem thêm >>',
                                                        style: TextStyle(
                                                          color:
                                                              Colors.blue[300],
                                                        ),
                                                      ))
                                                  : Container()
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Footer(marginFooter: EdgeInsets.only(top: 25), paddingFooter: EdgeInsets.all(15))
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return Center(child: const CircularProgressIndicator());
            },
          );
        } else if (listRule.hasError) {
          return Text('${listRule.error}');
        }

        // By default, show a loading spinner.
        return Center(child: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

// ignore: camel_case_types
class dsDonHang {
  String tenDonHang;
  String maDonHang;
  dsDonHang(this.maDonHang, this.tenDonHang);
}

// ----------------------------------------------------
// ignore: camel_case_types
class bieuDoTron extends StatefulWidget {
  const bieuDoTron({Key? key}) : super(key: key);

  @override
  State<bieuDoTron> createState() => _bieuDoTronState();
}

// ignore: camel_case_types
class _bieuDoTronState extends State<bieuDoTron> {
  late TooltipBehavior _tooltipBehavior;
  var orderStatusName;
  getOrderStatusName() async {
    var response = await httpGet("/api/donhang-trangthai/get/page", context);
    if (response.containsKey("body")) {
      setState(() {
        orderStatusName = jsonDecode(response["body"]);
      });
    }
  }

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: paddingBoxContainer,
      margin: EdgeInsets.only(right: 30),
      width: MediaQuery.of(context).size.width * 1,
      height: heightBoxContainer,
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: borderRadiusContainer,
        boxShadow: [boxShadowContainer],
        border: borderAllContainerBox,
      ),
      // decoration: BoxDecoration(
      //     border: Border.all(
      //   color: Colors.black,
      //   width: 1,
      // )),
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
            ],
          ),
          Container(
            margin: marginTopBottomHorizontalLine,
            child: Divider(
              thickness: 1,
              color: ColorHorizontalLine,
            ),
          ),
          SfCircularChart(
            tooltipBehavior: _tooltipBehavior,
            legend: Legend(
                isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
            //title: ChartTitle(text: 'Trạng thái đơn hàng'),
            series: <CircularSeries>[
              // Render pie chart
              PieSeries<ChartData, String>(
                enableTooltip: true,
                dataSource: [
                  // Bind data source
                  ChartData('Chưa phát hành', thongKe['donhang_chuaphathanh']),
                  ChartData('Chờ xử lý', thongKe['donhang_choxuly']),
                  ChartData('Đang thực hiện', thongKe['donhang_dangthuchien']),
                ],
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                // name: 'Data',
                dataLabelSettings: DataLabelSettings(isVisible: true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ignore: camel_case_types
class bieuDoTron2 extends StatefulWidget {
  const bieuDoTron2({Key? key}) : super(key: key);

  @override
  State<bieuDoTron2> createState() => _bieuDoTron2State();
}

// ignore: camel_case_types
class _bieuDoTron2State extends State<bieuDoTron2> {
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 30),
      padding: paddingBoxContainer,

      width: MediaQuery.of(context).size.width * 1,
      height: heightBoxContainer,
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: borderRadiusContainer,
        boxShadow: [boxShadowContainer],
        border: borderAllContainerBox,
      ),
      // height: 450,
      // margin: EdgeInsets.fromLTRB(0, 80, 30, 0),
      // decoration: BoxDecoration(
      //     border: Border.all(
      //   color: Colors.black,
      //   width: 1,
      // )),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trạng thái TTS',
                style: titleBox,
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
          SfCircularChart(
            tooltipBehavior: _tooltipBehavior,
            legend: Legend(
                isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
            //title: ChartTitle(text: 'Trạng thái TTS'),
            series: <CircularSeries>[
              // Render pie chart
              PieSeries<ChartData, String>(
                enableTooltip: true,
                dataSource: [
                  // Bind data source
                  ChartData('Đã tiến cử', thongKe['tts_datiencu']),
                  ChartData('Đã xuất cảnh', thongKe['tts_daxuatcanh']),
                  ChartData('Đang đào tạo', thongKe['tts_dangdaotao']),
                ],
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                // name: 'Data',
                dataLabelSettings: DataLabelSettings(isVisible: true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ignore: camel_case_types
class bieuDoTron3 extends StatefulWidget {
  const bieuDoTron3({Key? key}) : super(key: key);

  @override
  State<bieuDoTron3> createState() => _bieuDoTron3State();
}

// ignore: camel_case_types
class _bieuDoTron3State extends State<bieuDoTron3> {
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 450,
      // margin: EdgeInsets.fromLTRB(0, 80, 30, 0),
      // decoration: BoxDecoration(
      //     border: Border.all(
      //   color: Colors.black,
      //   width: 1,
      // )),
      padding: paddingBoxContainer,
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
                'Tiến độ thi tuyển',
                style: titleBox,
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
          SfCircularChart(
            tooltipBehavior: _tooltipBehavior,
            legend: Legend(
                isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
            //title: ChartTitle(text: 'Trạng thái TTS'),
            series: <CircularSeries>[
              // Render pie chart
              PieSeries<ChartData, String>(
                enableTooltip: true,
                dataSource: [
                  // Bind data source
                  ChartData('Đã thi tuyển', countTookTheExam),
                  ChartData('Chờ thi tuyển', countWaitEntranceExam),
                ],
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                // name: 'Data',
                dataLabelSettings: DataLabelSettings(isVisible: true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y, [this.color]);
  final String x;
  final double y;
  final Color? color;
}
