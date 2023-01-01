import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import '../../../../api.dart';
import '../../../../common/dynamic_table.dart';
import '../../../../common/style.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/model.dart';
import '../../navigation.dart';

class ChiTietKTX extends StatefulWidget {
  final String id;
  const ChiTietKTX({Key? key, required this.id}) : super(key: key);
  @override
  State<ChiTietKTX> createState() => _ChiTietKTXState();
}

class _ChiTietKTXState extends State<ChiTietKTX> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
        widgetBody: ChiTietKTXBody(
      id: widget.id,
    ));
  }
}

class ChiTietKTXBody extends StatefulWidget {
  final String id;

  const ChiTietKTXBody({Key? key, required this.id}) : super(key: key);

  @override
  State<ChiTietKTXBody> createState() => _ChiTietKTXBodyState();
}

late Future<dynamic> getKtxFuture;
late Future<dynamic> getGvFuture;
late Future<dynamic> getCTDTFuture;

class _ChiTietKTXBodyState extends State<ChiTietKTXBody> {
  var kyTucXa;
  Future<dynamic> getKtx() async {
    var response = await httpGet("/api/kytucxa/get/" + widget.id, context);
    if (response.containsKey("body")) {
      kyTucXa = jsonDecode(response["body"]);
      return jsonDecode(response["body"]);
    } else
      throw Exception("Error load data");
  }

  // Future<dynamic> getGV(String id) async {
  //   var response =
  //       await httpGet("/api/nguoidung/get/info?filter=id:$id", context);
  //   if (response.containsKey("body"))
  //     return jsonDecode(response["body"]);
  //   else
  //     throw Exception("Error load data");
  // }

  // getTCDT(String id) async {
  //   var response = await httpGet("/api/daotao-chuongtrinh/get/$id", context);
  //   if (response.containsKey("body"))
  //     return jsonDecode(response["body"]);
  //   else
  //     throw Exception("Error load data");
  // }

  void initState() {
    getKtxFuture = getKtx();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: getKtxFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView(
            children: [
              TitlePage(
                listPreTitle: [
                  {'url': '/bang-thong-ke-nhanh', 'title': 'Dashboard'},
                  {
                    'url': '/quan-ly-ky-tuc-xa',
                    'title': 'Quản lý phòng ký túc xá'
                  }
                ],
                content: 'Chi tiết phòng ký túc xá',
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
                        margin: EdgeInsets.only(top: 20),
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
                                SelectableText(
                                  'Thông tin ký túc xá',
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
                              children: [
                                Expanded(
                                    flex: 5,
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 2,
                                            child: SelectableText(
                                              'Mã phòng',
                                              style: titleWidgetBox,
                                            )),
                                        Expanded(
                                          flex: 7,
                                          child: SelectableText(
                                            kyTucXa['name'],
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                        Expanded(child: Container(), flex: 2),
                                      ],
                                    )),
                                Expanded(
                                    flex: 5,
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 4,
                                            child: SelectableText(
                                              'Số người tối đa trong phòng',
                                              style: titleWidgetBox,
                                            )),
                                        Expanded(
                                            flex: 3,
                                            child: SelectableText(
                                              kyTucXa['capacity'].toString(),
                                            )),
                                        Expanded(flex: 2, child: Container())
                                      ],
                                    ))
                              ],
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            // Row(
                            //   children: [
                            //     Expanded(
                            //         flex: 5,
                            //         child: Row(
                            //           children: [
                            //             Expanded(
                            //                 flex: 2,
                            //                 child: SelectableText(
                            //                   'Tên lớp',
                            //                   style: titleWidgetBox,
                            //                 )),
                            //             Expanded(
                            //               flex: 7,
                            //               child: SelectableText(
                            //                 snapshot.data!['name'],
                            //                 style: TextStyle(fontSize: 16),
                            //               ),
                            //             ),
                            //             Expanded(child: Container(), flex: 2),
                            //           ],
                            //         )),
                            //     Expanded(
                            //         flex: 5,
                            //         child: Row(
                            //           children: [
                            //             Expanded(
                            //                 flex: 2,
                            //                 child: SelectableText(
                            //                   'Chương trình đào tạo',
                            //                   style: titleWidgetBox,
                            //                 )),
                            //             Expanded(
                            //               flex: 3,
                            //               child: FutureBuilder<dynamic>(
                            //                 future: getCTDTFuture,
                            //                 builder: (context, ctdt) {
                            //                   if (ctdt.hasData) {
                            //                     return SelectableText(
                            //                       ctdt.data!['name'],
                            //                       style:
                            //                           TextStyle(fontSize: 16),
                            //                     );
                            //                   } else if (snapshot.hasError) {
                            //                     return SelectableText(
                            //                         '${snapshot.error}');
                            //                   }
                            //                   // By default, show a loading spinner.
                            //                   return const CircularProgressIndicator();
                            //                 },
                            //               ),
                            //             ),
                            //             Expanded(flex: 5, child: Container())
                            //           ],
                            //         ))
                            //   ],
                            // ),
                          ],
                        ),
                      )
                    ]),
              ),
              Container(
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
                            'Danh sách thực tập sinh trong phòng',
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
                              child: DSHocVien(
                            id: widget.id,
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),Footer()
            ],
          );
        } else if (snapshot.hasError) {
          return SelectableText('${snapshot.error}');
        }
        // By default, show a loading spinner.
        return Center(child: const CircularProgressIndicator());
      },
    );
  }
}

