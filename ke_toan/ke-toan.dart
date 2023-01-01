import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../api.dart';
import '../../../common/style.dart';

import '../../../common/widgets_form.dart';

import '../navigation.dart';

class KeToan extends StatefulWidget {
  const KeToan({Key? key}) : super(key: key);

  @override
  _KeToanState createState() => _KeToanState();
}

class _KeToanState extends State<KeToan> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: KeToanBody());
  }
}

class KeToanBody extends StatefulWidget {
  const KeToanBody({Key? key}) : super(key: key);

  @override
  State<KeToanBody> createState() => _KeToanBodyState();
}

class _KeToanBodyState extends State<KeToanBody> {
  late Future<dynamic> getThongKeFuture;
  var thongKe;
  getTtsDt() async {
    var dashboard = await httpGet("/api/hethong-chung/get/thongke", context);
    if (dashboard.containsKey("body")) thongKe = jsonDecode(dashboard['body']);
    return 0;
  }

  @override
  void initState() {
    // TODO: implement initState
    getThongKeFuture = getTtsDt();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: getThongKeFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            child: ListView(
              children: [
                TitlePage(
                  listPreTitle: [],
                  content: 'DashBoard',
                ),
                Container(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 25,
                      ),
                      Expanded(
                        flex: 1,
                        child: TTSDaTienCu(thongKe: thongKe),
                      ),
                      SizedBox(
                        width: 25,
                      ),
                      Expanded(
                        flex: 1,
                        child: TTSDaTrungTuyen(thongKe: thongKe),
                      ),
                      SizedBox(
                        width: 25,
                      ),
                    ],
                  ),
                ),Footer()
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return SelectableText('${snapshot.error}');
        }

        // By default, show a loading spinner.
        return Center(child: const CircularProgressIndicator());
      },
    );
  }
}

//biển đồ tròn TTS đã tiến cử
class TTSDaTienCu extends StatefulWidget {
  final dynamic thongKe;
  const TTSDaTienCu({Key? key, this.thongKe}) : super(key: key);

  @override
  State<TTSDaTienCu> createState() => _TTSDaTienCuState();
}

class _TTSDaTienCuState extends State<TTSDaTienCu> {
  late TooltipBehavior _tooltipBehavior;
  @override
  void initState() {
    // TODO: implement initState
    _tooltipBehavior = TooltipBehavior(enable: true);
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
              SelectableText(
                'TTS đã tiến cử',
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
              legend: Legend(
                  isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
              // title: ChartTitle(text: 'Trạng thái TTS', alignment: Alignment.topLeft),
              series: <CircularSeries>[
                // Render pie chart
                PieSeries<ChartDataP, String>(
                  enableTooltip: false,
                  dataSource: [
                    // Bind data source
                    ChartDataP('TTS đã đóng tiền cọc thi tuyển',
                        widget.thongKe['tts_dadongtientruocthituyen']),
                    ChartDataP('TTS chưa đóng tiền cọc thi tuyển',
                        widget.thongKe['tts_chuadongtientruocthituyen']),
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
  }
}

class ChartDataP {
  ChartDataP(this.x, this.y, [this.color]);
  final String x;
  final double y;
  final Color? color;
}

//biểu đồ tròn TTS đã trúng tuyển đơn hàng

class TTSDaTrungTuyen extends StatefulWidget {
  final dynamic thongKe;
  const TTSDaTrungTuyen({Key? key, this.thongKe}) : super(key: key);

  @override
  State<TTSDaTrungTuyen> createState() => _TTSDaTrungTuyenState();
}

class _TTSDaTrungTuyenState extends State<TTSDaTrungTuyen> {
  late TooltipBehavior _tooltipBehavior;
  @override
  void initState() {
    // TODO: implement initState
    _tooltipBehavior = TooltipBehavior(enable: true);
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
              SelectableText(
                'TTS đã trúng tuyển đơn hàng',
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
              legend: Legend(
                  isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
              // title: ChartTitle(text: 'Trạng thái TTS', alignment: Alignment.topLeft),
              series: <CircularSeries>[
                // Render pie chart
                PieSeries<ChartDataTT, String>(
                  enableTooltip: false,
                  dataSource: [
                    // Bind data source
                    ChartDataTT('TTS đã đóng tiền ngân hàng\n(xuất cảnh)',
                        widget.thongKe['tts_dadongtiensauthituyen']),
                    ChartDataTT('TTS chưa đóng tiền ngân hàng\n(xuất cảnh)',
                        widget.thongKe['tts_chuadongtiensauthituyen']),
                  ],
                  xValueMapper: (ChartDataTT data, _) => data.x,
                  yValueMapper: (ChartDataTT data, _) => data.y,

                  // name: 'Data',
                  dataLabelSettings: DataLabelSettings(isVisible: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChartDataTT {
  ChartDataTT(this.x, this.y, [this.color]);
  final String x;
  final double y;
  final Color? color;
}
