import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/navigation.dart';
import 'package:gentelella_flutter/widgets/ui/source_information/common_ource_information/constant.dart';
import 'package:gentelella_flutter/widgets/ui/source_information/setting-data/tts.dart';

import '../../../../api.dart';
import '../../../../common/dynamic_table.dart';
import '../../../../common/style.dart';
import '../../../../common/widgets_form.dart';
import 'dart:js' as js;

import '../../../../config.dart';

class ThongTinCongTacVien extends StatelessWidget {
  final String id;
  const ThongTinCongTacVien({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: ThongTinCongTacVienBody(id: id));
  }
}

class ThongTinCongTacVienBody extends StatefulWidget {
  final String id;
  const ThongTinCongTacVienBody({Key? key, required this.id}) : super(key: key);

  @override
  State<ThongTinCongTacVienBody> createState() => _ThongTinCongTacVienBodyState();
}

class _ThongTinCongTacVienBodyState extends State<ThongTinCongTacVienBody> {
  // var userInfo;
  late Future<dynamic> getUserFuture;

  InformationTTS infoCTV = new InformationTTS();
  Future<InformationTTS> getUser() async {
    var response = await httpGet("/api/nguoidung/get/info?filter=id:${widget.id}", context);
    var userInfo = jsonDecode(response["body"]);
    if (response.containsKey("body")) {
      setState(() {
        infoCTV = InformationTTS.fromJson(userInfo);
      });
    }
    return InformationTTS.fromJson(userInfo);
  }

