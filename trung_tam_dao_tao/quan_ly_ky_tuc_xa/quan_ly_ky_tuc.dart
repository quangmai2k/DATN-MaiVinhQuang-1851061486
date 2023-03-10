import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/widgets_form.dart';
import 'package:provider/provider.dart';
import '../../../../api.dart';
import '../../../../common/dynamic_table.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';
import '../../../../model/model.dart';
import '../../navigation.dart';

class QuanLyKyTuc extends StatefulWidget {
  const QuanLyKyTuc({Key? key}) : super(key: key);

  @override
  State<QuanLyKyTuc> createState() => _QuanLyKyTucState();
}

class _QuanLyKyTucState extends State<QuanLyKyTuc> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
      widgetBody: QuanLyKyTucBody(),
    );
  }
}

class QuanLyKyTucBody extends StatefulWidget {
  const QuanLyKyTucBody({Key? key}) : super(key: key);

  @override
  State<QuanLyKyTucBody> createState() => _QuanLyKyTucBodyState();
}

class _QuanLyKyTucBodyState extends State<QuanLyKyTucBody> {
  var listItems;
  String? request;
  late Future<dynamic> getListGVCNFuture;
  dynamic selectedValue = '-1';
  late int rowCount = 0;
  int currentPageDef = 1;
  int rowPerPage = 10;
  var kyTucXa = {};
  var gvcn;
  late Future<dynamic> getListKtxFuture;
  Map<int, int> listCount = {};
  dynamic listItemsGVCN = [];
  TextEditingController capacity = TextEditingController();
  TextEditingController name = TextEditingController();

  var listTtsInRoom;
  getCountTts() async {
    var response = await httpGet("/api/kytucxa-chitiet/get/page", context);
    if (response.containsKey("body")) {
      setState(() {
        listTtsInRoom = jsonDecode(response["body"]);
      });
    }
    return listTtsInRoom;
  }

  bool isNumber(String string) {
    try {
      int.parse(string);
      return true;
    } catch (e) {
      return false;
    }
  }

  getListKtx(int currentPage) async {
    var response;
    await getCountTts();
    String query = '';
    if (selectedGender != '-1') {
      query = " and gender:$selectedGender";
    }
    if (capacity.text.isNotEmpty && isNumber(capacity.text)) {
      query += ' and capacity:${capacity.text}';
    }
    response = await httpGet(
        "/api/kytucxa/get/page?size=$rowPerPage&page=${currentPage - 1}&filter=name~'*${name.text}*'$query",
        context);
    if (response.containsKey("body")) {
      kyTucXa = jsonDecode(response["body"]);
      if (kyTucXa['totalElements'] != null) rowCount = kyTucXa['totalElements'];

      setState(() {});
      return kyTucXa;
    } else
      throw Exception('False to load data');
  }

  String selectedGender = '-1';
  List<dynamic> itemsGender = [
    {'name': 'N???', 'value': '0'},
    {'name': 'Nam', 'value': '1'},
  ];

  TextEditingController textSearch = TextEditingController();
  @override
  void initState() {
    getListKtxFuture = getListKtx(1);
  }

