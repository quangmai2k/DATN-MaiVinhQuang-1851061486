import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/trung_tam_dao_tao/danh_sach_thuc_tap_sinh/danh_sach_thuc_tap_sinh.dart';
import 'package:intl/intl.dart';
import "package:collection/collection.dart";
import 'package:provider/provider.dart';

import '../../../api.dart';
import '../../../common/dynamic_table.dart';
import '../../../common/style.dart';
// ignore: unused_import
import '../../../common/toast.dart';
import '../../../common/widgets_form.dart';

// import '../../../model/type.dart';
import '../../../model/model.dart';
import '../navigation.dart';

class XacNhanThuTienTTS extends StatefulWidget {
  const XacNhanThuTienTTS({Key? key}) : super(key: key);

  @override
  _XacNhanThuTienTTSState createState() => _XacNhanThuTienTTSState();
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _XacNhanThuTienTTSState extends State<XacNhanThuTienTTS> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: XacNhanThuTienTTSBody());
  }
}

class XacNhanThuTienTTSBody extends StatefulWidget {
  const XacNhanThuTienTTSBody({Key? key}) : super(key: key);
  @override
  State<XacNhanThuTienTTSBody> createState() => _XacNhanThuTienTTSBodyState();
}

class _XacNhanThuTienTTSBodyState extends State<XacNhanThuTienTTSBody> {
  String? birthDate;
  String selectedValueTT = '-1';
  List<dynamic> itemsTT = [
    {'name': 'Đã tiến cử', 'value': '5'},
    {'name': 'Chờ thi tuyển', 'value': '6'},
    {'name': 'Đã trúng tuyển', 'value': '7'},
    {'name': 'Chờ đào tạo', 'value': '8'},
    {'name': 'Đang đào tạo', 'value': '9'},
    {'name': 'Chờ xuất cảnh', 'value': '10'},
    {'name': 'Đã xuất cảnh', 'value': '11'},
  ];
  String? selectedValueDH = '-1';
  List<dynamic> itemsDH = [];
  TextEditingController tenTts = TextEditingController();
  TextEditingController address = TextEditingController();
  late Future<dynamic> getListTtsFuture;
  var listTts;
  var listDh;

  getListDh() async {
    var response = await httpGet("/api/donhang/get/page", context);
    if (response.containsKey("body")) {
      setState(() {
        listDh = jsonDecode(response["body"])['content'];

        for (var row in listDh) {
          itemsDH.add({
            "name": row['orderName'],
            "value": row['id'].toString(),
            'code': row['orderCode']
          });
        }
      });
    }
  }

  var listTrangThaiThanhToan;
  getTrangThaiDongTien() async {
    var response = await httpGet(
        "/api/tts-thanhtoan/get/page?sort=createdDate,desc&filter=nguoidung.ttsStatusId in (5,6,7,8,9,10,11)",
        context);
    if (response.containsKey("body")) {
      var data = jsonDecode(response["body"])['content'];
      listTrangThaiThanhToan = groupBy(data, (dynamic obj) => obj['ttsId']);
    } else
      throw Exception("Error load data");
    return listTrangThaiThanhToan;
  }

  String selectedUser = '-1';
  var listTttt = {};
  dynamic getPayStatus() {
    for (var tts in listTts) {
      if (listTrangThaiThanhToan.containsKey(tts['id']) &&
          listTrangThaiThanhToan[tts['id']] != null) {
        for (var row in listTrangThaiThanhToan[tts['id']]) {
          if (row['orderId'] == tts['orderId']) {
            listTttt[tts['id']] = row;
            break;
          }
        }
      }
    }
  }

  String convertPaid(paid, type) {
    if (type == 1) {
      if (paid == 0)
        return "Chưa đóng tiền";
      else if (paid == 1)
        return "Hoàn thành";
      else if (paid == 2)
        return "Đóng 1 phần";
      else
        return '';
    } else {
      if (paid == null)
        return 'Chưa đóng tiền';
      else if (paid.split(',').last == '0')
        return 'Hoàn thành';
      else if (paid.split(',').last != '0')
        return 'Tháng ${paid.split(',').last}';
    }
    return '';
  }

