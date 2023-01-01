import 'dart:convert';
import 'dart:core';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/style.dart';
import 'package:gentelella_flutter/common/toast.dart';
import 'package:gentelella_flutter/model/market_development/Trainee.dart';
import 'package:gentelella_flutter/widgets/ui/ho_so_noi/chot_danh_sach_tts_tien_cu/chot_danh_sach_tts.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Border, Column, Row;
// ignore: deprecated_member_use
import 'package:universal_io/prefer_universal/io.dart';
import '../../../api.dart';
import '../../../common/dynamic_table.dart';
import '../../../common/widgets_form.dart';
import '../../../model/market_development/order.dart';
import '../../../model/model.dart';
import '../../utils/market_development.dart';
import '../navigation.dart';

class BaoCaoDanhSachTTS extends StatelessWidget {
  const BaoCaoDanhSachTTS({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: BaoCaoDanhSachTTSBody());
  }
}

class BaoCaoDanhSachTTSBody extends StatefulWidget {
  const BaoCaoDanhSachTTSBody({Key? key}) : super(key: key);

  @override
  State<BaoCaoDanhSachTTSBody> createState() => _BaoCaoDanhSachTTSBodyState();
}

String dropdownValue = "Tất cả";
Map<int, String> orderName = {0: "Tất cả"};

class _BaoCaoDanhSachTTSBodyState extends State<BaoCaoDanhSachTTSBody> {
  var page = 1;
  var rowPerPage = 10;
  var totalElements = 0;
  var firstRow = 1, lastRow = 0;
  var rowCount = 0;
  var currentPage = 1;
  bool _setLoading = false;
  late Future<List<Trainee>> _futureOrders;
  List<Trainee> listTrainee = [];
  var idDH;
  var idTT;
  int currentPageDef = 1;
  Map<int, String> traineeStatus = {
    -1: "Tất cả",
    6: "Chờ thi tuyển",
    7: "Đã trúng tuyển",
    10: "Chờ xuất cảnh"
  };
  String selectedTT = "";
  String trangThaiTTS =
      "and (ttsStatusId:6 or ttsStatusId:7 or ttsStatusId:10)";
  String donHang = "";
  String donHang1 = "";
  String? dateFrom;
  String? dateTo;
  bool check = false;

