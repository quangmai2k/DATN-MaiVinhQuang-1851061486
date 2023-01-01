import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/forms/market_development/utils/funciton.dart';
import 'package:provider/provider.dart';
import '../../../../api.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/model.dart';
import '../../navigation.dart';

class CapNhatDaoTaoXuPhat extends StatefulWidget {
  final String id;
  CapNhatDaoTaoXuPhat({Key? key, required this.id}) : super(key: key);

  @override
  State<CapNhatDaoTaoXuPhat> createState() => _CapNhatDaoTaoXuPhatState();
}

class _CapNhatDaoTaoXuPhatState extends State<CapNhatDaoTaoXuPhat> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
        widgetBody: CapNhatDaoTaoXuPhatBody(
      id: widget.id,
    ));
  }
}

class CapNhatDaoTaoXuPhatBody extends StatefulWidget {
  final String id;
  const CapNhatDaoTaoXuPhatBody({Key? key, required this.id}) : super(key: key);

  @override
  State<CapNhatDaoTaoXuPhatBody> createState() =>
      _CapNhatDaoTaoXuPhatBodyState();
}

class _CapNhatDaoTaoXuPhatBodyState extends State<CapNhatDaoTaoXuPhatBody> {
  TextEditingController title = TextEditingController();
  var file;
  var fileName;
  bool _isCheckTreatment = false;
  var listNvp;
  var daotaoxuphat;
  late Future<dynamic> getDaoTaoFuture;
  var listItemsTts = [];
  var listItemsQd = [];
  dynamic selectedValueTts = '-1';
  dynamic selectedValueQd = '-1';
  dynamic selectedValueQdFinal = '-1';

  var listQdxp = [];
  var fileInfo;
  getListNvp() async {
    listItemsTts = [];

    var listTts = await httpGet(
        "/api/nguoidung/get/page?filter=isTts:1 AND stopProcessing:0 and ttsStatusId:9",
        context);

    if (listTts.containsKey("body")) {
      setState(() {
        var data = jsonDecode(listTts["body"]);
        for (var row in data['content']) {
          listItemsTts.add({
            'value': row['id'].toString(),
            'name': row['fullName'],
            'code': row['userCode'],
          });
        }
      });
    }
    listItemsQd = [];
    var listQuyDinh =
        await httpGet("/api/daotao-quydinh-chitiet/get/page", context);
    if (listQuyDinh.containsKey("body")) {
      setState(() {
        var data = jsonDecode(listQuyDinh["body"])['content'];
        for (var row in data) {
          listItemsQd.add({
            'name': row['quydinh']['name'],
            'value': row['id'].toString(),
            'code':
                "${row['times'] != 0 ? 'Lần' : ''}${row['times'] != 0 ? ' ' : ''}${row['times'] != 0 ? row['times'] : ''}",
            'content': row['content']
          });
        }
      });
    }
    var daotao = await httpGet("/api/daotao-xuphat/get/${widget.id}", context);
    if (daotao.containsKey("body")) {
      setState(() {
        daotaoxuphat = jsonDecode(daotao["body"]);
        _isCheckTreatment = daotaoxuphat['treatment'] == 1 ? true : false;
        title.text = daotaoxuphat['title'];
      });
    }
    var response = await httpGet(
        "/api/daotao-xuphat-chitiet/get/page?sort=createdDate&filter=eduDecisionId:${widget.id}",
        context);
    if (response.containsKey("body")) {
      setState(() {
        listNvp = jsonDecode(response["body"])['content'];
        listQdxp = [];
        for (var row in listNvp) {
          listQdxp.add({
            'id': row['id'],
            'eduRuleId': setSelected(row['eduRuleId'], 'qd'),
            'ttsId': setSelected(row['ttsId'], 'tts'),
            'eduDecisionId': row['eduDecisionId'],
            'fines': TextEditingController(text: row['fines'].toString()),
            'content': TextEditingController(text: row['quydinh']['content']),
            'note': TextEditingController(text: row['note']),
            'violateDate': dateReverse(row['violateDate'])
          });
        }
      });
    }
    return 0;
  }

