import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/widgets_form.dart';
import 'package:gentelella_flutter/widgets/ui/bars.dart';

import '../../../../api.dart';
import '../../../../common/style.dart';

class ViewThongTinDaoTao extends StatefulWidget {
  final String id;
  const ViewThongTinDaoTao({Key? key, required this.id}) : super(key: key);

  @override
  State<ViewThongTinDaoTao> createState() => _ViewThongTinDaoTaoState();
}

class _ViewThongTinDaoTaoState extends State<ViewThongTinDaoTao> {
  late Future<dynamic> getInfoTtsFuture;
  var infoTts;
  getInfoTts() async {
    await getListNYP();
    await getTrangThaiDongTien();
    await getListInfoTTDT();
    await getListInfoVP();
    if (infoTtsTTDT != null) await getListInfoDTTN(infoTtsTTDT['id']);

    var response = await httpGet(
        "/api/daotao-tts/get/page?filter=ttsId:${widget.id}", context);
    if (response.containsKey("body")) {
      setState(() {
        if (jsonDecode(response["body"])['content'].isNotEmpty)
          infoTts = jsonDecode(response["body"])['content'][0];
      });
    }
    return 0;
  }

  var trangThaiDongTien;
  getTrangThaiDongTien() async {
    var response = await httpGet(
        "/api/tts-thanhtoan/get/page?filter=ttsId:${widget.id}", context);
    if (response.containsKey("body")) {
      if (jsonDecode(response["body"])['content'].isNotEmpty) {
        trangThaiDongTien = jsonDecode(response["body"])['content'][0];
      }
    } else
      throw Exception("Error load data");
    return trangThaiDongTien;
  }

  var infoTtsTTDT;
  var checkInfoTtsTTDT = [];
  getListInfoTTDT() async {
    var response = await httpGet(
        "/api/tts-thongtindaotao/get/page?filter=ttsId:${widget.id}", context);
    print("/api/tts-thongtindaotao/get/page?filter=ttsId:${widget.id}");
    if (response.containsKey("body")) {
      checkInfoTtsTTDT = jsonDecode(response["body"])['content'];
      print(checkInfoTtsTTDT);
      if (checkInfoTtsTTDT.isNotEmpty) {
        infoTtsTTDT = checkInfoTtsTTDT[0];
      }
    }

    return 0;
  }

  var listCheckNYP;
  var listNYP = {};
  getListNYP() async {
    var response = await httpGet(
        "/api/tts-thongtindaotao-hocpham/get/page?filter=ttsId:${widget.id}",
        context);
    if (response.containsKey("body")) {
      listCheckNYP = jsonDecode(response["body"])['content'];
      if (listCheckNYP.isNotEmpty) {
        listNYP = listCheckNYP[0];
        if (listNYP['minBook1'] == 1) {
          setNhuYeuPham('S??ch Min 1');
        }
        if (listNYP['minBook2'] == 1) {
          setNhuYeuPham('S??ch Min 2');
        }
        if (listNYP['dictionary'] == 1) {
          setNhuYeuPham('T??? ??i???n');
        }
        if (listNYP['kanji'] == 1) {
          setNhuYeuPham('Kanji');
        }
        if (listNYP['clothes'] == 1) {
          setNhuYeuPham('2 ??o');
        }
        if (listNYP['sandals'] == 1) {
          setNhuYeuPham('1 ????i d??p');
        }
        if (listNYP['userCard'] == 1) {
          setNhuYeuPham('1 th???');
        }
        if (listNYP['blanket'] == 1) {
          setNhuYeuPham('Ch??n');
        }
        if (listNYP['mat'] == 1) {
          setNhuYeuPham('Chi???u');
        }
        if (listNYP['drape'] == 1) {
          setNhuYeuPham('M??n');
        }
      }
    }

    return 0;
  }

  setNhuYeuPham(String title) {
    for (var row in listNhuYeuPham) {
      if (title == row['title']) {
        row['value'] = true;
      }
    }
  }

