import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/forms/market_development/utils/funciton.dart';

import 'package:gentelella_flutter/widgets/ui/navigation.dart';

import 'package:provider/provider.dart';

import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../../api.dart';
import '../../../../../common/format_date.dart';
import '../../../../../common/style.dart';
import '../../../../../model/base_model/object_line_chart.dart';
import '../../../../../model/base_model/object_pie_chart.dart';

import '../../../../../model/market_development/dto/union_dto.dart';
import '../../../../../model/market_development/order.dart';
import '../../../../../model/market_development/status_tts.dart';
import '../../../../../model/market_development/union.dart';
import '../../../../../model/model.dart';

import '../../../../common/widgets_form.dart';
import '../../../../model/market_development/thong_tin_dao_tao_tieng_nhat.dart';

import '../../../utils/market_development.dart';
import 'modal_.dart';
import 'package:jiffy/jiffy.dart';

class PhatTrienThiTruongWeb extends StatelessWidget {
  const PhatTrienThiTruongWeb({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: PhatTrienThiTruongBody());
  }
}

//------------Biểu đồ tròn trạng thái TTS----

class PhatTrienThiTruongBody extends StatefulWidget {
  const PhatTrienThiTruongBody({Key? key}) : super(key: key);

  @override
  State<PhatTrienThiTruongBody> createState() => _PhatTrienThiTruongBodyState();
}

class _PhatTrienThiTruongBodyState extends State<PhatTrienThiTruongBody> {
  List<ChartDataP> _lstDataUnionPieChart = [];

  List<ChartDataP> _lstDataTTSPieChart = [];

  List<dynamic> listUnionObjectResult = [];
  List<dynamic> listUnionDueToFee = [];
  List<ChartDataByMonth> chartData = [];
  final _key = GlobalKey();
  //Danh sách đơn hàng đang chờ xử lý
  List<Order> listOrderPending = [];
  bool _setLoading = false;
  late int numberOrder = 0;
  late int numberUnion = 0;
  late int sumNumberStatusUnionAll = 0;
  late int sumNumberStatusUnionStopCooperating = 0; //Dừng hợp tác 0
  late int sumNumberStatusUnionNeedAccess = 0; //Cần tiếp cận 1
  late int sumNumberStatusUnionApproaching = 0; //Đang tiếp cận 2
  late int sumNumberStatusUnionSignedAContract = 0; //Đã kí hợp đồng 3

  late int numberAllSTTS = 0;
  late int numberTTSTienCu = 0; //Dừng hợp tác 0
  late int numberTTSTrungTuyen = 0;

  List<int> _listMonth = [];
  List<StatusTTS> _listStatusTTS = [];
  Future countOrder() async {
    try {
      var response = await httpGet("/api/donhang/get/count", context);

      var body = jsonDecode(response['body']);

      if (response.containsKey("body")) {
        setState(() {
          numberOrder = body;
        });
      }
    } catch (e) {
      print("Ngoại lệ countOrder " + e.toString());
    }
  }

  Future countUnion() async {
    try {
      var response = await httpGet("/api/nghiepdoan/get/count", context);
      var body = jsonDecode(response['body']);
      if (response.containsKey("body")) {
        setState(() {
          numberUnion = body;
        });
      }
    } catch (e) {
      print("Ngoại lệ countUnion " + e.toString());
    }
  }

  Future countStatusStopCooperating() async {
    try {
      var response = await httpGet("/api/nghiepdoan/get/count?filter=contractStatus:0", context);
      var body = jsonDecode(response['body']);
      if (response.containsKey("body")) {
        setState(() {
          sumNumberStatusUnionStopCooperating = body;
          if (sumNumberStatusUnionStopCooperating > 0) {
            // var value = ((sumNumberStatusUnionStopCooperating / sumNumberStatusUnionAll) * 100);
            _lstDataUnionPieChart.add(ChartDataP("Dừng hợp tác", sumNumberStatusUnionStopCooperating));
          }
        });
      }
    } catch (e) {
      print("Ngoại lệ countStatusStopCooperating " + e.toString());
    }
  }

