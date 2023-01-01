import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/toast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../api.dart';
import '../../../../common/style.dart';
import '../../../../model/model.dart';
import '../../../utils/market_development.dart';
import '../setting-data/quydinh.dart';
import '../setting-data/quyetdinhxuphat.dart';

class LSPhat extends StatefulWidget {
  const LSPhat({Key? key}) : super(key: key);

  @override
  State<LSPhat> createState() => _LSPhatState();
}

class _LSPhatState extends State<LSPhat> {
  String getDateViewDayAndHour(String? date) {
    try {
      if (date == null) {
        return "Không có dữ liệu";
      }
      var inputFormat = DateFormat('yyyy-MM-ddThh:mm:ss');
      var inputDate = inputFormat.parse(date); // <-- dd/MM 24H format
      var outputFormat = DateFormat('HH:mm dd/MM/yyyy');
      var outputDate = outputFormat.format(inputDate);
      return outputDate;
    } catch (e) {}
    return "Không có dữ liệu";
  }

  late List<Quyetdinhxuphat> listQuyetdinhxuphat = [];
  var time1;
  var time2;
  late Future futureListLichSuPhat;
  var totalElements = 0;
  var firstRow = 0;
  var rowPerPage = 10;
  var currentPage = 0;
  String? dateFrom;
  String? dateTo;
  var resultLSP = {};
  Widget paging = Container();
  bool flag = true;
  String findSearch = "";

