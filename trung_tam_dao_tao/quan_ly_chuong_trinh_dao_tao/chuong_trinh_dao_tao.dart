import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../api.dart';
import '../../../../common/dynamic_table.dart';
import '../../../../common/style.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/model.dart';

import '../../navigation.dart';

class ChuongTrinhDaoTao extends StatefulWidget {
  final String id;
  const ChuongTrinhDaoTao({Key? key, required this.id}) : super(key: key);

  @override
  State<ChuongTrinhDaoTao> createState() => _ChuongTrinhDaoTaoState();
}

class _ChuongTrinhDaoTaoState extends State<ChuongTrinhDaoTao> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
        widgetBody: ChuongTrinhDaoTaoBody(
      id: widget.id,
    ));
  }
}

class ChuongTrinhDaoTaoBody extends StatefulWidget {
  final String id;
  const ChuongTrinhDaoTaoBody({Key? key, required this.id}) : super(key: key);

  @override
  State<ChuongTrinhDaoTaoBody> createState() => _ChuongTrinhDaoTaoBodyState();
}

class _ChuongTrinhDaoTaoBodyState extends State<ChuongTrinhDaoTaoBody> {
  var listCTDT = {};
  var ctdt;
  late Future<dynamic> getCtdtFuture;
  Future<dynamic> getCTDT() async {
    var response =
        await httpGet("/api/daotao-chuongtrinh/get/" + widget.id, context);
    if (response.containsKey("body")) {
      ctdt = jsonDecode(response["body"]);
      return ctdt;
    } else {
      throw Exception("Failse to load ctdt");
    }
  }

  Future<dynamic> getListCTDT() async {
    await getCTDT();
    var response1 = await httpGet(
        "/api/daotao-chuongtrinh/get/page?filter=parentId:" +
            widget.id.toString(),
        context);
    if (response1.containsKey("body")) {
      listCTDT = jsonDecode(response1["body"]);
      return listCTDT;
    } else {
      throw Exception("failse to load list ctdt");
    }
  }

  void initState() {
    getCtdtFuture = getListCTDT();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: getCtdtFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // print(ctdt);
          return ListView(
            children: [
              TitlePage(
                listPreTitle: [
                  {'url': '/bang-thong-ke-nhanh', 'title': 'Dashboard'},
                  {
                    'url': '/quan-ly-chuong-trinh-dao-tao',
                    'title': 'Quản lý chương trình đào tạo'
                  }
                ],
                content: "Chi tiết chương trình đào tạo",
              ),
              Container(
                width: MediaQuery.of(context).size.width * 1,
                padding: paddingTitledPage,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
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
                              child: Column(children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SelectableText(
                                      'Thông tin chương trình đào tạo',
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
                                                  'Danh mục:',
                                                  style: titleWidgetBox,
                                                )),
                                            Expanded(
                                              flex: 7,
                                              child: SelectableText(
                                                ctdt['name'],
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                            Expanded(
                                                child: Container(), flex: 2),
                                          ],
                                        )),
                                    Expanded(
                                        flex: 5,
                                        child: Row(
                                          children: [
                                            Expanded(
                                                flex: 2,
                                                child: SelectableText(
                                                  'Thời gian:',
                                                  style: titleWidgetBox,
                                                )),
                                            Expanded(
                                              flex: 3,
                                              child: SelectableText(
                                                ctdt['courseTime'] ?? 'nodata',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                            Expanded(
                                                flex: 5, child: Container())
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
                                                  'File bài giảng:',
                                                  style: titleWidgetBox,
                                                )),
                                            Expanded(
                                                flex: 7,
                                                child: ctdt['fileUrl'] != null
                                                    ? TextButton(
                                                        onPressed: () {
                                                          downloadFile(
                                                              ctdt['fileUrl']);
                                                        },
                                                        child: Text(
                                                            'File bài giảng'))
                                                    : Text('Không có file')),
                                            Expanded(
                                                child: Container(), flex: 2),
                                          ],
                                        )),
                                    Expanded(flex: 5, child: Container())
                                  ],
                                ),
                                SizedBox(
                                  height: 50,
                                )
                              ]),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 1,
                              margin: marginTopBoxContainer,
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
                                        'Bài giảng',
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
                                          child: DSBaiGiang(
                                        listCTDT: listCTDT,
                                      )),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ])
                    ]),
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

class DSBaiGiang extends StatefulWidget {
  final dynamic listCTDT;
  const DSBaiGiang({Key? key, this.listCTDT}) : super(key: key);

  @override
  State<DSBaiGiang> createState() => _DSBaiGiangState();
}

class _DSBaiGiangState extends State<DSBaiGiang> {
  var listCTDT;

  @override
  void initState() {
    listCTDT = widget.listCTDT;

    super.initState();
  }

  String hinhThucDanhGia(int displayScore, int showPassResult) {
    if (displayScore == 1 && showPassResult == 1) {
      return 'Hiển thị điểm & hiển thị kết quả (Đạt/Không đạt)';
    } else if (displayScore == 1 && showPassResult == 0) {
      return 'Hiển thị điểm';
    } else if (displayScore == 0 && showPassResult == 1) {
      return 'Hiển thị kết quả (Đạt/Không đạt)';
    } else {
      return '';
    }
  }

  int rowCount = 0;
  int currentPage = 1;
  int rowPerPage = 10;
  var firstRow;
  var lastRow;
  @override
  Widget build(BuildContext context) {
    rowCount = widget.listCTDT['content'].length;
    firstRow = (currentPage - 1) * rowPerPage;
    lastRow = currentPage * rowPerPage - 1;
    if (lastRow > rowCount - 1) {
      lastRow = rowCount - 1;
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DataTable(
                  columns: [
                    DataColumn(
                        label: Expanded(
                            child:
                                SelectableText('Bài', style: titleTableData))),
                    DataColumn(
                        label: Expanded(
                            child: SelectableText('Hình thức đánh giá',
                                style: titleTableData))),
                    DataColumn(
                        label: Expanded(
                            child: SelectableText('File bài giảng',
                                style: titleTableData))),
                  ],
                  rows: <DataRow>[
                    if (listCTDT['content'] != null)
                      for (int i = firstRow; i <= lastRow; i++)
                        DataRow(cells: <DataCell>[
                          DataCell(SelectableText(
                              listCTDT['content'][i]['name'],
                              style: bangDuLieu)),
                          DataCell(SelectableText(
                              hinhThucDanhGia(
                                  listCTDT['content'][i]['displayScore'],
                                  listCTDT['content'][i]['showPassResult']),
                              style: bangDuLieu)),
                          DataCell(listCTDT['content'][i]['fileUrl'] != null
                              ? TextButton(
                                  onPressed: () {
                                    downloadFile(
                                        listCTDT['content'][i]['fileUrl']);
                                  },
                                  child: Text('File bài giảng'))
                              : Text('Không có file')),
                        ])
                  ],
                  columnSpacing: 20,
                  horizontalMargin: 10,
                  dataRowHeight: 60,
                ),
              ),
            ],
          ),
          DynamicTablePagging(rowCount, currentPage, rowPerPage,
              pageChangeHandler: (currentPageCallBack) {
            setState(() {
              currentPage = currentPageCallBack;
            });
          }, rowPerPageChangeHandler: (rowPerPageChange) {
            currentPage = 1;
            rowPerPage = rowPerPageChange;
            print(rowPerPage);
            setState(() {});
          }),
        ],
      ),
    );
  }
}