class DSHocVien extends StatefulWidget {
  final String id;
  const DSHocVien({Key? key, required this.id}) : super(key: key);

  @override
  State<DSHocVien> createState() => _DSHocVienState();
}

class _DSHocVienState extends State<DSHocVien> {
  late Future<dynamic> getListTTSFuture;
  late int rowCount = 0;
  int currentPageDef = 1;
  int rowPerPage = 10;
  var listTts;
  Future<dynamic> getListTTS(currentPage) async {
    var response = await httpGet(
        "/api/kytucxa-chitiet/get/page?size=$rowPerPage&page=${currentPage - 1}&filter=dormId:${widget.id} and status:1",
        context);
    if (response.containsKey("body")) {
      listTts = jsonDecode(response["body"])['content'];
      rowCount = jsonDecode(response["body"])['totalElements'];
      return listTts;
    } else
      throw Exception("Error load data");
  }

  @override
  void initState() {
    getListTTSFuture = getListTTS(1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: getListTTSFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var tableIndex = (currentPageDef - 1) * rowPerPage + 1;
          return Container(
            margin: const EdgeInsets.all(16),
            child: Column(
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
                            'Mã TTS',
                            style: titleTableData,
                            textAlign: TextAlign.center,
                          ))),
                          DataColumn(
                              label: Expanded(
                                  child: SelectableText(
                            'Tên TTS',
                            style: titleTableData,
                            textAlign: TextAlign.center,
                          ))),
                          DataColumn(
                              label: Expanded(
                                  child: SelectableText(
                            'Ngày tháng năm sinh',
                            style: titleTableData,
                            textAlign: TextAlign.center,
                          ))),
                          DataColumn(
                              label: Expanded(
                                  child: SelectableText(
                            'Trạng thái TTS',
                            style: titleTableData,
                            textAlign: TextAlign.center,
                          ))),
                        ],
                        rows: <DataRow>[
                          for (var row in listTts)
                            DataRow(cells: [
                              DataCell(Center(child: SelectableText("${tableIndex++}"))),
                              DataCell(Center(
                                  child: SelectableText(row['thuctapsinh']['userCode'],
                                      style: bangDuLieu))),
                              DataCell(Center(
                                  child: SelectableText(row['thuctapsinh']['fullName'],
                                      style: bangDuLieu))),
                              DataCell(Center(
                                  child: SelectableText(
                                      row['thuctapsinh']['birthDate'] != null
                                          ? dateReverse(
                                              row['thuctapsinh']['birthDate'])
                                          : 'no data',
                                      style: bangDuLieu))),
                              DataCell(Center(
                                  child: SelectableText(
                                      row['thuctapsinh']['ttsTrangthai']
                                          ['statusName'],
                                      style: bangDuLieu))),
                              //
                            ])
                        ],
                      ),
                    ),
                  ],
                ),
                DynamicTablePagging(rowCount, currentPageDef, rowPerPage,
                    pageChangeHandler: (currentPage) {
                  setState(() {
                    getListTTSFuture = getListTTS(currentPage);
                    currentPageDef = currentPage;
                  });
                }, rowPerPageChangeHandler: (rowPerPageChange) {
                  currentPageDef = 1;

                  rowPerPage = rowPerPageChange;
                  getListTTSFuture = getListTTS(currentPageDef);
                  setState(() {});
                })
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return SelectableText('${snapshot.error}');
        }

        // By default, show a loading spinner.
        return Center(child: const CircularProgressIndicator());
      },
    );
  }
}
