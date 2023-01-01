import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/widgets_form.dart';
import 'package:gentelella_flutter/model/model.dart';
import 'package:intl/intl.dart';
import "package:collection/collection.dart";

import 'package:provider/provider.dart';
import '../../../../api.dart';
import '../../../../common/dynamic_table.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';
import '../../navigation.dart';

class ThemMoiLopHoc extends StatefulWidget {
  final String? id;
  const ThemMoiLopHoc({Key? key, this.id}) : super(key: key);

  @override
  State<ThemMoiLopHoc> createState() => _ThemMoiLopHocState();
}

class _ThemMoiLopHocState extends State<ThemMoiLopHoc> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
        widgetBody: ThemMoiLopHocBody(
      id: widget.id,
    ));
  }
}

class ThemMoiLopHocBody extends StatefulWidget {
  final String? id;
  const ThemMoiLopHocBody({Key? key, this.id}) : super(key: key);

  @override
  State<ThemMoiLopHocBody> createState() => _ThemMoiLopHocBodyState();
}

class _ThemMoiLopHocBodyState extends State<ThemMoiLopHocBody> {
  late Future<dynamic> getListTTSFuture;
  var listTtsTC;
  var listGVCN = [];
  var listDataCTDT = [];
  late int rowCount = 0;
  int currentPage = 1;
  int rowPerPage = 10;
  dynamic selectedValueGVCN;
  dynamic selectedValueCTDT;
  bool checkText = false;
  TextEditingController className = TextEditingController();
  TextEditingController description = TextEditingController();
  bool isEmpty = false;
  dynamic listItemsCTDT = [];
  dynamic listItemsGVCN = [];

  TextEditingController searchCTDT = TextEditingController();
  TextEditingController searchGVCN = TextEditingController();

  var listTts;
  late String titleLog;
  //Lấy ra danh sách thực tập sinh có trong lớp
  var dataTable = [];
  Future<dynamic> getListTTS() async {
    await getInfoLH();
    await getListGVCN();
    await getListCTDT();
    await getListTtsTtdt();
    var response = await httpGet(
        "/api/daotao-tts/get/page?filter=daotaoLopId:${widget.id} and nguoidung.ttsStatusId:9",
        context);
    if (response.containsKey("body")) {
      listTts = jsonDecode(response["body"])['content'];
      rowCount = jsonDecode(response["body"])['totalElements'];
      dataTable = [];
      for (var row in listTts) {
        row['nguoidung']['status'] = true;
        row['nguoidung']['daotaottsId'] = row['id'];
        dataTable.add(row['nguoidung']);
      }
      setState(() {});
    }
    return listTts;
  }

  var lophoc;
  //Lấy ra thông tin của lớp học
  getInfoLH() async {
    var response = await httpGet("/api/daotao-lop/get/${widget.id}", context);
    var data = {};
    if (response.containsKey("body")) {
      data = jsonDecode(response["body"]);
      lophoc = data;
      className.text = data['name'];
      description.text = data['description'];
      selectedValueGVCN = data['giaovienId'].toString();
      selectedValueCTDT = data['chuongtrinh']['id'].toString();
      return data;
    }
  }

  Future<dynamic> notId() async {
    await getListGVCN();
    await getListCTDT();
    return {};
  }

  //Lấy ra danh sách thực tập sinh tiến cử

  Future<dynamic> getListTtsTC() async {
    var response = await httpGet(
        "/api/donhang-tts-tiencu/get/page?filter=qcApproval:1 AND ptttApproval:1 ",
        context);
    if (response.containsKey("body")) {
      listTtsTC = jsonDecode(response["body"]);
      return listTtsTC;
    } else
      throw Exception("Error load data");
  }

  //Lấy ra thông tin đào tạo
  var listTtdt;
  getListTtsTtdt() async {
    var response = await httpGet("/api/tts-thongtindaotao/get/page", context);
    if (response.containsKey("body")) {
      listTtdt = jsonDecode(response["body"])['content'];
      return listTtdt;
    }
    return 0;
  }

  //Lấy ra danh sách giáo viên chủ nhiệm

  getListGVCN() async {
    var response = await httpGet(
        "/api/nguoidung/get/page?filter=isAam:1 AND departId:7", context);
    if (response.containsKey("body")) {
      setState(() {
        listGVCN = jsonDecode(response["body"])['content'];
        if (selectedValueGVCN == null) if (listGVCN.isNotEmpty)
          selectedValueGVCN = listGVCN[0]['id'].toString();
      });
    }
    listItemsGVCN = [];
    for (var row in listGVCN) {
      listItemsGVCN.add({
        'value': row['id'].toString(),
        'name': "${row['fullName']}",
        'code': row['userCode'] ?? ''
      });
    }
    print(listItemsGVCN);
    return 0;
  }

