import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/style.dart';
import 'package:gentelella_flutter/widgets/ui/navigation.dart';
import 'package:provider/provider.dart';
import '../../../../api.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/model.dart';

class ChiTietQuyDinhDaoTao extends StatefulWidget {
  final String idQuyDinh;

  ChiTietQuyDinhDaoTao({Key? key, required this.idQuyDinh}) : super(key: key);

  @override
  State<ChiTietQuyDinhDaoTao> createState() => _ChiTietQuyDinhDaoTaoState();
}

class _ChiTietQuyDinhDaoTaoState extends State<ChiTietQuyDinhDaoTao> {
  var listQuyDinh = {};
  var listQuyDinh1 = {};
  final String urlAddNewUpdate2 = "/cap-nhat-dao-tao-quy-dinh";
  late Future futureListQuyDinh;
  late Future futureListQuyDinh1;
  Future getQuyDinh1() async {
    var response = await httpGet("/api/daotao-quydinh/get/${widget.idQuyDinh}", context);
    if (response.containsKey("body")) {
      listQuyDinh1 = jsonDecode(response["body"]);
      setState(() {});
    }

    return listQuyDinh1;
  }

  Future getQuyDinh() async {
    var response = await httpGet("/api/daotao-quydinh-chitiet/get/page?filter=eduRuleId :${widget.idQuyDinh}", context);
    if (response.containsKey("body")) {
      listQuyDinh = jsonDecode(response["body"]);
      setState(() {});
    }

    return listQuyDinh;
  }

  var listQuyDinh2 = {};
  var listQDCha = {};
  Future getQuyDinh2() async {
    print(widget.idQuyDinh.toString());
    var response = await httpGet("/api/daotao-quydinh/get/${widget.idQuyDinh}", context);
    if (response.containsKey("body")) {
      listQuyDinh2 = jsonDecode(response["body"]);
      setState(() {});
    }
    // for (int i = 0; i < listQuyDinh2['content'].length; i++) {
    if (listQuyDinh2['parentId'] != 0) {
      print("khách 0");
      var response1 = await httpGet("/api/daotao-quydinh/get/${listQuyDinh2['parentId']}", context);
      print(listQuyDinh2['parentId'].toString());
      print(response1["id"]);
      if (response1.containsKey("body")) {
        print("diep");

        setState(() {
          listQDCha = jsonDecode(response1["body"]);
        });
      }
      print(listQDCha);
      print("diep");
    } else {
      print("bằng 0");
      setState(() {
        listQDCha = {};
      });
      // }
    }

    return listQDCha;
  }

  callApi() async {
    await getQuyDinh2();
    await getQuyDinh1();
  }

  @override
  void initState() {
    futureListQuyDinh = getQuyDinh();
    // futureListQuyDinh1 = getQuyDinh1();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationModel>(
      builder: (context, navigationModel, child) => HeaderAndNavigation(
        widgetBody: Material(
          child: ListView(
            children: [
              Column(
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
                                {'url': "/bang-thong-ke-nhanh", 'title': 'Dashboard'},
                                {'url': "/quy-dinh-dao-tao", 'title': 'Thông tin các quy định'},
                              ],
                              content: 'Thêm mới',
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                  Container(
                      color: backgroundPage,
                      padding: EdgeInsets.symmetric(vertical: verticalPaddingPage, horizontal: horizontalPaddingPage),
                      child: Column(children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * 1,
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
                                  Row(
                                    children: [
                                      SelectableText(
                                        '',
                                        style: titleBox,
                                      ),
                                      Container(
                                        width: 100,
                                      ),

                                      // SelectableText(
                                      //   listQDCha["name"] ?? listQuyDinh2["name"],
                                      //   style: titleWidgetBox,
                                      // )

                                      // By default, show a loading spinner.
                                    ],
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
                              FutureBuilder(
                                future: futureListQuyDinh,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Row(
                                      children: [
                                        Expanded(
                                            child: DataTable(
                                          columns: <DataColumn>[
                                            DataColumn(label: SelectableText("Nội dung vi phạm", style: titleTableData)),
                                            DataColumn(label: SelectableText("Nội dung phạt", style: titleTableData)),
                                            DataColumn(label: SelectableText("Thao tác", style: titleTableData)),
                                          ],
                                          rows: <DataRow>[
                                            for (int i = 0; i < listQuyDinh["content"].length; i++)
                                              DataRow(cells: [
                                                DataCell(SelectableText(
                                                    (listQuyDinh["content"][i]["times"] == 0)
                                                        ? listQuyDinh["content"][i]["quydinh"]["name"] ?? "no data"
                                                        : listQuyDinh["content"][i]["quydinh"]["name"] +
                                                                " lần ${listQuyDinh["content"][i]["times"]}" ??
                                                            "no data",
                                                    style: bangDuLieu)),
                                                DataCell(SelectableText(listQuyDinh["content"][i]["content"], style: bangDuLieu)),
                                                DataCell(Row(children: [
                                                  Container(
                                                    height: 40.0,
                                                    child: Center(
                                                        child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Container(
                                                            margin: EdgeInsets.fromLTRB(15, 0, 10, 0),
                                                            child: InkWell(
                                                                onTap: () {
                                                                  navigationModel.add(pageUrl: "$urlAddNewUpdate2/${widget.idQuyDinh}");
                                                                },
                                                                child: Icon(Icons.edit_calendar, color: Color(0xff009C87)))),
                                                      ],
                                                    )),
                                                  ),
                                                ]))
                                              ])
                                          ],
                                        )),
                                      ],
                                    );
                                  } else if (snapshot.hasError) {
                                    return SelectableText('${snapshot.error}');
                                  }
                                  // By default, show a loading spinner.
                                  return const CircularProgressIndicator();
                                },
                              )
                            ],
                          ),
                        ),
                      ])),
                ],
              ),
              Footer(),
            ],
          ),
        ),
      ),
    );
  }
}
