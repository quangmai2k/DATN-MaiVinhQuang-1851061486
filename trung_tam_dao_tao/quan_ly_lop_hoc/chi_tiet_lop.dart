import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../api.dart';
import '../../../../common/dynamic_table.dart';
import '../../../../common/style.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/model.dart';
import '../../navigation.dart';

class ChiTietLop extends StatefulWidget {
  final String id;
  const ChiTietLop({Key? key, required this.id}) : super(key: key);
  @override
  State<ChiTietLop> createState() => _ChiTietLopState();
}

class _ChiTietLopState extends State<ChiTietLop> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
        widgetBody: ChiTietLopBody(
      id: widget.id,
    ));
  }
}

class ChiTietLopBody extends StatefulWidget {
  final String id;

  const ChiTietLopBody({Key? key, required this.id}) : super(key: key);

  @override
  State<ChiTietLopBody> createState() => _ChiTietLopBodyState();
}

late Future<dynamic> getLhFuture;
late Future<dynamic> getGvFuture;
late Future<dynamic> getCTDTFuture;

class _ChiTietLopBodyState extends State<ChiTietLopBody> {
  Future<dynamic> getLH() async {
    var response = await httpGet("/api/daotao-lop/get/" + widget.id, context);
    if (response.containsKey("body"))
      return jsonDecode(response["body"]);
    else
      throw Exception("Error load data");
  }

  Future<dynamic> getGV(String id) async {
    var response =
        await httpGet("/api/nguoidung/get/info?filter=id:$id", context);
    if (response.containsKey("body"))
      return jsonDecode(response["body"]);
    else
      throw Exception("Error load data");
  }

  getTCDT(String id) async {
    var response = await httpGet("/api/daotao-chuongtrinh/get/$id", context);
    if (response.containsKey("body"))
      return jsonDecode(response["body"]);
    else
      throw Exception("Error load data");
  }

