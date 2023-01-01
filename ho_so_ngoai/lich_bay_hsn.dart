import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import "package:collection/collection.dart";

import 'package:gentelella_flutter/common/widgets_form.dart';
import 'package:gentelella_flutter/model/model.dart';
import 'package:gentelella_flutter/widgets/ui/ho_so_ngoai/datahsn/donhang.dart';
import 'package:gentelella_flutter/widgets/ui/ho_so_ngoai/datahsn/lichbay_chitiet.dart';
import 'package:gentelella_flutter/widgets/ui/ho_so_ngoai/datahsn/nghiepdoan.dart';
import 'package:gentelella_flutter/widgets/ui/ho_so_ngoai/datahsn/xinghiep.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../common/dynamic_table.dart';
import '../../../common/style.dart';
import '../../../common/toast.dart';
import '../navigation.dart';
import 'package:gentelella_flutter/api.dart';

import '../trung_tam_dao_tao/danh_sach_thuc_tap_sinh/form_thong_tin_dao_tao.dart';

class LichBayHoSoNgoai extends StatefulWidget {
  const LichBayHoSoNgoai({Key? key}) : super(key: key);

  @override
  _LichBayHoSoNgoaiState createState() => _LichBayHoSoNgoaiState();
}

class _LichBayHoSoNgoaiState extends State<LichBayHoSoNgoai> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: LichBayHoSoNgoaiBody());
  }
}

class LichBayHoSoNgoaiBody extends StatefulWidget {
  const LichBayHoSoNgoaiBody({Key? key}) : super(key: key);

  @override
  State<LichBayHoSoNgoaiBody> createState() => _LichBayHoSoNgoaiBodyState();
}

class _LichBayHoSoNgoaiBodyState extends State<LichBayHoSoNgoaiBody> {
  var body = {};
  var page = 1;
  late int rowCount = 0;
  int currentPageDef = 1;
  int rowPerPage = 10;
  var listLichBay;
  late Future<dynamic> futurelistLichBay;
  List<bool> _selectedDataRow = [];
  TextEditingController tenSV = TextEditingController();
  String searchLB = "";

  var time1;
  var time2;
  List listSelected = [];
  List<dynamic> listDungXuLy = [];
  getlistLichBay(curentPage) async {
    var response;
    String query = '';
    if (time1 != null && time2 == null) {
      query = "flightDate>:'$time1'";
    } else if (time1 == null && time2 != null) {
      query = "flightDate<:'$time2'";
    } else if (time1 != null && time2 != null) {
      query = "flightDate>:'$time1' and flightDate<:'$time2'";
    }
    response = await httpGet(
        "/api/lichxuatcanh/get/page?page=${curentPage - 1}&size=$rowPerPage&filter=$query",
        context);
    if (response.containsKey("body")) {
      setState(() {
        listLichBay = jsonDecode(response['body'])['content'];
        rowCount = jsonDecode(response['body'])['totalElements'];
      });
      return listLichBay;
    }
    return listLichBay;
  }