  dynamic selectedTTDT = '-1';
  List<dynamic> itemsTTDT = [
    {'name': 'Cọc thi tuyển', 'value': 'paidBeforeExam'},
    {'name': 'Thu tiền sau trúng tuyển', 'value': 'paidAfterExam'},
    {'name': 'Thu tiền học', 'value': 'paidTuition'},
    {'name': 'Thu tiền ăn', 'value': 'paidFood'},
    {'name': 'Thu tiền trước xuất cảnh', 'value': 'paidBeforeFlight'}
  ];
  String requestName = '';
  String requestAddress = '';
  var listUser = [];
  bool loading = false;
  getListTts() async {
    if (itemsDH.isEmpty) await getListDh();
    if (!loading) {
      await getTrangThaiDongTien();
      loading = true;
    }
    var response;
    String query = '';
    String ttdt = '';
    if (selectedTTDT != '-1') {
      if (selectedTTDT == 'paidFood') {
        ttdt = ' and not(paidFood is null)';
      } else {
        ttdt = ' and $selectedTTDT!0';
      }
    }
    if (selectedUser != '-1') {
      response = await httpGet(
          "/api/tts-thanhtoan/get/page?sort=createdDate,desc&filter=ttsId:$selectedUser",
          context);
    } else if (selectedValueTT == '-1') {
      query = '';
      if (birthDate != null) {
        query += "and nguoidung.birthDate:'$birthDate'";
      }
      if (requestAddress != '') {
        query += " and nguoidung.address~'*$requestAddress*'";
      }
      if (selectedValueDH != '-1') {
        query += ' and orderId:$selectedValueDH ';
      }
      response = await httpGet(
          "/api/tts-thanhtoan/get/page?sort=createdDate,desc&filter=nguoidung.isTts:1 $query $ttdt",
          context);
    } else {
      query = '';
      if (selectedValueDH != '-1') {
        query += ' and nguoidung.orderId:$selectedValueDH ';
      }
      if (birthDate != null) {
        query += "and nguoidung.birthDate:'$birthDate'";
      }
      if (requestAddress != '') {
        query += " and nguoidung.address~'*$requestAddress*'";
      }
      response = await httpGet(
          "/api/tts-thanhtoan/get/page?sort=createdDate,desc&filter=nguoidung.ttsStatusId:$selectedValueTT $query $ttdt",
          context);
    }
    if (listUser.isEmpty) {
      var user =
          await httpGet("/api/nguoidung/get/page?filter=isTts:1", context);
      var listData = jsonDecode(user["body"])['content'];
      listUser = [];
      for (var row in listData) {
        listUser.add({
          'value': row['id'].toString(),
          'name': "${row['fullName']} ",
          'code':
              "${row['birthDate'] != null ? DateFormat("dd-MM-yyyy").format(DateTime.parse(row['birthDate'])) : 'Không xác định'}) (${row['address'] != null ? hometown(row['address']) : "Không xác định"}"
        });
      }
    }
    if (response.containsKey("body")) {
      setState(() {
        listTts = jsonDecode(response["body"])['content'];
        getPayStatus();
        rowCount = jsonDecode(response["body"])['totalElements'];
      });
    }
    return 0;
  }

  String hometown(home) {
    if (home == '') {
      return 'Không xác định';
    }
    if (home.length > 100) {
      return "...${home.substring(home.length - 100, home.length)}";
    } else {
      return home;
    }
  }

  @override
  // ignore: must_call_super
  void initState() {
    getListTtsFuture = getListTts();
  }

