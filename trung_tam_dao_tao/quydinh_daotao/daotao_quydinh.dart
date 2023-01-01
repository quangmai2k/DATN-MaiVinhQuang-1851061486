import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/navigation.dart';
import 'package:provider/provider.dart';

import '../../../../api.dart';
import '../../../../common/style.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/model.dart';

BuildContext? contexts;

class QuyDinhDaoTao extends StatefulWidget {
  const QuyDinhDaoTao({Key? key}) : super(key: key);

  @override
  State<QuyDinhDaoTao> createState() => _QuyDinhDaoTaoState();
}

class _QuyDinhDaoTaoState extends State<QuyDinhDaoTao> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: QuyDinhDaoTaoBody());
  }
}

class QuyDinhDaoTaoBody extends StatefulWidget {
  const QuyDinhDaoTaoBody({Key? key}) : super(key: key);

  @override
  State<QuyDinhDaoTaoBody> createState() => _QuyDinhDaoTaoBodyState();
}

class _QuyDinhDaoTaoBodyState extends State<QuyDinhDaoTaoBody> {
  final String urlAddNewUpdate1 = "/them-moi-quy-dinh-dao-tao";
  final String urlAddNewUpdate2 = "/cap-nhat-quy-dinh-dao-tao";
  final String urlTTQDinh = "/chi-tiet-quy-dinh-dao-tao";
  TextEditingController tenTTS = TextEditingController();
  final TextEditingController _tenQD = TextEditingController();
  final TextEditingController _noiDungVP = TextEditingController();
  String findSearch = "";
  String? request;
  var totalElements = 0;
  var firstRow = 0;
  var rowPerPage = 10;
  late Future futureListQuyDinh;
  var currentPage = 0;
  var resultQuyDinh = {};

  Widget paging = Container();

  @override
  void initState() {
    super.initState();
    futureListQuyDinh = getQuyDinh(currentPage, findSearch);
  }

  Future getQuyDinh(page, String findSearch) async {
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
      print(page);
    }

