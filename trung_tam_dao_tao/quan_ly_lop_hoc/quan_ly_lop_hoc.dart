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

class QLLopHoc extends StatefulWidget {
  const QLLopHoc({Key? key}) : super(key: key);

  @override
  State<QLLopHoc> createState() => _QLLopHocState();
}

class _QLLopHocState extends State<QLLopHoc> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
      widgetBody: QLLopHocBody(),
    );
  }
}

class QLLopHocBody extends StatefulWidget {
  const QLLopHocBody({Key? key}) : super(key: key);

  @override
  State<QLLopHocBody> createState() => _QLLopHocBodyState();
}

class _QLLopHocBodyState extends State<QLLopHocBody> {
  var listItems;
  String? request;
  late Future<dynamic> getListGVCNFuture;
  dynamic selectedValue = '-1';
  late int rowCount = 0;
  int currentPageDef = 1;
  int rowPerPage = 10;
  var listLH = {};
  var gvcn;
  late Future<dynamic> getListLHFuture;
  Map<int, int> listCount = {};
  dynamic listItemsGVCN = [];
  TextEditingController searchGVCN = TextEditingController(text: '');
  Future<dynamic> getlistGVCN() async {
    var response = await httpGet(
        "/api/nguoidung/get/page?filter=isAam:1 AND departId:7 and fullName~'*${searchGVCN.text}*'",
        context);

    if (response.containsKey("body")) {
      setState(() {
        listItems = jsonDecode(response["body"]);
      });
    }
    listItemsGVCN = [];
    for (var row in listItems['content']) {
      listItemsGVCN.add({
        'value': row['id'].toString(),
        'name': row['fullName'],
        'code': row['userCode']
      });
    }
    return listItems;
  }

  var listTtsInLH;
  getCountTts() async {
    var response = await httpGet("/api/daotao-tts/get/page", context);
    if (response.containsKey("body")) {
      setState(() {
        listTtsInLH = jsonDecode(response["body"]);
      });
    }
    return listTtsInLH;
  }

  bool ruleAdd = false;
  getListLH(int currentPage) async {
    var response;
    await getCountTts();
    if (request == null) {
      response = await httpGet(
          "/api/daotao-lop/get/page?size=$rowPerPage&page=${currentPage - 1}",
          context);
    } else {
      if (selectedValue == '-1')
        response = await httpGet(
            "/api/daotao-lop/get/page?size=$rowPerPage&page=${currentPage - 1}&filter=code~'*$request*' or name~'*$request*'",
            context);
      else {
        response = await httpGet(
            "/api/daotao-lop/get/page?size=$rowPerPage&page=${currentPage - 1}&filter=(code~'*$request*' or name~'*$request*') and giaovienId:$selectedValue",
            context);
      }
    }
    if (response.containsKey("body")) {
      listLH = jsonDecode(response["body"]);
      if (listLH['totalElements'] != null) rowCount = listLH['totalElements'];
      return listLH;
    } else
      throw Exception('False to load data');
  }

  void search() {
    setState(() {
      request = textSearch.text;
      getListLHFuture = getListLH(1);
      setState(() {});
    });
  }

  TextEditingController textSearch = TextEditingController();
  @override
  void initState() {
    getListGVCNFuture = getlistGVCN();
    getListLHFuture = getListLH(1);
  }

