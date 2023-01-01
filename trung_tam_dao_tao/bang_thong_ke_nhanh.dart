import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/navigation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../api.dart';
import '../../../common/dynamic_table.dart';
import '../../../common/style.dart';
import '../../../common/widgets_form.dart';
import '../../../model/model.dart';
import '../source_information/thong_tin_nguon.dart';

class BangThongKeNhanh extends StatefulWidget {
  const BangThongKeNhanh({Key? key}) : super(key: key);

  @override
  State<BangThongKeNhanh> createState() => _BangThongKeNhanhState();
}

class _BangThongKeNhanhState extends State<BangThongKeNhanh> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
      widgetBody: BangThongKeNhanhBody(),
    );
  }
}

class BangThongKeNhanhBody extends StatefulWidget {
  const BangThongKeNhanhBody({Key? key}) : super(key: key);

  @override
  State<BangThongKeNhanhBody> createState() => _BangThongKeNhanhBodyState();
}

class _BangThongKeNhanhBodyState extends State<BangThongKeNhanhBody> {
  int sumTts = 0;
  List<ChartData> chartDataLine = [];
  DateTime now = DateTime.now();
  Future<dynamic> getCountTTSNHM() async {
    // DateTime now = DateTime.now();
    var formatterDate = DateFormat('dd-MM-yyyy');
    String beginDate = formatterDate.format(now);
    String endDate =
        formatterDate.format(now.subtract(const Duration(days: 7)));
    var response = await httpGet(
        "/api/tts-thongtindaotao/get/page?filter=admissionDate<:'$beginDate' and admissionDate>:'$endDate'",
        context);
    int one = jsonDecode(response["body"])['totalElements'];
    chartDataLine.add(ChartData('1 tuần trước', one));
    beginDate = formatterDate.format(now.subtract(const Duration(days: 7)));
    endDate = formatterDate.format(now.subtract(const Duration(days: 14)));
    response = await httpGet(
        "/api/tts-thongtindaotao/get/page?filter=admissionDate<:'$beginDate' and admissionDate>:'$endDate'",
        context);
    int two = jsonDecode(response["body"])['totalElements'];
    chartDataLine.add(ChartData('2 tuần trước', two));
    beginDate = formatterDate.format(now.subtract(const Duration(days: 14)));
    endDate = formatterDate.format(now.subtract(const Duration(days: 21)));
    response = await httpGet(
        "/api/tts-thongtindaotao/get/page?filter=admissionDate<:'$beginDate' and admissionDate>:'$endDate'",
        context);
    int three = jsonDecode(response["body"])['totalElements'];
    chartDataLine.add(ChartData('3 tuần trước', three));
    beginDate = formatterDate.format(now.subtract(const Duration(days: 21)));
    endDate = formatterDate.format(now.subtract(const Duration(days: 28)));
    response = await httpGet(
        "/api/tts-thongtindaotao/get/page?filter=admissionDate<:'$beginDate' and admissionDate>:'$endDate'",
        context);
    int four = jsonDecode(response["body"])['totalElements'];
    chartDataLine.add(ChartData('4 tuần trước', four));
    return chartDataLine;
  }

  var thongKe;
  int sumCtdt = 0;
  int sumClass = 0;
  late Future<dynamic> getThongKeFuture;
  getSumTTS() async {
    await getCountTTSNHM();
    var dashboard = await httpGet("/api/hethong-chung/get/thongke", context);
    if (dashboard.containsKey("body")) thongKe = jsonDecode(dashboard['body']);

    stt8 = thongKe['tts_chodaotao'];
    stt9 = thongKe['tts_dangdaotao'];
    stt10 = thongKe['tts_choxuatcanh'];
    stt11 = thongKe['tts_daxuatcanh'];
    chartData.add(ChartDataP('Chờ đào tạo', stt8));
    chartData.add(ChartDataP('Đang đào tạo', stt9));
    chartData.add(ChartDataP('Chờ xuất cảnh', stt10));
    chartData.add(ChartDataP('Đã xuất cảnh', stt11));

    var response1 = await httpGet("/api/daotao-chuongtrinh/get/count", context);
    var response2 = await httpGet("/api/daotao-lop/get/count", context);
    if (response2.containsKey("body")) {
      setState(() {
        sumClass = jsonDecode(response2["body"]);
      });
    }
    if (response1.containsKey("body")) {
      setState(() {
        sumCtdt = jsonDecode(response1["body"]);
      });
    }
    return 0;
  }