  int rowCount = 0;
  int currentPage = 1;
  int rowPerPage = 10;
  var firstRow;
  var lastRow;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: userRule('/xac-nhan-thu-tien-tts', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return FutureBuilder<dynamic>(
            future: getListTtsFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final double width = MediaQuery.of(context).size.width;
                rowCount = listTts.length;
                firstRow = (currentPage - 1) * rowPerPage;
                lastRow = currentPage * rowPerPage - 1;
                if (lastRow > rowCount - 1) {
                  lastRow = rowCount - 1;
                }
                // var tableIndex = (currentPage - 1) * rowPerPage + 1;
                return ListView(
                  children: [
                    TitlePage(
                      listPreTitle: [
                        {'url': '/ke-toan', 'title': 'Dashboard'},
                      ],
                      content: 'Xác nhận thu tiền TTS',
                    ),
                    Container(
                      margin: marginBoxFormTab,
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SelectableText(
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 30),
                                  child: DropdownBtnSearch(
                                    isAll: true,
                                    label: 'Tên TTS',
                                    listItems: listUser,
                                    search: TextEditingController(),
                                    isSearch: true,
                                    flexLabel: 2,
                                    flexDropdown: 12,
                                    selectedValue: selectedUser,
                                    setSelected: (selected) {
                                      selectedUser = selected;
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 30),
                                  child: DatePickerBoxVQ(
                                      isTime: false,
                                      label: SelectableText(
                                        'Ngày sinh',
                                        style: titleWidgetBox,
                                      ),
                                      dateDisplay: birthDate,
                                      selectedDateFunction: (day) {
                                        birthDate = day;
                                        setState(() {});
                                      }),
                                ),
                              ),
                              SizedBox(width: 100),
                              Expanded(
                                  flex: 3,
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 30),
                                    child: DropdownBtnSearch(
                                      isAll: true,
                                      label: 'Trạng thái đóng tiền',
                                      listItems: itemsTTDT,
                                      isSearch: false,
                                      selectedValue: selectedTTDT,
                                      setSelected: (selected) {
                                        selectedTTDT = selected;
                                      },
                                    ),
                                  )),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                  flex: 3,
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 30),
                                    child: DropdownBtnSearch(
                                      isAll: true,
                                      label: 'Đơn hàng',
                                      listItems: itemsDH,
                                      isSearch: true,
                                      search: TextEditingController(),
                                      selectedValue: selectedValueDH,
                                      setSelected: (selected) {
                                        selectedValueDH = selected;
                                      },
                                    ),
                                  )),
                              SizedBox(width: 100),
                              Expanded(
                                  flex: 3,
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 30),
                                    child: DropdownBtnSearch(
                                      isAll: true,
                                      label: 'Trạng thái TTS',
                                      listItems: itemsTT,
                                      isSearch: false,
                                      selectedValue: selectedValueTT,
                                      setSelected: (selected) {
                                        selectedValueTT = selected;
                                      },
                                    ),
                                  )),
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    //tìm kiếm
                                    Container(
                                      margin:
                                          EdgeInsets.only(left: 20, bottom: 30),
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 20.0,
                                            horizontal: 10.0,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                          ),
                                          backgroundColor:
                                              Color.fromRGBO(245, 117, 29, 1),
                                          primary:
                                              Theme.of(context).iconTheme.color,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .caption
                                              ?.copyWith(
                                                  fontSize: 10.0,
                                                  letterSpacing: 2.0),
                                        ),
                                        onPressed: () {
                                          requestName = tenTts.text;
                                          requestAddress = address.text;
                                          currentPage = 1;
                                          getListTtsFuture = getListTts();
                                        },
                                        child: Row(
                                          children: [
                                            Transform.rotate(
                                              angle: 270,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5, right: 5),
                                                child: Icon(
                                                  Icons.search,
                                                  color: Colors.white,
                                                  size: 15,
                                                ),
                                              ),
                                            ),
                                            Text('Tìm kiếm', style: textButton),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
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
                              children: [
                                Expanded(
                                    child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SelectableText(
                                          'Danh sách thực tập sinh',
                                          style: titleBox,
                                        ),
                                        SelectableText(
                                          'Kết quả tìm kiếm: $rowCount',
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
                                    Row(
                                      children: [
                                        Expanded(
                                            child: DataTable(
                                          columnSpacing: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  1600
                                              ? 5
                                              : 15,
                                          dataRowHeight: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  1600
                                              ? 80
                                              : 60,
                                          showCheckboxColumn: true,
                                          columns: [
                                            DataColumn(
                                                label: Container(
                                              child: SelectableText('STT',
                                                  style: titleTableData),
                                            )),
                                            DataColumn(
                                                label: Container(
                                              child: SelectableText('Mã TTS',
                                                  style: titleTableData),
                                            )),
                                            DataColumn(
                                                label: Container(
                                              child: SelectableText('Họ và tên',
                                                  style: titleTableData),
                                            )),
                                            DataColumn(
                                                label: Container(
                                              child: SelectableText(
                                                  'Mã đơn hàng',
                                                  style: titleTableData),
                                            )),
                                            DataColumn(
                                                label: Container(
                                              child: SelectableText(
                                                  'Tạm thu\n trước thi tuyển',
                                                  textAlign: TextAlign.center,
                                                  style: titleTableData),
                                            )),
                                            DataColumn(
                                                label: Container(
                                              child: SelectableText(
                                                  'Thu tiền\n sau trúng tuyển',
                                                  textAlign: TextAlign.center,
                                                  style: titleTableData),
                                            )),
                                            DataColumn(
                                                label: Container(
                                              child: SelectableText('Tiền học',
                                                  textAlign: TextAlign.center,
                                                  style: titleTableData),
                                            )),
                                            DataColumn(
                                                label: Container(
                                              child: SelectableText('Tiền ăn',
                                                  textAlign: TextAlign.center,
                                                  style: titleTableData),
                                            )),
                                            DataColumn(
                                                label: Container(
                                              child: SelectableText(
                                                  'Thu tiền\n trước xuất cảnh',
                                                  textAlign: TextAlign.center,
                                                  style: titleTableData),
                                            )),
                                            DataColumn(
                                                label: Container(
                                              child: SelectableText(
                                                  'Xác nhận\n thanh toán',
                                                  textAlign: TextAlign.center,
                                                  style: titleTableData),
                                            )),
                                          ],
                                          rows: <DataRow>[
                                            for (int i = firstRow;
                                                i <= lastRow;
                                                i++)
                                              DataRow(cells: [
                                                DataCell(
                                                  Container(
                                                    child: SelectableText(
                                                        '${i + 1}',
                                                        style: bangDuLieu),
                                                  ),
                                                ),
                                                DataCell(
                                                  Container(
                                                    width: MediaQuery
                                                                    .of(context)
                                                                .size
                                                                .width <
                                                            1600
                                                        ? MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.046
                                                        : MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.07,
                                                    child: SelectableText(
                                                        listTts[i]['nguoidung']
                                                            ['userCode'],
                                                        style: bangDuLieu),
                                                  ),
                                                ),
                                                DataCell(
                                                  Container(
                                                    width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width <
                                                            1600
                                                        ? MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.06
                                                        : MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.11,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        SelectableText(
                                                            listTts[i][
                                                                    'nguoidung']
                                                                ['fullName'],
                                                            style: bangDuLieu),
                                                        SelectableText(
                                                            listTts[i][
                                                                    'nguoidung']
                                                                ['birthDate'],
                                                            style: bangDuLieu),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Container(
                                                    width: MediaQuery
                                                                    .of(context)
                                                                .size
                                                                .width <
                                                            1600
                                                        ? MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.046
                                                        : MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.07,
                                                    child: Tooltip(
                                                      message: listTts[i]
                                                              ['donhang']
                                                          ['orderName'],
                                                      child: SelectableText(
                                                          listTts[i]['donhang']
                                                              ['orderCode'],
                                                          //  overflow: TextOverflow.ellipsis,
                                                          style: bangDuLieu),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Container(
                                                      child: Tooltip(
                                                    message:
                                                        "Ngày thanh toán: ${listTts[i]['paidBeforeExamDate'] != null ? dateReverse(displayDateTimeStamp(listTts[i]['paidBeforeExamDate'])) : 'Chưa thanh toán'}",
                                                    child: SelectableText(
                                                        convertPaid(
                                                            listTts[i][
                                                                'paidBeforeExam'],
                                                            1),
                                                        style: bangDuLieu),
                                                  )),
                                                ),
                                                DataCell(
                                                  Container(
                                                    child: Tooltip(
                                                      message:
                                                          "Ngày thanh toán: ${listTts[i]['paidAfterExamDate'] != null ? dateReverse(displayDateTimeStamp(listTts[i]['paidAfterExamDate'])) : 'Chưa thanh toán'}",
                                                      child: SelectableText(
                                                          convertPaid(
                                                              listTts[i][
                                                                  'paidAfterExam'],
                                                              1),
                                                          style: bangDuLieu),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Container(
                                                    child: Tooltip(
                                                      message:
                                                          "Ngày thanh toán: ${listTts[i]['paidTuitionDate'] != null ? dateReverse(displayDateTimeStamp(listTts[i]['paidTuitionDate'])) : 'Chưa thanh toán'}",
                                                      child: SelectableText(
                                                          convertPaid(
                                                              listTts[i][
                                                                  'paidTuition'],
                                                              1),
                                                          style: bangDuLieu),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Container(
                                                    child: Tooltip(
                                                      message:
                                                          "Ngày thanh toán: ${listTts[i]['paidFoodDate'] != null ? dateReverse(displayDateTimeStamp(listTts[i]['paidFoodDate'])) : 'Chưa thanh toán'}",
                                                      child: SelectableText(
                                                          convertPaid(
                                                              listTts[i]
                                                                  ['paidFood'],
                                                              0),
                                                          style: bangDuLieu),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Container(
                                                    child: Tooltip(
                                                      message:
                                                          "Ngày thanh toán: ${listTts[i]['paidBeforeFlightDate'] != null ? dateReverse(displayDateTimeStamp(listTts[i]['paidBeforeFlightDate'])) : 'Chưa thanh toán'}",
                                                      child: SelectableText(
                                                          convertPaid(
                                                              listTts[i][
                                                                  'paidBeforeFlight'],
                                                              1),
                                                          style: bangDuLieu),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  getRule(listRule.data,
                                                          Role.Sua, context)
                                                      ? listTts[i]['orderId'] ==
                                                              listTts[i][
                                                                      'nguoidung']
                                                                  ['orderId']
                                                          ? Container(
                                                              child: Row(
                                                                children: [
                                                                  Container(
                                                                    child:
                                                                        TextButton(
                                                                      style: TextButton
                                                                          .styleFrom(
                                                                        padding:
                                                                            const EdgeInsets.symmetric(
                                                                          vertical:
                                                                              20.0,
                                                                          horizontal:
                                                                              10.0,
                                                                        ),
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(5.0),
                                                                        ),
                                                                        backgroundColor: Color.fromRGBO(
                                                                            245,
                                                                            117,
                                                                            29,
                                                                            1),
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
                                                                      onPressed:
                                                                          () {
                                                                        showDialog(
                                                                            context:
                                                                                context,
                                                                            builder: (BuildContext context) =>
                                                                                ThanhToan(
                                                                                  setState: () {
                                                                                    loading = false;
                                                                                    getListTtsFuture = getListTts();
                                                                                    setState(() {});
                                                                                  },
                                                                                  row: listTts[i],
                                                                                ));
                                                                      },
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Text(
                                                                              'Xác nhận',
                                                                              style: textButton),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          : Text(
                                                              "Đã bị loại\nkhỏi đơn hàng",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red),
                                                            )
                                                      : Container(),
                                                ),
                                              ])
                                          ],
                                        )),
                                      ],
                                    ),
                                    DynamicTablePagging(
                                        rowCount, currentPage, rowPerPage,
                                        pageChangeHandler:
                                            (currentPageCallBack) {
                                      setState(() {
                                        currentPage = currentPageCallBack;
                                      });
                                    }, rowPerPageChangeHandler:
                                            (rowPerPageChange) {
                                      currentPage = 1;
                                      rowPerPage = rowPerPageChange;
                                      setState(() {});
                                    }),
                                  ],
                                )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Footer()
                    //
                  ],
                );
              } else if (snapshot.hasError) {
                return SelectableText('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return const Center(child: CircularProgressIndicator());
            },
          );
        } else if (listRule.hasError) {
          return SelectableText('${listRule.error}');
        }

        // By default, show a loading spinner.
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

// Pop-up xác nhận thu tiên
class ThanhToan extends StatefulWidget {
  final dynamic row;
  final Function setState;
  const ThanhToan({Key? key, required this.row, required this.setState})
      : super(key: key);

  @override
  State<ThanhToan> createState() => _ThanhToanState();
}

class _ThanhToanState extends State<ThanhToan> {
  bool paidFood = false;
  bool setDate = false;
  DateTime selectedDate = DateTime.now();
  dynamic selectedValueTTDT = '1';
  String titleLog = 'Cập nhật dữ liệu thành công';
  late List<dynamic> itemsTTDT = [
    {'name': 'Đóng 1 phần', 'value': '2'},
    {'name': 'Hoàn thành', 'value': '1'},
    {'name': 'Chưa đóng tiền', 'value': '0'},
  ];
  String selectedValueLTT = 'paidBeforeExam';

  List<dynamic> itemsLTT = [
    {'name': 'Cọc thi tuyển', 'value': 'paidBeforeExam'},
    {'name': 'Thu tiền sau trúng tuyển', 'value': 'paidAfterExam'},
    {'name': 'Thu tiền học', 'value': 'paidTuition'},
    {'name': 'Thu tiền ăn', 'value': 'paidFood'},
    {'name': 'Thu tiền trước xuất cảnh', 'value': 'paidBeforeFlight'}
  ];
  var listCheckBox = [
    {'title': "Tháng 1", 'value': false},
    {'title': "Tháng 2", 'value': false},
    {'title': "Tháng 3", 'value': false},
    {'title': "Tháng 4", 'value': false},
    {'title': "Tháng 5", 'value': false},
    {'title': "Tháng 6", 'value': false},
    {'title': "Tháng 7", 'value': false},
    {'title': "Tháng 8", 'value': false},
    {'title': "Tháng 9", 'value': false},
    {'title': "Tháng 10", 'value': false},
    {'title': "Tháng 11", 'value': false},
    {'title': "Tháng 12", 'value': false}
  ];
  int? userVerifier;
  String? ngayDongTien =
      DateFormat("dd-MM-yyyy").format(DateTime.now().toLocal());
  updateTTDT() async {
    if (widget.row != null) {
      String time = DateFormat("HH:mm").format(DateTime.now().toLocal());
      String dateName = "$selectedValueLTT" + 'Date';
      String verifier = "$selectedValueLTT" + 'Verifier';
      if (selectedValueLTT != 'paidFood') {
        widget.row['$selectedValueLTT'] = int.parse("$selectedValueTTDT");
        widget.row["$dateName"] = ngayDongTien != null
            ? convertTimeStamp(ngayDongTien!, time)
            : ngayDongTien;
        widget.row['$verifier'] = userVerifier;
        if (selectedValueTTDT == '0') {
          widget.row['$dateName'] = null;
          widget.row['$verifier'] = null;
        }
      } else {
        String month = '';
        for (int i = 0; i < 12; i++) {
          if (listCheckBox[i]['value'] == true) {
            month += '${i + 1},';
          }
        }
        if (month != '') month = month.substring(0, month.length - 1);
        if (selectedValueTTDT == '1') {
          if (month != '')
            month += ',0';
          else
            month += '0';
        }

        widget.row['paidFood'] = month;

        widget.row['paidFoodDate'] = ngayDongTien != null
            ? convertTimeStamp(ngayDongTien!, time)
            : ngayDongTien;
        widget.row['$verifier'] = userVerifier;
        if (selectedValueTTDT == '0') {
          widget.row['paidFood'] = null;
          widget.row['paidFoodDate'] = null;
          widget.row['$verifier'] = null;
        }
      }
      var response = await httpPut(
          '/api/tts-thanhtoan/put/${widget.row['id']}', widget.row, context);
      if (selectedValueLTT == "paidBeforeExam" && selectedValueTTDT != '0') {
        if (widget.row['nguoidung']['nhanvientuyendung'] != null) {
          await httpPost(
              "/api/push/tags/user_code/${widget.row['nguoidung']['nhanvientuyendung']['userCode']}",
              {
                "title": "Hệ thống thông báo",
                "message":
                    "TTS mã ${widget.row['nguoidung']['userCode']}-${widget.row['nguoidung']['fullName']} đã đóng tiền trước thi tuyển vào ngày $ngayDongTien"
              },
              context);
        }

        await httpPost(
            "/api/push/tags/depart_id/6&9",
            {
              "title": "Hệ thống thông báo",
              "message":
                  "TTS mã ${widget.row['nguoidung']['userCode']}-${widget.row['nguoidung']['fullName']} đã đóng tiền trước thi tuyển vào ngày $ngayDongTien"
            },
            context);
        await httpPostDiariStatus(
            widget.row['nguoidung']['id'],
            widget.row['nguoidung']['ttsStatusId'],
            widget.row['nguoidung']['ttsStatusId'],
            'Nộp tiền trước thi tuyển',
            context);
      }
      if (selectedValueLTT == "paidBeforeFlight" && selectedValueTTDT != '0') {
        if (widget.row['nguoidung']['nhanvientuyendung'] != null) {
          await httpPost(
              "/api/push/tags/user_code/${widget.row['nguoidung']['nhanvientuyendung']['userCode']}",
              {
                "title": "Hệ thống thông báo",
                "message":
                    "TTS mã ${widget.row['nguoidung']['userCode']}-${widget.row['nguoidung']['fullName']} đã đóng tiền trước xuất cảnh vào ngày $ngayDongTien"
              },
              context);
        }
        await httpPost(
            "/api/push/tags/depart_id/6&9",
            {
              "title": "Hệ thống thông báo",
              "message":
                  "TTS mã ${widget.row['nguoidung']['userCode']}-${widget.row['nguoidung']['fullName']} đã đóng tiền trước xuất cảnh vào ngày $ngayDongTien"
            },
            context);
        await httpPostDiariStatus(
            widget.row['nguoidung']['id'],
            widget.row['nguoidung']['ttsStatusId'],
            widget.row['nguoidung']['ttsStatusId'],
            'Nộp tiền trước xuất cảnh',
            context);
      }

      if (selectedValueLTT == "paidAfterExam" && selectedValueTTDT != '0') {
        if (widget.row['nguoidung']['ttsStatusId'] == 7 ||
            widget.row['nguoidung']['ttsStatusId'] == 8) {
          widget.row['nguoidung']['ttsStatusId'] = 8;
          await httpPut('/api/nguoidung/put/${widget.row['ttsId']}',
              widget.row['nguoidung'], context);
          if (widget.row['nguoidung']['nhanvientuyendung'] != null) {
            await httpPost(
                "/api/push/tags/user_code/${widget.row['nguoidung']['nhanvientuyendung']['userCode']}",
                {
                  "title": "Hệ thống thông báo",
                  "message":
                      "TTS mã ${widget.row['nguoidung']['userCode']}-${widget.row['nguoidung']['fullName']} đã đóng tiền sau thi tuyển vào ngày $ngayDongTien"
                },
                context);
          }
          await httpPost(
              "/api/push/tags/depart_id/6&9",
              {
                "title": "Hệ thống thông báo",
                "message":
                    "TTS mã ${widget.row['nguoidung']['userCode']}-${widget.row['nguoidung']['fullName']} đã đóng tiền sau thi tuyển vào ngày $ngayDongTien"
              },
              context);
          await httpPostDiariStatus(widget.row['nguoidung']['id'], 7, 8,
              'Nộp tiền sau thi tuyển', context);
        }
      }
      if (selectedValueLTT == "paidFood" ||
          selectedValueLTT == "paidTuition" && selectedValueTTDT != '0') {
        if (widget.row['nguoidung']['nhanvientuyendung'] != null)
          await httpPost(
              "/api/push/tags/user_code/${widget.row['nguoidung']['nhanvientuyendung']['userCode']}",
              {
                "title": "Hệ thống thông báo",
                "message":
                    "TTS mã ${widget.row['nguoidung']['userCode']}-${widget.row['nguoidung']['fullName']} đã đóng tiền ${selectedValueLTT == 'paidFood' ? "ăn" : "học"} vào ngày $ngayDongTien"
              },
              context);
        await httpPostDiariStatus(
            widget.row['nguoidung']['id'],
            widget.row['nguoidung']['ttsStatusId'],
            widget.row['nguoidung']['ttsStatusId'],
            'Nộp tiền ${selectedValueLTT == 'paidFood' ? "ăn" : "học"}',
            context);
        await httpPost(
            "/api/push/tags/depart_id/7&9",
            {
              "title": "Hệ thống thông báo",
              "message":
                  "TTS mã ${widget.row['nguoidung']['userCode']}-${widget.row['nguoidung']['fullName']} đã đóng tiền ${selectedValueLTT == 'paidFood' ? "ăn" : "học"} vào ngày $ngayDongTien"
            },
            context);
      }
      if (response['body'] == 'true') {
        print('Cập nhật dữ liệu thành công');
      } else {
        titleLog = 'Cập nhật thất bại';
      }
    } else {
      titleLog = "Không có dữ liệu";
    }
  }

  String? food;

  @override
  void initState() {
    // TODO: implement initState
    if (widget.row['paidBeforeExam'].toString() != '0')
      selectedValueTTDT = widget.row['paidBeforeExam'].toString();
    food = widget.row['paidFood'] ?? null;
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var curentUser =
        Provider.of<SecurityModel>(context, listen: false).userLoginCurren;
    userVerifier = curentUser['id'];
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
                SelectableText(
                  "Xác nhận thanh toán của TTS",
                  style: titleAlertDialog,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close),
          ),
        ],
      ),
      content: Container(
        width: 800,
        height: paidFood ? 500 : 300,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Divider(
                thickness: 1,
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Container(
              height: paidFood ? 400 : 200,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    DatePickerBoxVQ(
                        label: SelectableText(
                          'Ngày thanh toán',
                          style: titleWidgetBox,
                        ),
                        isTime: false,
                        dateDisplay: ngayDongTien,
                        flexLabel: 3,
                        selectedDateFunction: (day) {
                          ngayDongTien = day;
                          setDate = true;
                          setState(() {});
                        }),
                    SizedBox(
                      height: 25,
                    ),
                    DropdownBtnSearch(
                      isAll: false,
                      flexLabel: 3,
                      label: 'Loại thanh toán',
                      listItems: itemsLTT,
                      isSearch: false,
                      selectedValue: selectedValueLTT,
                      setSelected: (selected) {
                        selectedValueLTT = selected;
                        // if (selectedValueLTT == 'paidFood') {
                        //   if (food != null) {
                        //     var month = food!.split(',');
                        //     for (int i = 0; i < month.length; i++) {
                        //       if (month[i] != '' && int.parse(month[i]) != 0) {
                        //         listCheckBox[int.parse(month[i]) - 1]['value'] =
                        //             true;
                        //       }
                        //     }
                        //   }
                        //   paidFood = true;
                        // } else
                        //   paidFood = false;
                        if (selectedValueLTT == 'paidBeforeExam' ||
                            selectedValueLTT == 'paidFood' ||
                            selectedValueLTT == 'paidTuition' ||
                            selectedValueLTT == 'paidAfterExam') {
                          if (selectedValueLTT == 'paidBeforeExam' &&
                              widget.row['paidBeforeExam'].toString() != '0')
                            selectedValueTTDT =
                                widget.row['paidBeforeExam'].toString();
                          if (selectedValueLTT == 'paidAfterExam' &&
                              widget.row['paidAfterExam'].toString() != '0')
                            selectedValueTTDT =
                                widget.row['paidAfterExam'].toString();
                          if (selectedValueLTT == 'paidTuition' &&
                              widget.row['paidTuition'].toString() != '0')
                            selectedValueTTDT =
                                widget.row['paidTuition'].toString();
                          if (selectedValueLTT == 'paidFood') {
                            if (widget.row['paidFood'] != null &&
                                widget.row['paidFood'].split(',').last == '0') {
                              selectedValueTTDT = '1';
                            } else {
                              selectedValueTTDT = '2';
                            }
                          }
                          // print(widget.row['paidTuition'].toString());
                          itemsTTDT = [
                            {'name': 'Đóng 1 phần', 'value': '2'},
                            {'name': 'Hoàn thành', 'value': '1'},
                            {'name': 'Chưa đóng tiền', 'value': '0'},
                          ];
                        } else if (selectedValueLTT == 'paidBeforeFlight') {
                          selectedValueTTDT = '1';
                          itemsTTDT = [
                            {'name': 'Hoàn thành', 'value': '1'},
                            {'name': 'Chưa đóng tiền', 'value': '0'},
                          ];
                        }
                        setState(() {});
                      },
                    ),
                    SizedBox(
                      height: 25,
                    ),

                    Row(
                      children: [
                        Expanded(
                            flex: 3,
                            child: SelectableText(
                              'Trạng thái',
                              style: titleWidgetBox,
                            )),
                        Expanded(
                            flex: 5,
                            child: Container(
                              color: Colors.white,
                              width: MediaQuery.of(context).size.width * 0.25,
                              height: 40,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton2(
                                  dropdownMaxHeight: 300,
                                  items: [
                                    for (int i = 0; i < itemsTTDT.length; i++)
                                      DropdownMenuItem<String>(
                                        value: itemsTTDT[i]['value'],
                                        child: SelectableText(
                                          itemsTTDT[i]['name'],
                                        ),
                                      )
                                  ],
                                  value: selectedValueTTDT,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedValueTTDT = value;
                                    });
                                  },
                                  dropdownDecoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color.fromRGBO(
                                              216, 218, 229, 1))),
                                  buttonDecoration: BoxDecoration(
                                      border: Border.all(
                                          width: 0.5,
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
                    SizedBox(
                      height: 25,
                    ),

                    paidFood
                        ? ListMonth(
                            listCheckBox: listCheckBox,
                            function: (value) {
                              listCheckBox = value;
                            })
                        : Container()
                    // DropdownBtnSearch(
                    //   isAll: false,
                    //   flexLabel: 3,
                    //   label: 'Trạng thái đóng tiền',
                    //   listItems: itemsTTDT,
                    //   isSearch: false,
                    //   selectedValue: selectedValueTTDT,
                    //   setSelected: (selected) {
                    //     selectedValueTTDT = selected;
                    //     setState(() {});
                    //   },
                    // ),
                  ],
                ),
              ),
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
            var status = false;

            if (selectedValueLTT == 'paidFood' && selectedValueTTDT == '2') {
              for (var row in listCheckBox) {
                if (row['value'] == true) {
                  status = true;
                  break;
                }
              }
            } else {
              status = true;
            }
            if (ngayDongTien != null) {
              if (status) {
                await showDialog(
                  context: context,
                  builder: (BuildContext context) => ConfirmUpdate(
                      title: "Xác nhận thay đổi",
                      content: "Bạn có chắc chắn muốn thực hiện thay đổi",
                      function: () async {
                        await updateTTDT();
                        widget.setState();
                        Navigator.pop(context);
                      }),
                );
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
              } else {
                showToast(
                  context: context,
                  msg: 'Chọn ít nhất một tháng để xác nhận thanh toán',
                  color: Colors.red,
                  icon: const Icon(Icons.warning),
                );
              }
            } else {
              showToast(
                context: context,
                msg: 'Yêu cầu chọn ngày cập nhật',
                color: Colors.red,
                icon: const Icon(Icons.warning),
              );
            }
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
