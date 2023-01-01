import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/api.dart';
import 'package:gentelella_flutter/common/widgets_form.dart';
import 'package:gentelella_flutter/model/model.dart';
import 'package:gentelella_flutter/common/style.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../common/format_date.dart';
import '../navigation.dart';

class HoSoNgoai extends StatefulWidget {
  const HoSoNgoai({Key? key}) : super(key: key);

  @override
  _HoSoNgoaiState createState() => _HoSoNgoaiState();
}

class _HoSoNgoaiState extends State<HoSoNgoai> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: HoSoNgoaiBody());
  }
}

class HoSoNgoaiBody extends StatefulWidget {
  const HoSoNgoaiBody({Key? key}) : super(key: key);

  @override
  State<HoSoNgoaiBody> createState() => _HoSoNgoaiBodyState();
}

class _HoSoNgoaiBodyState extends State<HoSoNgoaiBody> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TitlePageWidget(
              textSpanWidget: [
                TextSpan(
                    text: 'Hồ Sơ Ngoại',
                    style: titlePage,
                    mouseCursor: MaterialStateMouseCursor.clickable),
              ],
              widgetBoxRight: [Container()],
            ),
            Container(child: Thongke()),
          ],
        ),
      ],
    );
  }
}

class Thongke extends StatefulWidget {
  // final Function voidCallBack;
  const Thongke({Key? key}) : super(key: key);

  @override
  State<Thongke> createState() => _ThongkeState();
}

class _ThongkeState extends State<Thongke> {
  late Future futureListLichBay;
  var listLichBay = {};
  var idLichBay;

  Future getLichBay() async {
    var response = await httpGet(
        "/api/lichxuatcanh/get/page?page=0&size=5&sort=flightDate,desc&filter=status:1",
        context);
    if (response.containsKey("body")) {
      setState(() {
        listLichBay = jsonDecode(response["body"]);
      });
    }
    return 0;
  }

  @override
  void initState() {
    futureListLichBay = getLichBay();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureListLichBay,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Consumer<NavigationModel>(
            builder: (context, navigationModel, child) => Container(
              color: backgroundPage,
              padding: EdgeInsets.symmetric(
                  vertical: verticalPaddingPage,
                  horizontal: horizontalPaddingPage),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: PieChart(),
                  ),
                  Expanded(
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
                      child: ListView(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Lịch bay (${listLichBay["content"].length})',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xff333333)),
                              ),
                              Icon(Icons.more_horiz,
                                  color: colorIconTitleBox,
                                  size: sizeIconTitleBox),
                            ],
                          ),
                          //Đường line
                          Container(
                            margin: marginTopBottomHorizontalLine,
                            child: Divider(
                                thickness: 1, color: ColorHorizontalLine),
                          ),
                          Column(
                            children: [
                              for (var i = 0;
                                  i < listLichBay["content"].length;
                                  i++)
                                Container(
                                  padding: EdgeInsets.only(top: 13, bottom: 15),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          width: 1, color: Color(0xffC8C9CA)),
                                    ),
                                  ),
                                  child: InkWell(
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
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
                                                child: Text('#${i + 1}',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15)),
                                              )),
                                        ),
                                        SizedBox(width: 20),
                                        Flexible(
                                          child: Text(
                                            'Lịch bay "${listLichBay["content"][i]["title"]}" được khởi hành vào ' +
                                                FormatDate.formatTime(
                                                    DateTime.parse(
                                                        listLichBay["content"]
                                                                [i]
                                                            ["flightDate"])) +
                                                " ngày " +
                                                FormatDate.formatDateddMMyy(
                                                    DateTime.parse(
                                                        listLichBay["content"]
                                                            [i]["flightDate"])),
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Color(0xff006496)),
                                            maxLines: 2,
                                            softWrap: false,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onTap: (() {
                                      idLichBay = listLichBay["content"][i]
                                              ["id"]
                                          .toString();
                                      navigationModel.add(
                                          pageUrl: ("/thong-tin-lb" +
                                              "/$idLichBay"));
                                    }),
                                  ),
                                ),
                              Container(
                                margin: EdgeInsets.only(top: 18),
                                child: TextButton(
                                  onPressed: () {
                                    Provider.of<NavigationModel>(context,
                                            listen: false)
                                        .add(pageUrl: "/lich-bay");
                                  },
                                  child: Text('Xem tất cả lịch bay',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xff006496),
                                          fontWeight: FontWeight.w400)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
    );
  }
}

//------------Biểu đồ tròn trạng thái TTS----

class PieChart extends StatefulWidget {
  const PieChart({Key? key}) : super(key: key);

  @override
  State<PieChart> createState() => _PieChartState();
}

class _PieChartState extends State<PieChart> {
  late TooltipBehavior _tooltipBehavior;
  late Future getThongKeFuture;
  var thongKe;
  Future getThongKe() async {
    var dashboard = await httpGet("/api/hethong-chung/get/thongke", context);
    if (dashboard.containsKey("body")) thongKe = jsonDecode(dashboard['body']);
    return 0;
  }

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    getThongKeFuture = getThongKe();
    super.initState();
  }

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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TTS sau trúng tuyển', style: titleBox),
              Icon(Icons.more_horiz,
                  color: colorIconTitleBox, size: sizeIconTitleBox),
            ],
          ),
          //Đường line
          Container(
              margin: marginTopBottomHorizontalLine,
              child: Divider(thickness: 1, color: ColorHorizontalLine)),
          Expanded(
              child: FutureBuilder<dynamic>(
            future: getThongKeFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SfCircularChart(
                  tooltipBehavior: _tooltipBehavior,
                  legend: Legend(
                    textStyle:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                    isVisible: true,
                    overflowMode: LegendItemOverflowMode.wrap,
                  ),
                  series: <CircularSeries>[
                    DoughnutSeries<ChartDataP, String>(
                      enableTooltip: true,
                      dataSource: [
                        ChartDataP(
                            'TTS đã xuất cảnh', thongKe['tts_daxuatcanh']),
                        ChartDataP(
                            'TTS đã trúng tuyển', thongKe['tts_datrungtuyen']),
                        ChartDataP(
                            'TTS đang đào tạo', thongKe['tts_dangdaotao']),
                        ChartDataP(
                            'TTS chờ xuất cảnh', thongKe['tts_choxuatcanh']),
                      ],
                      xValueMapper: (ChartDataP data, _) => data.x,
                      yValueMapper: (ChartDataP data, _) => data.y,
                      dataLabelSettings: DataLabelSettings(isVisible: true),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          )),
        ],
      ),
    );
  }
}

class ChartDataP {
  ChartDataP(this.x, this.y, [this.color]);
  final String x;
  final double y;
  final Color? color;
}