  //Lấy ra danh sách các chương trình đào tạo

  getListCTDT() async {
    var response = await httpGet("/api/daotao-chuongtrinh/get/page", context);
    if (response.containsKey("body")) {
      setState(() {
        listDataCTDT = jsonDecode(response["body"])['content'];
        if (selectedValueCTDT == null) if (listDataCTDT.isNotEmpty)
          selectedValueCTDT = listDataCTDT[0]['id'].toString();
      });
    }
    listItemsCTDT = [];
    for (var row in listDataCTDT) {
      listItemsCTDT.add({'value': row['id'].toString(), 'name': row['name']});
    }
    return 0;
  }

  bool isNumber(String string) {
    try {
      int.parse(string);
      return true;
    } catch (e) {
      return false;
    }
  }

  addLH(String daotaoChuongtrinhId, String name, String description,
      String giaovienId) async {
    var data = {
      "daotaoChuongtrinhId": int.parse(daotaoChuongtrinhId),
      "name": name,
      "description": description,
      "giaovienId": int.parse(giaovienId),
    };
    var response = await httpPost('/api/daotao-lop/post/save', data, context);
    if (isNumber(response['body'])) {
      titleLog = 'Thêm mới dữ liệu thành công';
      return response['body'];
    } else {
      titleLog = 'Thêm mới dữ liệu thất bại';
    }
    return 0;
  }

  updateLH(String daotaoChuongtrinhId, String name, String description,
      String giaovienId) async {
    lophoc["daotaoChuongtrinhId"] = int.parse(daotaoChuongtrinhId);
    lophoc["name"] = name;
    lophoc["description"] = description;
    lophoc["giaovienId"] = int.parse(giaovienId);
    var response =
        await httpPut('/api/daotao-lop/put/${widget.id}', lophoc, context);
    if (response['body'] == "true") {
      titleLog = 'Cập nhật dữ liệu thành công';
    } else {
      titleLog = 'Cập nhật thất bại';
    }

    return titleLog;
  }

  addTTS(row, idLh) async {
    var add = {
      "daotaoLopId": idLh,
      "ttsId": row['id'],
    };
    var responseAdd = await httpPost('/api/daotao-tts/post/save', add, context);
    if (row['ttsStatusId'] == 8) row['ttsStatusId'] = 9;
    row.remove('daotaoLopId');
    row.remove('status');
    row.remove('active');
    var responseUpdate =
        await httpPut('/api/nguoidung/put/${row['id']}', row, context);
    await httpPostDiariStatus(row['id'], 8, 9, 'Thêm mới vào lớp học', context);
    if (isNumber(responseAdd['body'])) {
      print("Thêm mới dữ liệu thành công: $responseAdd");
    } else {
      print('Thêm mới thất bại');
    }
    if (jsonDecode(responseUpdate["body"]).containsKey("1")) {
      print('Cập nhật dữ liệu thành công');
    } else {
      print('Sai ở đây nè');
    }
    return titleLog;
  }

  String getNgayNhapHoc(id) {
    for (var row in listTtdt ?? []) {
      if (row['ttsId'] == id) {
        return row['admissionDate'];
      }
    }
    return 'no data';
  }

  var newClass;