    if (page < 1) {
      page = 0;
    }
    var response;
    if (findSearch == "") {
      response = await httpGet(
          "/api/daotao-quydinh/get/page?page=$page&size=$rowPerPage&sort=id",
          context);
    } else {
      response = await httpGet(
          "/api/daotao-quydinh/get/page?page=$page&size=$rowPerPage&sort=id&filter=$findSearch",
          context);
    }
    if (response.containsKey("body")) {
      setState(() {
        currentPage = page;

        resultQuyDinh = jsonDecode(response["body"]);

        totalElements = resultQuyDinh["totalElements"];
      });
    }
    return resultQuyDinh;
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      contexts = context;
    });

    return FutureBuilder(
      future: futureListQuyDinh,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var tableIndex = (currentPage) * rowPerPage + 1;
          if (resultQuyDinh["content"].length > 0) {
            var firstRow = (currentPage) * rowPerPage + 1;
            var lastRow = (currentPage + 1) * rowPerPage;
            if (lastRow > resultQuyDinh["totalElements"]) {
              lastRow = resultQuyDinh["totalElements"];
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
                      getQuyDinh(currentPage, findSearch);
                    });
                  },
                  items: <int>[5, 10, 25, 50, 100]
                      .map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: SelectableText("$value"),
                    );
                  }).toList(),
                ),
                SelectableText(
                    "Dòng $firstRow - $lastRow của ${resultQuyDinh["totalElements"]}"),
                IconButton(
                    onPressed: firstRow != 1
                        ? () {
                            getQuyDinh(currentPage - 1, findSearch);
                            print(currentPage - 1);
                          }
                        : null,
                    icon: const Icon(Icons.chevron_left)),
                IconButton(
                    onPressed: lastRow < resultQuyDinh["totalElements"]
                        ? () {
                            getQuyDinh(currentPage + 1, findSearch);
                            print(currentPage + 1);
                          }
                        : null,
                    icon: const Icon(Icons.chevron_right)),
              ],
            );
          }

          return Consumer<NavigationModel>(
            builder: (context, navigationModel, child) => Scaffold(
              body: ListView(children: [
                TitlePage(
                  listPreTitle: [
                    {'url': '/bang-thong-ke-nhanh', 'title': 'Dashboard'},
                  ],
                  content: "Thông tin các quy định",
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
                          Padding(
                            padding: const EdgeInsets.fromLTRB(50, 30, 0, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: SelectableText('Tên quy định',
                                              style: titleWidgetBox),
                                        ),
                                        Expanded(
                                          flex: 5,
                                          child: Container(
                                            child: TextField(
                                              controller: _tenQD,
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
                                SizedBox(width: 200),
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: SelectableText(
                                              'Nội dung vi phạm',
                                              style: titleWidgetBox),
                                        ),
                                        Expanded(
                                          flex: 5,
                                          child: Container(
                                            child: TextField(
                                              controller: _noiDungVP,
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
                                      var noiDungVP;
                                      if (_tenQD.text != "")
                                        tenQD = "and name~'*${_tenQD.text}*' ";
                                      else
                                        tenQD = "";
                                      if (_noiDungVP.text != "")
                                        noiDungVP =
                                            "and name~'*${_noiDungVP.text}*' ";
                                      else
                                        noiDungVP = "";

                                      findSearch = tenQD + noiDungVP;
                                      if (findSearch != "") {
                                        if (findSearch.substring(0, 3) == "and")
                                          findSearch = findSearch.substring(4);

                                        getQuyDinh(0, findSearch);
                                      } else
                                        getQuyDinh(0, findSearch);
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
                                        //const Icon(Icons.near_me, color: Colors.white),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 20),
                                  //width: 110,
                                  height: 40,
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
                                      navigationModel.add(
                                          pageUrl: urlAddNewUpdate1);
                                    },
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(right: 10),
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 15,
                                          ),
                                        ),
                                        Text("Thêm mới", style: textButton)
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
                            'Thông tin quy định',
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
                      Column(
                        children: [
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
                                          "Tên quy đinh/Nội dung vi phạm",
                                          style: titleTableData)),
                                  DataColumn(
                                      label: SelectableText("Thực hiện",
                                          style: titleTableData))
                                ],
                                rows: <DataRow>[
                                  for (int i = 0;
                                      i < resultQuyDinh["content"].length;
                                      i++)
                                    DataRow(
                                      cells: <DataCell>[
                                        DataCell(SelectableText(
                                            "${tableIndex + i}",
                                            style: bangDuLieu)),
                                        DataCell((resultQuyDinh["content"][i]
                                                    ["parentId"] ==
                                                0)
                                            ? SelectableText(
                                                (resultQuyDinh["content"][i]
                                                        ["name"] ??
                                                    "no data"),
                                                style: bangDuLieu)
                                            : Container(
                                                width: MediaQuery.of(context).size.width *
                                                    0.3,
                                                child: Container(
                                                    margin: EdgeInsets.only(
                                                        left: 20),
                                                    child: SelectableText(
                                                        (resultQuyDinh["content"]
                                                            [i]["name"]),
                                                        style: bangDuLieu)))),
                                        DataCell(Row(
                                          children: [
                                            Consumer<NavigationModel>(
                                              builder: (context,
                                                      navigationModel, child) =>
                                                  Container(
                                                      margin:
                                                          EdgeInsets.fromLTRB(
                                                              0, 0, 10, 0),
                                                      child: InkWell(
                                                          onTap: () {
                                                            // idSelected=resultQuyDinh["content"][i]["id"];
                                                            navigationModel.add(
                                                                pageUrl:
                                                                    urlTTQDinh +
                                                                        "/${resultQuyDinh["content"][i]["id"]}");
                                                          },
                                                          child: Icon(Icons
                                                              .visibility))),
                                            ),
                                            Container(
                                                margin: EdgeInsets.fromLTRB(
                                                    10, 0, 10, 0),
                                                child: InkWell(
                                                    onTap: () {
                                                      navigationModel.add(
                                                          pageUrl:
                                                              "$urlAddNewUpdate2/${resultQuyDinh["content"][i]["id"]}");
                                                    },
                                                    child: Icon(
                                                        Icons.edit_calendar,
                                                        color: Color(
                                                            0xff009C87)))),
                                          ],
                                        ))
                                      ],
                                    ),
                                ],
                              )),
                            ],
                          ),
                          if (totalElements != 0)
                            paging
                          else
                            Center(
                                child:
                                    SelectableText("Không có kết quả phù hợp",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ))),
                        ],
                      ),
                    ],
                  ),
                ),

                Footer(),
                //
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
