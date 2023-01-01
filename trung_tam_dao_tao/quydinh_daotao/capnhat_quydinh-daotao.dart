import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../api.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/model.dart';
import '../../../forms/market_development/utils/funciton.dart';
import '../../navigation.dart';

class CapNhatQuyDinhDaoTao extends StatefulWidget {
  final String id;
  const CapNhatQuyDinhDaoTao({Key? key, required this.id}) : super(key: key);

  @override
  State<CapNhatQuyDinhDaoTao> createState() => _CapNhatQuyDinhDaoTaoState();
}

class _CapNhatQuyDinhDaoTaoState extends State<CapNhatQuyDinhDaoTao> {
  List<Map> dataRegulations = [];

  TextEditingController _ruleName = TextEditingController();
  TextEditingController times = TextEditingController();
  late QuyDinh1 selectedQD1;
  var ipQD;
  var resultQuyDinhDropDown = {};
  var listRemoveId = [];
  Map<int, String> ruleName = {0: ""};

  getQuyDinhDropDown() async {
    var response =
        await httpGet("/api/daotao-quydinh/get/page?sort=id", context);
    if (response.containsKey("body")) {
      setState(() {
        resultQuyDinhDropDown = jsonDecode(response["body"]);
        for (int i = 0; i < resultQuyDinhDropDown["content"].length; i++) {
          ruleName[resultQuyDinhDropDown["content"][i]["id"]] =
              resultQuyDinhDropDown["content"][i]["ruleName"] ?? "";
        }
      });
    }
  }

  int? selectedQD = 0;

  Future<List<QuyDinh1>> getQuyDinh1() async {
    //print("diep2");
    List<QuyDinh1> resultQuyDinh = [];
    var response1 =
        await httpGet("/api/daotao-quydinh/get/page?sort=id", context);
    var body = jsonDecode(response1['body']);
    var content = [];
    if (response1.containsKey("body")) {
      setState(() {
        content = body['content'];
        resultQuyDinh = content
            .map((e) {
              return QuyDinh1.fromJson(e);
            })
            .cast<QuyDinh1>()
            .toList();
      });
    }
    QuyDinh1 all = new QuyDinh1(id: 0, name: "");
    resultQuyDinh.insert(0, all);
    return resultQuyDinh;
  }

  deleteQuyDinhDaoTaoChiTiet() async {
    for (var i = 0; i < listRemoveId.length; i++) {
      await httpDelete(
          "/api/daotao-quydinh-chitiet/del/${listRemoveId[i]}", context);
    }
  }

  String? selectedDonHang;
  var ipVT;
  var resultVaiTroDropDown = {};
  String selectedVT = "";
  Map<int, String> name = {
    0: "TTS",
  };

  @override
  void initState() {
    //learnMap();
    getQuyDinhDropDown();
    super.initState();
    callApi();
  }

  callApi() async {
    await getData1();
    await getData();
    await getDataChiTiet();
  }

  var resultNextID;
  updateQuyDinh(String name) async {
    listQuyDinh1["name"] = name;
    listQuyDinh1["status"] =1;
    var response2 = await httpPut(
        "/api/daotao-quydinh/put/${widget.id}", listQuyDinh1, context);

    if (response2.containsKey("body")) {
      setState(() {
        resultNextID = jsonDecode(response2["body"]);
      });
    }
  }

  var listQuyDinh = [];
  var listItemsQd = [];
  getData() async {
    // int prID;
    var response =
        await httpGet("/api/daotao-quydinh/get/page?sort=id", context);
    if (response.containsKey("body")) {
      listQuyDinh = jsonDecode(response["body"])["content"];
      setState(() {
        listItemsQd = [];
        // _ruleName.text = listQuyDinh["name"];
        for (var row in listQuyDinh) {
          listItemsQd.add({
            'name': row['name'],
            'value': row['id'].toString(),
          });
        }
      });
    } else {
      selectedQD1 = new QuyDinh1(id: 0, name: "");
    }
    return listQuyDinh;
  }

  var listQuyDinh1 = {};
  getData1() async {
    // int prID;
    var response =
        await httpGet("/api/daotao-quydinh/get/${widget.id}", context);
    if (response.containsKey("body")) {
      listQuyDinh1 = jsonDecode(response["body"]);
      setState(() {
        _ruleName.text = listQuyDinh1["name"];
      });
    } else {
      selectedQD1 = new QuyDinh1(id: 0, name: "");
    }
    return listQuyDinh1;
  }