  Future countStatusNeedAccess() async {
    try {
      var response = await httpGet("/api/nghiepdoan/get/count?filter=contractStatus:1", context);
      var body = jsonDecode(response['body']);
      if (response.containsKey("body")) {
        setState(() {
          sumNumberStatusUnionNeedAccess = body;
          if (sumNumberStatusUnionNeedAccess > 0) {
            // var value = ((sumNumberStatusUnionNeedAccess / sumNumberStatusUnionAll) * 100);
            _lstDataUnionPieChart.add(ChartDataP("Cần tiếp cận", sumNumberStatusUnionNeedAccess));
          }
        });
      }
    } catch (e) {
      print("Ngoại lệ countStatusNeedAccess " + e.toString());
    }
  }

  Future countStatusApproaching() async {
    try {
      var response = await httpGet("/api/nghiepdoan/get/count?filter=contractStatus:2", context);
      var body = jsonDecode(response['body']);
      if (response.containsKey("body")) {
        setState(() {
          sumNumberStatusUnionApproaching = body;
          if (sumNumberStatusUnionApproaching > 0) {
            // var value = ((sumNumberStatusUnionApproaching / sumNumberStatusUnionAll) * 100);
            _lstDataUnionPieChart.add(ChartDataP("Đang tiếp cận", sumNumberStatusUnionApproaching));
          }
        });
      }
    } catch (e) {
      print("Ngoại lệ countStatusSignedAContract " + e.toString());
    }
  }

  Future countStatusSignedAContract() async {
    try {
      var response = await httpGet("/api/nghiepdoan/get/count?filter=contractStatus:3", context);
      var body = jsonDecode(response['body']);
      if (response.containsKey("body")) {
        setState(() {
          sumNumberStatusUnionSignedAContract = body;
          if (sumNumberStatusUnionSignedAContract > 0) {
            // var value = ((sumNumberStatusUnionSignedAContract / sumNumberStatusUnionAll) * 100);
            _lstDataUnionPieChart.add(ChartDataP("Đã kí hợp đồng", sumNumberStatusUnionSignedAContract));
          }
        });
      }
    } catch (e) {
      print("Ngoại lệ countStatusSignedAContract " + e.toString());
    }
  }

  Future countBySystem() async {
    print("countBySystem");
    try {
      var response = await httpGet("/api/hethong-chung/get/thongke", context);

      if (response.containsKey("body")) {
        setState(() {
          var body = jsonDecode(response['body']);

          numberTTSTienCu = body['tts_datiencu'];
          numberTTSTrungTuyen = body['tts_datrungtuyen'];
          numberOrder = body['donhang_chuaphathanh'] + body['donhang_choxuly'] + body['donhang_dangthuchien'] + body['donhang_hoanthanh'] + body['donhang_dungxuly'];
          _lstDataTTSPieChart.add(ChartDataP("Thực tập sinh tiến cử", numberTTSTienCu));
          _lstDataTTSPieChart.add(ChartDataP("Thực tập sinh trúng tuyển", numberTTSTrungTuyen));
        });
      }
    } catch (e) {
      print("Ngoại lệ countStatusTTSTienCu" + e.toString());
    }
  }

  Future<List<dynamic>> getListUnionByDueDateMax() async {
    var response = await httpGet("/api/nghiepdoan-denghi/get/page?sort=dueDate,desc&filter=requestStatus:1", context);
    var content = [];
    var body = jsonDecode(response['body']);
    if (response.containsKey("body")) {
      setState(() {
        content = body['content'];
        listUnionObjectResult = content;
      });
    }
    return listUnionObjectResult;
  }