  submitForm() async {
    if (className.text != '' &&
        selectedValueCTDT != null &&
        selectedValueGVCN != null) {
      if (widget.id == null) {
        addLH(selectedValueCTDT, className.text, description.text,
                selectedValueGVCN)
            .then((data) async {
          if (data != 0) {
            var getClass = await httpGet("/api/daotao-lop/get/$data", context);
            if (getClass.containsKey("body")) {
              setState(() {
                newClass = jsonDecode(getClass["body"]);
              });
            }
            for (var row in dataTable) {
              if (row['daotaottsId'] == null && row['status'] == true) {
                await addTTS(row, data);
                await httpPost(
                    "/api/push/tags/user_code/${row['userCode']}",
                    {
                      "title": "Hệ thống thông báo",
                      "message":
                          "Bạn đã được thêm vào lớp học ${newClass['code']}-${newClass['name']}. Liên hệ nhân viên tuyển dụng để biết thêm chi tiết"
                    },
                    context);
              }
            }

            await httpPost(
                "/api/push/tags/depart_id/7",
                {
                  "title": "Hệ thống thông báo",
                  "message":
                      "Lớp học ${newClass['code']}-${newClass['name']} đã được tạo lúc ${DateFormat("hh:mm dd-MM-yyyy").format(DateTime.now())}"
                },
                context);
          }
          Provider.of<NavigationModel>(context, listen: false)
              .add(pageUrl: "/quan-ly-lop-hoc");
          showToast(
            context: context,
            msg: titleLog,
            color: titleLog == "Thêm mới dữ liệu thành công"
                ? Color.fromARGB(136, 72, 238, 67)
                : Colors.red,
            icon: titleLog == "Thêm mới dữ liệu thành công"
                ? Icon(Icons.done)
                : Icon(Icons.warning),
          );
        });
      } else {
        updateLH(selectedValueCTDT, className.text, description.text,
                selectedValueGVCN)
            .then((data) async {
          var getClass =
              await httpGet("/api/daotao-lop/get/${widget.id}", context);
          if (getClass.containsKey("body")) {
            setState(() {
              newClass = jsonDecode(getClass["body"]);
            });
          }
          for (var row in dataTable) {
            if (row['daotaottsId'] == null && row['status'] == true) {
              await addTTS(row, int.parse(widget.id!));
              await httpPost(
                  "/api/push/tags/user_code/${row['id']}",
                  {
                    "title": "Hệ thống thông báo",
                    "message":
                        "Bạn đã được thêm vào lớp học ${newClass['code']}-${newClass['name']}. Liên hệ nhân viên tuyển dụng để biết thêm chi tiết"
                  },
                  context);
            } else if (row['daotaottsId'] != null && row['status'] == false) {
              await deleteTTS(row['daotaottsId']);
              await removeTts(row);
            }
          }
          Provider.of<NavigationModel>(context, listen: false)
              .add(pageUrl: "/quan-ly-lop-hoc");
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
        });
      }
    } else {
      showToast(
        context: context,
        msg: "Hãy nhập đủ dữ liệu",
        color: Colors.red,
        icon: Icon(Icons.warning),
      );
    }
  }

  deleteTTS(id) async {
    var response = await httpDelete("/api/daotao-tts/del/$id", context);

    if (jsonDecode(response["body"]).containsKey("1")) {
      titleLog = 'Cập nhật dữ liệu thành công';
    } else {
      print('Xóa không thành công');
    }
    return response;
  }

  removeTts(row) async {
    if (row['ttsStatusId'] == 9) row['ttsStatusId'] = 8;
    row.remove('daotaoLopId');
    row.remove('status');
    var response =
        await httpPut('/api/nguoidung/put/${row['id']}', row, context);
    print(response);
    await httpPostDiariStatus(row['id'], 9, 8, 'Xóa khỏi lớp học', context);
  }