  var listDTTN;
  var daoTaoTiengNhat = [];
  getListInfoDTTN(id) async {
    var response = await httpGet(
        "/api/tts-thongtindaotao-tiengnhat/get/page?filter=thongtindaotaoId:$id &sort=lessonFrom",
        context);
    if (response.containsKey("body")) {
      listDTTN = jsonDecode(response["body"])['content'];
    }
    daoTaoTiengNhat = [];
    for (var row in listDTTN) {
      daoTaoTiengNhat.add({
        'id': row['id'],
        'reportDate': dateReverse(displayDateTimeStamp(row['reportDate'])),
        'lessonFrom': row['lessonFrom'].toString(),
        'lessonTo': row['lessonTo'].toString(),
        'reportFile': row['reportFile'],
        'attitudeComment': row['attitudeComment'],
        'academicPerformanceComment': row['academicPerformanceComment'],
      });
    }
    print(daoTaoTiengNhat);
    return 0;
  }

  var viPham = [];
  var listViPham = [];
  getListInfoVP() async {
    var response = await httpGet(
        "/api/tts-thongtindaotao-vipham/get/page?filter=ttsId:${widget.id}&sort=isDone",
        context);
    if (response.containsKey("body")) {
      listViPham = jsonDecode(response["body"])['content'];
    }
    viPham = [];
    for (var row in listViPham) {
      viPham.add({
        "phongban": row['phongban']['departName'],
        "violateContent": row['violateContent'],
        "violateDate": dateReverse(displayDateTimeStamp(row['violateDate'])),
        "isDone": row['isDone'] == 1 ? "???? x??? l??" : 'Ch??a x??? l??',
      });
    }
    return 0;
  }

  List<dynamic> listNhuYeuPham = [
    {'title': 'S??ch Min 1', 'value': false},
    {'title': 'S??ch Min 2', 'value': false},
    {'title': 'T??? ??i???n', 'value': false},
    {'title': 'Kanji', 'value': false},
    {'title': '2 ??o', 'value': false},
    {'title': '1 ????i d??p', 'value': false},
    {'title': '1 th???', 'value': false},
    {'title': 'Ch??n', 'value': false},
    {'title': 'Chi???u', 'value': false},
    {'title': 'M??n', 'value': false}
  ];

  @override
  // ignore: must_call_super
  void initState() {
    getInfoTtsFuture = getInfoTts();
  }