  var listQuyDinhChiTiet = [];
  getDataChiTiet() async {
    var response = await httpGet(
        "/api/daotao-quydinh-chitiet/get/page?filter=eduRuleId:${widget.id}",
        context);
    if (response.containsKey("body")) {
      listQuyDinhChiTiet.add(jsonDecode(response["body"]));
      for (var element in listQuyDinhChiTiet) {
        for (var element1 in element["content"]) {
          dataRegulations.add({
            "times": TextEditingController(text: element1['times'].toString()),
            "content": TextEditingController(text: element1['content']),
            "id": element1['id']
          });
        }
      }

      setState(() {});
    }
    return dataRegulations;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationModel>(
      builder: (context, navigationModel, child) => HeaderAndNavigation(
        widgetBody: Scaffold(
          body: ListView(
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
                padding: paddingTitledPage,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TitlePage(
                          listPreTitle: [
                            {
                              'url': "/bang-thong-ke-nhanh",
                              'title': 'Dashboard'
                            },
                            {
                              'url': "/quy-dinh-dao-tao",
                              'title': 'Thông tin các quy định'
                            },
                          ],
                          content: 'Thêm mới',
                        ),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SelectableText(
                              'Điền thông tin',
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

                        Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(30, 30, 30, 50),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(width: 50),
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: SelectableText.rich(TextSpan(
                                                text: 'Nội dung vi phạm',
                                                style: titleWidgetBox,
                                                children: <InlineSpan>[
                                                  TextSpan(
                                                    text: '*',
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  )
                                                ])),
                                          ),
                                          Expanded(
                                            flex: 6,
                                            child: Container(
                                              // height: 40,
                                              child: TextField(
                                                controller: _ruleName,
                                                onChanged: (value) {},
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      width: 3,
                                                      color: Colors.black,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0.0),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(flex: 2, child: Container()),
                                ],
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 1,
                              margin: EdgeInsets.only(top: 20),
                              decoration: BoxDecoration(
                                color: colorWhite,
                                borderRadius: borderRadiusContainer,
                                boxShadow: [boxShadowContainer],
                                border: borderAllContainerBox,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (int i = 0;
                                      i < dataRegulations.length;
                                      i++)
                                    Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              30, 50, 30, 0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 5,
                                                child: Container(
                                                  child: Row(
                                                    children: [
                                                      // Expanded(
                                                      //   flex: 2,
                                                      //   child: SelectableText('Số lần vi phạm', style: titleWidgetBox),
                                                      // ),
                                                      // Expanded(
                                                      //   flex: 6,
                                                      //   child: Container(
                                                      //     child: TextField(
                                                      //       controller:
                                                      //       onChanged: (_times) async {
                                                      //         if (_times.isEmpty)
                                                      //           dataRegulations[i]['times'] = 0;
                                                      //         else
                                                      //           dataRegulations[i]['times'] = _times;
                                                      //         print(dataRegulations[i]['times']);
                                                      //       },
                                                      //       decoration: InputDecoration(
                                                      //         border: OutlineInputBorder(
                                                      //           borderSide: BorderSide(
                                                      //             width: 3,
                                                      //             color: Colors.black,
                                                      //           ),
                                                      //           borderRadius: BorderRadius.circular(0.0),
                                                      //         ),
                                                      //       ),
                                                      //     ),
                                                      //   ),
                                                      // )
                                                      Expanded(
                                                        child:
                                                            TextFieldValidatedForm(
                                                          type: 'N',
                                                          label:
                                                              'Số lần vi phạm',
                                                          height: 40,
                                                          controller:
                                                              dataRegulations[i]
                                                                  ["times"],
                                                          flexLable: 1,
                                                          flexTextField: 3,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 50),
                                              Expanded(
                                                flex: 5,
                                                child: TextFieldValidatedForm(
                                                  type: 'SelectableText',
                                                  label: 'Nội dung phạt',
                                                  height: 40,
                                                  controller: dataRegulations[i]
                                                      ["content"],
                                                  flexLable: 1,
                                                  flexTextField: 3,
                                                ),
                                              ),
                                              // Expanded(flex: 1, child: Container()),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              30, 30, 30, 0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 5,
                                                child: Container(
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 2,
                                                        child: SelectableText
                                                            .rich(TextSpan(
                                                                text: '',
                                                                style:
                                                                    titleWidgetBox,
                                                                children: <
                                                                    InlineSpan>[
                                                              TextSpan(
                                                                text: '',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red),
                                                              )
                                                            ])),
                                                      ),
                                                      Expanded(
                                                        flex: 6,
                                                        child: Container(),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              if (i ==
                                                  dataRegulations.length - 1)
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          right: 20,
                                                          top: 10,
                                                          bottom: 10),
                                                      width: 50,
                                                      height: 40,
                                                      child: TextButton(
                                                        style: TextButton
                                                            .styleFrom(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5.0),
                                                          ),
                                                          backgroundColor:
                                                              Colors.grey[300],
                                                          primary:
                                                              Theme.of(context)
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
                                                        onPressed: () {
                                                          setState(() {
                                                            listRemoveId.add(
                                                                dataRegulations[
                                                                    i]['id']);
                                                            dataRegulations
                                                                .removeAt(i);
                                                          });
                                                        },
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: Center(
                                                                child:
                                                                    SelectableText(
                                                                  "-",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Color(
                                                                        0xff009C87),
                                                                    fontSize:
                                                                        26,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          right: 20,
                                                          top: 10,
                                                          bottom: 10),
                                                      width: 50,
                                                      height: 40,
                                                      child: TextButton(
                                                        style: TextButton
                                                            .styleFrom(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5.0),
                                                          ),
                                                          backgroundColor:
                                                              Color(0xff009C87),
                                                          primary:
                                                              Theme.of(context)
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
                                                        onPressed: () {
                                                          setState(() {
                                                            dataRegulations
                                                                .add({
                                                              "times":
                                                                  TextEditingController(),
                                                              "content":
                                                                  TextEditingController(),
                                                              "id": null
                                                            });
                                                          });
                                                        },
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                                child: Center(
                                                              child: SelectableText(
                                                                  "+",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          26,
                                                                      color: Colors
                                                                          .white)),
                                                            ))
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              else
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          right: 20,
                                                          top: 10,
                                                          bottom: 10),
                                                      width: 50,
                                                      height: 40,
                                                      child: TextButton(
                                                        style: TextButton
                                                            .styleFrom(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5.0),
                                                          ),
                                                          backgroundColor:
                                                              Colors.grey[300],
                                                          primary:
                                                              Theme.of(context)
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
                                                        onPressed: () {
                                                          setState(() {
                                                            listRemoveId.add(
                                                                dataRegulations[
                                                                    i]['id']);
                                                            dataRegulations
                                                                .removeAt(i);
                                                          });
                                                        },
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: Center(
                                                                child:
                                                                    SelectableText(
                                                                  "-",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Color(
                                                                        0xff009C87),
                                                                    fontSize:
                                                                        26,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              // Expanded(flex: 2, child: Container()),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            )
                          ],
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(50, 50, 20, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 20),
                                width: 100,
                                height: 40,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15.0,
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
                                            fontSize: 10.0, letterSpacing: 2.0),
                                  ),
                                  onPressed: () async {
                                    bool status = true;
                                    for (var row in dataRegulations) {
                                      if (!isNumber(row['times']!.text) ||
                                          int.parse(row['times']!.text) < 0) {
                                        status = false;
                                      }
                                      if (row['times']!.text.isEmpty) {
                                        status = true;
                                      }
                                      if (row['content']!.text.isEmpty) {
                                        status = false;
                                      }
                                    }

                                    if (selectedQD == null || selectedQD == 0)
                                      selectedQD = 0;
                                    if (_ruleName.text.isNotEmpty) {
                                      await updateQuyDinh(
                                          _ruleName.text);
                                      for (int i = 0;
                                          i < dataRegulations.length;
                                          i++) {
                                        if (dataRegulations[i]['times']!
                                            .text
                                            .isEmpty)
                                          dataRegulations[i]['times']!.text =
                                              '0';
                                        if (dataRegulations[i]['id'] == null) {
                                          var requestBody = {
                                            "eduRuleId": widget.id,
                                            "times": int.tryParse(
                                                dataRegulations[i]['times']!
                                                    .text),
                                            "content": dataRegulations[i]
                                                    ['content']!
                                                .text
                                          };
                                          await httpPost(
                                              "/api/daotao-quydinh-chitiet/post/save",
                                              requestBody,
                                              context);
                                        }

                                        var requestBody = {
                                          "eduRuleId": widget.id,
                                          "times":
                                              dataRegulations[i]['times'].text,
                                          "content":
                                              dataRegulations[i]['content'].text
                                        };
                                        await httpPut(
                                            "/api/daotao-quydinh-chitiet/put/${dataRegulations[i]['id']}",
                                            requestBody,
                                            context);
                                      }
                                      if (listRemoveId.isNotEmpty)
                                        await deleteQuyDinhDaoTaoChiTiet();
                                      navigationModel.add(
                                          pageUrl: "/quy-dinh-dao-tao");
                                      showToast(
                                        context: context,
                                        msg: "Cập nhật quy định thành công",
                                        color: Color.fromARGB(136, 72, 238, 67),
                                        icon: const Icon(Icons.done),
                                      );
                                    } else {
                                      showToast(
                                          context: context,
                                          msg: "Vui lòng nhập nội dung vi phạm",
                                          color: Colors.red,
                                          icon: const Icon(
                                            Icons.warning,
                                          ));
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: Center(
                                              child: Text("Lưu",
                                                  style: textButton)))
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 20),
                                width: 100,
                                height: 40,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15.0,
                                      horizontal: 10.0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    backgroundColor: Colors.grey[100],
                                    primary: Theme.of(context).iconTheme.color,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .caption
                                        ?.copyWith(
                                            fontSize: 10.0, letterSpacing: 2.0),
                                  ),
                                  onPressed: () {
                                    navigationModel.add(
                                        pageUrl: "/quy-dinh-dao-tao");
                                    showToast(
                                      context: context,
                                      msg: "Đã hủy thêm mới quy định",
                                      color: Color.fromARGB(135, 247, 217, 179),
                                      icon: const Icon(Icons.done),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            "Hủy",
                                            style: TextStyle(
                                              color: Color.fromRGBO(
                                                  245, 117, 29, 1),
                                              fontSize: 14,
                                              letterSpacing: 0.1,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
              Footer(),
            ],
          ),
        ),
      ),
    );
  }
}

class myButton extends StatefulWidget {
  final int i;
  final Map name;
  final List<Map> formData;
  myButton(
      {Key? key, required this.name, required this.formData, required this.i})
      : super(key: key);

  @override
  State<myButton> createState() => _myButtonState();
}

class _myButtonState extends State<myButton> {
  dynamic selectedVT = "";
  @override
  Widget build(BuildContext context) {
    return Container(
      child: DropdownButtonHideUnderline(
        child: DropdownButton2(
          isExpanded: true,
          dropdownMaxHeight: 250,
          buttonPadding: const EdgeInsets.only(left: 10),
          buttonDecoration: BoxDecoration(
              border: Border.all(width: 0.5, style: BorderStyle.solid)),
          hint: SelectableText(
            '${widget.name[0]}',
            style: sizeTextKhung,
          ),
          items: widget.name.entries
              .map((item) => DropdownMenuItem<String>(
                    value: item.key.toString(),
                    child: SelectableText(item.value, style: sizeTextKhung),
                  ))
              .toList(),
          value: selectedVT != "" ? selectedVT : null,
          onChanged: (dynamic value) {
            if (value == "0") {
              // if (widget.formData[widget.i].containsKey('dutyId')) widget.formData[widget.i].removeWhere((key, value) => key == 'dutyId');
              widget.formData[widget.i]['dutyId'] = null;
            } else
              widget.formData[widget.i]['dutyId'] = value;
            setState(() {
              selectedVT = value as dynamic;
              selectedVT = value;
            });
          },
          // buttonHeight: 40,
          //itemHeight: 40,
        ),
      ),
    );
  }
}

class QuyDinh {
  int? id;
  String? name;
  int? parentId;
  String? status;
  QuyDinh1? quydinh;
  QuyDinh({this.id, this.parentId, this.name, this.status, this.quydinh});
}

class QuyDinh1 {
  int id;
  String name;
  int? parentId;
  String? status;
  QuyDinh1({required this.id, this.parentId, required this.name, this.status});

  factory QuyDinh1.fromJson(Map<dynamic, dynamic> json) {
    return QuyDinh1(
      id: json['id'] ?? 0,
      name: json['name'] ?? "No data !",
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}