  String titleLog = '';
  deleteLxc(row) async {
    print(
        "Lịch bay ${row['title']} vào thời gian: ${displayTimeStamp(row['flightDate']) + " ngày " + dateReverse(displayDateTimeStamp(row['flightDate']))} đã bị hủy");
    int beforeStatus = row['status'];
    row['status'] = 3;
    var response =
        await httpPut('/api/lichxuatcanh/put/${row['id']}', row, context);
    if (response['body'] == "true") {
      titleLog = 'Cập nhật dữ liệu thành công';
      if (beforeStatus == 1) {
        await httpPost(
            "/api/push/tags/depart_id/3&4&8",
            {
              "title": "Hệ thống thông báo",
              "message":
                  "Lịch bay ${row['title']} vào thời gian: ${DateFormat("hh:mm dd/MM/yyyy").format(DateTime.parse(row['flightDate']))} đã bị hủy"
            },
            context);
        var response2 = await httpGet(
            "/api/lichxuatcanh-chitiet/get/page?filter=flightScheduleId:${row['id']}",
            context);
        if (response2.containsKey("body")) {
          var listTtsXc = jsonDecode(response2['body'])['content'];
          for (var tts in listTtsXc) {
            if (tts['thuctapsinh']['nhanvientuyendung'] != null) {
              await httpPost(
                  "/api/push/tags/user_code/${tts['thuctapsinh']['nhanvientuyendung']['userCode']}",
                  {
                    "title": "Hệ thống thông báo",
                    "message":
                        "Lịch bay ${row['title']} vào thời gian: ${displayTimeStamp(row['flightDate']) + " ngày " + dateReverse(displayDateTimeStamp(row['flightDate']))} đã bị hủy"
                  },
                  context);
            }
            await httpPost(
                "/api/push/tags/user_code/${tts['thuctapsinh']['userCode']}",
                {
                  "title": "Hệ thống thông báo",
                  "message":
                      "Lịch bay vào thời gian: ${displayTimeStamp(row['flightDate']) + " ngày " + dateReverse(displayDateTimeStamp(row['flightDate']))} của bạn đã bị hủy"
                },
                context);
          }
        }
      }
    } else {
      titleLog = 'Cập nhật thất bại';
    }
    return titleLog;
  }

  confirmFly(row) async {
    row['status'] = 1;
    var response =
        await httpPut('/api/lichxuatcanh/put/${row['id']}', row, context);
    if (response['body'] == "true") {
      titleLog = 'Cập nhật dữ liệu thành công';
      await httpPost(
          "/api/push/tags/user_type/aam",
          {
            "title": "Hệ thống thông báo",
            "message":
                "Lịch bay ${row['title']} đã được chốt bay vào thời gian: ${displayTimeStamp(row['flightDate']) + " ngày " + dateReverse(displayDateTimeStamp(row['flightDate']))}"
          },
          context);
      var response2 = await httpGet(
          "/api/lichxuatcanh-chitiet/get/page?filter=flightScheduleId:${row['id']}",
          context);
      if (response2.containsKey("body")) {
        var listTtsXc = jsonDecode(response2['body'])['content'];
        for (var tts in listTtsXc) {
          if (tts['thuctapsinh']['nhanvientuyendung'] != null) {
            await httpPost(
                "/api/push/tags/user_code/${tts['thuctapsinh']['nhanvientuyendung']['userCode']}",
                {
                  "title": "Hệ thống thông báo",
                  "message":
                      "TTS mã ${tts['thuctapsinh']['userCode']}-${tts['thuctapsinh']['fullName']} đã được chốt lịch bay vào thời gian: ${displayTimeStamp(row['flightDate']) + " ngày " + dateReverse(displayDateTimeStamp(row['flightDate']))}"
                },
                context);
          }
          await httpPost(
              "/api/push/tags/user_code/${tts['thuctapsinh']['userCode']}",
              {
                "title": "Hệ thống thông báo",
                "message":
                    "Bạn đã được chốt lịch bay vào thời gian: ${displayTimeStamp(row['flightDate']) + " ngày " + dateReverse(displayDateTimeStamp(row['flightDate']))} "
              },
              context);
          print(
              "Bạn đã được chốt lịch bay vào thời gian: ${displayTimeStamp(row['flightDate']) + " ngày " + dateReverse(displayDateTimeStamp(row['flightDate']))} ");
        }
      }
    } else {
      titleLog = 'Cập nhật thất bại';
    }
    return titleLog;
  }

