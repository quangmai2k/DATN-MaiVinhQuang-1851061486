import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/navigation.dart';
import 'package:gentelella_flutter/widgets/ui/source_information/common_ource_information/constant.dart';
import 'package:provider/provider.dart';
import '../../../../api.dart';
import '../../../../common/dynamic_table.dart';
import '../../../../common/style.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/model.dart';

class DanhSachDonHangTTN extends StatelessWidget {
  const DanhSachDonHangTTN({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: DanhSachDonHangTTNBody());
  }
}

class DanhSachDonHangTTNBody extends StatefulWidget {
  const DanhSachDonHangTTNBody({Key? key}) : super(key: key);

  @override
  State<DanhSachDonHangTTNBody> createState() => _DanhSachDonHangTTNBodyState();
}

class _DanhSachDonHangTTNBodyState extends State<DanhSachDonHangTTNBody> {
  final String url = "danh-sach-don-hang-ttn/thong-tin-tts-phu-hop";
  TextEditingController orderController = TextEditingController();

  late List listSelectedRow;
  List<dynamic> idSelectedList = [];
  // List<bool> _selectedDataRow = [];
  late Future<dynamic> futureListOrder;
  String condition = ""; //Tình trạng
  var page;
  var listOrder; //Danh sách đơn hàng
  int rowCount = 0;
  int currentPageDef = 1;
  int rowPerPage = 10;
  //seachAndPageChange
  var searchRequest = "";
  var resultList = [];
  var content = [];
  Future<dynamic> pageChange(page) async {
    var response;
    if (searchRequest.isEmpty) {
      response = await httpGet(
          "/api/donhang/get/page?page=${page - 1}&size=$rowPerPage&sort=orderUrgent,desc&filter=orderStatusId:2 and stopProcessing:0 and nominateStatus:0",
          context);
    } else {
      response = await httpGet(
          "/api/donhang/get/page?page=${page - 1}&size=$rowPerPage&sort=orderUrgent,desc&filter=orderStatusId:2 and stopProcessing:0 and nominateStatus:0 $searchRequest",
          context);
    }
    var body = jsonDecode(response['body'] ?? []);
    if (response.containsKey("body")) {
      setState(() {
        content = body['content'];
        rowCount = body["totalElements"];
        rowCount = body["totalElements"];
        // _selectedDataRow = List<bool>.generate(content.length, (int index) => false);
      });
      listOrder = body;
      idSelectedList.clear();
      return body;
    } else {
      throw Exception("failse");
    }
  }

  //--Search theo trạng thái thức tập sinh--
  var optionListTTSStatus = {"-1": "Tất cả"};

  //-- Lấy id thực tập sinh để tiến cử
  String? idTTSRecommend;

  //-- Search nghiệp đoàn--
  var optionListSyndication = {"-1": "Tất cả"};
  //--Lấy id đơn hàng
  int? idSyndication = -1;
  getSyndication() async {
    var response = await httpGet("/api/nghiepdoan/get/page?sort=id", context);
    if (response.containsKey("body")) {
      // print("trangthai$response");
      var body = jsonDecode(response["body"]);
      if (body.containsKey("content")) {
        var content = body['content'];
        for (int i = 0; i < content.length; i++) {
          setState(() {
            optionListSyndication['${content[i]['id']}'] = content[i]['orgName'];
            // print("aaaaaaaaa");
            // print(optionListSyndication);
          });
        }
      }
    }
  }

  //-- Search Xí nghiệp--
  var optionListCompany = {"-1": "Tất cả"};
  //--Lấy id đơn hàng
  int? companyId = -1;
  getCompany() async {
    var response = await httpGet("/api/xinghiep/get/page?sort=id", context);
    if (response.containsKey("body")) {
      // print("trangthai$response");
      var body = jsonDecode(response["body"]);
      if (body.containsKey("content")) {
        var content = body['content'];
        for (int i = 0; i < content.length; i++) {
          setState(() {
            optionListCompany['${content[i]['id']}'] = content[i]['companyName'];
            // print("aaaaaaaaa");
            // print(optionListCompany);
          });
        }
      }
    }
  }

  //-- Search nghành nghề--
  var optionListjob = {"-1": "Tất cả"};
  //--Lấy id nghành nghề
  int? jobId = -1;
  getJob() async {
    var response = await httpGet("/api/nganhnghe/get/page?sort=id", context);
    if (response.containsKey("body")) {
      // print("trangthai$response");
      var body = jsonDecode(response["body"]);
      if (body.containsKey("content")) {
        var content = body['content'];
        for (int i = 0; i < content.length; i++) {
          setState(() {
            optionListjob['${content[i]['id']}'] = content[i]['jobName'];
            // print("aaaaaaaaa");
            // print(optionListjob);
          });
        }
      }
    }
  }

