import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/toast.dart';
import 'package:gentelella_flutter/widgets/ui/trung_tam_dao_tao/quyetdinh_xuphat/them_daotao_xuphat.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../api.dart';
import '../../../../common/format_date.dart';
import '../../../../common/style.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/model.dart';
import '../../../utils/market_development.dart';

class LichSuDaoTaoXuPhat extends StatefulWidget {
  const LichSuDaoTaoXuPhat({Key? key}) : super(key: key);

  @override
  State<LichSuDaoTaoXuPhat> createState() => _LichSuDaoTaoXuPhatState();
}

class _LichSuDaoTaoXuPhatState extends State<LichSuDaoTaoXuPhat> {
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

  late List<daoTaoXuPhat> listQuyetdinhxuphat = [];
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
  TextEditingController title = TextEditingController();

  Future getLichSuPhat(page, String findSearch, {dateTo, dateFrom}) async {
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }
    if (page < 1) {
      page = 0;
    }
    String condition = "";
    if (dateFrom != null && dateFrom != "") {
      condition += " decisionDate >:'${dateFrom!}'";
    }
    if (dateTo != null && dateTo != "") {
      condition += " AND decisionDate <:'${dateTo!}'";
    }
    var response;
    if (findSearch == "") {
      response = await httpGet(
          "/api/daotao-xuphat/get/page?page=$page&size=$rowPerPage&sort=createdDate,desc&filter=$condition",
          context);
    } else {
      response = await httpGet(
          "/api/daotao-xuphat/get/page?page=$page&size=$rowPerPage&sort=createdDate,desc&filter=title~*'$findSearch'*",
          context);
    }