  GlobalKey _globalKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: userRule('/quan-ly-ky-tuc-xa', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          var curentUser = Provider.of<SecurityModel>(context, listen: false)
              .userLoginCurren;
          bool ruleManager = curentUser['departId'] == 1 ||
              curentUser['departId'] == 2 ||
              (curentUser['departId'] == 7 &&
                  curentUser['vaitro'] != null &&
                  curentUser['vaitro']['level'] >= 2);

          return ListView(
            children: [
              TitlePage(
                listPreTitle: [
                  {'url': '/bang-thong-ke-nhanh', 'title': 'Dashboard'},
                ],
                content: 'Qu???n l?? ph??ng k?? t??c x??',
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
                                    'Nh???p th??ng tin t??m ki???m',
                                    style: titleBox,
                                  ),
                                  Icon(
                                    Icons.more_horiz,
                                    color: Color(0xff9aa5ce),
                                    size: 14,
                                  ),
                                ],
                              ),
                              //???????ng line
                              Container(
                                margin: marginTopBottomHorizontalLine,
                                child: Divider(
                                  thickness: 1,
                                  color: ColorHorizontalLine,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      flex: 10,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 7,
                                            child: TextFieldValidatedForm(
                                                type: 'None',
                                                label: 'M?? ph??ng',
                                                height: 40,
                                                controller: name,
                                                enter: () {
                                                  getListKtxFuture =
                                                      getListKtx(1);
                                                }),
                                          ),
                                        ],
                                      )),
                                  SizedBox(
                                    width: 100,
                                  ),
                                  Expanded(
                                    flex: 6,
                                    child: Container(
                                      margin: EdgeInsets.only(bottom: 40),
                                      child: DropdownBtnSearch(
                                        isAll: true,
                                        label: 'Gi???i t??nh',
                                        listItems: itemsGender,
                                        isSearch: false,
                                        selectedValue: selectedGender,
                                        setSelected: (selected) {
                                          selectedGender = selected;
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      margin: EdgeInsets.only(bottom: 40),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            getRule(listRule.data, Role.Xem,
                                                    context)
                                                ? Container(
                                                    margin: EdgeInsets.only(
                                                        left: 20),
                                                    child: TextButton.icon(
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
                                                            Color.fromRGBO(245,
                                                                117, 29, 1),
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
                                                      onPressed: () {
                                                        getListKtxFuture =
                                                            getListKtx(1);
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
                                                          Text('T??m ki???m ',
                                                              style:
                                                                  textButton),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : Container(),
                                            ruleManager
                                                ? getRule(listRule.data,
                                                        Role.Them, context)
                                                    ? Container(
                                                        margin: EdgeInsets.only(
                                                            left: 20),
                                                        child: TextButton.icon(
                                                          style: TextButton
                                                              .styleFrom(
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
                                                                Color.fromRGBO(
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
                                                            Provider.of<NavigationModel>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .add(
                                                                    pageUrl:
                                                                        "/them-moi-chinh-sua-ky-tuc");
                                                          },
                                                          icon: Icon(
                                                            Icons.add,
                                                            color: Colors.white,
                                                            size: 15,
                                                          ),
                                                          label: Row(
                                                            children: [
                                                              Text('Th??m m???i',
                                                                  style:
                                                                      textButton),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    : Container()
                                                : Container(),
                                          ]),
                                    ),
                                    flex: 8,
                                  )
                                ],
                              ),

                              Row(
                                children: [
                                  Expanded(
                                      flex: 10,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 7,
                                            child: TextFieldValidatedForm(
                                                type: 'Number',
                                                label: 'S??? ng?????i t???i da',
                                                height: 40,
                                                controller: capacity,
                                                enter: () {
                                                  getListKtxFuture =
                                                      getListKtx(1);
                                                }),
                                          ),
                                        ],
                                      )),
                                  SizedBox(
                                    width: 100,
                                  ),
                                  Expanded(flex: 14, child: Container())
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ]),
              ),
              Container(
                key: _globalKey,
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SelectableText(
                            'Danh s??ch ph??ng k?? t??c',
                            style: titleBox,
                          ),
                          Icon(
                            Icons.more_horiz,
                            color: colorIconTitleBox,
                            size: 14,
                          ),
                        ],
                      ),
                      //???????ng line
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
                              child: FutureBuilder<dynamic>(
                            future: getListKtxFuture,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                int countTts(id) {
                                  int count = 0;
                                  for (var row
                                      in listTtsInRoom['content'] ?? []) {
                                    if (row['dormId'] == id &&
                                        row['status'] == 1) {
                                      count++;
                                    }
                                  }
                                  return count;
                                }

                                var tableIndex =
                                    (currentPageDef - 1) * rowPerPage + 1;
                                return Column(
                                  children: [
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
                                              columns: [
                                                DataColumn(
                                                    label: SelectableText('STT',
                                                        style: titleTableData)),
                                                DataColumn(
                                                    label: SelectableText(
                                                        'T??n ph??ng',
                                                        style: titleTableData)),
                                                DataColumn(
                                                    label: SelectableText(
                                                        'Gi???i t??nh',
                                                        style: titleTableData)),
                                                DataColumn(
                                                    label: SelectableText(
                                                        'S??? l?????ng ng?????i ??ang ???',
                                                        style: titleTableData)),
                                                DataColumn(
                                                    label: SelectableText(
                                                        'S??? ng?????i t???i ??a',
                                                        style: titleTableData)),
                                                DataColumn(
                                                    label: SelectableText(
                                                        'H??nh ?????ng',
                                                        style: titleTableData)),
                                                DataColumn(
                                                    label: SelectableText(
                                                        'Th??m ng?????i',
                                                        style: titleTableData)),
                                                DataColumn(
                                                    label: SelectableText(
                                                        'X??c nh???n ho??n th??nh',
                                                        style: titleTableData)),
                                              ],
                                              rows: [
                                                for (var row
                                                    in kyTucXa['content'])
                                                  DataRow(
                                                      // onLongPress: () {
                                                      //   Provider.of<NavigationModel>(
                                                      //           context,
                                                      //           listen: false)
                                                      //       .add(
                                                      //           pageUrl:
                                                      //               "/quan-ly-lop-hoc/chi-tiet-lop/${kyTucXa['content'][i]['id']}");
                                                      // },
                                                      cells: [
                                                        DataCell(SelectableText(
                                                            '${tableIndex++}')),
                                                        DataCell(SelectableText(
                                                            row['name'])),
                                                        DataCell(SelectableText(
                                                            row['gender'] == 0
                                                                ? 'N???'
                                                                : 'Nam')),
                                                        DataCell(SelectableText(
                                                            countTts(row['id'])
                                                                .toString())),
                                                        DataCell(SelectableText(
                                                            row['capacity']
                                                                .toString())),
                                                        DataCell(Row(
                                                          children: [
                                                            getRule(
                                                                    listRule
                                                                        .data,
                                                                    Role.Xem,
                                                                    context)
                                                                ? Container(
                                                                    child: InkWell(
                                                                        onTap: () {
                                                                          Provider.of<NavigationModel>(context, listen: false)
                                                                              .add(pageUrl: "/chi-tiet-ktx/${row['id']}");
                                                                        },
                                                                        child: Icon(Icons.visibility)))
                                                                : Container(),
                                                            ruleManager
                                                                ? getRule(
                                                                        listRule
                                                                            .data,
                                                                        Role
                                                                            .Sua,
                                                                        context)
                                                                    ? Container(
                                                                        margin: EdgeInsets.fromLTRB(
                                                                            10,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                        child: InkWell(
                                                                            onTap: () {
                                                                              Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/them-moi-chinh-sua-ky-tuc/${row['id']}");
                                                                            },
                                                                            child: Icon(Icons.edit_calendar, color: Color(0xff009C87))))
                                                                    : Container()
                                                                : Container(),
                                                            ruleManager
                                                                ? getRule(
                                                                        listRule
                                                                            .data,
                                                                        Role
                                                                            .Xoa,
                                                                        context)
                                                                    ? Container(
                                                                        margin: EdgeInsets.fromLTRB(
                                                                            10,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                        child:
                                                                            InkWell(
                                                                          onTap:
                                                                              () {},
                                                                          child:
                                                                              Icon(
                                                                            Icons.delete_outline,
                                                                            color:
                                                                                Colors.red,
                                                                          ),
                                                                        ))
                                                                    : Container()
                                                                : Container(),
                                                          ],
                                                        )),
                                                        DataCell(ruleManager
                                                            ? Container(
                                                                child: InkWell(
                                                                    onTap: () {
                                                                      showDialog(
                                                                        context:
                                                                            context,
                                                                        builder: (BuildContext context) => ThemMoiHocVienKyTuc(
                                                                            function: () {
                                                                              getListKtxFuture = getListKtx(1);
                                                                            },
                                                                            room: row),
                                                                      );
                                                                    },
                                                                    child: Icon(
                                                                      Icons.add,
                                                                      color: Color(
                                                                          0xff009C87),
                                                                      size: 35,
                                                                    )))
                                                            : Container()),
                                                        DataCell(Row(
                                                          children: [
                                                            ruleManager
                                                                ? Container(
                                                                    margin: EdgeInsets
                                                                        .only(
                                                                            left:
                                                                                20),
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
                                                                                fontSize: 20.0,
                                                                                letterSpacing: 2.0),
                                                                      ),
                                                                      onPressed:
                                                                          () {
                                                                        showDialog(
                                                                          context:
                                                                              context,
                                                                          builder: (BuildContext context) => XacNhanHoanThanh(
                                                                              function: () {
                                                                                getListKtxFuture = getListKtx(1);
                                                                              },
                                                                              room: row),
                                                                        );
                                                                      },
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Text(
                                                                              'X??c nh???n',
                                                                              style: textButton),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Container(),
                                                          ],
                                                        )),
                                                      ])
                                              ]),
                                        ),
                                      ],
                                    ),
                                    DynamicTablePagging(
                                        rowCount, currentPageDef, rowPerPage,
                                        pageChangeHandler: (currentPage) {
                                      setState(() {
                                        getListKtxFuture =
                                            getListKtx(currentPage);
                                        currentPageDef = currentPage;
                                      });
                                    }, rowPerPageChangeHandler:
                                            (rowPerPageChange) {
                                      currentPageDef = 1;

                                      rowPerPage = rowPerPageChange;
                                      getListKtxFuture =
                                          getListKtx(currentPageDef);
                                      setState(() {});
                                    })
                                  ],
                                );
                              } else if (snapshot.hasError) {
                                return SelectableText('${snapshot.error}');
                              }

                              // By default, show a loading spinner.
                              return const Center(
                                  child: CircularProgressIndicator());
                            },
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Footer()
            ],
          );
        } else if (listRule.hasError) {
          print("L???i ph??n quy???n");
          return SelectableText('${listRule.error}');
        }

        // By default, show a loading spinner.
        return Center(child: const CircularProgressIndicator());
      },
    );
  }
}