  Future getLichSuPhat(page, String findSearch, {dateTo, dateFrom}) async {
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }
    if (page < 1) {
      page = 0;
    }
    String condition = "";
    if (dateFrom != null && dateFrom != "") {
      condition += "and decisionDate >:'${dateFrom!}'";
    }
    if (dateTo != null && dateTo != "") {
      condition += " AND decisionDate <:'${dateTo!}'";
    }
    var response;
    if (findSearch == "") {
      response = await httpGet(
          "/api/quyetdinh-xuphat/get/page?page=$page&size=$rowPerPage&sort=createdDate,desc&filter=$condition",
          context);
    } else {
      response = await httpGet(
          "/api/quyetdinh-xuphat/get/page?page=$page&size=$rowPerPage&sort=createdDate,desc&filter=$findSearch $condition",
          context);
      print(
          "/api/quyetdinh-xuphat/get/page?page=$page&size=$rowPerPage&sort=createdDate,desc&filter=$findSearch and $condition");
    }
    // print("quangg");
    // print(findSearch);
    if (response.containsKey("body")) {
      setState(() {
        // print("quangg1");
        // print(response);
        currentPage = page;
        resultLSP = jsonDecode(response["body"]);
        totalElements = resultLSP["totalElements"];
      });
    }
    return resultLSP;
  }

  int quyDinhCha = 0;
  int? selectTQD;
  //quy định cha
  Future<List<QuyDinh1>> getQuyDinh(int paremtId) async {
    List<QuyDinh1> quydinh = [];
    var response1;
    response1 = await httpGet(
        "/api/quydinh/get/page?sort=id&filter=parentId:$paremtId and deleted: false",
        context);
    if (response1.containsKey("body")) {
      var resultQuyDinh = jsonDecode(response1["body"]);
      setState(() {
        for (var item in resultQuyDinh['content']) {
          QuyDinh1 e = new QuyDinh1(
              id: item['id'],
              ruleName: item['ruleName'],
              parentId: item['parentId']);
          quydinh.add(e);
        }
        QuyDinh1 e = QuyDinh1(id: 0, ruleName: "");
        quydinh.insert(0, e);
      });
      //return quydinh;
    }
    return quydinh;
  }

  // postQuyetDinhXuPhatCT(List<Quyetdinhxuphat> listQuyetdinhxuphat) async {
  //   for (var item in listQuyetdinhxuphat) {
  //     var requestBody;
  //     if (item.option == 0) {
  //       requestBody = {
  //         "decisionId": resultNextID,
  //         "userId": item.tts!.id,
  //         "ruleDetailId": item.quyDinhcon!.id,
  //         "finesTotal": item.quyDinhcon!.fines,
  //         "reason": item.quyDinhcon!.reason,
  //         // "violateDate": null
  //       };
  //     } else {
  //       requestBody = {
  //         "decisionId": resultNextID,
  //         "dutyId": item.vatro!.id,
  //         "userId": item.userAAM!.id,
  //         "ruleDetailId": item.quyDinhcon!.id,
  //         "finesTotal": item.quyDinhcon!.fines,
  //         "reason": item.quyDinhcon!.reason
  //         // "violateDate": null
  //       };
  //     }
  //     await httpPost("/api/quyetdinh-xuphat-chitiet/post/save", requestBody, context);
  //     print(requestBody);
  //   }
  // }

  @override
  void initState() {
    futureListLichSuPhat = getLichSuPhat(currentPage, findSearch);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureListLichSuPhat,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var tableIndex = (currentPage) * rowPerPage + 1;
          if (resultLSP["content"].length > 0) {
            var firstRow = (currentPage) * rowPerPage + 1;
            var lastRow = (currentPage + 1) * rowPerPage;
            if (lastRow > resultLSP["totalElements"]) {
              lastRow = resultLSP["totalElements"];
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
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (int? newValue) {
                    setState(() {
                      rowPerPage = newValue!;
                      getLichSuPhat(currentPage, findSearch);
                    });
                  },
                  items: <int>[2, 5, 10, 25, 50, 100]
                      .map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text("$value"),
                    );
                  }).toList(),
                ),
                Text(
                    "Dòng $firstRow - $lastRow của ${resultLSP["totalElements"]}"),
                IconButton(
                    onPressed: firstRow != 1
                        ? () {
                            getLichSuPhat(currentPage - 1, findSearch);
                          }
                        : null,
                    icon: const Icon(Icons.chevron_left)),
                IconButton(
                    onPressed: lastRow < resultLSP["totalElements"]
                        ? () {
                            getLichSuPhat(currentPage + 1, findSearch);
                          }
                        : null,
                    icon: const Icon(Icons.chevron_right)),
              ],
            );
          }

          return Consumer<NavigationModel>(
            builder: (context, navigationModel, child) => Scaffold(
              body: ListView(controller: ScrollController(), children: [
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
                              Text(
                                'Chọn thông tin',
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
                            padding: const EdgeInsets.fromLTRB(50, 20, 0, 0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text('Tên quy định',
                                              style: titleWidgetBox),
                                        ),
                                        Expanded(
                                            flex: 5,
                                            child: Container(
                                              color: Colors.white,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.20,
                                              height: 40,
                                              child: DropdownSearch<QuyDinh1>(
                                                maxHeight: 350,
                                                mode: Mode.MENU,
                                                showSearchBox: true,
                                                onFind: (String? filter) =>
                                                    getQuyDinh(0),
                                                itemAsString: (QuyDinh1? u) =>
                                                    "${u!.ruleName}",
                                                dropdownSearchDecoration:
                                                    styleDropDown,
                                                onChanged: (value) async {
                                                  setState(() {
                                                    quyDinhCha = value!.id;
                                                    selectTQD = value.id;
                                                    // print('1');
                                                    // print(selectTQD);
                                                    // print('2');
                                                    // print(quyDinhCha);
                                                    // resultPhongBan = [Depart(departName: '', id: -1)];
                                                    // if (value.id == 0) {
                                                    //   for (var item in listQuyetdinhxuphat) {
                                                    //     item.quyDinhcon!.id = 0;
                                                    //     item.quyDinhcon!.ruleName = "";
                                                    //   }
                                                    // }
                                                  });
                                                },
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 100),
                                Expanded(flex: 5, child: Container()),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(50, 30, 0, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: DatePickerBoxCustomForMarkert(
                                      isTime: false,
                                      title: "Từ ngày",
                                      isBlocDate: false,
                                      isNotFeatureDate: true,
                                      label: Text(
                                        'Từ ngày',
                                        style: titleWidgetBox,
                                      ),
                                      dateDisplay: dateFrom,
                                      selectedDateFunction: (day) {
                                        setState(() {
                                          dateFrom = day;
                                        });
                                      }),
                                ),
                                SizedBox(width: 100),
                                Expanded(
                                  flex: 3,
                                  child: DatePickerBoxCustomForMarkert(
                                      isTime: false,
                                      title: "Đến ngày",
                                      isBlocDate: false,
                                      isNotFeatureDate: true,
                                      label: Text(
                                        'Đến ngày',
                                        style: titleWidgetBox,
                                      ),
                                      dateDisplay: dateTo,
                                      selectedDateFunction: (day) {
                                        setState(() {
                                          dateTo = day;
                                        });
                                      }),
                                ),
                                Expanded(flex: 2, child: Container()),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(50, 50, 20, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  height: 40,
                                  margin: EdgeInsets.only(left: 20),
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 15.0,
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
                                      findSearch = "";
                                      var tenQD;
                                      if (selectTQD != 0 && selectTQD != null) {
                                        tenQD = "ruleId:$selectTQD";
                                      } else {
                                        tenQD = "";
                                      }
                                      findSearch = tenQD;
                                      getLichSuPhat(0, findSearch,
                                          dateFrom: dateFrom, dateTo: dateTo);
                                      setState(() {});
                                    },
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(right: 10),
                                          child: Icon(
                                            Icons.search,
                                            color: Colors.white,
                                            size: 15,
                                          ),
                                        ),
                                        Text('Tìm kiếm', style: textButton),
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
                Container(
                  width: MediaQuery.of(context).size.width * 1,
                  margin: marginTopLeftRightContainer,
                  decoration: BoxDecoration(
                    color: colorWhite,
                    borderRadius: borderRadiusContainer,
                    boxShadow: [boxShadowContainer],
                    border: borderAllContainerBox,
                  ),
                  padding: paddingBoxContainer,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Thông tin lịch sử vi phạm ',
                            style: titleBox,
                          ),
                          Icon(
                            Icons.more_horiz,
                            color: colorIconTitleBox,
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
                              child: DataTable(
                            columns: <DataColumn>[
                              DataColumn(
                                  label: Text(
                                "STT",
                                style: titleTableData,
                              )),
                              DataColumn(
                                  label: Text(
                                "Tên quy định",
                                style: titleTableData,
                              )),
                              DataColumn(
                                  label: Text(
                                "Ngày gửi quyết định",
                                style: titleTableData,
                              )),
                              DataColumn(
                                  label: Text(
                                "Thông tin \n liên quan",
                                style: titleTableData,
                              )),
                              DataColumn(
                                  label: Text(
                                "Thực hiện",
                                style: titleTableData,
                              )),
                              DataColumn(
                                  label: Text(
                                " ",
                                style: titleTableData,
                              ))
                            ],
                            rows: <DataRow>[
                              for (int i = 0;
                                  i < resultLSP["content"].length;
                                  i++)
                                DataRow(
                                  cells: [
                                    DataCell(Text(
                                      '${tableIndex + i}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400),
                                    )),
                                    DataCell(Text(
                                      (resultLSP["content"][i]["quydinh"]
                                              ["ruleName"] ??
                                          ""),
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400),
                                    )),
                                    DataCell(Text(
                                      (resultLSP["content"][i]
                                                  ["decisionDate"]) !=
                                              null
                                          ? DateFormat('dd-MM-yyyy').format(
                                              DateTime.parse(
                                                  resultLSP["content"][i]
                                                      ["decisionDate"]))
                                          : " ",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400),
                                    )),
                                    DataCell((resultLSP["content"][i]
                                                ["relateFile"]) !=
                                            null
                                        ? TextButton(
                                            child: Text(
                                              resultLSP["content"][i]
                                                  ["relateFile"],
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                            onPressed: () {
                                              downloadFile(resultLSP["content"]
                                                  [i]["relateFile"]);
                                            },
                                          )
                                        : Container()),
                                    DataCell(Row(
                                      children: [
                                        Consumer<NavigationModel>(
                                          builder: (context, navigationModel,
                                                  child) =>
                                              Container(
                                                  margin: EdgeInsets.fromLTRB(
                                                      0, 0, 10, 0),
                                                  child: InkWell(
                                                      onTap: () {
                                                        navigationModel.add(
                                                            pageUrl:
                                                                "/chi-tiet-lich-su-phat" +
                                                                    "/${resultLSP["content"][i]["id"]}");
                                                      },
                                                      child: Icon(
                                                          Icons.visibility))),
                                        ),
                                        Consumer<NavigationModel>(
                                          builder: (context, navigationModel,
                                                  child) =>
                                              Container(
                                                  margin: EdgeInsets.fromLTRB(
                                                      10, 0, 10, 0),
                                                  child: InkWell(
                                                      onTap: () {
                                                        if (resultLSP["content"]
                                                                    [i][
                                                                "decisionDate"] ==
                                                            null)
                                                          navigationModel.add(
                                                              pageUrl:
                                                                  "/cap-nhat-qdxp" +
                                                                      "/${resultLSP["content"][i]["id"]}");
                                                        else
                                                          showToast(
                                                              context: context,
                                                              msg:
                                                                  "Quyết định đã gửi không được sửa",
                                                              color: Colors.red,
                                                              icon: Icon(Icons
                                                                  .warning));
                                                      },
                                                      child: Icon(
                                                          Icons.edit_calendar,
                                                          color: Color(
                                                              0xff009C87)))),
                                        ),
                                      ],
                                    )),
                                    DataCell(
                                      (resultLSP["content"][i]
                                                  ["decisionDate"] ==
                                              null)
                                          ? Container(
                                              width: 150,
                                              child: TextButton(
                                                style: TextButton.styleFrom(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 20.0,
                                                    horizontal: 10.0,
                                                  ),
                                                  shape: RoundedRectangleBorder(
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
                                                          fontSize: 10.0,
                                                          letterSpacing: 2.0),
                                                ),
                                                onPressed: () async {
                                                  putNgayGuiQuyetDinhXuPhat() async {
                                                    var requestBody = {
                                                      "decisionDate":
                                                          DateFormat(
                                                                  'yyyy-MM-dd')
                                                              .format(DateTime
                                                                  .now())
                                                    };
                                                    print(requestBody);
                                                    await httpPut(
                                                        "/api/quyetdinh-xuphat/put/${resultLSP["content"][i]["id"]}",
                                                        requestBody,
                                                        context);
                                                  }

                                                  await putNgayGuiQuyetDinhXuPhat();
                                                  addNotification() async {
                                                    try {
                                                      var data = {
                                                        "title":
                                                            "Kiểm soát thông báo",
                                                        "message": 'Đơn hàng có mã' +
                                                            '${resultLSP["content"][i]["quydinh"]["ruleName"]}' +
                                                            ' đã dừng xử lý lúc lúc ${getDateViewDayAndHour(resultLSP["content"][i]["createdDate"])}.',
                                                      };
                                                      await httpPost(
                                                          '/api/push/tags/depart_id/2&9',
                                                          data,
                                                          context);
                                                    } catch (_) {
                                                      print("Fail!");
                                                    }
                                                  }

                                                  await addNotification();

                                                  futureListLichSuPhat =
                                                      getLichSuPhat(currentPage,
                                                          findSearch);
                                                  showToast(
                                                      context: context,
                                                      msg:
                                                          'Gửi quyết định thành công',
                                                      color: Colors.green,
                                                      icon: Icon(Icons.done));
                                                },
                                                child: Text('Gửi quyết định',
                                                    style: textButton),
                                              ),
                                            )
                                          : Container(
                                              width: 150,
                                              child: TextButton(
                                                style: TextButton.styleFrom(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 20.0,
                                                    horizontal: 10.0,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                  ),
                                                  backgroundColor:
                                                      Color.fromARGB(
                                                          255, 110, 110, 110),
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
                                                onPressed: () async {},
                                                child: Container(
                                                    child: Text(
                                                        'Đã gửi quyết định',
                                                        style: textButton)),
                                              ),
                                            ),
                                    )

                                    //
                                  ],
                                ),
                            ],
                          )),
                        ],
                      ),
                      paging
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 30, left: 30, right: 30),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('no copyright'),
                    ],
                  ),
                ),
              ]),
            ),
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