  @override
  void initState() {
    getUserFuture = getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: userRule('/thong-tin-cong-tac-vien', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return SingleChildScrollView(
              child: Column(
            children: [
              TitlePage(
                listPreTitle: [
                  {'url': '/bang-thong-ke-nhanh', 'title': 'Dashboard'},
                  {'url': QUAN_LY_CTV, 'title': 'Qu???n l?? c???ng t??c vi??n'}
                ],
                content: "Qu???n l?? h??? s?? c???ng t??c vi??n",
              ),
              FutureBuilder<dynamic>(
                future: getUserFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                      color: backgroundPage,
                      padding: EdgeInsets.symmetric(vertical: verticalPaddingPage, horizontal: horizontalPaddingPage),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                                  Text(
                                    'Th??ng tin chi ti???t c???ng t??c vi??n',
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
                                      child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                              child: Text(
                                            "?????nh danh(C?? nh??n/T??? ch???c)",
                                            style: titleWidgetBox,
                                          )),
                                          Expanded(child: SelectableText(infoCTV.fullName ?? ''))
                                        ],
                                      ),
                                      SizedBox(
                                        height: 25,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: Text(
                                            "T??n ch??? t??i kho???n",
                                            style: titleWidgetBox,
                                          )),
                                          Expanded(child: SelectableText(infoCTV.bankAccountName ?? ''))
                                        ],
                                      ),
                                      SizedBox(
                                        height: 25,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: Text(
                                            "S??? t??i kho???n",
                                            style: titleWidgetBox,
                                          )),
                                          Expanded(child: SelectableText(infoCTV.bankNumber ?? ""))
                                        ],
                                      ),
                                      SizedBox(
                                        height: 25,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: Text(
                                            "Ng??n h??ng",
                                            style: titleWidgetBox,
                                          )),
                                          Expanded(child: SelectableText(infoCTV.bankName ?? ''))
                                        ],
                                      ),
                                      SizedBox(
                                        height: 25,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: Text(
                                            "Chi nh??nh ng??n h??ng",
                                            style: titleWidgetBox,
                                          )),
                                          Expanded(child: SelectableText(infoCTV.bankBranch ?? ''))
                                        ],
                                      ),
                                      SizedBox(
                                        height: 25,
                                      ),
                                    ],
                                  )),
                                  SizedBox(
                                    width: 100,
                                  ),
                                  Expanded(
                                      child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                              child: Text(
                                            "?????a ch???",
                                            style: titleWidgetBox,
                                          )),
                                          Expanded(child: SelectableText(infoCTV.address ?? ''))
                                        ],
                                      ),
                                      SizedBox(
                                        height: 25,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: Text(
                                            "S??? ??i???n tho???i 1",
                                            style: titleWidgetBox,
                                          )),
                                          Expanded(
                                            child: infoCTV.phone != ""
                                                ? Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      SelectableText(
                                                        infoCTV.phone ?? '',
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Tooltip(
                                                        message: "G???i ??i???n",
                                                        child: InkWell(
                                                            onTap: () async {
                                                              js.context.callMethod('call', [infoCTV.phone]);
                                                            },
                                                            child: Icon(
                                                              Icons.phone_in_talk,
                                                              color: Color.fromARGB(255, 52, 147, 224),
                                                            )),
                                                      ),
                                                    ],
                                                  )
                                                : Text(''),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 25,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: Text(
                                            "S??? ??i???n tho???i 2",
                                            style: titleWidgetBox,
                                          )),
                                          Expanded(
                                            child: infoCTV.phone2 != ''
                                                ? Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      SelectableText(infoCTV.phone2!, style: bangDuLieu),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Tooltip(
                                                        message: "G???i ??i???n",
                                                        child: InkWell(
                                                            onTap: () async {
                                                              js.context.callMethod('call', [infoCTV.phone2]);
                                                            },
                                                            child: Icon(
                                                              Icons.phone_in_talk,
                                                              color: Color.fromARGB(255, 52, 147, 224),
                                                            )),
                                                      ),
                                                    ],
                                                  )
                                                : Text(''),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 25,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: Text(
                                            "Email 1",
                                            style: titleWidgetBox,
                                          )),
                                          Expanded(child: SelectableText(infoCTV.email ?? ''))
                                        ],
                                      ),
                                      SizedBox(
                                        height: 25,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: Text(
                                            "Email 2",
                                            style: titleWidgetBox,
                                          )),
                                          Expanded(child: SelectableText(infoCTV.email2 ?? ''))
                                        ],
                                      ),
                                      SizedBox(
                                        height: 25,
                                      ),
                                    ],
                                  ))
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      flex: 5,
                                      child: Row(
                                        children: [
                                          Expanded(
                                              flex: 3,
                                              child: Text(
                                                "M???t tr?????c ch???ng minh th??",
                                                style: titleWidgetBox,
                                              )),
                                          Expanded(
                                            flex: 5,
                                            child: Column(
                                              children: [
                                                (infoCTV.idCardImageFront != null)
                                                    ? Container(
                                                        margin: EdgeInsets.only(bottom: 10),
                                                        width: 250,
                                                        height: 150,
                                                        child: Image.network("$baseUrl/api/files/${infoCTV.idCardImageFront}"))
                                                    : Container(
                                                        height: 100,
                                                        width: 100,
                                                        decoration: BoxDecoration(
                                                          // borderRadius: BorderRadius.circular(100),
                                                          image: DecorationImage(
                                                            image: AssetImage('assets/images/no-img.png'),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                // Container(
                                                //     child: TextButton(
                                                //   child: Text('T???i ???nh l??n'),
                                                //   onPressed: () async {
                                                //     FilePickerResult? result = await FilePicker.platform.pickFiles(
                                                //       type: FileType.custom,
                                                //       allowedExtensions: ['png', 'JPEG', 'JPG'],
                                                //       withReadStream: true,
                                                //       allowMultiple: false,
                                                //     );
                                                //     if (result != null) {
                                                //       String img = await uploadFile(result, context: context);
                                                //       //   var bytes = result.files.single.bytes;
                                                //       // String img = await uploadFileByter(bytes, context:context);
                                                //       setState(() {
                                                //         idCardImageFront = img;
                                                //       });
                                                //     } else {
                                                //       return showToast(
                                                //         context: context,
                                                //         msg: "Ch???n l???i file",
                                                //         color: Color.fromRGBO(245, 117, 29, 1),
                                                //         icon: const Icon(Icons.info),
                                                //       );
                                                //     }
                                                //   },
                                                // )),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )),
                                  SizedBox(
                                    width: 30,
                                  ),
                                  Expanded(
                                      flex: 5,
                                      child: Row(
                                        children: [
                                          Expanded(
                                              flex: 3,
                                              child: Text(
                                                "M???t Sau ch???ng minh th??",
                                                style: titleWidgetBox,
                                              )),
                                          Expanded(
                                            flex: 5,
                                            child: Column(
                                              children: [
                                                (infoCTV.idCardImageBack != null)
                                                    ? Container(
                                                        margin: EdgeInsets.only(bottom: 10),
                                                        width: 250,
                                                        height: 150,
                                                        child: Image.network("$baseUrl/api/files/${infoCTV.idCardImageBack}"))
                                                    : Container(
                                                        height: 100,
                                                        width: 100,
                                                        decoration: BoxDecoration(
                                                          // borderRadius: BorderRadius.circular(100),
                                                          image: DecorationImage(
                                                            image: AssetImage('assets/images/no-img.png'),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                // Container(
                                                //     child: TextButton(
                                                //   child: Text('T???i ???nh l??n'),
                                                //   onPressed: () async {
                                                //     FilePickerResult? result = await FilePicker.platform.pickFiles(
                                                //       type: FileType.custom,
                                                //       allowedExtensions: ['png', 'JPEG', 'JPG'],
                                                //       withReadStream: true,
                                                //       allowMultiple: false,
                                                //     );
                                                //     if (result != null) {
                                                //       String img = await uploadFile(result, context: context);
                                                //       //   var bytes = result.files.single.bytes;
                                                //       // String img = await uploadFileByter(bytes, context:context);
                                                //       setState(() {
                                                //         idCardImageBack = img;
                                                //       });
                                                //     } else {
                                                //       return showToast(
                                                //         context: context,
                                                //         msg: "Ch???n l???i file",
                                                //         color: Color.fromRGBO(245, 117, 29, 1),
                                                //         icon: const Icon(Icons.info),
                                                //       );
                                                //     }
                                                //   },
                                                // )),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )),
                                ],
                              ),
                            ],
                          ),
                        )
                      ]),
                    );
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }

                  // By default, show a loading spinner.
                  return const CircularProgressIndicator();
                },
              ),
              Container(
                color: backgroundPage,
                padding: EdgeInsets.symmetric(vertical: verticalPaddingPage, horizontal: horizontalPaddingPage),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                            Text(
                              'Danh s??ch gi???i thi???u th???c t???p sinh',
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
                        DSGioiThieu(id: widget.id)
                      ],
                    ),
                  )
                ]),
              ),
              Container(
                color: backgroundPage,
                padding: EdgeInsets.symmetric(vertical: verticalPaddingPage, horizontal: horizontalPaddingPage),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                            Text(
                              'L???ch s??? thanh to??n',
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
                        LichSuTinhThuong(id: widget.id)
                      ],
                    ),
                  )
                ]),
              ),
            ],
          ));

          // Text(listRule.data!.title);
        } else if (listRule.hasError) {
          return Text('${listRule.error}');
        }

        // By default, show a loading spinner.
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class DSGioiThieu extends StatefulWidget {
  final String id;

  const DSGioiThieu({Key? key, required this.id}) : super(key: key);
  @override
  State<DSGioiThieu> createState() => DSGioiThieuState();
}