// Pop-up th??m m???i h???c vi??n
class ThemMoiHocVienKyTuc extends StatefulWidget {
  final dynamic room;
  final Function function;
  const ThemMoiHocVienKyTuc(
      {Key? key, required this.room, required this.function})
      : super(key: key);

  @override
  State<ThemMoiHocVienKyTuc> createState() => _ThemMoiHocVienKyTucState();
}

class _ThemMoiHocVienKyTucState extends State<ThemMoiHocVienKyTuc> {
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
  bool load = false;
  var listTtsInRoom;
  var dataTable = [];
  var listTts = [];
  getListTtsCDT(int currentPage) async {
    String requestId = '';
    String requestDay = '';
    if (birthDay != null) {
      requestDay = " and birthDate:'$birthDay'";
    }
    var getListTtsInRoom =
        await httpGet("/api/kytucxa-chitiet/get/page?filter=status:1", context);
    var getListTtsInCurentRoom = await httpGet(
        "/api/kytucxa-chitiet/get/page?filter=dormId:${widget.room['id']} and status:1",
        context);
    if (getListTtsInCurentRoom.containsKey('body')) {
      var listDataTts = jsonDecode(getListTtsInCurentRoom["body"])['content'];
      for (var row in listDataTts)
        listTts.add({
          'thuctapsinh': row['thuctapsinh'],
          'id': row['id'],
          "deleted": false
        });
    }
    if (getListTtsInRoom.containsKey("body")) {
      listTtsInRoom = jsonDecode(getListTtsInRoom["body"])['content'];
      if (listTtsInRoom.length > 0) {
        requestId += 'and not(id in (';
        for (var row in listTtsInRoom) {
          requestId += row['thuctapsinh']['id'].toString();
          requestId += ',';
        }
        requestId = requestId.substring(0, requestId.length - 1);
        requestId += '))';
      }
    }
    var response = await httpGet(
        "/api/nguoidung/get/page?filter=isTts:1 AND ttsStatusId:9 and stopProcessing:0 and (fullName~'*${name.text}*' or userCode~'*${name.text}*') and gender:${widget.room['gender']} $requestDay$requestId",
        context);
    if (response.containsKey("body")) {
      rowCount = jsonDecode(response["body"])['totalElements'];
      listTtsTc = jsonDecode(response["body"])['content'];
      for (var row in listTtsTc) {
        dataTable.add({'thuctapsinh': row, 'status': false});
      }
      setState(() {});
      return listTtsTc;
    } else
      throw Exception("Error load data");
  }