  @override
  void initState() {
    super.initState();
    futurelistLichBay = getlistLichBay(1);
    listSelected = [];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: userRule('/lich-bay', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return Consumer<NavigationModel>(
            builder: (context, navigationModel, child) => ListView(
              children: [
                TitlePage(
                  listPreTitle: [
                    {'url': '/ho-so-ngoai', 'title': 'Dashboard'},
                  ],
                  content: "Danh sách lịch bay",
                ),
                FutureBuilder(
                  future: futurelistLichBay,
                  builder: (context, snapshot) {
                    double screenwidth = MediaQuery.of(context).size.width;
                    if (snapshot.hasData) {
                      var tableIndex = (currentPageDef - 1) * rowPerPage + 1;
                      return Container(
                        color: backgroundPage,
                        padding: EdgeInsets.symmetric(
                            vertical: verticalPaddingPage,
                            horizontal: horizontalPaddingPage),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 1,
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: DatePickerBox1(
                                            requestDayBefore: time2,
                                            isTime: false,
                                            label: Text('Từ ngày:',
                                                style: titleWidgetBox),
                                            dateDisplay: time1,
                                            selectedDateFunction: (day) {
                                              time1 = day;
                                              setState(() {});
                                            }),
                                      ),
                                      SizedBox(width: 100),
                                      Expanded(
                                        flex: 3,
                                        child: DatePickerBox1(
                                            requestDayAfter: time1,
                                            isTime: false,
                                            label: Text('Đến ngày:',
                                                style: titleWidgetBox),
                                            dateDisplay: time1,
                                            selectedDateFunction: (day) {
                                              time2 = day;
                                              setState(() {});
                                            }),
                                      ),
                                      Expanded(flex: 1, child: Container()),
                                    ],
                                  ),
                                  SizedBox(height: 50),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(left: 20),
                                        child: TextButton.icon(
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 20.0,
                                                horizontal: 10.0),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0)),
                                            backgroundColor:
                                                Color.fromRGBO(245, 117, 29, 1),
                                            primary: Theme.of(context)
                                                .iconTheme
                                                .color,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .caption
                                                ?.copyWith(
                                                    fontSize: 10.0,
                                                    letterSpacing: 2.0),
                                          ),
                                          onPressed: () {
                                            futurelistLichBay =
                                                getlistLichBay(1);
                                          },
                                          icon: Transform.rotate(
                                            angle: 270,
                                            child: Icon(Icons.search,
                                                color: Colors.white, size: 15),
                                          ),
                                          label: Row(
                                            children: [
                                              Text('Tìm kiếm ',
                                                  style: textButton)
                                            ],
                                          ),
                                        ),
                                      ),
                                      getRule(listRule.data, Role.Them, context)
                                          ? Consumer<NavigationModel>(
                                              builder: (context,
                                                      navigationModel, child) =>
                                                  Container(
                                                margin:
                                                    EdgeInsets.only(left: 20),
                                                child: TextButton.icon(
                                                  style: TextButton.styleFrom(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 20.0,
                                                        horizontal: 10.0),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.0),
                                                    ),
                                                    backgroundColor:
                                                        Color.fromRGBO(
                                                            245, 117, 29, 1),
                                                    primary: Theme.of(context)
                                                        .iconTheme
                                                        .color,
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .caption
                                                        ?.copyWith(
                                                            fontSize: 10.0,
                                                            letterSpacing: 2.0),
                                                  ),
                                                  onPressed: () {
                                                    Provider.of<NavigationModel>(
                                                            context,
                                                            listen: false)
                                                        .add(
                                                            pageUrl:
                                                                "/them-moi-cap-nhat-lich-bay");
                                                  },
                                                  icon: Icon(Icons.add,
                                                      color: Colors.white,
                                                      size: 15),
                                                  label: Row(
                                                    children: [
                                                      Text('Thêm mới',
                                                          style: textButton)
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            //--------------------table--------------------

                            Container(
                              width: MediaQuery.of(context).size.width * 1,
                              margin: marginTopBoxContainer,
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Danh sách lịch bay',
                                          style: titleBox),
                                      Icon(Icons.more_horiz,
                                          color: Color(0xff9aa5ce), size: 14),
                                    ],
                                  ),
                                  //Đường line
                                  Container(
                                    margin: EdgeInsets.only(top: 10),
                                    child: Divider(
                                        thickness: 1,
                                        color: ColorHorizontalLine),
                                  ),
                                  if (snapshot.hasData)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: DataTable(
                                              columnSpacing:
                                                  MediaQuery.of(context)
                                                              .size
                                                              .width <
                                                          1600
                                                      ? 10
                                                      : 20,
                                              showCheckboxColumn: false,
                                              columns: [
                                                DataColumn(
                                                    label: Text(
                                                  'STT',
                                                  style: titleTableData,
                                                  textAlign: TextAlign.center,
                                                )),
                                                DataColumn(
                                                    label: Text(
                                                  'Tiêu đề',
                                                  style: titleTableData,
                                                  textAlign: TextAlign.center,
                                                )),
                                                DataColumn(
                                                    label: Text(
                                                  'Thời gian xuất cảnh',
                                                  style: titleTableData,
                                                  textAlign: TextAlign.center,
                                                )),
                                                DataColumn(
                                                    label: Text(
                                                  'Hành động',
                                                  style: titleTableData,
                                                  textAlign: TextAlign.center,
                                                )),
                                                DataColumn(
                                                    label: Expanded(
                                                  child: Text(
                                                    'Trạng thái',
                                                    style: titleTableData,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                )),
                                              ],
                                              rows: <DataRow>[
                                                for (var row in listLichBay)
                                                  DataRow(cells: [
                                                    DataCell(Text(
                                                        '${tableIndex++}')),
                                                    DataCell(Text(
                                                        row['title'] ?? '')),
                                                    DataCell(Row(
                                                      children: [
                                                        Text(
                                                          displayTimeStamp(row[
                                                                  'flightDate']) +
                                                              " ",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red),
                                                        ),
                                                        Text(
                                                          dateReverse(
                                                              displayDateTimeStamp(
                                                                  row['flightDate'])),
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xff459A88)),
                                                        )
                                                      ],
                                                    )),
                                                    DataCell(Row(
                                                      children: [
                                                        getRule(
                                                                listRule.data,
                                                                Role.Xem,
                                                                context)
                                                            ? Container(
                                                                child: InkWell(
                                                                    onTap: () {
                                                                      Provider.of<NavigationModel>(
                                                                              context,
                                                                              listen: false)
                                                                          .add(pageUrl: "/thong-tin-lb/${row['id']}");
                                                                    },
                                                                    child: Icon(
                                                                        Icons
                                                                            .visibility)))
                                                            : Container(),
                                                        getRule(
                                                                listRule.data,
                                                                Role.Sua,
                                                                context)
                                                            ? Container(
                                                                margin: EdgeInsets
                                                                    .fromLTRB(
                                                                        10,
                                                                        0,
                                                                        0,
                                                                        0),
                                                                child: Tooltip(
                                                                  message: row[
                                                                              'status'] ==
                                                                          2
                                                                      ? "Lịch bay đã hoàn thành"
                                                                      : row['status'] ==
                                                                              3
                                                                          ? 'Lịch bay đã hủy'
                                                                          : row['status'] == 1
                                                                              ? 'Lịch bay đã chốt không được chỉnh sửa'
                                                                              : '',
                                                                  child: InkWell(
                                                                      onTap: row['status'] == 2 || row['status'] == 3 || row['status'] == 1
                                                                          ? null
                                                                          : () {
                                                                              Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/them-moi-cap-nhat-lich-bay/${row['id']}");
                                                                            },
                                                                      child: Icon(Icons.edit_calendar, color: row['status'] == 2 || row['status'] == 3 || row['status'] == 1 ? Colors.grey : Color(0xff009C87))),
                                                                ))
                                                            : Container(),
                                                        getRule(
                                                                listRule.data,
                                                                Role.Xoa,
                                                                context)
                                                            ? Container(
                                                                margin: EdgeInsets
                                                                    .fromLTRB(
                                                                        10,
                                                                        0,
                                                                        0,
                                                                        0),
                                                                child: Tooltip(
                                                                  message: row[
                                                                              'status'] ==
                                                                          2
                                                                      ? "Lịch bay đã hoàn thành"
                                                                      : row['status'] ==
                                                                              3
                                                                          ? 'Lịch bay đã hủy'
                                                                          : '',
                                                                  child:
                                                                      InkWell(
                                                                    onTap: row['status'] ==
                                                                                2 ||
                                                                            row['status'] ==
                                                                                3
                                                                        ? null
                                                                        : () {
                                                                            showDialog(
                                                                              context: context,
                                                                              builder: (BuildContext context) => ConfirmUpdate(
                                                                                  title: "Xác nhận hủy lịch bay",
                                                                                  function: () async {
                                                                                    await deleteLxc(row);
                                                                                    futurelistLichBay = getlistLichBay(currentPageDef);
                                                                                    showToast(
                                                                                      context: context,
                                                                                      msg: titleLog,
                                                                                      color: titleLog == "Cập nhật dữ liệu thành công" ? Color.fromARGB(136, 72, 238, 67) : Colors.red,
                                                                                      icon: titleLog == "Cập nhật dữ liệu thành công" ? Icon(Icons.done) : Icon(Icons.warning),
                                                                                    );
                                                                                    Navigator.pop(context);
                                                                                  },
                                                                                  content: "Bạn có muốn hủy lịch bay này không"),
                                                                            );
                                                                          },
                                                                    child: Icon(
                                                                      Icons
                                                                          .close,
                                                                      color: row['status'] == 2 ||
                                                                              row['status'] ==
                                                                                  3
                                                                          ? Colors
                                                                              .grey
                                                                          : Colors
                                                                              .red,
                                                                    ),
                                                                  ),
                                                                ))
                                                            : Container()
                                                      ],
                                                    )),
                                                    DataCell(
                                                      getRule(listRule.data,
                                                              Role.Sua, context)
                                                          ? row['status'] == 3
                                                              ? Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text(
                                                                        'Đã hủy lịch'),
                                                                  ],
                                                                )
                                                              : row['status'] ==
                                                                      2
                                                                  ? Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Text(
                                                                            "Đã hoàn thành"),
                                                                      ],
                                                                    )
                                                                  : Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Container(
                                                                          child:
                                                                              TextButton(
                                                                            style:
                                                                                TextButton.styleFrom(
                                                                              padding: const EdgeInsets.symmetric(
                                                                                vertical: 20.0,
                                                                                horizontal: 10.0,
                                                                              ),
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(5.0),
                                                                              ),
                                                                              backgroundColor: Color.fromRGBO(245, 117, 29, 1),
                                                                              primary: Theme.of(context).iconTheme.color,
                                                                              textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                                                            ),
                                                                            onPressed:
                                                                                () async {
                                                                              if (row['status'] == 0) {
                                                                                showDialog(
                                                                                  context: context,
                                                                                  builder: (BuildContext context) => ConfirmUpdate(
                                                                                      title: "Xác nhận chốt lịch bay",
                                                                                      function: () async {
                                                                                        await confirmFly(row);
                                                                                        futurelistLichBay = getlistLichBay(currentPageDef);
                                                                                        showToast(
                                                                                          context: context,
                                                                                          msg: titleLog,
                                                                                          color: titleLog == "Cập nhật dữ liệu thành công" ? Color.fromARGB(136, 72, 238, 67) : Colors.red,
                                                                                          icon: titleLog == "Cập nhật dữ liệu thành công" ? Icon(Icons.done) : Icon(Icons.warning),
                                                                                        );
                                                                                        Navigator.pop(context);
                                                                                      },
                                                                                      content: "Bạn chắc chắn muốn chốt lịch bay này không?"),
                                                                                );
                                                                              } else {
                                                                                showDialog(
                                                                                  context: context,
                                                                                  builder: (BuildContext context) => XacNhanXuatCanh(
                                                                                    function: () async {
                                                                                      futurelistLichBay = getlistLichBay(currentPageDef);
                                                                                      Navigator.pop(context);
                                                                                    },
                                                                                    row: row,
                                                                                  ),
                                                                                );
                                                                              }
                                                                            },
                                                                            child:
                                                                                Row(
                                                                              children: [
                                                                                Text(row['status'] == 0 ? 'Chốt lịch bay' : "Xác nhận xuất cảnh", style: textButton),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                          : Center(
                                                              child: Text(row[
                                                                          'status'] ==
                                                                      0
                                                                  ? "Chưa kích hoạt"
                                                                  : row['status'] ==
                                                                          1
                                                                      ? "Chờ chốt lịch"
                                                                      : row['status'] ==
                                                                              2
                                                                          ? 'Đã hoàn thành'
                                                                          : 'Đã hủy lịch'),
                                                            ),
                                                    ),
                                                  ])
                                              ]),
                                        ),
                                      ],
                                    ),
                                  DynamicTablePagging(
                                      rowCount, currentPageDef, rowPerPage,
                                      pageChangeHandler: (currentPage) {
                                    setState(() {
                                      futurelistLichBay =
                                          getlistLichBay(currentPage);
                                      currentPageDef = currentPage;
                                    });
                                  }, rowPerPageChangeHandler:
                                          (rowPerPageChange) {
                                    currentPageDef = 1;

                                    rowPerPage = rowPerPageChange;
                                    futurelistLichBay =
                                        getlistLichBay(currentPageDef);
                                    setState(() {});
                                  })
                                ],
                              ),
                            )
                          ],
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