  int stt8 = 0;
  int stt9 = 0;
  int stt10 = 0;
  int stt11 = 0;
  List<ChartDataP> chartData = [];

  @override
  // ignore: must_call_super
  void initState() {
    getThongKeFuture = getSumTTS();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        TitlePage(
          listPreTitle: [],
          content: 'Bảng thống kê nhanh',
        ),
        SizedBox(
          height: 25,
        ),
        FutureBuilder<dynamic>(
          future: getThongKeFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 1,
                    // margin: marginTopBoxContainer,
                    padding: paddingBoxContainer,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            //Các khối dữ liệu tổng quan ở trên đầu trang
                            OverviewDataBox(
                              bGColorIconBox: colorBGIconOverviewDataBox1,
                              dataBox: thongKe['tts_daotao'],
                              titleBox: 'Tổng số TTS',
                              colorIconBox: colorWhite,
                              iconBox: Icons.account_box,
                              sizeIconBox: sizeIconOverviewDataBox,
                              function: () {
                                Provider.of<NavigationModel>(context,
                                        listen: false)
                                    .add(pageUrl: "/danh-sach-thuc-tap-sinh");
                              },
                            ),
                            SizedBox(
                              width: 25,
                            ),
                            OverviewDataBox(
                                bGColorIconBox: colorBlueBtnDialog,
                                dataBox: sumCtdt,
                                titleBox: 'Tổng số chương trình đào tạo',
                                colorIconBox: colorWhite,
                                iconBox: Icons.play_lesson,
                                sizeIconBox: sizeIconOverviewDataBox,
                                function: () {
                                  Provider.of<NavigationModel>(context,
                                          listen: false)
                                      .add(
                                          pageUrl:
                                              "/quan-ly-chuong-trinh-dao-tao");
                                }),
                            SizedBox(
                              width: 25,
                            ),
                            OverviewDataBox(
                              bGColorIconBox: colorOrange,
                              dataBox: sumClass,
                              titleBox: 'Tổng số lớp học',
                              colorIconBox: colorWhite,
                              iconBox: Icons.school,
                              sizeIconBox: sizeIconOverviewDataBox,
                              function: () {
                                Provider.of<NavigationModel>(context,
                                        listen: false)
                                    .add(pageUrl: "/quan-ly-lop-hoc");
                              },
                            ),
                          ],
                        ),
                        Row(children: [
                          Expanded(
                              flex: 4,
                              child: Center(
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
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SelectableText(
                                            'Số thực tập sinh nhập học mới',
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
                                              // Initialize category axis
                                              primaryXAxis: CategoryAxis(),
                                              primaryYAxis: CategoryAxis(
                                                  arrangeByIndex: false),
                                              legend: Legend(isVisible: true),
                                              series: <ChartSeries>[
                                            // Initialize line series
                                            LineSeries<ChartData, String>(
                                                enableTooltip: true,
                                                name: 'TTS nhập học mới',
                                                dataLabelSettings:
                                                    DataLabelSettings(
                                                        isVisible: true),
                                                dataSource: chartDataLine,
                                                xValueMapper:
                                                    (ChartData data, _) =>
                                                        data.x,
                                                yValueMapper:
                                                    (ChartData data, _) =>
                                                        data.y),
                                          ])),
                                    ],
                                  ),
                                ),
                              )),
                          SizedBox(
                            width: 30,
                          ),
                          Expanded(
                              flex: 3,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SelectableText(
                                          'Số lượng TTS theo trạng thái',
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
                                            legend: Legend(
                                                isVisible: true,
                                                overflowMode:
                                                    LegendItemOverflowMode
                                                        .wrap),
                                            series: <CircularSeries>[
                                          // Render pie chart
                                          PieSeries<ChartDataP, String>(
                                              dataSource: chartData,
                                              dataLabelSettings:
                                                  DataLabelSettings(
                                                      isVisible: true,
                                                      labelPosition:
                                                          ChartDataLabelPosition
                                                              .outside),
                                              xValueMapper:
                                                  (ChartDataP data, _) =>
                                                      data.x,
                                              yValueMapper:
                                                  (ChartDataP data, _) =>
                                                      data.y)
                                        ])),
                                  ],
                                ),
                              ))
                        ]),
                      ],
                    ),
                  ),
                  Container(
                    color: backgroundPage,
                    padding: EdgeInsets.symmetric(
                        vertical: verticalPaddingPage,
                        horizontal: horizontalPaddingPage),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 1,
                      // margin: marginTopBoxContainer,
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
                              SelectableText(
                                'Danh sách TTS chờ đào tạo',
                                style: titleBox,
                              ),
                              Icon(
                                Icons.more_horiz,
                                color: colorIconTitleBox,
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
                          Row(
                            children: [
                              Expanded(child: TableTTSCDT()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: backgroundPage,
                    padding: EdgeInsets.symmetric(
                        vertical: verticalPaddingPage,
                        horizontal: horizontalPaddingPage),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 1,
                      // margin: marginTopBoxContainer,
                      decoration: BoxDecoration(
                        color: colorWhite,
                        borderRadius: borderRadiusContainer,
                        boxShadow: [boxShadowContainer],
                        border: borderAllContainerBox,
                      ),
                      padding: paddingBoxContainer,
                      child: Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SelectableText(
                              'Danh sách TTS đang đào tạo chuẩn bị xuất cảnh',
                              style: titleBox,
                            ),
                            Icon(
                              Icons.more_horiz,
                              color: colorIconTitleBox,
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
                        Row(
                          children: [
                            Expanded(child: TableTTSCBXC()),
                          ],
                        ),
                      ]),
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return SelectableText('${snapshot.error}');
            }

            // By default, show a loading spinner.
            return Center(child: const CircularProgressIndicator());
          },
        ),
        Footer(),
      ],
    );
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final int y;
}