  String titleLog = 'C???p nh???t d??? li???u th??nh c??ng';
  submitForm() async {
    var listTtsAdd = [];
    for (var row in listTts) {
      if (row['deleted'] == true && row['id'] != null) {
        var deleteTts =
            await httpDelete("/api/kytucxa-chitiet/del/${row['id']}", context);
        print("/api/kytucxa-chitiet/del/${row['id']}");
        if (jsonDecode(deleteTts["body"]).containsKey("1")) {
          titleLog = 'C???p nh???t d??? li???u th??nh c??ng';
        } else {
          titleLog = 'X??a kh??ng th??nh c??ng';
        }
      } else if (row['deleted'] == false && row['id'] == null) {
        listTtsAdd.add({
          "dormId": widget.room['id'],
          "ttsId": row['thuctapsinh']['id'],
          'status': 1
        });
      }
    }
    if (listTtsAdd.isNotEmpty) {
      var response = await httpPost(
          '/api/kytucxa-chitiet/post/saveAll', listTtsAdd, context);
      if (response['body'] == "true") {
        titleLog = 'C???p nh???t d??? li???u th??nh c??ng';
      } else {
        titleLog = 'C???p nh???t th???t b???i';
      }
    }
    showToast(
      context: context,
      msg: titleLog,
      color: titleLog == "C???p nh???t d??? li???u th??nh c??ng"
          ? Color.fromARGB(136, 72, 238, 67)
          : Colors.red,
      icon: titleLog == "C???p nh???t d??? li???u th??nh c??ng"
          ? Icon(Icons.done)
          : Icon(Icons.warning),
    );
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
    return FutureBuilder<dynamic>(
      future: getListTtsCDTFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var tableIndex = (currentPage - 1) * rowPerPage + 1;
          rowCount = dataTable.length;
          firstRow = (currentPage - 1) * rowPerPage;
          lastRow = currentPage * rowPerPage - 1;
          if (lastRow > rowCount - 1) {
            lastRow = rowCount - 1;
          }
          int countTtsInRoom = 0;
          for (var row in listTts) {
            if (row['deleted'] == false) {
              countTtsInRoom++;
            }
          }
          int firstRowTts = 1;
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
                        "Th??m th???c t???p sinh v??o k?? t??c",
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
                                              label: 'T??n TTS',
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
                                                    'Ng??y sinh',
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
                                                  Text('T??m ki???m ',
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
                                              'M?? TTS',
                                              style: titleTableData,
                                              textAlign: TextAlign.center,
                                            ))),
                                            DataColumn(
                                                label: Expanded(
                                                    child: SelectableText(
                                              'T??n TTS',
                                              style: titleTableData,
                                              textAlign: TextAlign.center,
                                            ))),
                                            DataColumn(
                                                label: Expanded(
                                                    child: SelectableText(
                                              'Ng??y th??ng n??m sinh',
                                              style: titleTableData,
                                              textAlign: TextAlign.center,
                                            ))),
                                            DataColumn(
                                                label: Expanded(
                                                    child: SelectableText(
                                              'Tr???ng th??i TTS',
                                              style: titleTableData,
                                              textAlign: TextAlign.center,
                                            ))),
                                          ],
                                          rows: <DataRow>[
                                            for (int i = firstRow;
                                                i <= lastRow;
                                                i++)
                                              DataRow(
                                                  selected: dataTable[i]
                                                      ['status'],
                                                  onSelectChanged: (value) {
                                                    dataTable[i]['status'] =
                                                        value;
                                                    setState(() {});
                                                  },
                                                  cells: [
                                                    DataCell(Center(
                                                        child: SelectableText(
                                                            "${tableIndex++}"))),
                                                    DataCell(Center(
                                                        child: SelectableText(
                                                            dataTable[i][
                                                                    'thuctapsinh']
                                                                ['userCode'],
                                                            style:
                                                                bangDuLieu))),
                                                    DataCell(Center(
                                                        child: SelectableText(
                                                            dataTable[i][
                                                                    'thuctapsinh']
                                                                ['fullName'],
                                                            style:
                                                                bangDuLieu))),
                                                    DataCell(Center(
                                                        child: SelectableText(
                                                            dataTable[i]['thuctapsinh']
                                                                        [
                                                                        'birthDate'] !=
                                                                    null
                                                                ? dateReverse(
                                                                    dataTable[i]
                                                                            [
                                                                            'thuctapsinh']
                                                                        [
                                                                        'birthDate'])
                                                                : 'no data',
                                                            style:
                                                                bangDuLieu))),
                                                    DataCell(Center(
                                                        child: SelectableText(
                                                            dataTable[i][
                                                                        'thuctapsinh']
                                                                    [
                                                                    'ttsTrangthai']
                                                                ['statusName'],
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
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
                                                fontSize: 20.0,
                                                letterSpacing: 2.0),
                                      ),
                                      onPressed: () {
                                        int count = 0;
                                        for (var row in dataTable) {
                                          if (row['status'] == true) {
                                            count++;
                                          }
                                        }
                                        if (widget.room['capacity'] -
                                                countTtsInRoom <
                                            count) {
                                          showToast(
                                            context: context,
                                            msg:
                                                "S??? l?????ng ch??? tr???ng trong ph??ng ch??? c??n ${widget.room['capacity'] - countTtsInRoom} ch???",
                                            color: Colors.red,
                                            icon: Icon(Icons.warning),
                                          );
                                        } else {
                                          var listData = [];
                                          listData.addAll(dataTable);
                                          for (var row in listData) {
                                            if (row['status'] == true) {
                                              listTts.add({
                                                'thuctapsinh':
                                                    row['thuctapsinh'],
                                                'deleted': false,
                                                'id': null
                                              });
                                              dataTable.remove(row);
                                            }
                                          }
                                        }

                                        setState(() {});
                                      },
                                      child: Row(
                                        children: [
                                          Text('Th??m th???c t???p sinh ',
                                              style: textButton),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 25,
                              ),
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SelectableText(
                                        'Danh s??ch c??c th???c t???p sinh trong ph??ng',
                                        style: titleBox,
                                      ),
                                      Icon(
                                        Icons.more_horiz,
                                        color: colorIconTitleBox,
                                        size: 14,
                                      ),
                                    ],
                                  ),
                                  //???????ng line
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
                                              'M?? TTS',
                                              style: titleTableData,
                                              textAlign: TextAlign.center,
                                            ))),
                                            DataColumn(
                                                label: Expanded(
                                                    child: SelectableText(
                                              'T??n TTS',
                                              style: titleTableData,
                                              textAlign: TextAlign.center,
                                            ))),
                                            DataColumn(
                                                label: Expanded(
                                                    child: SelectableText(
                                              'Ng??y th??ng n??m sinh',
                                              style: titleTableData,
                                              textAlign: TextAlign.center,
                                            ))),
                                            DataColumn(
                                                label: Expanded(
                                                    child: SelectableText(
                                              'Tr???ng th??i TTS',
                                              style: titleTableData,
                                              textAlign: TextAlign.center,
                                            ))),
                                            DataColumn(
                                                label: Expanded(
                                                    child: SelectableText(
                                              'X??a',
                                              style: titleTableData,
                                              textAlign: TextAlign.center,
                                            ))),
                                          ],
                                          rows: <DataRow>[
                                            for (var row in listTts)
                                              if (row['deleted'] == false)
                                                DataRow(cells: [
                                                  DataCell(Center(
                                                      child: SelectableText(
                                                          "${firstRowTts++}"))),
                                                  DataCell(Center(
                                                      child: SelectableText(
                                                          row['thuctapsinh']
                                                              ['userCode'],
                                                          style: bangDuLieu))),
                                                  DataCell(Center(
                                                      child: SelectableText(
                                                          row['thuctapsinh']
                                                              ['fullName'],
                                                          style: bangDuLieu))),
                                                  DataCell(Center(
                                                      child: SelectableText(
                                                          row['thuctapsinh'][
                                                                      'birthDate'] !=
                                                                  null
                                                              ? dateReverse(row[
                                                                      'thuctapsinh']
                                                                  ['birthDate'])
                                                              : 'no data',
                                                          style: bangDuLieu))),
                                                  DataCell(Center(
                                                      child: SelectableText(
                                                          row['thuctapsinh'][
                                                                  'ttsTrangthai']
                                                              ['statusName'],
                                                          style: bangDuLieu))),
                                                  DataCell(Center(
                                                    child: Container(
                                                        margin:
                                                            EdgeInsets.fromLTRB(
                                                                10, 0, 0, 0),
                                                        child: InkWell(
                                                          onTap: () {
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder: (BuildContext
                                                                        context) =>
                                                                    ConfirmUpdate(
                                                                        title:
                                                                            "X??c nh???n x??a",
                                                                        function:
                                                                            () {
                                                                          row['deleted'] =
                                                                              true;
                                                                          dataTable
                                                                              .add({
                                                                            'thuctapsinh':
                                                                                row['thuctapsinh'],
                                                                            'status':
                                                                                false
                                                                          });
                                                                          setState(
                                                                              () {});
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        content:
                                                                            "B???n c?? mu???n x??a th???c t???p sinh ra kh???i ph??ng kh??ng?"));
                                                          },
                                                          child: Icon(
                                                            Icons
                                                                .delete_outline,
                                                            color: Colors.red,
                                                          ),
                                                        )),
                                                  )),
                                                ])
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  countTtsInRoom == 0
                                      ? Center(
                                          child: SelectableText(
                                              'Kh??ng c?? th???c t???p sinh n??o'),
                                        )
                                      : Container()
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
                  child: Text('H???y', style: textButton),
                ),
              ),
              Container(
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
                    backgroundColor: Color.fromRGBO(245, 117, 29, 1),
                    primary: Theme.of(context).iconTheme.color,
                    textStyle: Theme.of(context)
                        .textTheme
                        .caption
                        ?.copyWith(fontSize: 20.0, letterSpacing: 2.0),
                  ),
                  onPressed: () async {
                    await showDialog(
                        context: context,
                        builder: (BuildContext context) => ConfirmUpdate(
                            title: "X??c nh???n thay ?????i",
                            function: () async {
                              await submitForm();
                              widget.function();
                              Navigator.pop(context);
                            },
                            content:
                                "B???n c?? ch???c ch???n mu???n th???c hi???n thay ?????i kh??ng?"));
                    Navigator.pop(context);

                    setState(() {});
                  },
                  child: Text('X??c nh???n', style: textButton),
                ),
              ),
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