class DSGioiThieuState extends State<DSGioiThieu> {
  late int rowCount = 0;
  int currentPageDef = 1;
  int rowPerPage = 5;
  var listTTS;
  late String dateFromRequest;
  late String dateToRequest;
  late Future<dynamic> getListTTSFuture;
  Future<dynamic> getListTTS(currentPage) async {
    var response =
        await httpGet("/api/nguoidung/get/page?size=$rowPerPage&page=${currentPage - 1}&filter=isTts:1 and recommendUser:${widget.id} ", context);
    // print("name${jsonDecode(response["body"])}");
    if (response.containsKey("body")) {
      setState(() {
        listTTS = jsonDecode(response["body"])['content'];
      });
      rowCount = jsonDecode(response["body"])['totalElements'];
    }
    return 0;
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
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DataTable(
                      showCheckboxColumn: false,
                      columns: [
                        DataColumn(
                            label: Expanded(
                                child: Text(
                          'STT',
                          style: titleTableData,
                          textAlign: TextAlign.center,
                        ))),
                        DataColumn(
                            label: Expanded(
                                child: Text(
                          'M?? TTS',
                          style: titleTableData,
                          textAlign: TextAlign.center,
                        ))),
                        DataColumn(
                            label: Expanded(
                                child: Text(
                          'H??? v?? t??n',
                          style: titleTableData,
                          textAlign: TextAlign.center,
                        ))),
                        DataColumn(
                            label: Expanded(
                                child: Text(
                          'Tr???ng th??i TTS',
                          style: titleTableData,
                          textAlign: TextAlign.center,
                        ))),
                      ],
                      rows: <DataRow>[
                        for (var row in listTTS)
                          DataRow(cells: [
                            DataCell(Center(child: SelectableText("${tableIndex++}"))),
                            DataCell(Center(child: SelectableText(row['userCode'], style: bangDuLieu))),
                            DataCell(Center(child: SelectableText(row['fullName'], style: bangDuLieu))),
                            DataCell(Center(child: SelectableText(row['ttsTrangthai']['statusName'], style: bangDuLieu))),
                            //
                          ])
                      ],
                    ),
                  ),
                ],
              ),
              DynamicTablePagging(rowCount, currentPageDef, rowPerPage, pageChangeHandler: (currentPage) {
                setState(() {
                  getListTTSFuture = getListTTS(currentPage);
                  currentPageDef = currentPage;
                });
              }, rowPerPageChangeHandler: (rowPerPageChange) {
                setState(() {
                  rowPerPage = rowPerPageChange;
                  getListTTSFuture = getListTTS(currentPageDef);
                });
              })
            ],
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        // By default, show a loading spinner.
        return const CircularProgressIndicator();
      },
    );
  }
}

