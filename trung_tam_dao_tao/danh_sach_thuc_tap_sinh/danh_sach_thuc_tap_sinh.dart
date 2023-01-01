import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/widgets_form.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../api.dart';
import '../../../../common/dynamic_table.dart';
import '../../../../common/toast.dart';
import '../../../../model/model.dart';
import '../../../../common/style.dart';
import '../../navigation.dart';

class DanhSachThucTapSinh extends StatefulWidget {
  const DanhSachThucTapSinh({Key? key}) : super(key: key);

  @override
  _DanhSachThucTapSinhState createState() => _DanhSachThucTapSinhState();
}

class _DanhSachThucTapSinhState extends State<DanhSachThucTapSinh> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
      widgetBody: DanhSachThucTapSinhBody(),
    );
  }
}

Color bgBtn = Colors.grey;

class DanhSachThucTapSinhBody extends StatefulWidget {
  const DanhSachThucTapSinhBody({Key? key}) : super(key: key);

  @override
  State<DanhSachThucTapSinhBody> createState() =>
      _DanhSachThucTapSinhBodyState();
}

class _DanhSachThucTapSinhBodyState extends State<DanhSachThucTapSinhBody> {
  var listTTS = {};
  int rowCount = 0;
  int currentPage = 1;
  int rowPerPage = 10;
  var firstRow;
  var lastRow;
  bool search = false;
  late Future<dynamic> getListTTSFuture;
  String requestName = '';
  String requestDate = '';
  String requestClass = '';
  String requestOrder = '';
  String? birthDay;
  TextEditingController searchGVCN = TextEditingController();

  TextEditingController searchLH = TextEditingController();
  int load = 1;
  var listTtsSearch;
  var listTtsFilterClass = [];
  var listFinal = [];
  var listTrangThaiThanhToan = {};
  int idThanhToan(id, orderId) {
    for (var row in listTrangThaiThanhToan['content'] ?? []) {
      if (row['ttsId'] == id && row['orderId'] == orderId) {
        if (row['paidTuition'] == 0)
          return row['id'];
        else if (row['paidTuition'] == 1)
          return row['id'];
        else if (row['paidTuition'] == 2)
          return row['id'];
        else if (row['paidTuition'] == 3) return row['id'];
      }
    }
    return 0;
  }

  getListTtsSearch() async {
    btnActive = false;
    if (load == 1) {
      await getListLopHoc();
      await getListGVCN();
      await getTrangThaiDongTien();
      await getListTtsDT();
      await getListTtsTtdt();
    }
    load++;
    // await getListTtsSearch();
    listTtsFilterClass = [];
    listFinal = [];
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

    String query =
        "/api/nguoidung/get/page?filter=(fullName~'*${tenTTS.text}*' or userCode~'*${tenTTS.text}*') and (donhang.orderName~'*${donHang.text}*' or donhang.orderCode~'*${donHang.text}*')";
    if (selectedValueTT == '1') {
      query += 'and stopProcessing:1';
    } else if (selectedValueTT == '8' ||
        selectedValueTT == '9' ||
        selectedValueTT == '10' ||
        selectedValueTT == '11') {
      query += ' and ttsStatusId:$selectedValueTT';
    } else {
      query += ' and ttsStatusId in (8,9,10,11)';
    }
    if (birthDay != null) {
      query += " and birthDate:'$birthDay'";
    }
    if (selectedValueMUT != '-1') {
      query += " and donhang.orderUrgent:$selectedValueMUT";
    }
    print(query);
    var response = await httpGet(query, context);
    if (response.containsKey("body")) {
      setState(() {
        listTtsSearch = jsonDecode(response["body"])['content'];
      });
      listTtsFilterClass = [];
      listFinal = [];
      for (var row in listTtsSearch) {
        if (selectedValueLH == '-1') {
          listTtsFilterClass.add(row);
        } else {
          for (var ttsDt in listTtsDt) {
            if (selectedValueLH != '-1') {
              if (row['id'] == ttsDt['ttsId'] &&
                  ttsDt['daotaoLopId'] == int.parse(selectedValueLH)) {
                listTtsFilterClass.add(row);
                break;
              }
            }
          }
        }
      }

      if (selectedValueGVCN != '-1' && selectedValueDH == '-1') {
        listTtsFilterClass = [];
      }
      for (var row in listTtsFilterClass) {
        if (selectedValueTTDT == '-1') {
          listFinal.add(row);
        } else {
          for (var ttdt in listTrangThaiThanhToan['content']) {
            if (selectedValueTTDT == '1') {
              if (row['id'] == ttdt['ttsId'] &&
                  ttdt['paidTuition'] == int.parse(selectedValueTTDT) &&
                  row['orderId'] == ttdt['orderId'] &&
                  checkPaidFood(ttdt['paidFood'])) {
                listFinal.add(row);
                break;
              }
            } else if (selectedValueTTDT == '2') {
              if (row['id'] == ttdt['ttsId'] &&
                  row['orderId'] == ttdt['orderId'] &&
                  ttdt['paidFood'] != null) {
                listFinal.add(row);
                break;
              }
            } else if (selectedValueTTDT == '3') {
              if (row['id'] == ttdt['ttsId'] &&
                  ttdt['paidTuition'] != 0 &&
                  row['orderId'] == ttdt['orderId']) {
                listFinal.add(row);
                break;
              }
            } else if (selectedValueTTDT == '0') {
              if (row['id'] == ttdt['ttsId'] &&
                  ttdt['paidTuition'] == 0 &&
                  row['orderId'] == ttdt['orderId'] &&
                  ttdt['paidFood'] == null) {
                listFinal.add(row);
                break;
              }
            }
          }
        }
      }

      listSelectedRow = [];
      listIdSelected = [];
      for (int i = 0; i < listFinal.length; i++) {
        listSelectedRow.add(false);
      }
      setState(() {});
      return listTtsSearch;
    }
  }

  var listTtsDt = [];
  getListTtsDT() async {
    var response = await httpGet("/api/daotao-tts/get/page", context);
    if (response.containsKey("body")) {
      setState(() {
        listTtsDt = jsonDecode(response["body"])['content'];
      });
    }
    return 0;
  }

  dynamic selectedValueGVCN = '-1';
  dynamic selectedNameGVCN = '-1';
  dynamic listItemsGVCN = [];
  var listGVCN = [];
  getListGVCN() async {
    var response = await httpGet(
        "/api/nguoidung/get/page?filter=isAam:1 AND departId:7", context);
    if (response.containsKey("body")) {
      setState(() {
        listGVCN = jsonDecode(response["body"])['content'];
      });
    }
    listItemsGVCN = [];
    for (var row in listGVCN) {
      listItemsGVCN.add({
        'value': row['id'].toString(),
        'name': "${row['fullName']} (${row['userCode']})",
        'code': row['userCode']
      });
    }
    return 0;
  }

  var listTtsInLH = [];
  getListTtsInLH(selected) async {
    var response = await httpGet(
        "/api/daotao-tts/get/page?filter=daotaoLopId:$selected", context);
    if (response.containsKey("body")) {
      setState(() {
        listTtsInLH = jsonDecode(response["body"])['content'];
      });
    }
    return 0;
  }