  String getStatusNameTTS(List<StatusTTS> listStatus, int id) {
    for (int i = 0; i < listStatus.length; i++) {
      if (id == listStatus[i].id) {
        return listStatus[i].statusName!;
      }
    }
    return "No data!";
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

  Future getMonthListToMonthCurrent() async {
    try {
      List<ChartDataByMonth> listMonth = [];
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
          var response = await httpGet("/api/donhang/get/count?filter=publishDate>:'$dateFrom' AND  publishDate<:'$dateTo'  ", context);
          var body = jsonDecode(response['body']);

          ChartDataByMonth item = new ChartDataByMonth("Tháng $i", body, i);
          listMonth.add(item);
        } catch (e) {
          print(e);
        }
      }
      setState(() {
        chartData = listMonth;
      });
    } catch (e) {
      print("Ngoại lệ tổng" + e.toString());
    }
  }

  Future<List<ThongTinDaoTaoTiengNhat>> getThongTinDaoTaoTiengNhat() async {
    var response = await httpGet("/api/tts-thongtindaotao-tiengnhat/get/page?filter=reportFile is not empty and reportFile is not null ", context);

    Map<int, Order> mapLocOrder = {};

    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        content = body['content'];

        List<ThongTinDaoTaoTiengNhat> listThongTinDaoTaoTiengNhat = content.map((e) {
          return ThongTinDaoTaoTiengNhat.fromJson(e);
        }).toList();
        if (listThongTinDaoTaoTiengNhat.length > 0) {
          for (var item in listThongTinDaoTaoTiengNhat) {
            try {
              if (item.user != null) {
                if (item.user!.order != null) {
                  if (!mapLocOrder.containsKey(item.user!.order!.id)) {
                    mapLocOrder.putIfAbsent(item.user!.order!.id, () => item.user!.order!);
                  }
                }
              }
            } catch (e) {
              print(e.toString());
            }
          }
        }

        for (var item in mapLocOrder.values) {
          try {
            listOrderPending.add(item);
          } catch (e) {
            print(e);
          }
        }
      });
    }

    return content.map((e) {
      return ThongTinDaoTaoTiengNhat.fromJson(e);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    setState(() {
      _setLoading = false;
    });
    try {
      //await countOrder();
      await countBySystem();
      await countUnion();
      await countStatusStopCooperating();
      await countStatusNeedAccess();
      await countStatusApproaching();
      await countStatusSignedAContract();
      await getListUnionByDueDateMax().then((value) => listUnionDueToFee = getUnionsDueDateToCollectTheFee(value));
      // await countStatusTTSTienCu();
      // await countStatusTTSTrungTuyen();
      // await getListUnionSearchBy().then((value) {
      //   listUnionDueToFee = getUnionsDueDateToCollectTheFee(value);
      // });
      await getMonthListToMonthCurrent();
      await getThongTinDaoTaoTiengNhat();
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _setLoading = true;
      });
    }
  }

  List<dynamic> calculateTheDateOfAppointmentAndCollectionDateForTheUnion(List<dynamic> list) {
    List<UnionDto> listUniOnDto = [];
    for (var item in listUnionObjectResult) {
      try {
        DateTime? chargeStartDate;
        DateTime? dueToCollectTheFeeDate;
        DateTime? appointmentDate;
        if (item.chargeStartDate != null) {
          chargeStartDate = DateTime.parse(item.chargeStartDate!);
          dueToCollectTheFeeDate = Jiffy(chargeStartDate).add(months: item.chargeCycleDate ?? 0).dateTime;
          // dueToCollectTheFeeDate = chargeStartDate.add(Duration(days: item.chargeCycleDate ?? 0));
          appointmentDate = Jiffy(dueToCollectTheFeeDate).subtract(months: item.chargeCycleDate ?? 0).dateTime;
          //appointmentDate = dueToCollectTheFeeDate.subtract(Duration(days: item.chargeWarningDate ?? 0));
          UnionDto dto = UnionDto(
              id: item.id!,
              orgCode: item.orgCode!,
              orgName: item.orgName!,
              deputy: item.deputy!,
              chargeStartDate: item.chargeStartDate!,
              chargeCycleDate: item.chargeCycleDate!,
              chargeWarningDate: item.chargeWarningDate!,
              dueDateToCollectTheFee: dueToCollectTheFeeDate, //Ngày đến hạn thu phí
              appointmentDate: appointmentDate //Ngày nhắc hạn
              );
          listUniOnDto.add(dto);
        }
      } catch (e) {
        print(item.orgCode.toString() + e.toString());
      }
    }

    return listUniOnDto;
  }

  List<dynamic> getUnionsDueDateToCollectTheFee(List<dynamic> list) {
    DateTime timeNow = DateTime.now();
    //DateTime timeNow = DateTime.parse('2023-06-24');
    DateTime? dateFrom;
    DateTime? dateTo;
    List<dynamic> listUnionDue = [];
    for (var item in list) {
      try {
        dateFrom = DateTime.parse(item['dueDate']).subtract(new Duration(days: item['nghiepdoan']['chargeWarningDate'] != null ? item['nghiepdoan']['chargeWarningDate'] : 7));
        dateTo = DateTime.parse(item['dueDate']);

        if (dateFrom.isBefore(timeNow) && dateTo.isAfter(timeNow)) {
          listUnionDue.add(item);
        }
      } catch (e) {
        print(e);
      }
    }
    return listUnionDue;
  }

  double heightBox = 100;
  @override
  Widget build(BuildContext context) {
    return Material(
      //chú ý thêm material nếu không code sẽ lỗi
      child: _setLoading
          ? ListView(
              controller: ScrollController(),
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
                  child: TitlePage(
                    listPreTitle: [
                      {'url': '/phat-trien-thi-truong', 'title': 'Dashboard'},
                    ],
                    content: 'Dashboard',
                  ),
                ),
                //========Bảng thống kê start========
                Container(
                  color: backgroundPage,
                  padding: EdgeInsets.symmetric(vertical: verticalPaddingPage, horizontal: horizontalPaddingPage),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Consumer<NavigationModel>(
                          builder: (context, navigationModel, child) => Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  //Các khối dữ liệu tổng quan ở trên đầu trang
                                  InkWell(
                                    onTap: () {
                                      navigationModel.add(pageUrl: "/quan-li-don-hang");
                                    },
                                    child: OverviewDataBox(
                                      bGColorIconBox: colorBGIconOverviewDataBox1,
                                      dataBox: numberOrder,
                                      titleBox: 'Đơn hàng',
                                      colorIconBox: colorWhite,
                                      iconBox: Icons.account_box,
                                      sizeIconBox: sizeIconOverviewDataBox,
                                    ),
                                  ),

                                  SizedBox(
                                    width: 30,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      navigationModel.add(pageUrl: "/quan-li-nghiep-doan");
                                    },
                                    child: OverviewDataBox(
                                      bGColorIconBox: colorBGIconOverviewDataBox2,
                                      dataBox: numberUnion,
                                      titleBox: 'Số lượng nghiệp đoàn',
                                      colorIconBox: colorWhite,
                                      iconBox: Icons.account_balance_wallet_sharp,
                                      sizeIconBox: sizeIconOverviewDataBox,
                                    ),
                                  ),
                                ],
                              )),
                      Row(
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
                                      Flexible(
                                        child: Tooltip(
                                          message: 'Báo cáo kết quả đào tạo của TTS chờ gửi nghiệp đoàn (theo đơn hàng)',
                                          child: Text(
                                            'Báo cáo kết quả đào tạo của TTS chờ gửi nghiệp đoàn (theo đơn hàng)',
                                            style: titleBox,
                                            maxLines: 1,
                                            softWrap: true,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
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
                                    width: 1000,
                                    height: 350,
                                    child: ListView(
                                      controller: ScrollController(),
                                      children: [
                                        Column(
                                          children: [
                                            if (listOrderPending.length > 0)
                                              for (int j = 0; j < listOrderPending.length; j++)
                                                Container(
                                                  padding: EdgeInsets.only(
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
                                                    onTap: () {
                                                      //thái coding
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            return ModelDanhSach(
                                                              orderId: listOrderPending[j].id,
                                                              order: listOrderPending[j],
                                                            );
                                                          });
                                                    },
                                                    child: Row(
                                                      children: [
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
                                                              "#${j + 1}",
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(color: Colors.white, fontSize: 15),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 20),
                                                        Flexible(
                                                          child: Text(
                                                            listOrderPending[j].orderCode + " - " + listOrderPending[j].orderName,
                                                            maxLines: 2,
                                                            softWrap: false,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                              color: Color.fromARGB(255, 22, 171, 221),
                                                              decoration: TextDecoration.underline,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                            else
                                              Center(
                                                child: Text("Không có dữ liệu phù hợp !"),
                                              )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //thông báo
                          SizedBox(
                            width: 30,
                          ),
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
                                      Flexible(
                                        child: Tooltip(
                                          message: 'Thông báo nghiệp đoàn đến hạn thu phí',
                                          child: Text(
                                            'Thông báo nghiệp đoàn đến hạn thu phí',
                                            style: titleBox,
                                            maxLines: 1,
                                            softWrap: false,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
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
                                    width: 1000,
                                    height: 350,
                                    child: ListView(
                                      children: [
                                        Column(
                                          children: [
                                            Container(
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(right: 30),
                                                    child: Container(
                                                        width: 30,
                                                        height: 30,
                                                        child: Center(
                                                          child: Text(
                                                            "STT",
                                                            textAlign: TextAlign.center,
                                                            style: titleBox,
                                                          ),
                                                        )),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      "Nghiệp đoàn",
                                                      maxLines: 2,
                                                      style: titleBox,
                                                      softWrap: false,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Expanded(flex: 1, child: Container()),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      "Ngày đến hạn",
                                                      maxLines: 2,
                                                      style: titleBox,
                                                      softWrap: false,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              child: Divider(
                                                thickness: 1,
                                                color: ColorHorizontalLine,
                                              ),
                                            ),
                                            if (listUnionDueToFee.isNotEmpty)
                                              for (int j = 0; j < listUnionDueToFee.length; j++)
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
                                                          padding: EdgeInsets.only(right: 30),
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
                                                                  "#${j + 1}",
                                                                  textAlign: TextAlign.center,
                                                                  style: TextStyle(color: Colors.white, fontSize: 15),
                                                                ),
                                                              )),
                                                        ),
                                                        Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                            listUnionDueToFee[j]['nghiepdoan']['orgCode'] + " - " + listUnionDueToFee[j]['nghiepdoan']['orgName'],
                                                            maxLines: 2,
                                                            softWrap: false,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                        Expanded(flex: 1, child: Container()),
                                                        Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                            getDateView(listUnionDueToFee[j]['dueDate']),
                                                            maxLines: 2,
                                                            softWrap: false,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    onTap: (() {}),
                                                  ),
                                                )
                                            else
                                              Center(child: Text("Không có dữ liệu phù hợp !"))
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        decoration: BoxDecoration(
                          color: colorWhite,
                          border: Border.all(
                            width: 1,
                            color: Color.fromARGB(255, 194, 194, 194),
                          ),
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
                        child: Row(
                          //biểu đồ
                          children: [
                            Expanded(
                              flex: 5,
                              child: Container(
                                margin: EdgeInsets.only(top: 30),
                                width: MediaQuery.of(context).size.width * 1,
                                height: heightBoxContainer,
                                child: PieChart(
                                  nameChart: "Nghiệp đoàn",
                                  listObjectPieChart: _lstDataUnionPieChart,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            Expanded(
                              flex: 5,
                              child: Container(
                                margin: marginTopBoxContainer,
                                width: MediaQuery.of(context).size.width * 1,
                                height: heightBoxContainer,
                                child: PieChart(
                                  nameChart: "TTS trúng tuyển/TTS tiến cử",
                                  listObjectPieChart: _lstDataTTSPieChart,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        //biểu đồ
                        children: [
                          Expanded(
                            flex: 6,
                            // child: PieChart(),
                            child: BieuDo(listMonth: _listMonth, chartData: chartData),
                          ),
                        ],
                      ),
                      Footer(),
                    ],
                  ),
                ),
                //========Bảng thống kê end========
              ],
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

//---biểu đồ đường CTV

class BieuDo extends StatelessWidget {
  final List<int>? listMonth;
  final List<ChartDataByMonth>? chartData;
  BieuDo({Key? key, this.listMonth, this.chartData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(30),
      margin: EdgeInsets.only(top: 30),
      width: MediaQuery.of(context).size.width * 1,
      height: 450,
      // margin: EdgeInsets.fromLTRB(30, 40, 0, 0),
      decoration: BoxDecoration(
        color: colorWhite,
        border: Border.all(
          width: 1,
          color: Color.fromARGB(255, 194, 194, 194),
        ),
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
            'Số lượng đơn hàng(Theo ngày phát hành)',
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
                  dataSource: chartData!,
                  xValueMapper: (ChartDataByMonth data, _) => data.x,
                  yValueMapper: (ChartDataByMonth data, _) => data.y,
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

class OverviewDataBox extends StatefulWidget {
  final String titleBox;
  final int dataBox;
  final IconData iconBox;
  final Color colorIconBox;
  final Color bGColorIconBox;
  final double sizeIconBox;

  const OverviewDataBox(
      {Key? key, required this.titleBox, required this.dataBox, required this.iconBox, required this.colorIconBox, required this.bGColorIconBox, required this.sizeIconBox})
      : super(key: key);

  @override
  State<OverviewDataBox> createState() => _OverviewDataBoxState();
}

class _OverviewDataBoxState extends State<OverviewDataBox> {
  final double heightBox = 100;
  @override
  Widget build(BuildContext context) {
    return Container(
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
                        Text(
                          widget.dataBox.toString(),
                          style: dataOverviewDataBox,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