  @override
  void initState() {
    futureListOrder = pageChange(0);
    getSyndication();
    getCompany();
    getJob();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: userRule(DANH_SACH_DON_HANG_TTN, context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return Consumer<NavigationModel>(
            builder: (context, navigationModel, child) => ListView(
              children: [
                TitlePage(
                  listPreTitle: [
                    {'url': THONG_TIN_NGUON, 'title': 'Dashboard'},
                  ],
                  content: 'Danh sách đơn hàng',
                ),
                Container(
                  color: backgroundPage,
                  padding: EdgeInsets.symmetric(vertical: verticalPaddingPage, horizontal: horizontalPaddingPage),
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
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                TextFieldValidated(
                                  label: 'Đơn hàng',
                                  type: 'none',
                                  height: 40,
                                  controller: orderController,
                                  hint: "Tên hoặc mã đơn hàng",
                                  enter: () {
                                    searchRequest =
                                        "and (orderName~'*${orderController.text.trim()}*' or orderCode~'*${orderController.text.trim()}*')";
                                    futureListOrder = pageChange(1);
                                  },
                                ),
                                SizedBox(width: 50),
                                DropDownButtonWidgetV2(
                                  labelDropDown: Text('Xí nghiệp', style: titleWidgetBox),
                                  // widgetBox: Container(),
                                  functionDropDown: (value) {
                                    setState(() {
                                      companyId = int.tryParse(value);
                                    });
                                  },
                                  selectedValues: {'-1': 'Tất cả'},
                                  listOption: optionListCompany,
                                ),
                                Expanded(flex: 2, child: Container()),
                              ],
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                DropDownButtonWidgetV2(
                                  labelDropDown: Text('Nghiệp đoàn', style: titleWidgetBox),
                                  // widgetBox: Container(),
                                  functionDropDown: (value) {
                                    setState(() {
                                      idSyndication = int.tryParse(value);
                                    });
                                  },
                                  selectedValues: {'-1': 'Tất cả'},
                                  listOption: optionListSyndication,
                                ),
                                SizedBox(width: 50),
                                DropDownButtonWidgetV2(
                                  labelDropDown: Text('Ngành nghề', style: titleWidgetBox),
                                  // widgetBox: Container(),
                                  functionDropDown: (value) {
                                    setState(() {
                                      jobId = int.tryParse(value);
                                    });
                                  },
                                  selectedValues: {'-1': 'Tất cả'},
                                  listOption: optionListjob,
                                ),
                                Expanded(flex: 2, child: Container()),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(30, 30, 0, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  //tìm kiếm
                                  Container(
                                    margin: EdgeInsets.only(left: 20),
                                    child: TextButton.icon(
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 20.0,
                                          horizontal: 10.0,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5.0),
                                        ),
                                        backgroundColor: Color.fromRGBO(245, 117, 29, 1),
                                        primary: Theme.of(context).iconTheme.color,
                                        textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 20.0, letterSpacing: 2.0),
                                      ),
                                      onPressed: () {
                                        var x = "";
                                        searchRequest = "and orderName~'*${orderController.text.trim()}*'";
                                        // searchRequest = "orderName~'*${orderController.text}*' and jobId:$jobId and orgId:$idSyndication and companyId:$companyId";
                                        if (companyId != -1) x += " and companyId:$companyId";
                                        if (jobId != -1) x += " and jobId:$jobId";
                                        if (idSyndication != -1) x += " and orgId:$idSyndication";
                                        searchRequest += x;
                                        futureListOrder = pageChange(1);
                                      },
                                      icon: Transform.rotate(
                                        angle: 270,
                                        child: Icon(
                                          Icons.search,
                                          color: Colors.white,
                                          size: 15,
                                        ),
                                      ),
                                      label: Row(
                                        children: [
                                          Text('Tìm kiếm ', style: textButton),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      FutureBuilder(
                        future: futureListOrder,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var tableIndex = (currentPageDef - 1) * rowPerPage + 1;
                            return Container(
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
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Đơn hàng',
                                        style: titleBox,
                                      ),
                                      Text(
                                        'Kết quả tìm kiếm: $rowCount',
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
                                  Container(
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: DataTable(
                                                showCheckboxColumn: false,
                                                columnSpacing: MediaQuery.of(context).size.width < 1600 ? 10 : 25,
                                                dataRowHeight: MediaQuery.of(context).size.width < 1600 ? 70 : 60,
                                                columns: [
                                                  DataColumn(label: Text('STT', style: titleTableData)),
                                                  DataColumn(label: Text('Mã đơn hàng', style: titleTableData)),
                                                  DataColumn(label: Text('Tên đơn hàng', style: titleTableData)),
                                                  DataColumn(label: Text('Nghiệp đoàn', style: titleTableData)),
                                                  DataColumn(
                                                      label: MediaQuery.of(context).size.width > 1200
                                                          ? Text('Ngành nghề xin visa', style: titleTableData)
                                                          : Text('Ngành nghề \n xin visa', style: titleTableData)),
                                                  DataColumn(label: Text('TTS phù hợp', style: titleTableData)),
                                                  DataColumn(label: Center(child: Text('Hành động ', style: titleTableData))),
                                                ],
                                                rows: <DataRow>[
                                                  for (int i = 0; i < listOrder["content"].length; i++)
                                                    DataRow(
                                                      cells: <DataCell>[
                                                        DataCell(SelectableText("${tableIndex++}")),
                                                        DataCell(
                                                          SelectableText(listOrder["content"][i]["orderCode"] ?? "", style: bangDuLieu),
                                                        ),
                                                        DataCell(
                                                          Container(
                                                            width: MediaQuery.of(context).size.width < 1600
                                                                ? MediaQuery.of(context).size.width * 0.15
                                                                : MediaQuery.of(context).size.width * 0.2,
                                                            child: SelectableText(listOrder["content"][i]["orderName"], style: bangDuLieu),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Container(
                                                            width: MediaQuery.of(context).size.width < 1600
                                                                ? MediaQuery.of(context).size.width * 0.1
                                                                : MediaQuery.of(context).size.width * 0.15,
                                                            child: SelectableText(listOrder["content"][i]["nghiepdoan"]["orgName"] ?? "",
                                                                style: bangDuLieu),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          SelectableText(listOrder["content"][i]["nganhnghe"]["jobName"] ?? "", style: bangDuLieu),
                                                        ),
                                                        DataCell(
                                                          Container(
                                                              child: TextButton(
                                                            style: TextButton.styleFrom(
                                                              padding: paddingBtn,
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: borderRadiusBtn,
                                                              ),
                                                              backgroundColor: backgroundColorBtn,
                                                              primary: Theme.of(context).iconTheme.color,
                                                              textStyle:
                                                                  Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                                            ),
                                                            onPressed: () {
                                                              navigationModel.add(pageUrl: "/thong-tin-tts-phu-hop/${listOrder["content"][i]['id']}");
                                                            },
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Text(' Gợi ý', style: textButton),
                                                              ],
                                                            ),
                                                          )),
                                                        ),
                                                        DataCell(
                                                          (getRule(listRule.data, Role.Xem, context))
                                                              ? Row(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    Center(
                                                                      child: Container(
                                                                        child: Tooltip(
                                                                          message: "Xem chi tiết",
                                                                          child: InkWell(
                                                                            onTap: () {
                                                                              navigationModel.add(
                                                                                  pageUrl: "/xem-chi-tiet-don-hang/${listOrder["content"][i]['id']}");
                                                                              // Provider.of<NavigationModel>(context, listen: false)
                                                                              //     .add(pageUrl: "/thong-tin-don-hang/${listOrder["content"][i]['id']}");
                                                                            },
                                                                            child: Icon(Icons.visibility),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                              : Container(),
                                                        ),
                                                        //
                                                      ],
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        DynamicTablePagging(rowCount, currentPageDef, rowPerPage, pageChangeHandler: (currentPage) {
                                          setState(() {
                                            futureListOrder = pageChange(currentPage);
                                            currentPageDef = currentPage;
                                          });
                                        }, rowPerPageChangeHandler: (rowPerPageChange) {
                                          currentPageDef = 1;

                                          rowPerPage = rowPerPageChange;
                                          futureListOrder = pageChange(currentPageDef);
                                          setState(() {});
                                        })
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Text('${snapshot.error}');
                          }
                          return const Center(child: CircularProgressIndicator());
                          // return Container();
                        },
                      ),
                      Footer(paddingFooter: paddingBoxContainer, marginFooter: EdgeInsets.only(top: 30)),
                    ],
                  ),
                ),
              ],
            ),
          );

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