class ChartDataP {
  ChartDataP(this.x, this.y, [this.color]);
  final String x;
  final int y;
  final Color? color;
}

class TableTTSCDT extends StatefulWidget {
  @override
  State<TableTTSCDT> createState() => _TableTTSCDTState();
}

class _TableTTSCDTState extends State<TableTTSCDT> {
  late int rowCount;
  int currentPageDef = 1;
  int rowPerPage = 10;
  late Future<dynamic> getListTTSCDTFuture;
  var listTTSCDT = {};
  getlistTTSCDT(int currentPage) async {
    var response = await httpGet(
        "/api/nguoidung/get/page?size=$rowPerPage&page=${currentPage - 1}&filter=isTts:1 AND ttsStatusId:8",
        context);
    if (response.containsKey("body")) {
      listTTSCDT = jsonDecode(response["body"]);
      rowCount = listTTSCDT['totalElements'] ?? 0;
      return listTTSCDT;
    } else
      throw Exception('False to load data');
  }

  @override
  void initState() {
    getListTTSCDTFuture = getlistTTSCDT(1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: getListTTSCDTFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var tableIndex = (currentPageDef - 1) * rowPerPage + 1;
          return Container(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DataTable(showCheckboxColumn: false, columns: [
                        DataColumn(label: SelectableText('STT')),
                        DataColumn(label: SelectableText('Mã TTS')),
                        DataColumn(label: SelectableText('Họ tên')),
                        DataColumn(label: SelectableText('Mã Đơn hàng')),
                        DataColumn(label: SelectableText('Tên đơn hàng')),
                        DataColumn(label: SelectableText('Mức ưu tiên')),
                      ], rows: <DataRow>[
                        for (var row in snapshot.data['content'] ?? [])
                          DataRow(
                            cells: [
                              DataCell(SelectableText(" ${tableIndex++}")),
                              DataCell(SelectableText(row['userCode'] ?? '')),
                              DataCell(SelectableText(row['fullName'] ?? '')),
                              DataCell(SelectableText(row['donhang'] != null
                                  ? row['donhang']['orderCode'] ?? ''
                                  : '')),
                              DataCell(SelectableText(row['donhang'] != null
                                  ? row['donhang']['orderName'] ?? ''
                                  : '')),
                              DataCell(SelectableText(row['donhang'] != null
                                  ? row['donhang']['orderUrgent'] == 1
                                      ? 'Xử lý gấp'
                                      : 'Bình thường'
                                  : ''))
                            ],
                          )
                      ]),
                    ),
                  ],
                ),
                DynamicTablePagging(rowCount, currentPageDef, rowPerPage,
                    pageChangeHandler: (currentPage) {
                  setState(() {
                    getListTTSCDTFuture = getlistTTSCDT(currentPage);
                    currentPageDef = currentPage;
                  });
                }, rowPerPageChangeHandler: (rowPerPageChange) {
                  rowPerPage = rowPerPageChange;
                  getListTTSCDTFuture = getlistTTSCDT(currentPageDef);
                  setState(() {});
                })
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return SelectableText('${snapshot.error}');
        }
        // By default, show a loading spinner.
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class TableTTSCBXC extends StatefulWidget {
  @override
  State<TableTTSCBXC> createState() => _TableTTSCBXCState();
}