  @override
  void initState() {
    if (widget.id != null) {
      getListTTSFuture = getListTTS();
    } else {
      getListTTSFuture = notId();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var curentUser =
        Provider.of<SecurityModel>(context, listen: false).userLoginCurren;
    return FutureBuilder<dynamic>(
      future: userRule('/them-moi-lop-hoc', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return FutureBuilder<dynamic>(
            future: getListTTSFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                String request = '';

                rowCount = 0;

                for (int i = 0; i < dataTable.length; i++) {
                  if (dataTable[i]['status'] == true) {
                    request += dataTable[i]['id'].toString();
                    request += ',';
                    rowCount++;
                  }
                }
                String finalRequest = '';
                if (rowCount >= 1) {
                  for (int i = 0; i < request.length; i++) {
                    if (i < request.length - 1) finalRequest += request[i];
                  }
                }
                if (finalRequest == '') finalRequest = '0';
                var rowCountReal = dataTable.length;
                var firstRow = (currentPage - 1) * rowPerPage;
                var lastRow = currentPage * rowPerPage + 1;
                if (lastRow > rowCountReal) {
                  lastRow = rowCountReal;
                }
                var tableIndex = (currentPage - 1) * rowPerPage + 1;
                return ListView(
                  children: [
                    TitlePage(
                      listPreTitle: [
                        {'url': '/bang-thong-ke-nhanh', 'title': 'Dashboard'},
                        {'url': '/quan-ly-lop-hoc', 'title': 'Quản lý lớp học'}
                      ],
                      content: widget.id == null
                          ? "Thêm mới lớp học"
                          : "Cập nhật lớp học",
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
                              margin: EdgeInsets.only(top: 20),
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
                                    SelectableText(
                                      'Nhập thông tin ',
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
                                        flex: 4,
                                        child: TextFieldValidatedForm(
                                          label: 'Tên lớp',
                                          height: 40,
                                          type: 'SelectableText',
                                          controller: className,
                                          flexLable: 2,
                                          enter: () {
                                            submitForm();
                                          },
                                          requiredValue: 1,
                                        )),
                                    // Expanded(child: Container(), flex: 5),
                                    SizedBox(
                                      width: 150,
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: 40),
                                        child: DropdownBtnSearch(
                                          isAll: false,
                                          label: 'Giáo viên chủ nhiệm',
                                          listItems: listItemsGVCN,
                                          search: searchGVCN,
                                          isSearch: true,
                                          flexDropdown: 5,
                                          selectedValue: selectedValueGVCN,
                                          setSelected: (selected) {
                                            selectedValueGVCN = selected;
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 25,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        flex: 4,
                                        child: Row(
                                          children: [
                                            Expanded(
                                                flex: 2,
                                                child: SelectableText(
                                                  'Mô tả',
                                                  style: titleWidgetBox,
                                                )),
                                            Expanded(
                                              flex: 5,
                                              child: Container(
                                                // width: MediaQuery.of(context).size.width * 0.15,
                                                child: TextField(
                                                  controller: description,
                                                  minLines: 4,
                                                  maxLines: 4,
                                                  decoration: InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                  onSubmitted: (value) {
                                                    submitForm();
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        )),
                                    SizedBox(
                                      width: 150,
                                    ),

                                    // Expanded(flex: 5, child: Row()),
                                    Expanded(
                                      flex: 4,
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: 40),
                                        child: DropdownBtnSearch(
                                          isAll: false,
                                          label: 'Chương trình đào tạo',
                                          listItems: listItemsCTDT,
                                          search: searchCTDT,
                                          isSearch: true,
                                          flexDropdown: 5,
                                          selectedValue: selectedValueCTDT,
                                          setSelected: (selected) {
                                            selectedValueCTDT = selected;
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 25,
                                ),
                                curentUser['departId'] == 1 ||
                                        curentUser['departId'] == 2 ||
                                        (curentUser['departId'] == 7 &&
                                            curentUser['vaitro'] != null &&
                                            curentUser['vaitro']['level'] >= 2)
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          getRule(
                                                  listRule.data,
                                                  widget.id == null
                                                      ? Role.Them
                                                      : Role.Sua,
                                                  context)
                                              ? Container(
                                                  margin:
                                                      EdgeInsets.only(left: 20),
                                                  child: TextButton(
                                                    style: TextButton.styleFrom(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        vertical: 20.0,
                                                        horizontal: 10.0,
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
                                                                      20.0,
                                                                  letterSpacing:
                                                                      2.0),
                                                    ),
                                                    onPressed: () {
                                                      submitForm();
                                                    },
                                                    child: Row(
                                                      children: [
                                                        Text("Lưu",
                                                            style: textButton),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              : Container(),
                                        ],
                                      )
                                    : Container()
                              ]),
                            ),
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
                                    children: [
                                      Expanded(
                                          child: Container(
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                SelectableText(
                                                  'Danh sách học viên',
                                                  style: titleBox,
                                                ),
                                                Row(
                                                  children: [
                                                    getRule(
                                                                listRule.data,
                                                                Role.Them,
                                                                context) ||
                                                            getRule(
                                                                listRule.data,
                                                                Role.Sua,
                                                                context)
                                                        ? Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    left: 20),
                                                            child: TextButton(
                                                              style: TextButton
                                                                  .styleFrom(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                  vertical:
                                                                      20.0,
                                                                  horizontal:
                                                                      10.0,
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
                                                                            20.0,
                                                                        letterSpacing:
                                                                            2.0),
                                                              ),
                                                              onPressed: () {
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder: (BuildContext
                                                                          context) =>
                                                                      ThemMoiHocVien(
                                                                          request:
                                                                              finalRequest,
                                                                          setState:
                                                                              (listTtsAdd) {
                                                                            print('Zooo');
                                                                            for (var row
                                                                                in listTtsAdd) {
                                                                              row['daotaottsId'] = null;
                                                                              row['status'] = true;
                                                                              dataTable.add(row);
                                                                            }
                                                                            setState(() {});
                                                                          },
                                                                          titleDialog:
                                                                              'Danh sách TTS'),
                                                                );
                                                              },
                                                              child: Row(
                                                                children: [
                                                                  Text(
                                                                      'Thêm TTS',
                                                                      style:
                                                                          textButton),
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),
                                                  ],
                                                )
                                              ],
                                            ),
                                            //Đường line
                                            Container(
                                              margin:
                                                  marginTopBottomHorizontalLine,
                                              child: Divider(
                                                thickness: 1,
                                                color: ColorHorizontalLine,
                                              ),
                                            ),
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
                                                            label: Expanded(
                                                                child:
                                                                    SelectableText(
                                                          'STT',
                                                          style: titleTableData,
                                                          textAlign:
                                                              TextAlign.center,
                                                        ))),
                                                        DataColumn(
                                                            label: Expanded(
                                                                child:
                                                                    SelectableText(
                                                          'Mã đơn hàng',
                                                          style: titleTableData,
                                                          textAlign:
                                                              TextAlign.center,
                                                        ))),
                                                        DataColumn(
                                                            label: Expanded(
                                                                child:
                                                                    SelectableText(
                                                          'Tên đơn hàng',
                                                          style: titleTableData,
                                                          textAlign:
                                                              TextAlign.center,
                                                        ))),
                                                        DataColumn(
                                                            label: Expanded(
                                                                child:
                                                                    SelectableText(
                                                          'Mã TTS',
                                                          style: titleTableData,
                                                          textAlign:
                                                              TextAlign.center,
                                                        ))),
                                                        DataColumn(
                                                            label: Expanded(
                                                                child:
                                                                    SelectableText(
                                                          'Tên TTS',
                                                          style: titleTableData,
                                                          textAlign:
                                                              TextAlign.center,
                                                        ))),
                                                        DataColumn(
                                                            label: Expanded(
                                                                child:
                                                                    SelectableText(
                                                          'Ngày nhập học\n dự kiến',
                                                          style: titleTableData,
                                                          textAlign:
                                                              TextAlign.center,
                                                        ))),
                                                        DataColumn(
                                                            label: Expanded(
                                                                child:
                                                                    SelectableText(
                                                          'Ngày xuất cảnh\n dự kiến',
                                                          style: titleTableData,
                                                          textAlign:
                                                              TextAlign.center,
                                                        ))),
                                                        DataColumn(
                                                            label: Expanded(
                                                                child:
                                                                    SelectableText(
                                                          'Số điện thoại\n TTS',
                                                          style: titleTableData,
                                                          textAlign:
                                                              TextAlign.center,
                                                        ))),
                                                        DataColumn(
                                                            label: Expanded(
                                                                child:
                                                                    SelectableText(
                                                          'Xóa',
                                                          style: titleTableData,
                                                          textAlign:
                                                              TextAlign.center,
                                                        ))),
                                                      ],
                                                      rows: <DataRow>[
                                                        for (int i = firstRow;
                                                            i < lastRow;
                                                            i++)
                                                          if (dataTable[i]
                                                                  ['status'] ==
                                                              true)
                                                            DataRow(cells: [
                                                              DataCell(Center(
                                                                  child: SelectableText(
                                                                      "${tableIndex++}"))),
                                                              DataCell(Center(
                                                                  child: SelectableText(
                                                                      dataTable[i]['donhang'] !=
                                                                              null
                                                                          ? dataTable[i]['donhang']
                                                                              [
                                                                              'orderCode']
                                                                          : '',
                                                                      style:
                                                                          bangDuLieu))),
                                                              DataCell(Center(
                                                                  child: SelectableText(
                                                                      dataTable[i]['donhang'] !=
                                                                              null
                                                                          ? dataTable[i]['donhang']
                                                                              [
                                                                              'orderName']
                                                                          : '',
                                                                      style:
                                                                          bangDuLieu))),
                                                              DataCell(Center(
                                                                  child: SelectableText(
                                                                      dataTable[
                                                                              i]
                                                                          [
                                                                          'userCode'],
                                                                      style:
                                                                          bangDuLieu))),
                                                              DataCell(Center(
                                                                  child: SelectableText(
                                                                      dataTable[
                                                                              i]
                                                                          [
                                                                          'fullName'],
                                                                      style:
                                                                          bangDuLieu))),
                                                              DataCell(Center(
                                                                  child: SelectableText(
                                                                      dataTable[i]['donhang'] != null
                                                                          ? dataTable[i]['donhang']['estimatedAdmissionDate'] != null
                                                                              ? dateReverse(dataTable[i]['donhang']['estimatedAdmissionDate'])
                                                                              : ''
                                                                          : '',
                                                                      style: bangDuLieu))),

                                                              DataCell(Center(
                                                                  child: SelectableText(
                                                                      dataTable[i]['donhang'] != null
                                                                          ? dataTable[i]['donhang']['estimatedEntryDate'] != null
                                                                              ? dateReverse(dataTable[i]['donhang']['estimatedEntryDate'])
                                                                              : ''
                                                                          : '',
                                                                      style: bangDuLieu))),
                                                              DataCell(Center(
                                                                  child: SelectableText(
                                                                      dataTable[i]
                                                                              [
                                                                              'mobile'] ??
                                                                          '',
                                                                      style:
                                                                          bangDuLieu))),
                                                              DataCell(Center(
                                                                child:
                                                                    IconButton(
                                                                  color: Colors
                                                                      .red,
                                                                  onPressed:
                                                                      () async {
                                                                    showDialog(
                                                                      context:
                                                                          context,
                                                                      builder: (BuildContext
                                                                              context) =>
                                                                          XacNhanXoa(
                                                                        id: dataTable[i]['daotaottsId']
                                                                            .toString(),
                                                                        function:
                                                                            () {
                                                                          dataTable[i]['status'] =
                                                                              false;
                                                                          setState(
                                                                              () {});
                                                                          // getListTTSFuture =
                                                                          //     getListTTS(
                                                                          //         currentPageDef);
                                                                          // setState(() {});
                                                                        },
                                                                      ),
                                                                    );
                                                                  },
                                                                  icon: Icon(Icons
                                                                      .delete),
                                                                  iconSize: 30,
                                                                ),
                                                              )),
                                                              //
                                                            ])
                                                      ]),
                                                ),
                                              ],
                                            ),
                                            DynamicTablePagging(
                                                rowCount,
                                                currentPage,
                                                rowPerPage, pageChangeHandler:
                                                    (currentPageCallBack) {
                                              setState(() {
                                                currentPage =
                                                    currentPageCallBack;
                                              });
                                            }, rowPerPageChangeHandler:
                                                    (rowPerPageChange) {
                                              rowPerPage = rowPerPageChange;
                                              print(rowPerPage);
                                              setState(() {});
                                            }),
                                          ],
                                        ),
                                      )),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ]),
                    ),
                    Footer()
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

//Xác nhận xóa học viên
// ignore: must_be_immutable
class XacNhanXoa extends StatefulWidget {
  String id;
  Function function;
  XacNhanXoa({Key? key, required this.id, required this.function})
      : super(key: key);
  @override
  State<XacNhanXoa> createState() => _XacNhanXoaState();
}

class _XacNhanXoaState extends State<XacNhanXoa> {
  String titleLog = '';
  deleteTTS() async {
    var response =
        await httpDelete("/api/daotao-tts/del/${widget.id}", context);
    if (jsonDecode(response["body"]).containsKey("1")) {
      titleLog = 'Đã xóa thực tập sinh khỏi lớp học';
    } else {
      titleLog = 'Xóa không thành công';
    }
    return response;
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
                  'Xác nhận xóa thực tập sinh',
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
        height: 100,
        width: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(0),
              child: Divider(
                thickness: 1,
              ),
            ),
            SelectableText(
              'Bạn có chắc chắn muốn xóa thực tập sinh khỏi lớp!',
            ),
            Padding(
              padding: const EdgeInsets.all(0),
              child: Divider(
                thickness: 1,
              ),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          // textColor: Color(0xFF6200EE),
          onPressed: () => Navigator.pop(context),
          child: SelectableText('Hủy'),
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
            // await deleteTTS();
            // await removeTts();
            // widget.function();
            // showToast(
            //   context: context,
            //   msg: titleLog,
            //   color: titleLog == "Đã xóa thực tập sinh khỏi lớp học"
            //       ? Color.fromARGB(136, 72, 238, 67)
            //       : Colors.red,
            //   icon: titleLog == "Đã xóa thực tập sinh khỏi lớp học"
            //       ? Icon(Icons.done)
            //       : Icon(Icons.warning),
            // );
            widget.function();
            Navigator.pop(context);
          },
          child: SelectableText(
            'Đồng ý',
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

// Pop-up thêm mới học viên
class ThemMoiHocVien extends StatefulWidget {
  final String titleDialog;
  final Function setState;
  final String request;
  const ThemMoiHocVien(
      {Key? key,
      required this.titleDialog,
      required this.setState,
      required this.request})
      : super(key: key);

  @override
  State<ThemMoiHocVien> createState() => _ThemMoiHocVienState();
}

class _ThemMoiHocVienState extends State<ThemMoiHocVien> {
  TextEditingController name = TextEditingController();
  late int rowCount = 0;
  List<bool> listSelectedRow = [];
  List<dynamic> listIdSelected = [];
  var listTtsTc;
  bool btnActive = false;
  bool search = false;
  String requestName = '';
  String? birthDay;
  late Future<dynamic> getListTtsCDTFuture;
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
    print(paidFood);
    if (paidFood == null) {
      return false;
    } else {
      return true;
    }
  }

  var listTttt = {};
  var listTtsCtdFilter = [];
  bool load = false;
  getListTtsCDT(int currentPage) async {
    if (load == false) {
      await getTrangThaiDongTien();
      load = true;
    }

    // var formatterDate = DateFormat('dd-MM-yyyy');
    // String birthDayFormat = formatterDate.format(birthDay);
    String requestDay = '';
    if (birthDay != null) {
      requestDay = " and birthDate:'$birthDay'";
    }
    var response;
    response = await httpGet(
        "/api/nguoidung/get/page?filter=isTts:1 AND ttsStatusId:8 and stopProcessing:0 and (fullName~'*${name.text}*' or userCode~'*${name.text}*') $requestDay and not(id in (${widget.request}))",
        context);
    if (response.containsKey("body")) {
      rowCount = jsonDecode(response["body"])['totalElements'];
      listTtsTc = jsonDecode(response["body"])['content'];
      listTtsCtdFilter = [];

      for (var tts in listTtsTc) {
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
      for (var row in listTtsTc) {
        if (listTttt[row['id']] != null &&
            listTttt[row['id']]['paidTuition'] != 0 &&
            checkPaidFood(listTttt[row['id']]['paidFood'])) {
          listSelectedRow.add(false);
          row['active'] = true;
          listTtsCtdFilter.add(row);
        } else {
          listSelectedRow.add(false);
          row['active'] = false;
          listTtsCtdFilter.add(row);
        }
      }
      setState(() {});
      return listTtsTc;
    } else
      throw Exception("Error load data");
  }

  @override
  void initState() {
    getListTtsCDTFuture = getListTtsCDT(1);
    super.initState();
  }

  DateTime selectedDate = DateTime.now();
  int currentPage = 1;
  int rowPerPage = 10;
  var firstRow;
  var lastRow;
  @override
  Widget build(BuildContext context) {
    var curentUser =
        Provider.of<SecurityModel>(context, listen: false).userLoginCurren;
    return FutureBuilder<dynamic>(
      future: getListTtsCDTFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var tableIndex = (currentPage - 1) * rowPerPage + 1;
          rowCount = listTtsCtdFilter.length;
          firstRow = (currentPage - 1) * rowPerPage;
          lastRow = currentPage * rowPerPage - 1;
          if (lastRow > rowCount - 1) {
            lastRow = rowCount - 1;
          }
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
              width: 1300,
              height: 600,
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
                      Container(
                        child: Container(
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 7,
                                            child: TextFieldValidatedForm(
                                              label: 'Tên TTS',
                                              height: 40,
                                              type: 'None',
                                              flexLable: 2,
                                              controller: name,
                                              enter: () {
                                                getListTtsCDTFuture =
                                                    getListTtsCDT(1);
                                              },
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(),
                                            flex: 1,
                                          )
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 8,
                                            child: Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 30),
                                              child: DatePickerBoxVQ(
                                                  isTime: false,
                                                  label: SelectableText(
                                                    'Ngày sinh',
                                                    style: titleWidgetBox,
                                                  ),
                                                  dateDisplay: birthDay,
                                                  selectedDateFunction: (day) {
                                                    birthDay = day;
                                                    setState(() {});
                                                  }),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(),
                                            flex: 1,
                                          )
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(
                                                left: 20, bottom: 30),
                                            child: TextButton.icon(
                                              style: TextButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 20.0,
                                                  horizontal: 10.0,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                ),
                                                backgroundColor: Color.fromRGBO(
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
                                                getListTtsCDTFuture =
                                                    getListTtsCDT(1);
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
                                                  SelectableText('Tìm kiếm ',
                                                      style: textButton),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: DataTable(
                                          columnSpacing: 5,
                                          showCheckboxColumn: true,
                                          columns: [
                                            DataColumn(
                                                label: Expanded(
                                                    child: SelectableText(
                                              'STT',
                                              style: titleTableData,
                                              textAlign: TextAlign.center,
                                            ))),
                                            DataColumn(
                                                label: Expanded(
                                                    child: SelectableText(
                                              'Mã TTS',
                                              style: titleTableData,
                                              textAlign: TextAlign.center,
                                            ))),
                                            DataColumn(
                                                label: Expanded(
                                                    child: SelectableText(
                                              'Tên TTS',
                                              style: titleTableData,
                                              textAlign: TextAlign.center,
                                            ))),
                                            DataColumn(
                                                label: Expanded(
                                                    child: SelectableText(
                                              'Ngày tháng năm sinh',
                                              style: titleTableData,
                                              textAlign: TextAlign.center,
                                            ))),
                                          ],
                                          rows: <DataRow>[
                                            for (int i = firstRow;
                                                i <= lastRow;
                                                i++)
                                              DataRow(
                                                  selected: listSelectedRow[i],
                                                  onSelectChanged:
                                                      listTtsCtdFilter[i]
                                                                  ['active'] ==
                                                              true
                                                          ? (value) {
                                                              setState(() {
                                                                if (listIdSelected
                                                                    .contains(
                                                                        listTtsCtdFilter[
                                                                            i])) {
                                                                  listIdSelected
                                                                      .remove(
                                                                          listTtsCtdFilter[
                                                                              i]);
                                                                } else {
                                                                  listIdSelected.add(
                                                                      listTtsCtdFilter[
                                                                          i]);
                                                                }
                                                                listSelectedRow[
                                                                    i] = value!;
                                                                for (int i = 0;
                                                                    i <
                                                                        listSelectedRow
                                                                            .length;
                                                                    i++) {
                                                                  if (listSelectedRow[
                                                                          i] ==
                                                                      true) {
                                                                    btnActive =
                                                                        true;
                                                                    break;
                                                                  }
                                                                  btnActive =
                                                                      false;
                                                                }
                                                              });
                                                            }
                                                          : null,
                                                  cells: [
                                                    DataCell(Center(
                                                        child: SelectableText(
                                                            "${tableIndex++}"))),
                                                    DataCell(Row(
                                                      children: [
                                                        listTtsCtdFilter[i][
                                                                    'active'] ==
                                                                false
                                                            ? Tooltip(
                                                                message:
                                                                    'Thực tập sinh chưa đóng tiền ăn học',
                                                                child: Icon(
                                                                  Icons
                                                                      .warning_amber_rounded,
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                              )
                                                            : Container(),
                                                        Center(
                                                            child: SelectableText(
                                                                listTtsCtdFilter[
                                                                        i][
                                                                    'userCode'],
                                                                style:
                                                                    bangDuLieu)),
                                                      ],
                                                    )),
                                                    DataCell(Center(
                                                        child: SelectableText(
                                                            listTtsCtdFilter[i]
                                                                ['fullName'],
                                                            style:
                                                                bangDuLieu))),
                                                    DataCell(Center(
                                                        child: SelectableText(
                                                            listTtsCtdFilter[i][
                                                                        'birthDate'] !=
                                                                    null
                                                                ? dateReverse(
                                                                    listTtsCtdFilter[
                                                                            i][
                                                                        'birthDate'])
                                                                : 'no data',
                                                            style:
                                                                bangDuLieu))),
                                                    //
                                                  ])
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  DynamicTablePagging(
                                      rowCount, currentPage, rowPerPage,
                                      pageChangeHandler: (currentPageCallBack) {
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
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.only(left: 20, bottom: 20),
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 10.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    backgroundColor: Color.fromRGBO(245, 117, 29, 1),
                    primary: Theme.of(context).iconTheme.color,
                    textStyle: Theme.of(context)
                        .textTheme
                        .caption
                        ?.copyWith(fontSize: 20.0, letterSpacing: 2.0),
                  ),
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                  child: Text('Hủy', style: textButton),
                ),
              ),
              curentUser['departId'] == 1 ||
                      curentUser['departId'] == 2 ||
                      (curentUser['departId'] == 7 &&
                          curentUser['vaitro'] != null &&
                          curentUser['vaitro']['level'] >= 2)
                  ? Container(
                      margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 20.0,
                            horizontal: 10.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          backgroundColor: btnActive == true
                              ? Color.fromRGBO(245, 117, 29, 1)
                              : Colors.grey,
                          primary: Theme.of(context).iconTheme.color,
                          textStyle: Theme.of(context)
                              .textTheme
                              .caption
                              ?.copyWith(fontSize: 20.0, letterSpacing: 2.0),
                        ),
                        onPressed: btnActive == true
                            ? () async {
                                // for (int i = 0; i < listIdSelected.length; i++) {
                                //   await addTTS(listIdSelected[i].toString());
                                // }
                                // Navigator.pop(context);
                                // showToast(
                                //   context: context,
                                //   msg: titleLog,
                                //   color: titleLog == "Thêm mới dữ liệu thành công"
                                //       ? Color.fromARGB(136, 72, 238, 67)
                                //       : Colors.red,
                                //   icon: titleLog == "Thêm mới dữ liệu thành công"
                                //       ? Icon(Icons.done)
                                //       : Icon(Icons.warning),
                                // );
                                widget.setState(listIdSelected);
                                Navigator.pop(context);

                                setState(() {});
                              }
                            : null,
                        child: Text('Xác nhận', style: textButton),
                      ),
                    )
                  : Container(),
            ],
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