class XacNhanHoanThanh extends StatefulWidget {
  final dynamic room;
  final Function function;
  const XacNhanHoanThanh({Key? key, required this.room, required this.function})
      : super(key: key);

  @override
  State<XacNhanHoanThanh> createState() => _XacNhanHoanThanhState();
}

class _XacNhanHoanThanhState extends State<XacNhanHoanThanh> {
  var listTts;
  var dataTable = [];
  late Future<dynamic> getListTts;
  getListTtsCDT() async {
    var response = await httpGet(
        "/api/kytucxa-chitiet/get/page?filter=dormId:${widget.room['id']} and status:1",
        context);
    if (response.containsKey("body")) {
      listTts = jsonDecode(response["body"])['content'];
      for (var row in listTts) {
        dataTable.add({
          'thuctapsinh': row['thuctapsinh'],
          'status': false,
          'id': row['id'],
          'object': row
        });
      }
      setState(() {});
      return dataTable;
    } else
      throw Exception("Error load data");
  }

  String titleLog = '';
  submitForm() async {
    var listTtsUpdate = [];
    for (var row in dataTable) {
      if (row['status'] == true) {
        row['object']['status'] = 0;
        listTtsUpdate.add(row['object']);
      }
    }
    var response =
        await httpPut('/api/kytucxa-chitiet/put/all', listTtsUpdate, context);
    if (response['body'] == "true") {
      titleLog = 'C???p nh???t d??? li???u th??nh c??ng';
    } else {
      titleLog = 'C???p nh???t th???t b???i';
    }
    showToast(
      context: context,
      msg: titleLog,
      color: titleLog == "C???p nh???t d??? li???u th??nh c??ng"
          ? Color.fromARGB(136, 72, 238, 67)
          : Colors.red,
      icon: titleLog == "C???p nh???t d??? li???u th??nh c??ng"
          ? Icon(Icons.done)
          : Icon(Icons.warning),
    );
  }

