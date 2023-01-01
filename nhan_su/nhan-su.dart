import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../api.dart';
import '../../../common/style.dart';
import '../../../common/widgets_form.dart';
import '../../../model/model.dart';
import '../../forms/nhan_su/setting-data/interview.dart';
import '../../forms/nhan_su/setting-data/userAAM.dart';
import '../navigation.dart';

class NhanSu extends StatefulWidget {
  const NhanSu({Key? key}) : super(key: key);

  @override
  _NhanSuState createState() => _NhanSuState();
}

class _NhanSuState extends State<NhanSu> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: NhanSuBody());
  }
}

class NhanSuBody extends StatefulWidget {
  const NhanSuBody({Key? key}) : super(key: key);

  @override
  // ignore: override_on_non_overriding_member
  State<NhanSuBody> createState() => _NhanSuBodyState();
}

class _NhanSuBodyState extends State<NhanSuBody> {
  List<Interview> listInterViews = [];
  late Future<List<Interview>> futureLPV;
  Future<List<Interview>> getLPV1() async {
    var response5 = await httpGet("/api/tuyendung-phongvan/get/page?size=5&page=0&sort=status&sort=interviewTime,desc", context);
    if (response5.containsKey("body")) {
      var resultLPV = jsonDecode(response5["body"]);
      var content = resultLPV['content'];
      setState(() {
        for (var item in content) {
          Interview e = new Interview(
            id: item['id'],
            title: item['tuyendung']['title'],
            interviewTime: item['interviewTime'],
          );
          listInterViews.add(e);
        }
      });
      return listInterViews;
    } else
      throw Exception('Không có data');
  }