//--------------Thông báo đã chuyển dữ liệu vào kho lưu trữ----------

// ignore: must_be_immutable
class XacNhanXuatCanh extends StatefulWidget {
  dynamic row;
  Function function;
  XacNhanXuatCanh({Key? key, required this.function, required this.row})
      : super(key: key);
  @override
  State<XacNhanXuatCanh> createState() => _XacNhanXuatCanhState();
}

class _XacNhanXuatCanhState extends State<XacNhanXuatCanh> {
  var listTtsXc;

  late Future<dynamic> getListTtsFuture;
  var dataTable = [];
  getListTts() async {
    await getTrangThaiDongTien();
    var listTttt = {};
    var response = await httpGet(
        "/api/lichxuatcanh-chitiet/get/page?filter=flightScheduleId:${widget.row['id']}",
        context);
    if (response.containsKey("body")) {
      setState(() {
        listTtsXc = jsonDecode(response["body"])['content'];
        dataTable = [];
        for (var tts in listTtsXc) {
          if (listTrangThaiThanhToan.containsKey(tts['thuctapsinh']['id']) &&
              listTrangThaiThanhToan[tts['thuctapsinh']['id']] != null) {
            for (var row in listTrangThaiThanhToan[tts['thuctapsinh']['id']]) {
              if (row['orderId'] == tts['thuctapsinh']['orderId']) {
                listTttt[tts['thuctapsinh']['id']] = row;
                break;
              }
            }
          }
        }
        for (var row in listTtsXc) {
          if (listTttt[row['thuctapsinh']['id']] != null &&
              listTttt[row['thuctapsinh']['id']]['paidBeforeExam'] == 1 &&
              listTttt[row['thuctapsinh']['id']]['paidAfterExam'] == 1 &&
              listTttt[row['thuctapsinh']['id']]['paidBeforeFlight'] == 1 &&
              listTttt[row['thuctapsinh']['id']]['paidTuition'] == 1 &&
              checkPaidFood(listTttt[row['thuctapsinh']['id']]['paidFood'])) {
            row['checkPaid'] = true;
          } else {
            row['checkPaid'] = false;
          }
          row['thuctapsinh']['feeManageDate'] = DateFormat("yyyy-MM-dd").format(
              DateTime.parse(widget.row['flightDate'])
                  .add(const Duration(days: 30)));
          row['active'] = false;
          dataTable.add(row);
        }
      });
    }
    return 0;
  }