  setSelected(id, type) {
    dynamic selected;
    if (type == 'tts') {
      for (var row in listItemsTts) {
        if (row['value'] == id.toString())
          selected = "${row['name']} ${row['value']}";
      }
      if (selected == null) {
        selected =
            "${listItemsTts.first['name']} ${listItemsTts.first['value']}";
      }
    } else {
      for (var row in listItemsQd) {
        if (row['value'] == id.toString())
          selected = "${row['name']} ${row['value']}";
      }
      if (selected == null) {
        selected = "${listItemsQd.first['name']} ${listItemsQd.first['value']}";
      }
    }
    return selected;
  }

  String titleLog = '';
  submitForm() async {
    var listAdd = [];
    String titleSting = title.text;
    int treatment = _isCheckTreatment ? 1 : 0;
    daotaoxuphat['title'] = titleSting;
    daotaoxuphat['treatment'] = treatment;
    if (fileInfo == null) {
      var response = await httpPut(
          '/api/daotao-xuphat/put/${widget.id}', daotaoxuphat, context);
      print(response);
      if (response['body'] == "true") {
        titleLog = 'Cập nhật dữ liệu thành công';
      } else {
        titleLog = 'Cập nhật thất bại';
      }
    } else {
      await uploadFile(fileInfo, context: context).then((data) async {
        daotaoxuphat['relateFile'] = data;
        fileInfo = null;
        var response = await httpPut(
            '/api/daotao-xuphat/put/${widget.id}', daotaoxuphat, context);
        if (response['body'] == "true") {
          titleLog = 'Cập nhật dữ liệu thành công';
          setState(() {});
        } else {
          titleLog = 'Cập nhật thất bại';
        }
      });
    }
    await httpDelete(
        '/api/daotao-xuphat-chitiet/del/all?filter=eduDecisionId:${widget.id}',
        context);
    for (var row in listQdxp) {
      listAdd.add({
        'eduRuleId': int.parse(selectedValue(row['eduRuleId'], listItemsQd)),
        'ttsId': int.parse(selectedValue(row['ttsId'], listItemsTts)),
        'eduDecisionId': int.parse(widget.id),
        'fines':
            isNumber(row['fines'].text) ? int.parse(row['fines'].text) : null,
        'note': row['note'].text,
        'violateDate': dateReverse(row['violateDate'])
      });
    }
    var add = await httpPost(
        '/api/daotao-xuphat-chitiet/post/saveAll', listAdd, context);
    if (add['body'] == "true") {
      titleLog = 'Cập nhật dữ liệu thành công';
      setState(() {});
    } else {
      titleLog = 'Cập nhật thất bại';
    }
    getDaoTaoFuture = getListNvp();

    Provider.of<NavigationModel>(context, listen: false)
        .add(pageUrl: "/quyet-dinh-xu-phat-dao-tao");
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

  selectedValue(selected, listItems) {
    for (var row in listItems) {
      if ("${row['name']} ${row['value']}" == selected) {
        return row['value'];
      }
    }
  }

  selectedContent(selected, listItems) {
    for (var row in listItems) {
      if ("${row['name']} ${row['value']}" == selected) {
        return row['content'];
      }
    }
  }

  TextEditingController searchNdp = TextEditingController();
  int index = 0;
  @override
  void initState() {
    getDaoTaoFuture = getListNvp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var curentUser =
        Provider.of<SecurityModel>(context, listen: false).userLoginCurren;
    return ListView(
      controller: ScrollController(),
      children: [
        TitlePage(
          listPreTitle: [
            {'url': "/bang-thong-ke-nhanh", 'title': 'Dashboard'}
          ],
          content: 'Cập nhật',
        ),
        FutureBuilder<dynamic>(
          future: getDaoTaoFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: colorWhite,
                        borderRadius: borderRadiusContainer,
                        boxShadow: [boxShadowContainer],
                        border: borderAllContainerBox,
                      ),
                      padding: paddingBoxContainer,
                      margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                      child: Column(children: [
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
                        Container(
                          margin: marginTopBottomHorizontalLine,
                          child: Divider(
                            thickness: 1,
                            color: ColorHorizontalLine,
                          ),
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(width: 20),
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    child: TextFieldValidatedForm(
                                      type: 'Text',
                                      height: 40,
                                      controller: title,
                                      label: 'Tiêu đề: ',
                                      flexLable: 1,
                                      flexTextField: 3,
                                    ),
                                  ),
                                ),
                                Expanded(flex: 1, child: Container()),
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 30),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 2,
                                            child: SelectableText(
                                                "Thông tin liên quan: ",
                                                style: titleWidgetBox)),
                                        Expanded(
                                            flex: 3,
                                            child: TextButton(
                                                onPressed: () async {
                                                  fileInfo = await FilePicker
                                                      .platform
                                                      .pickFiles(
                                                    type: FileType.custom,
                                                    allowedExtensions: [
                                                      'pdf',
                                                      'docx',
                                                      'jpeg',
                                                      'png',
                                                      'jpg'
                                                    ],
                                                    withReadStream: true, //
                                                  );

                                                  setState(() {});
                                                },
                                                child: Text(fileInfo ==
                                                        null
                                                    ? '${daotaoxuphat['relateFile']}'
                                                    : fileInfo
                                                        .files.first.name)))
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(flex: 3, child: Container())
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 20),
                              child: Row(
                                children: [
                                  SizedBox(width: 20),
                                  Expanded(
                                    flex: 4,
                                    child: Row(
                                      children: [
                                        Checkbox(
                                            value: _isCheckTreatment,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                _isCheckTreatment =
                                                    !_isCheckTreatment;
                                              });
                                            }),
                                        SelectableText(
                                          "Phạt tài chính",
                                          style: titleBox,
                                        )
                                      ],
                                    ),
                                  ),
                                  Expanded(flex: 1, child: Container()),
                                  Expanded(flex: 7, child: Container())
                                ],
                              ),
                            ),
                            for (var row in listQdxp)
                              Container(
                                margin: EdgeInsets.only(top: 15, bottom: 10),
                                padding: EdgeInsets.only(left: 20, right: 20),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 250, 250, 250),
                                  borderRadius: borderRadiusContainer,
                                  boxShadow: [boxShadowContainer],
                                  border: borderAllContainerBox,
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 25,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: SelectableText.rich(
                                                    TextSpan(
                                                        text: 'TTS',
                                                        style: titleWidgetBox,
                                                        children: <InlineSpan>[
                                                      TextSpan(
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      )
                                                    ])),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                      flex: 5,
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.25,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                        ),
                                                        height: 40,
                                                        child:
                                                            DropdownButtonHideUnderline(
                                                          child:
                                                              DropdownButton2(
                                                            hint: Text(
                                                                "Chọn thông tin"),
                                                            searchController:
                                                                searchNdp,
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
                                                                    searchNdp,
                                                                decoration:
                                                                    InputDecoration(
                                                                        // icon: Icon(Icons.search),
                                                                        prefixIcon: Padding(
                                                                            padding: EdgeInsets.all(
                                                                                5),
                                                                            child: Icon(Icons
                                                                                .search)),
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
                                                                searchNdp
                                                                    .clear();
                                                              }
                                                            },
                                                            isExpanded: true,
                                                            items: [
                                                              for (var row
                                                                  in listItemsTts)
                                                                DropdownMenuItem<
                                                                    String>(
                                                                  value:
                                                                      "${row['name']} ${row['value']}",
                                                                  child:
                                                                      Text(
                                                                    "${row['name']} ${row['code'] != null ? '(' : ''}${row['code'] ?? ''}${row['code'] != null ? ')' : ''}",
                                                                  ),
                                                                )
                                                            ],
                                                            value: row['ttsId'],
                                                            onChanged: (value) {
                                                              setState(() {
                                                                row['ttsId'] =
                                                                    value;
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
                                                                    width: 1,
                                                                    color: Colors
                                                                        .black)),
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
                                                            dropdownMaxHeight:
                                                                300,
                                                          ),
                                                        ),
                                                      )),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(flex: 1, child: Container()),
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SelectableText(
                                                  "Ngày vi phạm",
                                                  style: titleWidgetBox,
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                DatePickerBoxVQ(
                                                    isTime: false,
                                                    dateDisplay:
                                                        row['violateDate'],
                                                    selectedDateFunction:
                                                        (day) {
                                                      row['violateDate'] = day;
                                                      setState(() {});
                                                    }),
                                              ]),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  child: SelectableText.rich(
                                                      TextSpan(
                                                          text: 'Nội dung phạt',
                                                          style: titleWidgetBox,
                                                          children: <
                                                              InlineSpan>[
                                                        TextSpan(
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red),
                                                        )
                                                      ])),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                        flex: 5,
                                                        child: Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.25,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                          ),
                                                          height: 40,
                                                          child:
                                                              DropdownButtonHideUnderline(
                                                            child:
                                                                DropdownButton2(
                                                              hint: Text(
                                                                  "Chọn thông tin"),
                                                              searchController:
                                                                  searchNdp,
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
                                                                      searchNdp,
                                                                  decoration: InputDecoration(
                                                                      // icon: Icon(Icons.search),
                                                                      prefixIcon: Padding(padding: EdgeInsets.all(5), child: Icon(Icons.search)),
                                                                      isDense: true,
                                                                      contentPadding: const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            10,
                                                                        vertical:
                                                                            15,
                                                                      ),
                                                                      hintText: 'Tìm kiếm',
                                                                      hintStyle: const TextStyle(fontSize: 14),
                                                                      border: InputBorder.none),
                                                                ),
                                                              ),
                                                              searchMatchFn: (item,
                                                                  searchValue) {
                                                                return (item
                                                                    .value
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
                                                                  searchNdp
                                                                      .clear();
                                                                }
                                                              },
                                                              isExpanded: true,
                                                              items: [
                                                                for (var row
                                                                    in listItemsQd)
                                                                  DropdownMenuItem<
                                                                      String>(
                                                                    value:
                                                                        "${row['name']} ${row['value']}",
                                                                    child:
                                                                        Text(
                                                                      "${row['name']} ${row['code'].isNotEmpty ? '(' : ''}${row['code'].isNotEmpty ? row['code'] : ''}${row['code'].isNotEmpty ? ')' : ''}",
                                                                    ),
                                                                  )
                                                              ],
                                                              value: row[
                                                                  'eduRuleId'],
                                                              onChanged:
                                                                  (value) {
                                                                setState(() {
                                                                  row['eduRuleId'] =
                                                                      value;
                                                                  row['content']
                                                                          .text =
                                                                      selectedContent(
                                                                          row['eduRuleId'],
                                                                          listItemsQd);
                                                                });
                                                              },
                                                              dropdownDecoration: BoxDecoration(
                                                                  border: Border.all(
                                                                      color: const Color
                                                                              .fromRGBO(
                                                                          216,
                                                                          218,
                                                                          229,
                                                                          1))),
                                                              buttonDecoration:
                                                                  BoxDecoration(
                                                                      border: Border.all(
                                                                          width:
                                                                              1,
                                                                          color:
                                                                              Colors.black)),
                                                              buttonElevation:
                                                                  0,
                                                              buttonPadding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 14,
                                                                      right:
                                                                          14),
                                                              itemPadding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 14,
                                                                      right:
                                                                          14),
                                                              dropdownElevation:
                                                                  5,
                                                              focusColor:
                                                                  Colors.white,
                                                              dropdownMaxHeight:
                                                                  300,
                                                            ),
                                                          ),
                                                        )),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(flex: 1, child: Container()),
                                          Expanded(
                                            flex: 3,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.fromLTRB(
                                                      0, 30, 0, 0),
                                                  child: SelectableText.rich(
                                                      TextSpan(
                                                          text:
                                                              'Hình thức xử phạt',
                                                          style: titleWidgetBox,
                                                          children: <
                                                              InlineSpan>[
                                                        TextSpan(
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red),
                                                        )
                                                      ])),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                TextFieldValidatedForm(
                                                  enabled: false,
                                                  height: 40,
                                                  type: 'Text',
                                                  controller: row['content'],
                                                  flexLable: 2,
                                                  flexTextField: 5,
                                                  enter: () {},
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                margin: EdgeInsets.fromLTRB(
                                                    0, 30, 0, 0),
                                                child: SelectableText.rich(
                                                    TextSpan(
                                                        text: 'Ghi chú',
                                                        style: titleWidgetBox,
                                                        children: <InlineSpan>[
                                                      TextSpan(
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      )
                                                    ])),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              TextFieldValidatedForm(
                                                height: 40,
                                                type: 'Text',
                                                controller: row['note'],
                                                flexLable: 2,
                                                flexTextField: 5,
                                                enter: () {},
                                              )
                                            ],
                                          ),
                                        ),
                                        Expanded(flex: 1, child: Container()),
                                        Expanded(
                                            flex: 3,
                                            child: _isCheckTreatment
                                                ? Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                            top: 20),
                                                        child: SelectableText
                                                            .rich(TextSpan(
                                                                text:
                                                                    'Mức tiền phạt',
                                                                style:
                                                                    titleWidgetBox,
                                                                children: <
                                                                    InlineSpan>[
                                                              TextSpan(
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red),
                                                              )
                                                            ])),
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      TextFieldValidatedForm(
                                                        height: 40,
                                                        type: 'None',
                                                        controller:
                                                            row['fines'],
                                                        flexLable: 2,
                                                        flexTextField: 5,
                                                        enter: () {},
                                                      )
                                                    ],
                                                  )
                                                : Container()),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        listQdxp.length > 1
                                            ? Container(
                                                margin: EdgeInsets.only(
                                                    right: 20,
                                                    top: 10,
                                                    bottom: 10),
                                                width: 50,
                                                height: 40,
                                                child: TextButton(
                                                  style: TextButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.0),
                                                    ),
                                                    backgroundColor:
                                                        Colors.grey[300],
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
                                                    listQdxp.remove(row);
                                                    setState(() {});
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Center(
                                                          child: Text(
                                                            "-",
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xff009C87),
                                                              fontSize: 26,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                        listQdxp.last == row
                                            ? Container(
                                                margin: EdgeInsets.only(
                                                    right: 20,
                                                    top: 10,
                                                    bottom: 10),
                                                width: 50,
                                                height: 40,
                                                child: TextButton(
                                                  style: TextButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.0),
                                                    ),
                                                    backgroundColor:
                                                        Color(0xff009C87),
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
                                                    listQdxp.add({
                                                      'id': index--,
                                                      'eduRuleId':
                                                          setSelected(0, 'qd'),
                                                      'ttsId':
                                                          setSelected(0, 'tts'),
                                                      'eduDecisionId':
                                                          int.parse(widget.id),
                                                      'fines':
                                                          TextEditingController(),
                                                      'note':
                                                          TextEditingController(),
                                                      'violateDate': null
                                                    });
                                                    setState(() {});
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                          child: Center(
                                                        child: Text("+",
                                                            style: TextStyle(
                                                                fontSize: 26,
                                                                color: Colors
                                                                    .white)),
                                                      ))
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                          ],
                        ),
                        SizedBox(
                          height: 35,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 20),
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20.0,
                                      horizontal: 10.0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    backgroundColor:
                                        Color.fromRGBO(245, 117, 29, 1),
                                    primary: Theme.of(context).iconTheme.color,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .caption
                                        ?.copyWith(
                                            fontSize: 20.0, letterSpacing: 2.0),
                                  ),
                                  onPressed: () {
                                    Provider.of<NavigationModel>(context,
                                            listen: false)
                                        .add(
                                            pageUrl:
                                                "/quyet-dinh-xu-phat-dao-tao");
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
                                      margin: EdgeInsets.only(left: 20),
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
                                                  fontSize: 20.0,
                                                  letterSpacing: 2.0),
                                        ),
                                        onPressed: () async {
                                          bool validate = true;
                                          bool isNumber(String string) {
                                            try {
                                              int.parse(string);
                                              return true;
                                            } catch (e) {
                                              return false;
                                            }
                                          }

                                          for (var row in listQdxp) {
                                            if (row['violateDate'] == null ||
                                                row['note'].text.isEmpty) {
                                              validate = false;
                                              break;
                                            }
                                            if (_isCheckTreatment == true &&
                                                (row['fines'].text.isEmpty ||
                                                    !isNumber(
                                                        row['fines'].text))) {
                                              validate = false;
                                            }
                                          }
                                          if (title.text.isEmpty) {
                                            validate = false;
                                          }
                                          if (validate)
                                            submitForm();
                                          else {
                                            showToast(
                                              context: context,
                                              msg: "Hãy nhập đủ dữ liệu",
                                              color: Colors.red,
                                              icon: Icon(Icons.warning),
                                            );
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            Text('Lưu', style: textButton),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container()
                            ]),
                      ]),
                    ),
                  ],
                ),
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