class _TableTTSCBXCState extends State<TableTTSCBXC> {
  late int rowCount;
  int currentPageDef = 1;
  int rowPerPage = 10;
  late Future<dynamic> getListTTSCDTFuture;
  var listTTSCDT = {};
  getlistTTSCDT(int currentPage) async {
    DateTime now = DateTime.now();
    var formatterDate = DateFormat('dd-MM-yyyy');
    String beginDate = formatterDate.format(now);
    String endDate = formatterDate.format(now.add(const Duration(days: 14)));
    var response = await httpGet(
        "/api/daotao-tts/get/page?size=$rowPerPage&page=${currentPage - 1}&filter=nguoidung.ttsStatusId:10 and nguoidung.donhang.estimatedEntryDate>:'$beginDate' and nguoidung.donhang.estimatedEntryDate<:'$endDate'",
        context);
    if (response.containsKey("body")) {
      listTTSCDT = jsonDecode(response["body"]);
      rowCount = listTTSCDT['totalElements'] ?? 0;

      return listTTSCDT;
    } else
      throw Exception('False to load data');
  }

  @override
  void initState() {
    getListTTSCDTFuture = getlistTTSCDT(1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: getListTTSCDTFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var tableIndex = (currentPageDef - 1) * rowPerPage + 1;
          return Container(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DataTable(showCheckboxColumn: false, columns: [
                        DataColumn(label: SelectableText('STT')),
                        DataColumn(label: SelectableText('Mã TTS')),
                        DataColumn(label: SelectableText('Họ tên')),
                        DataColumn(label: SelectableText('Mã Đơn hàng')),
                        DataColumn(label: SelectableText('Tên đơn hàng')),
                        DataColumn(label: SelectableText('Mức ưu tiên')),
                      ], rows: <DataRow>[
                        for (var row in snapshot.data['content'] ?? [])
                          DataRow(
                            cells: [
                              DataCell(SelectableText(" ${tableIndex++}")),
                              DataCell(SelectableText(
                                  row['nguoidung']['userCode'] ?? '')),
                              DataCell(SelectableText(
                                  row['nguoidung']['fullName'] ?? '')),
                              DataCell(SelectableText(row['nguoidung']
                                      ['donhang']['orderCode'] ??
                                  '')),
                              DataCell(SelectableText(row['nguoidung']
                                      ['donhang']['orderName'] ??
                                  '')),
                              DataCell(SelectableText(row['nguoidung']
                                          ['donhang']['orderUrgent'] ==
                                      1
                                  ? 'Xử lý gấp'
                                  : 'Bình thường'))
                            ],
                          )
                      ]),
                    ),
                  ],
                ),
                DynamicTablePagging(rowCount, currentPageDef, rowPerPage,
                    pageChangeHandler: (currentPage) {
                  setState(() {
                    getListTTSCDTFuture = getlistTTSCDT(currentPage);
                    currentPageDef = currentPage;
                  });
                }, rowPerPageChangeHandler: (rowPerPageChange) {
                  currentPageDef = 1;

                  rowPerPage = rowPerPageChange;
                  getListTTSCDTFuture = getlistTTSCDT(currentPageDef);
                  setState(() {});
                })
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