  var listTrangThaiThanhToan;
  getTrangThaiDongTien() async {
    var response = await httpGet("/api/tts-thanhtoan/get/page", context);
    if (response.containsKey("body")) {
      var data = jsonDecode(response["body"])['content'];
      listTrangThaiThanhToan = groupBy(data, (dynamic obj) => obj['ttsId']);
    } else
      throw Exception("Error load data");
    return listTrangThaiThanhToan;
  }

  checkPaidFood(paidFood) {
    if (paidFood == null) {
      return false;
    } else {
      if (paidFood.split(',').last == '0') {
        return true;
      } else
        return false;
    }
  }

  String titleLog = '';
  xacNhanXuatCanh(row) async {
    row['status'] = 2;
    var response =
        await httpPut('/api/lichxuatcanh/put/${row['id']}', row, context);
    if (response['body'] == "true") {
      titleLog = 'Cập nhật dữ liệu thành công';
      await httpPost(
          "/api/push/tags/user_type/aam",
          {
            "title": "Hệ thống thông báo",
            "message":
                "Lịch bay ${row['title']} vào thời gian: ${displayTimeStamp(row['flightDate']) + " ngày " + dateReverse(displayDateTimeStamp(row['flightDate']))} đã được hoàn thành "
          },
          context);
      for (var tts in dataTable) {
        if (tts['active'] == true) {
          tts.remove('active');
          if (tts['thuctapsinh']['nhanvientuyendung'] != null) {
            await httpPost(
                "/api/push/tags/user_code/${tts['thuctapsinh']['nhanvientuyendung']['userCode']}",
                {
                  "title": "Hệ thống thông báo",
                  "message":
                      "TTS mã ${tts['thuctapsinh']['userCode']}-${tts['thuctapsinh']['fullName']} đã xuất cảnh thành công"
                },
                context);
          }
          int beforeStatus = tts['thuctapsinh']['ttsStatusId'];
          tts['thuctapsinh']['ttsStatusId'] = 11;
          tts['thuctapsinh']["departureDate"] = row['flightDate'];
          await httpPut('/api/nguoidung/put/${tts['thuctapsinh']['id']}',
              tts['thuctapsinh'], context);
          if (tts['thuctapsinh']['donhang'] != null
              ? tts['thuctapsinh']['donhang']['orderStatusId'] == 2
              : false) {
            tts['thuctapsinh']['donhang']['orderStatusId'] = 3;
            await httpPut(
                '/api/donhang/put/${tts['thuctapsinh']['donhang']['id']}',
                tts['thuctapsinh']['donhang'],
                context);
          }
          await httpPostDiariStatus(tts['thuctapsinh']['id'], beforeStatus, 11,
              'Xác nhận xuất cảnh', context);
          tts['status'] = 1;
          await httpPut(
              "/api/lichxuatcanh-chitiet/put/${tts['id']}", tts, context);
        } else {
          tts.remove('active');
          tts['status'] = 2;
          await httpPut(
              "/api/lichxuatcanh-chitiet/put/${tts['id']}", tts, context);
        }
      }
    } else {
      titleLog = 'Cập nhật thất bại';
    }
    return titleLog;
  }