  int sum = 0;
  getLPV(String startDay, String endDay) async {
    var resultLPV = {};
    var response5 =
        await httpGet("/api/tuyendung-phongvan/get/page?filter=status:1 and interviewTime > '$startDay' and interviewTime < '$endDay'", context);
    if (response5.containsKey("body")) {
      resultLPV = jsonDecode(response5["body"]);
      if (resultLPV['content'] != null) sum = resultLPV['content'].length;
      setState(() {});

      return sum;
    }
    return sum;
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

  late Future<List<UserAAM>> futureListUerAAM;
  List<UserAAM> listUserAAM = [];
  int? selectedNVTD;
  int sumNV = 0;
  Future<List<UserAAM>> getListUser() async {
    var response2 = await httpGet("/api/nguoidung/get/page?filter=isAam:1 and isBlocked:0 &sort=dateInCompany,desc", context);
    var body = jsonDecode(response2['body']);
    var content = [];

    if (response2.containsKey("body")) {
      setState(() {
        content = body['content'];
        sumNV = body['totalElements'];
        for (var element in content) {
          if (element['departId'] != 1 && element['departId'] != 2) {
            UserAAM item = UserAAM(
              id: element['id'] ?? 0,
              userCode: element['userCode'] ?? "",
              userName: element['userName'] ?? "",
              fullName: element['fullName'] ?? "",
              avatar: element['avatar'] ?? "",
              qrcodeUrl: element['qrcodeUrl'],
              birthDate: element['birthDate'] ?? "-----------",
              timeKeepingCode: element['timeKeepingCode'] ?? "",
              gender: element['gender'] ?? 0,
              phone: element['phone'] ?? "",
              email: element['email'] ?? "",
              address: element['address'] ?? "",
              hometown: element['hometown'] ?? "",
              residence: element['residence'] ?? "",
              departId: element['departId'] ?? 0,
              departName: (element['phongban'] != null) ? element['phongban']['departName'] : "",
              teamId: element['teamId'] ?? 0,
              teamName: (element['doinhom'] != null) ? element['doinhom']['departName'] : "",
              dutyId: element['dutyId'] ?? 0,
              dutyName: (element['vaitro'] != null) ? element['vaitro']['name'] : "",
              maritalStatus: element['maritalStatus'] ?? 0,
              issuedDate: element['issuedDate'] ?? "",
              issuedBy: element['issuedBy'] ?? "",
              idCardNo: element['idCardNo'] ?? "",
              dateInCompany: element['dateInCompany'] ?? "",
              hsSource: element['hsSource'] ?? "",
              pnBhxh: element['pnBhxh'] ?? "",
              mst: element['mst'] ?? "",
              device: element['device'] ?? "",
              nbProvince: element['nbProvince'] ?? "",
              note: element['note'] ?? "",
              bankAccountName: element['bankAccountName'] ?? "",
              bankNumber: element['bankNumber'] ?? "",
              bankName: element['bankName'] ?? "",
              bankBranch: element['bankBranch'] ?? "",
              isBlocked: element['isBlocked'] ?? 0,
              blockedReason: element['blockedReason'] ?? "",
              nhansuTuyendungId: element['nhansuTuyendungId'] ?? 0,
              refUrl: element['refUrl'] ?? "",
            );
            listUserAAM.add(item);
            // print("listUserAAM:${item.fullName}");
          }
        }
      });
      for (var item in listUserAAM) {
        if (item.dateInCompany != "" && item.dateInCompany != null) {
          DateTime dateInCompany = DateTime.parse(item.dateInCompany.toString()).toLocal();
          if (dateInCompany.year == DateTime.now().toLocal().year) {
            if (dateInCompany.month <= DateTime.now().toLocal().month) {
              chartData[dateInCompany.month - 1].y += 1;
            }
          }
        }
      }
    }
    return content.map((e) {
      return UserAAM.fromJson(e);
    }).toList();
  }

  var startDay;
  var endDay;
  bool checkStatus = false;
  late int monthNow;
  List<ChartData1> chartData = [];
  void callAPI() async {
    monthNow = DateTime.now().toLocal().month;
    for (var i = 0; i < monthNow; i++) {
      chartData.add(ChartData1(x: "Tháng ${i + 1}", y: 0));
    }
    await getListUser();
    await getLPV1();
    await getLPV(startDay, endDay);
    setState(() {
      checkStatus = true;
    });
  }

  @override
  void initState() {
    super.initState();
    DateTime timeNow = DateTime(DateTime.now().toLocal().year, DateTime.now().toLocal().month);

    if (timeNow.month > 9) {
      startDay = "01-${timeNow.month}-${timeNow.year}";
      endDay = getDateInMonth(timeNow.month, timeNow.year).toString() + "-${timeNow.month}-${timeNow.year}";
    } else {
      startDay = "01-0${timeNow.month}-${timeNow.year}";
      endDay = getDateInMonth(timeNow.month, timeNow.year).toString() + "-0${timeNow.month}-${timeNow.year}";
    }
    callAPI();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: userRule('/nhan-su', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return Container(
              child: (checkStatus)
                  ? ListView(
                      controller: ScrollController(),
                      children: [
                        TitlePage(
                          listPreTitle: [
                            {'url': "/dashboard", 'title': 'Trang chủ'},
                            // {'url': "/cham-cong", 'title': 'Chấm công'},
                          ],
                          content: 'Bảng thống kê nhanh',
                        ),
                        Container(
                          color: backgroundPage,
                          padding: EdgeInsets.symmetric(vertical: verticalPaddingPage, horizontal: horizontalPaddingPage),
                          child: Container(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: backgroundPage,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(""),
                                    ),
                                    Expanded(
                                      child: Container(
                                        width: MediaQuery.of(context).size.width * 0.25,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: colorWhite,
                                          borderRadius: borderRadiusContainer,
                                          boxShadow: [boxShadowContainer],
                                          border: borderAllContainerBox,
                                        ),
                                        child: TextButton(
                                          onPressed: () => {Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/ho-so-nhan-su")},
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
                                                        color: colorBGIconOverviewDataBox1,
                                                        borderRadius: borderRadiusIconOverviewDataBox,
                                                      ),
                                                      child: Icon(
                                                        Icons.account_box,
                                                        color: colorWhite,
                                                        size: sizeIconOverviewDataBox,
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
                                                              'Tổng số nhân viên',
                                                              style: titleOverviewDataBox,
                                                              maxLines: 2,
                                                              softWrap: false,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                            SizedBox(
                                                              height: 8,
                                                            ),
                                                            Text(
                                                              "$sumNV",
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
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      child: Container(
                                        width: MediaQuery.of(context).size.width * 0.25,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: colorWhite,
                                          borderRadius: borderRadiusContainer,
                                          boxShadow: [boxShadowContainer],
                                          border: borderAllContainerBox,
                                        ),
                                        child: TextButton(
                                          onPressed: () =>
                                              {Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/chi-tieu-tuyen-dung")},
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
                                                        color: colorBGIconOverviewDataBox1,
                                                        borderRadius: borderRadiusIconOverviewDataBox,
                                                      ),
                                                      child: Icon(
                                                        Icons.receipt_long,
                                                        color: colorWhite,
                                                        size: sizeIconOverviewDataBox,
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
                                                              'Lịch đã phỏng vấn tháng ${DateFormat("MM-yyyy").format(DateTime.now())}',
                                                              style: titleOverviewDataBox,
                                                              maxLines: 2,
                                                              softWrap: false,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                            SizedBox(
                                                              height: 8,
                                                            ),
                                                            Text(
                                                              "$sum",
                                                              style: dataOverviewDataBox,
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
                                    ),
                                    Expanded(
                                      child: Text(""),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                child: Center(
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * 1,
                                    margin: EdgeInsets.only(top: 30, left: 25, right: 25),
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
                                              'Số lượng nhân viên ${DateTime.now().year}',
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
                                            title: ChartTitle(
                                                text: '',
                                                alignment: ChartAlignment.near,
                                                textStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                )),
                                            primaryXAxis: CategoryAxis(),
                                            tooltipBehavior: TooltipBehavior(enable: true),
                                            series: <ChartSeries>[
                                              LineSeries<ChartData1, String>(
                                                name: 'Nhân viên',
                                                dataSource: chartData,
                                                xValueMapper: (ChartData1 data, _) => data.x,
                                                yValueMapper: (ChartData1 data, _) => data.y,
                                                dataLabelSettings:
                                                    DataLabelSettings(isVisible: true, textStyle: TextStyle(fontSize: 13, color: Colors.blue)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                // crossAxisAlignment: CrossAxisAlignment.start,
                                // mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: paddingBoxContainer,
                                      margin: EdgeInsets.only(
                                        top: 30,
                                        left: 20,
                                      ),
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
                                                'Nhân sự mới',
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
                                          (listUserAAM.length > 4)
                                              ? Column(
                                                  children: [
                                                    for (int j = 0; j < 5; j++)
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
                                                                        style: TextStyle(color: Colors.white, fontSize: 15),
                                                                      ),
                                                                    )),
                                                              ),
                                                              SizedBox(width: 20),
                                                              Flexible(
                                                                child: Text(
                                                                  "Nhân sự ${listUserAAM[j].userCode}-${listUserAAM[j].fullName} thuộc phòng ban ${listUserAAM[j].departName} gia nhập ngày ${(listUserAAM[j].dateInCompany != null && listUserAAM[j].dateInCompany != "") ? DateFormat('dd-MM-yyyy').format(DateTime.parse(listUserAAM[j].dateInCompany.toString())) : ""}",
                                                                  softWrap: false,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          onTap: (() {
                                                            Provider.of<NavigationModel>(context, listen: false)
                                                                .add(pageUrl: "/view-hsns/${listUserAAM[j].id}");
                                                          }),
                                                        ),
                                                      ),
                                                    Container(
                                                      margin: EdgeInsets.only(top: 18),
                                                      child: TextButton(
                                                        onPressed: () {
                                                          Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/ho-so-nhan-su");
                                                        },
                                                        child: Text(
                                                          'Xem thêm',
                                                          style: TextStyle(
                                                            color: Color(0xffF577C74),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Column(
                                                  children: [
                                                    for (int j = 0; j < listUserAAM.length; j++)
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
                                                                        // '${}',
                                                                        textAlign: TextAlign.center,
                                                                        style: TextStyle(color: Colors.white, fontSize: 15),
                                                                      ),
                                                                    )),
                                                              ),
                                                              SizedBox(width: 20),
                                                              Flexible(
                                                                child: Text(
                                                                  "Nhân sự ${listUserAAM[j].userCode}-${listUserAAM[j].fullName} thuộc phòng ban ${listUserAAM[j].departName} gia nhập ngày ${(listUserAAM[j].dateInCompany != null && listUserAAM[j].dateInCompany != "") ? DateFormat('dd-MM-yyyy').format(DateTime.parse(listUserAAM[j].dateInCompany.toString())) : ""}",
                                                                  softWrap: false,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          onTap: (() {
                                                            Provider.of<NavigationModel>(context, listen: false)
                                                                .add(pageUrl: "/view-hsns/${listUserAAM[j].id}");
                                                          }),
                                                        ),
                                                      ),
                                                    Container(
                                                      margin: EdgeInsets.only(top: 18),
                                                      child: TextButton(
                                                        onPressed: () {
                                                          Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/ho-so-nhan-su");
                                                        },
                                                        child: Text(
                                                          'Xem thêm',
                                                          style: TextStyle(
                                                            color: Color(0xffF577C74),
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
                                  Expanded(
                                    child: Container(
                                      padding: paddingBoxContainer,
                                      margin: EdgeInsets.only(
                                        top: 30,
                                        left: 20,
                                        right: 20,
                                      ),
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
                                                'Lịch phỏng vấn',
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
                                          // listInterViews
                                          (listInterViews.length > 4)
                                              ? Column(
                                                  children: [
                                                    for (int j = 0; j < 5; j++)
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
                                                                        // '${}',
                                                                        textAlign: TextAlign.center,
                                                                        style: TextStyle(color: Colors.white, fontSize: 15),
                                                                      ),
                                                                    )),
                                                              ),
                                                              SizedBox(width: 20),
                                                              Flexible(
                                                                  // fit: FlexFit.tight,
                                                                  child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    '${listInterViews[j].title} ',
                                                                    softWrap: true,
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Text(
                                                                    "${DateFormat('hh:mm a dd-MM-yyyy').format(DateTime.parse(listInterViews[j].interviewTime.toString()).toLocal())}",
                                                                    softWrap: false,
                                                                    overflow: TextOverflow.ellipsis,
                                                                  )
                                                                ],
                                                              )),
                                                            ],
                                                          ),
                                                          onTap: (() {
                                                            Provider.of<NavigationModel>(context, listen: false)
                                                                .add(pageUrl: "/view-lpv" + "/${listInterViews[j].id}");
                                                          }),
                                                        ),
                                                      ),
                                                    Container(
                                                      margin: EdgeInsets.only(top: 18),
                                                      child: TextButton(
                                                        onPressed: () {
                                                          Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/lich-phong-van");
                                                        },
                                                        child: Text(
                                                          'Xem thêm',
                                                          style: TextStyle(
                                                            color: Color(0xffF577C74),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : (listInterViews.length > 0)
                                                  ? Column(
                                                      children: [
                                                        for (int j = 0; j < listInterViews.length; j++)
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
                                                                            // '${}',
                                                                            textAlign: TextAlign.center,
                                                                            style: TextStyle(color: Colors.white, fontSize: 15),
                                                                          ),
                                                                        )),
                                                                  ),
                                                                  SizedBox(width: 20),
                                                                  Flexible(
                                                                      // fit: FlexFit.tight,
                                                                      child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                        '${listInterViews[j].title} ',
                                                                        softWrap: true,
                                                                        overflow: TextOverflow.ellipsis,
                                                                      ),
                                                                      SizedBox(
                                                                        width: 10,
                                                                      ),
                                                                      Text(
                                                                        "${DateFormat('hh:mm a dd-MM-yyyy').format(DateTime.parse(listInterViews[j].interviewTime.toString()))}",
                                                                        softWrap: false,
                                                                        overflow: TextOverflow.ellipsis,
                                                                      )
                                                                    ],
                                                                  )),
                                                                ],
                                                              ),
                                                              onTap: (() {
                                                                Provider.of<NavigationModel>(context, listen: false)
                                                                    .add(pageUrl: "/view-lpv" + "/${listInterViews[j].id}");
                                                              }),
                                                            ),
                                                          ),
                                                        Container(
                                                          margin: EdgeInsets.only(top: 18),
                                                          child: TextButton(
                                                            onPressed: () {
                                                              Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/lich-phong-van");
                                                            },
                                                            child: Text(
                                                              'Xem thêm',
                                                              style: TextStyle(
                                                                color: Color(0xffF577C74),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : Text("")
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )),
                        ),
                        Footer(marginFooter: EdgeInsets.only(top: 5), paddingFooter: EdgeInsets.all(15)),
                        SizedBox(height: 20)
                      ],
                    )
                  : Center(child: CircularProgressIndicator()));
        } else if (listRule.hasError) {
          return Text('${listRule.error}');
        }

        // By default, show a loading spinner.
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

//  FutureBuilder(
//     future: futureLPV,
//     builder: (context, snapshot) {
//       if (snapshot.hasData) {

//       } else if (snapshot.hasError) {
//         return Text('${snapshot.error}');
//       }
//       // By default, show a loading spinner.
//       return const CircularProgressIndicator();
//     },
//   )

// getLPV() async {
//   var getLPV1 = await httpGet("/api/tuyendung-phongvan/get/page?filter=id:${widget.idLPV}", context);
//   if (getLPV1.containsKey("body")) {
//     // soLuongDaTuyen.text = resultLPV["content"][0]['qtyRecruited'];
//       resultLPV = jsonDecode(getLPV1["body"]);
//     setState(() {
//       for (var element in resultLPV["content"]) {
//         diaDiem.text = element['interviewAddress'];
//       yeuCauChiTiet.text = element['jobDesc'];
//       soLuongDaTuyen.text = element['qtyRecruited'].toString();
//       timePV = element['interviewTime'];
//       timeDayPV = timePV.toString().substring(0, 10);
//       timeHoursPV = timePV.toString().substring(11, 16);
//       }

//     });

//     return resultLPV;
//   }
// }
class ChartData1 {
  String x;
  int y;
  ChartData1({required this.x, required this.y});
}