  GlobalKey _globalKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    var curentUser =
        Provider.of<SecurityModel>(context, listen: false).userLoginCurren;
    return FutureBuilder<dynamic>(
      future: userRule('/quan-ly-lop-hoc', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return FutureBuilder<dynamic>(
            future: getListGVCNFuture,
            builder: (context, listGVCN) {
              if (listGVCN.hasData) {
                return ListView(
                  children: [
                    TitlePage(
                      listPreTitle: [
                        {'url': '/bang-thong-ke-nhanh', 'title': 'Dashboard'},
                      ],
                      content: 'Qu???n l?? l???p h???c',
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
                                            flex: 6,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 7,
                                                  child: TextFieldValidatedForm(
                                                      type: 'None',
                                                      label: 'L???p',
                                                      height: 40,
                                                      controller: textSearch,
                                                      enter: () {
                                                        search();
                                                      }),
                                                ),
                                              ],
                                            )),
                                        SizedBox(
                                          width: 100,
                                        ),
                                        Expanded(
                                          flex: 10,
                                          child: Container(
                                            margin: EdgeInsets.only(bottom: 40),
                                            child: DropdownBtnSearch(
                                              isAll: true,
                                              label: 'Gi??o vi??n ch??? nhi???m',
                                              listItems: listItemsGVCN,
                                              search: searchGVCN,
                                              isSearch: true,
                                              selectedValue: selectedValue,
                                              setSelected: (selected) {
                                                selectedValue = selected;
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
                                                  getRule(listRule.data,
                                                          Role.Xem, context)
                                                      ? Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 20),
                                                          child:
                                                              TextButton.icon(
                                                            style: TextButton
                                                                .styleFrom(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                vertical: 20.0,
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
                                                              search();
                                                            },
                                                            icon: Transform
                                                                .rotate(
                                                              angle: 270,
                                                              child: Icon(
                                                                Icons.search,
                                                                color: Colors
                                                                    .white,
                                                                size: 15,
                                                              ),
                                                            ),
                                                            label: Row(
                                                              children: [
                                                                Text(
                                                                    'T??m ki???m ',
                                                                    style:
                                                                        textButton),
                                                              ],
                                                            ),
                                                          ),
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
                                                                      'level'] >=
                                                                  2)
                                                      ? getRule(
                                                              listRule.data,
                                                              Role.Them,
                                                              context)
                                                          ? Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left: 20),
                                                              child: TextButton
                                                                  .icon(
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
                                                                        BorderRadius.circular(
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
                                                                              "/them-moi-lop-hoc");
                                                                },
                                                                icon: Icon(
                                                                  Icons.add,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 15,
                                                                ),
                                                                label: Row(
                                                                  children: [
                                                                    Text(
                                                                        'Th??m m???i',
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
                                  'Danh s??ch l???p h???c',
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
                                  future: getListLHFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      int countTts(id) {
                                        int count = 0;
                                        for (var row
                                            in listTtsInLH['content'] ?? []) {
                                          if (row['daotaoLopId'] == id &&
                                              row['nguoidung']['ttsStatusId'] ==
                                                  9) {
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
                                                          label: SelectableText(
                                                              'STT',
                                                              style:
                                                                  titleTableData)),
                                                      DataColumn(
                                                          label: SelectableText(
                                                              'M?? l???p h???c',
                                                              style:
                                                                  titleTableData)),
                                                      DataColumn(
                                                          label: SelectableText(
                                                              'T??n l???p h???c',
                                                              style:
                                                                  titleTableData)),
                                                      DataColumn(
                                                          label: SelectableText(
                                                              'Gi??o vi??n ch??? nhi???m',
                                                              style:
                                                                  titleTableData)),
                                                      DataColumn(
                                                          label: SelectableText(
                                                              'S??? l?????ng h???c vi??n',
                                                              style:
                                                                  titleTableData)),
                                                      DataColumn(
                                                          label: SelectableText(
                                                              'H??nh ?????ng',
                                                              style:
                                                                  titleTableData)),
                                                    ],
                                                    rows: [
                                                      for (var row
                                                          in listLH['content'])
                                                        DataRow(
                                                            // onLongPress: () {
                                                            //   Provider.of<NavigationModel>(
                                                            //           context,
                                                            //           listen: false)
                                                            //       .add(
                                                            //           pageUrl:
                                                            //               "/quan-ly-lop-hoc/chi-tiet-lop/${listLH['content'][i]['id']}");
                                                            // },
                                                            cells: [
                                                              DataCell(
                                                                  SelectableText(
                                                                      '${tableIndex++}')),
                                                              DataCell(
                                                                  SelectableText(
                                                                      row['code'])),
                                                              DataCell(
                                                                  Container(
                                                                width: MediaQuery.of(context).size.width < 1600
                                                                    ? MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.15
                                                                    : MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.3,
                                                                child: SelectableText(
                                                                    row['name']),
                                                              )),
                                                              DataCell(SelectableText(
                                                                  row['giaovien']
                                                                      [
                                                                      'fullName'])),
                                                              DataCell(SelectableText(
                                                                  countTts(row[
                                                                          'id'])
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
                                                                                Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/chi-tiet-lop/${row['id']}");
                                                                              },
                                                                              child: Icon(Icons.visibility)))
                                                                      : Container(),
                                                                  curentUser['departId'] == 1 ||
                                                                          curentUser['departId'] ==
                                                                              2 ||
                                                                          (curentUser['departId'] == 7 &&
                                                                              curentUser['vaitro'] !=
                                                                                  null &&
                                                                              curentUser['vaitro']['level'] >=
                                                                                  2)
                                                                      ? getRule(
                                                                              listRule.data,
                                                                              Role.Sua,
                                                                              context)
                                                                          ? Container(
                                                                              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                              child: InkWell(
                                                                                  onTap: () {
                                                                                    Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/them-moi-lop-hoc/${row['id']}");
                                                                                  },
                                                                                  child: Icon(Icons.edit_calendar, color: Color(0xff009C87))))
                                                                          : Container()
                                                                      : Container(),
                                                                  curentUser['departId'] == 1 ||
                                                                          curentUser['departId'] ==
                                                                              2 ||
                                                                          (curentUser['departId'] == 7 &&
                                                                              curentUser['vaitro'] !=
                                                                                  null &&
                                                                              curentUser['vaitro']['level'] >=
                                                                                  2)
                                                                      ? getRule(
                                                                              listRule.data,
                                                                              Role.Xoa,
                                                                              context)
                                                                          ? Container(
                                                                              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                              child: InkWell(
                                                                                onTap: () {
                                                                                  showDialog(
                                                                                    context: context,
                                                                                    builder: (BuildContext context) => XacNhanXoa(
                                                                                      id: row['id'],
                                                                                      function: () async {
                                                                                        getListLHFuture = getListLH(currentPageDef);
                                                                                      },
                                                                                    ),
                                                                                  );
                                                                                },
                                                                                child: Icon(
                                                                                  Icons.delete_outline,
                                                                                  color: Colors.red,
                                                                                ),
                                                                              ))
                                                                          : Container()
                                                                      : Container(),
                                                                ],
                                                              )),
                                                            ])
                                                    ]),
                                              ),
                                            ],
                                          ),
                                          DynamicTablePagging(rowCount,
                                              currentPageDef, rowPerPage,
                                              pageChangeHandler: (currentPage) {
                                            setState(() {
                                              getListLHFuture =
                                                  getListLH(currentPage);
                                              currentPageDef = currentPage;
                                            });
                                          }, rowPerPageChangeHandler:
                                                  (rowPerPageChange) {
                                            currentPageDef = 1;

                                            rowPerPage = rowPerPageChange;
                                            getListLHFuture =
                                                getListLH(currentPageDef);
                                            setState(() {});
                                          })
                                        ],
                                      );
                                    } else if (snapshot.hasError) {
                                      return SelectableText(
                                          '${snapshot.error}');
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
                  ],
                );
              } else if (listGVCN.hasError) {
                return SelectableText('${listGVCN.error}');
              }

              // By default, show a loading spinner.
              return const Center(child: CircularProgressIndicator());
            },
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