  String trangThaiThanhToan(input) {
    if (input == 0)
      return 'Ch??a ????ng ti???n';
    else if (input == 1)
      return '????ng to??n b???';
    else if (input == 2)
      return '???? ????ng ti???n ??n';
    else if (input == 3) return '???? ????ng ti???n h???c';
    return 'nodata';
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return FutureBuilder<dynamic>(
      future: getInfoTtsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (infoTtsTTDT != null)
            return Container(
                margin: EdgeInsets.only(top: 20),
                color: backgroundPage,
                padding: EdgeInsets.symmetric(
                    vertical: 0, horizontal: horizontalPaddingPage),
                child: SingleChildScrollView(
                  controller: ScrollController(),
                  child: Column(children: [
                    Container(
                      // padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      // margin: EdgeInsets.only(top: 20),
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SelectableText(
                              'Th??ng tin TTS  ',
                              style: titleBox,
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                      flex: 1,
                                      child: trangThaiDongTien != null
                                          ? (trangThaiDongTien['paidTuition'] !=
                                                  0
                                              ? Icon(Icons.done)
                                              : Container())
                                          : Icon(Icons.close)),
                                  Expanded(
                                    flex: 25,
                                    child: SelectableText(
                                      // '',
                                      'X??c nh???n thu ti???n h???c ph?? (${trangThaiDongTien != null ? trangThaiThanhToan(trangThaiDongTien['paidTuition']) : 'nodata'})',
                                      style: TextStyle(
                                        color: Color(0xff333333),
                                        fontSize: 16,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                                child: Row(
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: SelectableText(
                                      'Ng??y nh???p h???c',
                                      style: titleWidgetBox,
                                    )),
                                Expanded(
                                    flex: 1,
                                    child: SelectableText(
                                        infoTtsTTDT['admissionDate'] != null
                                            ? dateReverse(
                                                infoTtsTTDT['admissionDate'])
                                            : 'Ch??a x??c ?????nh')),
                                Expanded(flex: 2, child: Container())
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
                                child: Row(
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: SelectableText(
                                      'M?? l???p',
                                      style: titleWidgetBox,
                                    )),
                                Expanded(
                                    flex: 1,
                                    child: SelectableText(infoTts != null
                                        ? infoTts['lophoc']['code']
                                        : 'nodata')),
                                Expanded(flex: 2, child: Container())
                              ],
                            )),
                            Expanded(
                                child: Row(
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: SelectableText(
                                      'Ng??y m??n kh??a',
                                      style: titleWidgetBox,
                                    )),
                                Expanded(
                                    flex: 1,
                                    child: SelectableText(infoTtsTTDT[
                                                'courseCompletedDate'] !=
                                            null
                                        ? dateReverse(
                                            infoTtsTTDT['courseCompletedDate'])
                                        : "??ang ????o t???o")),
                                Expanded(flex: 2, child: Container())
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
                                child: Row(
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: SelectableText(
                                      'Gi??o vi??n ch??? nhi???m',
                                      style: titleWidgetBox,
                                    )),
                                Expanded(
                                    flex: 1,
                                    child: SelectableText(infoTts != null
                                        ? infoTts['lophoc']['giaovien']
                                            ['fullName']
                                        : "nodata")),
                                Expanded(flex: 2, child: Container())
                              ],
                            )),
                            Expanded(child: Container())
                          ],
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SelectableText(
                              '????o t???o tr?????c thi tuy???n',
                              style: titleBox,
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 1,
                                child: infoTtsTTDT['trainedBeforeExam'] == 1
                                    ? Icon(Icons.done)
                                    : Icon(Icons.close)),
                            Expanded(
                              flex: 25,
                              child: SelectableText(
                                '???? ????o t???o tr?????c thi tuy???n',
                                style: TextStyle(
                                  color: Color(0xff333333),
                                  fontSize: 16,
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Row(
                          children: [
                            Expanded(
                                flex: 1,
                                child: SelectableText(
                                  'N???i dung ????o t???o:',
                                  style: titleWidgetBox,
                                )),
                            Expanded(
                                flex: 7,
                                child: SelectableText(
                                    infoTtsTTDT['trainedContentBeforeExam'] ??
                                        '')),
                          ],
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SelectableText(
                              'Nhu y???u ph???m',
                              style: titleBox,
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
                        LableWidthCheckbox(listCheckBox: listNhuYeuPham),
                        SizedBox(
                          height: 50,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SelectableText(
                              '????o t???o sau tr??ng tuy???n',
                              style: titleBox,
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
                        SizedBox(
                          height: 25,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SelectableText(
                              '1. ????o t???o c?? b???n',
                              style: titleBox,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Row(
                          children: [
                            Expanded(
                                flex: 2,
                                child: SelectableText(
                                  'Ch??o h???i c?? b???n:',
                                  style: titleWidgetBox,
                                )),
                            Expanded(
                                flex: 20,
                                child: SelectableText(
                                    infoTtsTTDT['basicGreetings'] == 1
                                        ? '?????t'
                                        : 'Kh??ng ?????t'))
                          ],
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Row(
                          children: [
                            Expanded(
                                flex: 2,
                                child: SelectableText(
                                  'B???ng ch??? c??i:',
                                  style: titleWidgetBox,
                                )),
                            Expanded(
                                flex: 20,
                                child: SelectableText(
                                    '${infoTtsTTDT['alphabetScore'] ?? "Ch??a c??"} ??i???m   (${infoTtsTTDT['alphabet'] == 1 ? '?????t' : 'Kh??ng ?????t'})'))
                          ],
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SelectableText(
                              '2. ????o t???o ti???ng Nh???t',
                              style: titleBox,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: DataTable(
                                // headingRowColor: MaterialStateProperty.all(backgroundColor),
                                columnSpacing: 0,
                                horizontalMargin: 0,
                                columns: [
                                  DataColumn(
                                      label: Container(
                                    child: SelectableText(
                                      'Ng??y b??o c??o',
                                      style: titleTableData,
                                      textAlign: TextAlign.center,
                                    ),
                                  )),
                                  DataColumn(
                                      label: Container(
                                    child: SelectableText(
                                      'B??i',
                                      style: titleTableData,
                                      textAlign: TextAlign.center,
                                    ),
                                  )),
                                  DataColumn(
                                      label: Container(
                                    child: SelectableText(
                                      'Nh???n x??t v??? h???c l???c',
                                      style: titleTableData,
                                      textAlign: TextAlign.center,
                                    ),
                                  )),
                                  DataColumn(
                                      label: Container(
                                    child: SelectableText(
                                      'Nh???n x??t v??? th??i ?????',
                                      style: titleTableData,
                                      textAlign: TextAlign.center,
                                    ),
                                  )),
                                  DataColumn(
                                      label: Container(
                                    child: SelectableText(
                                      'B??o c??o',
                                      style: titleTableData,
                                      textAlign: TextAlign.center,
                                    ),
                                  )),
                                ],
                                rows: <DataRow>[
                                  for (var row in daoTaoTiengNhat)
                                    DataRow(cells: <DataCell>[
                                      DataCell(SelectableText(
                                        row['reportDate'],
                                        style: bangDuLieu,
                                      )),
                                      DataCell(SelectableText(
                                        "${row['lessonFrom']} ?????n ${row['lessonTo']}",
                                        style: bangDuLieu,
                                      )),
                                      DataCell(SelectableText(
                                        row['academicPerformanceComment'],
                                        style: bangDuLieu,
                                      )),
                                      DataCell(SelectableText(
                                        row['attitudeComment'],
                                        style: bangDuLieu,
                                      )),
                                      DataCell(TextButton(
                                        onPressed: () {
                                          downloadFile(row['reportFile']);
                                        },
                                        child: Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.attach_file),
                                              Text(
                                                "${row['reportFile']}",
                                                style: TextStyle(
                                                    color: Colors.blue),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )),
                                    ])
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SelectableText(
                              '3. ??i???m thi n??ng l???c ti???ng Nh???t',
                              style: titleBox,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        flex: 1,
                                        child: SelectableText(
                                          'N5:',
                                          style: titleWidgetBox,
                                        )),
                                    Expanded(
                                        flex: 8,
                                        child: SelectableText(
                                            '${infoTtsTTDT['n5Score'] ?? "Ch??a c??"} ??i???m   (${infoTtsTTDT['n5'] == 1 ? '?????t' : 'Kh??ng ?????t'})')),
                                  ],
                                ),
                                SizedBox(
                                  height: 25,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        flex: 1,
                                        child: SelectableText(
                                          'N4:',
                                          style: titleWidgetBox,
                                        )),
                                    Expanded(
                                        flex: 8,
                                        child: Text(
                                            '${infoTtsTTDT['n4Score'] ?? "Ch??a c??"} ??i???m   (${infoTtsTTDT['n4'] == 1 ? '?????t' : 'Kh??ng ?????t'})')),
                                  ],
                                ),
                              ],
                            )),
                            Expanded(
                                child: infoTtsTTDT['vnuCertificate'] != null
                                    ? TextButton(
                                        onPressed: () {
                                          downloadFile(
                                              infoTtsTTDT['vnuCertificate']);
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.attach_file),
                                            Text(
                                              '${infoTtsTTDT['vnuCertificate']}',
                                              style:
                                                  TextStyle(color: Colors.blue),
                                            ),
                                          ],
                                        ),
                                      )
                                    : SelectableText('Ch??a c?? ch???ng ch???'))
                          ],
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SelectableText(
                              '4. ????o t???o tr?????c xu???t c???nh',
                              style: titleBox,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 1,
                                child: infoTtsTTDT['trainedBeforeFlight'] == 1
                                    ? Icon(Icons.done)
                                    : Icon(Icons.close)),
                            Expanded(
                              flex: 25,
                              child: SelectableText(
                                '???? ????o t???o ',
                                style: TextStyle(
                                  color: Color(0xff333333),
                                  fontSize: 16,
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Row(
                          children: [
                            Expanded(
                                flex: 1,
                                child: SelectableText(
                                  'N???i dung chi ti???t:',
                                  style: titleWidgetBox,
                                )),
                            Expanded(
                                flex: 7,
                                child: SelectableText(
                                    infoTtsTTDT['trainedContentBeforeFlight'] ??
                                        '')),
                          ],
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SelectableText(
                              'C??c vi ph???m n???u c??',
                              style: titleBox,
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
                                headingRowColor:
                                    MaterialStateProperty.all(backgroundColor),
                                columnSpacing: 0,
                                horizontalMargin: 0,
                                columns: [
                                  DataColumn(
                                      label: Container(
                                    // width: width * .02,
                                    child: Row(
                                      children: [
                                        SelectableText(
                                          'STT',
                                          style: titleTableData,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  )),
                                  DataColumn(
                                      label: Container(
                                    // width: width * .1,
                                    child: Row(
                                      children: [
                                        SelectableText(
                                          'Ng??y th??ng',
                                          style: titleTableData,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  )),
                                  DataColumn(
                                      label: Container(
                                    // width: width * .1,
                                    child: Row(
                                      children: [
                                        SelectableText(
                                          'B??? ph???n x??? l??',
                                          style: titleTableData,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  )),
                                  DataColumn(
                                      label: Container(
                                    // width: width * .2,
                                    child: Row(
                                      children: [
                                        SelectableText(
                                          'Ph??t sinh/L???i',
                                          style: titleTableData,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  )),
                                  // DataColumn(
                                  //     label: Container(
                                  //   width: width * .2,
                                  //   child: Row(
                                  //     children: [
                                  //       Expanded(
                                  //           child: SelectableText(
                                  //         'K???t qu??? x??? l??',
                                  //         style: titleTableData,
                                  //         textAlign: TextAlign.center,
                                  //       )),
                                  //     ],
                                  //   ),
                                  // )),
                                ],
                                rows: <DataRow>[
                                  for (int i = 0; i < viPham.length; i++)
                                    DataRow(cells: <DataCell>[
                                      DataCell(Container(
                                          margin: EdgeInsets.only(
                                              left: width * .005),
                                          child: SelectableText(
                                              (i + 1).toString(),
                                              style: bangDuLieu))),
                                      DataCell(SelectableText(
                                        viPham[i]['violateDate'],
                                        style: bangDuLieu,
                                      )),
                                      DataCell(SelectableText(
                                        viPham[i]['phongban'],
                                        style: bangDuLieu,
                                      )),
                                      DataCell(SelectableText(
                                        viPham[i]['violateContent'],
                                        style: bangDuLieu,
                                      )),
                                      // DataCell(Center(
                                      //     child: SelectableText(
                                      //   viPham[i]['isDone'],
                                      //   style: bangDuLieu,
                                      // ))),
                                    ])
                                ],
                              ),
                            ),
                          ],
                        ),
                      ]),
                    ),
                    Footer()
                  ]),
                ));
          else
            return Container(
              margin: EdgeInsets.only(top: 30),
              color: backgroundPage,
              padding: EdgeInsets.symmetric(
                  vertical: 0, horizontal: horizontalPaddingPage),
              child: Container(
                width: MediaQuery.of(context).size.width * 1,
                decoration: BoxDecoration(
                  color: colorWhite,
                  borderRadius: borderRadiusContainer,
                  boxShadow: [boxShadowContainer],
                  border: borderAllContainerBox,
                ),
                padding: paddingBoxContainer,
                child: Center(
                  child: SelectableText(
                    "Ch??a c?? th??ng tin ????o t???o",
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
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

// ignore: must_be_immutable
class LableWidthCheckbox extends StatefulWidget {
  final List<dynamic> listCheckBox;
  const LableWidthCheckbox({Key? key, required this.listCheckBox})
      : super(key: key);

  @override
  State<LableWidthCheckbox> createState() => _LableWidthCheckboxState();
}

class _LableWidthCheckboxState extends State<LableWidthCheckbox> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 25.0,
      spacing: 5.0,
      children: [
        for (var row in widget.listCheckBox)
          Container(
            width: 600,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                    flex: 1,
                    child: row['value'] == true
                        ? Icon(Icons.done)
                        : Icon(Icons.close)),
                Expanded(
                  flex: 4,
                  child: SelectableText(
                    row['title'],
                    style: TextStyle(
                      color: Color(0xff333333),
                      fontSize: 16,
                    ),
                  ),
                )
              ],
            ),
          ),
      ],
    );
  }
}

// ignore: unused_element
class _DataTableDTTN {
  String time;
  String bai;
  String nxhl;
  String nxtd;
  String url;
  _DataTableDTTN(this.time, this.bai, this.nxhl, this.nxtd, this.url);
}

class _DataTable {
  String time;
  String boPhanXL;
  String loi;
  String ketQua;
  _DataTable(this.time, this.boPhanXL, this.loi, this.ketQua);
}

class _TableLoi extends StatefulWidget {
  const _TableLoi({Key? key}) : super(key: key);

  @override
  State<_TableLoi> createState() => _TableLoiState();
}

class _TableLoiState extends State<_TableLoi> {
  List<_DataTable> data = [
    _DataTable('01/01/2020', 'Trung t??m ????o t???o', '', ''),
  ];
  List<String> itemsBPXL = [
    'Trung t??m ????o t???o',
    'Bp. Ki???m so??t',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [],
      ),
    );
  }
}