    if (response.containsKey("body")) {
      setState(() {
        currentPage = page;
        resultLSP = jsonDecode(response["body"]);
        print(resultLSP);
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
        "/api/daotao/get/page?sort=id&filter=parentId:$paremtId and deleted: false",
        context);
    if (response1.containsKey("body")) {
      var resultQuyDinh = jsonDecode(response1["body"]);
      setState(() {
        for (var item in resultQuyDinh['content']) {
          QuyDinh1 e = new QuyDinh1(
              id: item['id'],
              name: item['ruleName'],
              parentId: item['parentId']);
          quydinh.add(e);
        }
        QuyDinh1 e = QuyDinh1(id: 0, name: "");
        quydinh.insert(0, e);
      });
      //return quydinh;
    }
    return quydinh;
  }

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
                const SelectableText("Số dòng trên trang: "),
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
                              SelectableText(
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
                                TextFieldValidated(
                                  type: 'Null',
                                  height: 40,
                                  controller: title,
                                  label: 'Tiêu đề',
                                  flexLable: 3,
                                  flexTextField: 7,
                                  enter: () {
                                    findSearch = title.text;
                                    getLichSuPhat(0, findSearch,
                                        dateFrom: dateFrom, dateTo: dateTo);
                                  },
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
                                      label: SelectableText(
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
                                      label: SelectableText(
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
                                      findSearch = title.text;
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
                          SelectableText(
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
                                  label: SelectableText(
                                "STT",
                                style: titleTableData,
                              )),
                              DataColumn(
                                  label: SelectableText(
                                "Tiêu đề",
                                style: titleTableData,
                              )),
                              DataColumn(
                                  label: SelectableText(
                                "Ngày gửi quyết định",
                                style: titleTableData,
                              )),
                              DataColumn(
                                  label: SelectableText(
                                "Thông tin \n liên quan",
                                style: titleTableData,
                              )),
                              DataColumn(
                                  label: SelectableText(
                                "Thực hiện",
                                style: titleTableData,
                              )),
                              DataColumn(
                                  label: SelectableText(
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
                                    DataCell(SelectableText(
                                      '${tableIndex + i}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400),
                                    )),
                                    DataCell(SelectableText(
                                      (resultLSP["content"][i]["title"] ??
                                          "no data"),
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400),
                                    )),
                                    DataCell(SelectableText(
                                      (resultLSP["content"][i]
                                                  ["sentAcctDate"]) !=
                                              null
                                          ? DateFormat('dd-MM-yyyy').format(
                                              DateTime.parse(
                                                  resultLSP["content"][i]
                                                      ["sentAcctDate"]))
                                          : " ",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400),
                                    )),
                                    DataCell(TextButton(
                                      child: SelectableText(
                                        (resultLSP["content"][i]
                                                    ["relateFile"]) !=
                                                null
                                            ? resultLSP["content"][i]
                                                ["relateFile"]
                                            : " ",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      onPressed: () {
                                        downloadFile(resultLSP["content"][i]
                                            ["relateFile"]);
                                      },
                                    )),
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
                                                                "/chi-tiet-lich-su-phat-dao-tao" +
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
                                                                "finesApproval"] ==
                                                            0)
                                                          navigationModel.add(
                                                              pageUrl:
                                                                  "/cap-nhat-dao-tao-xu-phat" +
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
                                      (resultLSP["content"][i]["treatment"] ==
                                              1)
                                          ? (resultLSP["content"][i]
                                                      ["approver"] ==
                                                  null)
                                              ? Consumer2<NavigationModel,
                                                      SecurityModel>(
                                                  builder: (context,
                                                          navigationModel,
                                                          user,
                                                          child) =>
                                                      Container(
                                                        width: 150,
                                                        child: TextButton(
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
                                                                        10.0,
                                                                    letterSpacing:
                                                                        2.0),
                                                          ),
                                                          onPressed: () async {
                                                            putNgayGuiQuyetDinhXuPhat() async {
                                                              resultLSP["content"]
                                                                          [i][
                                                                      'approver'] =
                                                                  user.userLoginCurren[
                                                                      "id"];
                                                              await httpPut(
                                                                  "/api/daotao-xuphat/put/${resultLSP["content"][i]["id"]}",
                                                                  resultLSP[
                                                                      "content"][i],
                                                                  context);
                                                            }

                                                            await putNgayGuiQuyetDinhXuPhat();

                                                            showToast(
                                                                context:
                                                                    context,
                                                                msg:
                                                                    'Gửi quyết định thành công',
                                                                color: Colors
                                                                    .green,
                                                                icon: Icon(Icons
                                                                    .done));
                                                            futureListLichSuPhat =
                                                                getLichSuPhat(
                                                                    currentPage,
                                                                    findSearch);
                                                          },
                                                          child: Text('Duyệt',
                                                              style:
                                                                  textButton),
                                                        ),
                                                      ))
                                              : ((resultLSP["content"][i]
                                                          ["sentAcctDate"] !=
                                                      null)
                                                  ? Container(
                                                      width: 150,
                                                      child: TextButton(
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
                                                              Color.fromARGB(
                                                                  255,
                                                                  110,
                                                                  110,
                                                                  110),
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
                                                        onPressed: () async {},
                                                        child: Container(
                                                            child: Text(
                                                                'Đã gửi quyết định',
                                                                style:
                                                                    textButton)),
                                                      ),
                                                    )
                                                  : Container(
                                                      width: 150,
                                                      child: TextButton(
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
                                                                      10.0,
                                                                  letterSpacing:
                                                                      2.0),
                                                        ),
                                                        onPressed: () async {
                                                          putNgayGuiQuyetDinhXuPhat() async {
                                                            resultLSP["content"]
                                                                        [i][
                                                                    'sentAcctDate'] =
                                                                FormatDate
                                                                    .formatDateInsertDB(
                                                                        DateTime
                                                                            .now());
                                                            await httpPut(
                                                                "/api/daotao-xuphat/put/${resultLSP["content"][i]["id"]}",
                                                                resultLSP[
                                                                    "content"][i],
                                                                context);
                                                          }

                                                          await putNgayGuiQuyetDinhXuPhat();

                                                          showToast(
                                                              context: context,
                                                              msg:
                                                                  'Gửi quyết định thành công',
                                                              color:
                                                                  Colors.green,
                                                              icon: Icon(
                                                                  Icons.done));
                                                          futureListLichSuPhat =
                                                              getLichSuPhat(
                                                                  currentPage,
                                                                  findSearch);
                                                        },
                                                        child: Text(
                                                            'Gửi kế toán',
                                                            style: textButton),
                                                      ),
                                                    ))
                                          : Container(),
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
                Footer()
              ]),
            ),
          );
        } else if (snapshot.hasError) {
          return SelectableText('${snapshot.error}');
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