  @override
  void initState() {
    getListTts = getListTtsCDT();
    super.initState();
  }

  DateTime selectedDate = DateTime.now();
  int currentPage = 1;
  int rowPerPage = 10;
  var firstRow;
  var lastRow;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: getListTts,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
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
                        "Th??m th???c t???p sinh v??o k?? t??c",
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
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SelectableText(
                                        'Danh s??ch c??c th???c t???p sinh trong ph??ng',
                                        style: titleBox,
                                      ),
                                      Icon(
                                        Icons.more_horiz,
                                        color: colorIconTitleBox,
                                        size: 14,
                                      ),
                                    ],
                                  ),
                                  //???????ng line
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
                                              'M?? TTS',
                                              style: titleTableData,
                                              textAlign: TextAlign.center,
                                            ))),
                                            DataColumn(
                                                label: Expanded(
                                                    child: SelectableText(
                                              'T??n TTS',
                                              style: titleTableData,
                                              textAlign: TextAlign.center,
                                            ))),
                                            DataColumn(
                                                label: Expanded(
                                                    child: SelectableText(
                                              'Ng??y th??ng n??m sinh',
                                              style: titleTableData,
                                              textAlign: TextAlign.center,
                                            ))),
                                            DataColumn(
                                                label: Expanded(
                                                    child: SelectableText(
                                              'Tr???ng th??i TTS',
                                              style: titleTableData,
                                              textAlign: TextAlign.center,
                                            ))),
                                          ],
                                          rows: <DataRow>[
                                            for (var row in dataTable)
                                              DataRow(
                                                  selected: row['status'],
                                                  onSelectChanged: (value) {
                                                    row['status'] = value;
                                                    setState(() {});
                                                  },
                                                  cells: [
                                                    DataCell(Center(
                                                        child: SelectableText(
                                                            ""))),
                                                    DataCell(Center(
                                                        child: SelectableText(
                                                            row['thuctapsinh']
                                                                ['userCode'],
                                                            style:
                                                                bangDuLieu))),
                                                    DataCell(Center(
                                                        child: SelectableText(
                                                            row['thuctapsinh']
                                                                ['fullName'],
                                                            style:
                                                                bangDuLieu))),
                                                    DataCell(Center(
                                                        child: SelectableText(
                                                            row['thuctapsinh'][
                                                                        'birthDate'] !=
                                                                    null
                                                                ? dateReverse(row[
                                                                        'thuctapsinh']
                                                                    [
                                                                    'birthDate'])
                                                                : 'no data',
                                                            style:
                                                                bangDuLieu))),
                                                    DataCell(Center(
                                                        child: SelectableText(
                                                            row['thuctapsinh'][
                                                                    'ttsTrangthai']
                                                                ['statusName'],
                                                            style:
                                                                bangDuLieu))),

                                                    //
                                                  ])
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  dataTable.length == 0
                                      ? Center(
                                          child: SelectableText(
                                              'Kh??ng c?? th???c t???p sinh n??o'),
                                        )
                                      : Container()
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
                  child: Text('H???y', style: textButton),
                ),
              ),
              Container(
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
                    backgroundColor: Color.fromRGBO(245, 117, 29, 1),
                    primary: Theme.of(context).iconTheme.color,
                    textStyle: Theme.of(context)
                        .textTheme
                        .caption
                        ?.copyWith(fontSize: 20.0, letterSpacing: 2.0),
                  ),
                  onPressed: () async {
                    await showDialog(
                        context: context,
                        builder: (BuildContext context) => ConfirmUpdate(
                            title: "X??c nh???n thay ?????i",
                            function: () async {
                              await submitForm();
                              widget.function();
                              Navigator.pop(context);
                            },
                            content:
                                "B???n c?? ch???c ch???n mu???n th???c hi???n thay ?????i kh??ng?"));
                    Navigator.pop(context);

                    setState(() {});
                  },
                  child: Text('X??c nh???n', style: textButton),
                ),
              ),
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