//X??c nh???n th??m v??o kho l??u tr???
class LuuTru extends StatefulWidget {
  const LuuTru({Key? key}) : super(key: key);

  @override
  State<LuuTru> createState() => _LuuTruState();
}

class _LuuTruState extends State<LuuTru> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Row(
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
                  '???? chuy???n d??? li???u v??o kho l??u tr???',
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
    );
  }
}

class XacNhanXoa extends StatefulWidget {
  Function function;
  int id;
  XacNhanXoa({Key? key, required this.function, required this.id})
      : super(key: key);
  @override
  State<XacNhanXoa> createState() => _XacNhanXoaState();
}

class _XacNhanXoaState extends State<XacNhanXoa> {
  String titleLog = '';
  deleteLH(id) async {
    var response =
        await httpDelete("/api/daotao-lop/del/${id.toString()}", context);
    if (jsonDecode(response["body"]).containsKey("1")) {
      titleLog = '???? x??a l???p h???c';
    } else {
      var result = jsonDecode(response["body"]);

      titleLog = result["0"];
    }
    return 0;
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
                  'X??c nh???n x??a l???p h???c',
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
              'B???n c?? ch???c ch???n mu???n x??a l???p h???c kh??ng?',
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
          child: Text('H???y'),
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
            await deleteLH(widget.id);

            showToast(
              context: context,
              msg: titleLog,
              color: titleLog == "???? x??a l???p h???c"
                  ? Color.fromARGB(136, 72, 238, 67)
                  : Colors.red,
              icon: titleLog == "???? x??a l???p h???c"
                  ? Icon(Icons.done)
                  : Icon(Icons.warning),
            );
            Navigator.pop(context);
            widget.function();
          },
          child: Text(
            '?????ng ??',
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