  void initState() {
    getLhFuture = getLH();
    getLhFuture.then((data) {
      getGvFuture = getGV(data['giaovienId'].toString());
      getCTDTFuture = getTCDT(data['daotaoChuongtrinhId'].toString());
    }, onError: (e) {
      print(e);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: getLhFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView(
            children: [
              TitlePage(
                listPreTitle: [
                  {'url': '/bang-thong-ke-nhanh', 'title': 'Dashboard'},
                  {'url': '/quan-ly-lop-hoc', 'title': 'Qu???n l?? l???p h???c'}
                ],
                content: 'Chi ti???t l???p h???c',
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
                                  'Th??ng tin l???p h???c',
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
                              children: [
                                Expanded(
                                    flex: 5,
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 2,
                                            child: SelectableText(
                                              'M?? l???p',
                                              style: titleWidgetBox,
                                            )),
                                        Expanded(
                                          flex: 7,
                                          child: SelectableText(
                                            snapshot.data!['code'],
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
                                            flex: 3,
                                            child: SelectableText(
                                              'Gi??o vi??n ch??? nhi???m',
                                              style: titleWidgetBox,
                                            )),
                                        Expanded(
                                            flex: 3,
                                            child: SelectableText(
                                              snapshot.data!['giaovien'] != null
                                                  ? snapshot.data!['giaovien']
                                                      ['fullName']
                                                  : "",
                                              style: TextStyle(fontSize: 16),
                                            )),
                                        Expanded(flex: 5, child: Container())
                                      ],
                                    ))
                              ],
                            ),
                            SizedBox(
                              height: 25,
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
                                              'T??n l???p',
                                              style: titleWidgetBox,
                                            )),
                                        Expanded(
                                          flex: 7,
                                          child: SelectableText(
                                            snapshot.data!['name'],
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
                                            flex: 3,
                                            child: SelectableText(
                                              'Ch????ng tr??nh ????o t???o',
                                              style: titleWidgetBox,
                                            )),
                                        Expanded(
                                            flex: 3,
                                            child: SelectableText(
                                              snapshot.data!['chuongtrinh']
                                                  ['name'],
                                              style: TextStyle(fontSize: 16),
                                            )),
                                        Expanded(flex: 5, child: Container())
                                      ],
                                    ))
                              ],
                            ),
                            SizedBox(
                              height: 25,
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
                                              'M?? t???',
                                              style: titleWidgetBox,
                                            )),
                                        Expanded(
                                          flex: 7,
                                          child: SelectableText(
                                            snapshot.data!['description'],
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                        Expanded(child: Container(), flex: 2),
                                      ],
                                    )),
                                Expanded(
                                  flex: 5,
                                  child: Container(),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 25,
                            ),
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
                            'Danh s??ch h???c vi??n',
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
                              child: DSHocVien(
                            id: snapshot.data!['id'].toString(),
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
  late Future<dynamic> getListInfoTTSFuture;
  late int rowCount = 0;
  int currentPageDef = 1;
  int rowPerPage = 10;
  var listTts;
  Future<dynamic> getListTTS(currentPage) async {
    await getListTtsTtdt();
    var response = await httpGet(
        "/api/daotao-tts/get/page?size=$rowPerPage&page=${currentPage - 1}&filter=daotaoLopId:${widget.id} and nguoidung.ttsStatusId:9",
        context);
    if (response.containsKey("body")) {
      await getOrderInfo();
      listTts = jsonDecode(response["body"])['content'];
      rowCount = jsonDecode(response["body"])['totalElements'];
      return listTts;
    } else
      throw Exception("Error load data");
  }

  var orderInfo;
  getOrderInfo() async {
    var response = await httpGet("/api/donhang/get/page", context);

    if (response.containsKey("body")) {
      orderInfo = jsonDecode(response["body"]);
      return orderInfo;
    } else
      throw Exception("Error load data");
  }

  //L???y ra th??ng tin ????o t???o
  var listTtdt;
  getListTtsTtdt() async {
    var response = await httpGet("/api/tts-thongtindaotao/get/page", context);
    if (response.containsKey("body")) {
      listTtdt = jsonDecode(response["body"])['content'];
      return listTtdt;
    }
    return 0;
  }

  String getNgayNhapHoc(id) {
    for (var row in listTtdt ?? []) {
      if (row['ttsId'] == id) {
        return row['admissionDate'];
      }
    }
    return 'no data';
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
                          columnSpacing:
                              MediaQuery.of(context).size.width < 1600
                                  ? 10
                                  : 20,
                          // columnSpacing: 5,
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
                              'M?? ????n h??ng',
                              style: titleTableData,
                              textAlign: TextAlign.center,
                            ))),
                            DataColumn(
                                label: Expanded(
                                    child: SelectableText(
                              'T??n ????n h??ng',
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
                              'Ng??y nh???p h???c\n d??? ki???n',
                              style: titleTableData,
                              textAlign: TextAlign.center,
                            ))),
                            DataColumn(
                                label: Expanded(
                                    child: SelectableText(
                              'Ng??y xu???t c???nh\n d??? ki???n',
                              style: titleTableData,
                              textAlign: TextAlign.center,
                            ))),
                            DataColumn(
                                label: Expanded(
                                    child: SelectableText(
                              'S??? ??i???n tho???i TTS',
                              style: titleTableData,
                              textAlign: TextAlign.center,
                            ))),
                          ],
                          rows: <DataRow>[
                            for (var row in listTts)
                              DataRow(cells: <DataCell>[
                                DataCell(Center(
                                    child: SelectableText('${tableIndex++}',
                                        style: bangDuLieu))),
                                DataCell(Center(
                                    child: SelectableText(
                                        row['nguoidung']['donhang'] != null
                                            ? row['nguoidung']['donhang']
                                                ['orderCode']
                                            : '',
                                        style: bangDuLieu))),
                                DataCell(Center(
                                    child: SelectableText(
                                        row['nguoidung']['donhang'] != null
                                            ? row['nguoidung']['donhang']
                                                ['orderName']
                                            : '',
                                        style: bangDuLieu))),
                                DataCell(Center(
                                    child: SelectableText(
                                        row['nguoidung']['userCode'],
                                        style: bangDuLieu))),
                                DataCell(Center(
                                    child: SelectableText(
                                        row['nguoidung']['fullName'],
                                        style: bangDuLieu))),
                                DataCell(Center(
                                    child: SelectableText(
                                        row['nguoidung']['donhang'] != null
                                            ? row['nguoidung']['donhang'][
                                                        'estimatedAdmissionDate'] !=
                                                    null
                                                ? DateFormat("dd-MM-yyyy")
                                                    .format(DateTime.parse(row[
                                                                'nguoidung']
                                                            ['donhang'][
                                                        'estimatedAdmissionDate']))
                                                : ''
                                            : '',
                                        style: bangDuLieu))),
                                DataCell(Center(
                                    child: SelectableText(
                                        row['nguoidung']['donhang'] != null
                                            ? row['nguoidung']['donhang'][
                                                        'estimatedEntryDate'] !=
                                                    null
                                                ? DateFormat("dd-MM-yyyy")
                                                    .format(DateTime.parse(row[
                                                                'nguoidung']
                                                            ['donhang']
                                                        ['estimatedEntryDate']))
                                                : ''
                                            : '',
                                        style: bangDuLieu))),
                                DataCell(Center(
                                    child: SelectableText(
                                        row['nguoidung']['mobile'] ?? '',
                                        style: bangDuLieu))),
                              ])
                          ],
                          horizontalMargin: 10,
                          dataRowHeight: 60,
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
                    setState(() {
                      currentPageDef = 1;

                      rowPerPage = rowPerPageChange;
                      getListTTSFuture = getListTTS(currentPageDef);
                    });
                  })
                ],
              ));
        } else if (snapshot.hasError) {
          return SelectableText('${snapshot.error}');
        }

        // By default, show a loading spinner.
        return Center(child: const CircularProgressIndicator());
      },
    );
  }
}