  // Xuất file excel
  String fileNameExport = "";
  Future<void> exportExcel(List<Trainee> trainee) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];

    sheet.getRangeByName('A1:AO999').cellStyle.fontSize = 10;
    sheet.getRangeByName('A1:AO999').cellStyle.fontName = "Arial";

    sheet.getRangeByName('A1:AO999').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('A1:AO999').cellStyle.vAlign = VAlignType.center;
    sheet.getRangeByName('D6:D999').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('E6:E999').cellStyle.hAlign = HAlignType.left;

    sheet.getRangeByName('A2').setText('AAM');
    sheet.getRangeByName('A2').cellStyle.fontSize = 14;
    sheet.getRangeByName('A2').cellStyle.bold = true;

    sheet.getRangeByName('A3').setText('BÁO CÁO DANH SÁCH THỰC TẬP SINH');
    sheet.getRangeByName('A3').cellStyle.bold = true;
    sheet.getRangeByName('A3').cellStyle.fontSize = 14;
    sheet.getRangeByName('A3:G3').merge();

    //bảng dữ liệu
    sheet.getRangeByName('A1').columnWidth = 5.1;
    sheet.getRangeByName('B1:C1').columnWidth = 25;
    sheet.getRangeByName('D1').columnWidth = 25;
    sheet.getRangeByName('E1').columnWidth = 70;
    sheet.getRangeByName('F1:H1').columnWidth = 25;

    sheet.getRangeByName('A5:F5').cellStyle.bold = true;
    sheet.getRangeByName('A5').setText('STT');
    sheet.getRangeByName('B5').setText('Mã TTS');
    sheet.getRangeByName('C5').setText('Tên TTS');
    sheet.getRangeByName('D5').setText('Mã đơn hàng');
    sheet.getRangeByName("E5").setText('Tên đơn hàng');
    sheet.getRangeByName('F5').setText('Trạng thái hiện tại');
    for (int i = 0; i < trainee.length; i++) {
      sheet.getRangeByIndex(6 + i, 1).setNumber(i + 1);
      sheet.getRangeByIndex(6 + i, 2).setText("${trainee[i].userCode!}");
      sheet.getRangeByIndex(6 + i, 3).setText("${trainee[i].fullName!}");
      sheet.getRangeByIndex(6 + i, 4).setText(
          "${trainee[i].order != null ? trainee[i].order!.orderCode : " "}");
      sheet.getRangeByIndex(6 + i, 5).setText(
          "${trainee[i].order != null ? trainee[i].order!.orderName : " "}");
      sheet.getRangeByIndex(6 + i, 6).setText("${trainee[i].ttsTrangthai!}");
    }
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    if (kIsWeb) {
      AnchorElement(
          href:
              'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
        ..setAttribute('download', 'Báo cáo danh sách thực tập sinh.xlsx')
        ..click();
      fileNameExport = await uploadFile(bytes);
    } else {
      final String path = (await getApplicationSupportDirectory()).path;
      final String fileName =
          Platform.isWindows ? '$path\\Output.xlsx' : '$path/Output.xlsx';
      final File file = File(fileName);
      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open(fileName);

      String fileNamePost = await uploadFile(file);
      print("fileNamePost: $fileNamePost");
    }
  }

  Future<List<Trainee>> getlistTrainees(page,
      {order, status, dateFrom, dateTo}) async {
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }
    if (page < 1) {
      page = 0;
    }
    var response;

    // print(condition);
    response = await httpGet(
        "/api/nguoidung/get/page?page=$page&size=$rowPerPage&filter= isTts:1 $trangThaiTTS $donHang ",
        context);

    var body = jsonDecode(response['body']);

    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        currentPage = page + 1;
        content = body['content'];
        rowCount = body["totalElements"];
        totalElements = body["totalElements"];
        lastRow = totalElements;
        listTrainee = content.map((e) {
          return Trainee.fromJson(e);
        }).toList();
      });
    }

    return content.map((e) {
      return Trainee.fromJson(e);
    }).toList();
  }

  Future<List<Trainee>> getlistTraineesSearchBy(page,
      {order, status, dateFrom, dateTo}) async {
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }
    if (page < 1) {
      page = 0;
    }
    var response;
    String condition = "";
    if (dateFrom != null && dateFrom != "") {
      condition += "and createdDate >:'${dateFrom!}'";
    }
    if (dateTo != null && dateTo != "") {
      condition += "AND createdDate <:'${dateTo!}'";
    }

    var listTTS = {};
    var listId = [];
    var response1 = await httpGet(
        "/api/tts-nhatky/get/page?filter= thuctapsinh.isTts:1 and ttsStatusAfterId: $selectedTT $donHang1 $condition",
        context);
    print(
        "/api/tts-nhatky/get/page?filter= thuctapsinh.isTts:1 and ttsStatusAfterId: $selectedTT $donHang1 $condition");

    if (response1.containsKey("body")) {
      listTTS = jsonDecode(response1['body']);
      listId.clear();
      for (var element in listTTS['content']) {
        listId.add(element['ttsId']);
      }
    }
    print(listId);
    String request = '';
    for (int i = 0; i < listId.length; i++) {
      if (listId[i] != null) {
        request += listId[i].toString();
        if (i < listId.length - 1) {
          request += ',';
        }
      }
    }
    if (listId.isEmpty) request = "0";
    // print(condition);
    response = await httpGet(
        "/api/nguoidung/get/page?page=$page&size=$rowPerPage&filter= isTts:1 and id in ($request)  $donHang ",
        context);

    var body = jsonDecode(response['body']);

    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        currentPage = page + 1;
        content = body['content'];
        rowCount = body["totalElements"];
        totalElements = body["totalElements"];
        lastRow = totalElements;
        listTrainee = content.map((e) {
          return Trainee.fromJson(e);
        }).toList();
      });
    }

    return content.map((e) {
      return Trainee.fromJson(e);
    }).toList();
  }

  Future<List<Order>> getListOrder() async {
    List<Order> resultOrder = [];
    var response1 = await httpGet("/api/donhang/get/page?sort=id", context);
    var body = jsonDecode(response1['body']);
    var content = [];
    if (response1.containsKey("body")) {
      setState(() {
        content = body['content'];
        resultOrder = content.map((e) {
          return Order.fromJson(e);
        }).toList();
        Order all = new Order(
            id: -1,
            orderName: "Tất cả",
            enterprise: null,
            jobs: null,
            orderCode: '',
            orderStatusId: 0,
            union: null);
        resultOrder.insert(0, all);
      });
    }
    return resultOrder;
  }

  @override
  void initState() {
    super.initState();
    _futureOrders = getlistTrainees(page - 1,
        order: "", dateFrom: "", dateTo: "", status: -1);
  }

  handleClickBtnSearch({order, status, dateFrom, dateTo}) {
    print("clicked");
    setState(() {
      _setLoading = true;
    });

    Future<List<Trainee>> _futureOrders1 = getlistTraineesSearchBy(0,
        order: order, status: status, dateFrom: dateFrom, dateTo: dateTo);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _futureOrders = _futureOrders1;
        _setLoading = false;
      });
    });
  }

  int getIndex(page, rowPerPage, index) {
    return ((page * rowPerPage) + index) + 1;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: userRule('/bao-cao-danh-sach-tts', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return Consumer<NavigationModel>(
              builder: (context, navigationModel, child) => FutureBuilder<
                      List<Trainee>>(
                  future: _futureOrders,
                  builder: (context, snapshot) {
                    return ListView(
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
                          // padding: paddingTitledPage,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TitlePage(
                                listPreTitle: [
                                  {'url': '/ho-so-noi', 'title': 'Hồ sơ nội'},
                                ],
                                content: 'Báo cáo danh sách TTS',
                              ),
                            ],
                          ),
                        ),
                        Container(
                            color: backgroundPage,
                            padding: EdgeInsets.symmetric(
                                vertical: verticalPaddingPage,
                                horizontal: horizontalPaddingPage),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width * 1,
                                    decoration: BoxDecoration(
                                      color: colorWhite,
                                      borderRadius: borderRadiusContainer,
                                      boxShadow: [boxShadowContainer],
                                      border: borderAllContainerBox,
                                    ),
                                    padding: paddingBoxContainer,
                                    child: Column(children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Nhập thông tin',
                                            style: titleBox,
                                          ),
                                          Icon(
                                            Icons.more_horiz,
                                            color: Color(0xff9aa5ce),
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
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 0, 0, 0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text('Đơn hàng',
                                                          style:
                                                              titleWidgetBox),
                                                    ),
                                                    Expanded(
                                                      flex: 5,
                                                      child: Container(
                                                        height: 40,
                                                        child: DropdownSearch<
                                                            Order>(
                                                          // ignore: deprecated_member_use
                                                          hint: "Tất cả",
                                                          maxHeight: 350,
                                                          mode: Mode.MENU,
                                                          showSearchBox: true,
                                                          onFind: (String?
                                                                  filter) =>
                                                              getListOrder(),
                                                          itemAsString: (Order?
                                                                  u) =>
                                                              '${u!.orderName}' +
                                                              '(${u.orderCode})',
                                                          dropdownSearchDecoration:
                                                              styleDropDown,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              idDH = value!.id;
                                                              selectedDH = idDH
                                                                  .toString();
                                                              print(selectedDH);
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 100),
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text('Trạng thái',
                                                          style:
                                                              titleWidgetBox),
                                                    ),
                                                    Expanded(
                                                      flex: 5,
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      0.0),
                                                          border: Border.all(
                                                              color:
                                                                  Colors.black,
                                                              style: BorderStyle
                                                                  .solid,
                                                              width: 0.80),
                                                        ),
                                                        child:
                                                            DropdownButtonHideUnderline(
                                                                child:
                                                                    ButtonTheme(
                                                          alignedDropdown: true,
                                                          child:
                                                              DropdownButton2<
                                                                  String>(
                                                            dropdownPadding:
                                                                EdgeInsets.all(
                                                                    0),
                                                            dropdownMaxHeight:
                                                                400,
                                                            underline:
                                                                Container(
                                                              height: 1,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            hint: Text(
                                                                '${traineeStatus[-1]}',
                                                                style:
                                                                    sizeTextKhung),
                                                            buttonPadding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 20),
                                                            items: traineeStatus
                                                                .entries
                                                                .map((item) =>
                                                                    DropdownMenuItem<
                                                                        String>(
                                                                      value: item
                                                                          .key
                                                                          .toString(),
                                                                      child: Text(
                                                                          item
                                                                              .value,
                                                                          style:
                                                                              sizeTextKhung),
                                                                    ))
                                                                .toList(),
                                                            value:
                                                                selectedTT != ""
                                                                    ? selectedTT
                                                                    : null,
                                                            itemPadding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 30),
                                                            onChanged: (value) {
                                                              setState(() {
                                                                selectedTT = value
                                                                    as String;
                                                                idTT = int.tryParse(
                                                                    selectedTT
                                                                        .toString());
                                                                selectedTT =
                                                                    value;
                                                              });
                                                            },
                                                            buttonHeight: 40,
                                                          ),
                                                        )),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                                flex: 2, child: Container()),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 30, 0, 0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child:
                                                  DatePickerBoxCustomForMarkert(
                                                      isTime: false,
                                                      title: "Từ ngày",
                                                      isBlocDate: false,
                                                      isNotFeatureDate: true,
                                                      label: Text(
                                                        'Từ ngày',
                                                        style: titleWidgetBox,
                                                      ),
                                                      dateDisplay: dateFrom,
                                                      selectedDateFunction:
                                                          (day) {
                                                        setState(() {
                                                          dateFrom = day;
                                                        });
                                                      }),
                                            ),
                                            SizedBox(width: 100),
                                            Expanded(
                                              flex: 3,
                                              child:
                                                  DatePickerBoxCustomForMarkert(
                                                      isTime: false,
                                                      title: "Đến ngày",
                                                      isBlocDate: false,
                                                      isNotFeatureDate: true,
                                                      label: Text(
                                                        'Đến ngày',
                                                        style: titleWidgetBox,
                                                      ),
                                                      dateDisplay: dateTo,
                                                      selectedDateFunction:
                                                          (day) {
                                                        setState(() {
                                                          dateTo = day;
                                                        });
                                                      }),
                                            ),
                                            Expanded(
                                                flex: 2, child: Container()),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              50, 50, 20, 0),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(left: 20),
                                                  child: TextButton(
                                                    style: TextButton.styleFrom(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        vertical: 20.0,
                                                        horizontal: 20.0,
                                                      ),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.0),
                                                      ),
                                                      backgroundColor:
                                                          Color.fromRGBO(
                                                              245, 117, 29, 1),
                                                      primary: Theme.of(context)
                                                          .iconTheme
                                                          .color,
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .caption
                                                              ?.copyWith(
                                                                  fontSize:
                                                                      10.0,
                                                                  letterSpacing:
                                                                      2.0),
                                                    ),
                                                    onPressed: () {
                                                      if (dateFrom == null &&
                                                          dateTo == null) {
                                                        check = false;
                                                        if (idTT != null &&
                                                            idTT != -1)
                                                          trangThaiTTS =
                                                              "and ttsStatusId:$idTT";
                                                        else
                                                          trangThaiTTS =
                                                              "and (ttsStatusId:6 or ttsStatusId:7 or ttsStatusId:10)";
                                                        if (idDH != null &&
                                                            idDH != -1)
                                                          donHang =
                                                              "and orderId:$idDH";
                                                        else
                                                          donHang = "";
                                                        _futureOrders =
                                                            getlistTrainees(
                                                                currentPage);
                                                      } else {
                                                        check = true;
                                                        if (idTT != null &&
                                                            idTT != -1)
                                                          trangThaiTTS =
                                                              "and ttsStatusId:$idTT";
                                                        else
                                                          trangThaiTTS =
                                                              "and (ttsStatusId:6 or ttsStatusId:7 or ttsStatusId:10)";
                                                        if (idDH != null &&
                                                            idDH != -1)
                                                          donHang1 =
                                                              "and thuctapsinh.orderId:$idDH";
                                                        else
                                                          donHang1 = "";
                                                        if (dateFrom != null &&
                                                            dateTo != null &&
                                                            (trangThaiTTS ==
                                                                'and (ttsStatusId:6 or ttsStatusId:7 or ttsStatusId:10)')) {
                                                          showToast(
                                                              context: context,
                                                              msg:
                                                                  "Vui lòng chọn trạng thái TTS",
                                                              color: Colors.red,
                                                              icon: Icon(Icons
                                                                  .warning));
                                                        } else {
                                                          setState(() async {
                                                            await getlistTraineesSearchBy(
                                                                currentPage);
                                                            await handleClickBtnSearch(
                                                                dateFrom:
                                                                    dateFrom,
                                                                dateTo: dateTo);
                                                          });
                                                        }
                                                      }
                                                    },
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.search,
                                                            color: Colors.white,
                                                            size: 15),
                                                        Text(' Tìm kiếm',
                                                            style: textButton),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                    margin: EdgeInsets.only(
                                                        left: 20),
                                                    child: (getRule(
                                                                listRule.data,
                                                                Role.Xem,
                                                                context) ==
                                                            true)
                                                        ? TextButton(
                                                            style: TextButton
                                                                .styleFrom(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                vertical: 20.0,
                                                                horizontal:
                                                                    20.0,
                                                              ),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5.0),
                                                              ),
                                                              backgroundColor:
                                                                  Color
                                                                      .fromRGBO(
                                                                          245,
                                                                          117,
                                                                          29,
                                                                          1),
                                                              primary: Theme.of(
                                                                      context)
                                                                  .iconTheme
                                                                  .color,
                                                              textStyle: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .caption
                                                                  ?.copyWith(
                                                                      fontSize:
                                                                          10.0,
                                                                      letterSpacing:
                                                                          2.0),
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              if (dateFrom ==
                                                                      null &&
                                                                  dateTo ==
                                                                      null) {
                                                                if (idTT !=
                                                                        null &&
                                                                    idTT != -1)
                                                                  trangThaiTTS =
                                                                      "and ttsStatusId:$idTT";
                                                                else
                                                                  trangThaiTTS =
                                                                      "and (ttsStatusId:6 or ttsStatusId:7 or ttsStatusId:10)";
                                                                if (idDH !=
                                                                        null &&
                                                                    idDH != -1)
                                                                  donHang =
                                                                      "and orderId:$idDH";
                                                                else
                                                                  donHang = "";
                                                                List<Trainee>
                                                                    listTrainee1 =
                                                                    [];
                                                                var response;
                                                                String
                                                                    condition =
                                                                    "";
                                                                if (dateFrom !=
                                                                        null &&
                                                                    dateFrom !=
                                                                        "") {
                                                                  condition +=
                                                                      "and ttsTrangthai.createdDate >:'${dateFrom!}'";
                                                                }
                                                                if (dateTo !=
                                                                        null &&
                                                                    dateTo !=
                                                                        "") {
                                                                  condition +=
                                                                      "AND ttsTrangthai.createdDate <:'${dateTo!}'";
                                                                }

                                                                // print(condition);
                                                                response =
                                                                    await httpGet(
                                                                        "/api/nguoidung/get/page?filter= isTts:1 $trangThaiTTS $donHang $condition",
                                                                        context);

                                                                var body =
                                                                    jsonDecode(
                                                                        response[
                                                                            'body']);

                                                                var content =
                                                                    [];
                                                                if (response
                                                                    .containsKey(
                                                                        "body")) {
                                                                  setState(() {
                                                                    content = body[
                                                                        'content'];
                                                                    listTrainee1 =
                                                                        content.map(
                                                                            (e) {
                                                                      return Trainee
                                                                          .fromJson(
                                                                              e);
                                                                    }).toList();
                                                                  });
                                                                }
                                                                await exportExcel(
                                                                    listTrainee1);
                                                              } else {
                                                                if (idTT !=
                                                                        null &&
                                                                    idTT != -1)
                                                                  trangThaiTTS =
                                                                      "and ttsStatusId:$idTT";
                                                                else
                                                                  trangThaiTTS =
                                                                      "and (ttsStatusId:6 or ttsStatusId:7 or ttsStatusId:10)";
                                                                if (idDH !=
                                                                        null &&
                                                                    idDH != -1)
                                                                  donHang1 =
                                                                      "and thuctapsinh.orderId:$idDH";
                                                                else
                                                                  donHang1 = "";
                                                                if (dateFrom !=
                                                                        null &&
                                                                    dateTo !=
                                                                        null &&
                                                                    (trangThaiTTS ==
                                                                        'and (ttsStatusId:6 or ttsStatusId:7 or ttsStatusId:10)')) {
                                                                  showToast(
                                                                      context:
                                                                          context,
                                                                      msg:
                                                                          "Vui lòng chọn trạng thái TTS",
                                                                      color: Colors
                                                                          .red,
                                                                      icon: Icon(
                                                                          Icons
                                                                              .warning));
                                                                } else {
                                                                  var response;
                                                                  String
                                                                      condition =
                                                                      "";
                                                                  if (dateFrom !=
                                                                          null &&
                                                                      dateFrom !=
                                                                          "") {
                                                                    condition +=
                                                                        "and createdDate >:'${dateFrom!}'";
                                                                  }
                                                                  if (dateTo !=
                                                                          null &&
                                                                      dateTo !=
                                                                          "") {
                                                                    condition +=
                                                                        "AND createdDate <:'${dateTo!}'";
                                                                  }

                                                                  var listTTS =
                                                                      {};
                                                                  var listId =
                                                                      [];
                                                                  var response1 =
                                                                      await httpGet(
                                                                          "/api/tts-nhatky/get/page?filter= thuctapsinh.isTts:1 and ttsStatusAfterId: $selectedTT $donHang1 $condition",
                                                                          context);
                                                                  print(
                                                                      "/api/tts-nhatky/get/page?filter= thuctapsinh.isTts:1 and ttsStatusAfterId: $selectedTT $donHang1 $condition");
                                                                  if (response1
                                                                      .containsKey(
                                                                          "body")) {
                                                                    listTTS = jsonDecode(
                                                                        response1[
                                                                            'body']);
                                                                    listId
                                                                        .clear();
                                                                    for (var element
                                                                        in listTTS[
                                                                            'content']) {
                                                                      listId.add(
                                                                          element[
                                                                              'ttsId']);
                                                                    }
                                                                  }
                                                                  print(listId);
                                                                  String
                                                                      request =
                                                                      '';
                                                                  for (int i =
                                                                          0;
                                                                      i <
                                                                          listId
                                                                              .length;
                                                                      i++) {
                                                                    if (listId[
                                                                            i] !=
                                                                        null) {
                                                                      request +=
                                                                          listId[i]
                                                                              .toString();
                                                                      if (i <
                                                                          listId.length -
                                                                              1) {
                                                                        request +=
                                                                            ',';
                                                                      }
                                                                    }
                                                                  }
                                                                  if (listId
                                                                      .isEmpty)
                                                                    request =
                                                                        "0";
                                                                  // print(condition);
                                                                  response = await httpGet(
                                                                      "/api/nguoidung/get/page?filter= isTts:1 and id in ($request)  $donHang ",
                                                                      context);

                                                                  List<Trainee>
                                                                      listTrainee =
                                                                      [];
                                                                  var content =
                                                                      [];
                                                                  if (response
                                                                      .containsKey(
                                                                          "body")) {
                                                                    setState(
                                                                        () {
                                                                      var body =
                                                                          jsonDecode(
                                                                              response['body']);
                                                                      content =
                                                                          body[
                                                                              'content'];
                                                                      listTrainee =
                                                                          content
                                                                              .map((e) {
                                                                        return Trainee
                                                                            .fromJson(e);
                                                                      }).toList();
                                                                    });
                                                                  }
                                                                  await exportExcel(
                                                                      listTrainee);
                                                                }
                                                              }
                                                            },
                                                            child:
                                                                Row(children: [
                                                              Icon(
                                                                  Icons
                                                                      .upload_file,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 15),
                                                              Text('Xuất file',
                                                                  style:
                                                                      textButton),
                                                            ]))
                                                        : Container()),
                                              ])),
                                    ])),
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
                                      if (snapshot.hasData)
                                        //Start Datatable
                                        !_setLoading
                                            ? Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    1,
                                                child: DataTable(
                                                  dataTextStyle:
                                                      const TextStyle(
                                                          color:
                                                              Color(0xff313131),
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                  showBottomBorder: true,
                                                  dataRowHeight: 60,
                                                  showCheckboxColumn: true,
                                                  dataRowColor:
                                                      MaterialStateProperty
                                                          .resolveWith<
                                                              Color?>((Set<
                                                                  MaterialState>
                                                              states) {
                                                    if (states.contains(
                                                        MaterialState
                                                            .selected)) {
                                                      return MaterialStateColor
                                                          .resolveWith((states) =>
                                                              const Color(
                                                                  0xffeef3ff));
                                                    }
                                                    return MaterialStateColor
                                                        .resolveWith((states) =>
                                                            Colors
                                                                .white); // Use the default value.
                                                  }),
                                                  columns: <DataColumn>[
                                                    DataColumn(
                                                      label: Text(
                                                        'STT',
                                                        style: titleTableData,
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        'Mã TTS',
                                                        style: titleTableData,
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        'Tên TTS',
                                                        style: titleTableData,
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        'Ngày sinh',
                                                        style: titleTableData,
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        'Mã đơn hàng',
                                                        style: titleTableData,
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        'Tên đơn hàng',
                                                        style: titleTableData,
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        'Trạng thái hiện tại',
                                                        style: titleTableData,
                                                      ),
                                                    ),
                                                  ],
                                                  rows: <DataRow>[
                                                    for (int i = 0;
                                                        i < listTrainee.length;
                                                        i++)
                                                      DataRow(
                                                        cells: <DataCell>[
                                                          DataCell(Text(
                                                            getIndex(
                                                                    currentPage -
                                                                        1,
                                                                    rowPerPage,
                                                                    i)
                                                                .toString(),
                                                          )),
                                                          DataCell(Text(
                                                              listTrainee[i]
                                                                  .userCode!)),
                                                          DataCell(Container(
                                                              width: 150,
                                                              child: Text(
                                                                  listTrainee[i]
                                                                      .fullName!))),
                                                          DataCell(Text(
                                                            listTrainee[i]
                                                                        .birthDate !=
                                                                    null
                                                                ? DateFormat(
                                                                        "dd-MM-yyyy")
                                                                    .format(DateTime.parse(
                                                                        listTrainee[i]
                                                                            .birthDate!))
                                                                : "",
                                                          )),
                                                          DataCell(Text(
                                                              listTrainee[i]
                                                                          .order !=
                                                                      null
                                                                  ? listTrainee[
                                                                          i]
                                                                      .order!
                                                                      .orderCode
                                                                  : " ")),
                                                          DataCell(Text(
                                                              listTrainee[i]
                                                                          .order !=
                                                                      null
                                                                  ? listTrainee[
                                                                          i]
                                                                      .order!
                                                                      .orderName
                                                                  : " ")),
                                                          DataCell(Container(
                                                              width: 100,
                                                              child: Text(
                                                                  listTrainee[i]
                                                                      .ttsTrangthai!))),
                                                        ],
                                                      ),
                                                  ],
                                                ))
                                            : Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              )
                                      else if (snapshot.hasError)
                                        Text("Fail! ${snapshot.error}")
                                      else if (!snapshot.hasData)
                                        Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      Container(
                                        // margin: const EdgeInsets.only(right: 50),
                                        child: (check == false)
                                            ? DynamicTablePagging(
                                                rowCount,
                                                currentPage,
                                                rowPerPage,
                                                pageChangeHandler: (page) {
                                                  setState(() {
                                                    _futureOrders =
                                                        getlistTrainees(
                                                            page - 1,
                                                            dateFrom: dateFrom,
                                                            dateTo: dateTo);
                                                    currentPage = page - 1;
                                                  });
                                                },
                                                rowPerPageChangeHandler:
                                                    (rowPerPage) {
                                                  setState(() {
                                                    this.rowPerPage =
                                                        rowPerPage!;
                                                    _futureOrders =
                                                        getlistTrainees(
                                                            page - 1,
                                                            dateFrom: dateFrom,
                                                            dateTo: dateTo);
                                                  });
                                                },
                                              )
                                            : DynamicTablePagging(
                                                rowCount,
                                                currentPage,
                                                rowPerPage,
                                                pageChangeHandler: (page) {
                                                  setState(() {
                                                    _futureOrders =
                                                        getlistTraineesSearchBy(
                                                            page - 1,
                                                            dateFrom: dateFrom,
                                                            dateTo: dateTo);
                                                    currentPage = page - 1;
                                                  });
                                                },
                                                rowPerPageChangeHandler:
                                                    (rowPerPage) {
                                                  setState(() {
                                                    this.rowPerPage =
                                                        rowPerPage!;
                                                    _futureOrders =
                                                        getlistTraineesSearchBy(
                                                            page - 1,
                                                            dateFrom: dateFrom,
                                                            dateTo: dateTo);
                                                  });
                                                },
                                              ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            )),
                        Footer(
                            marginFooter: EdgeInsets.only(top: 25),
                            paddingFooter: EdgeInsets.all(15))
                      ],
                    );
                  }));
        } else if (listRule.hasError) {
          return Text('${listRule.error}');
        }

        // By default, show a loading spinner.
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