  getSelectedGVCN() async {
    var response =
        await httpGet("/api/daotao-lop/get/$selectedValueLH", context);
    if (response.containsKey("body")) {}
    return "${jsonDecode(response["body"])['giaovien']['fullName']} (${jsonDecode(response["body"])['giaovien']['userCode']})";
  }

  dynamic selectedValueLH = '-1';
  dynamic selectedNameLH = '-1';

  dynamic listItemsLH = [];
  var listLopHoc = [];
  getListLopHoc() async {
    var response;
    if (selectedValueGVCN != '-1') {
      response = await httpGet(
          "/api/daotao-lop/get/page?filter=giaovien.id:$selectedValueGVCN",
          context);
    } else {
      response = await httpGet("/api/daotao-lop/get/page", context);
    }
    if (response.containsKey("body")) {
      setState(() {
        listLopHoc = jsonDecode(response["body"])['content'];
      });
    }
    listItemsLH = [];
    for (var row in listLopHoc) {
      listItemsLH.add({
        'value': row['id'].toString(),
        'name': "${row['name']} (${row['code']})"
      });
    }
    return 0;
  }

  getTrangThaiDongTien() async {
    var response = await httpGet("/api/tts-thanhtoan/get/page", context);
    if (response.containsKey("body")) {
      setState(() {
        listTrangThaiThanhToan = jsonDecode(response["body"]);
      });
    } else {
      throw Exception("Error load data");
    }

    return listTrangThaiThanhToan;
  }

  String trangThaiThanhToan(id, orderId, type) {
    if (type == 'edu') {
      for (var row in listTrangThaiThanhToan['content'] ?? []) {
        if (row['ttsId'] == id && row['orderId'] == orderId) {
          if (row['paidTuition'] == 0)
            return 'Chưa đóng tiền';
          else if (row['paidTuition'] == 1)
            return 'Đóng toàn bộ';
          else if (row['paidTuition'] == 2) return 'Đóng 1 phần';
        }
      }
      return '';
    } else {
      for (var row in listTrangThaiThanhToan['content'] ?? []) {
        if (row['ttsId'] == id && row['orderId'] == orderId) {
          if (row['paidFood'] == null)
            return 'Chưa đóng tiền';
          else if (row['paidFood'].split(',').last == '0')
            return 'Đóng toàn bộ';
          else if (row['paidFood'].split(',').last != '0')
            return 'Tháng ${row['paidFood'].split(',').last}';
        }
      }
      return '';
    }
  }

  var infoTtsTTDT;
  var checkInfoTtsTTDT = [];
  bool checkExist = true;
  var listCheckExist;
  getListTtsTtdt() async {
    var response = await httpGet('/api/tts-thongtindaotao/get/page', context);
    if (response.containsKey("body")) {
      listCheckExist = jsonDecode(response["body"])['content'];
    } else
      throw Exception("Error load data");
    return listCheckExist;
  }

  bool btnActive = false;
  String selectedValueDH = 'Tất cả';

  dynamic selectedValueTT = '-1';
  List<dynamic> itemsTT = [
    {'name': 'Tạm dừng xử lý', 'value': '1'},
    {'name': 'Chờ đào tạo', 'value': '8'},
    {'name': 'Đang đào tạo', 'value': '9'},
    {'name': 'Chờ xuất cảnh', 'value': '10'},
    {'name': 'Đã xuất cảnh', 'value': '11'},
  ];
  dynamic selectedValueMUT = '-1';
  List<dynamic> itemsMUT = [
    {'name': 'Bình thường', 'value': '0'},
    {'name': 'Xử lý gấp', 'value': '1'},
  ];
  dynamic selectedValueTTDT = '-1';
  List<dynamic> itemsTTDT = [
    {'name': 'Đã đóng tiền học', 'value': '3'},
    {'name': 'Đã đóng tiền ăn', 'value': '2'},
    {'name': 'Đã đóng toàn bộ', 'value': '1'},
    {'name': 'Chưa đóng tiền', 'value': '0'},
  ];
  double height = 40;
  TextEditingController tenTTS = TextEditingController();
  TextEditingController donHang = TextEditingController();
  TextEditingController lop = TextEditingController();
  TextEditingController giaoVien = TextEditingController();
  List<bool> listSelectedRow = [];
  List<dynamic> listIdSelected = [];
  void searchFuction() {
    currentPage = 1;
    setState(() {
      search = true;
      requestName = tenTTS.text;
      requestClass = lop.text;
      requestOrder = donHang.text;
      getListTTSFuture = getListTtsSearch();
    });
  }

