import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/api.dart';
import 'package:gentelella_flutter/common/widgets_form.dart';
import 'package:gentelella_flutter/model/model.dart';
import 'package:gentelella_flutter/widgets/ui/ho_so_ngoai/datahsn/donhang.dart';
import 'package:gentelella_flutter/widgets/ui/ho_so_ngoai/datahsn/trangthai_tts.dart';
import 'package:gentelella_flutter/widgets/ui/ho_so_ngoai/tts/xacNhanXuatCanh.dart';
import 'package:gentelella_flutter/widgets/ui/source_information/common_ource_information/common_source_information.dart';
// import 'package:gentelella_flutter/widgets/ui/trung_tam_dao_tao/danh_sach_thuc_tap_sinh/danh_sach_thuc_tap_sinh.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' show AnchorElement;
import 'package:universal_io/io.dart';
import '../../../common/format_date.dart';
import '../../../common/style.dart';
import '../../../common/toast.dart';
import '../../forms/market_development/utils/funciton.dart';
import '../navigation.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Border, Column, Row;

class DanhSachTTS extends StatefulWidget {
  const DanhSachTTS({Key? key}) : super(key: key);

  @override
  _DanhSachTTSState createState() => _DanhSachTTSState();
}

class _DanhSachTTSState extends State<DanhSachTTS> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: DanhSachTTSBody());
  }
}

class DanhSachTTSBody extends StatefulWidget {
  const DanhSachTTSBody({Key? key}) : super(key: key);

  @override
  State<DanhSachTTSBody> createState() => _DanhSachTTSBodyState();
}