class LichSuTinhThuong extends StatefulWidget {
  final String id;

  const LichSuTinhThuong({Key? key, required this.id}) : super(key: key);
  @override
  State<LichSuTinhThuong> createState() => LichSuTinhThuongState();
}

class LichSuTinhThuongState extends State<LichSuTinhThuong> {
  late int rowCount = 0;
  int currentPageDef = 1;
  int rowPerPage = 5;
  var listTinhThuong;
  late Future<dynamic> getListTTSFuture;
  Future<dynamic> getListTTS(currentPage) async {
    var response = await httpGet("/api/ctv-lichsu-thanhtoan/get/page?sort=payDate,desc&filter=ttsId:${widget.id}", context);
    if (response.containsKey("body")) {
      setState(() {
        listTinhThuong = jsonDecode(response["body"])['content'];
      });
      rowCount = jsonDecode(response["body"])['totalElements'];
    }
    return 0;
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
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DataTable(
                      showCheckboxColumn: false,
                      columns: [
                        DataColumn(
                            label: Expanded(
                                child: Text(
                          'STT',
                          style: titleTableData,
                          textAlign: TextAlign.center,
                        ))),
                        DataColumn(
                            label: Expanded(
                                child: Text(
                          'Ng??y th??ng',
                          style: titleTableData,
                          textAlign: TextAlign.center,
                        ))),
                        DataColumn(
                            label: Expanded(
                                child: Text(
                          'S??? t??i kho???n',
                          style: titleTableData,
                          textAlign: TextAlign.center,
                        ))),
                        DataColumn(
                            label: Expanded(
                                child: Text(
                          'Ng??n h??ng',
                          style: titleTableData,
                          textAlign: TextAlign.center,
                        ))),
                        DataColumn(
                            label: Expanded(
                                child: Text(
                          'T??n ch??? t??i kho???n',
                          style: titleTableData,
                          textAlign: TextAlign.center,
                        ))),
                        DataColumn(
                            label: Expanded(
                                child: Text(
                          'S??? TTS\n???? xu???t c???nh',
                          style: titleTableData,
                          textAlign: TextAlign.center,
                        ))),
                        DataColumn(
                            label: Expanded(
                                child: Text(
                          '????n gi??',
                          style: titleTableData,
                          textAlign: TextAlign.center,
                        ))),
                        DataColumn(
                            label: Expanded(
                                child: Text(
                          'Th?????ng KM',
                          style: titleTableData,
                          textAlign: TextAlign.center,
                        ))),
                        DataColumn(
                            label: Expanded(
                                child: Text(
                          'T???ng ti???n',
                          style: titleTableData,
                          textAlign: TextAlign.center,
                        ))),
                      ],
                      rows: <DataRow>[
                        for (var row in listTinhThuong)
                          DataRow(cells: [
                            DataCell(Center(child: SelectableText("${tableIndex++}"))),
                            DataCell(Center(child: SelectableText(dateReverse(displayDateTimeStamp(row['payDate'])), style: bangDuLieu))),
                            DataCell(Center(child: SelectableText(row['bankNumber'], style: bangDuLieu))),
                            DataCell(Center(child: SelectableText(row['bankName'], style: bangDuLieu))),
                            DataCell(Center(child: SelectableText(row['bankAccountName'], style: bangDuLieu))),
                            DataCell(Center(child: SelectableText(row['ttsFlightTotal'].toString(), style: bangDuLieu))),
                            DataCell(Center(child: SelectableText(row['ttsPriceUnit'].toString(), style: bangDuLieu))),
                            DataCell(Center(child: SelectableText(row['promotTotal'].toString(), style: bangDuLieu))),
                            DataCell(Center(child: SelectableText(row['totalAmount'].toString(), style: bangDuLieu))),

                            //
                          ])
                      ],
                    ),
                  ),
                ],
              ),
              DynamicTablePagging(rowCount, currentPageDef, rowPerPage, pageChangeHandler: (currentPage) {
                setState(() {
                  getListTTSFuture = getListTTS(currentPage);
                  currentPageDef = currentPage;
                });
              }, rowPerPageChangeHandler: (rowPerPageChange) {
                setState(() {
                  rowPerPage = rowPerPageChange;
                  getListTTSFuture = getListTTS(currentPageDef);
                });
              })
            ],
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        // By default, show a loading spinner.
        return const CircularProgressIndicator();
      },
    );
  }
}
