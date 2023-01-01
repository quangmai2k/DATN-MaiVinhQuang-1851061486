import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
// import 'package:pie_chart/pie_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../api.dart';
import '../../../common/style.dart';
import '../../../common/widgets_form.dart';
import '../../../common/widgets_form.dart';
import '../../../model/model.dart';

import '../dashboard.dart';
import '../navigation.dart';

final String urlThuongDonHang = "/thuong-don-hang";
final String urlDonHang = "ho-so-noi/don-hang";
int countOrder = 0;
int countRecomendedTrainee = 0;
double countNewlyCreateOrder = 0;
double countWaitingForHandleOrder = 0;
double countHandlingOrder = 0;
double countExitTrainee = 0;
double countTrainingTrainee = 0;
double countRecomendedTrainee1 = 0;
double countTookEntranceExam = 0;
double countWaitEntranceExam = 0;
var listNewlyCreateOrder = {};

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
  // getCountOrder() async {
  //   var response = await httpGet("/api/donhang/get/count", context);
  //   if (response.containsKey("body")) {
  //     setState(() {
  //       countOrder = jsonDecode(response["body"]);
  //     });
  //   }
  // }

  // getCountRecomendedTrainee() async {
  //   var response = await httpGet("/api/nguoidung/get/count?filter=isTts:1 and ttsStatusId:5", context);
  //   if (response.containsKey("body")) {
  //     setState(() {
  //       countRecomendedTrainee = jsonDecode(response["body"]);
  //       countRecomendedTrainee1 = jsonDecode(response["body"]);
  //     });
  //   }
  // }

  // getCountNewlyCreateOrder() async {
  //   var response = await httpGet("/api/donhang/get/count?filter=orderStatusId:1", context);
  //   if (response.containsKey("body")) {
  //     setState(() {
  //       countNewlyCreateOrder = jsonDecode(response['body']);
  //     });
  //   }
  // }

  // getCountWaitingForHandleOrder() async {
  //   var response = await httpGet("/api/donhang/get/count?filter=orderStatusId:2", context);
  //   if (response.containsKey("body")) {
  //     setState(() {
  //       countWaitingForHandleOrder = jsonDecode(response['body']);
  //     });
  //   }
  // }

  // getCountHandlingOrder() async {
  //   var response = await httpGet(
  //       "/api/nguoidung/get/count?filter=isTts:1 and ttsStatusId:2", //Đang xử lý
  //       context);
  //   if (response.containsKey("body")) {
  //     setState(() {
  //       countHandlingOrder = jsonDecode(response['body']);
  //     });
  //   }
  // }

  // getCountExitTrainee() async {
  //   var response = await httpGet(
  //       "/api/nguoidung/get/count?filter=isTts:1 and ttsStatusId:11", //Đã xuất cảnh
  //       context);
  //   if (response.containsKey("body")) {
  //     setState(() {
  //       countExitTrainee = jsonDecode(response["body"]);
  //     });
  //   }
  // }

  // getCountTrainingTrainee() async {
  //   var response = await httpGet("/api/nguoidung/get/count?filter=isTts:1 and ttsStatusId:9", context);
  //   if (response.containsKey("body")) {
  //     setState(() {
  //       countTrainingTrainee = jsonDecode(response["body"]);
  //     });
  //   }
  // }

  // getCountTookEntranceExam() async {
  //   DateTime dateTime = new DateTime.now();
  //   var response = await httpGet("/api/lichthituyen/get/count?filter=examDate < '${dateTime.day}-${dateTime.month}-${dateTime.year}'", context);
  //   if (response.containsKey("body")) {
  //     setState(() {
  //       countTookEntranceExam = jsonDecode(response["body"]);
  //     });
  //   }
  // }

  // getCountWaitEntranceExam() async {
  //   DateTime dateTime = new DateTime.now();

  //   var response = await httpGet("/api/lichthituyen/get/count?filter=examDate > '${dateTime.day}-${dateTime.month}-${dateTime.year}'", context);
  //   if (response.containsKey("body")) {
  //     setState(() {
  //       countWaitEntranceExam = jsonDecode(response["body"]);
  //     });
  //   }
  // }

  // getNewlyCreateOrder() async {
  //   var response = await httpGet("/api/donhang/get/page?page=0&size=5&createdDate:max(date)&filter=orderStatusId:2", context);
  //   if (response.containsKey("body")) {
  //     setState(() {
  //       listNewlyCreateOrder = jsonDecode(response["body"]);
  //     });
  //   }
  // }

  // callApi() async {
  //   await getCountOrder();
  //   await getCountRecomendedTrainee();
  //   await getCountNewlyCreateOrder();
  //   await getCountWaitingForHandleOrder();
  //   await getCountHandlingOrder();
  //   await getCountTrainingTrainee();
  //   await getCountExitTrainee();
  //   await getCountTookEntranceExam();
  //   await getCountWaitEntranceExam();
  //   await getNewlyCreateOrder();
  // }
  var data = {};
  getData() async {
    var response = await httpGet("/api/hethong-chung/get/thongke", context);
    if (response.containsKey("body")) {
      setState(() {
        data = jsonDecode(response['body']);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Consumer<NavigationModel>(
          builder: (context, navigationModel, child) => Container(
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
                                style: TextStyle(color: Color(0xff009C87)),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 5, right: 5),
                                child: Text(
                                  '/',
                                  style: TextStyle(
                                    color: Color(0xffC8C9CA),
                                  ),
                                ),
                              ),
                              Text('Hồ sơ nội',
                                  style: TextStyle(color: Color(0xff009C87))),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(25, 0, 0, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("Bảng thống kê nhanh", style: titlePage),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: backgroundPage,
                    padding: EdgeInsets.symmetric(
                        vertical: verticalPaddingPage,
                        horizontal: horizontalPaddingPage),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          //Các khối dữ liệu tổng quan ở trên đầu trang
                          Expanded(flex: 2, child: Container()),

                          Expanded(
                            flex: 5,
                            child: InkWell(
                              child: OverviewDataBox(
                                bGColorIconBox: colorBGIconOverviewDataBox1,
                                dataBox: countOrder,
                                titleBox: 'Đơn hàng',
                                colorIconBox: colorWhite,
                                iconBox: Icons.account_box,
                                sizeIconBox: sizeIconOverviewDataBox,
                              ),
                              onTap: () {
                                navigationModel.add(pageUrl: urlThuongDonHang);
                              },
                            ),
                          ),

                          Expanded(flex: 2, child: Container()),

                          Expanded(
                            flex: 5,
                            child: InkWell(
                              child: OverviewDataBox(
                                bGColorIconBox: colorBGIconOverviewDataBox3,
                                dataBox: countRecomendedTrainee,
                                titleBox: 'Tổng số TTS đã tiến cử ',
                                colorIconBox: colorWhite,
                                iconBox: Icons.account_tree_outlined,
                                sizeIconBox: sizeIconOverviewDataBox,
                              ),
                              onTap: () {
                                navigationModel.add(pageUrl: urlThuongDonHang);
                              },
                            ),
                          ),
                          Expanded(flex: 2, child: Container()),
                        ]),
                  ),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                      child: bieuDoTron(data: data),
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
                      child: bieuDoTron2(data: data),
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  margin: EdgeInsets.fromLTRB(20, 20, 0, 0),
                                  child: Text(
                                      'Danh sách đơn hàng chưa phát hành (${listNewlyCreateOrder["size"]})',
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
                        Container(
                          padding: EdgeInsets.only(left: 20),
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Column(
                              children: [
                                if (listNewlyCreateOrder["content"] != null)
                                  for (int j = 0;
                                      j < listNewlyCreateOrder["size"];
                                      j++)
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
                                        ))),
                                        child: Consumer<NavigationModel>(
                                          builder: (context, navigationModel,
                                                  child) =>
                                              Container(
                                            child: InkWell(
                                              // onHover: (value) => Colors.red,
                                              child: Row(
                                                children: [
                                                  Container(
                                                    child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 10),
                                                        //Số thứ tự
                                                        child: Container(
                                                          width: 30,
                                                          height: 30,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Color(
                                                                0xffF577C74),
                                                            // border: Border.all(
                                                            //     color: Colors.blue,
                                                            //     width: 1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(
                                                              Radius.elliptical(
                                                                  10, 10),
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
                                                  SizedBox(width: 20),
                                                  Flexible(
                                                    child: Text(
                                                      listNewlyCreateOrder[
                                                              "content"][j]
                                                          ["orderName"],
                                                      maxLines: 2,
                                                      softWrap: false,
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
                                                        "quan-li-don-hang/id/${listNewlyCreateOrder["content"][j]["id"]}");
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
                                  Container(
                                    child: Text(
                                        "Không có đơn hàng nào chưa phát hành"),
                                  )
                              ],
                            ),
                          ),
                        ),
                        Consumer<NavigationModel>(
                          builder: (context, navigationModel, child) => Row(
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                  onPressed: () {
                                    navigationModel.add(
                                        pageUrl: urlThuongDonHang);
                                  },
                                  child: Text(
                                    'Xem thêm >>',
                                    style: TextStyle(
                                      color: Colors.blue[300],
                                    ),
                                  ))
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
        ),
        Footer(marginFooter: EdgeInsets.only(top: 25), paddingFooter: EdgeInsets.all(15))
      ],
      
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
  final data;
  const bieuDoTron({Key? key, required this.data}) : super(key: key);

  @override
  State<bieuDoTron> createState() => _bieuDoTronState();
}

// ignore: camel_case_types
class _bieuDoTronState extends State<bieuDoTron> {
  late TooltipBehavior _tooltipBehavior;

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
                  ChartData(
                      'Chưa phát hành',
                      (widget.data["donhang_chuaphathanh"] != null)
                          ? widget.data["donhang_chuaphathanh"]
                          : 0),
                  ChartData(
                      'Chờ xử lý',
                      (widget.data["donhang_choxuly"] != null)
                          ? widget.data["donhang_choxuly"]
                          : 0),
                  ChartData(
                      'Đang thực hiện',
                      (widget.data["donhang_dangthuchien"] != null)
                          ? widget.data["donhang_dangthuchien"]
                          : 0),
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
  final data;
  const bieuDoTron2({Key? key, required this.data}) : super(key: key);

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
                  ChartData(
                      'Đã tiến cử',
                      (widget.data["tts_datiencu"] != null)
                          ? widget.data["tts_datiencu"]
                          : 0),
                  ChartData(
                      'Đã xuất cảnh',
                      (widget.data["tts_daxuatcanh"] != null)
                          ? widget.data["tts_daxuatcanh"]
                          : 0),
                  ChartData(
                      'Đang đào tạo',
                      (widget.data["tts_dangdaotao"] != null)
                          ? widget.data["tts_dangdaotao"]
                          : 0),
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
                  ChartData('Đã thi tuyển', countTookEntranceExam),
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