class _DanhSachTTSBodyState extends State<DanhSachTTSBody> {
  String fileNameExport = "";
  Future<void> exportExcel(listDungXuLy) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];

    sheet.getRangeByName('A1:AO999').cellStyle.fontSize = 10;
    sheet.getRangeByName('A1:AO999').cellStyle.fontName = "Arial";

    sheet.getRangeByName('A1:AO999').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('A1:AO999').cellStyle.vAlign = VAlignType.center;
    sheet.getRangeByName('C6:C999').cellStyle.hAlign = HAlignType.left;
    // sheet.getRangeByName('D6:D999').cellStyle.hAlign = HAlignType.left;
    sheet.getRangeByName('E6:E999').cellStyle.hAlign = HAlignType.left;
    sheet.getRangeByName('F6:F999').cellStyle.hAlign = HAlignType.left;
    sheet.getRangeByName('G6:G999').cellStyle.hAlign = HAlignType.left;

    sheet.getRangeByName('A2').setText('AAM');
    sheet.getRangeByName('A2').cellStyle.fontSize = 14;
    sheet.getRangeByName('A2').cellStyle.bold = true;
    sheet.getRangeByName('A2:B2').merge();

    sheet.getRangeByName('A3').setText('DANH SÁCH TTS');
    sheet.getRangeByName('A3').cellStyle.bold = true;
    sheet.getRangeByName('A3').cellStyle.fontSize = 14;
    sheet.getRangeByName('A3:I3').merge();

    //bảng dữ liệu
    sheet.getRangeByName('A1').columnWidth = 5.1;
    sheet.getRangeByName('B1').columnWidth = 25;
    sheet.getRangeByName('C1').columnWidth = 70;
    sheet.getRangeByName('D1').columnWidth = 25;
    sheet.getRangeByName('E1').columnWidth = 30;
    sheet.getRangeByName('F1:G1').columnWidth = 40;
    sheet.getRangeByName('H1:I1').columnWidth = 25;

    sheet.getRangeByName('A5:I5').cellStyle.bold = true;
    sheet.getRangeByName('A5').setText('STT');
    sheet.getRangeByName('B5').setText('Mã đơn hàng');
    sheet.getRangeByName('C5').setText('Tên đơn hàng');
    sheet.getRangeByName('D5').setText('Mã TTS');
    sheet.getRangeByName("E5").setText('Tên TTS');
    sheet.getRangeByName('F5').setText('Tên nghiệp đoàn');
    sheet.getRangeByName('G5').setText('Tên xí nghiệp');
    sheet.getRangeByName('H5').setText('Thời gian xuất cảnh');
    sheet.getRangeByName('I5').setText('Trạng thái');
    for (int i = 0; i < listDungXuLy.length; i++) {
      sheet.getRangeByIndex(6 + i, 1).setNumber(i + 1);
      sheet.getRangeByIndex(6 + i, 2).setText(
          "${listDungXuLy[i]["donhang"] != null ? listDungXuLy[i]["donhang"]["orderCode"] : ""}");
      sheet.getRangeByIndex(6 + i, 3).setText(
          "${listDungXuLy[i]["donhang"] != null ? listDungXuLy[i]["donhang"]["orderName"] : " "}");
      sheet.getRangeByIndex(6 + i, 4).setText("${listDungXuLy[i]["userCode"]}");
      sheet.getRangeByIndex(6 + i, 5).setText("${listDungXuLy[i]["fullName"]}");
      sheet.getRangeByIndex(6 + i, 6).setText(
          "${listDungXuLy[i]["donhang"] != null ? listDungXuLy[i]["donhang"]["nghiepdoan"]["orgName"] : " "}");
      sheet.getRangeByIndex(6 + i, 7).setText(
          "${listDungXuLy[i]["donhang"] != null ? listDungXuLy[i]["donhang"]["xinghiep"]["companyName"] : " "}");
      sheet.getRangeByIndex(6 + i, 8).setText(
          "${listDungXuLy[i]['departureDate'] != null ? FormatDate.formatDateddMMyy(DateTime.parse(listDungXuLy[i]['departureDate'])) : ""}");
      sheet.getRangeByIndex(6 + i, 9).setText(
          "${(listDungXuLy[i]["stopProcessing"] == 1) ? "Tạm dừng xử lý" : listDungXuLy[i]["ttsTrangthai"]["statusName"]}");
    }
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    if (kIsWeb) {
      AnchorElement(
          href:
              'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
        ..setAttribute('download', 'Danh sách tts.xlsx')
        ..click();
      // fileNameExport = await uploadFile(bytes);
    } else {
      final String path = (await getApplicationSupportDirectory()).path;
      final String fileName =
          Platform.isWindows ? '$path\\Output.xlsx' : '$path/Output.xlsx';
      final File file = File(fileName);
      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open(fileName);

      String fileNamePost = await uploadFile(file);
      // print("fileNamePost: $fileNamePost");
    }
  }

  //
  var time1;
  var time2;

  TextEditingController tenTTS = TextEditingController();
  var firstRow = 0;
  var rowPerPage = 10;
  var totalElements = 0;
  var currentPage = 0;
  var listTTS;
  var listChiTiet;
  Widget paging = Container();
  late Future<dynamic> futureListTTSHSN;
  List<bool> _selectedDataRow = [];
  List listSelected = [];
  var listTtsSelected = [];
  var idList = [];
  var idDonHang = [];
  var idTTS;
  String searchTTS = "";
  // var listDungXuLy = [];
  List<dynamic> listDungXuLy = [];

  Future<dynamic> getListDSTTS(page) async {
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }
    if (page < 1) {
      page = 0;
    }

    var response;
    print(
        "/api/nguoidung/get/page?page=$page&size=$rowPerPage&sort=fullName&filter=isTts:1 and entryDocumentsCompleted:false and not(ttsStatusId in (1,2,3,4,6,16)) and donhang is not null");
    if (iCheckProfile == true) {
      if (searchTTS == "") {
        response = await httpGet(
            "/api/nguoidung/get/page?page=$page&size=$rowPerPage&sort=fullName&filter=isTts:1 and entryDocumentsCompleted:false and not(ttsStatusId in (1,2,3,4,6,16)) and donhang is not null",
            context);
      } else
        response = await httpGet(
            "/api/nguoidung/get/page?page=$page&size=$rowPerPage&sort=fullName&filter=isTts:1 and entryDocumentsCompleted:false and not(ttsStatusId in (1,2,3,4,6,16)) and donhang is not null and $searchTTS",
            context);
    } else {
      if (searchTTS == "") {
        response = await httpGet(
            "/api/nguoidung/get/page?page=$page&size=$rowPerPage&sort=fullName&filter=isTts:1 and not(ttsStatusId in (1,2,3,4,6,16)) and donhang is not null",
            context);
      } else
        response = await httpGet(
            "/api/nguoidung/get/page?page=$page&size=$rowPerPage&sort=fullName&filter=isTts:1 and not(ttsStatusId in (1,2,3,4,6,16)) and donhang is not null and $searchTTS",
            context);
    }

    if (response.containsKey("body")) {
      setState(() {
        currentPage = page;
        listTTS = jsonDecode(response["body"]);
        totalElements = listTTS["totalElements"];
        _selectedDataRow = List<bool>.generate(
            listTTS["content"].length, (int index) => false);
        listSelected.clear();
        idList.clear();
      });
      print("chạy");
    }
    return listTTS;
  }

  //Lọc nhang những thằng thiếu hồ sơ
  bool iCheckProfile = false;

  //search don hang
  int? selectedDH;
  DonHang selectedDH1 =
      DonHang(id: -1, orderName: 'Tất cả', orderCode: 'Tất cả');
  Future<List<DonHang>> getDonHang() async {
    late List<DonHang> resultDonHang;
    var response1 = await httpGet(
        "/api/donhang/get/page?sort=id&filter=orderStatusId:3 or orderStatusId:2",
        context);
    var body = jsonDecode(response1['body']);
    var content = [];
    if (response1.containsKey("body")) {
      setState(() {
        content = body['content'];
        resultDonHang = content.map((e) {
          return DonHang.fromJson(e);
        }).toList();
      });
      DonHang all =
          new DonHang(id: -1, orderName: 'Tất cả', orderCode: 'Tất cả');
      resultDonHang.insert(0, all);
    }
    return resultDonHang;
  }

  //search trạng thái
  int? selectedTT;
  TrangThai selectedTT1 = TrangThai(id: -1, statusName: 'Tất cả');
  Future<List<TrangThai>> getTrangThaiTTS() async {
    late List<TrangThai> resultTrangThai;
    var response1 = await httpGet(
        "/api/tts-trangthai/get/page?filter=id!1 and id!2 and id!3 and id!4 and id!6 and id!14",
        context);
    var body = jsonDecode(response1['body']);
    var content = [];
    if (response1.containsKey("body")) {
      setState(() {
        content = body['content'];
        resultTrangThai = content.map((e) {
          return TrangThai.fromJson(e);
        }).toList();
      });
      TrangThai all = new TrangThai(id: -1, statusName: 'Tất cả');
      resultTrangThai.insert(0, all);
    }
    return resultTrangThai;
  }

  bool isLoading = false;
  functionIsClickXacNhan(bool value) {
    setState(() {
      isLoading = value;
      getListDSTTS(currentPage);
      isLoading = false;
    });

    // Future.delayed(const Duration(seconds: 1), () {
    //   setState(() {

    //   });
    // });
  }

  @override
  void initState() {
    super.initState();
    futureListTTSHSN = getListDSTTS(currentPage);
    listSelected = [];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationModel>(
      builder: (context, navigationModel, child) => ListView(
        children: [
          TitlePage(
            listPreTitle: [
              {'url': '/ho-so-ngoai', 'title': 'Dashboard'},
            ],
            content: "Danh sách TTS",
          ),
          FutureBuilder(
            future: futureListTTSHSN,
            builder: (context, snapshot) {
              double screenwidth = MediaQuery.of(context).size.width;
              if (snapshot.hasData) {
                var tableIndex = (currentPage) * rowPerPage + 1;
                if (listTTS["content"].length > 0) {
                  var firstRow = (currentPage) * rowPerPage + 1;
                  var lastRow = (currentPage + 1) * rowPerPage;
                  if (lastRow > listTTS["totalElements"]) {
                    lastRow = listTTS["totalElements"];
                  }

                  paging = Row(
                    children: [
                      Expanded(flex: 1, child: Container()),
                      const Text("Số dòng trên trang: "),
                      DropdownButton<int>(
                        value: rowPerPage,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        elevation: 16,
                        style: const TextStyle(color: Colors.deepPurple),
                        underline: Container(
                            height: 2, color: Colors.deepPurpleAccent),
                        onChanged: (int? newValue) {
                          setState(() {
                            rowPerPage = newValue!;
                            getListDSTTS(currentPage);
                          });
                        },
                        items: <int>[5, 10, 25, 50, 100]
                            .map<DropdownMenuItem<int>>((int value) {
                          return DropdownMenuItem<int>(
                              value: value, child: Text("$value"));
                        }).toList(),
                      ),
                      Text(
                          "Dòng $firstRow - $lastRow của ${listTTS["totalElements"]}"),
                      IconButton(
                          onPressed: firstRow != 1
                              ? () {
                                  getListDSTTS(currentPage - 1);
                                }
                              : null,
                          icon: const Icon(Icons.chevron_left)),
                      IconButton(
                          onPressed: lastRow < listTTS["totalElements"]
                              ? () {
                                  getListDSTTS(currentPage + 1);
                                }
                              : null,
                          icon: const Icon(Icons.chevron_right)),
                    ],
                  );
                }
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
                            child: Column(children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Nhập thông tin', style: titleBox),
                                  Icon(Icons.more_horiz,
                                      color: Color(0xff9aa5ce), size: 14),
                                ],
                              ),
                              //Đường line
                              Container(
                                  margin: marginTopBottomHorizontalLine,
                                  child: Divider(
                                      thickness: 1,
                                      color: ColorHorizontalLine)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  TextFieldValidated(
                                    type: 'None',
                                    height: 40,
                                    controller: tenTTS,
                                    label: 'Tên TTS',
                                    enter: () async {
                                      // await functionIsClickXacNhan(true);
                                    },
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
                                              child: Text('Đơn hàng',
                                                  style: titleWidgetBox)),
                                          Expanded(
                                            flex: 5,
                                            child: Container(
                                              color: Colors.white,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.20,
                                              height: 40,
                                              child: DropdownSearch<DonHang>(
                                                mode: Mode.MENU,
                                                selectedItem: selectedDH1,
                                                maxHeight: 350,
                                                showSearchBox: true,
                                                onFind: (String? filter) =>
                                                    getDonHang(),
                                                itemAsString: (DonHang? u) =>
                                                    u!.orderName!,
                                                dropdownSearchDecoration:
                                                    styleDropDown,
                                                emptyBuilder:
                                                    (context, String? value) {
                                                  return const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10),
                                                    child: Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                            "Không có dữ liệu !")),
                                                  );
                                                },
                                                onChanged: (value) {
                                                  setState(() {
                                                    selectedDH = value!.id;
                                                    selectedDH1 = value;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(flex: 1, child: Container())
                                ],
                              ),
                              SizedBox(height: 25),
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
                              SizedBox(height: 25),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
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
                                              child: Text('Trạng thái',
                                                  style: titleWidgetBox)),
                                          Expanded(
                                            flex: 5,
                                            child: Container(
                                              color: Colors.white,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.20,
                                              height: 40,
                                              child: DropdownSearch<TrangThai>(
                                                mode: Mode.MENU,
                                                selectedItem: selectedTT1,
                                                maxHeight: 350,
                                                showSearchBox: true,
                                                onFind: (String? filter) =>
                                                    getTrangThaiTTS(),
                                                itemAsString: (TrangThai? u) =>
                                                    u!.statusName,
                                                dropdownSearchDecoration:
                                                    styleDropDown,
                                                emptyBuilder:
                                                    (context, String? value) {
                                                  return const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10),
                                                    child: Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                            "Không có dữ liệu !")),
                                                  );
                                                },
                                                onChanged: (value) {
                                                  setState(() {
                                                    selectedTT = value!.id;
                                                    selectedTT1 = value;
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
                                  Expanded(flex: 4, child: Container()),
                                ],
                              ),
                              SizedBox(height: 25),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CheckBoxWidget(
                                      isChecked: iCheckProfile,
                                      functionCheckBox: (bool value) {
                                        setState(() {
                                          iCheckProfile = value;
                                          functionIsClickXacNhan(true);
                                        });
                                      },
                                      widgetTitle: [
                                        Text('TTS thiếu hồ sơ'),
                                      ]),
                                  Row(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(left: 20),
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 20.0,
                                                horizontal: 10.0),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0)),
                                            backgroundColor:
                                                listSelected.isNotEmpty
                                                    ? Color.fromRGBO(
                                                        245, 117, 29, 1)
                                                    : Colors.grey,
                                            primary: Theme.of(context)
                                                .iconTheme
                                                .color,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .caption
                                                ?.copyWith(
                                                    fontSize: 20.0,
                                                    letterSpacing: 2.0),
                                          ),
                                          onPressed: listSelected.isNotEmpty
                                              ? () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext
                                                            context) =>
                                                        Confirm(
                                                      titleDialog:
                                                          'Xác nhận xuất cảnh',
                                                      funcXN:
                                                          functionIsClickXacNhan,
                                                      listId: listDungXuLy,
                                                      donhangId: null,
                                                    ),
                                                  );
                                                }
                                              : null,
                                          child: Text('Xác nhận xuất cảnh ',
                                              style: textButton),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 20),
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 20.0,
                                                horizontal: 10.0),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0)),
                                            backgroundColor:
                                                listSelected.isNotEmpty
                                                    ? Color.fromRGBO(
                                                        245, 117, 29, 1)
                                                    : Colors.grey,
                                            primary: Theme.of(context)
                                                .iconTheme
                                                .color,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .caption
                                                ?.copyWith(
                                                    fontSize: 20.0,
                                                    letterSpacing: 2.0),
                                          ),
                                          onPressed: listSelected.isNotEmpty
                                              ? () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext
                                                            context) =>
                                                        DungXuLy(
                                                            setState: () async {
                                                              await functionIsClickXacNhan(
                                                                  true);
                                                              setState(() {});
                                                            },
                                                            listIdSelected:
                                                                listDungXuLy,
                                                            titleDialog:
                                                                'Dừng xử lý'),
                                                  );
                                                }
                                              : null,
                                          child: Text('Dừng xử lý',
                                              style: textButton),
                                        ),
                                      ),
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
                                                    fontSize: 20.0,
                                                    letterSpacing: 2.0),
                                          ),
                                          onPressed: () async {
                                            searchTTS = "";
                                            var title = "";
                                            if (tenTTS.text != "") {
                                              title =
                                                  "and fullName~'*${tenTTS.text}*' ";
                                              // title = "and userCode~'*${tenTTS.text}*' ";
                                              // userCode~'*${tenTTS.text}*' OR
                                            } else
                                              title = "";
                                            //
                                            var donHang = "";
                                            if (selectedDH != null &&
                                                selectedDH != -1) {
                                              donHang =
                                                  "and orderId:$selectedDH ";
                                            } else
                                              donHang = "";
                                            //
                                            var trangThai = "";
                                            if (selectedTT != null &&
                                                selectedTT != -1) {
                                              trangThai =
                                                  "and ttsStatusId:$selectedTT ";
                                            } else
                                              trangThai = "";
                                            //
                                            var tuNgay = "";
                                            if (time1 != null) {
                                              tuNgay =
                                                  "and departureDate>:'$time1' ";
                                            } else
                                              tuNgay = "";
                                            var denNgay = "";
                                            if (time2 != null) {
                                              int a = int.parse(time2
                                                  .toString()
                                                  .substring(0, 2));
                                              if (a > 9)
                                                denNgay =
                                                    "and departureDate<'${a + 1}${time2.toString().substring(2)}' ";
                                              else
                                                denNgay =
                                                    "and departureDate<'0${a + 1}${time2.toString().substring(2)}' ";
                                            } else
                                              denNgay = "";

                                            searchTTS = title +
                                                donHang +
                                                trangThai +
                                                tuNgay +
                                                denNgay;
                                            if (searchTTS != "") {
                                              if (searchTTS.substring(0, 3) ==
                                                  "and")
                                                searchTTS =
                                                    searchTTS.substring(4);
                                              await functionIsClickXacNhan(
                                                  true);
                                            } else
                                              await functionIsClickXacNhan(
                                                  true);
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
                                                    fontSize: 20.0,
                                                    letterSpacing: 2.0),
                                          ),
                                          onPressed: () {
                                            if (listDungXuLy.isNotEmpty) {
                                              exportExcel(listDungXuLy);
                                            } else {
                                              showToast(
                                                  context: context,
                                                  msg:
                                                      "Vui lòng chọn ít nhất 1 bản ghi",
                                                  color: Color.fromARGB(
                                                      255, 212, 240, 135),
                                                  icon: Icon(Icons.warning));
                                            }
                                          },
                                          icon: Transform.rotate(
                                            angle: 270,
                                            child: Icon(Icons.file_open_sharp,
                                                color: Colors.white, size: 15),
                                          ),
                                          label: Row(
                                            children: [
                                              Text('Xuất file',
                                                  style: textButton)
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Danh sách TTS', style: titleBox),
                                  // Text('Số lượng TTS : $totalElements', style: titleBox),
                                  Icon(Icons.more_horiz,
                                      color: Color(0xff9aa5ce), size: 14),
                                ],
                              ),
                              //Đường line
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                child: Divider(
                                    thickness: 1, color: ColorHorizontalLine),
                              ),
                              if (snapshot.hasData)
                                !isLoading
                                    ? Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1,
                                        child: screenwidth >= 1080
                                            ? DataTable(
                                                showBottomBorder: true,
                                                columnSpacing: 8,
                                                dataRowHeight: 65,
                                                columns: [
                                                  DataColumn(
                                                      label: Text('STT',
                                                          style:
                                                              titleTableData)),
                                                  DataColumn(
                                                      label: Text('Mã đơn hàng',
                                                          style:
                                                              titleTableData)),
                                                  DataColumn(
                                                      label: Text(
                                                          'Tên đơn hàng',
                                                          style:
                                                              titleTableData)),
                                                  DataColumn(
                                                      label: Text('Mã TTS',
                                                          style:
                                                              titleTableData)),
                                                  DataColumn(
                                                      label: Text('Tên TTS',
                                                          style:
                                                              titleTableData)),
                                                  DataColumn(
                                                      label: Text('Nghiệp đoàn',
                                                          style:
                                                              titleTableData)),
                                                  DataColumn(
                                                      label: Text('Xí nghiệp',
                                                          style:
                                                              titleTableData)),
                                                  DataColumn(
                                                      label: Text(
                                                          'Thời gian\nxuất cảnh',
                                                          style:
                                                              titleTableData)),
                                                  DataColumn(
                                                      label: Text('Trạng thái',
                                                          style:
                                                              titleTableData)),
                                                  DataColumn(
                                                      label: Text('Hành động',
                                                          style:
                                                              titleTableData)),
                                                ],
                                                rows: <DataRow>[
                                                  for (int j = 0;
                                                      j <
                                                          listTTS["content"]
                                                              .length;
                                                      j++)
                                                    DataRow(
                                                      selected:
                                                          _selectedDataRow[j],
                                                      onSelectChanged: ((listTTS[
                                                                      "content"][j]
                                                                  [
                                                                  "stopProcessing"]! ==
                                                              0))
                                                          ? (bool? selected) {
                                                              setState(() {
                                                                _selectedDataRow[
                                                                        j] =
                                                                    selected!;
                                                                print(
                                                                    _selectedDataRow[
                                                                        j]);
                                                                var item = [];
                                                                item.add(listTTS[
                                                                        "content"]
                                                                    [j]["id"]);
                                                                item.add(listTTS[
                                                                        "content"][j]
                                                                    [
                                                                    "donhang"]["id"]);
                                                                if (_selectedDataRow[
                                                                    j]) {
                                                                  // idList.add(item);
                                                                  listSelected.add(
                                                                      listTTS["content"]
                                                                              [
                                                                              j]
                                                                          [
                                                                          "id"]);
                                                                  listDungXuLy.add(
                                                                      listTTS["content"]
                                                                          [j]);
                                                                } else {
                                                                  // idList.remove(item);
                                                                  listSelected.remove(
                                                                      listTTS["content"]
                                                                              [
                                                                              j]
                                                                          [
                                                                          "id"]);
                                                                  listDungXuLy.remove(
                                                                      listTTS["content"]
                                                                          [j]);
                                                                }
                                                              });
                                                            }
                                                          : null,
                                                      cells: <DataCell>[
                                                        DataCell(Container(
                                                            width: (MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    10) *
                                                                0.15,
                                                            child: Text(
                                                                "${tableIndex + j}",
                                                                style:
                                                                    bangDuLieu))),
                                                        DataCell(
                                                          Container(
                                                            width: (MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    10) *
                                                                0.6,
                                                            child: Text(
                                                                (listTTS["content"][j]
                                                                            [
                                                                            "donhang"] !=
                                                                        null
                                                                    ? listTTS["content"][j]["donhang"]
                                                                            [
                                                                            "orderCode"]
                                                                        .toString()
                                                                    : " "),
                                                                style:
                                                                    bangDuLieu),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Container(
                                                            width: (MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    10) *
                                                                0.6,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .all(
                                                                      10.0),
                                                              child: Tooltip(
                                                                message:
                                                                    "${(listTTS["content"][j]["donhang"] != null ? listTTS["content"][j]["donhang"]["orderName"] : " ")}",
                                                                child: Text(
                                                                    (listTTS["content"][j]["donhang"] !=
                                                                            null
                                                                        ? listTTS["content"][j]["donhang"]
                                                                            [
                                                                            "orderName"]
                                                                        : " "),
                                                                    maxLines: 2,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style:
                                                                        bangDuLieu),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Container(
                                                              width: (MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      10) *
                                                                  0.7,
                                                              child: Text(
                                                                  (listTTS["content"]
                                                                              [
                                                                              j]
                                                                          [
                                                                          "userCode"])
                                                                      .toString(),
                                                                  style:
                                                                      bangDuLieu)),
                                                        ),
                                                        DataCell(
                                                          Container(
                                                            width: (MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    10) *
                                                                0.6,
                                                            child: (listTTS["content"]
                                                                            [j][
                                                                        "entryDocumentsCompleted"] ==
                                                                    false)
                                                                ? Tooltip(
                                                                    message:
                                                                        "TTS thiếu hồ sơ",
                                                                    child:
                                                                        RichText(
                                                                      text:
                                                                          TextSpan(
                                                                        children: [
                                                                          WidgetSpan(
                                                                            child: Icon(Icons.warning_amber_rounded,
                                                                                color: Colors.red,
                                                                                size: 18),
                                                                          ),
                                                                          TextSpan(
                                                                            text: listTTS["content"][j]["fullName"] != null
                                                                                ? listTTS["content"][j]["fullName"]
                                                                                : "",
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ))
                                                                : Text(
                                                                    listTTS["content"][j]["fullName"] !=
                                                                            null
                                                                        ? listTTS["content"][j][
                                                                            "fullName"]
                                                                        : "",
                                                                    maxLines: 2,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style:
                                                                        bangDuLieu),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Container(
                                                            width: (MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    10) *
                                                                0.6,
                                                            child: Text(
                                                                (listTTS["content"][j]
                                                                            [
                                                                            "donhang"] !=
                                                                        null
                                                                    ? listTTS["content"][j]
                                                                            [
                                                                            "donhang"]["nghiepdoan"]
                                                                        [
                                                                        "orgName"]
                                                                    : " "),
                                                                style:
                                                                    bangDuLieu),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Container(
                                                            width: (MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    10) *
                                                                0.7,
                                                            child: Text(
                                                                (listTTS["content"][j]
                                                                            [
                                                                            "donhang"] !=
                                                                        null
                                                                    ? listTTS["content"][j]
                                                                            [
                                                                            "donhang"]["xinghiep"]
                                                                        [
                                                                        "companyName"]
                                                                    : " "),
                                                                style:
                                                                    bangDuLieu),
                                                          ),
                                                        ),
                                                        DataCell(Container(
                                                          width: (MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  10) *
                                                              0.5,
                                                          child: Text(
                                                              listTTS['content'][j]
                                                                          [
                                                                          'departureDate'] !=
                                                                      null
                                                                  ? (listTTS['content'][j]['departureDate']
                                                                          .toString()
                                                                          .substring(
                                                                              8,
                                                                              10) +
                                                                      '-' +
                                                                      listTTS['content'][j]['departureDate']
                                                                          .toString()
                                                                          .substring(
                                                                              5,
                                                                              7) +
                                                                      '-' +
                                                                      listTTS['content'][j]
                                                                              ['departureDate']
                                                                          .toString()
                                                                          .substring(0, 4))
                                                                  : "",
                                                              style: bangDuLieu),
                                                        )),
                                                        DataCell(
                                                          Container(
                                                            width: (MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    10) *
                                                                0.4,
                                                            child: (listTTS["content"]
                                                                            [j][
                                                                        "stopProcessing"] ==
                                                                    1)
                                                                ? Text(
                                                                    ("Tạm dừng xử lý"),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        color: Colors
                                                                            .orangeAccent))
                                                                : Text(
                                                                    ((listTTS["content"][j]["ttsTrangthai"]["statusName"] !=
                                                                            null
                                                                        ? listTTS["content"][j]["ttsTrangthai"]
                                                                            ["statusName"]
                                                                        : "")),
                                                                    style: bangDuLieu),
                                                          ),
                                                        ),
                                                        DataCell(Row(
                                                          children: [
                                                            Consumer<
                                                                NavigationModel>(
                                                              builder: (context,
                                                                      navigationModel,
                                                                      child) =>
                                                                  Container(
                                                                margin: const EdgeInsets
                                                                        .fromLTRB(
                                                                    10,
                                                                    0,
                                                                    0,
                                                                    0),
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    idTTS = listTTS["content"][j]
                                                                            [
                                                                            "id"]
                                                                        .toString();
                                                                    navigationModel.add(
                                                                        pageUrl:
                                                                            ("/view-thong-tin-thuc-tap-sinh" +
                                                                                "/$idTTS"));
                                                                  },
                                                                  child: Icon(Icons
                                                                      .visibility),
                                                                ),
                                                              ),
                                                            ),
                                                            Consumer<
                                                                NavigationModel>(
                                                              builder: (context,
                                                                      navigationModel,
                                                                      child) =>
                                                                  Container(
                                                                margin: EdgeInsets
                                                                    .fromLTRB(
                                                                        10,
                                                                        0,
                                                                        0,
                                                                        0),
                                                                child: (listTTS["content"][j]
                                                                            [
                                                                            "stopProcessing"] ==
                                                                        0)
                                                                    ? InkWell(
                                                                        onTap:
                                                                            () {
                                                                          navigationModel.add(
                                                                              pageUrl: "/sua-ho-so-tts" + "/${listTTS['content'][j]['id'].toString()}");
                                                                        },
                                                                        child: Icon(
                                                                            Icons
                                                                                .edit_calendar,
                                                                            color: Color(
                                                                                0xff009C87)))
                                                                    : InkWell(
                                                                        onTap:
                                                                            null,
                                                                        child: Icon(
                                                                            Icons
                                                                                .edit_calendar,
                                                                            color:
                                                                                Colors.grey)),
                                                              ),
                                                            ),
                                                          ],
                                                        )),
                                                      ],
                                                    )
                                                ],
                                              )
                                            : SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: DataTable(
                                                  showCheckboxColumn: true,
                                                  // columnSpacing: 1,
                                                  // horizontalMargin: 0,
                                                  dataRowHeight: 50,
                                                  columns: [
                                                    DataColumn(
                                                        label: Text('STT',
                                                            style:
                                                                titleTableData)),
                                                    DataColumn(
                                                        label: Text(
                                                            'Mã Đơn hàng',
                                                            style:
                                                                titleTableData)),
                                                    DataColumn(
                                                        label: Text(
                                                            'Tên đơn hàng',
                                                            style:
                                                                titleTableData)),
                                                    DataColumn(
                                                        label: Text('Mã TTS',
                                                            style:
                                                                titleTableData)),
                                                    DataColumn(
                                                        label: Text('Tên TTS',
                                                            style:
                                                                titleTableData)),
                                                    DataColumn(
                                                        label: Text(
                                                            'Tên nghiệp đoàn',
                                                            style:
                                                                titleTableData)),
                                                    DataColumn(
                                                        label: Text(
                                                            'Tên xí nghiệp',
                                                            style:
                                                                titleTableData)),
                                                    DataColumn(
                                                        label: Text(
                                                            'Thời gian xuất cảnh',
                                                            style:
                                                                titleTableData)),
                                                    DataColumn(
                                                        label: Text(
                                                            'Trạng thái',
                                                            style:
                                                                titleTableData)),
                                                    DataColumn(
                                                        label: Text('Hành động',
                                                            style:
                                                                titleTableData)),
                                                  ],
                                                  rows: <DataRow>[
                                                    for (int j = 0;
                                                        j <
                                                            listTTS["content"]
                                                                .length;
                                                        j++)
                                                      DataRow(
                                                        selected:
                                                            _selectedDataRow[j],
                                                        onSelectChanged:
                                                            ((listTTS["content"]
                                                                            [j][
                                                                        "stopProcessing"]! ==
                                                                    0))
                                                                ? (bool?
                                                                    selected) {
                                                                    setState(
                                                                        () {
                                                                      _selectedDataRow[
                                                                              j] =
                                                                          selected!;
                                                                      print(_selectedDataRow[
                                                                          j]);
                                                                      // listDungXuLy.clear();
                                                                      // idList.clear();
                                                                      var item =
                                                                          [];
                                                                      item.add(listTTS["content"]
                                                                              [
                                                                              j]
                                                                          [
                                                                          "id"]);
                                                                      item.add(listTTS["content"][j]
                                                                              [
                                                                              "donhang"]
                                                                          [
                                                                          "id"]);
                                                                      item.add(listTTS["content"]
                                                                              [
                                                                              j]
                                                                          [
                                                                          "ttsStatusId"]);
                                                                      if (_selectedDataRow[
                                                                          j]) {
                                                                        print(
                                                                            "thêm");
                                                                        // idList.add(item);
                                                                        listSelected.add(listTTS["content"][j]
                                                                            [
                                                                            "id"]);
                                                                        listDungXuLy.add(listTTS["content"]
                                                                            [
                                                                            j]);
                                                                        print(
                                                                            listDungXuLy);
                                                                      } else {
                                                                        print(
                                                                            "xóa");
                                                                        // idList.remove(item);
                                                                        listSelected.remove(listTTS["content"][j]
                                                                            [
                                                                            "id"]);
                                                                        listDungXuLy.remove(listTTS["content"]
                                                                            [
                                                                            j]);
                                                                        print(
                                                                            listDungXuLy);
                                                                      }
                                                                    });
                                                                  }
                                                                : null,
                                                        cells: <DataCell>[
                                                          DataCell(Text(
                                                              "${tableIndex + j}",
                                                              style:
                                                                  bangDuLieu)),
                                                          DataCell(
                                                            Text(
                                                                (listTTS["content"][j]
                                                                            [
                                                                            "donhang"] !=
                                                                        null
                                                                    ? listTTS["content"][j]["donhang"]
                                                                            [
                                                                            "orderCode"]
                                                                        .toString()
                                                                    : " "),
                                                                style:
                                                                    bangDuLieu),
                                                          ),
                                                          DataCell(
                                                            Text(
                                                                (listTTS["content"][j]
                                                                            [
                                                                            "donhang"] !=
                                                                        null
                                                                    ? listTTS["content"][j]
                                                                            [
                                                                            "donhang"]
                                                                        [
                                                                        "orderName"]
                                                                    : " "),
                                                                style:
                                                                    bangDuLieu),
                                                          ),
                                                          DataCell(
                                                            Text(
                                                                (listTTS["content"]
                                                                            [j][
                                                                        "userCode"])
                                                                    .toString(),
                                                                style:
                                                                    bangDuLieu),
                                                          ),
                                                          // DataCell(listTTHSN)
                                                          DataCell(
                                                            Container(
                                                              child: (listTTS["content"]
                                                                              [j][
                                                                          "entryDocumentsCompleted"] ==
                                                                      false)
                                                                  ? Tooltip(
                                                                      message:
                                                                          "TTS thiếu hồ sơ",
                                                                      child:
                                                                          RichText(
                                                                        text:
                                                                            TextSpan(
                                                                          children: [
                                                                            WidgetSpan(
                                                                              child: Icon(Icons.warning_amber_rounded, color: Colors.red, size: 18),
                                                                            ),
                                                                            TextSpan(
                                                                              text: listTTS["content"][j]["fullName"] != null ? listTTS["content"][j]["fullName"] : "",
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ))
                                                                  : Text(
                                                                      listTTS["content"][j]["fullName"] !=
                                                                              null
                                                                          ? listTTS["content"][j]
                                                                              [
                                                                              "fullName"]
                                                                          : "",
                                                                      maxLines:
                                                                          2,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style:
                                                                          bangDuLieu),
                                                            ),
                                                          ),
                                                          DataCell(
                                                            Text(
                                                                (listTTS["content"][j]
                                                                            [
                                                                            "donhang"] !=
                                                                        null
                                                                    ? listTTS["content"][j]
                                                                            [
                                                                            "donhang"]["nghiepdoan"]
                                                                        [
                                                                        "orgName"]
                                                                    : " "),
                                                                style:
                                                                    bangDuLieu),
                                                          ),
                                                          DataCell(
                                                            Text(
                                                                (listTTS["content"][j]
                                                                            [
                                                                            "donhang"] !=
                                                                        null
                                                                    ? listTTS["content"][j]
                                                                            [
                                                                            "donhang"]["xinghiep"]
                                                                        [
                                                                        "companyName"]
                                                                    : " "),
                                                                style:
                                                                    bangDuLieu),
                                                          ),
                                                          DataCell(Text(
                                                              listTTS['content'][j]
                                                                          [
                                                                          'departureDate'] !=
                                                                      null
                                                                  ? (listTTS['content'][j]['departureDate']
                                                                          .toString()
                                                                          .substring(
                                                                              8,
                                                                              10) +
                                                                      '-' +
                                                                      listTTS['content'][j]['departureDate']
                                                                          .toString()
                                                                          .substring(
                                                                              5,
                                                                              7) +
                                                                      '-' +
                                                                      listTTS['content'][j]
                                                                              ['departureDate']
                                                                          .toString()
                                                                          .substring(0, 4))
                                                                  : "",
                                                              style: bangDuLieu)),
                                                          DataCell(
                                                            (listTTS["content"]
                                                                            [j][
                                                                        "stopProcessing"] ==
                                                                    1)
                                                                ? Text(
                                                                    ("Tạm dừng xử lý"),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        color: Colors
                                                                            .green))
                                                                : Text(
                                                                    ((listTTS["content"]
                                                                            [
                                                                            j]["ttsTrangthai"]
                                                                        [
                                                                        "statusName"])),
                                                                    style:
                                                                        bangDuLieu),
                                                          ),
                                                          DataCell(Row(
                                                            children: [
                                                              Consumer<
                                                                  NavigationModel>(
                                                                builder: (context,
                                                                        navigationModel,
                                                                        child) =>
                                                                    Container(
                                                                  margin: const EdgeInsets
                                                                          .fromLTRB(
                                                                      10,
                                                                      0,
                                                                      0,
                                                                      0),
                                                                  child:
                                                                      InkWell(
                                                                    onTap: () {
                                                                      idTTS = listTTS["content"][j]
                                                                              [
                                                                              "id"]
                                                                          .toString();
                                                                      navigationModel.add(
                                                                          pageUrl:
                                                                              ("/danh-sach-tts/view" + "/$idTTS"));
                                                                    },
                                                                    child: Icon(
                                                                        Icons
                                                                            .visibility),
                                                                  ),
                                                                ),
                                                              ),
                                                              Consumer<
                                                                  NavigationModel>(
                                                                builder: (context,
                                                                        navigationModel,
                                                                        child) =>
                                                                    Container(
                                                                  margin: EdgeInsets
                                                                      .fromLTRB(
                                                                          10,
                                                                          0,
                                                                          0,
                                                                          0),
                                                                  child: (listTTS["content"][j]
                                                                              [
                                                                              "stopProcessing"] ==
                                                                          0)
                                                                      ? InkWell(
                                                                          onTap:
                                                                              () {
                                                                            navigationModel.add(pageUrl: "/sua-ho-so-tts" + "/${listTTS['content'][j]['id'].toString()}");
                                                                          },
                                                                          child: Icon(Icons.edit_calendar,
                                                                              color: Color(
                                                                                  0xff009C87)))
                                                                      : InkWell(
                                                                          onTap:
                                                                              null,
                                                                          child: Icon(
                                                                              Icons.edit_calendar,
                                                                              color: Colors.grey)),
                                                                ),
                                                              ),
                                                            ],
                                                          )),
                                                        ],
                                                      )
                                                  ],
                                                ),
                                              ),
                                      )
                                    : Center(
                                        child: CircularProgressIndicator()),
                              if (totalElements != 0)
                                paging
                              else
                                Container(
                                    child: Column(
                                  children: [
                                    SizedBox(
                                      height: 25,
                                    ),
                                    Text('Không có kết quả phù hợp'),
                                  ],
                                )),
                            ],
                          ),
                        )
                      ],
                    ));
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
    );
  }
}

