import 'dart:convert';
import 'package:gentelella_flutter/common/format_date.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../../api.dart';
import '../../../../common/style.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/model.dart';
import '../../navigation.dart';

class ChiTietLSPDaoTao extends StatefulWidget {
  final String idCTLSPhat;
  const ChiTietLSPDaoTao({Key? key, required this.idCTLSPhat})
      : super(key: key);

  @override
  State<ChiTietLSPDaoTao> createState() => _ChiTietLSPDaoTaoState();
}

class _ChiTietLSPDaoTaoState extends State<ChiTietLSPDaoTao> {
  var listVP = [];
  String fileNameExport = "";

  late Future futureListLichSuPhatTTS;
  var resultPhatTTS = {};
  var response1;
  getPhatTTS() async {
    Future.delayed(const Duration(seconds: 5));
    response1 = await httpGet(
        "/api/daotao-xuphat-chitiet/get/page?sort=id&filter=eduDecisionId:${widget.idCTLSPhat}",
        context);
    print(
        "/api/daotao-xuphat-chitiet/get/page?sort=id&filter=decisionId:${widget.idCTLSPhat}");

    if (response1.containsKey('body')) {
      setState(() {
        resultPhatTTS = jsonDecode(response1["body"]);
      });
    }
    return resultPhatTTS;
  }

  late Future futureListLichSuPhatCBTD;
  var resultPhatCBTD = {};
  var response2;

  var truong;
  getData() async {
    await Future.delayed(const Duration(seconds: 5));
    setState(() {
      truong = 100;
    });
  }

  callApi() async {
    await getPhatTTS();
  }

  void initState() {
    super.initState();
    getData();
    callApi();
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
                            TextButton(
                              onPressed: () {},
                              child: SelectableText(
                                'Home',
                                style: TextStyle(color: Color(0xff009C87)),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 5, right: 5),
                              child: SelectableText(
                                '/',
                                style: TextStyle(
                                  color: Color(0xffC8C9CA),
                                ),
                              ),
                            ),
                            TextButton(
                                onPressed: () {},
                                child: SelectableText('Trung tâm đào tạo',
                                    style:
                                        TextStyle(color: Color(0xff009C87)))),
                            Padding(
                              padding: EdgeInsets.only(left: 5, right: 5),
                              child: SelectableText(
                                '/',
                                style: TextStyle(
                                  color: Color(0xffC8C9CA),
                                ),
                              ),
                            ),
                            SelectableText('Chi tiết quyết định xử phạt',
                                style: titlePage),
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
                      padding: EdgeInsets.symmetric(
                          vertical: verticalPaddingPage,
                          horizontal: horizontalPaddingPage),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SelectableText(
                                    'Danh sách phạt TTS',
                                    style: titleBox,
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

                              response1 == null
                                  ? Container()
                                  : Row(
                                      children: [
                                        Expanded(
                                            child: DataTable(
                                          columns: <DataColumn>[
                                            DataColumn(
                                                label: Column(
                                              children: [
                                                SelectableText("STT",
                                                    style: titleTableData),
                                              ],
                                            )),
                                            DataColumn(
                                                label: Column(
                                              children: [
                                                SelectableText("Họ tên TTS",
                                                    style: titleTableData),
                                              ],
                                            )),
                                            DataColumn(
                                                label: Column(
                                              children: [
                                                SelectableText("Ngày vi phạm",
                                                    style: titleTableData),
                                              ],
                                            )),
                                            DataColumn(
                                                label: Column(
                                              children: [
                                                SelectableText("Nội dung phạt",
                                                    style: titleTableData),
                                              ],
                                            )),
                                            DataColumn(
                                                label: Column(
                                              children: [
                                                SelectableText("Mức tiền phạt",
                                                    style: titleTableData),
                                              ],
                                            )),
                                            DataColumn(
                                                label: Column(
                                              children: [
                                                SelectableText("Ghi chú",
                                                    style: titleTableData),
                                              ],
                                            )),
                                          ],
                                          rows: <DataRow>[
                                            for (int i = 0;
                                                i <
                                                    resultPhatTTS['content']
                                                        .length;
                                                i++)
                                              DataRow(cells: [
                                                DataCell(SelectableText(
                                                    '${i + 1}',
                                                    style: bangDuLieu)),
                                                DataCell(SelectableText(
                                                    resultPhatTTS['content'][i]
                                                                ['thuctapsinh']
                                                            ['fullName'] ??
                                                        "",
                                                    style: bangDuLieu)),
                                                DataCell(SelectableText(
                                                    resultPhatTTS['content'][i][
                                                                    'thuctapsinh']
                                                                ['birthDate'] !=
                                                            null
                                                        ? FormatDate.formatDateView(
                                                            DateTime.parse(
                                                                resultPhatTTS[
                                                                        'content'][i]
                                                                    [
                                                                    'violateDate']))
                                                        : '',
                                                    style: bangDuLieu)),
                                                DataCell(SelectableText(
                                                    resultPhatTTS['content'][i]
                                                                ['quydinh'] !=
                                                            null
                                                        ? resultPhatTTS['content'][i]
                                                                            ['quydinh']
                                                                        [
                                                                        'quydinh']
                                                                    ["name"]
                                                                .toString() +
                                                            " lần " +
                                                            resultPhatTTS['content']
                                                                            [i][
                                                                        'quydinh']
                                                                    ['times']
                                                                .toString()
                                                        : 'no data',
                                                    style: bangDuLieu)),
                                                DataCell(SelectableText(
                                                    resultPhatTTS['content'][i]
                                                            ['fines']
                                                        .toString(),
                                                    style: bangDuLieu)),
                                                DataCell(SelectableText(
                                                    resultPhatTTS['content'][i]
                                                        ['note'],
                                                    style: bangDuLieu)),
                                              ])
                                          ],
                                        )),
                                      ],
                                    ),
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