  @override
  void initState() {
    getListTtsFuture = getListTts();
  }

  @override
  Widget build(BuildContext context) {
    int i = 1;
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  child: Image.asset('images/logoAAM.png'),
                  margin: EdgeInsets.only(right: 10),
                ),
                Text('Xác nhận xuất cảnh', style: titleAlertDialog),
              ],
            ),
          ),
          IconButton(
              onPressed: () => Navigator.pop(context), icon: Icon(Icons.close)),
        ],
      ),
      content: SingleChildScrollView(
        child: Container(
          height: 500,
          width: 1000,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Expanded(
                      child: FutureBuilder<dynamic>(
                    future: getListTtsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return DataTable(
                          columnSpacing: 5,
                          showCheckboxColumn: true,
                          columns: [
                            DataColumn(
                                label: Expanded(
                                    child: Text(
                              'STT',
                              style: titleTableData,
                              textAlign: TextAlign.center,
                            ))),
                            DataColumn(
                                label: Expanded(
                                    child: Text(
                              'Mã TTS',
                              style: titleTableData,
                              textAlign: TextAlign.center,
                            ))),
                            DataColumn(
                                label: Expanded(
                                    child: Text(
                              'Tên TTS',
                              style: titleTableData,
                              textAlign: TextAlign.center,
                            ))),
                            DataColumn(
                                label: Expanded(
                                    child: Text(
                              'Ngày tháng năm sinh',
                              style: titleTableData,
                              textAlign: TextAlign.center,
                            ))),
                            DataColumn(
                                label: Expanded(
                                    child: Text(
                              'Ngày tính phí \n quản lý',
                              style: titleTableData,
                              textAlign: TextAlign.center,
                            ))),
                          ],
                          rows: <DataRow>[
                            for (var row in dataTable)
                              DataRow(
                                  selected: row['active'],
                                  onSelectChanged: row['checkPaid']
                                      ? (value) {
                                          setState(() {
                                            row['active'] = value;
                                          });
                                        }
                                      : null,
                                  cells: [
                                    DataCell(Center(child: Text("${i++}"))),
                                    DataCell(Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            row['checkPaid'] == false
                                                ? Tooltip(
                                                    message:
                                                        'Thực tập sinh chưa đóng đủ tiền',
                                                    child: Icon(
                                                      Icons
                                                          .warning_amber_rounded,
                                                      color: Colors.red,
                                                    ),
                                                  )
                                                : Container(),
                                            Center(
                                                child: Text(
                                                    row['thuctapsinh']
                                                        ['userCode'],
                                                    style: bangDuLieu)),
                                          ],
                                        ),
                                      ],
                                    )),
                                    DataCell(Center(
                                        child: Text(
                                            row['thuctapsinh']['fullName'],
                                            style: bangDuLieu))),
                                    DataCell(Center(
                                        child: Text(
                                            row['thuctapsinh']['birthDate'] !=
                                                    null
                                                ? dateReverse(row['thuctapsinh']
                                                    ['birthDate'])
                                                : 'no data',
                                            style: bangDuLieu))),
                                    DataCell(Container(
                                      // width: width * .1,
                                      child: DatePickerInTable(
                                        dateDisplay: dateReverse(
                                            row['thuctapsinh']
                                                ['feeManageDate']),
                                        function: (date) {
                                          row['thuctapsinh']['feeManageDate'] =
                                              dateReverse(date);
                                        },
                                      ),
                                    )),
                                    //
                                  ])
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }

                      // By default, show a loading spinner.
                      return Center(child: const CircularProgressIndicator());
                    },
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Hủy'),
          style: ElevatedButton.styleFrom(
            primary: colorOrange,
            onPrimary: colorWhite,
            elevation: 3,
            minimumSize: Size(140, 50),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            bool checkExitst = false;
            for (var row in dataTable) {
              if (row['active'] == true) {
                checkExitst = true;
                break;
              }
            }
            if (checkExitst) {
              await xacNhanXuatCanh(widget.row);
              showToast(
                context: context,
                msg: titleLog,
                color: titleLog == "Cập nhật dữ liệu thành công"
                    ? Color.fromARGB(136, 72, 238, 67)
                    : Colors.red,
                icon: titleLog == "Cập nhật dữ liệu thành công"
                    ? Icon(Icons.done)
                    : Icon(Icons.warning),
              );
              widget.function();
            } else {
              showToast(
                context: context,
                msg: 'Yêu cầu có ít nhất một thực tập sinh xuất cảnh.',
                color: Colors.red,
                icon: const Icon(Icons.warning),
              );
            }
          },
          child: Text('Xác nhận'),
          style: ElevatedButton.styleFrom(
            primary: colorBlueBtnDialog,
            onPrimary: colorWhite,
            elevation: 3,
            minimumSize: Size(140, 50),
          ),
        ),
      ],
    );
  }
}