// Pop-up dừng xử lý
class DungXuLy extends StatefulWidget {
  final String titleDialog;
  final List<dynamic> listIdSelected;
  final Function setState;
  const DungXuLy(
      {Key? key,
      required this.titleDialog,
      required this.listIdSelected,
      required this.setState})
      : super(key: key);
  @override
  State<DungXuLy> createState() => _DungXuLyState();
}

class _DungXuLyState extends State<DungXuLy> {
  TextEditingController detail = TextEditingController();
  DateTime selectedDate = DateTime.now();

  dynamic selectedValueTT = '1';
  List<dynamic> itemsTT = [
    {'name': 'Chờ tiến cử lại', 'value': '0'},
    {'name': 'Dừng xử lý tạm thời', 'value': '1'}
  ];

  dynamic selectedValueLD = '1';
  List<dynamic> itemsLD = [
    {'name': 'Do nghiệp đoàn', 'value': '0'},
    {'name': 'Do cá nhân', 'value': '1'},
    {'name': 'Khác', 'value': '2'}
  ];
  String? er;
  double height = 80;
  String titleLog = 'Cập nhật dữ liệu thành công';
  updateDXL(row) async {
    // var data1;
    var data2;
    var response1;
    var response2;
    if (selectedValueTT == '1') {
      row["stopProcessing"] = 1;
      print(row);
      response1 =
          await httpPut('/api/nguoidung/put/${row['id']}', row, context);
      await httpPost(
          "/api/push/tags/depart_id/3&4&5&6&7&8&9&10",
          {
            "title": "Hệ thống thông báo",
            "message":
                "Tạm dừng xử lý TTS ${row['fullName']} có mã ${row['userCode']} lúc ${getDateViewDayAndHour(FormatDate.formatDateInsertDBHHss(DateTime.now()))}"
          },
          context);
      data2 = {
        "ttsId": row['id'],
        "itemType": 0,
        "causeType": int.parse(selectedValueLD),
        "causeContent": detail.text,
        "approvalType": 0
      };
      response2 =
          await httpPost('/api/tts-donhang-dungxuly/post/save', data2, context);
      print(response2);
    } else {
      print('Có đổi trạng thái');
      row["ttsStatusId"] = 14;
      response1 =
          await httpPut('/api/nguoidung/put/${row['id']}', row, context);
      print(response1);
      await httpPost(
          "/api/push/tags/depart_id/3",
          {
            "title": "Hệ thống thông báo",
            "message":
                "TTS ${row['userCode']}(${row['fullName']}) được chuyển về chờ tiến cử lại."
          },
          context);
      await httpPostDiariStatus(
          row['id'], row['ttsStatusId'], 14, detail.text, context);
    }
    if (jsonDecode(response1["body"])['1'] ==
        "Cập nhật thông tin thành công!") {
      print('Cập nhật dữ liệu thành công');
    } else {
      titleLog = 'Cập nhật thất bại';
    }
    return titleLog;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                    margin: EdgeInsets.only(right: 10)),
                Text(widget.titleDialog, style: titleAlertDialog),
              ],
            ),
          ),
          IconButton(
              onPressed: () => Navigator.pop(context), icon: Icon(Icons.close)),
        ],
      ),
      content: Container(
        width: 500,
        height: 270,
        child: ListView(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Divider(thickness: 1),
                ),
                SizedBox(height: 25),
                Container(
                  height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              flex: 3,
                              child: Text('Trạng thái', style: titleWidgetBox)),
                          Expanded(
                              flex: 5,
                              child: Container(
                                color: Colors.white,
                                width: MediaQuery.of(context).size.width * 0.25,
                                height: 40,
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2(
                                    isExpanded: true,
                                    items: [
                                      for (int i = 0; i < itemsTT.length; i++)
                                        DropdownMenuItem<String>(
                                          value: itemsTT[i]['value'],
                                          child: Text(itemsTT[i]['name']),
                                        )
                                    ],
                                    value: selectedValueTT,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedValueTT = value;
                                      });
                                    },
                                    dropdownDecoration: BoxDecoration(
                                        border: Border.all(
                                            color: const Color.fromRGBO(
                                                216, 218, 229, 1))),
                                    buttonDecoration: BoxDecoration(
                                        border: Border.all(
                                            width: 0.35,
                                            style: BorderStyle.solid)),
                                    buttonElevation: 0,
                                    buttonPadding: const EdgeInsets.only(
                                        left: 14, right: 14),
                                    itemPadding: const EdgeInsets.only(
                                        left: 14, right: 14),
                                    dropdownElevation: 5,
                                    focusColor: Colors.white,
                                  ),
                                ),
                              ))
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                              flex: 3,
                              child: Text('Lý do', style: titleWidgetBox)),
                          Expanded(
                              flex: 5,
                              child: Container(
                                color: Colors.white,
                                width: MediaQuery.of(context).size.width * 0.25,
                                height: 40,
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2(
                                    isExpanded: true,
                                    items: [
                                      for (int i = 0; i < itemsLD.length; i++)
                                        DropdownMenuItem<String>(
                                          value: itemsLD[i]['value'],
                                          child: Text(itemsLD[i]['name']),
                                        )
                                    ],
                                    value: selectedValueLD,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedValueLD = value;
                                      });
                                    },
                                    dropdownDecoration: BoxDecoration(
                                        border: Border.all(
                                            color: const Color.fromRGBO(
                                                216, 218, 229, 1))),
                                    buttonDecoration: BoxDecoration(
                                        border: Border.all(
                                            width: 0.35,
                                            style: BorderStyle.solid)),
                                    buttonElevation: 0,
                                    buttonPadding: const EdgeInsets.only(
                                        left: 14, right: 14),
                                    itemPadding: const EdgeInsets.only(
                                        left: 14, right: 14),
                                    dropdownElevation: 5,
                                    focusColor: Colors.white,
                                  ),
                                ),
                              ))
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                              flex: 3,
                              child: Text('Mô tả chi tiết',
                                  style: titleWidgetBox)),
                          Expanded(
                              flex: 5,
                              child: Container(
                                height: height,
                                // width: MediaQuery.of(context).size.width * 0.15,
                                child: TextField(
                                  controller: detail,
                                  minLines: 2,
                                  maxLines: 2,
                                  decoration: InputDecoration(
                                    hintText: 'Nhập nội dung',
                                    errorText: er,
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    if (detail.text.isEmpty) {
                                      er = 'Yêu cầu không được để trống';
                                      height = 92;
                                    } else {
                                      er = null;
                                      height = 80;
                                    }
                                    setState(() {});
                                  },
                                ),
                              ))
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          // textColor: Color(0xFF6200EE),
          onPressed: () => Navigator.pop(context),
          child: Text('Hủy'),
          style: ElevatedButton.styleFrom(
            primary: colorOrange,
            onPrimary: colorWhite,
            // shadowColor: Colors.greenAccent,
            elevation: 3,
            // shape: Border.all(width: 1,color: Colors.red);
            // side: BorderSide(
            //   width: 1,
            //   color: Colors.black87,
            // ),
            minimumSize: Size(140, 50),
            // maximumSize: Size(140, 50), //////// HERE
          ),
        ),
        ElevatedButton(
          // textColor: Color(0xFF6200EE),
          onPressed: () async {
            for (var row in widget.listIdSelected) {
              await updateDXL(row);
            }
            widget.setState();
            Navigator.pop(context);
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
          },
          child: Text(
            'Xác nhận',
            style: TextStyle(),
          ),
          style: ElevatedButton.styleFrom(
            primary: colorBlueBtnDialog,
            onPrimary: colorWhite,
            // shadowColor: Colors.greenAccent,
            elevation: 3,
            // shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(32.0)),
            minimumSize: Size(140, 50), //////// HERE
          ),
        ),
      ],
    );
  }
}