  @override
  void initState() {
    getListTTSFuture = getListTtsSearch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var curentUser =
        Provider.of<SecurityModel>(context, listen: false).userLoginCurren;
    return FutureBuilder<dynamic>(
      future: userRule('/danh-sach-thuc-tap-sinh', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return FutureBuilder<dynamic>(
            future: getListTTSFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                String nameLh(id) {
                  for (var row in listTtsDt) {
                    if (row['ttsId'] == id) {
                      return row['lophoc']['name'];
                    }
                  }
                  return '';
                }

                String nameGVCN(id) {
                  for (var row in listTtsDt) {
                    if (row['ttsId'] == id) {
                      return row['lophoc']['giaovien']['fullName'];
                    }
                  }
                  return '';
                }

                final double width = MediaQuery.of(context).size.width;

                rowCount = listFinal.length;
                firstRow = (currentPage - 1) * rowPerPage;
                lastRow = currentPage * rowPerPage - 1;
                if (lastRow > rowCount - 1) {
                  lastRow = rowCount - 1;
                }
                return ListView(
                  children: [
                    TitlePage(
                      listPreTitle: [
                        {'url': '/bang-thong-ke-nhanh', 'title': 'Dashboard'},
                      ],
                      content: 'Danh sách thực tập sinh',
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
                              // padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                              margin: EdgeInsets.only(top: 20),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 1,
                                decoration: BoxDecoration(
                                  color: colorWhite,
                                  borderRadius: borderRadiusContainer,
                                  boxShadow: [boxShadowContainer],
                                  border: borderAllContainerBox,
                                ),
                                padding: paddingBoxContainer,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SelectableText(
                                          'Nhập thông tin tìm kiếm',
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
                                      children: [
                                        Expanded(
                                            flex: 3,
                                            child: TextFieldValidatedForm(
                                              type: 'None',
                                              height: 40,
                                              controller: tenTTS,
                                              label: 'Tên TTS',
                                              flexLable: 2,
                                              flexTextField: 5,
                                              enter: () {
                                                searchFuction();
                                                setState(() {});
                                              },
                                            )),
                                        SizedBox(
                                          width: 100,
                                        ),
                                        Expanded(
                                            flex: 3,
                                            child: Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 30),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: DatePickerBoxVQ(
                                                        label: SelectableText(
                                                          'Ngày sinh',
                                                          style: titleWidgetBox,
                                                        ),
                                                        isTime: false,
                                                        selectedDateFunction:
                                                            (day) {
                                                          birthDay = day;
                                                          setState(() {});
                                                        }),
                                                  ),
                                                ],
                                              ),
                                            )),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                            flex: 3,
                                            child: Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 30),
                                              child: DropdownBtnSearch(
                                                isAll: true,
                                                label: 'Trạng thái',
                                                listItems: itemsTT,
                                                isSearch: false,
                                                selectedValue: selectedValueTT,
                                                setSelected: (selected) {
                                                  selectedValueTT = selected;
                                                },
                                              ),
                                            )),
                                        SizedBox(
                                          width: 100,
                                        ),
                                        Expanded(
                                            flex: 3,
                                            child: Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 30),
                                              // child: DropdownBtnSearch(
                                              //   isAll: true,
                                              //   label: 'Lớp',
                                              //   listItems: listItemsLH,
                                              //   search: searchLH,
                                              //   isSearch: true,
                                              //   selectedValue: selectedValueLH,
                                              //   setSelected: (selected) async {
                                              //     selectedValueLH = selected;
                                              //     if (selectedValueLH != '-1') {
                                              //       await getSelectedGVCN()
                                              //           .then((data) {
                                              //         print(selectedValueGVCN);
                                              //         selectedValueGVCN = data;
                                              //         print(selectedValueGVCN);
                                              //         setState(() {});
                                              //       });
                                              //     } else {
                                              //       selectedValueGVCN = '-1';
                                              //     }
                                              //     setState(() {});
                                              //   },
                                              // ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      flex: 2,
                                                      child: SelectableText(
                                                        'Lớp',
                                                        style: titleWidgetBox,
                                                      )),
                                                  Expanded(
                                                      flex: 5,
                                                      child: Container(
                                                        color: Colors.white,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.25,
                                                        height: 40,
                                                        child:
                                                            DropdownButtonHideUnderline(
                                                          child:
                                                              DropdownButton2(
                                                            dropdownMaxHeight:
                                                                300,
                                                            searchController:
                                                                searchLH,
                                                            searchInnerWidget:
                                                                Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                top: 0,
                                                                bottom: 0,
                                                                right: 0,
                                                                left: 0,
                                                              ),
                                                              child:
                                                                  TextFormField(
                                                                controller:
                                                                    searchLH,
                                                                decoration:
                                                                    InputDecoration(
                                                                        isDense:
                                                                            true,
                                                                        contentPadding: const EdgeInsets
                                                                            .symmetric(
                                                                          horizontal:
                                                                              10,
                                                                          vertical:
                                                                              15,
                                                                        ),
                                                                        hintText:
                                                                            'Tìm kiếm',
                                                                        hintStyle: const TextStyle(
                                                                            fontSize:
                                                                                14),
                                                                        border:
                                                                            InputBorder.none),
                                                              ),
                                                            ),
                                                            searchMatchFn: (item,
                                                                searchValue) {
                                                              return (item.child
                                                                  .toString()
                                                                  .contains(
                                                                      searchValue));
                                                            },
                                                            //This to clear the search value when you close the menu
                                                            onMenuStateChange:
                                                                (isOpen) {
                                                              if (!isOpen) {
                                                                searchLH
                                                                    .clear();
                                                              }
                                                            },
                                                            isExpanded: true,
                                                            items: [
                                                              DropdownMenuItem<
                                                                  String>(
                                                                value: '-1',
                                                                child:
                                                                    SelectableText(
                                                                  'Tất cả',
                                                                ),
                                                              ),
                                                              for (var row
                                                                  in listItemsLH)
                                                                DropdownMenuItem<
                                                                    String>(
                                                                  value:
                                                                      "${row['name']} ${row['value']}",
                                                                  child:
                                                                      SelectableText(
                                                                    row['name'],
                                                                  ),
                                                                )
                                                            ],
                                                            value:
                                                                selectedNameLH,
                                                            onChanged:
                                                                (value) async {
                                                              selectedNameLH =
                                                                  value;
                                                              for (var row
                                                                  in listItemsLH) {
                                                                if ("${row['name']} ${row['value']}" ==
                                                                    value) {
                                                                  selectedValueLH =
                                                                      row['value'];
                                                                }
                                                              }
                                                              if (selectedNameLH !=
                                                                  '-1') {
                                                                await getSelectedGVCN()
                                                                    .then(
                                                                        (data) {
                                                                  selectedNameGVCN =
                                                                      data;
                                                                });
                                                              } else {
                                                                selectedNameGVCN =
                                                                    '-1';
                                                                selectedValueGVCN =
                                                                    '-1';
                                                                selectedValueLH =
                                                                    '-1';
                                                              }
                                                              setState(() {});
                                                            },
                                                            dropdownDecoration:
                                                                BoxDecoration(
                                                                    border: Border.all(
                                                                        color: const Color.fromRGBO(
                                                                            216,
                                                                            218,
                                                                            229,
                                                                            1))),
                                                            buttonDecoration: BoxDecoration(
                                                                border: Border.all(
                                                                    width: 0.5,
                                                                    style: BorderStyle
                                                                        .solid)),
                                                            buttonElevation: 0,
                                                            buttonPadding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 14,
                                                                    right: 14),
                                                            itemPadding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 14,
                                                                    right: 14),
                                                            dropdownElevation:
                                                                5,
                                                            focusColor:
                                                                Colors.white,
                                                          ),
                                                        ),
                                                      ))
                                                ],
                                              ),
                                            )),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                            flex: 3,
                                            child: TextFieldValidatedForm(
                                              height: 40,
                                              type: 'None',
                                              controller: donHang,
                                              label: 'Đơn hàng',
                                              flexLable: 2,
                                              flexTextField: 5,
                                              enter: () {
                                                searchFuction();
                                              },
                                            )),
                                        SizedBox(
                                          width: 100,
                                        ),
                                        Expanded(
                                            flex: 3,
                                            child: Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 30),
                                              // child: DropdownBtnSearch(
                                              //   isAll: true,
                                              //   label: 'Giáo viên chủ nhiệm',
                                              //   listItems: listItemsGVCN,
                                              //   search: searchGVCN,
                                              //   isSearch: true,
                                              //   selectedValue: selectedValueGVCN,
                                              //   setSelected: (selected) {
                                              //     selectedValueGVCN = selected;
                                              //     selectedValueLH = '-1';
                                              //     getListLopHoc();
                                              //     print(selectedValueGVCN);
                                              //     setState(() {});
                                              //   },
                                              // ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      flex: 2,
                                                      child: SelectableText(
                                                        'Giáo viên chủ nhiệm',
                                                        style: titleWidgetBox,
                                                      )),
                                                  Expanded(
                                                      flex: 5,
                                                      child: Container(
                                                        color: Colors.white,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.25,
                                                        height: 40,
                                                        child:
                                                            DropdownButtonHideUnderline(
                                                          child:
                                                              DropdownButton2(
                                                            dropdownMaxHeight:
                                                                300,
                                                            searchController:
                                                                searchGVCN,
                                                            searchInnerWidget:
                                                                Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                top: 0,
                                                                bottom: 0,
                                                                right: 0,
                                                                left: 0,
                                                              ),
                                                              child:
                                                                  TextFormField(
                                                                controller:
                                                                    searchGVCN,
                                                                decoration:
                                                                    InputDecoration(
                                                                        isDense:
                                                                            true,
                                                                        contentPadding: const EdgeInsets
                                                                            .symmetric(
                                                                          horizontal:
                                                                              10,
                                                                          vertical:
                                                                              15,
                                                                        ),
                                                                        hintText:
                                                                            'Tìm kiếm',
                                                                        hintStyle: const TextStyle(
                                                                            fontSize:
                                                                                14),
                                                                        border:
                                                                            InputBorder.none),
                                                              ),
                                                            ),
                                                            searchMatchFn: (item,
                                                                searchValue) {
                                                              return (item.value
                                                                  .toString()
                                                                  .toLowerCase()
                                                                  .contains(
                                                                      searchValue
                                                                          .toLowerCase()));
                                                            },
                                                            //This to clear the search value when you close the menu
                                                            onMenuStateChange:
                                                                (isOpen) {
                                                              if (!isOpen) {
                                                                searchGVCN
                                                                    .clear();
                                                              }
                                                            },
                                                            isExpanded: true,
                                                            items: [
                                                              DropdownMenuItem<
                                                                  String>(
                                                                value: '-1',
                                                                child: Text(
                                                                  'Tất cả',
                                                                ),
                                                              ),
                                                              for (var row
                                                                  in listItemsGVCN)
                                                                DropdownMenuItem<
                                                                    String>(
                                                                  value:
                                                                      "${row['name']} ${row['value']}",
                                                                  child: Text(
                                                                    row['name'],
                                                                  ),
                                                                )
                                                            ],
                                                            value:
                                                                selectedNameGVCN,
                                                            onChanged: (value) {
                                                              setState(() {
                                                                selectedNameGVCN =
                                                                    value;
                                                                for (var row
                                                                    in listItemsGVCN) {
                                                                  if ("${row['name']} ${row['value']}" ==
                                                                      value)
                                                                    selectedValueGVCN =
                                                                        row['value'];
                                                                }
                                                                if (value ==
                                                                    '-1')
                                                                  selectedValueGVCN =
                                                                      '-1';
                                                                selectedValueLH =
                                                                    '-1';
                                                                getListLopHoc();
                                                              });
                                                            },
                                                            dropdownDecoration:
                                                                BoxDecoration(
                                                                    border: Border.all(
                                                                        color: const Color.fromRGBO(
                                                                            216,
                                                                            218,
                                                                            229,
                                                                            1))),
                                                            buttonDecoration: BoxDecoration(
                                                                border: Border.all(
                                                                    width: 0.5,
                                                                    style: BorderStyle
                                                                        .solid)),
                                                            buttonElevation: 0,
                                                            buttonPadding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 14,
                                                                    right: 14),
                                                            itemPadding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 14,
                                                                    right: 14),
                                                            dropdownElevation:
                                                                5,
                                                            focusColor:
                                                                Colors.white,
                                                          ),
                                                        ),
                                                      ))
                                                ],
                                              ),
                                            )),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                            flex: 3,
                                            child: Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 30),
                                              child: DropdownBtnSearch(
                                                isAll: true,
                                                label: 'Mức ưu tiên',
                                                listItems: itemsMUT,
                                                isSearch: false,
                                                selectedValue: selectedValueMUT,
                                                setSelected: (selected) {
                                                  selectedValueMUT = selected;
                                                },
                                              ),
                                            )),
                                        SizedBox(
                                          width: 100,
                                        ),
                                        Expanded(
                                            flex: 3,
                                            child: Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 30),
                                              child: DropdownBtnSearch(
                                                isAll: true,
                                                label: 'Trạng thái đóng tiền',
                                                listItems: itemsTTDT,
                                                isSearch: false,
                                                selectedValue:
                                                    selectedValueTTDT,
                                                setSelected: (selected) {
                                                  selectedValueTTDT = selected;
                                                },
                                              ),
                                            )),
                                      ],
                                    ),
                                    SizedBox(height: 50),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        curentUser['departId'] == 1 ||
                                                curentUser['departId'] == 2 ||
                                                (curentUser['departId'] == 7 &&
                                                    curentUser['vaitro'] !=
                                                        null &&
                                                    curentUser['vaitro']
                                                            ['level'] >=
                                                        2)
                                            ? getRule(listRule.data, Role.Sua,
                                                    context)
                                                ? Container(
                                                    margin: EdgeInsets.only(
                                                        left: 20),
                                                    child: TextButton(
                                                      style:
                                                          TextButton.styleFrom(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          vertical: 20.0,
                                                          horizontal: 10.0,
                                                        ),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.0),
                                                        ),
                                                        backgroundColor:
                                                            btnActive == true
                                                                ? Color
                                                                    .fromRGBO(
                                                                        245,
                                                                        117,
                                                                        29,
                                                                        1)
                                                                : Colors.grey,
                                                        primary:
                                                            Theme.of(context)
                                                                .iconTheme
                                                                .color,
                                                        textStyle: Theme.of(
                                                                context)
                                                            .textTheme
                                                            .caption
                                                            ?.copyWith(
                                                                fontSize: 20.0,
                                                                letterSpacing:
                                                                    2.0),
                                                      ),
                                                      onPressed:
                                                          btnActive == true
                                                              ? () {
                                                                  showDialog(
                                                                    context:
                                                                        context,
                                                                    builder: (BuildContext
                                                                            context) =>
                                                                        DungXuLy(
                                                                            setState:
                                                                                () {
                                                                              getListTTSFuture = getListTtsSearch();

                                                                              setState(() {});
                                                                            },
                                                                            listIdSelected:
                                                                                listIdSelected,
                                                                            titleDialog:
                                                                                'Dừng xử lý'),
                                                                  );
                                                                }
                                                              : null,
                                                      child: SelectableText(
                                                          'Dừng xử lý ',
                                                          style: textButton),
                                                    ),
                                                  )
                                                : Container()
                                            : Container(),
                                        getRule(listRule.data, Role.Xem,
                                                context)
                                            ? Container(
                                                margin:
                                                    EdgeInsets.only(left: 20),
                                                child: TextButton.icon(
                                                  style: TextButton.styleFrom(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      vertical: 20.0,
                                                      horizontal: 10.0,
                                                    ),
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
                                                            fontSize: 20.0,
                                                            letterSpacing: 2.0),
                                                  ),
                                                  onPressed: () {
                                                    searchFuction();
                                                  },
                                                  icon: Transform.rotate(
                                                    angle: 270,
                                                    child: Icon(
                                                      Icons.search,
                                                      color: Colors.white,
                                                      size: 15,
                                                    ),
                                                  ),
                                                  label: Row(
                                                    children: [
                                                      SelectableText(
                                                          'Tìm kiếm ',
                                                          style: textButton),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                        curentUser['departId'] == 1 ||
                                                curentUser['departId'] == 2 ||
                                                (curentUser['departId'] == 7 &&
                                                    curentUser['vaitro'] !=
                                                        null &&
                                                    curentUser['vaitro']
                                                            ['level'] ==
                                                        1)
                                            ? getRule(listRule.data, Role.Sua,
                                                    context)
                                                ? Container(
                                                    margin: EdgeInsets.only(
                                                        left: 20),
                                                    child: TextButton(
                                                      style:
                                                          TextButton.styleFrom(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          vertical: 20.0,
                                                          horizontal: 10.0,
                                                        ),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.0),
                                                        ),
                                                        backgroundColor: btnActive ==
                                                                    true &&
                                                                listIdSelected
                                                                        .length ==
                                                                    1
                                                            ? Color.fromRGBO(
                                                                245, 117, 29, 1)
                                                            : Colors.grey,
                                                        primary:
                                                            Theme.of(context)
                                                                .iconTheme
                                                                .color,
                                                        textStyle: Theme.of(
                                                                context)
                                                            .textTheme
                                                            .caption
                                                            ?.copyWith(
                                                                fontSize: 20.0,
                                                                letterSpacing:
                                                                    2.0),
                                                      ),
                                                      onPressed: btnActive ==
                                                                  true &&
                                                              listIdSelected
                                                                      .length ==
                                                                  1
                                                          ? () {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder: (BuildContext context) =>
                                                                    XacNhanThuTien(
                                                                        listTrangThaiThanhToan:
                                                                            listTrangThaiThanhToan,
                                                                        setState:
                                                                            () async {
                                                                          await getTrangThaiDongTien();
                                                                          getListTTSFuture =
                                                                              getListTtsSearch();
                                                                          setState(
                                                                              () {});
                                                                        },
                                                                        tts: listIdSelected
                                                                            .first,
                                                                        titleDialog:
                                                                            'Xác nhận thu tiền'),
                                                              );
                                                            }
                                                          : null,
                                                      child: Text(
                                                          'Xác nhận thu tiền',
                                                          style: textButton),
                                                    ),
                                                  )
                                                : Container()
                                            : Container(),
                                        curentUser['departId'] == 1 ||
                                                curentUser['departId'] == 2 ||
                                                (curentUser['departId'] == 7 &&
                                                    curentUser['vaitro'] !=
                                                        null &&
                                                    curentUser['vaitro']
                                                            ['level'] >=
                                                        2)
                                            ? getRule(listRule.data, Role.Sua,
                                                    context)
                                                ? Container(
                                                    margin: EdgeInsets.only(
                                                        left: 20),
                                                    child: TextButton(
                                                      style:
                                                          TextButton.styleFrom(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          vertical: 20.0,
                                                          horizontal: 10.0,
                                                        ),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.0),
                                                        ),
                                                        backgroundColor:
                                                            btnActive == true
                                                                ? Color
                                                                    .fromRGBO(
                                                                        245,
                                                                        117,
                                                                        29,
                                                                        1)
                                                                : Colors.grey,
                                                        primary:
                                                            Theme.of(context)
                                                                .iconTheme
                                                                .color,
                                                        textStyle: Theme.of(
                                                                context)
                                                            .textTheme
                                                            .caption
                                                            ?.copyWith(
                                                                fontSize: 20.0,
                                                                letterSpacing:
                                                                    2.0),
                                                      ),
                                                      onPressed:
                                                          btnActive == true
                                                              ? () async {
                                                                  var checkStatus =
                                                                      true;
                                                                  for (var row
                                                                      in listIdSelected) {
                                                                    if (row['ttsStatusId'] !=
                                                                        9) {
                                                                      checkStatus =
                                                                          false;
                                                                      break;
                                                                    }
                                                                    if (listCheckExist
                                                                        .isEmpty)
                                                                      checkExist =
                                                                          false;
                                                                    for (var listId
                                                                        in listCheckExist) {
                                                                      if (row['id'] ==
                                                                          listId[
                                                                              'ttsId']) {
                                                                        checkExist =
                                                                            true;
                                                                        break;
                                                                      } else {
                                                                        checkExist =
                                                                            false;
                                                                      }
                                                                    }
                                                                    if (checkExist ==
                                                                        false) {
                                                                      break;
                                                                    } else {
                                                                      continue;
                                                                    }
                                                                  }
                                                                  if (checkExist ==
                                                                          false ||
                                                                      checkStatus ==
                                                                          false) {
                                                                    if (checkExist ==
                                                                        false) {
                                                                      showToast(
                                                                        context:
                                                                            context,
                                                                        msg:
                                                                            "Chưa có thông tin đào tạo",
                                                                        color: Colors
                                                                            .red,
                                                                        icon: Icon(
                                                                            Icons.warning),
                                                                      );
                                                                      checkExist =
                                                                          true;
                                                                    }
                                                                    if (checkStatus ==
                                                                        false) {
                                                                      showToast(
                                                                        context:
                                                                            context,
                                                                        msg:
                                                                            "Thực tập sinh không trong trạng thái đang đào tạo",
                                                                        color: Colors
                                                                            .red,
                                                                        icon: Icon(
                                                                            Icons.warning),
                                                                      );
                                                                      checkStatus =
                                                                          true;
                                                                    }
                                                                  } else {
                                                                    showDialog(
                                                                      context:
                                                                          context,
                                                                      builder: (BuildContext context) => XacNhanManKhoa(
                                                                          setState: () {
                                                                            getListTTSFuture =
                                                                                getListTtsSearch();
                                                                            setState(() {});
                                                                          },
                                                                          listIdSelected: listIdSelected,
                                                                          titleDialog: 'Xác nhận mãn khóa'),
                                                                    );
                                                                  }
                                                                }
                                                              : null,
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                              'Xác nhận mãn khóa',
                                                              style:
                                                                  textButton),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : Container()
                                            : Container(),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ]),
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
                                          columnSpacing: 5,
                                          showCheckboxColumn: true,
                                          dataRowHeight: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  1600
                                              ? 78
                                              : 63,
                                          columns: [
                                            DataColumn(
                                                label: Container(
                                              child: SelectableText('STT',
                                                  style: titleTableData),
                                            )),
                                            DataColumn(
                                                label: SelectableText('Mã TTS',
                                                    style: titleTableData)),
                                            DataColumn(
                                                label: SelectableText('Tên TTS',
                                                    style: titleTableData)),
                                            DataColumn(
                                                label: Container(
                                              child: SelectableText('Lớp',
                                                  style: titleTableData),
                                            )),
                                            DataColumn(
                                                label: Container(
                                              child: SelectableText('GVCN',
                                                  style: titleTableData),
                                            )),
                                            DataColumn(
                                                label: Container(
                                              child: SelectableText(
                                                  'Trạng thái',
                                                  style: titleTableData),
                                            )),
                                            DataColumn(
                                                label: Container(
                                              child: SelectableText('Tiền học',
                                                  style: titleTableData),
                                            )),
                                            DataColumn(
                                                label: Container(
                                              child: SelectableText('Tiền ăn',
                                                  style: titleTableData),
                                            )),
                                            DataColumn(
                                                label: Container(
                                              child: SelectableText('Đơn hàng',
                                                  style: titleTableData),
                                            )),
                                            DataColumn(
                                                label: Container(
                                              child: SelectableText('Hành động',
                                                  style: titleTableData),
                                            )),
                                          ],
                                          rows: <DataRow>[
                                            for (int i = firstRow;
                                                i <= lastRow;
                                                i++)
                                              DataRow(
                                                selected: listSelectedRow[i],
                                                onSelectChanged: listFinal[i][
                                                            'stopProcessing'] ==
                                                        1
                                                    ? null
                                                    : (value) {
                                                        setState(() {
                                                          if (listIdSelected
                                                              .contains(
                                                                  listFinal[
                                                                      i])) {
                                                            listIdSelected
                                                                .remove(
                                                                    listFinal[
                                                                        i]);
                                                          } else {
                                                            listIdSelected.add(
                                                                listFinal[i]);
                                                          }
                                                          listSelectedRow[i] =
                                                              value!;
                                                          for (int i = 0;
                                                              i <
                                                                  listSelectedRow
                                                                      .length;
                                                              i++) {
                                                            if (listSelectedRow[
                                                                    i] ==
                                                                true) {
                                                              btnActive = true;
                                                              break;
                                                            }
                                                            btnActive = false;
                                                          }
                                                          for (var row
                                                              in listIdSelected) {
                                                            if (row['stopProcessing'] ==
                                                                1) {
                                                              btnActive = false;
                                                              break;
                                                            }
                                                          }
                                                        });
                                                      },
                                                cells: <DataCell>[
                                                  DataCell(Container(
                                                      child: SelectableText(
                                                          "${i + 1}"))),

                                                  DataCell(
                                                    Container(
                                                      width: MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              1600
                                                          ? MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.046
                                                          : MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.08,
                                                      child: SelectableText(
                                                          listFinal[i]
                                                              ['userCode'],
                                                          style: bangDuLieu),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Container(
                                                      width: MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              1600
                                                          ? MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.075
                                                          : MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.1,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          SelectableText(
                                                              listFinal[i][
                                                                      'fullName'] ??
                                                                  '',
                                                              style:
                                                                  bangDuLieu),
                                                          SelectableText(
                                                              listFinal[i][
                                                                          'birthDate'] ==
                                                                      null
                                                                  ? ''
                                                                  : dateReverse(
                                                                      listFinal[
                                                                              i]
                                                                          [
                                                                          'birthDate']),
                                                              style:
                                                                  bangDuLieu),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Container(
                                                      width: MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              1600
                                                          ? MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.065
                                                          : MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.12,
                                                      child: SelectableText(
                                                          nameLh(listFinal[i]
                                                              ['id']),
                                                          style: bangDuLieu),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Container(
                                                      child: SelectableText(
                                                          nameGVCN(listFinal[i]
                                                              ['id']),
                                                          style: bangDuLieu),
                                                    ),
                                                  ),

                                                  DataCell(
                                                    Container(
                                                      child: listFinal[i][
                                                                  'stopProcessing'] ==
                                                              1
                                                          ? SelectableText(
                                                              'Tạm dừng xử lý',
                                                              style: TextStyle(
                                                                  color:
                                                                      colorOrange))
                                                          : SelectableText(
                                                              listFinal[i][
                                                                      'ttsTrangthai']
                                                                  [
                                                                  'statusName'],
                                                              style: TextStyle(
                                                                color: listFinal[i]
                                                                            [
                                                                            'ttsStatusId'] !=
                                                                        10
                                                                    ? Color(
                                                                        0xff333333)
                                                                    : Colors
                                                                        .green,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              )),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Container(
                                                      width: MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              1600
                                                          ? MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.045
                                                          : MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.05,
                                                      child: SelectableText(
                                                          trangThaiThanhToan(
                                                              listFinal[i]
                                                                  ['id'],
                                                              listFinal[i]
                                                                  ['orderId'],
                                                              'edu'),
                                                          style: bangDuLieu),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Container(
                                                      width: MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              1600
                                                          ? MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.045
                                                          : MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.05,
                                                      child: SelectableText(
                                                          trangThaiThanhToan(
                                                              listFinal[i]
                                                                  ['id'],
                                                              listFinal[i]
                                                                  ['orderId'],
                                                              'food'),
                                                          style: bangDuLieu),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Container(
                                                      width: MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              1600
                                                          ? MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.065
                                                          : MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.12,
                                                      child: SelectableText(
                                                          listFinal[i][
                                                                      'donhang'] !=
                                                                  null
                                                              ? listFinal[i][
                                                                      'donhang']
                                                                  ['orderName']
                                                              : 'nodata',
                                                          style: bangDuLieu),
                                                    ),
                                                  ),
                                                  DataCell(Container(
                                                    child: Row(
                                                      children: [
                                                        getRule(
                                                                listRule.data,
                                                                Role.Xem,
                                                                context)
                                                            ? Tooltip(
                                                                message:
                                                                    "Xem chi tiết thông tin đào tạo",
                                                                child: Container(
                                                                    child: InkWell(
                                                                        onTap: () async {
                                                                          Provider.of<NavigationModel>(context, listen: false)
                                                                              .add(pageUrl: "/view-thong-tin-thuc-tap-sinh/${listFinal[i]['id']}");
                                                                        },
                                                                        child: Icon(Icons.visibility))),
                                                              )
                                                            : Container(),
                                                        curentUser['departId'] == 1 ||
                                                                curentUser[
                                                                        'departId'] ==
                                                                    2 ||
                                                                (curentUser['departId'] ==
                                                                        7 &&
                                                                    curentUser[
                                                                            'vaitro'] !=
                                                                        null &&
                                                                    curentUser['vaitro']
                                                                            [
                                                                            'level'] !=
                                                                        1)
                                                            ? getRule(
                                                                        listRule
                                                                            .data,
                                                                        Role
                                                                            .Sua,
                                                                        context) ||
                                                                    getRule(
                                                                        listRule
                                                                            .data,
                                                                        Role.Them,
                                                                        context)
                                                                ? Tooltip(
                                                                    message: listFinal[i]['stopProcessing'] ==
                                                                            0
                                                                        ? listFinal[i]['ttsStatusId'] ==
                                                                                8
                                                                            ? 'Thực tập sinh chưa được phân lớp đào tạo'
                                                                            : "Chỉnh sửa/thêm mới thông tin đào tạo"
                                                                        : "TTS đang tạm dừng xử lý",
                                                                    child: Container(
                                                                        margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                        child: InkWell(
                                                                            onTap: listFinal[i]['stopProcessing'] == 1 || listFinal[i]['ttsStatusId'] == 8
                                                                                ? null
                                                                                : () {
                                                                                    if ((curentUser['departId'] == 7 && curentUser['vaitro'] != null && curentUser['vaitro']['level'] == 0)) {
                                                                                      for (var row in listCheckExist) {
                                                                                        if (listFinal[i]['id'] == row['ttsId']) {
                                                                                          checkExist = true;
                                                                                          break;
                                                                                        } else {
                                                                                          checkExist = false;
                                                                                        }
                                                                                      }
                                                                                      if (listCheckExist.isEmpty) checkExist = false;
                                                                                      if (checkExist == false) {
                                                                                        showToast(
                                                                                          context: context,
                                                                                          msg: "Chưa có thông tin đào tạo",
                                                                                          color: Colors.red,
                                                                                          icon: Icon(Icons.warning),
                                                                                        );
                                                                                        checkExist = true;
                                                                                      } else
                                                                                        Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/cap-nhat-thong-tin-dao-tao/${listFinal[i]['id']}");
                                                                                    } else {
                                                                                      Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/cap-nhat-thong-tin-dao-tao/${listFinal[i]['id']}");
                                                                                    }
                                                                                  },
                                                                            child: Icon(
                                                                              Icons.edit_calendar,
                                                                              color: listFinal[i]['stopProcessing'] == 1 || listFinal[i]['ttsStatusId'] == 8 ? Colors.grey : Color(0xff009C87),
                                                                            ))),
                                                                  )
                                                                : Container()
                                                            : Container(),
                                                      ],
                                                    ),
                                                  )),
                                                  //
                                                ],
                                              )
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
class XacNhanThuTien extends StatefulWidget {
  final String titleDialog;
  final dynamic tts;
  final Function setState;
  final dynamic listTrangThaiThanhToan;
  const XacNhanThuTien(
      {Key? key,
      required this.titleDialog,
      required this.tts,
      required this.setState,
      required this.listTrangThaiThanhToan})
      : super(key: key);

  @override
  State<XacNhanThuTien> createState() => _XacNhanThuTienState();
}

class _XacNhanThuTienState extends State<XacNhanThuTien> {
  DateTime selectedDate = DateTime.now();
  dynamic selectedValueTTDT = '2';
  String titleLog = 'Cập nhật dữ liệu thành công';
  bool setDate = false;
  List<dynamic> itemsLTT = [
    {'name': 'Thanh toán tiền ăn', 'value': 'paidFood'},
    {'name': 'Thu tiền học', 'value': 'paidTuition'}
  ];
  String selectedValueLTT = 'paidTuition';

  List<dynamic> itemsTTDT = [
    {'name': 'Chưa đóng tiền', 'value': '0'},
    {'name': 'Đã đóng toàn bộ', 'value': '1'},
    {'name': 'Đóng 1 phần', 'value': '2'}
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
  idThanhToan(id, orderId) {
    for (var row in widget.listTrangThaiThanhToan['content'] ?? []) {
      if (row['ttsId'] == id && row['orderId'] == orderId) {
        if (row['paidTuition'] == 0)
          return row;
        else if (row['paidTuition'] == 1)
          return row;
        else if (row['paidTuition'] == 2)
          return row;
        else if (row['paidTuition'] == 3) return row;
      }
    }
    return 0;
  }

  int? userVerifier;
  String? ngayDongTien =
      DateFormat("dd-MM-yyyy").format(DateTime.now().toLocal());
  var thucTapSinhThanhToan;
  updateTTDT() async {
    if (idThanhToan(widget.tts['id'], widget.tts['orderId']) != 0) {
      String month = '';
      String time = DateFormat("HH:mm").format(DateTime.now().toLocal());
      String verifier = "$selectedValueLTT" + 'Verifier';
      if (selectedValueLTT == 'paidFood') {
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
        thucTapSinhThanhToan['paidFood'] = month;

        thucTapSinhThanhToan['paidFoodDate'] = ngayDongTien != null
            ? convertTimeStamp(ngayDongTien!, time)
            : ngayDongTien;
        thucTapSinhThanhToan['$verifier'] = userVerifier;
        if (selectedValueTTDT == '0') {
          thucTapSinhThanhToan['paidFood'] = null;
          thucTapSinhThanhToan['$verifier'] = null;
          thucTapSinhThanhToan['paidFoodDate'] = null;
        }
      } else {
        thucTapSinhThanhToan['$verifier'] = userVerifier;
        thucTapSinhThanhToan['paidTuition'] = int.parse(selectedValueTTDT);
        thucTapSinhThanhToan['paidTuitionDate'] = ngayDongTien != null
            ? convertTimeStamp(ngayDongTien!, time)
            : ngayDongTien;
        if (selectedValueTTDT == '0') {
          thucTapSinhThanhToan['paidTuitionDate'] = null;
          thucTapSinhThanhToan['$verifier'] = null;
        }
      }
      var response = await httpPut(
          '/api/tts-thanhtoan/put/${thucTapSinhThanhToan['id']}',
          thucTapSinhThanhToan,
          context);

      if (response['body'] == 'true') {
        await httpPost(
            "/api/push/tags/user_code/${widget.tts['nhanvientuyendung']['userCode']}",
            {
              "title": "Hệ thống thông báo",
              "message":
                  "TTS mã ${widget.tts['userCode']}-${widget.tts['fullName']} đã đóng tiền ${selectedValueLTT == 'paidFood' ? "ăn" : "học"} vào ngày $ngayDongTien"
            },
            context);
       
        await httpPostDiariStatus(
            widget.tts['id'],
            widget.tts['ttsStatusId'],
            widget.tts['ttsStatusId'],
            'Nộp tiền ${selectedValueLTT == 'paidFood' ? "ăn" : "học"}',
            context);
        await httpPost(
            "/api/push/tags/depart_id/9&7",
            {
              "title": "Hệ thống thông báo",
              "message":
                  "TTS mã ${widget.tts['userCode']}-${widget.tts['fullName']} đã đóng tiền ${selectedValueLTT == 'paidFood' ? "ăn" : "học"} vào ngày $ngayDongTien"
            },
            context);
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
    thucTapSinhThanhToan = idThanhToan(widget.tts['id'], widget.tts['orderId']);
    if (thucTapSinhThanhToan != 0) food = thucTapSinhThanhToan['paidFood'];

    super.initState();
  }

  bool paidFood = false;
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
                  widget.titleDialog,
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
        height: 400,
        child: ListView(
          children: [
            Column(
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
                  height: paidFood ? 500 : 300,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DropdownBtnSearch(
                        isAll: false,
                        flexLabel: 3,
                        label: 'Loại thanh toán',
                        listItems: itemsLTT,
                        isSearch: false,
                        selectedValue: selectedValueLTT,
                        setSelected: (selected) {
                          selectedValueLTT = selected;
                          if (selectedValueLTT == 'paidFood') {
                            if (food != null) {
                              var month = food!.split(',');
                              for (int i = 0; i < month.length; i++) {
                                if (month[i] != '' &&
                                    int.parse(month[i]) != 0) {
                                  listCheckBox[int.parse(month[i]) - 1]
                                      ['value'] = true;
                                }
                              }
                            }
                            paidFood = true;
                          } else
                            paidFood = false;
                          setState(() {});
                        },
                      ),
                      DropdownBtnSearch(
                        isAll: false,
                        flexLabel: 3,
                        label: 'Trạng thái đóng tiền',
                        listItems: itemsTTDT,
                        isSearch: false,
                        selectedValue: selectedValueTTDT,
                        setSelected: (selected) {
                          selectedValueTTDT = selected;
                          setState(() {});
                        },
                      ),
                      DatePickerBoxVQ(
                          label: SelectableText(
                            'Ngày tháng',
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
                      paidFood
                          ? ListMonth(
                              listCheckBox: listCheckBox,
                              function: (value) {
                                listCheckBox = value;
                              })
                          : Container()
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
            if (ngayDongTien == null) {
              showToast(
                context: context,
                msg: 'Ngày đóng tiền không được để trống',
                color: Colors.red,
                icon: const Icon(Icons.warning),
              );
            } else {
              if (status) {
                await showDialog(
                  context: context,
                  builder: (BuildContext context) => ConfirmUpdate(
                      title: "Xác nhận thanh toán",
                      content:
                          "Bạn có chắc chắn muốn thanh toán cho thực tập sinh",
                      function: () async {
                        await updateTTDT();
                        widget.setState();
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
                        Navigator.pop(context);
                      }),
                );
                Navigator.pop(context);
              } else {
                showToast(
                  context: context,
                  msg: 'Chọn ít nhất một tháng để xác nhận thanh toán',
                  color: Colors.red,
                  icon: const Icon(Icons.warning),
                );
              }
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

  dynamic selectedValueTT = '2';
  List<dynamic> itemsTT = [
    {'name': 'Chờ tiến cử lại', 'value': '1'},
    {'name': 'Dừng xử lý tạm thời', 'value': '2'}
  ];

  dynamic selectedValueLD = '1';
  List<dynamic> itemsLD = [
    {'name': 'Do nghiệp đoàn', 'value': '0'},
    {'name': 'Do cá nhân', 'value': '1'},
    {'name': 'Khác', 'value': '2'}
  ];
  dynamic selectedMoneyBack = '0';
  String? er;
  double height = 80;
  String titleLog = 'Cập nhật dữ liệu thành công';
  updateDXL(row) async {
    var data2;
    var response1;
    var response2;
    if (selectedValueTT == '2') {
      row["stopProcessing"] = 1;
      response1 =
          await httpPut('/api/nguoidung/put/${row['id']}', row, context);
      data2 = {
        "ttsId": row['id'],
        "itemType": 0,
        "causeType": int.parse(selectedValueLD),
        "causeContent": detail.text,
        "approvalType": 0
      };
      response2 =
          await httpPost('/api/tts-donhang-dungxuly/post/save', data2, context);
    } else {
      row['orderId'] = 0;
      row["ttsStatusId"] = 14;
      response1 =
          await httpPut('/api/nguoidung/put/${row['id']}', row, context);
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
                  margin: EdgeInsets.only(right: 10),
                ),
                SelectableText(
                  widget.titleDialog,
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
        width: 650,
        height: 400,
        child: ListView(
          children: [
            Column(
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
                  height: 300,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
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
                                    isExpanded: true,
                                    items: [
                                      for (int i = 0; i < itemsTT.length; i++)
                                        DropdownMenuItem<String>(
                                          value: itemsTT[i]['value'],
                                          child: Text(
                                            itemsTT[i]['name'],
                                          ),
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
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                              flex: 3,
                              child: SelectableText(
                                'Lý do',
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
                                    isExpanded: true,
                                    items: [
                                      for (int i = 0; i < itemsLD.length; i++)
                                        DropdownMenuItem<String>(
                                          value: itemsLD[i]['value'],
                                          child: SelectableText(
                                            itemsLD[i]['name'],
                                          ),
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
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                              flex: 3,
                              child: SelectableText(
                                'Mô tả chi tiết',
                                style: titleWidgetBox,
                              )),
                          Expanded(
                              flex: 5,
                              child: Container(
                                height: height,
                                // width: MediaQuery.of(context).size.width * 0.15,
                                child: TextField(
                                  controller: detail,
                                  minLines: 4,
                                  maxLines: 4,
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
            if (detail.text.isEmpty) {
              showToast(
                context: context,
                msg: "Yêu cầu nhập rõ lý do dừng xử lý  ",
                color: Colors.red,
                icon: Icon(Icons.warning),
              );
            } else {
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

// Pop-up xác nhận thu tiên
class XacNhanManKhoa extends StatefulWidget {
  final String titleDialog;
  final List<dynamic> listIdSelected;
  final Function setState;
  const XacNhanManKhoa(
      {Key? key,
      required this.titleDialog,
      required this.listIdSelected,
      required this.setState})
      : super(key: key);

  @override
  State<XacNhanManKhoa> createState() => _XacNhanManKhoaState();
}

class _XacNhanManKhoaState extends State<XacNhanManKhoa> {
  var listTtsDt;
  getListTtsDt() async {
    var response = await httpGet('/api/tts-thongtindaotao/get/page', context);
    if (response.containsKey("body")) {
      listTtsDt = jsonDecode(response["body"])['content'];
    } else
      throw Exception("Error load data");
    return listTtsDt;
  }

  updateNMK() async {
    var data = {
      "courseCompletedDate": dateReverse(ngayManKhoa),
    };
    for (var row in widget.listIdSelected) {
      for (var ttsDt in listTtsDt)
        if (row['id'] == ttsDt['ttsId']) {
          var response = await httpPut(
              '/api/tts-thongtindaotao/put/${ttsDt["id"]}', data, context);
          int oldStatus = row['ttsStatusId'];
          row['ttsStatusId'] = 10;
          await httpPut('/api/nguoidung/put/${row['id']}', row, context);
          await httpPostDiariStatus(
              row['id'], oldStatus, 10, 'Xác nhận mãn khóa', context);
          if (response['body'] == 'true') {
            titleLog = 'Cập nhật dữ liệu thành công';
          } else {
            titleLog = 'Cập nhật thất bại';
          }
        }
      // titleLog = "Không có dữ liệu";
    }
  }

  @override
  void initState() {
    // getListTtsDt();
    super.initState();
  }

  String titleLog = 'Cập nhật dữ liệu thành công';
  String ngayManKhoa =
      DateFormat("dd-MM-yyyy").format(DateTime.now().toLocal());
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
                  margin: EdgeInsets.only(right: 10),
                ),
                SelectableText(
                  widget.titleDialog,
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
        width: 500,
        height: 300,
        child: ListView(
          children: [
            Column(
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
                  height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DatePickerBoxVQ(
                          label: SelectableText(
                            'Ngày tháng',
                            style: titleWidgetBox,
                          ),
                          isTime: false,
                          dateDisplay: ngayManKhoa,
                          flexLabel: 3,
                          selectedDateFunction: (day) {
                            ngayManKhoa = day;
                            setState(() {});
                          }),
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
            await getListTtsDt();
            await updateNMK();
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

class ListMonth extends StatefulWidget {
  final List<dynamic> listCheckBox;
  final Function function;
  const ListMonth(
      {Key? key, required this.listCheckBox, required this.function})
      : super(key: key);

  @override
  State<ListMonth> createState() => _ListMonthState();
}

class _ListMonthState extends State<ListMonth> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 25.0,
      spacing: 5.0,
      children: [
        for (var row in widget.listCheckBox)
          Container(
            width: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Checkbox(
                    checkColor: Colors.white,
                    value: row['value'],
                    onChanged: (value) {
                      setState(() {
                        row['value'] = value!;
                        widget.function(widget.listCheckBox);
                      });
                    },
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    row['title'],
                    style: TextStyle(
                      color: Color(0xff333333),
                      fontSize: 16,
                    ),
                  ),
                )
              ],
            ),
          ),
      ],
    );
  }
}
