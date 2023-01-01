import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/widgets_form.dart';
import 'package:gentelella_flutter/model/model.dart';
import 'package:provider/provider.dart';

import '../../../../api.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';
import '../../navigation.dart';

class QLChuongTrinhDaoTao extends StatefulWidget {
  const QLChuongTrinhDaoTao({Key? key}) : super(key: key);

  @override
  State<QLChuongTrinhDaoTao> createState() => _QLChuongTrinhDaoTaoState();
}

class _QLChuongTrinhDaoTaoState extends State<QLChuongTrinhDaoTao> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
      widgetBody: QLChuongTrinhDaoTaoBody(),
    );
  }
}

class QLChuongTrinhDaoTaoBody extends StatefulWidget {
  const QLChuongTrinhDaoTaoBody({Key? key}) : super(key: key);

  @override
  State<QLChuongTrinhDaoTaoBody> createState() =>
      _QLChuongTrinhDaoTaoBodyState();
}

class _QLChuongTrinhDaoTaoBodyState extends State<QLChuongTrinhDaoTaoBody> {
  var listCTDT;
  TextEditingController textCtdt = TextEditingController(text: '');
  String request = '';
  late Future<dynamic> getListCTDTFuture;
  bool isNumber(String string) {
    try {
      int.parse(string);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<dynamic> getListCTDT() async {
    var response;
    String request = '';

    if (total.text != '' && isNumber(total.text)) {
      request = 'and lecturesTotal:${total.text}';
    }
    if (courseTime.text != '') {
      request += "and courseTime~'*${courseTime.text}*'";
    }
    response = await httpGet(
        "/api/daotao-chuongtrinh/get/page?filter=parentId:0  AND  name~'*${textCtdt.text}*'  $request",
        context);
    if (response.containsKey("body")) {
      setState(() {
        listCTDT = jsonDecode(response["body"])['content'];
        rowCount = jsonDecode(response["body"])['totalElements'];
      });
    }
    return listCTDT;
  }

  void search() {
    request = textCtdt.text;
    getListCTDTFuture = getListCTDT();
    setState(() {});
  }

  late int rowCount = 0;
  int currentPage = 1;
  int rowPerPage = 5;
  TextEditingController courseTime = TextEditingController();
  TextEditingController total = TextEditingController();

  @override
  void initState() {
    getListCTDTFuture = getListCTDT();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: userRule('/quan-ly-chuong-trinh-dao-tao', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return FutureBuilder<dynamic>(
            future: getListCTDTFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var firstRow = (currentPage - 1) * rowPerPage;
                var lastRow = currentPage * rowPerPage;
                if (lastRow > rowCount) {
                  lastRow = rowCount;
                }
                var lastPage = rowCount % rowPerPage != 0
                    ? rowCount ~/ rowPerPage + 1
                    : rowCount / rowPerPage;

                var currentPageDisplay = currentPage;
                if (currentPage > lastPage - 2) {
                  currentPageDisplay = int.parse(lastPage.toString()) - 2;
                }
                var tableIndex = (currentPage - 1) * rowPerPage + 1;
                var curentUser =
                    Provider.of<SecurityModel>(context, listen: false)
                        .userLoginCurren;
                return ListView(
                  children: [
                    TitlePage(
                      listPreTitle: [
                        {'url': '/bang-thong-ke-nhanh', 'title': 'Dashboard'},
                      ],
                      content: 'Quản lý chương trình đào tạo',
                    ),
                    // Center(child: NavBar()),
                    Container(
                      color: backgroundPage,
                      padding: EdgeInsets.symmetric(
                          vertical: verticalPaddingPage,
                          horizontal: horizontalPaddingPage),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 20, bottom: 25),
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
                                    Text(
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
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: TextFieldValidatedForm(
                                        type: 'None',
                                        label: 'Chương trình đào tạo',
                                        height: 40,
                                        controller: textCtdt,
                                        enter: () {
                                          search();
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: 100,
                                    ),
                                    Expanded(
                                      child: TextFieldValidatedForm(
                                        type: 'None',
                                        label: 'Thời gian đào tạo',
                                        height: 40,
                                        controller: courseTime,
                                        enter: () {
                                          search();
                                        },
                                      ),
                                    )
                                  ],
                                ),
                                Column(children: [
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: TextFieldValidatedForm(
                                            type: 'Number',
                                            label: 'Số bài giảng',
                                            height: 40,
                                            controller: total,
                                            require: true,
                                            enter: () {
                                              search();
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          width: 100,
                                        ),
                                        Expanded(
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
                                                                      20.0,
                                                                  letterSpacing:
                                                                      2.0),
                                                        ),
                                                        onPressed: () {
                                                          search();
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
                                                            Text(
                                                                'Tìm kiếm ',
                                                                style:
                                                                    textButton),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  : Container(),
                                              curentUser['departId'] == 1 ||
                                                      curentUser['departId'] ==
                                                          2 ||
                                                      (curentUser['departId'] ==
                                                              7 &&
                                                          curentUser[
                                                                  'vaitro'] !=
                                                              null &&
                                                          curentUser['vaitro']
                                                                  ['level'] >=
                                                              2)
                                                  ? getRule(listRule.data,
                                                          Role.Them, context)
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
                                                              Provider.of<NavigationModel>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .add(
                                                                      pageUrl:
                                                                          "/them-moi-cap-nhat-chuong-trinh-dao-tao");
                                                            },
                                                            icon: Icon(
                                                              Icons.add,
                                                              color:
                                                                  Colors.white,
                                                              size: 15,
                                                            ),
                                                            label: Row(
                                                              children: [
                                                                Text('Thêm mới',
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
                                        ),
                                      ]),
                                ]),
                              ],
                            ),
                          ),
                          Container(
                            // padding: paddingBoxContainer,
                            child: Column(
                              children: [
                                if (listCTDT.isNotEmpty)
                                  for (int i = firstRow; i < lastRow; i++)
                                    CardTrainTime(
                                      xem: getRule(
                                          listRule.data, Role.Xem, context),
                                      sua: getRule(
                                          listRule.data, Role.Sua, context),
                                      xoa: getRule(
                                          listRule.data, Role.Xoa, context),
                                      row: listCTDT[i],
                                      function: () {
                                        getListCTDTFuture = getListCTDT();
                                      },
                                    )
                                else
                                  Center(
                                      child: Container(
                                    margin: EdgeInsets.only(top: 50),
                                    child: Text(
                                      'Không có chương trình đào tạo nào!',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  )),
                                SizedBox(
                                  height: 25,
                                ),
                                rowCount > 0
                                    ? Row(
                                        children: [
                                          Expanded(flex: 3, child: Container()),
                                          Expanded(
                                            flex: 2,
                                            child: lastPage > 5
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      IconButton(
                                                          color:
                                                              Color(0xff009C87),
                                                          onPressed:
                                                              currentPage > 1
                                                                  ? () {
                                                                      currentPage--;
                                                                      setState(
                                                                          () {});
                                                                    }
                                                                  : null,
                                                          icon: Icon(Icons
                                                              .chevron_left)),
                                                      for (int i = currentPageDisplay ==
                                                                  1
                                                              ? currentPageDisplay
                                                              : currentPageDisplay -
                                                                  1;
                                                          i <
                                                              (currentPageDisplay ==
                                                                      1
                                                                  ? currentPageDisplay +
                                                                      3
                                                                  : currentPageDisplay +
                                                                      2);
                                                          i++)
                                                        i != currentPage
                                                            ? TextButton(
                                                                style: TextButton
                                                                    .styleFrom(
                                                                  primary: Colors
                                                                      .black,
                                                                ),
                                                                onPressed: () {
                                                                  currentPage =
                                                                      i;
                                                                  setState(
                                                                      () {});
                                                                },
                                                                child: Text(
                                                                    '${i < 10 ? "0" : ""}$i'))
                                                            : TextButton(
                                                                style: TextButton
                                                                    .styleFrom(
                                                                  primary: Color(
                                                                      0xff009C87),
                                                                ),
                                                                onPressed: () {
                                                                  currentPage =
                                                                      i;
                                                                  setState(
                                                                      () {});
                                                                },
                                                                child: Text(
                                                                    '${i < 10 ? "0" : ""}$i',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold))),
                                                      Text("..."),
                                                      currentPage != lastPage
                                                          ? TextButton(
                                                              style: TextButton
                                                                  .styleFrom(
                                                                primary: Colors
                                                                    .black,
                                                              ),
                                                              onPressed: () {
                                                                currentPage =
                                                                    int.parse(
                                                                        lastPage
                                                                            .toString());

                                                                setState(() {});
                                                              },
                                                              child: Text(
                                                                  '${lastPage < 10 ? "0" : ""}$lastPage'))
                                                          : TextButton(
                                                              style: TextButton
                                                                  .styleFrom(
                                                                primary: Color(
                                                                    0xff009C87),
                                                              ),
                                                              onPressed: () {},
                                                              child: Text(
                                                                  '${lastPage < 10 ? "0" : ""}$lastPage',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold))),
                                                      IconButton(
                                                          color:
                                                              Color(0xff009C87),
                                                          onPressed:
                                                              currentPage <
                                                                      lastPage
                                                                  ? () {
                                                                      currentPage++;
                                                                      setState(
                                                                          () {});
                                                                    }
                                                                  : null,
                                                          icon: Icon(Icons
                                                              .chevron_right)),
                                                    ],
                                                  )
                                                : Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                        IconButton(
                                                            color: Color(
                                                                0xff009C87),
                                                            onPressed:
                                                                currentPage > 1
                                                                    ? () {
                                                                        currentPage--;
                                                                        setState(
                                                                            () {});
                                                                      }
                                                                    : null,
                                                            icon: Icon(Icons
                                                                .chevron_left)),
                                                        for (int i = 1;
                                                            i <= lastPage;
                                                            i++)
                                                          i != currentPage
                                                              ? TextButton(
                                                                  style: TextButton
                                                                      .styleFrom(
                                                                    primary: Colors
                                                                        .black,
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    currentPage =
                                                                        i;
                                                                    setState(
                                                                        () {});
                                                                  },
                                                                  child: Text(
                                                                      '${i < 10 ? '0' : ''}$i'))
                                                              : TextButton(
                                                                  style: TextButton
                                                                      .styleFrom(
                                                                    primary: Color(
                                                                        0xff009C87),
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    currentPage =
                                                                        i;
                                                                    setState(
                                                                        () {});
                                                                  },
                                                                  child:
                                                                      Text(
                                                                    '${i < 10 ? '0' : ''}$i',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  )),
                                                        IconButton(
                                                            color: Color(
                                                                0xff009C87),
                                                            onPressed:
                                                                currentPage <
                                                                        lastPage
                                                                    ? () {
                                                                        currentPage++;
                                                                        setState(
                                                                            () {});
                                                                      }
                                                                    : null,
                                                            icon: Icon(Icons
                                                                .chevron_right)),
                                                      ]),
                                          ),
                                          Expanded(flex: 3, child: Container()),
                                        ],
                                      )
                                    : Container()
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Footer()
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return const Center(child: CircularProgressIndicator());
            },
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

class CardTrainTime extends StatefulWidget {
  final dynamic row;
  final bool xem;
  final bool sua;
  final bool xoa;
  final Function? function;
  const CardTrainTime(
      {Key? key,
      required this.row,
      this.function,
      required this.xem,
      required this.sua,
      required this.xoa})
      : super(key: key);

  @override
  State<CardTrainTime> createState() => _CardTrainTimeState();
}

class _CardTrainTimeState extends State<CardTrainTime> {
  bool _showTable = false;
  var listCTDT = {};
  late Future<dynamic> getCTDTFuture;
  Future<dynamic> getListCTDT() async {
    var response = await httpGet(
        "/api/daotao-chuongtrinh/get/page?filter=parentId:${widget.row['id'].toString()}",
        context);
    if (response.containsKey("body")) {
      setState(() {
        listCTDT = jsonDecode(response["body"]);
      });
      return listCTDT;
    } else
      throw Exception('Lỗi rồi ----');
  }

  String titleLog = '';
  deleteCTDT(id) async {
    var response = await httpDelete("/api/daotao-chuongtrinh/del/$id", context);
    if (jsonDecode(response['body']).containsKey('1')) {
      titleLog = jsonDecode(response['body'])['1'];
    } else {
      titleLog = jsonDecode(response['body'])['0'];
    }
    showToast(
      context: context,
      msg: titleLog,
      color: titleLog == "Xóa thành công."
          ? Color.fromARGB(136, 72, 238, 67)
          : Colors.red,
      icon: titleLog == "Xóa thành công."
          ? Icon(Icons.done)
          : Icon(Icons.warning),
    );
    return titleLog;
  }

  late Future<dynamic> getListBG;

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var curentUser =
        Provider.of<SecurityModel>(context, listen: false).userLoginCurren;
    return Column(
      children: [
        Container(
            margin: new EdgeInsets.symmetric(vertical: 10.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        flex: 20,
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                  margin: const EdgeInsets.all(0),
                                  padding: const EdgeInsets.all(0),
                                  decoration: BoxDecoration(
                                    color: _showTable
                                        ? Color(0xffB2DFD9)
                                        : Colors.white,
                                    border: Border.all(color: Colors.black12),
                                    borderRadius: _showTable
                                        ? BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10))
                                        : BorderRadius.circular(10),
                                    boxShadow: [boxShadowContainer],
                                  ),
                                  // borderRadius: borderRadiusContainer,
                                  // border: borderAllContainerBox,
                                  child: TextButton(
                                      style: TextButton.styleFrom(
                                        primary: Color(0xff009C87),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          if (_showTable == false)
                                            getListBG = getListCTDT();

                                          _showTable = !_showTable;
                                          // _showTable
                                          //     ? _bg = 'green'
                                          //     : _bg = 'blue';
                                        });
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            margin:
                                                const EdgeInsets.only(left: 30),
                                            height: 130,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    widget.row['name'],
                                                    style: TextStyle(
                                                      fontSize: 26,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xff212529),
                                                    )),
                                                Text(
                                                  "Thời gian: ${widget.row['courseTime'] ?? "No data"}",
                                                  style: TextStyle(
                                                    color: Color(0xff000000),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  'Số lượng bài giảng: ${widget.row['lecturesTotal'].toString() == 'null' ? 'No data' : widget.row['lecturesTotal'].toString()}',
                                                  style: TextStyle(
                                                    color: Color(0xff000000),
                                                    fontSize: 14,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Container(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 10, 0, 10),
                                              margin: const EdgeInsets.only(
                                                  right: 30),
                                              height: 120,
                                              child: Row(
                                                children: [
                                                  widget.xem
                                                      ? Tooltip(
                                                          message:
                                                              "Xem chi tiết",
                                                          child: IconButton(
                                                            splashRadius: 1,
                                                            onPressed: () {
                                                              Provider.of<NavigationModel>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .add(
                                                                      pageUrl:
                                                                          "/chi-tiet-chuong-trinh-dao-tao/${widget.row['id']}");
                                                            },
                                                            icon: Icon(
                                                              Icons.visibility,
                                                              color: Colors
                                                                  .blueGrey,
                                                            ),
                                                            iconSize: 26,
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
                                                      ? widget.sua
                                                          ? Tooltip(
                                                              message:
                                                                  "Chỉnh sửa chương trình đào tạo",
                                                              child: IconButton(
                                                                splashRadius: 1,
                                                                onPressed: () {
                                                                  Provider.of<NavigationModel>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .add(
                                                                          pageUrl:
                                                                              "/them-moi-cap-nhat-chuong-trinh-dao-tao/${widget.row['id']}");
                                                                },
                                                                icon: Icon(
                                                                  Icons
                                                                      .edit_calendar,
                                                                  color: Color(
                                                                      0xff009C87),
                                                                ),
                                                                iconSize: 26,
                                                              ),
                                                            )
                                                          : Container()
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
                                                      ? widget.xoa
                                                          ? Tooltip(
                                                              message:
                                                                  "Xóa chương trình đào tạo",
                                                              child: IconButton(
                                                                  splashRadius:
                                                                      1,
                                                                  onPressed:
                                                                      () {
                                                                    showDialog(
                                                                      context:
                                                                          context,
                                                                      builder: (BuildContext
                                                                              context) =>
                                                                          XacNhanXoa(
                                                                        function:
                                                                            () async {
                                                                          await deleteCTDT(
                                                                              widget.row['id']);
                                                                          widget
                                                                              .function!();

                                                                          // getListBG =
                                                                          //     getListCTDT();
                                                                        },
                                                                      ),
                                                                    );
                                                                  },
                                                                  icon: Icon(
                                                                    Icons
                                                                        .delete_outline,
                                                                    color: Colors
                                                                        .red,
                                                                  ),
                                                                  iconSize: 26),
                                                            )
                                                          : Container()
                                                      : Container()
                                                ],
                                              ))
                                        ],
                                      ))),
                            ],
                          ),
                        )),
                  ],
                ),
                _showTable
                    ? FutureBuilder<dynamic>(
                        future: getListBG,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.black12),
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      flex: 20,
                                      child: Table(
                                          border: TableBorder(
                                              horizontalInside: BorderSide(
                                                  color: Color.fromARGB(
                                                      184, 233, 240, 246)),
                                              right: BorderSide(
                                                  color: Color.fromARGB(
                                                      184, 233, 240, 246))),
                                          defaultVerticalAlignment:
                                              TableCellVerticalAlignment.middle,
                                          children: <TableRow>[
                                            if (listCTDT['content'] != null &&
                                                listCTDT['content'].length > 0)
                                              for (int i = 0;
                                                  i <
                                                      listCTDT['content']
                                                          .length;
                                                  i++)
                                                TableRow(children: [
                                                  Container(
                                                      // color: i % 2 == 0
                                                      //     ? Color(0xF2F2F2)
                                                      //     : Colors.white,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    75,
                                                                    0,
                                                                    75,
                                                                    0),
                                                            child:
                                                                Text(
                                                              listCTDT[
                                                                      'content']
                                                                  [i]['name'],
                                                              style: TextStyle(
                                                                color: Color(
                                                                    0xff000000),
                                                                fontSize: 18,
                                                              ),
                                                            ),
                                                          ),
                                                          Row(
                                                            children: [
                                                              curentUser['departId'] == 1 ||
                                                                      curentUser[
                                                                              'departId'] ==
                                                                          2 ||
                                                                      (curentUser['departId'] == 7 &&
                                                                          curentUser['vaitro'] !=
                                                                              null &&
                                                                          curentUser['vaitro']['level'] >=
                                                                              2)
                                                                  ? widget.sua
                                                                      ? Tooltip(
                                                                          message:
                                                                              "Chỉnh sửa bài giảng",
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsets.fromLTRB(
                                                                                75,
                                                                                0,
                                                                                0,
                                                                                0),
                                                                            child:
                                                                                IconButton(
                                                                              splashRadius: 1,
                                                                              onPressed: () {
                                                                                Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/them-moi-cap-nhat-chuong-trinh-dao-tao/${listCTDT['content'][i]['id']}");
                                                                              },
                                                                              icon: Icon(
                                                                                Icons.edit_calendar,
                                                                                color: Color(0xff009C87),
                                                                              ),
                                                                              iconSize: 26,
                                                                            ),
                                                                          ),
                                                                        )
                                                                      : Container()
                                                                  : Container(),
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        right:
                                                                            30),
                                                                child: curentUser['departId'] == 1 ||
                                                                        curentUser['departId'] ==
                                                                            2 ||
                                                                        (curentUser['departId'] == 7 &&
                                                                            curentUser['vaitro'] !=
                                                                                null &&
                                                                            curentUser['vaitro']['level'] >=
                                                                                2)
                                                                    ? widget.xoa
                                                                        ? Tooltip(
                                                                            message:
                                                                                "Xóa bài giảng",
                                                                            child: IconButton(
                                                                                splashRadius: 1,
                                                                                onPressed: () {
                                                                                  showDialog(
                                                                                    context: context,
                                                                                    builder: (BuildContext context) => XacNhanXoa(
                                                                                      function: () async {
                                                                                        await deleteCTDT(listCTDT['content'][i]['id']);
                                                                                        showToast(
                                                                                          context: context,
                                                                                          msg: titleLog,
                                                                                          color: titleLog == "Xóa thành công." ? Color.fromARGB(136, 72, 238, 67) : Colors.red,
                                                                                          icon: titleLog == "Xóa thành công." ? Icon(Icons.done) : Icon(Icons.warning),
                                                                                        );
                                                                                        widget.function!();
                                                                                        getListBG = await getListCTDT();
                                                                                      },
                                                                                    ),
                                                                                  );
                                                                                },
                                                                                icon: Icon(
                                                                                  Icons.delete_outline,
                                                                                  color: Colors.red,
                                                                                ),
                                                                                iconSize: 26),
                                                                          )
                                                                        : Container()
                                                                    : Container(),
                                                              )
                                                            ],
                                                          ),
                                                        ],
                                                      ))
                                                ])
                                            else
                                              TableRow(children: [
                                                Container(
                                                  // color: i % 2 == 0
                                                  //     ? Color(0xF2F2F2)
                                                  //     : Colors.white,
                                                  padding:
                                                      const EdgeInsets.all(15),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                75, 0, 75, 0),
                                                        child: Text(
                                                          "Không có bài giảng nào!",
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xff000000),
                                                              fontSize: 16,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ])
                                          ]),
                                    ),
                                    // Expanded(
                                    //   child: Container(),
                                    //   flex: 1,
                                    // )
                                  ],
                                ),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Text('${snapshot.error}');
                          }

                          // By default, show a loading spinner.
                          return Center(
                              child: const CircularProgressIndicator());
                        },
                      )
                    : Container(),
              ],
            )),
      ],
    );
  }
}

// ignore: must_be_immutable
class XacNhanXoa extends StatefulWidget {
  Function function;
  XacNhanXoa({Key? key, required this.function}) : super(key: key);
  @override
  State<XacNhanXoa> createState() => _XacNhanXoaState();
}

class _XacNhanXoaState extends State<XacNhanXoa> {
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
                Text(
                  'Xác nhận xóa chương trình đào tạo',
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
            Text(
              'Bạn có chắc chắn muốn xóa chương trình đào tạo không?',
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
            widget.function();
            Navigator.pop(context);
          },
          child: Text(
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
